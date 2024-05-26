TransferFunctions = TransferFunctions or {}

function TransferFunctions.UpdateFundingStatus(oldOffer, newOffer)
    local oldFunded = oldOffer.Funded
    local newOfferAmount = newOffer.Offer

    -- Calculate the difference between the new offer and the old offer
    local difference = newOfferAmount - oldOffer.Offer

    if newOffer.Funded > 0 then
        -- If the new offer is higher than the old one, update the funded amount
        if difference > 0 then
            newOffer.Funded = oldFunded
            -- Perform additional actions for higher new offer
            -- Example: deduct the difference from buyer's account or handle funds transfer
            print("New offer is higher, previous funded amount carried over.")
            Send({
                Target = newOffer.Buyer,
                Action = "Market-Notice",
                Data = "Your new offer on Token: " ..
                    newOffer.TokenID ..
                    " has been registered. Please fund the difference from your previously funded amount by transfering " ..
                    tostring(difference) .. " to this process."
            })
        else
            -- Perform additional actions for lower new offer
            -- Example: refund the difference to buyer's account
            print("New offer is lower, handle fund adjustments.")
        end
    end
end

function TransferFunctions.MakeOffer(msg)
    assert(msg.TokenID, "Must Specify Token")
    assert(msg.Offer, "Must provide amount for offer")
    assert(tonumber(msg.Offer), "Offer amount must be a number")

    local tokenOwner = GeneralFunctions.GetOwner(msg.TokenID)
    assert(msg.From ~= tokenOwner, "Cannot make offers on Tokens you own.")
    local newOffer = {
        TokenID = msg.TokenID,
        Owner = tokenOwner,
        Accepted = false,
        Funded = 0, -- Default state for Funded is 0
        Buyer = msg.From,
        Offer = tonumber(msg.Offer)
    }


    -- Ensure State.TransferOffers.Buy is initialized
    if not State.TransferOffers.Buy then
        State.TransferOffers.Buy = {}
    end

    -- Get current buy offers for the specified token, or initialize it if not present
    local currentBuyOffers = State.TransferOffers.Buy[msg.TokenID] or {}

    -- Check if there's an existing offer with the same token and quantity
    for _, existingOffer in ipairs(currentBuyOffers) do
        if existingOffer.Offer == newOffer.Offer then
            error("An offer for this token with the same quantity already exists.")
        end
    end

    -- Check if there's an existing offer from the same buyer
    local offerUpdated = false
    for i, existingOffer in ipairs(currentBuyOffers) do
        if existingOffer.Buyer == msg.From then
            -- Update the existing offer and call UpdateFundingStatus
            TransferFunctions.UpdateFundingStatus(existingOffer, newOffer)
            currentBuyOffers[i] = newOffer
            offerUpdated = true
            break
        end
    end

    -- If no existing offer from the same buyer was found, add the new offer
    if not offerUpdated then
        table.insert(currentBuyOffers, newOffer)
    end

    -- Update the offers table in the state
    State.TransferOffers.Buy[msg.TokenID] = currentBuyOffers

    return "Offer of " ..
        tostring(newOffer.Offer) .. " for token " .. tostring(newOffer.TokenID) .. " created successfully"
end

function TransferFunctions.WithdrawBuyOffer(msg)
    assert(msg.TokenID, "Must specify Token ID")
    assert(msg.From, "Must specify the buyer")

    local currentBuyOffers = State.TransferOffers.Buy[msg.TokenID]
    if not currentBuyOffers then
        print("No current buy offers for this token")
        return
    end

    for i, offer in ipairs(currentBuyOffers) do
        if offer.Buyer == msg.From then
            local funded = offer.Funded
            table.remove(currentBuyOffers, i)
            print("Offer withdrawn")
            -- Optionally, you can send a message back to the buyer confirming the withdrawal
            Send({ Target = msg.From, Action = "Info-Message", Data = "Your offer has been withdrawn." })
            Send({
                Target = KARD_Process,
                Action = "Transfer",
                Recipient = msg.From,
                Quantity = tostring(funded),
                Note =
                "Refund for withdrawn offer."
            })
            return
        end
    end

    print("No matching offer found to withdraw")
    -- Optionally, you can send a message back to the buyer indicating no offer was found
    Send({ Target = msg.From, Action = "Error", Data = "No matching offer found to withdraw." })
end

function TransferFunctions.AcceptBuyOffer(msg)
    assert(msg.TokenID, "Must Specify Token")
    assert(msg.Quantity, "Must provide quantity for offer")
    assert(tonumber(msg.Quantity), "Quantity must be a number")

    local tokenID = msg.TokenID
    local quantity = tonumber(msg.Quantity)
    local from = msg.From

    -- Verify the offer exists for the selected tokenID at the provided quantity
    local currentBuyOffers = State.TransferOffers.Buy[tokenID] or {}
    local selectedOffer = nil

    for _, offer in ipairs(currentBuyOffers) do
        if offer.Offer == quantity then
            selectedOffer = offer
            break
        end
    end

    if not selectedOffer then
        error("No offer found for this token with the specified quantity.")
    end

    -- Verify that the sender is the owner of the token
    if from ~= State.Tokens[tokenID].Owner then
        error("You are not the owner of this token.")
    end

    -- Check if the offer is fully funded
    if selectedOffer.Funded < selectedOffer.Offer then
        selectedOffer.Accepted = true
        local remainingAmount = selectedOffer.Offer - selectedOffer.Funded
        Send({
            Target = selectedOffer.Buyer,
            Action = "Info-Message",
            Data = "Your offer has been accepted, but it is not fully funded. You need to fund an additional " ..
                remainingAmount .. " units."
        })
        return "Offer accepted but not fully funded. Buyer notified of remaining amount."
    end

    -- Transfer ownership of the token
    local oldOwner = State.Tokens[tokenID].Owner
    local newOwner = selectedOffer.Buyer
    State.Tokens[tokenID].Owner = newOwner

    -- Find the token in State.Holders[oldOwner] and remove it
    local oldOwnerTokens = State.Holders[oldOwner]
    local actualToken = nil
    if oldOwnerTokens then
        for i, token in ipairs(oldOwnerTokens) do
            if token.TokenID == tonumber(tokenID) then
                -- If the token is a character, check if it has any equipment
                if token.Type == "Character" and token.Equipment and #token.Equipment > 0 then
                    GeneralFunctions.AutoUnequipAll(tostring(tokenID))
                end
                if not token.Type == "Character" and token.EquippedTo then
                    error("Unequip this item before transfer")
                end
                actualToken = token
                if not State.Holders[newOwner] then
                    State.Holders[newOwner] = {}
                end
                table.insert(State.Holders[newOwner], actualToken)
                table.remove(oldOwnerTokens, i)
                break
            end
        end
    end

    -- Ensure the token is a fresh copy to avoid referencing issues

    -- Copy the token to State.Holders[newOwner]


    -- Remove the accepted offer from the list of buy offers
    -- for i, offer in ipairs(currentBuyOffers) do
    --     if offer == selectedOffer then
    --         table.remove(currentBuyOffers, i)
    --         break
    --     end
    -- end

    -- Update the buy offers for the token
    State.TransferOffers.Buy[tokenID] = nil

    -- Notify the buyer that the offer has been accepted and the transfer is complete
    Send({
        Target = selectedOffer.Buyer,
        Action = "Info-Message",
        Data = "Your offer of " ..
            tostring(selectedOffer.Offer) ..
            " for token " .. tostring(tokenID) .. " has been accepted and the transfer is complete."
    })

    local taxes = math.floor(selectedOffer.Offer * 0.025)
    print("taxes: " .. taxes)

    Send({
        Target = KARD_Process,
        Action = "Transfer",
        Recipient = State.Tokens[tokenID].Minter,
        Quantity = tostring(
            taxes),
        Note = "Minter reward on Token Sale."
    })

    local sellerCut = selectedOffer.Offer - (2 * taxes)

    Send({
        Target = KARD_Process,
        Action = "Transfer",
        Recipient = oldOwner,
        Quantity = tostring(sellerCut),
        Note =
        "Purchase of token."
    })

    return "Offer of " .. tostring(selectedOffer.Offer) .. " for token " .. tostring(tokenID) .. " accepted successfully"
end

function TransferFunctions.FreeTransfer(msg)
    assert(msg.TokenID, "Must Specify Token")
    assert(msg.TransferTo, "Must specify the recipient of the transfer")

    local tokenID = msg.TokenID
    local transferTo = msg.TransferTo
    local from = msg.From

    -- Verify that the sender is the owner of the token
    if from ~= State.Tokens[tokenID].Owner then
        error("You are not the owner of this token.")
    end

    -- Transfer ownership of the token
    local oldOwner = State.Tokens[tokenID].Owner
    local tokenType = State.Tokens[tokenID].Type
    local newOwner = transferTo

    if not tokenType == "Character" then
        tokenType = "Equipment"
    end

    -- Find the token in State.Holders[oldOwner] and remove it
    local oldOwnerTokens = State.Holders[oldOwner]
    local tokenToTransfer = nil
    if oldOwnerTokens then
        for i, token in ipairs(oldOwnerTokens) do
            if tonumber(token.TokenID) == tonumber(tokenID) then
                if tokenType == "Equipment" and token.EquippedTo then
                    error("Must unequip before transferring")
                end
                if tokenType == "Character" then
                    GeneralFunctions.AutoUnequipAll(tostring(tokenID))
                end
                tokenToTransfer = table.remove(oldOwnerTokens, i)
                break
            end
        end
    end

    -- Ensure the token to transfer exists
    if not tokenToTransfer then
        error("Token not found in the holder's inventory.")
    end

    -- Copy the token to State.Holders[newOwner]
    if not State.Holders[newOwner] then
        State.Holders[newOwner] = {}
    end
    table.insert(State.Holders[newOwner], tokenToTransfer)
    State.Tokens[tokenID].Owner = newOwner
    -- Notify the recipient of the transfer
    Send({
        Target = newOwner,
        Action = "Info-Message",
        Data = "You have received token " .. tokenID .. " from " .. oldOwner .. "."
    })

    return "Token " .. tokenID .. " has been transferred to " .. newOwner .. " successfully"
end

function TransferFunctions.FundOffer(Buyer, TokenID, Quantity)
    assert(Buyer, "Buyer must be specified")
    assert(TokenID, "TokenID must be specified")
    assert(Quantity and tonumber(Quantity), "Quantity must be a valid number")

    local quantity = tonumber(Quantity)
    local tokenID = tonumber(TokenID) -- Convert TokenID to a number for comparison
    local currentBuyOffers = State.TransferOffers.Buy[tostring(tokenID)] or {}

    local selectedOffer = nil
    print("Attempting to fund offer from " .. Buyer)
    print(currentBuyOffers)

    -- Find the offer from the Buyer for the TokenID
    for _, offer in ipairs(currentBuyOffers) do
        if offer.Buyer == Buyer then
            selectedOffer = offer
            break
        end
    end

    if not selectedOffer then
        Send({
            Target = KARD_Process,
            Action = "Transfer",
            Recipient = Buyer,
            Quantity = Quantity,
            Note = "Refund on Error"
        })
        error("No offer found from the specified Buyer for this TokenID")
    end

    -- Add Quantity to offer.Funded
    selectedOffer.Funded = (selectedOffer.Funded or 0) + quantity

    -- Check if offer.Funded is equal to or greater than offer.Offer
    if selectedOffer.Funded >= selectedOffer.Offer then
        print("Offer is fully funded")
        if selectedOffer.Funded > selectedOffer.Offer then
            local overfundedAmount = tostring(selectedOffer.Funded - selectedOffer.Offer)
            selectedOffer.Funded = selectedOffer.Offer -- Adjust Funded to match the Offer amount
            Send({
                Target = Buyer,
                Action = 'Refund-Notice',
                Data = "Your offer was overfunded. Refunding the excess amount: " .. overfundedAmount
            })
            -- Handle the actual refund
            Send({
                Target = KARD_Process,
                Action = "Transfer",
                Recipient = Buyer,
                Quantity = overfundedAmount,
                Note = "Refund for overfunded offer."
            })
        end

        Send({
            Target = Buyer,
            Action = "Info-Notice",
            Data = "Offer of " ..
                tostring(selectedOffer.Offer) .. " for Token # " .. tostring(tokenID) .. " is fully funded."
        })

        if selectedOffer.Accepted then
            local taxes = math.floor(selectedOffer.Offer * 0.025)
            local sellerCut = selectedOffer.Offer - (2 * taxes)

            local oldOwner = State.Tokens[tokenID].Owner
            local newOwner = selectedOffer.Buyer

            -- Transfer the token
            local oldOwnerTokens = State.Holders[oldOwner] or {}
            local actualToken = nil

            for i, token in ipairs(oldOwnerTokens) do
                if token.TokenID == tokenID then
                    -- Check if the token is equipped and handle unequipping if necessary
                    if token.Type == "Character" and token.Equipment and #token.Equipment > 0 then
                        GeneralFunctions.AutoUnequipAll(tostring(tokenID))
                    end
                    if token.Type ~= "Character" and token.EquippedTo then
                        Send({
                            Target = oldOwner,
                            Action = "Info-Message",
                            Data = "The accepted offer for TokenID " ..
                                tostring(tokenID) ..
                                " has been fully funded, but transfer failed because the item is equipped. Please Unequip and Accept the offer again."
                        })
                        error("Owner must Unequip this item before transfer")
                    end
                    actualToken = token

                    if not State.Holders[newOwner] then
                        State.Holders[newOwner] = {}
                    end
                    table.insert(State.Holders[newOwner], actualToken)
                    State.Tokens[tokenID].Owner = newOwner

                    table.remove(oldOwnerTokens, i)
                    break
                end
            end


            State.TransferOffers.Buy[tostring(tokenID)] = nil

            Send({
                Target = selectedOffer.Buyer,
                Action = "Info-Message",
                Data = "Your offer of " ..
                    tostring(selectedOffer.Offer) ..
                    " for token " .. tostring(tokenID) .. " has been accepted and the transfer is complete."
            })

            -- Handle fund transfers
            Send({
                Target = KARD_Process,
                Action = "Transfer",
                Recipient = State.Tokens[tokenID].Minter,
                Quantity = tostring(taxes),
                Note = "Minter reward on Token Sale."
            })
            Send({
                Target = KARD_Process,
                Action = "Transfer",
                Recipient = oldOwner,
                Quantity = tostring(sellerCut),
                Note = "Purchase of token."
            })
        end
    elseif selectedOffer.Funded < selectedOffer.Offer then
        -- Request more from the buyer
        print("Offer is partially funded. Request more from buyer")
        local remainingAmount = tostring(selectedOffer.Offer - selectedOffer.Funded)
        Send({
            Target = Buyer,
            Action = 'Funding-Request',
            Data = "Your offer is partially funded. Please fund the remaining amount: " .. remainingAmount
        })
        return
    end

    -- Update the offers table in the state
end

return TransferFunctions
