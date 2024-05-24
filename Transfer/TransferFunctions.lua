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

return TransferFunctions
