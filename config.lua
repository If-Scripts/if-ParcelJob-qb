Config = {}

Config.UseTarget = GetConvar('UseTarget', 'false') == 'true'
Config.Jobname = 'parcel'
-- Price taken and given back when delivered a car
Config.carPrice = 250

-- How many stops minimum should the job roll?
Config.MinStops = 5

-- Upper worth per parcel
Config.parcelUpperWorth = 100

-- Lower worth per parcel
Config.parcelLowerWorth = 50

-- Minimum parcels per stop
Config.MinparcelsPerStop = 1

-- Maximum parcels per stop
Config.MaxparcelsPerStop = 1

-- WIP: Do not use
-- If you want to use custom routes instead of random amount of stops stops set to true
Config.UsePreconfiguredRoutes = false

Config.Peds = {
    {
        model = 'cs_movpremmale',
        coords = vector4(223.16, 121.61, 101.7, 248.7),
        zoneOptions = { -- Used for when UseTarget is false
            length = 3.0,
            width = 3.0
        }
    }
}

Config.Locations = {
    ["main"] = {
        label = "Parcel Collecting Job",
        coords = vector3(232.62, 116.47, 102.6),
    },
    ["vehicle"] = {
        label = "Parcel Car Store",
        coords = { -- parking spot locations to spawn parcel
            [1] = vector4(239.33, 115.06, 102.52, 339.31),
            [2] = vector4(233.17, 117.32, 102.5, 340.47),
        },
    },
    ["paycheck"] = {
        label = "Payslip Collection",
        coords = vector3(223.78, 121.24, 102.78),
    },
    ["parcel"] ={
        [1] = {
            name = "forumdrive",
            coords = vector4(-148.02, -1687.47, 33.07, 324.3),
        },
        [2] = {
            name = "grovestreet",
            coords = vector4(114.36, -1961.2, 21.33, 204.04),
        },
        [3] = {
            name = "jamestownstreet",
            coords = vector4(332.35, -2018.47, 22.35, 319.99),
        },
        [4] = {
            name = "davisave",
            coords = vector4(412.18, -1488.48, 30.15, 219.35),
        },
        [5] = {
            name = "littlebighornavenue",
            coords = vector4(485.93, -1296.08, 29.59, 91.54),
        },
        [6] = {
            name = "vespucciblvd",
            coords = vector4(296.18, -1027.4, 29.21, 13.51),
        },
        [7] = {
            name = "elginavenue",
            coords = vector4(246.26, -678.0, 37.74, 251.83),
        },
        [8] = {
            name = "elginavenue2",
            coords = vector4(543.51, -204.41, 54.16, 199.5),
        },
        [9] = {
            name = "powerstreet",
            coords = vector4(280.31, -25.91, 73.53, 330.63),
        },
        [10] = {
            name = "altastreet",
            coords = vector4(210.0, 272.98, 105.59, 72.93),
        },
        [11] = {
            name = "didiondrive",
            coords = vector4(-2.84, 398.25, 120.45, 344.67),
        },
        [12] = {
            name = "miltonroad",
            coords = vector4(-556.35, 275.6, 83.08, 356.45),
        },
        [13] = {
            name = "eastbourneway",
            coords = vector4(-663.36, -172.22, 37.77, 298.2),
        },
        [14] = {
            name = "eastbourneway2",
            coords = vector4(-757.88, -230.74, 37.28, 291.19),
        },
        [15] = {
            name = "industrypassage",
            coords = vector4(-1060.95, -521.59, 36.09, 202.15),
        },
     --You Can Add More Locations Here
    },
}

Config.Vehicle = 'boxville2' -- vehicle name used to spawn