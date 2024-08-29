if Config.ESX == "New" then
    ESX = exports["es_extended"]:getSharedObject()
else
    ESX = nil
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
end

local function GeneratePlate()
    local plate = ""
    for i = 1, 6 do
        plate = plate .. string.char(math.random(65, 90))
    end
    return plate
end

ESX.RegisterServerCallback("LConncessAuto:GetVehicles", function(source, cb, category)
    MySQL.Async.fetchAll("SELECT * FROM `vehicles` WHERE `category` = ?", {
        category
    }, function(result)
        cb(result)
    end)
end)

RegisterServerEvent("LConncessAuto:BuyVehicle", function(vehicle, price)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getMoney() >= price then
        xPlayer.removeMoney(price)
        MySQL.Async.execute("INSERT INTO `owned_vehicles` (`owner`, `plate`, `vehicle`, `stored`) VALUES (?, ?, ?, ?)", {
            xPlayer.getIdentifier(),
            GeneratePlate(),
            vehicle,
            1
        })
        ShowNotification("Vous avez acheté un véhicule, retrouvez-le dans votre garage", source)
    else
        ShowNotification("Vous n'avez pas assez d'argent", source)
    end
end)

RegisterServerEvent("LConncessAuto:AddPlayerInRoutingBucket", function(playerId)
    SetPlayerRoutingBucket(playerId, 16)
end)

RegisterServerEvent("LConncessAuto:ResetPlayerInRoutingBucket", function(playerId)
    SetPlayerRoutingBucket(playerId, 0)
end)