local CharacterMintFunctions = require("Minting.CharacterMintFunctions")
local EqupmentMintFunctions = require("Minting.EquipmentMintFunctions")
local State = require("State")
local CombatFunctions = require("combat.CombatFunctions")
local GeneralFunctions = require("utils.General")
local NonCombatNPCList = require("NonCombatResources.NonCombatNPC")
local CombatNPCList = require("combat.NPC")
local Locations = require("locations.Locations")
local CharacterSchemas = require("Schemas.Character")
local EquipmentSchemas = require("Schemas.Equipment")
local CharacterBlueprints = require("TokenBlueprints.Characters")
local EquipmentBlueprints = require("TokenBlueprints.Equipment")
local TransferFunctions = require("Transfer.TransferFunctions")

json = require("json")


function IsMintMessage(msg)
    if msg.Action == "Credit-Notice" then
        return true
    else
        return 0
    end
end

-- Character mint handlers

Handlers.add(
    "InitiateCharacterMint",
    Handlers.utils.hasMatchingTag("Action", "MintCharacter"),
    function(msg)
        print("Received mint request")
        -- Using pcall to handle errors in InitiateCharacterMint
        local success, errorMessage = pcall(CharacterMintFunctions.InitializeCharacterMint, msg)
        if not success then
            print("Error processing mint request: " .. errorMessage)
        end
    end
)


Handlers.add(
    "ProcessMintPayment",
    IsMintMessage,
    function(msg)
        print("Received mint request")
        -- Using pcall to handle errors in InitiateCharacterMint
        local success, errorMessage = pcall(CharacterMintFunctions.MintCharacter, msg)
        if not success then
            print("Error processing mint final request: " .. errorMessage)
        end
    end
)



Handlers.add(
    "WithdrawCharacterMint",
    Handlers.utils.hasMatchingTag("Action", "WithdrawCharacterMint"),
    CharacterMintFunctions.RevokeCharacterOffer
)

-- Get Token Info Handlers

Handlers.add(
    "GetTokenByID",
    Handlers.utils.hasMatchingTag("Action", "GetTokenByID"),
    function(msg)
        if msg.TokenID then
            -- print(msg)
            -- print(msg.TokenID)
            -- Using pcall to handle the potential error in GetTokenByID
            local success, tokenOrError = pcall(GeneralFunctions.GetTokenByID, tonumber(msg.TokenID))
            -- print(success)
            if success then
                -- If pcall succeeds, tokenOrError contains the returned token
                Send({ Target = msg.From, Action = "Token-Data", Data = json.encode(tokenOrError) })
            else
                print(success)
                -- If pcall fails, tokenOrError contains the error message
                print("Error retrieving token: " .. tokenOrError)
                -- Optionally send a failure notification to the requester
                Send({ Target = msg.From, Action = "Error", Data = "Failed to retrieve token data: " .. tokenOrError })
            end
        else
            print("TokenID is nil")
        end
    end

)

Handlers.add(
    "getTokens",
    Handlers.utils.hasMatchingTag("Action", "GetTokens"),
    function(msg)
        -- Determine the owner based on whether msg.Owner is provided; default to msg.From if not
        local owner = msg.Holder or msg.From
        print(owner)
        -- Retrieve tokens for the determined owner, encode them to JSON, and send
        local tokens = json.encode(GeneralFunctions.GetTokens(owner))
        Send({ Target = msg.From, Action = "Token-Data", Data = tokens })
    end

)

-- General Handlers

Handlers.add(
    "move",
    Handlers.utils.hasMatchingTag("Action", "Move"),
    function(msg)
        -- Using pcall to handle potential errors during the move operation
        local success, Message = pcall(GeneralFunctions.Move, msg)
        if not success then
            -- If the move function fails, log the error message
            print("Error occurred during move: " .. Message)
            -- Optionally, you could return or handle the error in another way
        end
        Send({ Target = msg.From, Action = "Info-Message", Data = Message })
    end

)

Handlers.add("WhereCanIMove", Handlers.utils.hasMatchingTag("Action", "WhereCanIMove"),
    function(msg)
        local success, Message = pcall(GeneralFunctions.WhereCanIMove, msg)
        if not success then Send({ Target = msg.From, Action = "Error-Message", Data = Message }) end
    end)

Handlers.add(
    "TalkToNPC",
    Handlers.utils.hasMatchingTag("Action", "TalkToNPC"),
    function(msg)
        local success, Message = pcall(GeneralFunctions.TalkToNPC, msg)
        if not success then
            local action = "Error-Message"
            Send({ Target = msg.From, Action = action, Data = Message })
        end
    end
)

Handlers.add(
    "WhoCanITalkTo",
    Handlers.utils.hasMatchingTag("Action", "WhoCanITalkTo"),
    function(msg)
        -- First, ensure that the FromToken is provided in the message
        if not msg.FromToken then
            Send({
                Target = msg.From,
                Action = "Error-Message",
                Data =
                "Improper request: Must provide TokenID of character making the request."
            })
            return
        end

        -- Retrieve the token using its ID to get the location
        local token = GeneralFunctions.GetTokenByID(tonumber(msg.FromToken))
        if not token or not token.Location then
            Send({ Target = msg.From, Action = "Error-Message", Data = "Token not found or location undefined." })
            return
        end
        local tokenLocation = token.Location

        -- Prepare a list to store names of NPCs who can be talked to at this location
        local talkList = {}
        for _, npc in pairs(NonCombatNPCList) do
            if npc.Location == tokenLocation then
                table.insert(talkList, npc.Name)
            end
        end

        -- Check if any NPCs were found; handle the case where no NPCs are available to talk
        if #talkList == 0 then
            Send({ Target = msg.From, Action = "Info-Message", Data = "No NPCs to talk to at this location." })
        else
            -- Sending the list of NPC names that can be talked to
            Send({
                Target = msg.From,
                Action = "Info-Message",
                Data = json.encode(talkList)
            })
        end
    end

)

Handlers.add(
    "Equip",
    Handlers.utils.hasMatchingTag("Action", "Equip"),
    function(msg)
        local success, Message = pcall(GeneralFunctions.Equip, msg)
        if not success then
            print("Error: " .. Message)
        end
        if success then
            print("Successfully equipped")
        end
    end
)

Handlers.add(
    "UnEquip",
    Handlers.utils.hasMatchingTag("Action", "Unequip"),
    function(msg)
        local success, Message = pcall(GeneralFunctions.UnEquip, msg)
        if not success then
            print("Error: " .. Message)
        end
        if success then
            print("Successfully unequipped")
        end
    end
)

Handlers.add(
    "SpendPoint",
    Handlers.utils.hasMatchingTag("Action", "SpendPoint"),
    function(msg)
        local success, Message = pcall(GeneralFunctions.SpendPoint, msg)
        if not success then
            print("Error: " .. Message)
        else
            print("Point Spent")
        end
    end
)

Handlers.add(
    "Rename",
    Handlers.utils.hasMatchingTag("Action", "Rename"),
    function(msg)
        -- First check if all necessary parameters are provided
        if not msg.FromToken or not msg.NewName then
            Send({
                Target = msg.From,
                Action = "Error-Message",
                Data =
                "Improper request: Token ID and new name required."
            })
            return
        end

        -- Get the owner of the token
        local owner = GeneralFunctions.GetOwner(msg.FromToken)
        if not owner then
            Send({ Target = msg.From, Action = "Error-Message", Data = "Token not found or no owner available." })
            return
        end

        -- Ensure the requester is the owner of the token
        if owner ~= msg.From then
            Send({
                Target = msg.From,
                Action = "Error-Message",
                Data =
                "Unauthorized access: You are not the owner of this token."
            })
            return
        end

        -- Attempt to rename the token using a protected call
        local success, messageOrError = pcall(GeneralFunctions.Rename, msg.FromToken, msg.NewName)
        if success then
            Send({ Target = msg.From, Action = "Info-Message", Data = messageOrError or "Token renamed successfully." })
        else
            Send({ Target = msg.From, Action = "Error-Message", Data = messageOrError or "Failed to rename token." })
        end
    end

)


-- Combat Handlers

Handlers.add(
    "EnterCombat",
    Handlers.utils.hasMatchingTag("Action", "EnterCombat"),

    function(msg)
        local success, ErrorOrMessage = pcall(CombatFunctions.EnterCombat, msg)
        if not success then
            print("Error: " .. ErrorOrMessage)
            Send({ Target = msg.From, Action = "Combat-Info", Data = ErrorOrMessage })
        end
    end
)

Handlers.add(
    "Attack",
    Handlers.utils.hasMatchingTag("Action", "Attack"),

    function(msg)
        local success, ErrorOrMessage = pcall(CombatFunctions.ProcessAttack, msg)
        if not success then
            print("Error: " .. ErrorOrMessage)
            Send({ Target = msg.From, Action = "Combat-Info", Data = ErrorOrMessage })
        end
    end
)

Handlers.add(
    "WhoCanIFight",
    Handlers.utils.hasMatchingTag("Action", "WhoCanIFight"),
    function(msg)
        if not msg.FromToken then
            Send({ Target = msg.From, Action = "Error-Message", Data = "Must provide a Token ID as 'FromToken'." })
            return
        end

        local targetLocation = msg.TargetLocation
        if not targetLocation then
            local holderTokens = State.Holders[msg.From]
            for _, token in ipairs(holderTokens or {}) do
                if tostring(token.TokenID) == msg.FromToken then
                    targetLocation = token.Location
                    break
                end
            end
        end

        if not targetLocation then
            Send({ Target = msg.From, Action = "Error-Message", Data = "Token location not found." })
            return
        end

        local success, fightListOrError = pcall(GeneralFunctions.WhoCanIFight, targetLocation)
        if not success then
            Send({ Target = msg.From, Action = "Error-Message", Data = fightListOrError })
        else
            if #fightListOrError == 0 then
                Send({
                    Target = msg.From,
                    Action = "Info-Message",
                    Data =
                    "There are no enemies nearby. You are safe. For now."
                })
            else
                Send({ Target = msg.From, Action = "Info-Message", Data = json.encode(fightListOrError) })
            end
        end
    end
)


-- Transfer Handlers

Handlers.add(
    "MakeBuyOffer",
    Handlers.utils.hasMatchingTag("Action", "MakeBuyOffer"),
    function(msg)
        local success, Message = pcall(TransferFunctions.MakeOffer, msg)
        if not success then
            local action = "Error-Message"
            Send({ Target = msg.From, Action = action, Data = Message })
        else Send({ Target = msg.From, Action = "Info-Message", Data = Message})
        end
    end
)

Handlers.add(
    "WithdrawBuyOffer",
    Handlers.utils.hasMatchingTag("Action", "WithdrawBuyOffer"),
    function(msg)
        local success, errorMessage = pcall(TransferFunctions.WithdrawBuyOffer, msg)
        if not success then
            print("Error withdrawing buy offer: " .. errorMessage)
            Send({ Target = msg.From, Action = "Error", Data = "Failed to withdraw buy offer: " .. errorMessage })
        end
    end
)

Handlers.add(
    "AcceptBuyOffer",
    Handlers.utils.hasMatchingTag("Action", "AcceptBuyOffer"),
    function(msg)
        local success, errorMessage = pcall(TransferFunctions.AcceptBuyOffer, msg)
        if not success then
            print("Error accepting buy offer: " .. errorMessage)
            Send({ Target = msg.From, Action = "Error", Data = "Failed to accept buy offer: " .. errorMessage })
        end
    end
)

