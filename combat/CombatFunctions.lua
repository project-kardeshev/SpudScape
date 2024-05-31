CombatFunctions = CombatFunctions or {}

-- Helper function to check if a table contains a particular value
function table.contains(tbl, element)
    for _, value in pairs(tbl) do
        if value == element then
            return true
        end
    end
    return false
end

-- Utility function to deep copy tables
local function DeepCopy(original)
    local copy = {}
    for key, value in pairs(original) do
        if type(value) == 'table' then
            copy[key] = DeepCopy(value)
        else
            copy[key] = value
        end
    end
    return copy
end

function CombatFunctions.IsPartyInCombat(TokenID)
    -- Retrieve the token
    local token = GeneralFunctions.GetTokenByID(TokenID)
    assert(token, "Token not found")

    -- Check if the token itself is in combat
    if State.ActiveCombat[tostring(TokenID)] then
        return true
    end

    -- If the token has a party, check each party member
    if token.Party then
        for _, partyMemberID in ipairs(token.Party) do
            if State.ActiveCombat[tostring(partyMemberID)] then
                return true
            end
        end
    end

    -- If neither the token nor any of its party members are in combat, return false
    return false
end

function CombatFunctions.EnterCombat(msg)
    assert(msg.Tags.FromToken, "Improperly formatted message")
    local isInCombat = CombatFunctions.IsPartyInCombat(msg.Tags.FromToken)
    assert(not isInCombat, "Already in combat")

    local owner = GeneralFunctions.GetOwner(tonumber(msg.Tags.FromToken))
    assert(owner == msg.From, "Unauthorized")

    local token = GeneralFunctions.GetTokenByID(tonumber(msg.Tags.FromToken))
    if not token then
        error("Token not found")
    end

    local currentLocation = token.Location

    local possibleEnemies = {}
    for npcName, npcData in pairs(CombatNPCList) do
        if npcData.Locations and table.contains(npcData.Locations, currentLocation) then
            table.insert(possibleEnemies, npcData)
        end
    end

    if #possibleEnemies == 0 then
        error("No enemies found at this location")
    end

    local selectedEnemy = possibleEnemies[math.random(#possibleEnemies)]

    -- Create a table for the combat instance
    local combatInstance = {
        Player = {},
        NPC = { ["1"] = DeepCopy(selectedEnemy) },
        StartHeight = msg["Block-Height"],
        LastAction = msg["Block-Height"]
    }

    -- Function to add a player's token to the combat instance
    local function addPlayerTokenToCombat(playerToken)
        local playerCombatToken = DeepCopy(playerToken)
        playerCombatToken.Attacks = DeepCopy(playerCombatToken.Attacks) or {}
        for _, eqType in ipairs({ "Weapon", "Armor", "Accessory" }) do
            local equipment = playerToken.Equipment and playerToken.Equipment[eqType]
            if equipment and next(equipment) then -- Check if the equipment is not an empty table
                for stat, value in pairs(equipment.Stats or {}) do
                    playerCombatToken.Stats[stat] = (playerCombatToken.Stats[stat] or 0) + value
                end
                for attackName, attackDetails in pairs(equipment.GivesAttacks or {}) do
                    playerCombatToken.Attacks[attackName] = DeepCopy(attackDetails)
                end
            end
        end
        combatInstance.Player[tostring(playerCombatToken.TokenID)] = playerCombatToken
    end

    -- Add the main player's token to the combat instance
    addPlayerTokenToCombat(token)

    -- Add party members' tokens to the combat instance
    if token.Party then
        for _, partyMemberID in ipairs(token.Party) do
            local partyMemberToken = GeneralFunctions.GetTokenByID(partyMemberID)
            if partyMemberToken then
                addPlayerTokenToCombat(partyMemberToken)
            end
        end
    end

    State.ActiveCombat[tostring(msg.Tags.FromToken)] = combatInstance
    print("Combat initiated between " ..
        combatInstance.Player[tostring(token.TokenID)].Name .. " and " .. combatInstance.NPC["1"].Name)
    Send({
        Target = msg.From,
        Action = "CombatInfo",
        IsEndCombat = "false",
        CombatState = json.encode(combatInstance),
        Data = "Combat initiated between " ..
            combatInstance.Player[tostring(token.TokenID)].Name .. " and " .. combatInstance.NPC["1"].Name
    })
end

function CombatFunctions.DetermineFirstAttacker(playerParty, npcParty)
    -- Collect all combatants with their speeds
    local combatants = {}

    for tokenID, player in pairs(playerParty) do
        table.insert(combatants, { tokenID = tokenID, speed = player.Stats.Speed, type = "Player" })
    end

    for npcID, npc in pairs(npcParty) do
        table.insert(combatants, { tokenID = npcID, speed = npc.Stats.Speed, type = "NPC" })
    end

    -- Sort combatants by speed in descending order
    table.sort(combatants, function(a, b) return a.speed > b.speed end)

    return combatants
end

function CombatFunctions.DoesAttackLand(attacker, defender, attack)
    print("Determining accuracy")
    print("attacker")
    print(attacker)
    local attackerPrecision = attacker.Stats.Precision
    local attackAccuracy = attack.Accuracy
    print("defender")
    print(defender)
    local defenderEvasion = defender.Stats.Evasion

    local baseChanceToHit = 50 + (attackerPrecision + attackAccuracy - defenderEvasion) * 5
    local randomFactor = math.random(80, 120) / 100 -- This factor adds variability
    local finalChanceToHit = baseChanceToHit * randomFactor

    print("Final chance to hit is " .. finalChanceToHit)

    if finalChanceToHit >= 50 then
        print("Attack lands!")
        return true
    else
        print("Attack misses!")
        return false
    end
end

function CombatFunctions.DetermineDamage(attacker, attack, defender)
    local attackerPower = attacker.Stats.Power
    local attackForce = attack.Force
    local defenderDefense = defender.Stats.Defense

    local attackRandomFactor = math.random(1, 10)
    local defenseRandomFactor = math.random(1, 10)

    local attackValue = attackerPower * attackForce * attackRandomFactor
    local effectiveDefense = defenderDefense * defenseRandomFactor

    local damage = attackValue / effectiveDefense
    damage = math.floor(damage)

    if damage < 1 and damage > 0 then
        damage = 1
    end

    print(string.format("Damage calculated: %d (Attack: %d, Defense: %d)", damage, attackValue, effectiveDefense))
    return damage
end

function CombatFunctions.FinalizeCombat(combatKey, winner, loser, XP)
    local owner = GeneralFunctions.GetOwner(combatKey)
    local message
    local messageList = State.ActiveCombat[combatKey]["NPC"]["1"].Messages

    if winner == "Player" then
        message = messageList.OnDefeated
        local playerTokens = State.ActiveCombat[combatKey]["Player"]
        local numPlayers = 0
        local alivePlayers = 0
        local deadPlayers = 0

        for _, playerToken in pairs(playerTokens) do
            numPlayers = numPlayers + 1
            if playerToken.Stats.Health > 0 then
                alivePlayers = alivePlayers + 1
            else
                deadPlayers = deadPlayers + 1
            end
        end

        local baseXP = math.floor(XP / numPlayers)
        local aliveXP = baseXP
        local deadXP = math.floor(baseXP / 2)

        for _, playerToken in pairs(playerTokens) do
            if playerToken.Stats.Health > 0 then
                playerToken.CurrentXP = playerToken.CurrentXP + aliveXP
            else
                playerToken.CurrentXP = playerToken.CurrentXP + deadXP
            end

            if playerToken.CurrentXP >= playerToken.LevelUpXP then
                GeneralFunctions.LevelUp(playerToken)
            end

            print(playerToken.Name .. " gains XP: " .. playerToken.CurrentXP .. "/" .. playerToken.LevelUpXP)
        end

        print("Player wins! XP distributed among party members.")
    else
        print("NPC wins! " .. State.ActiveCombat[combatKey].Player.Name .. " has been defeated.")
        message = messageList.OnPlayerDefeated
    end

    print("Combat ended. Removing combat instance for TokenID: " .. combatKey)
    State.ActiveCombat[combatKey] = nil
    print("message is: " .. message)
    Send({ Target = owner, Action = "CombatInfo", IsEndCombat = "true", Data = message })
end

function CombatFunctions.SelectNPCAttack(npcParty)
    local npcAttacks = {}
    for npcID, npc in pairs(npcParty) do
        local npcAttackKeys = {}
        for attackName, _ in pairs(npc.Attacks) do
            table.insert(npcAttackKeys, attackName)
        end
        local randomIndex = math.random(#npcAttackKeys)
        npcAttacks[npcID] = npc.Attacks[npcAttackKeys[randomIndex]]
    end
    return npcAttacks
end

function CombatFunctions.ProcessAttack(msg)
    local combatKey = tostring(msg.Tags.FromToken)
    assert(State.ActiveCombat[combatKey], "No active combat found for the given token.")
    local owner = GeneralFunctions.GetOwner(tonumber(msg.Tags.FromToken))
    assert(owner == msg.From, "Sender is not the owner of the token.")

    local combatInstance = State.ActiveCombat[combatKey]

    local attacks = {}
    if msg.Tags.Attack then
        for tokenID, attackName, target in msg.Tags.Attack:gmatch("(%d+)%s*=%s*([^:]+)%s*:*(%d*)") do
            attackName = attackName:match("^%s*(.-)%s*$") -- Trim whitespace from attack name
            target = target and target ~= "" and target or tostring(math.random(#combatInstance.NPC))
            attacks[tokenID] = { attack = attackName, target = target }
        end
    elseif msg.Tags.Attacks then
        print("Parsing Attacks: " .. msg.Tags.Attacks)
        for tokenID, attackName, target in msg.Tags.Attacks:gmatch("(%d+)%s*=%s*([^:]+)%s*:*(%d*)") do
            attackName = attackName:match("^%s*(.-)%s*$") -- Trim whitespace from attack name
            target = target and target ~= "" and target or tostring(math.random(#combatInstance.NPC))
            attacks[tokenID] = { attack = attackName, target = target }
        end
    end

    print("Attack list")
    for k, v in pairs(attacks) do
        print(k, v.attack, v.target)
    end

    assert(#attacks == #combatInstance.Player,
        "The number of attacks specified does not match the number of active players in combat.")

    -- Validate attacks
    for tokenID, attackInfo in pairs(attacks) do
        local token = combatInstance.Player[tokenID]
        assert(token, "Token not part of the combat")
        assert(token.Stats.Health > 0, "Cannot attack with a dead token")
        assert(token.Attacks[attackInfo.attack], "Attack not available for token")
    end

    local XPOnWin = combatInstance.NPC["1"].GivesXP
    print("Selecting first attacker")
    local combatOrder = CombatFunctions.DetermineFirstAttacker(combatInstance.Player, combatInstance.NPC)
    print("First attacker selected")
    print("Selecting NPC attack")
    local npcAttacks = CombatFunctions.SelectNPCAttack(combatInstance.NPC)
    print("NPC attack selected")

    local events = {}
    local npcAttacked = {}

    local playerTokens = {}
    for tokenID in pairs(combatInstance.Player) do
        table.insert(playerTokens, tokenID)
    end

    for i, combatant in ipairs(combatOrder) do
        print("Entering Combat loop # " .. i)
        if combatant.type == "Player" then
            local attackerInfo = combatInstance.Player[combatant.tokenID]
            local attackName = attacks[combatant.tokenID].attack
            local targetID = attacks[combatant.tokenID].target
            local attack = attackerInfo.Attacks[attackName]
            print("Determining accuracy for loop " .. i)
            local attackLands = CombatFunctions.DoesAttackLand(attackerInfo, combatInstance.NPC[targetID], attack)
            print("accuracy determined for loop " .. i)
            if attackLands then
                print("Determining Damage for loop " .. i)
                local damage = CombatFunctions.DetermineDamage(attackerInfo, attack, combatInstance.NPC[targetID])
                print("Damage determined for loop " .. i)
                print("Referencing Stats for health removal")
                combatInstance.NPC[targetID].Stats.Health = combatInstance.NPC[targetID].Stats.Health - damage
                print("Health removed")
                events[#events + 1] = attackerInfo.Name ..
                    " attacked " ..
                    combatInstance.NPC[targetID].Name .. " with " .. attackName .. " and dealt " .. damage .. " damage."
                print("Checking if NPC is dead")
                if combatInstance.NPC[targetID].Stats.Health <= 0 then
                    print(combatInstance.NPC[targetID].Name .. " has been defeated.")
                    print("Finalizing combat in loop " .. i)
                    CombatFunctions.FinalizeCombat(combatKey, "Player", "NPC", XPOnWin)
                    return "Combat ended. " .. combatInstance.NPC[targetID].Name .. " defeated."
                end
            else
                events[#events + 1] = attackerInfo.Name ..
                    " attacked " .. combatInstance.NPC[targetID].Name .. " with " .. attackName .. " and missed."
            end
        else
            print("entering the else block")
            if not npcAttacked[combatant.tokenID] then
                npcAttacked[combatant.tokenID] = true
                print("npc attacks")
                print(npcAttacks)
                local npc = combatInstance.NPC[combatant.tokenID]
                local attackName = npcAttacks[combatant.tokenID].Name
                print("choosing attack")
                local chosenAttack = npcAttacks[combatant.tokenID]
                print("getting targetID")
                local targetID = tostring(playerTokens[math.random(#playerTokens)])
                print("Target id is : " .. targetID)
                local playerToken = combatInstance.Player[targetID]
                print(playerToken)
                if playerToken and playerToken.Stats.Health > 0 then
                    print("Does NPC attack land?")
                    local attackLands = CombatFunctions.DoesAttackLand(npc, playerToken, chosenAttack)
                    print(attackLands)
                    if attackLands then
                        local damage = CombatFunctions.DetermineDamage(npc, chosenAttack, playerToken)
                        playerToken.Stats.Health = playerToken.Stats.Health - damage
                        events[#events + 1] = npc.Name ..
                            " attacked " ..
                            playerToken.Name ..
                            " with " .. attackName .. " and dealt " .. damage .. " damage."
                        if playerToken.Stats.Health <= 0 then
                            print(playerToken.Name .. " has been defeated.")
                            -- Handle player defeat
                        end
                    else
                        events[#events + 1] = npc.Name ..
                            " attacked " ..
                            playerToken.Name .. " with " .. attackName .. " and missed."
                    end
                end
            end
        end
    end

    -- Send the summary message of the round if combat did not end
    if State.ActiveCombat[combatKey] then -- Check if the combat instance still exists
        local message = table.concat(events, " ")
        Send({
            Target = msg.From,
            Action = "CombatInfo",
            IsEndCombat = "false",
            CombatState = json.encode(combatInstance),
            Data = message
        })
    end

    return "Round completed. Both combatants still alive."
end



return CombatFunctions
