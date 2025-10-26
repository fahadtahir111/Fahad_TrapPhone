Config = {}

-- Core Settings
Config.CooldownTime = 30000 -- 30 seconds between transactions
Config.PoliceNotificationChance = 15 -- 15% chance to notify police
Config.MinPoliceOnline = 0 -- Minimum police online for transactions

-- NPC Configuration
Config.NPCSpawnDistance = 150.0
Config.NPCDespawnDistance = 200.0
Config.MaxActiveNPCs = 5
Config.NPCSpawnCooldown = 45000 -- 45 seconds between spawns
Config.NPCWaitTime = 120000 -- 2 minutes before NPC leaves
Config.CallDuration = 8000 -- 8 seconds call duration

-- NPC Models
Config.NPCModels = {
    'a_m_m_bevhills_01',
    'a_m_m_business_01',
    'a_m_m_downtown_01',
    'a_m_m_eastsa_01',
    'a_m_m_fatlatin_01',
    'a_m_m_genfat_01',
    'a_m_m_golfer_01',
    'a_m_m_hasjew_01',
    'a_m_m_hillbilly_01',
    'a_m_m_indian_01',
    'a_f_m_bevhills_01',
    'a_f_m_business_02',
    'a_f_m_downtown_01',
    'a_f_m_eastsa_01',
    'a_f_m_fatbla_01',
    'a_f_m_ktown_01',
    'a_f_m_salton_01',
    'a_f_m_skidrow_01',
    'a_f_m_soucentmc_01',
    'a_f_m_soucent_01'
}

-- Drug Configuration
Config.Drugs = {
    {
        id = 'weed',
        name = 'Cannabis',
        emoji = '🌿',
        buyPrice = 150,
        sellPrice = 120,
        minQuantity = 1,
        maxQuantity = 10,
        rarity = 'common',
        description = 'High quality cannabis',
        npcDemand = 85,
        blackMoneyMultiplier = 0.8
    },
    {
        id = 'cocaine',
        name = 'Cocaine',
        emoji = '❄️',
        buyPrice = 300,
        sellPrice = 250,
        minQuantity = 1,
        maxQuantity = 5,
        rarity = 'rare',
        description = 'Pure white powder',
        npcDemand = 65,
        blackMoneyMultiplier = 1.0
    },
    {
        id = 'meth',
        name = 'Methamphetamine',
        emoji = '💎',
        buyPrice = 450,
        sellPrice = 380,
        minQuantity = 1,
        maxQuantity = 3,
        rarity = 'epic',
        description = 'Crystal blue product',
        npcDemand = 45,
        blackMoneyMultiplier = 1.2
    },
    {
        id = 'lsd',
        name = 'LSD',
        emoji = '🔮',
        buyPrice = 200,
        sellPrice = 160,
        minQuantity = 1,
        maxQuantity = 8,
        rarity = 'uncommon',
        description = 'Mind-expanding tabs',
        npcDemand = 75,
        blackMoneyMultiplier = 0.9
    },
    {
        id = 'heroin',
        name = 'Heroin',
        emoji = '💉',
        buyPrice = 600,
        sellPrice = 500,
        minQuantity = 1,
        maxQuantity = 2,
        rarity = 'legendary',
        description = 'Highly addictive substance',
        npcDemand = 35,
        blackMoneyMultiplier = 1.5
    }
}

-- Animation Configuration
Config.Animations = {
    phone = {
        dict = 'cellphone@',
        name = 'cellphone_text_read_base',
        flag = 49
    },
    call = {
        dict = 'cellphone@',
        name = 'cellphone_call_listen_base',
        flag = 49
    },
    transaction = {
        dict = 'mp_common',
        name = 'givetake1_a',
        flag = 0
    }
}

-- Buyer spawn configuration
Config.BuyerSpawnRadius = 20.0 -- Distance from player to spawn buyer
Config.BuyerSpawnHeight = 1.0 -- Height above ground for buyer spawn
Config.BuyerInteractionRadius = 5.0 -- Distance for interaction with buyer