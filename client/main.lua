local QBCore = exports['qb-core']:GetCoreObject()

local holdingMap = false

local objectNetID = nil
local objectModel = "prop_tourist_map_01"

local animDict = "amb@world_human_tourist_map@male@base"
local anim = "base"


-- functions
local function removeMap()
    holdingMap = false
    local playerPed = PlayerPedId()
    ClearPedTasks(playerPed)
    DetachEntity(NetToObj(objectNetID), true, true)
    DeleteEntity(NetToObj(objectNetID))
    objectNetID = nil
end

local function attachMap()
    holdingMap = true
    local objectModelHash = GetHashKey(objectModel)
    RequestModel(objectModelHash)
    while not HasModelLoaded(objectModelHash) do
        Wait(500)
    end

    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Wait(500)
    end

    local playerPed = PlayerPedId()
    local playerCoords = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 0.0, -5.0)
    local object = CreateObject(objectModelHash, playerCoords.x, playerCoords.y, playerCoords.z, true, true, true)
    local netID = ObjToNet(object)
    SetNetworkIdExistsOnAllMachines(netID, true)
    NetworkSetNetworkIdDynamic(netID, true)
    SetNetworkIdCanMigrate(netID, false)
    AttachEntityToEntity(object, playerPed, GetPedBoneIndex(playerPed, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1, 1, 0, 1, 0, 1)
    TaskPlayAnim(playerPed, animDict, anim, 1.0, 1.0, -1, 50, 0, false, false, false)
    objectNetID = netID
end


-- events
RegisterNetEvent('dz-qb-holdmap:client:ToggleMap', function()
    if holdingMap then
        removeMap()
    else
        attachMap()
    end
end)


-- threads
CreateThread(function()
    local sleep = 10000
    while not LocalPlayer.state.isLoggedIn do
        -- do nothing
        Wait(sleep)
    end

    while true do
        if not holdingMap and objectNetID then
            removeMap()
        end

        Wait(sleep)
    end
end)
