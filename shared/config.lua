Config = {

    ESX = "New", -- "Old" or "New"

    MainColor = "~b~",
    RightLabel = ">",
    
    PedType = "a_m_y_business_02", -- https://docs.fivem.net/docs/game-references/ped-models/
    PedPos = vec4(-57.151386260986, -1098.9992675781, 25.422426223755, 28.024740219116),

    EnableBlips = true,
    BlipPos = vec3(-57.728572845459, -1097.6820068359, 26.422348022461),
    BlipName = "Concessionnaire", -- Nom du blip
    BlipSprite = 227, -- Sprite du blip
    BlipColor = 29, -- Couleur du blip
    BlipScale = 0.9, -- Taille du blip

    DrawMarkerPos = vec3(-57.973468780518, -1097.52734375, 26.422334671021),

    CamPos = vec4(-52.042942047119, -1094.7326660156, 28.422344207764, 248.5131072998),
    PreviewSpawnCar = vec4(-45.629634857178, -1097.1435546875, 26.422361373901, 65.257019042969),

    TestDrive = true,
    TestDriveTime = 30000, -- 30 secondes
    TestDrivePos = vec4(-905.18316650391, -3292.7409667969, 13.944423675537, 58.192096710205),

    Class = {
        ["compacts"] = "Compacts",
        ["sedans"] = "Sedans",
        ["suvs"] = "SUVs",
        ["coupes"] = "Coupes",
        ["muscle"] = "Muscle",
        ["sportsclassics"] = "Sports Classics",
        ["sports"] = "Sports",
        ["super"] = "Super",
        ["motorcycles"] = "Moto",
        ["offroad"] = "Off-Road",
        ["vans"] = "Vans",
    },

    BlackList = {
        ["dilettante2"] = true,
        ["issi3"] = true,
        ["issi4"] = true,
        ["issi5"] = true,
        ["issi6"] = true,
        ["rrocket"] = true,
        ["oppressor2"] = true,
        ["deathbike3"] = true,
        ["deathbike2"] = true,
        ["oppressor"] = true,
        ["shotaro"] = true,
    }
}

function ShowNotification(text, id)
    if id == nil then
        TriggerEvent("Notif:ShowNotification", text)
        -- TriggerEvent('esx:showNotification', text)
    else
        TriggerClientEvent("Notif:ShowNotification", id, text)
        -- TriggerClientEvent('esx:showNotification', id, text)
    end
end