
CharacterMintFunctions = CharacterMintFunctions or {}

function CharacterMintFunctions.GetCost(rarity)
    local baseCost = State.BaseCosts[rarity]
    local modifier = State.priceModifiers[rarity]
    local count = State.MintNumbers[rarity]

    local cost = baseCost
    for i = 1, count do
        cost = cost * modifier
    end
    return cost
end

function CharacterMintFunctions.InitializeCharacterMint(msg)
    print("This is the first step")
    assert(msg.Rarity, "Please define the rarity of the character you want to mint.")
    assert(msg.From and msg['Block-Height'], "Missing necessary minting parameters.")

    local rarity = msg.Rarity
    local cost = CharacterMintFunctions.GetCost(rarity)
    local mintOffer = {
        Minter = msg.From,
        BlockStamp = msg['Block-Height'],
        -- Offers are good for about 1 hour
        BlockDeadline = msg['Block-Height'] + 30,
        Rarity = rarity,
        Cost = cost
    }

    -- Check if there are already pending mints for this user
    if State.PendingMints[msg.From] then
        -- Check for an existing offer of the same rarity
        for _, offer in ipairs(State.PendingMints[msg.From]) do
            if offer.Rarity == rarity then
                error("You cannot have two pending offers of the same rarity at the same time.")
            end
        end
        -- If no existing offer is found, insert the new offer
        table.insert(State.PendingMints[msg.From], mintOffer)
    else
        -- If no pending mints exist for this user, create a new list with this offer
        State.PendingMints[msg.From] = { mintOffer }
    end

    -- Notify the user about the minting process
    Send({
        Target = msg.From,
        Data = "You have successfully started the minting process for a new " .. rarity ..
            " character. Please send " ..
            cost .. " $KARD to finalize the mint. This offer is good for 30 blocks, or about 1 hour."
    })
end

function CharacterMintFunctions.RevokeCharacterOffer(msg)
    assert(State.PendingMints[msg.From], "You have no pending character mints.")

    if msg.Rarity then
        -- If rarity is specified, remove only the specific offer
        local found = false
        for i, offer in ipairs(State.PendingMints[msg.From]) do
            if offer.Rarity == msg.Rarity then
                tabType = selectedToken.InitialState.Type,le.remove(State.PendingMints[msg.From], i)
                found = true
                Send({ Target = msg.From, Data = "Your pending mint offer for a " ..
                msg.Rarity .. " character has been revoked." })
                break
            end
        end
        assert(found, "No pending offer found with the specified rarity.")
    else
        -- If no rarity is specified, remove all offers for the user
        State.PendingMints[msg.From] = nil
        Send({ Target = msg.From, Data = "All pending offers have been revoked." })
    end
end

-- Utility function to validate character stats against the schema
local function ValidateStats(stats)
    for key, rule in pairs(CharacterSchema.Stats) do
        local value = stats[key]

        -- Check if required value is missing
        if value == nil and rule.required then
            return false, key .. " is required."
        end

        -- Handle number type with min and max bounds
        if value and rule.type == "number" then
            if type(value) ~= "number" or value < rule.min or value > rule.max then
                return false, key .. " must be a number between " .. rule.min .. " and " .. rule.max .. "."
            end
        end

        -- Handle string type with enumerated values
        if value and rule.type == "string" then
            if type(value) ~= "string" then
                return false, key .. " must be a string."
            end
            if rule.enum and not tableContains(rule.enum, value) then
                return false, key .. " must be one of the following: " .. table.concat(rule.enum, ", ") .. "."
            end
        end
    end
    return true
end

-- Helper function to check if a value exists in a table
function TableContains(table, value)
    for _, v in ipairs(table) do
        if v == value then
            return true
        end
    end
    return false
end


-- Function to generate a character based on rarity
function CharacterMintFunctions.GenerateCharacter(rarity)
    local tokens = CharacterBlueprints.TokenClasses.Character.Tokens
    local matchedTokens = {}
    for key, token in pairs(tokens) do
        if token.Rarity == rarity then
            table.insert(matchedTokens, token)
        end
    end

    -- Randomly select one of the matched tokens
    local selectedToken = matchedTokens[math.random(#matchedTokens)]

    -- Construct the full character data
    local characterData = {
        Name = selectedToken.InitialState.Name,
        TokenID = State.NextID,
        Type = selectedToken.InitialState.Type,
        Description = selectedToken.InitialState.Description,
        Level = CharacterBlueprints.TokenClasses.Character.LevelStats.Level,
        CurrentXP = CharacterBlueprints.TokenClasses.Character.LevelStats.CurrentXP,
        LevelUpXP = CharacterBlueprints.TokenClasses.Character.LevelStats.LevelUpXP,
        Skills = CharacterBlueprints.TokenClasses.Character.Skills,
        Attacks = {
            Punch = {
                Name = "Punch",
                Force = 1,
                Affinity = "none",
                Accuracy = 2
            }
        },
        Stats = {},
        Location = "Town",
        AvailableStatPoints = 0,
        Equipment = CharacterBlueprints.TokenClasses.Character.Equipment
    }

    -- Merge base stats and token-specific stats
    for _, stat in ipairs(selectedToken.InitialState.Stats) do
        characterData.Stats[stat.name] = stat.value
    end

    -- Validate the generated character data against the schema
    local isValid, errorMessage = ValidateStats(characterData.Stats)
    if not isValid then
        error("Validation failed: " .. errorMessage)
    end

    return characterData
end

function CharacterMintFunctions.MintCharacter(msg)
assert(msg.Sender and msg.Quantity and msg['Block-Height'], "This does not fit the required message schema for minting")
assert(State.PendingMints[msg.Sender], "You have no pending mint offers.")

print("received the mint final request")
local offers = State.PendingMints[msg.Sender]
local offerFound = false
local newCharacter
for i, offer in ipairs(offers) do
    if tonumber(msg.Quantity) == offer.Cost then
        if msg['Block-Height'] > offer.BlockDeadline then
            -- If the offer has expired
            table.remove(offers, i) -- Remove the expired offer
            error("The minting offer has expired.")
        else
            -- Attempt to generate the character
            local success, newCharacterOrErrorMessage = pcall(CharacterMintFunctions.GenerateCharacter, offer.Rarity)
            if not success then
                -- Handle the error, newCharacterOrErrorMessage will contain the error message
                print("Failed to generate character: " .. newCharacterOrErrorMessage)
            else
                -- If successful, handle the new character
                newCharacter = newCharacterOrErrorMessage
                print("Character generated successfully!")

                -- Update mint numbers
               
                State.MintNumbers[offer.Rarity] = (State.MintNumbers[offer.Rarity] or 0) + 1
                 local currentMint = State.NextID
                State.NextID = State.NextID + 1

                -- Ensure the sender has a holder list and append the new character
                if not State.Holders[msg.Sender] then
                    State.Holders[msg.Sender] = {}
                end
                Token = {
                    TokenID = currentMint,
                    Type = "Character",
                    Owner = msg.Sender,
                    Minter = msg.Sender
                }
                State.Tokens[tostring(currentMint)] = Token
                table.insert(State.Holders[msg.Sender], newCharacter)
                Send({Target = msg.Sender, Action = "Creation-Notice", Data = "Congratulations! You have succesfully minted a new character!"})

                -- Successfully handled the offer, so remove it
                table.remove(offers, i)
                offerFound = true
                break
            end
        end
    end
end

-- Clean up the PendingMints table if there are no more offers for this user
if offerFound and #offers == 0 then
    State.PendingMints[msg.Sender] = nil
    print("All pending offers for " .. msg.Sender .. " have been processed and removed.")
end

if not offerFound then
    error("No valid offer found matching the sent quantity.")
end
end


return CharacterMintFunctions
