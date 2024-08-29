if Config.ESX == "New" then
    ESX = exports["es_extended"]:getSharedObject()
else
    ESX = nil
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
end

local main = RageUI.CreateMenu("Concessionnaire", GetPlayerName(PlayerId()))
local category = RageUI.CreateSubMenu(main, "Catégories", "")
local vehicle = RageUI.CreateSubMenu(category, "Véhicules", "")
local vehicleInfo = {}
local preview = false
local ListVehicles = {}

Citizen.CreateThread(function()
    local hash = GetHashKey(Config.PedType)
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(1000)
    end
    local ped = CreatePed("PED_TYPE_CIVMALE", Config.PedType, Config.PedPos, false, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)
end)

if Config.EnableBlips then
    local blips = AddBlipForCoord(Config.BlipPos)
    SetBlipScale(blips, Config.BlipScale)
    SetBlipAsShortRange(blips, true)
    SetBlipSprite(blips, Config.BlipSprite)
    SetBlipColour(blips, Config.BlipColor)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.BlipName)
    EndTextCommandSetBlipName(blips)
end

Citizen.CreateThread(function()
    while true do
        sleep = 1000
        local dst = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), Config.DrawMarkerPos, true)
        if dst < 20 then
            sleep = 0
            DrawMarker(6, Config.DrawMarkerPos.x, Config.DrawMarkerPos.y, Config.DrawMarkerPos.z-0.99, nil, nil, nil, -90, nil, nil, 1.0, 1.0, 1.0, 0, 0, 0, 155)
        end
        if dst < 2 then
            sleep = 0
            ESX.ShowHelpNotification("Appuyez sur ~INPUT_CONTEXT~ pour ouvrir le concessionnaire")
            if IsControlJustPressed(1, 51) then
                RageUI.Visible(main, not RageUI.Visible(main))
            end
        elseif dst > 2 and RageUI.CurrentMenu == main then
            Citizen.CreateThread(function()
                RageUI.CloseAll()
            end)
        end
        Wait(sleep)
    end
end)

function RageUI.PoolMenus:ConcessAuto()
    main:IsVisible(function(Items)
        Items:AddSeparator('↓ ' .. Config.MainColor .. 'Catégories~s~ ↓')
        Items:Line()
        for k,v in pairs(Config.Class) do
            Items:AddButton(v, nil, {RightLabel = Config.RightLabel}, function(onSelected) 
                if onSelected then
                    ESX.TriggerServerCallback("LConncessAuto:GetVehicles", function(vehicles) 
                        ListVehicles = vehicles
                        category:SetSubtitle(v)
                    end, k)
                end
            end, category)
        end
    end, function() end)
    category:IsVisible(function(Items)
        Items:AddSeparator('↓ ' .. Config.MainColor .. 'Véhicules~s~ ↓')
        Items:Line()
        for i = 1, #ListVehicles do

            if Config.BlackList[ListVehicles[i].model] then
                goto continue
            end

            Items:AddButton(ListVehicles[i].name, nil, {RightLabel = ListVehicles[i].price .. '$'}, function(onSelected, Active) 
                vehicleInfo = ListVehicles[i]
                vehicle:SetSubtitle(ListVehicles[i].name)
            end, vehicle)

            ::continue::
        end
    end, function() end)
    vehicle:IsVisible(function(Items)
        Items:AddSeparator('↓ ' .. Config.MainColor .. 'Informations~s~ ↓')
        Items:Line()
        if preview == false then
            Items:AddButton("Visualiser le véhicule", nil, {RightLabel = Config.RightLabel}, function(onSelected, Active)
                if onSelected then
                    preview = true
                    TriggerServerEvent('LConncessAuto:AddPlayerInRoutingBucket', GetPlayerServerId(PlayerId()))
                    SetEntityVisible(PlayerPedId(), false)
                    local vehicle = vehicleInfo.model
                    if not IsModelInCdimage(vehicle) then return end
                    RequestModel(vehicle)
                    while not HasModelLoaded(vehicle) do
                      Wait(0)
                    end
                    local veh = CreateVehicle(vehicle, Config.PreviewSpawnCar.x, Config.PreviewSpawnCar.y, Config.PreviewSpawnCar.z, Config.PreviewSpawnCar.w, false, false)
                    SetModelAsNoLongerNeeded(veh)
                    TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
                    FreezeEntityPosition(veh, true)
                    local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
                    RenderScriptCams(true, true, 500)
                    SetCamCoord(cam, Config.CamPos.x, Config.CamPos.y, Config.CamPos.z)
                    SetCamRot(cam, -20.0, 0.0, Config.CamPos.w)
                    CreateThread(function()
                        while preview do
                            Wait(0)
                            SetEntityHeading(veh, GetEntityHeading(veh) + 0.1)
                            DisableControlAction(0, 75, true)
                        end
                    end)
                end
            end)
        else
            Items:AddButton("Arrêter de visualiser le véhicule", nil, {RightLabel = Config.RightLabel}, function(onSelected, Active)
                if Active then
                    if IsControlJustPressed(1, 177) then
                        preview = false
                        TriggerServerEvent('LConncessAuto:ResetPlayerInRoutingBucket', GetPlayerServerId(PlayerId()))
                        SetEntityVisible(PlayerPedId(), true)
                        RenderScriptCams(false, true, 500)
                        SetEntityAsNoLongerNeeded(veh)
                        SetModelAsNoLongerNeeded(veh)
                        DeleteEntity(GetVehiclePedIsIn(PlayerPedId(), false))
                        DestroyCam(cam, false)
                        SetEntityCoords(PlayerPedId(), Config.DrawMarkerPos)
                    end
                end
                if onSelected then
                    preview = false
                    TriggerServerEvent('LConncessAuto:ResetPlayerInRoutingBucket', GetPlayerServerId(PlayerId()))
                    SetEntityVisible(PlayerPedId(), true)
                    RenderScriptCams(false, true, 500)
                    SetEntityAsNoLongerNeeded(veh)
                    SetModelAsNoLongerNeeded(veh)
                    DeleteEntity(GetVehiclePedIsIn(PlayerPedId(), false))
                    DestroyCam(cam, false)
                    SetEntityCoords(PlayerPedId(), Config.DrawMarkerPos)
                end
            end)
        end
        Items:AddButton("Acheter le véhicule", nil, {RightLabel = Config.RightLabel}, function(onSelected, Active)
            if onSelected then
                TriggerServerEvent('LConncessAuto:BuyVehicle', vehicleInfo.model, vehicleInfo.price)
                if preview then
                    preview = false
                    TriggerServerEvent('LConncessAuto:ResetPlayerInRoutingBucket', GetPlayerServerId(PlayerId()))
                    SetEntityVisible(PlayerPedId(), true)
                    RenderScriptCams(false, true, 500)
                    SetEntityAsNoLongerNeeded(veh)
                    SetModelAsNoLongerNeeded(veh)
                    DeleteEntity(GetVehiclePedIsIn(PlayerPedId(), false))
                    DestroyCam(cam, false)
                    SetEntityCoords(PlayerPedId(), Config.DrawMarkerPos)
                end
            end
        end)
    end, function() end)
end