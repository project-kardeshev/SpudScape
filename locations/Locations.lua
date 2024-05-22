Locations = Locations or {}

Locations.Town = {
    CanEnterCombat = false,
    CombatOnEnter = false,
    CanMoveTo = {"Orphanage", "Woods"},
    CanFindLoot = false,
    Loot = {}
}

Locations.Orphanage = {
    CanEnterCombat = true,
    CombatOnEnter = false,
    CanMoveTo = {"Town"},
    CanFindLoot = false,
    Loot = {}
}

Locations.Woods = {
    CanEnterCombat = true,
    CombatOnEnter = true,
    CanMoveTo = {"Town"},
    CanFindLoot = true,
    Loot = {"Cool Looking Stick"}
}

return Locations