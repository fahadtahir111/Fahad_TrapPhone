# 🚬 TrapPhone - Drug Selling System

A complete drug selling system for FiveM ESX servers with phone interface, NPC buyers, and inventory integration.

## 📱 Features

- **Phone Interface**: Modern React-based UI with inventory management
- **NPC Buyers**: Dynamic buyer spawning with realistic AI behavior
- **Call System**: Phone call animations with progress bars
- **Inventory Integration**: Works with ox_inventory for item management
- **Police Alerts**: Configurable police notification system
- **Black Money**: Sells drugs for black money instead of regular money
- **Cooldown System**: Prevents spam selling with configurable cooldowns

## 🛠️ Installation

### 1. Resource Setup
1. Place the resource in your `resources` folder
2. Add `ensure Fahad_TrapPhone` to your `server.cfg`
3. Restart your server

### 2. Item Configuration
Add the trap_phone item to your `ox_inventory/data/items.lua`:

```lua
	['trapphone'] = {
    label = 'Trap Phone',
    weight = 200,
    stack = false,
    consume = 0,
    client = {
        export = 'Fahad_TrapPhone.useTrapPhone'
    }
},
```

### 3. Dependencies
Make sure you have these resources installed:
- `es_extended` (ESX Legacy)
- `ox_inventory`
- `ox_lib`

## ⚙️ Configuration

### Config.lua Settings

```lua

Config.CooldownTime = 30000               -- 30 seconds between transactions
Config.CallDuration = 5000                -- 5 seconds call duration
Config.CooldownDuration = 60000           -- 1 minute cooldown after call
Config.NotificationDuration = 5000        -- Notification display time
Config.PoliceNotificationChance = 25      -- 25% chance police gets notified

-- NPC Spawning
Config.BuyerSpawnRadius = 50.0           -- Distance from player to spawn buyer
Config.BuyerSpawnHeight = 1.0            -- Height offset for spawning
Config.BuyerInteractionRadius = 3.0      -- Distance to interact with buyer
Config.NPCInteractionRadius = 2.0        -- General NPC interaction distance

-- Drugs Configuration
Config.Drugs = {
    {
        id = 'cocaine',
        name = 'Cocaine',
        sellPrice = 150,
        blackMoneyMultiplier = 1.5
    },
    {
        id = 'weed',
        name = 'Weed',
        sellPrice = 50,
        blackMoneyMultiplier = 1.2
    }
    -- Add more drugs as needed
}
```

## 📖 Usage

### For Players

1. **Get the Phone**: Obtain a `trapphone` item
2. **Use the Phone**: Use the item from your inventory
3. **Select Drug**: Choose a drug from your inventory
4. **Call Buyer**: Click "Call Buyer" to start the process
5. **Wait for Call**: Phone call animation plays with progress bar
6. **Meet Buyer**: NPC spawns nearby and approaches you
7. **Sell Drugs**: Interact with the NPC to complete the sale



## 🔧 Customization

### Adding New Drugs

Add new drugs to `Config.Drugs` in `config.lua`:

```lua
{
    id = 'your_drug_id',
    name = 'Your Drug Name',
    sellPrice = 200,
    blackMoneyMultiplier = 1.8
}
```

### Modifying Spawn Behavior

Adjust these settings in `config.lua`:
- `Config.BuyerSpawnRadius`: How far from player NPCs spawn
- `Config.BuyerInteractionRadius`: How close you need to be to interact
- `Config.CooldownTime`: Time between transactions

### UI Customization

The phone UI is built with React and Tailwind CSS. Modify files in `web/src/` to change:
- Colors and styling
- Layout and components
- Animations and transitions

## 🚨 Police System

The script includes a configurable police alert system:
- **Notification Chance**: Set in `Config.PoliceNotificationChance`
- **Blip Creation**: Creates temporary blips for police
- **Area Alerts**: Notifies all players of suspicious activity


### Phone Not Opening
1. Check if `trap_phone` item exists in ox_inventory
2. Verify item registration in server.lua
3. Check console for error messages

### NPC Not Spawning
1. Ensure player is in a valid location
2. Check spawn radius configuration
3. Verify no other scripts blocking NPC creation

### Selling Not Working
1. Check if player has the required items
2. Verify ox_inventory integration
3. Check server console for transaction errors

## 📝 License

This resource is created for FiveM ESX servers. Use at your own risk.

## 🤝 Support

For support or feature requests, contact the developer.

---

**Version**: 1.0.0  
**Framework**: ESX Legacy  
**Inventory**: ox_inventory  
**UI**: React + Tailwind CSS 