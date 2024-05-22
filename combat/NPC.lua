CombatNPCList = CombatNPCList or {}


CombatNPCList.Kitten = {
    Type = "Combat NPC",
    Skills = {},
    Level = 1,
    GivesXP = 5,
    Stats = {
        Health = 10,
        Power = 1,
        Defense = 1,
        Speed = 1,
        Precision = 1,
        Evasion = 1,
        Affinity = "None",
    },
    Name = "Cute Little Kitten",
    Description = "A cute little kitten, who would ever want to punch it?",
    Attacks = {
        Meow = {
            Name = "Meow",
            Accuracy = 100,
            Affinity = "none",
            Force = 0
        }
    },
    Locations = { "Orphanage" },
    Messages = {
        OnDefeated =
        "You just murdered a kitten. In an orphange. That was some poor orphan's pet. May the Great Potato have mercy on your soul.",
        OnPlayerDefeated = "How did you get killed by a cute little kitten?"
    }
}

CombatNPCList.Orphans = {
    Type = "Combat NPC",
    Skills = {},
    Level = 20,
    GivesXP = 100000000,
    Stats = {
        Health = 10000,
        Power = 50,
        Defense = 35,
        Speed = 25,
        Precision = 25,
        Evasion = 17,
        Affinity = "None"
    },
    Name = "Swarm of Angry Orphans",
    Description =
    "A massive swarm of screaming orphans. Many seem to be holding pictures of themselves with a familiar looking kitten...",
    Attacks = {
        Scratch = {
            Name = "Scratch",
            Accuracy = 50,
            Affinity = "None",
            Force = 5
        },
        Snot = {
            Name = "Snot Rocket",
            Accuracy = 30,
            Affinity = "Viral",
            Force = 5
        }
    },
    Locations = { 
        -- "Orphanage" 
    },
    Messages = {
        OnDefeated =
        "Wow... You just slaughtered an entire swarm of Orphans... There were at least 40 children. They're all dead now. Why would anyone want to play this game?",
        OnPlayerDefeated =
        "You were just murdered by a bunch of orphans. Maybe dont go around slaughtering pet kittens and this kind of thing wont happen."
    }
}

CombatNPCList.ScurvyCultist = {
    Type = "Combat NPC",
    Skills = {},
    Level = 3,
    GivesXP = 30,
    Stats = {
        Health = 50,
        Power = 5,
        Defense = 3,
        Speed = 2,
        Precision = 2,
        Evasion = 4,
        Affinity = "None"
    },
    Name = "Scurvy riddled Tripe Cultist",
    Description = "A member of the Tripe Cult. He appears to be suffering from Scurvy.",
    Attacks = {
        Punch = {
            Name = "Punch",
            Force = 1,
            Affinity = "none",
            Accuracy = 2
        }
    },
    Locations = {"Woods"},
    Messages = {
        OnDefeated = "You have defeated the cultist. He will Defy the Great Potato no more.",
        OnPlayerDefeated = "You were killed by a sickly cultist. Maybe the Church isnt as powerful as you thought."
    }
}


CombatNPCList.StarvingBandit = {
    Type = "Combat NPC",
    Skills = {},
    Level = 2,
    GivesXP = 20,
    Stats = {
        Health = 40,
        Power = 4,
        Defense = 2,
        Speed = 3,
        Precision = 3,
        Evasion = 3,
        Affinity = "None"
    },
    Name = "Starving Bandit",
    Description = "A desperate and hungry bandit looking for anything to survive.",
    Attacks = {
        Slash = {
            Name = "Slash",
            Force = 2,
            Affinity = "none",
            Accuracy = 3
        }
    },
    Locations = {"Woods"},
    Messages = {
        OnDefeated = "The bandit collapses, unable to continue his desperate fight.",
        OnPlayerDefeated = "You have fallen to the starving bandit. Hunger and desperation made him a dangerous foe."
    }
}



return CombatNPCList

