local ESX = exports['es_extended']:getSharedObject()

local phoneOpen = false

local cooldownActive = false
local activeNPCs = {}
local lastNPCSpawn = 0
local currentCall = nil
local isInCall = false

-- Phone usage event
RegisterNetEvent('trapphone:use')
AddEventHandler('trapphone:use', function()
    if not phoneOpen and not cooldownActive and not isCalling then
        openTrapPhone()
    else
        showNotification('Phone is busy or on cooldown!', 'error')
    end
end)

function openTrapPhone()
    phoneOpen = true
    
    -- Play phone animation
    local playerPed = PlayerPedId()
    if not IsEntityPlayingAnim(playerPed, Config.Animations.phone.dict, Config.Animations.phone.name, 3) then
        lib.requestAnimDict(Config.Animations.phone.dict)
        TaskPlayAnim(playerPed, Config.Animations.phone.dict, Config.Animations.phone.name, 8.0, -8.0, -1, Config.Animations.phone.flag, 0, 0, 0, 0)
    end
    
    -- Disable controls while phone is open
    CreateThread(function()
        while phoneOpen do
            DisableAllControlActions(0)
            EnableControlAction(0, 1, true) -- Look Left/Right
            EnableControlAction(0, 2, true) -- Look Up/Down
            EnableControlAction(0, 245, true) -- Chat
            EnableControlAction(0, 249, true) -- Push to talk
            Wait(0)
        end
    end)
    
    -- Get player inventory for selling
    local inventory = exports.ox_inventory:GetPlayerItems()
    local drugInventory = {}
    
    for _, item in pairs(inventory) do
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
    
    -- Open NUI
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = 'openPhone',
        drugs = Config.Drugs,
        inventory = drugInventory
    })
end

function closeTrapPhone()
    phoneOpen = false
    
    -- Stop animation
    local playerPed = PlayerPedId()
    ClearPedTasks(playerPed)
    
    -- Enable controls
    SetNuiFocus(false, false)
    
    -- Send close message to NUI
    SendNUIMessage({
        type = 'closePhone'
    })
end

-- NPC Management System - SIMPLIFIED
function cleanupNPCs()
    local playerCoords = GetEntityCoords(PlayerPedId())
    
    for i = #activeNPCs, 1, -1 do
        local npcData = activeNPCs[i]
        if DoesEntityExist(npcData.entity) then
            local npcCoords = GetEntityCoords(npcData.entity)
            local distance = #(playerCoords - npcCoords)
            local timeSinceSpawn = GetGameTimer() - npcData.spawnTime
            
            -- Remove NPC if too far or too old
            if distance > 100.0 or timeSinceSpawn > 300000 then -- 5 minutes
                DeleteEntity(npcData.entity)
                if npcData.blip then
                    RemoveBlip(npcData.blip)
                end
                table.remove(activeNPCs, i)
            end
        else
            if npcData.blip then
                RemoveBlip(npcData.blip)
            end
            table.remove(activeNPCs, i)
        end
    end
end

-- Main NPC management thread
CreateThread(function()
    while true do
        if phoneOpen then
            cleanupNPCs()
        end
        Wait(5000)
    end
end)

-- NUI Callbacks
RegisterNUICallback('callForSale', function(data, cb)
    local drugId = data.drugId
    local quantity = data.quantity
    local availableCount = data.availableCount
    
    if Config.Debug then
        print("^3[TRAPPHONE DEBUG]^0 NUI callForSale triggered")
        print("^3[TRAPPHONE DEBUG]^0 Drug ID: " .. drugId)
        print("^3[TRAPPHONE DEBUG]^0 Quantity: " .. quantity)
        print("^3[TRAPPHONE DEBUG]^0 Available: " .. availableCount)
    end
    
    local success = callBuyer(drugId, quantity, availableCount)
    
    cb({
        success = success,
        message = success and 'Calling buyer...' or 'Failed to call buyer'
    })
end)

RegisterNUICallback('close', function(data, cb)
    closeTrapPhone()
    cb({})
end)

RegisterNUICallback('buyDrug', function(data, cb)
    if cooldownActive then
        cb({success = false, message = 'Transaction cooldown active'})
        return
    end
    
    -- Play transaction animation
    local playerPed = PlayerPedId()
    lib.requestAnimDict(Config.Animations.transaction.dict)
    TaskPlayAnim(playerPed, Config.Animations.transaction.dict, Config.Animations.transaction.name, 8.0, -8.0, 2000, Config.Animations.transaction.flag, 0, 0, 0, 0)
    
    -- Trigger server event
    TriggerServerEvent('trapphone:buyDrug', data.drugId, data.quantity)
    
    -- Start cooldown
    cooldownActive = true
    SetTimeout(Config.CooldownTime, function()
        cooldownActive = false
    end)
    
    cb({success = true})
end)

RegisterNUICallback('saveTheme', function(data, cb)
    -- Theme is saved automatically in localStorage by the frontend
    cb('ok')
end)

-- Handle server responses
RegisterNetEvent('trapphone:transactionResult')
AddEventHandler('trapphone:transactionResult', function(success, message)
    SendNUIMessage({
        type = 'transactionResult',
        success = success,
        message = message
    })
    
    if success then
        -- Success effects
        PlaySoundFrontend(-1, 'PURCHASE', 'HUD_LIQUOR_STORE_SOUNDSET', 1)
        
        -- Update inventory
        local inventory = exports.ox_inventory:GetPlayerItems()
        local drugInventory = {}
        
        for _, item in pairs(inventory) do
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
        
        SendNUIMessage({
            type = 'updateInventory',
            inventory = drugInventory
        })
    else
        -- Error effects
        PlaySoundFrontend(-1, 'ERROR', 'HUD_FRONTEND_DEFAULT_SOUNDSET', 1)
    end
end)

-- NPC interaction system
CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local nearNPC = false
        
        for i, npcData in ipairs(activeNPCs) do
            if DoesEntityExist(npcData.entity) then
                local npcCoords = GetEntityCoords(npcData.entity)
                local distance = #(playerCoords - npcCoords)
                
                -- Check if NPC is close enough to interact (5 meters)
                if distance <= (Config.BuyerInteractionRadius or 5.0) then
                    nearNPC = true
                    
                    -- If this is a buyer NPC, show interaction prompt
                    if npcData.isBuyer then
                        local drug = npcData.wantedDrug
                        local totalPrice = drug.sellPrice * npcData.quantity
                        local moneyType = Config.UseBlackMoney and "black money" or "$"
                        local prompt = '[E] - Sell ' .. npcData.quantity .. 'x ' .. drug.name .. ' for ' .. totalPrice .. ' ' .. moneyType
                        
                        lib.showTextUI(prompt)
                        
                        if IsControlJustReleased(0, 38) then -- E key
                            lib.hideTextUI()
                            
                            -- Disable E key during transaction
                            DisableControlAction(0, 38, true)
                            
                            -- Show selling progress bar
                            if lib.progressBar({
                                duration = 3000,
                                label = 'Selling drugs...',
                                useWhileDead = false,
                                canCancel = false,
                                disable = {
                                    car = true,
                                    move = true,
                                    combat = true
                                },
                                anim = {
                                    dict = Config.Animations.transaction.dict,
                                    clip = Config.Animations.transaction.name
                                }
                            }) then
                                -- Play transaction animation
                                RequestAnimDict(Config.Animations.transaction.dict)
                                while not HasAnimDictLoaded(Config.Animations.transaction.dict) do
                                    Citizen.Wait(0)
                                end
                                
                                TaskPlayAnim(playerPed, Config.Animations.transaction.dict, Config.Animations.transaction.name, 8.0, -8.0, 3000, Config.Animations.transaction.flag, 0, false, false, false)
                                
                                if DoesEntityExist(npcData.entity) then
                                    TaskLookAtEntity(npcData.entity, playerPed, 3000, 0, 2)
                                    TaskPlayAnim(npcData.entity, Config.Animations.transaction.dict, 'givetake1_b', 8.0, -8.0, 3000, 0, 0, false, false, false)
                                end
                                
                                -- Trigger server sale
                                TriggerServerEvent('trapphone:sellToNPC', npcData.wantedDrug.id, npcData.quantity)
                                
                                -- Remove NPC after transaction
                                SetTimeout(3000, function()
                                    if DoesEntityExist(npcData.entity) then
                                        DeleteEntity(npcData.entity)
                                    end
                                    if npcData.blip then
                                        RemoveBlip(npcData.blip)
                                    end
                                    table.remove(activeNPCs, i)
                                    
                                    -- Re-enable E key
                                    EnableControlAction(0, 38, true)
                                end)
                            end
                        end
                    end
                end
            end
        end
        
        if not nearNPC then
            lib.hideTextUI()
        end
        
        cleanupNPCs()
    end
end)

-- Call buyer function
function callBuyer(drugId, quantity, availableCount)
    if isCalling then
        lib.notify({
            title = 'TrapPhone',
            description = 'Already making a call!',
            type = 'error'
        })
        return false
    end

    isCalling = true
    -- Close phone UI immediately and hide cursor
    closeTrapPhone()
    SetNuiFocus(false, false)

    local playerPed = PlayerPedId()
    RequestAnimDict(Config.Animations.call.dict)
    while not HasAnimDictLoaded(Config.Animations.call.dict) do
        Citizen.Wait(0)
    end
    TaskPlayAnim(playerPed, Config.Animations.call.dict, Config.Animations.call.name, 8.0, -8.0, Config.CallDuration, Config.Animations.call.flag, 0, false, false, false)

    -- Function to complete the call process
    local function completeCall()
        -- Stop call animation
        ClearPedTasks(playerPed)
        isCalling = false

        -- Ensure cursor is hidden and controls are enabled
        SetNuiFocus(false, false)

        -- Spawn buyer near player
        local success = spawnBuyerNearPlayer(drugId, quantity)

        if success then
            lib.notify({
                title = 'TrapPhone',
                description = 'Buyer is on the way! Check your GPS.',
                type = 'success'
            })
            if #activeNPCs > 0 then
                local npcData = activeNPCs[#activeNPCs]
                if DoesEntityExist(npcData.entity) then
                    local npcCoords = GetEntityCoords(npcData.entity)
                    SetNewWaypoint(npcCoords.x, npcCoords.y)
                end
            end
            cooldownActive = true
            SetTimeout(Config.CooldownDuration or 30000, function()
                cooldownActive = false
            end)
        else
            lib.notify({
                title = 'TrapPhone',
                description = 'Failed to contact buyer. Try again.',
                type = 'error'
            })
        end
    end

    -- Show calling progress bar
    if lib.progressBar({
        duration = Config.CallDuration,
        label = 'Calling buyer...',
        useWhileDead = false,
        canCancel = false,
        disable = {
            car = true,
            move = true,
            combat = true
        },
        anim = {
            dict = Config.Animations.call.dict,
            clip = Config.Animations.call.name
        }
    }) then
        completeCall()
    else
        -- Fallback if progress bar fails
        SetTimeout(Config.CallDuration + 1000, function()
            if isCalling then
                completeCall()
            end
        end)
    end

    return true
end

-- Spawn buyer near player function - SIMPLIFIED
function spawnBuyerNearPlayer(drugId, quantity)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    -- Find the drug config
    local drug = nil
    for _, configDrug in pairs(Config.Drugs) do
        if configDrug.id == drugId then
            drug = configDrug
            break
        end
    end
    
    if not drug then
        print("^1[TRAPPHONE ERROR]^0 Drug not found: " .. drugId)
        return false
    end
    
    -- Simple spawn - random position around player
    local spawnRadius = Config.BuyerSpawnRadius or 20.0
    local angle = math.random(0, 360) * math.pi / 180
    local spawnX = playerCoords.x + math.cos(angle) * spawnRadius
    local spawnY = playerCoords.y + math.sin(angle) * spawnRadius
    local spawnZ = playerCoords.z + 1.0
    
    print("^3[TRAPPHONE DEBUG]^0 Spawning buyer at: " .. spawnX .. ", " .. spawnY .. ", " .. spawnZ)
    
    -- Select random NPC model
    local model = Config.NPCModels[math.random(#Config.NPCModels)]
    lib.requestModel(model)
    
    -- Create the NPC
    local npc = CreatePed(4, model, spawnX, spawnY, spawnZ, 0.0, false, true)
    
    if not DoesEntityExist(npc) then
        print("^1[TRAPPHONE ERROR]^0 Failed to create NPC")
        return false
    end
    
    -- Set basic NPC properties (removed complex functions)
    SetEntityAsMissionEntity(npc, true, true)
    SetPedRandomComponentVariation(npc, false)
    SetPedRandomProps(npc)
    
    -- Make NPC walk to player
    TaskGoToEntity(npc, playerPed, -1, 2.0, 2.0, 1073741824, 0)
    
    -- Create blip for the NPC
    local blip = AddBlipForEntity(npc)
    SetBlipSprite(blip, 1)
    SetBlipColour(blip, 2)
    SetBlipScale(blip, 0.8)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Drug Buyer")
    EndTextCommandSetBlipName(blip)
    
    -- Store NPC data
    local npcData = {
        entity = npc,
        blip = blip,
        wantedDrug = drug,
        quantity = quantity,
        spawnTime = GetGameTimer(),
        contacted = false,
        isBuyer = true
    }
    
    table.insert(activeNPCs, npcData)
    
    print("^3[TRAPPHONE DEBUG]^0 Buyer spawned successfully!")
    return true
end

-- Item usage registration
exports('useTrapPhone', function()
    TriggerEvent('trapphone:use')
end)

