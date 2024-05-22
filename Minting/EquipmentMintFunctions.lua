
EquipmentMintFunctions = EquipmentMintFunctions or {}


local function deepCopy(original)
    local copy = {}
    for key, value in pairs(original) do
        if type(value) == "table" then
            copy[key] = deepCopy(value)
        else
            copy[key] = value
        end
    end
    return copy
end

function EquipmentMintFunctions.SpecialMint(MintTo, EquipmentName)
    assert((type(MintTo) == "number") or (type(MintTo) == "string" and tonumber(MintTo) ~= nil), "Invalid type for receiving token: Must be a number or a numeric string")
    assert(type(EquipmentName) == "string", "Specify the name of the equipment to be minted")
    
    local function findEquipmentByName()
        for typeName, tokenClass in pairs(EquipmentBlueprints.TokenClasses) do
            for itemName, itemDetails in pairs(tokenClass) do
                if type(itemDetails) == "table" and itemDetails.Name == EquipmentName then
                    -- Return a deep copy of the equipment and the type to ensure modifications don't affect the original
                    return deepCopy(itemDetails), typeName
                end
            end
        end
        error("Equipment with name '" .. EquipmentName .. "' not found.")
    end

    local success, equipmentOrError, equipmentType = pcall(findEquipmentByName)
    if not success then
        error(equipmentOrError)
    end

    local owner = GeneralFunctions.GetOwner(MintTo)
    if not owner or not State.Holders[owner] then
        error("No owner found or no holder entry for owner: " .. tostring(owner))
    end

    local tokenID = State.NextID
    State.NextID = State.NextID + 1
    equipmentOrError.TokenID = tokenID

    local token = {
        TokenID = tokenID,
        Type = equipmentType,
        Owner = owner,
        Minter = owner
    }

    State.Tokens[tostring(tokenID)] = token
    equipmentOrError.EquippedTo = nil
    table.insert(State.Holders[owner], equipmentOrError)

    return equipmentOrError
end





return EquipmentMintFunctions

