Locations = Locations or {}

local nothing = function() return end

Locations.Town = {
    CanEnterCombat = false,
    CanMoveTo = {"Orphanage", "Woods", "Tavern"},
    ActionOnEnter = nothing

}

Locations.Tavern = {
    CanEnterCombat = false,
    CanMoveTo = {"Town"},
    ActionOnEnter = nothing
}

Locations.Orphanage = {
    CanEnterCombat = true,
    CanMoveTo = {"Town"},
    ActionOnEnter = nothing

}

Locations.Woods = {
    CanEnterCombat = true,
    CanMoveTo = {"Town"},
    ActionOnEnter = function(msg) CombatFunctions.EnterCombat(msg) end
}

return Locations