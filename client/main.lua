local QBCore = exports['qb-core']:GetCoreObject()
local parcelVehicle = nil
local hasparcel = false
local currentStop = 0
local deliveryBlip = nil
local amountOfparcels = 0
local parcelObject = nil
local endBlip = nil
local parcelBlip = nil
local canTakeparcel = true
local currentStopNum = 0
local PZone = nil
local listen = false
local finished = false
local continueworking = false
local playerJob = {}
-- Handlers

-- Functions

local function setupClient()
    parcelVehicle = nil
    hasparcel = false
    currentStop = 0
    deliveryBlip = nil
    amountOfparcels = 0
    parcelObject = nil
    endBlip = nil
    currentStopNum = 0
    if playerJob.name == Config.Jobname then
        parcelBlip = AddBlipForCoord(Config.Locations["main"].coords.x, Config.Locations["main"].coords.y, Config.Locations["main"].coords.z)
        SetBlipSprite(parcelBlip, 267)
        SetBlipDisplay(parcelBlip, 4)
        SetBlipScale(parcelBlip, 0.8)
        SetBlipAsShortRange(parcelBlip, true)
        SetBlipColour(parcelBlip, 60)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(Config.Locations["main"].label)
        EndTextCommandSetBlipName(parcelBlip)
    end
end



local function LoadAnimation(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(10) end
end

local function BringBackCar()
    DeleteVehicle(parcelVehicle)
    if endBlip then
        RemoveBlip(endBlip)
    end
    if deliveryBlip then
        RemoveBlip(deliveryBlip)
    end
    parcelVehicle = nil
    hasparcel = false
    currentStop = 0
    deliveryBlip = nil
    amountOfparcels = 0
    parcelObject = nil
    endBlip = nil
    currentStopNum = 0
end

local function DeleteZone()
    listen = false
    PZone:destroy()
end

local function SetRouteBack()
    local depot = Config.Locations["main"].coords
    endBlip = AddBlipForCoord(depot.x, depot.y, depot.z)
    SetBlipSprite(endBlip, 1)
    SetBlipDisplay(endBlip, 2)
    SetBlipScale(endBlip, 1.0)
    SetBlipAsShortRange(endBlip, false)
    SetBlipColour(endBlip, 3)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(Config.Locations["vehicle"].label)
    EndTextCommandSetBlipName(endBlip)
    SetBlipRoute(endBlip, true)
    DeleteZone()
    finished = true
end

local function AnimCheck()
    CreateThread(function()
        local ped = PlayerPedId()
        while hasparcel and not IsEntityPlayingAnim(ped, 'anim@heists@load_box', 'load_box_4',3) do
            if not IsEntityPlayingAnim(ped, 'anim@heists@box_carry@', 'walk', 3) then
                ClearPedTasksImmediately(ped)
                LoadAnimation('anim@heists@box_carry@')
                TaskPlayAnim(ped, 'anim@heists@box_carry@', 'walk', 6.0, -6.0, -1, 49, 0, 0, 0, 0)
            end
            Wait(1000)
        end
    end)
end

local function DeliverAnim()
    local ped = PlayerPedId()
    LoadAnimation('anim@heists@load_box')
    TaskPlayAnim(ped, 'anim@heists@load_box', 'load_box_4', 8.0, 8.0, 1100, 48, 0.0, 0, 0, 0)
    FreezeEntityPosition(ped, true)
    SetEntityHeading(ped, GetEntityHeading(parcelVehicle))
    canTakeparcel = false
    SetTimeout(1250, function()
        DetachEntity(parcelObject, 1, false)
        DeleteObject(parcelObject)
        TaskPlayAnim(ped, 'anim@heists@load_box', 'exit', 8.0, 8.0, 1100, 48, 0.0, 0, 0, 0)
        FreezeEntityPosition(ped, false)
        parcelObject = nil
        canTakeparcel = true
    end)
    if Config.UseTarget and hasparcel then
        local CL = Config.Locations["parcel"][currentStop]
        hasparcel = false
        local pos = GetEntityCoords(ped)
        exports['qb-target']:RemoveTargetEntity(parcelVehicle)
        if (amountOfparcels - 1) <= 0 then
            QBCore.Functions.TriggerCallback('parceljob:server:NextStop', function(hasMoreStops, nextStop, newparcelAmount)
                if hasMoreStops and nextStop ~= 0 then
                    -- Here he puts your next location and you are not finished working yet.
                    currentStop = nextStop
                    currentStopNum = currentStopNum + 1
                    amountOfparcels = newparcelAmount
                    SetparcelRoute()
                    QBCore.Functions.Notify(Lang:t("info.all_parcel"))
                    SetVehicleDoorShut(parcelVehicle, 5, false)
                else
                    if hasMoreStops and nextStop == currentStop then
                        QBCore.Functions.Notify(Lang:t("info.depot_issue"))
                        amountOfparcels = 0
                    else
                        -- You are done with work here.
                        QBCore.Functions.Notify(Lang:t("info.done_working"))
                        SetVehicleDoorShut(parcelVehicle, 5, false)
                        RemoveBlip(deliveryBlip)
                        SetRouteBack()
                        amountOfparcels = 0
                    end
                end
            end, currentStop, currentStopNum, pos)
        else
            -- You haven't delivered all parcels here
            amountOfparcels = amountOfparcels - 1
            if amountOfparcels > 1 then
                QBCore.Functions.Notify(Lang:t("info.parcel_left", { value = amountOfparcels }))
            else
                QBCore.Functions.Notify(Lang:t("info.parcel_still", { value = amountOfparcels }))
            end
            exports['qb-target']:AddCircleZone('parcelbin', vector3(CL.coords.x, CL.coords.y, CL.coords.z), 2.0,{
                name = 'parcelbin', debugPoly = false, useZ=true}, {
                options = {{label = Lang:t("target.grab_parcel"),icon = 'fa-solid fa-box', action = function() TakeAnim() end}},
                distance = 2.0
            })
        end
    end
end

function TakeAnim()
    local ped = PlayerPedId()
    QBCore.Functions.Progressbar("parcel_pickup", Lang:t("info.picking_parcel"), math.random(3000, 5000), false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "timetable@jimmy@doorknock@",
        anim = "knockdoor_idle",
        flags = 16,
    }, {}, {}, function()
        LoadAnimation('anim@heists@box_carry@')
        TaskPlayAnim(ped, 'anim@heists@box_carry@', 'walk', 6.0, -6.0, -1, 49, 0, 0, 0, 0)
        parcelObject = CreateObject(`prop_cs_cardbox_01`, 0, 0, 0, true, true, true)
        AttachEntityToEntity(parcelObject, ped, GetPedBoneIndex(ped, 57005), 0.12, 0.0, -0.05, 220.0, 120.0, 0.0, true, true, false, true, 1, true)
        StopAnimTask(PlayerPedId(), "timetable@jimmy@doorknock@","knockdoor_idle", 1.0)
        AnimCheck()
        if Config.UseTarget and not hasparcel then
            hasparcel = true
            exports['qb-target']:RemoveZone("parcelbin")
            exports['qb-target']:AddTargetEntity(parcelVehicle, {
            options = {
                {label = Lang:t("target.keep_parcel"),icon = 'fa-solid fa-box',action = function() DeliverAnim() end,canInteract = function() if hasparcel then return true end return false end, }
            },
            distance = 2.0
            })
        end
    end, function()
        StopAnimTask(PlayerPedId(), "timetable@jimmy@doorknock@", "knockdoor_idle", 1.0)
        QBCore.Functions.Notify(Lang:t("error.cancled"), "error")
    end)
end

local function RunWorkLoop()
    CreateThread(function()
        local GarbText = false
        while listen do
            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped)
            local DeliveryData = Config.Locations["parcel"][currentStop]
            local Distance = #(pos - vector3(DeliveryData.coords.x, DeliveryData.coords.y, DeliveryData.coords.z))
            if Distance < 15 or hasparcel then

                if not hasparcel and canTakeparcel then
                    if Distance < 1.5 then
                        if not GarbText then
                            GarbText = true
                            exports['qb-core']:DrawText(Lang:t("info.grab_parcel"), 'left')
                        end
                        if IsControlJustPressed(0, 51) then
                            hasparcel = true
                            exports['qb-core']:HideText()
                            TakeAnim()
                        end
                    elseif Distance < 10 then
                        if GarbText then
                            GarbText = false
                            exports['qb-core']:HideText()
                        end
                    end
                else
                    if DoesEntityExist(parcelVehicle) then
                        local Coords = GetOffsetFromEntityInWorldCoords(parcelVehicle, 0.0, -4.5, 0.0)
                        local carDist = #(pos - Coords)
                        local TrucText = false

                        if carDist < 2 then
                            if not TrucText then
                                TrucText = true
                                exports['qb-core']:DrawText(Lang:t("info.keep_parcel"), 'left')
                            end
                            if IsControlJustPressed(0, 51) and hasparcel then
                                StopAnimTask(PlayerPedId(), 'anim@heists@box_carry@', 'walk', 1.0)
                                DeliverAnim()
                                QBCore.Functions.Progressbar("deliverparcel", Lang:t("info.progressbar"), 2000, false, true, {
                                        disableMovement = true,
                                        disableCarMovement = true,
                                        disableMouse = false,
                                        disableCombat = true,
                                    }, {}, {}, {}, function() -- Done
                                        hasparcel = false
                                        canTakeparcel = false
                                        DetachEntity(parcelObject, 1, false)
                                        DeleteObject(parcelObject)
                                        FreezeEntityPosition(ped, false)
                                        parcelObject = nil
                                        canTakeparcel = true
                                        -- Looks if you have delivered all parcels
                                        if (amountOfparcels - 1) <= 0 then
                                            QBCore.Functions.TriggerCallback('parceljob:server:NextStop', function(hasMoreStops, nextStop, newparcelAmount)
                                                if hasMoreStops and nextStop ~= 0 then
                                                    -- Here he puts your next location and you are not finished working yet.
                                                    currentStop = nextStop
                                                    currentStopNum = currentStopNum + 1
                                                    amountOfparcels = newparcelAmount
                                                    SetparcelRoute()
                                                    QBCore.Functions.Notify(Lang:t("info.all_parcel"))
                                                    listen = false
                                                    SetVehicleDoorShut(parcelVehicle, 5, false)
                                                else
                                                    if hasMoreStops and nextStop == currentStop then
                                                        QBCore.Functions.Notify(Lang:t("info.depot_issue"))
                                                        amountOfparcels = 0
                                                    else
                                                        -- You are done with work here.
                                                        QBCore.Functions.Notify(Lang:t("info.done_working"))
                                                        SetVehicleDoorShut(parcelVehicle, 5, false)
                                                        RemoveBlip(deliveryBlip)
                                                        SetRouteBack()
                                                        amountOfparcels = 0
                                                        listen = false
                                                    end
                                                end
                                            end, currentStop, currentStopNum, pos)
                                            hasparcel = false
                                        else
                                            -- You haven't delivered all parcels here
                                            amountOfparcels = amountOfparcels - 1
                                            if amountOfparcels > 1 then
                                                QBCore.Functions.Notify(Lang:t("info.parcel_left", { value = amountOfparcels }))
                                            else
                                                QBCore.Functions.Notify(Lang:t("info.parcel_still", { value = amountOfparcels }))
                                            end
                                            hasparcel = false
                                        end

                                        Wait(1500)
                                        if TrucText then
                                            exports['qb-core']:HideText()
                                            TrucText = false
                                        end
                                    end, function() -- Cancel
                                    QBCore.Functions.Notify(Lang:t("error.cancled"), "error")
                                end)

                            end
                        end
                    else
                        QBCore.Functions.Notify(Lang:t("error.no_car"), "error")
                        hasparcel = false
                    end
                end
            end
            Wait(1)
        end
    end)
end

local function CreateZone(x, y, z)
    CreateThread(function()
        PZone = CircleZone:Create(vector3(x, y, z), 15.0, {
            name = "NewRouteWhoDis",
            debugPoly = false,
        })

        PZone:onPlayerInOut(function(isPointInside)
            if isPointInside then
                if not Config.UseTarget then
                    listen = true
                    RunWorkLoop()
                end
                SetVehicleDoorOpen(parcelVehicle,5,false,false)
            else
                if not Config.UseTarget then
                    exports['qb-core']:HideText()
                    listen = false
                end
                SetVehicleDoorShut(parcelVehicle, 5, false)
            end
        end)
    end)
end

function SetparcelRoute()
    local CL = Config.Locations["parcel"][currentStop]
    if deliveryBlip then
        RemoveBlip(deliveryBlip)
    end
    deliveryBlip = AddBlipForCoord(CL.coords.x, CL.coords.y, CL.coords.z)
    SetBlipSprite(deliveryBlip, 1)
    SetBlipDisplay(deliveryBlip, 2)
    SetBlipScale(deliveryBlip, 1.0)
    SetBlipAsShortRange(deliveryBlip, false)
    SetBlipColour(deliveryBlip, 27)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(Config.Locations["parcel"][currentStop].name)
    EndTextCommandSetBlipName(deliveryBlip)
    SetBlipRoute(deliveryBlip, true)
    finished = false
    if Config.UseTarget and not hasparcel then
        exports['qb-target']:AddCircleZone('parcelbin', vector3(CL.coords.x, CL.coords.y, CL.coords.z), 2.0,{
            name = 'parcelbin', debugPoly = false, useZ=true }, {
            options = {{label = Lang:t("target.grab_parcel"), icon = 'fa-solid fa-trash', action = function() TakeAnim() end }},
            distance = 2.0
        })
    end
    if PZone then
        DeleteZone()
        Wait(500)
        CreateZone(CL.coords.x, CL.coords.y, CL.coords.z)
    else
        CreateZone(CL.coords.x, CL.coords.y, CL.coords.z)
    end
end

local ControlListen = false
local function Listen4Control()
    ControlListen = true
    CreateThread(function()
        while ControlListen do
            if IsControlJustReleased(0, 38) then
                TriggerEvent("ef-parceljob:client:MainMenu")
            end
            Wait(1)
        end
    end)
end

local pedsSpawned = false
local function spawnPeds()
    if not Config.Peds or not next(Config.Peds) or pedsSpawned then return end
    for i = 1, #Config.Peds do
        local current = Config.Peds[i]
        current.model = type(current.model) == 'string' and GetHashKey(current.model) or current.model
        RequestModel(current.model)
        while not HasModelLoaded(current.model) do
            Wait(0)
        end
        local ped = CreatePed(0, current.model, current.coords, false, false)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        current.pedHandle = ped

        if Config.UseTarget then
            exports['qb-target']:AddTargetEntity(ped, {
                options = {{type = "client", event = "ef-parceljob:client:MainMenu", label = Lang:t("target.talk"), icon = 'fa-solid fa-recycle', job = "parcel",}},
                distance = 2.0
            })
        else
            local options = current.zoneOptions
            if options then
                local zone = BoxZone:Create(current.coords.xyz, options.length, options.width, {
                    name = "zone_cityhall_" .. ped,
                    heading = current.coords.w,
                    debugPoly = false
                })
                zone:onPlayerInOut(function(inside)
                    if LocalPlayer.state.isLoggedIn then
                        if inside then
                            exports['qb-core']:DrawText(Lang:t("info.talk"), 'left')
                            Listen4Control()
                        else
                            ControlListen = false
                            exports['qb-core']:HideText()
                        end
                    end
                end)
            end
        end
    end
    pedsSpawned = true
end

local function deletePeds()
    if not Config.Peds or not next(Config.Peds) or not pedsSpawned then return end
    for i = 1, #Config.Peds do
        local current = Config.Peds[i]
        if current.pedHandle then
            DeletePed(current.pedHandle)
        end
    end
end

-- Events

RegisterNetEvent('parceljob:client:SetWaypointHome', function()
    SetNewWaypoint(Config.Locations["main"].coords.x, Config.Locations["main"].coords.y)
end)

RegisterNetEvent('ef-parceljob:client:RequestRoute', function()
    if parcelVehicle then continueworking = true TriggerServerEvent('parceljob:server:PayShift', continueworking) end
    QBCore.Functions.TriggerCallback('parceljob:server:NewShift', function(shouldContinue, firstStop, totalparcels)
        if shouldContinue then
            if not parcelVehicle then
                local occupied = false
                for _,v in pairs(Config.Locations["vehicle"].coords) do
                    if not IsAnyVehicleNearPoint(vector3(v.x,v.y,v.z), 2.5) then
                        QBCore.Functions.TriggerCallback('QBCore:Server:SpawnVehicle', function(netId)
                            local veh = NetToVeh(netId)
                            SetVehicleEngineOn(veh, false, true)
                            parcelVehicle = veh
                            SetVehicleNumberPlateText(veh, "QB-" .. tostring(math.random(1000, 9999)))
                            SetEntityHeading(veh, v.w)
                            exports['LegacyFuel']:SetFuel(veh, 100.0)
                            SetVehicleFixed(veh)
                            SetEntityAsMissionEntity(veh, true, true)
                            SetVehicleDoorsLocked(veh, 2)
                            currentStop = firstStop
                            currentStopNum = 1
                            amountOfparcels = totalparcels
                            SetparcelRoute()
                            TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
                            QBCore.Functions.Notify(Lang:t("info.deposit_paid", { value = Config.carPrice }))
                            QBCore.Functions.Notify(Lang:t("info.started"))
                            TriggerServerEvent("ef-parceljob:server:payDeposit")
                        end, Config.Vehicle, v, false)
                        return
                    else
                        occupied = true
                    end
                end
                if occupied then
                    QBCore.Functions.Notify(Lang:t("error.all_occupied"))
                end
            end
            currentStop = firstStop
            currentStopNum = 1
            amountOfparcels = totalparcels
            SetparcelRoute()
        else
            QBCore.Functions.Notify(Lang:t("info.not_enough", { value = Config.carPrice }))
        end
    end, continueworking)
end)

RegisterNetEvent('ef-parceljob:client:RequestPaycheck', function()
    if parcelVehicle then
        BringBackCar()
        QBCore.Functions.Notify(Lang:t("info.car_returned"))
    end
    TriggerServerEvent('parceljob:server:PayShift')
end)

RegisterNetEvent('ef-parceljob:client:MainMenu', function()
    if playerJob.name == Config.Jobname then
        local MainMenu = {}
        MainMenu[#MainMenu+1] = {isMenuHeader = true,header = Lang:t("menu.header")}
        MainMenu[#MainMenu+1] = { header = Lang:t("menu.collect"),txt = Lang:t("menu.return_collect"),params = { event = 'ef-parceljob:client:RequestPaycheck',}}
        if not parcelVehicle or finished then
            MainMenu[#MainMenu+1] = { header = Lang:t("menu.route"), txt = Lang:t("menu.request_route"), params = { event = 'ef-parceljob:client:RequestRoute',}}
        end
        exports['qb-menu']:openMenu(MainMenu)
    else
        QBCore.Functions.Notify(Lang:t("error.job"))
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    playerJob = QBCore.Functions.GetPlayerData().job
    setupClient()
    spawnPeds()
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    playerJob = JobInfo
    if parcelBlip then
        RemoveBlip(parcelBlip)
    end
    if endBlip then
        RemoveBlip(endBlip)
    end
    if deliveryBlip then
        RemoveBlip(deliveryBlip)
    end
    endBlip = nil
    deliveryBlip = nil
    setupClient()
    spawnPeds()
end)

AddEventHandler('onResourceStop', function(resource)
    if GetCurrentResourceName() == resource then
        if parcelObject then
            DeleteEntity(parcelObject)
            parcelObject = nil
        end
        deletePeds()
    end
end)

AddEventHandler('onResourceStart', function(resource)
    if GetCurrentResourceName() == resource then
        playerJob = QBCore.Functions.GetPlayerData().job
        setupClient()
        spawnPeds()
    end
end)