GeneralFunctions = GeneralFunctions or {}

function GeneralFunctions.TalkToNPC(msg)
    assert(msg.Tags.TargetNPC, "Who are you trying to talk to?")
    assert(msg.Tags.FromToken, "Who is trying to talk?")

    -- Initialize variable to hold the NPC once found
    local NPC = nil

    -- Iterate over all NPCs to find the one with the matching Name
    for _, npcDetails in pairs(NonCombatNPCList) do
        if npcDetails.Name == msg.Tags.TargetNPC then
            NPC = npcDetails
            break
        end
    end

    -- Check if the NPC was found
    assert(NPC, "That NPC does not exist.")

    -- Check if the NPC has an action to perform
    if NPC.Action then
        NPC.Action(msg)
    end
end

function GeneralFunctions.Move(msg)
    -- Validate the required fields are present and the target location exists in the system
    assert(msg.Tags.FromToken and msg.Tags.TargetLocation, "Improperly formatted command.")
    assert(Locations[msg.Tags.TargetLocation], "Target location does not exist.")
    local isInCombat = CombatFunctions.IsPartyInCombat(msg.Tags.FromToken)
    assert(not isInCombat, "Cannot flee from combat. We die like men!!")
    -- assert(not State.ActiveCombat[tostring(msg.Tags.FromToken)], "Cannot flee from combat. Real men fight to the death.")
    -- Convert the token identifier from string to number if necessary and fetch the token
    local TokenID = tonumber(msg.Tags.FromToken)
    -- if TokenID then print("TokenID is " .. TokenID) end
    local token = GeneralFunctions.GetTokenByID(tonumber(TokenID))
    -- if token then print(token) end
    -- Check if the token was successfully retrieved
    if not token then
        error("Token not found.")
    end

    -- Retrieve the current location of the token from its data
    local currentLocation = token.Location
    if currentLocation then print(currentLocation) end
    if not currentLocation or not Locations[currentLocation] then
        error("Current location of the token is invalid or not defined.")
    end

    -- Retrieve possible target locations from the current location
    local possibleTargets = Locations[currentLocation].CanMoveTo
    if not possibleTargets then
        error("No possible movement targets defined for the current location.")
    end

    -- Check if the target location is in the list of possible targets
    local isMoveAllowed = false
    for _, location in ipairs(possibleTargets) do
        if location == msg.Tags.TargetLocation then
            isMoveAllowed = true
            break
        end
    end

    if isMoveAllowed then
        print("Move from " .. currentLocation .. " to " .. msg.Tags.TargetLocation .. " is allowed.")
        -- Here you can implement the code to update the token's location in your data structure
        token.Location = msg.Tags.TargetLocation -- Update the token's location
        if token.Party then
            for _, partyMember in ipairs(token.Party) do
                local partyMemberToken = GeneralFunctions.GetTokenByID(partyMember)
                partyMemberToken.Location = msg.Tags.TargetLocation
            end

        end

        Locations[msg.Tags.TargetLocation].ActionOnEnter(msg)

        return "Moved from " .. currentLocation .. " to " .. msg.Tags.TargetLocation
    else
        print("Move from " .. currentLocation .. " to " .. msg.Tags.TargetLocation .. " is not allowed.")
        error("Cannot move to the specified location.")
    end
end

function GeneralFunctions.WhereCanIMove(msg)
    assert(msg.Tags.FromToken, "Improperly formatted command")
    local token = GeneralFunctions.GetTokenByID(msg.Tags.FromToken)
    if not token then return end
    local currentLocation = token.Location

    local CanMoveTo = Locations[currentLocation].CanMoveTo

    if CanMoveTo then
        Send({ Target = msg.From, Action = "Info-Message", Data = json.encode(CanMoveTo) })
    end
end

function GeneralFunctions.LevelUp(token)
    assert(token.CurrentXP, "Current XP is wrong")
    assert(token.LevelUpXP, "Level up xp is wrong")
    local currentXP = token.CurrentXP
    local levelUpXP = token.LevelUpXP
    assert(currentXP >= levelUpXP, "Not enough XP to level up.")
    assert(token.Level < 50, "Token at max level")

    token.AvailableStatPoints = token.AvailableStatPoints + 3

    token.CurrentXP = currentXP - levelUpXP

    token.LevelUpXP = levelUpXP * 5
    token.Level = token.Level + 1
end

function GeneralFunctions.SpendPoint(msg)
    assert(msg.Tags.FromToken, "Must define token")
    local owner = GeneralFunctions.getOwner(msg.Tags.FromToken)
    assert(owner == msg.From, "Unauthorized")
    assert(msg.Tags.SpendOn, "Must define where point to be spent")
    local token = GeneralFunctions.getTokenByID(tonumber(msg.Tags.FromToken))

    if token then
        assert(token.AvailableStatPoints > 0, "No Stat points to spend.")
        token.Stats[msg.Tags.SpendOn] = token.Stats[msg.Tags.SpendOn] + 1
        token.AvailableStatPoints = token.AvailableStatPoints - 1
    else
        error("Token not found.")
    end
end

function GeneralFunctions.Equip(msg)
    assert(msg.Tags.FromToken and msg.Tags.EquipmentID, "Must specify Equipment ID and which token will be equipping")
    assert(State.Tokens[msg.Tags.FromToken] and State.Tokens[msg.Tags.EquipmentID], "Token does not exist")
    assert(State.Tokens[msg.Tags.FromToken].Type == "Character", "Must equip to a character")
    assert(State.Tokens[msg.Tags.FromToken].Owner == msg.From and State.Tokens[msg.Tags.EquipmentID].Owner == msg.From,
        "Must own both tokens to equip")
    -- print("This last one")
    local tokenType = State.Tokens[msg.Tags.EquipmentID].Type
    print(tokenType)
    -- Retrieve the character token to which equipment will be attached
    local characterToken = nil
    for _, item in ipairs(State.Holders[msg.From] or {}) do
        if item.TokenID == tonumber(msg.Tags.FromToken) then
            characterToken = item
            break
        end
    end
    -- print(characterToken)
    local equipmentToken = nil
    for _, item in ipairs(State.Holders[msg.Tags.From] or {}) do
        if item.TokenID == tonumber(msg.Tags.EquipmentID) then
            equipmentToken = item
            break
        end
    end
    -- print(equipmentToken)
    assert(characterToken, "Character token not found in holder's inventory.")
    assert(equipmentToken, "Equipment token not found in holder's inventory")
    assert(equipmentToken.EquippedTo == nil, "Item already equipped.")
    -- Proceed based on the type of equipment
    if tokenType == "Weapon" then
        print("Still Weapon")
        -- Example: attach the weapon
        local slotsNeeded = equipmentToken.SlotsNeeded
        -- TODO: handle multi-hand weapons and dual weilding single hand weapons
        equipmentToken.EquippedTo = tonumber(characterToken.TokenID)
        characterToken.Equipment.Weapon = equipmentToken


        print("Weapon Equipped")
    elseif tokenType == "Armor" then
        -- Handle armor
    elseif tokenType == "Accessory" then
        -- Handle accessory
    else
        error("Invalid equipment type.")
    end
end

function GeneralFunctions.UnEquip(msg)
    assert(msg.Tags.FromToken and msg.Tags.EquipmentID, "Must specify Equipment ID and which token will be Unequipping")
    assert(State.Tokens[msg.Tags.FromToken] and State.Tokens[msg.Tags.EquipmentID], "Token does not exist")
    assert(State.Tokens[msg.Tags.FromToken].Type == "Character", "Must Unequip from a character")
    assert(State.Tokens[msg.Tags.FromToken].Owner == msg.From and State.Tokens[msg.Tags.EquipmentID].Owner == msg.From,
        "Must own both tokens")

    local tokenType = State.Tokens[msg.Tags.EquipmentID].Type
    print(tokenType)

    local characterToken = nil
    for _, item in ipairs(State.Holders[msg.From] or {}) do
        if item.TokenID == tonumber(msg.Tags.FromToken) then
            characterToken = item
            break
        end
    end
    -- print(characterToken)
    local equipmentToken = nil
    for _, item in ipairs(State.Holders[msg.From] or {}) do
        if item.TokenID == tonumber(msg.Tags.EquipmentID) then
            equipmentToken = item
            break
        end
    end

    assert(characterToken, "Character token not found in holder's inventory.")
    assert(equipmentToken, "Equipment token not found in holder's inventory")
    assert(equipmentToken.EquippedTo == tonumber(characterToken.TokenID), "Item not equipped.")

    if tokenType == "Weapon" then
        characterToken.Equipment.Weapon = {}
        equipmentToken.EquippedTo = nil
        print("Unequipped Weapon")
    end
end

function GeneralFunctions.AutoUnequipAll(tokenID)
    assert(State.Tokens[tokenID], "Token does not exist")
    assert(State.Tokens[tokenID].Type == "Character", "Must unequip from a character")

    local characterToken = State.Tokens[tokenID]

    -- Ensure the characterToken exists in State.Holders
    local owner = characterToken.Owner
    local characterInHolders = nil
    for _, item in ipairs(State.Holders[owner] or {}) do
        if item.TokenID == tonumber(tokenID) then
            characterInHolders = item
            break
        end
    end
    assert(characterInHolders, "Character token not found in holder's inventory.")

    -- Check and unequip all items
    for _, equipmentID in ipairs(characterInHolders.Equipment or {}) do
        local equipmentToken = State.Tokens[equipmentID]
        if equipmentToken and equipmentToken.EquippedTo == tonumber(tokenID) then
            equipmentToken.EquippedTo = nil
        end
    end

    -- Clear the character's equipment fields
    characterInHolders.Equipment = {
        Weapon = {},
        Armor = {},
        Accessories = {}
    }

    return "All equipment has been unequipped from character " .. tokenID
end

function GeneralFunctions.Rename(TokenID, newName)
    -- Ensure TokenID is provided and a newName is specified
    assert(TokenID, "TokenID must be provided.")
    assert(type(newName) == "string" and newName ~= "", "A valid new name must be provided.")

    local tokenType = State.Tokens[tostring(TokenID)] and State.Tokens[tostring(TokenID)].Type
    -- Ensure that the token exists and is of type 'Character'
    assert(tokenType == "Character", "Only characters can be renamed")

    -- Retrieve the owner of the token
    local owner = GeneralFunctions.GetOwner(TokenID)
    assert(owner, "No owner found for the given TokenID.")

    -- Find the token in the holder's list
    local tokenFound = false
    for _, item in ipairs(State.Holders[owner] or {}) do
        if tostring(item.TokenID) == tostring(TokenID) then
            -- Rename the token
            item.Name = newName
            tokenFound = true
            print("Token renamed to " .. newName)
            break
        end
    end

    -- Check if the token was found and renamed
    assert(tokenFound, "Token with provided ID not found among the holder's items.")
end

function GeneralFunctions.GetOwner(TokenID)
    -- print(TokenID)
    if State.Tokens and State.Tokens[tostring(TokenID)] then
        -- print(State.Tokens[TokenID])
        local owner = State.Tokens[tostring(TokenID)].Owner
        if owner then
            -- print("Owner found: " .. owner)
            return owner
        else
            print("Owner field is nil for TokenID:", TokenID)
        end
    else
        print("TokenID not found in State.Tokens:", TokenID)
    end
    return nil
end

function GeneralFunctions.GetTokenByID(TokenID)
    -- assert(type(TokenID) == "number", "TokenID must be a number")
    -- Using pcall to safely call getOwner and handle potential errors
    local success, owner = pcall(GeneralFunctions.GetOwner, tonumber(TokenID))
    if not success or owner == nil then
        print("No owner found for the given TokenID: " .. (owner or "Error in getOwner"))
        return nil
    end

    -- Access the array of tokens for the found owner
    local tokens = State.Holders[owner]
    if tokens then
        -- print(tokens)
        for _, token in ipairs(tokens) do
            -- Debug: Print out the token ID to ensure it's accessible
            -- print("Inspecting token with TokenID:", token.TokenID)
            if token.TokenID and token.TokenID == tonumber(TokenID) then
                -- print("Matching token found:" .. json.encode(token))
                return token -- Return the token directly if IDs match
            end
        end
    else
        print("No tokens found for owner:", owner)
    end

    print("Token not found for TokenID:" .. tostring(TokenID))
    return nil -- Return nil if the token is not found
end

function GeneralFunctions.GetTokens(owner)
    print(owner)
    -- print(State.Holders[owner])
    return State.Holders[owner]
end

function GeneralFunctions.WhoCanIFight(locationName)
    print("Enemy list requested for " .. locationName)
    -- Assert that the location exists in the Locations table
    assert(Locations[locationName], "Invalid location name provided.")

    -- Only proceed if the location can enter combat
    if not Locations[locationName].CanEnterCombat then
        return {}
    end

    local fightList = {}
    -- Iterate over the NPCList to find NPCs that can be fought at the given location
    for npcName, npcDetails in pairs(CombatNPCList) do
        for _, loc in ipairs(npcDetails.Locations) do
            if loc == locationName then
                -- Add NPC name and level to the fight list if they can be fought at the location
                table.insert(fightList, { Name = npcName, Level = npcDetails.Level })
                break
            end
        end
    end

    return fightList
end

function GeneralFunctions.SetParty(msg)
    assert(msg.Tags.Party, "Must define party")
    assert(type(msg.Tags.Party) == "string", "Party must be a string")
    print("Received party string:" .. msg.Tags.Party)

    -- Split the party string into individual numbers
    local partyMembers = {}
    for number in msg.Tags.Party:gmatch("[^,]+") do
        local num = tonumber(number:match("^%s*(.-)%s*$")) -- Trim spaces and convert to number
        assert(num, "Party must be a string of numbers separated by commas")
        assert(State.Tokens[tostring(num)].Owner == msg.From, "Only tokens you own can be in your party")
        assert(State.Tokens[tostring(num)].Type == "Character", "Equipment cannot join your party")
        table.insert(partyMembers, num)
    end

    -- Add FromToken to partyMembers if not already included
    local fromTokenID = tonumber(msg.FromToken)
    local isIncluded = false
    for _, member in ipairs(partyMembers) do
        if member == fromTokenID then
            isIncluded = true
            break
        end
    end

    if not isIncluded then
        table.insert(partyMembers, fromTokenID)
    end

    print("Party members extracted:" .. table.concat(partyMembers, ", "))

    assert(#partyMembers >= 2 and #partyMembers <= 5, "Parties must be 2 - 5 members.")

    -- Fetch the current token
    local currentToken = GeneralFunctions.GetTokenByID(msg.FromToken)
    assert(currentToken, "Current token not found")

    -- Fetch and validate each member of the new party
    local partyTokens = {}
    for _, member in ipairs(partyMembers) do
        print("Party member:" .. member)
        local token = GeneralFunctions.GetTokenByID(member)
        print("Got the token")
        assert(token and token.Location == "Tavern", "Can only set parties if all members are in the Tavern")
        partyTokens[member] = token
    end
    print("all tokens found")

    -- Remove current token from old parties
    if currentToken.Party then
        print("Current party exists, doing things")
        for _, partyMemberID in ipairs(currentToken.Party) do
            local oldPartyMemberToken = GeneralFunctions.GetTokenByID(partyMemberID)
            if oldPartyMemberToken and oldPartyMemberToken.Party then
                for i = #oldPartyMemberToken.Party, 1, -1 do
                    if oldPartyMemberToken.Party[i] == currentToken.TokenID then
                        table.remove(oldPartyMemberToken.Party, i)
                        if #oldPartyMemberToken.Party < 1 then
                            oldPartyMemberToken.Party = nil
                        end
                    end
                end
            end
        end
    end

    print("Setting party on current token")
    -- Set the new party for the current token, excluding its own TokenID
    print(currentToken)
    local newParty = {}
    for _, member in ipairs(partyMembers) do
        if member ~= fromTokenID then
            table.insert(newParty, member)
        end
    end
    currentToken.Party = newParty

    -- Update each member in the new party to include the current token
    for _, member in ipairs(partyMembers) do
        print("attempting to set party for " .. member)
        local token = partyTokens[member]
        if token ~= currentToken then
            if not token.Party then
                token.Party = {}
            end
            table.insert(token.Party, currentToken.TokenID)
        end
    end
    return "Successfully set a new party with " .. tostring(table.concat(partyMembers, ", "))
end

return GeneralFunctions
