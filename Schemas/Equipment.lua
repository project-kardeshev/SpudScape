EquipmentSchemas = {}

return EquipmentSchemas

-- {
--   "Equipment": {
--     "Armor": {
--       "mapping": {
--         "Helm": {
--           "prefix": {
--             "properties": {
--               "Artisan": {
--                 "properties": {
--                   "Sockets": {
--                     "type": "number",
--                     "min": 1,
--                     "max": 5,
--                     "required": true
--                   }
--                 }
--               },
--               "Battle-Hardened": {
--                 "properties": {
--                   "Defense": {
--                     "type": "number",
--                     "min": 1,
--                     "max": 10,
--                     "required": true
--                   }
--                 }
--               }
--             }
--           },
--           "suffix": {
--             "properties": {
--               "of the Bear": {
--                 "properties": {
--                   "Health": {
--                     "type": "number",
--                     "min": 1,
--                     "max": 50,
--                     "required": true
--                   }
--                 }
--               },
--               "of Agility": {
--                 "properties": {
--                   "Speed": {
--                     "type": "number",
--                     "min": 1,
--                     "max": 10,
--                     "required": true
--                   }
--                 }
--               }
--             }
--           }
--         },
--         "Armor": {
--           "prefix": {
--             "properties": {
--               "Reinforced": {
--                 "properties": {
--                   "Defense": {
--                     "type": "number",
--                     "min": 5,
--                     "max": 15,
--                     "required": true
--                   }
--                 }
--               },
--               "Lightweight": {
--                 "properties": {
--                   "Speed": {
--                     "type": "number",
--                     "min": 1,
--                     "max": 5,
--                     "required": true
--                   }
--                 }
--               }
--             }
--           },
--           "suffix": {
--             "properties": {
--               "of the Fox": {
--                 "properties": {
--                   "Evasion": {
--                     "type": "number",
--                     "min": 1,
--                     "max": 10,
--                     "required": true
--                   }
--                 }
--               },
--               "of Protection": {
--                 "properties": {
--                   "Defense": {
--                     "type": "number",
--                     "min": 1,
--                     "max": 20,
--                     "required": true
--                   }
--                 }
--               }
--             }
--           }
--         },
--         "Shield": {
--           "prefix": {
--             "properties": {
--               "Sturdy": {
--                 "properties": {
--                   "Defense": {
--                     "type": "number",
--                     "min": 1,
--                     "max": 20,
--                     "required": true
--                   }
--                 }
--               },
--               "Enchanted": {
--                 "properties": {
--                   "Element": {
--                     "enum": ["None", "Fire", "Ice", "Nature", "Earth"],
--                     "required": true
--                   }
--                 }
--               }
--             }
--           },
--           "suffix": {
--             "properties": {
--               "of the Guardian": {
--                 "properties": {
--                   "Health": {
--                     "type": "number",
--                     "min": 1,
--                     "max": 50,
--                     "required": true
--                   }
--                 }
--               },
--               "of Reflection": {
--                 "properties": {
--                   "Precision": {
--                     "type": "number",
--                     "min": 1,
--                     "max": 10,
--                     "required": true
--                   }
--                 }
--               }
--             }
--           }
--         },
--         "Boots": {
--           "prefix": {
--             "properties": {
--               "Swift": {
--                 "properties": {
--                   "Speed": {
--                     "type": "number",
--                     "min": 1,
--                     "max": 10,
--                     "required": true
--                   }
--                 }
--               },
--               "Silent": {
--                 "properties": {
--                   "Evasion": {
--                     "type": "number",
--                     "min": 1,
--                     "max": 10,
--                     "required": true
--                   }
--                 }
--               }
--             }
--           },
--           "suffix": {
--             "properties": {
--               "of the Wind": {
--                 "properties": {
--                   "Speed": {
--                     "type": "number",
--                     "min": 5,
--                     "max": 15,
--                     "required": true
--                   }
--                 }
--               },
--               "of Stability": {
--                 "properties": {
--                   "Defense": {
--                     "type": "number",
--                     "min": 1,
--                     "max": 10,
--                     "required": true
--                   }
--                 }
--               }
--             }
--           }
--         },
--         "Gloves": {
--           "prefix": {
--             "properties": {
--               "Gripping": {
--                 "properties": {
--                   "Power": {
--                     "type": "number",
--                     "min": 1,
--                     "max": 10,
--                     "required": true
--                   }
--                 }
--               },
--               "Reinforced": {
--                 "properties": {
--                   "Defense": {
--                     "type": "number",
--                     "min": 1,
--                     "max": 10,
--                     "required": true
--                   }
--                 }
--               }
--             }
--           },
--           "suffix": {
--             "properties": {
--               "of Dexterity": {
--                 "properties": {
--                   "Precision": {
--                     "type": "number",
--                     "min": 1,
--                     "max": 10,
--                     "required": true
--                   }
--                 }
--               },
--               "of Fortitude": {
--                 "properties": {
--                   "Health": {
--                     "type": "number",
--                     "min": 1,
--                     "max": 50,
--                     "required": true
--                   }
--                 }
--               }
--             }
--           }
--         },
--         "Belt": {
--           "prefix": {
--             "properties": {
--               "Sturdy": {
--                 "properties": {
--                   "Defense": {
--                     "type": "number",
--                     "min": 1,
--                     "max": 10,
--                     "required": true
--                   }
--                 }
--               },
--               "Ornate": {
--                 "properties": {
--                   "Evasion": {
--                     "type": "number",
--                     "min": 1,
--                     "max": 10,
--                     "required": true
--                   }
--                 }
--               }
--             }
--           },
--           "suffix": {
--             "properties": {
--               "of the Warrior": {
--                 "properties": {
--                   "Power": {
--                     "type": "number",
--                     "min": 1,
--                     "max": 20,
--                     "required": true
--                   }
--                 }
--               },
--               "of the Monk": {
--                 "properties": {
--                   "Speed": {
--                     "type": "number",
--                     "min": 1,
--                     "max": 10,
--                     "required": true
--                   }
--                 }
--               }
--             }
--           }
--         }
--       }
--     },
--     "properties": {
--       "Durability": {
--         "type": "number",
--         "min": 1,
--         "max": 100,
--         "required": true
--       },
--       "Defense": {
--         "type": "number",
--         "min": 1,
--         "max": 100,
--         "required": true
--       },
--       "RequiredLevel": {
--         "type": "number",
--         "min": 1,
--         "max": 50,
--         "required": true
--       }
--     }
--   },
--   "Weapon": {
--     "mapping": {
--       "Sword": {
--         "prefix": {
--           "properties": {
--             "Sharp": {
--               "properties": {
--                 "Power": {
--                   "type": "number",
--                   "min": 1,
--                   "max": 20,
--                   "required": true
--                 }
--               }
--             },
--             "Cursed": {
--               "properties": {
--                 "Evasion": {
--                   "type": "number",
--                   "min": -10,
--                   "max": 0,
--                   "required": true
--                 }
--               }
--             }
--           }
--         },
--         "suffix": {
--           "properties": {
--             "of Slaying": {
--               "properties": {
--                 "Power": {
--                   "type": "number",
--                   "min": 10,
--                   "max": 30,
--                   "required": true
--                 }
--               }
--             },
--             "of the Knight": {
--               "properties": {
--                 "Defense": {
--                   "type": "number",
--                   "min": 1,
--                   "max": 15,
--                   "required": true
--                 }
--               }
--             }
--           }
--         }
--       },
--       "Bow": {
--         "prefix": {
--           "properties": {
--             "Swift": {
--               "properties": {
--                 "Speed": {
--                   "type": "number",
--                   "min": 1,
--                   "max": 10,
--                   "required": true
--                 }
--               }
--             },
--             "Silent": {
--               "properties": {
--                 "Precision": {
--                   "type": "number",
--                   "min": 1,
--                   "max": 10,
--                   "required": true
--                 }
--               }
--             }
--           }
--         },
--         "suffix": {
--           "properties": {
--             "of the Hunter": {
--               "properties": {
--                 "Precision": {
--                   "type": "number",
--                   "min": 5,
--                   "max": 20,
--                   "required": true
--                 }
--               }
--             },
--             "of the Wind": {
--               "properties": {
--                 "Speed": {
--                   "type": "number",
--                   "min": 1,
--                   "max": 15,
--                   "required": true
--                 }
--               }
--             }
--           }
--         }
--       },
--       "Staff": {
--         "prefix": {
--           "properties": {
--             "Mystic": {
--               "properties": {
--                 "Element": {
--                   "enum": ["Fire", "Ice", "Nature", "Earth"],
--                   "required": true
--                 }
--               }
--             },
--             "Ancient": {
--               "properties": {
--                 "Power": {
--                   "type": "number",
--                   "min": 1,
--                   "max": 20,
--                   "required": true
--                 }
--               }
--             }
--           }
--         },
--         "suffix": {
--           "properties": {
--             "of the Mage": {
--               "properties": {
--                 "Power": {
--                   "type": "number",
--                   "min": 5,
--                   "max": 25,
--                   "required": true
--                 }
--               }
--             },
--             "of the Seer": {
--               "properties": {
--                 "Precision": {
--                   "type": "number",
--                   "min": 1,
--                   "max": 10,
--                   "required": true
--                 }
--               }
--             }
--           }
--         }
--       },
--       "Club": {
--         "prefix": {
--           "properties": {
--             "Heavy": {
--               "properties": {
--                 "Power": {
--                   "type": "number",
--                   "min": 1,
--                   "max": 15,
--                   "required": true
--                 }
--               }
--             },
--             "Brutal": {
--               "properties": {
--                 "Power": {
--                   "type": "number",
--                   "min": 5,
--                   "max": 25,
--                   "required": true
--                 }
--               }
--             }
--           }
--         },
--         "suffix": {
--           "properties": {
--             "of the Ogre": {
--               "properties": {
--                 "Health": {
--                   "type": "number",
--                   "min": 1,
--                   "max": 50,
--                   "required": true
--                 }
--               }
--             },
--             "of Crushing": {
--               "properties": {
--                 "Power": {
--                   "type": "number",
--                   "min": 10,
--                   "max": 30,
--                   "required": true
--                 }
--               }
--             }
--           }
--         }
--       },
--       "Spear": {
--         "prefix": {
--           "properties": {
--             "Sharp": {
--               "properties": {
--                 "Power": {
--                   "type": "number",
--                   "min": 1,
--                   "max": 20,
--                   "required": true
--                 }
--               }
--             },
--             "Balanced": {
--               "properties": {
--                 "Speed": {
--                   "type": "number",
--                   "min": 1,
--                   "max": 10,
--                   "required": true
--                 }
--               }
--             }
--           }
--         },
--         "suffix": {
--           "properties": {
--             "of the Warrior": {
--               "properties": {
--                 "Power": {
--                   "type": "number",
--                   "min": 5,
--                   "max": 25,
--                   "required": true
--                 }
--               }
--             },
--             "of Precision": {
--               "properties": {
--                 "Precision": {
--                   "type": "number",
--                   "min": 1,
--                   "max": 15,
--                   "required": true
--                 }
--               }
--             }
--           }
--         }
--       }
--     }
--   },
--   "Accessory": {
--     "mapping": {
--       "Ring": {
--         "prefix": {
--           "properties": {
--             "Enchanted": {
--               "properties": {
--                 "MagicResist": {
--                   "type": "number",
--                   "min": 1,
--                   "max": 10,
--                   "required": true
--                 }
--               }
--             },
--             "Glowing": {
--               "properties": {
--                 "Speed": {
--                   "type": "number",
--                   "min": 1,
--                   "max": 5,
--                   "required": true
--                 }
--               }
--             }
--           }
--         },
--         "suffix": {
--           "properties": {
--             "of Power": {
--               "properties": {
--                 "Power": {
--                   "type": "number",
--                   "min": 1,
--                   "max": 10,
--                   "required": true
--                 }
--               }
--             },
--             "of Protection": {
--               "properties": {
--                 "Defense": {
--                   "type": "number",
--                   "min": 1,
--                   "max": 10,
--                   "required": true
--                 }
--               }
--             }
--           }
--         }
--       },
--       "Necklace": {
--         "prefix": {
--           "properties": {
--             "Shimmering": {
--               "properties": {
--                 "Health": {
--                   "type": "number",
--                   "min": 1,
--                   "max": 15,
--                   "required": true
--                 }
--               }
--             },
--             "Stalwart": {
--               "properties": {
--                 "Defense": {
--                   "type": "number",
--                   "min": 1,
--                   "max": 10,
--                   "required": true
--                 }
--               }
--             }
--           }
--         },
--         "suffix": {
--           "properties": {
--             "of the Fox": {
--               "properties": {
--                 "Evasion": {
--                   "type": "number",
--                   "min": 1,
--                   "max": 10,
--                   "required": true
--                 }
--               }
--             },
--             "of Vitality": {
--               "properties": {
--                 "Health": {
--                   "type": "number",
--                   "min": 1,
--                   "max": 20,
--                   "required": true
--                 }
--               }
--             }
--           }
--         }
--       },
--       "Jewel": {
--         "prefix": {
--           "properties": {
--             "Tiny": {
--               "properties": {
--                 "Power": {
--                   "type": "number",
--                   "min": 1,
--                   "max": 5,
--                   "required": true
--                 }
--               }
--             },
--             "Faint": {
--               "properties": {
--                 "Speed": {
--                   "type": "number",
--                   "min": 1,
--                   "max": 5,
--                   "required": true
--                 }
--               }
--             }
--           }
--         },
--         "suffix": {
--           "properties": {
--             "of Glimmering": {
--               "properties": {
--                 "Precision": {
--                   "type": "number",
--                   "min": 1,
--                   "max": 5,
--                   "required": true
--                 }
--               }
--             },
--             "of Slight Vigor": {
--               "properties": {
--                 "Health": {
--                   "type": "number",
--                   "min": 1,
--                   "max": 5,
--                   "required": true
--                 }
--               }
--             }
--           }
--         }
--       },
--       "Treasure": {
--         "prefix": {
--           "properties": {
--             "Ancient": {
--               "properties": {
--                 "Value": {
--                   "type": "number",
--                   "min": 100,
--                   "max": 1000,
--                   "required": true
--                 }
--               }
--             },
--             "Mythic": {
--               "properties": {
--                 "Value": {
--                   "type": "number",
--                   "min": 500,
--                   "max": 5000,
--                   "required": true
--                 }
--               }
--             }
--           }
--         },
--         "suffix": {
--           "properties": {
--             "of the Ages": {
--               "properties": {
--                 "Value": {
--                   "type": "number",
--                   "min": 200,
--                   "max": 2000,
--                   "required": true
--                 }
--               }
--             },
--             "of Legend": {
--               "properties": {
--                 "Value": {
--                   "type": "number",
--                   "min": 1000,
--                   "max": 10000,
--                   "required": true
--                 }
--               }
--             }
--           }
--         }
--       }
--     }
--   }
-- }
