
CombatFunctions = CombatFunctions or {}

-- Helper function to check if a table contains a particular value
function table.contains(table, element)
    for _, value in pairs(table) do
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

function CombatFunctions.EnterCombat(msg)
    assert(msg.FromToken, "Improperly formatted message")
    assert(not State.ActiveCombat[tostring(msg.FromToken)], "Already in combat")
    local owner = GeneralFunctions.getOwner(tonumber(msg.FromToken))
    assert(owner == msg.From, "Unauthorized")
    local token = GeneralFunctions.getTokenByID(tonumber(msg.FromToken))
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
    local combatInstance = {
        Player = DeepCopy(token),      -- Deep copy the player's token
        NPC = DeepCopy(selectedEnemy), -- Deep copy the selected NPC
        StartHeight = msg["Block-Height"],
        LastAction = msg["Block-Height"]
    }

    -- Incorporating equipment stats and attacks into the combat instance
    combatInstance.Player.Attacks = DeepCopy(combatInstance.Player.Attacks) or {}
    for _, eqType in ipairs({ "Weapon", "Armor", "Accessory" }) do
        local equipment = token.Equipment and token.Equipment[eqType]
        if equipment and next(equipment) then -- Check if the equipment is not an empty table
            for stat, value in pairs(equipment.Stats or {}) do
                combatInstance.Player.Stats[stat] = (combatInstance.Player.Stats[stat] or 0) + value
            end
            for attackName, attackDetails in pairs(equipment.GivesAttacks or {}) do
                combatInstance.Player.Attacks[attackName] = DeepCopy(attackDetails)
            end
        end
    end

    State.ActiveCombat[tostring(msg.FromToken)] = combatInstance
    print("Combat initiated between " .. combatInstance.Player.Name .. " and " .. combatInstance.NPC.Name)
    Send({
        Target = msg.From,
        Action = "CombatInfo",
        IsEndCombat = "false",
        CombatState = json.encode(combatInstance),
        Data = "Combat initiated between " .. combatInstance.Player.Name .. " and " .. combatInstance.NPC.Name
    })
end

function CombatFunctions.DetermineFirstAttacker(player, npc)
    local playerSpeed = player.Stats.Speed -- This might later include modifications
    local npcSpeed = npc.Stats.Speed       -- Same as above

    if playerSpeed > npcSpeed then
        return "Player"
    elseif npcSpeed > playerSpeed then
        return "NPC"
    else
        -- If speeds are equal, decide randomly or by another attribute
        return math.random() < 0.5 and "Player" or "NPC"
    end
end

function CombatFunctions.DoesAttackLand(combatInstance, whoseTurn, attack)
    -- Determine the attacker and defender using Lua's and/or pattern
    local attacker = (whoseTurn == "Player") and combatInstance.Player or combatInstance.NPC
    local defender = (whoseTurn == "Player") and combatInstance.NPC or combatInstance.Player

    local attackerPrecision = attacker.Stats.Precision
    local attackAccuracy = attack.Accuracy
    local defenderEvasion = defender.Stats.Evasion

    -- Modify the base chance to hit to incorporate a more favorable early game hit chance
    -- The adjustment ensures that low values still provide a reasonable chance to hit
    local baseChanceToHit = 50 + (attackerPrecision + attackAccuracy - defenderEvasion) * 5
    local randomFactor = math.random(80, 120) / 100 -- This factor adds variability
    local finalChanceToHit = baseChanceToHit * randomFactor

    -- Debug output to see the calculated values
    print("Final chance to hit is " .. finalChanceToHit)

    -- Define a threshold for hitting, adjusted for better early game performance
    if finalChanceToHit >= 50 then
        print("Attack lands!")
        return true
    else
        print("Attack misses!")
        return false
    end
end

function CombatFunctions.DetermineDamage(attacker, attack, defender)
    -- Retrieve the necessary combat stats
    local attackerPower = attacker.Stats.Power
    local attackForce = attack.Force
    local defenderDefense = defender.Stats.Defense

    -- Generate random factors for the attack and defense
    local attackRandomFactor = math.random(1, 10)
    local defenseRandomFactor = math.random(1, 10)

    -- Calculate the preliminary attack value
    local attackValue = attackerPower * attackForce * attackRandomFactor

    -- Calculate the effective defense
    local effectiveDefense = defenderDefense * defenseRandomFactor

    -- Determine the final damage value
    local damage = attackValue / effectiveDefense

    -- Round down the damage to the nearest whole number
    damage = math.floor(damage)

    -- Ensure damage is at least 1 unless it is 0 (to prevent negative or zero damage while ensuring some impact)
    if damage < 1 and damage > 0 then
        damage = 1
    end

    print(string.format("Damage calculated: %d (Attack: %d, Defense: %d)", damage, attackValue, effectiveDefense))
    return damage
end

function CombatFunctions.FinalizeCombat(combatKey, winner, loser, XP)
    local owner = GeneralFunctions.getOwner(combatKey)
    local message
    local messageList = State.ActiveCombat[combatKey]["NPC"].Messages
    if winner == "Player" then
        local playerToken = GeneralFunctions.GetTokenByID(tonumber(State.ActiveCombat[combatKey]["Player"].TokenID))
        message = messageList.OnDefeated
        if playerToken then
            playerToken.CurrentXP = playerToken.CurrentXP + XP
            if playerToken.CurrentXP >= playerToken.LevelUpXP then
                GeneralFunctions.LevelUp(playerToken)
            end
            print("Player wins! New XP: " .. playerToken.CurrentXP .. "/" .. playerToken.LevelUpXP)
            -- Send({ Target = owner, Action = "CombatInfo", Data = "Player won the battle! Gained " .. tostring(XP) .. " XP."})
        else
            error("Player token not found.")
            -- Send({ Target = owner, Action = "CombatInfo", Data = "Player was defeated by " .. State.ActiveCombat[combatKey]["NPC"].Name .. ". Maybe you should try getting some better equipment."})
        end
    else
        print("NPC wins! " .. State.ActiveCombat[combatKey].Player.Name .. " has been defeated.")
        message = messageList.OnPlayerDefeated
    end

    -- Remove the combat instance
    print("Combat ended. Removing combat instance for TokenID: " .. combatKey)
    State.ActiveCombat[combatKey] = nil
    print("message is: " .. message)
    Send({ Target = owner, Action = "CombatInfo", IsEndCombat = "true", Data = message })
end

function CombatFunctions.SelectNPCAttack(npcAttacks)
    local npcAttackKeys = {}
    for attackName, _ in pairs(npcAttacks) do
        table.insert(npcAttackKeys, attackName)
    end
    local randomIndex = math.random(#npcAttackKeys)
    return npcAttacks[npcAttackKeys[randomIndex]]
end

function CombatFunctions.ProcessAttack(msg)
    local combatKey = tostring(msg.FromToken)
    assert(State.ActiveCombat[combatKey], "No active combat found for the given token.")
    local owner = GeneralFunctions.GetOwner(tonumber(msg.FromToken))
    assert(owner == msg.From, "Sender is not the owner of the token.")

    local combatInstance = State.ActiveCombat[combatKey]
    local playerAttack = assert(combatInstance.Player.Attacks[msg.Attack], "Specified attack is not available.")
    print("Processing player's attack: " .. msg.Attack)

    local XPOnWin = combatInstance["NPC"].GivesXP
    local firstAttacker = CombatFunctions.DetermineFirstAttacker(combatInstance.Player, combatInstance.NPC)
    local secondAttacker = (firstAttacker == "Player") and "NPC" or "Player"

    local npcAttack = CombatFunctions.SelectNPCAttack(combatInstance.NPC.Attacks)
    print("NPC's randomly selected attack: " .. npcAttack.Name)

    local events = {}
    local attackers = {
        Player = { combatant = combatInstance.Player, attack = playerAttack },
        NPC = { combatant = combatInstance.NPC, attack = npcAttack }
    }

    for _, turn in ipairs({ firstAttacker, secondAttacker }) do
        local attackerInfo = attackers[turn]
        local defenderInfo = attackers[(turn == "Player") and "NPC" or "Player"]
        local attackLands = CombatFunctions.DoesAttackLand(combatInstance, turn, attackerInfo.attack)

        if attackLands then
            local damage = CombatFunctions.DetermineDamage(attackerInfo.combatant, attackerInfo.attack,
                defenderInfo.combatant)
            defenderInfo.combatant.Stats.Health = defenderInfo.combatant.Stats.Health - damage
            events[#events + 1] = turn ..
            " attacked with " .. attackerInfo.attack.Name .. " and dealt " .. damage .. " damage."
            if defenderInfo.combatant.Stats.Health <= 0 then
                print(defenderInfo.combatant.Name .. " has been defeated.")
                CombatFunctions.FinalizeCombat(combatKey, turn, (turn == "Player") and "NPC" or "Player", XPOnWin)
                return "Combat ended. " .. defenderInfo.combatant.Name .. " defeated."
            end
        else
            events[#events + 1] = turn .. " attacked with " .. attackerInfo.attack.Name .. " and missed."
        end
    end

    -- Send the summary message of the round if combat did not end
    if State.ActiveCombat[combatKey] then -- Check if the combat instance still exists
        local message = table.concat(events, " ")
        Send({ Target = msg.From, Action = "CombatInfo", IsEndCombat = "false", CombatState = json.encode(combatInstance), Data =
        message })
    end

    return "Round completed. Both combatants still alive."
end

return CombatFunctions
