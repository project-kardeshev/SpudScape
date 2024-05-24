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
            Send({ Target = newOffer.Buyer, Action = "Market-Notice", Data = "Your new offer on Token: " ..
            newOffer.TokenID ..
            " has been registered. Please fund the difference from your previously funded amount by transfering " ..
            tostring(difference) .. " to this process." })
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

    return "Offer of " .. newOffer.Offer .. " for token " .. newOffer.TokenID .. " created successfully"
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
            table.remove(currentBuyOffers, i)
            print("Offer withdrawn")
            -- Optionally, you can send a message back to the buyer confirming the withdrawal
            Send({ Target = msg.From, Action = "OfferWithdrawn", Data = "Your offer has been withdrawn." })
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

    -- Transfer ownership of the token
    local oldOwner = State.Tokens[tokenID].Owner
    local newOwner = selectedOffer.Buyer
    State.Tokens[tokenID].Owner = newOwner

    -- Find the token in State.Holders[oldOwner] and remove it
    local oldOwnerTokens = State.Holders[oldOwner]
    if oldOwnerTokens then
        for i, token in ipairs(oldOwnerTokens) do
            if token.TokenID == tokenID then
                -- If the token is a character, check if it has any equipment
                if token.Type == "Character" and token.Equipment and #token.Equipment > 0 then
                    -- TODO: handle unequip
                end
                table.remove(oldOwnerTokens, i)
                break
            end
        end
    end

    -- Ensure the token is a fresh copy to avoid referencing issues
    local newToken = {
        TokenID = State.Tokens[tokenID].TokenID,
        Owner = State.Tokens[tokenID].Owner,
        Type = State.Tokens[tokenID].Type,
        -- Add other token properties here
    }

    -- Copy the token to State.Holders[newOwner]
    if not State.Holders[newOwner] then
        State.Holders[newOwner] = {}
    end
    table.insert(State.Holders[newOwner], newToken)

    -- Remove the accepted offer from the list of buy offers
    for i, offer in ipairs(currentBuyOffers) do
        if offer == selectedOffer then
            table.remove(currentBuyOffers, i)
            break
        end
    end

    -- Update the buy offers for the token
    State.TransferOffers.Buy[tokenID] = currentBuyOffers

    -- TODO: handle transferring funds

    return "Offer of " .. selectedOffer.Offer .. " for token " .. tokenID .. " accepted successfully"
end




return TransferFunctions
