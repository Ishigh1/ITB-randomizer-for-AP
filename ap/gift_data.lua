return {
    info = { -- List of all known units
        -- Bots
        Snowtank1 = "Cannon-Bot",
        Snowtank2 = "Cannon-Mech",
        Snowart1 = "Artillery-Bot",
        Snowart2 = "Artillery-Mech",
        Snowlaser1 = "Laser-Bot",
        Snowlaser2 = "Laser-Mech",
        Snowmine1 = "Mine-Bot", -- This one is friendly
        Snowtank1_Boom = "Boom Cannon",
        Snowart1_Boom = "Boom Artillery",
        Snowlaser1_Boom = "Boom Laser",

        -- Veks
        Blobber1 = "Blobber",   -- Explosive spawner
        Blobber2 = "Alpha Blobber",
        Blob1 = "Blob",         -- Explosive
        Blob2 = "Alpha Blob",
        Scorpion1 = "Scorpion", -- Webber melee
        Scorpion2 = "Alpha Scorpion",
        Firefly1 = "Firefly",   -- Shooter
        Firefly2 = "Alpha Firefly",
        Leaper1 = "Leaper",
        Leaper2 = "Alpha Leaper",
        Beetle1 = "Beetle",       -- Rusher
        Beetle2 = "Alpha Beetle",
        Scarab1 = "Scarab",       -- Ranged single tile
        Scarab2 = "Alpha Scarab",
        Crab1 = "Crab",           -- Scarab AOE
        Crab2 = "Alpha Crab",
        Centipede1 = "Centipede", -- Splash acid
        Centipede2 = "Alpha Centipede",
        Digger1 = "Digger",       -- Rock maker
        Digger2 = "Alpha Digger",
        Hornet1 = "Hornet",       -- Flyer
        Hornet2 = "Alpha Hornet",
        Jelly_Health1 = "Soldier Psion",
        Jelly_Armor1 = "Shell Psion",
        Jelly_Regen1 = "Blood Psion",
        Jelly_Explode1 = "Blast Psion",
        Jelly_Lava1 = "Psion Tyrant", -- Tentacle Psion
        Spider1 = "Spider",           -- Spider spawner
        Spider2 = "Alpha Spider",
        WebbEgg1 = "Spiderling Egg",
        Spiderling1 = "Spiderling",
        Spiderling2 = "Alpha Spiderling",
        Burrower1 = "Burrower",
        Burrower2 = "Alpha Burrower",

        -- AE enemies
        Shaman1 = "Plasmodia",  -- Ranged spawner
        Shaman2 = "Alpha Plasmodia",
        Totem1 = "Spore",       -- Single use ranged
        Totem2 = "Alpha Spore",
        Bouncer1 = "Bouncer",   -- Melee goes back
        Bouncer2 = "Alpha Bouncer",
        Moth1 = "Moth",         -- Flying Crab
        Moth2 = "Alpha Moth",
        Mosquito1 = "Mosquito", -- Hornet + smoke
        Mosquito2 = "Alpha Mosquito",
        Starfish1 = "Starfish", -- Diagonal attacker
        Starfish2 = "Alpha Starfish",
        Dung1 = "Tumblebug",    -- Explosive boulder summoner
        Dung2 = "Alpha Tumblebug",
        Burnbug1 = "Gastropod", -- Puller
        Burnbug2 = "Alpha Gastropod",
        Jelly_Spider1 = "Arachnid Psion",
        Jelly_Fire1 = "Smoldering Psion",
        Jelly_Boost1 = "Raging Psion",

        -- Rocks
        BombRock = "Unstable Boulder",
        Wall = "Boulder",

        -- Bosses
        BeetleBoss = "Beetle Leader",
        BotBoss = "Bot Leader",
        FireflyBoss = "Firefly Leader",
        BlobBoss = "Large Goo",
        BlobBossMed = "Medium Goo",
        BlobBossSmall = "Small Goo",
        Jelly_Boss = "Psion Abomination",
        HornetBoss = "Hornet Leader",
        ScorpionBoss = "Scorpion Leader",
        SpiderBoss = "Spider Leader",
        SpiderlingEgg1 = "Spiderling Egg",

        GlowingScorpion = "Volatile Vek",

        -- Summons
        Deploy_Tank = "Push Tank",
        Deploy_ShieldTank = "Shield Tank",
        Deploy_AcidTank = "Acid Tank",
        Deploy_IceTank = "Ice Tank",
        Deploy_PullTank = "Pull Tank",
    },

    boss_enemies = {
        "BeetleBoss",
        "BotBoss",
        "FireflyBoss",
        "BlobBoss",
        "Jelly_Boss",
        "HornetBoss",
        "ScorpionBoss",
        --"SpiderBoss"
    },

    enemy_gift = { -- Spawnables units by island
        [1] = { "Snowtank1", "Snowart1", "Snowlaser1", "Blob1", "WebbEgg1" },
        [2] = { "Leaper1", "Spiderling2", "BombRock", "Blob2", "Totem1" },
        [3] = { "Scorpion1", "Firefly1", "Hornet1", "Scarab1", "Bouncer1" },
        [4] = { "Blobber1", "Shaman1", "Snowtank1_Boom", "Snowart1_Boom", "Snowlaser1_Boom" },
        [5] = { "Jelly_Health1", "Jelly_Armor1", "Jelly_Regen1", "Jelly_Explode1", "Jelly_Lava1" },
    },

    ally_gift = { "Deploy_Tank", "Deploy_ShieldTank", "Deploy_AcidTank", "Deploy_IceTank", "Deploy_PullTank" }
}
