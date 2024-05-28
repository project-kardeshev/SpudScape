
NonCombatNPCList = NonCombatNPCList or {}

NonCombatNPCList.OldWoodsGuy = {
    Name = "Weird Old Guy",
    Location = "Woods",
    Responses = {
        A = "It's dangerous to go alone, take this.",
        B = "What do you want from me? You already have my coolest stick!"
    },
    Action = function(msg)
        local tokenID = msg.Tags.FromToken
        local holder = GeneralFunctions.GetOwner(tokenID)
        local hasStick = false

        -- Check if the holder's inventory exists in the State
        if State.Holders[holder] then
            for _, item in ipairs(State.Holders[holder]) do
                if item.Name == "Cool Looking Stick" then
                    hasStick = true
                    break
                end
            end
        end

        if hasStick then
            Send({ Target = holder, Action = "NPC-Interaction", Data = NonCombatNPCList.OldWoodsGuy.Responses["B"] })
        else
            -- Perform actions since the stick was not found
            print("Performing action as the stick was not found.")
            Send({ Target = holder, Action = "NPC-Interaction", Data = NonCombatNPCList.OldWoodsGuy.Responses["A"] })
            -- Additional logic here if the player does not have the stick
            EquipmentMintFunctions.SpecialMint(tokenID, "Cool Looking Stick")
        end
    end
}

NonCombatNPCList.Constable = {
    Name = "Constable",
    Location = "Town",
    Responses = { A = "Don't go wandering into the woods alone. It's dangerous out there!", },
    Action = function(msg)
        Send({Target = msg.From, Action = "NPC-Interaction", Data = NonCombatNPCList.Constable.Responses["A"]})
    end
}




return NonCombatNPCList
