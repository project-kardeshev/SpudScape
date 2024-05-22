CharacterSchema = {
  Level = {
    type = "number",
    min = 1,
    max = 50,
    required = true
  },
  CurrentXP = {
    type = "number",
    min = 0,
    max = 1000000,
    required = true
  },
  LevelUpXP = {
    type = "number",
    min = 100,
    max = 10000000,
    required = true
  },
  TokenID = {
    type = "number",
    min = 1,
    required = true
  },
  Skills = {
    type = "table",
    required = true
  },
  Attacks = {
    type = "table",
    required = true
  },
  Stats = {
    Health = {
      type = "number",
      min = 1,
      max = 300, -- Adjusted based on the highest health value given for "The Grand Potato"
      required = true
    },
    Power = {
      type = "number",
      min = 1,
      max = 10, -- Adjusted to match "The Grand Potato"
      required = true
    },
    Defense = {
      type = "number",
      min = 1,
      max = 10, -- Adjusted to match "The Grand Potato"
      required = true
    },
    Speed = {
      type = "number",
      min = 1,
      max = 10, -- Adjusted to match "The Grand Potato"
      required = true
    },
    Precision = {
      type = "number",
      min = 1,
      max = 10, -- Adjusted to match "The Grand Potato"
      required = true
    },
    Evasion = {
      type = "number",
      min = 1,
      max = 10, -- Adjusted to match "The Grand Potato"
      required = true
    },
    Affinity = {
      enum = { "None", "Fungal", "Bacterial", "Viral", "Mycorrhizal", "Animalistic" },
      required = true
    }
  },
  Location = {
    type = "string",
    required = true
  },
  AvailableStatPoints = {
    type = "number",
    min = 0,
    required = true
  }
}

return CharacterSchema
