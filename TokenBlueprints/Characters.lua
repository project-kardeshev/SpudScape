CharacterBlueprints = {
    TokenClasses = {
        Character = {
            TokenID = 0,
            Skills = {},
            LevelStats = {
                Level = 1,
                CurrentXP = 0,
                LevelUpXP = 100
            },
            Equipment = {
                Armor = {},
                Weapon = {},
                Accessory = {}
            },
            Location = "Town",
            Faction = "None",
            Tokens = {
                Token0 = {
                    Rarity = "Common",
                     Quantity = 0,
                    InitialState = {
                        Name = "Bob the Peasant",
                        Description = "He's just Bob. Nothing special about him.",
                        Type = "Character",
                        Stats = {
                            {name = "Health", value = 100},
                            {name = "Power", value = 1},
                            {name = "Defense", value = 1},
                            {name = "Speed", value = 1},
                            {name = "Precision", value = 1},
                            {name = "Evasion", value = 1},
                            {name = "Affinity", value = "None"}
                        }
                    }
                },
                Token1 = {
                    Rarity = "Uncommon",
                    Quantity = 0,
                    InitialState = {
                        Name = "Carl, the buff guy",
                        Description = "Carl does crossfit.",
                        Type = "Character",
                        Stats = {
                            {name = "Health", value = 120},
                            {name = "Power", value = 3},
                            {name = "Defense", value = 1},
                            {name = "Speed", value = 2},
                            {name = "Precision", value = 1},
                            {name = "Evasion", value = 1},
                            {name = "Affinity", value = "None"}
                        }
                    }
                },
                Token2 = {
                    Rarity = "Rare",
                    Quantity = 0,
                    InitialState = {
                        Name = "Tim the fungus mage",
                        Description = "Tim ate mushrooms growing under his bed as a child. Now he thinks he's a god.",
                        Type = "Character",
                        Stats = {
                            {name = "Health", value = 150},
                            {name = "Power", value = 3},
                            {name = "Defense", value = 3},
                            {name = "Speed", value = 3},
                            {name = "Precision", value = 3},
                            {name = "Evasion", value = 3},
                            {name = "Affinity", value = "Fungal"}
                        }
                    }
                },
                Token3 = {
                    Rarity = "Epic",
                    Quantity = 0,
                    InitialState = {
                        Name = "Atticus",
                        Description = "Hey, that's one of the dev's name. Does that make this an easter egg?",
                        Type = "Character",
                        Stats = {
                            {name = "Health", value = 200},
                            {name = "Power", value = 5},
                            {name = "Defense", value = 5},
                            {name = "Speed", value = 5},
                            {name = "Precision", value = 5},
                            {name = "Evasion", value = 5},
                            {name = "Affinity", value = "Viral"}
                        }
                    }
                },
                Token4 = {
                    Rarity = "Legendary",
                    Quantity = 0,
                    InitialState = {
                        Name = "The Grand Potato",
                        Description = "A sentient potato. None who cross it live to tell the tale.",
                        Type = "Character",
                        Stats = {
                            {name = "Health", value = 300},
                            {name = "Power", value = 10},
                            {name = "Defense", value = 10},
                            {name = "Speed", value = 10},
                            {name = "Precision", value = 10},
                            {name = "Evasion", value = 10},
                            {name = "Affinity", value = "Mycorrhizal"}
                        }
                    }
                }

            }
        }
    }
}

return CharacterBlueprints