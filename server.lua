-- Get player inventory callback
lib.callback.register('trapphone:getInventory', function(source)
    local inventory = exports.ox_inventory:GetInventory(source, false)
    local drugInventory = {}
    
    if inventory and inventory.items then
        for _, item in pairs(inventory.items) do
            for _, drug in pairs(Config.Drugs) do
                if item.name == drug.id and item.count > 0 then
                    drugInventory[drug.id] = {
                        name = drug.name,
                        count = item.count,
                        sellPrice = drug.sellPrice
                    }
                    break
                end
            end
        end
    end
    
    return drugInventory
end)

-- Handle drug purchases
RegisterNetEvent('trapphone:buyDrug')
AddEventHandler('trapphone:buyDrug', function(drugId, quantity)
    local source = source
    
    -- Find the drug in config
    local drug = nil
    for _, configDrug in pairs(Config.Drugs) do
        if configDrug.id == drugId then
            drug = configDrug
            break
        end
    end
    
    if not drug then
        TriggerClientEvent('trapphone:transactionResult', source, false, 'Invalid drug selected')
        return
    end
    
    -- Validate quantity
    if quantity < drug.minQuantity or quantity > drug.maxQuantity then
        TriggerClientEvent('trapphone:transactionResult', source, false, 'Invalid quantity')
        return
    end
    
    -- Check if player has trap phone
    local hasPhone = exports.ox_inventory:GetItemCount(source, Config.PhoneItem)
    if hasPhone < 1 then
        TriggerClientEvent('trapphone:transactionResult', source, false, 'You need a trap phone')
        return
    end
    
    -- Calculate total price
    local totalPrice = drug.buyPrice * quantity
    
    -- Check if player has enough money
    local playerMoney = exports.ox_inventory:GetItemCount(source, 'money')
    if playerMoney < totalPrice then
        TriggerClientEvent('trapphone:transactionResult', source, false, 'Not enough money')
        return
    end
    
    -- Check police online (if configured)
    if Config.MinPoliceOnline > 0 then
        local policeCount = 0
        local players = GetPlayers()
        
        for _, playerId in pairs(players) do
            local playerData = exports.ox_inventory:GetInventory(playerId, false)
            -- You can implement police job check here based on your framework
            -- This is a placeholder - adjust according to your police system
        end
        
        if policeCount < Config.MinPoliceOnline then
            TriggerClientEvent('trapphone:transactionResult', source, false, 'Not enough police online')
            return
        end
    end
    
    -- Process transaction
    local success = exports.ox_inventory:RemoveItem(source, 'money', totalPrice)
    if success then
        exports.ox_inventory:AddItem(source, drugId, quantity)
        
        -- Log transaction
        print(('[TRAPPHONE] Player %s bought %dx %s for $%d'):format(source, quantity, drug.name, totalPrice))
        
        -- Notify police chance
        if math.random(100) <= Config.PoliceNotificationChance then
            notifyPolice(source)
        end
        
        TriggerClientEvent('trapphone:transactionResult', source, true, ('Purchased %dx %s for $%d'):format(quantity, drug.name, totalPrice))
    else
        TriggerClientEvent('trapphone:transactionResult', source, false, 'Transaction failed')
    end
end)

-- Handle selling to NPCs
RegisterNetEvent('trapphone:sellToNPC')
AddEventHandler('trapphone:sellToNPC', function(drugId, quantity)
    local source = source
    
    -- Find the drug in config
    local drug = nil
    for _, configDrug in pairs(Config.Drugs) do
        if configDrug.id == drugId then
            drug = configDrug
            break
        end
    end
    
    if not drug then
        TriggerClientEvent('trapphone:transactionResult', source, false, 'Invalid drug selected')
        return
    end
    
    -- Check if player has the drug
    local itemCount = exports.ox_inventory:GetItemCount(source, drugId)
    if itemCount < quantity then
        TriggerClientEvent('trapphone:transactionResult', source, false, 'You don\'t have enough of this drug')
        return
    end
    
    -- Calculate total price (selling price with black money multiplier)
    local totalPrice = math.floor(drug.sellPrice * quantity * drug.blackMoneyMultiplier)
    
    -- Process transaction
    local success = exports.ox_inventory:RemoveItem(source, drugId, quantity)
    if success then
        -- Add black money instead of regular money
        exports.ox_inventory:AddItem(source, 'black_money', totalPrice)
        
        -- Log transaction
        print(('[TRAPPHONE] Player %s sold %dx %s for $%d black money to NPC'):format(source, quantity, drug.name, totalPrice))
        
        -- Notify police chance (higher for selling)
        if math.random(100) <= (Config.PoliceNotificationChance + 15) then
            notifyPolice(source)
        end
        
        TriggerClientEvent('trapphone:transactionResult', source, true, ('Sold %dx %s for $%d black money'):format(quantity, drug.name, totalPrice))
    else
        TriggerClientEvent('trapphone:transactionResult', source, false, 'Transaction failed')
    end
end)

function notifyPolice(source)
    local players = GetPlayers()
    local coords = GetEntityCoords(GetPlayerPed(source))
    
    for _, playerId in pairs(players) do
        -- You can implement police job check here based on your framework
        -- This is a placeholder notification system
        TriggerClientEvent('ox_lib:notify', playerId, {
            title = 'Police Alert',
            description = 'Suspicious drug activity reported in the area',
            type = 'inform'
        })
        
        -- Add blip for police (optional)
        TriggerClientEvent('trapphone:createPoliceBlip', playerId, coords)
    end
end

-- Create police blip
RegisterNetEvent('trapphone:createPoliceBlip')
AddEventHandler('trapphone:createPoliceBlip', function(coords)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, 161)
    SetBlipScale(blip, 0.8)
    SetBlipColour(blip, 1)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Drug Activity")
    EndTextCommandSetBlipName(blip)
    
    -- Remove blip after 2 minutes
    SetTimeout(120000, function()
        RemoveBlip(blip)
    end)
end)

-- Register item usage with ox_inventory
-- Item usage
ESX.RegisterUsableItem(Config.PhoneItem, function(source)
    TriggerClientEvent('trapphone:use', source)
end)

