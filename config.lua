Config = {}


--[[
  _____       ___   ___  ____   _____           ____  ____  ________  _____     _____  _______     _       ______    
 |_   _|    .'   `.|_  ||_  _| |_   _|         |_   ||   _||_   __  ||_   _|   |_   _||_   __ \   / \     |_   _ `.  
   | |     /  .-.  \ | |_/ /     | |             | |__| |    | |_ \_|  | |       | |    | |__) | / _ \      | | `. \ 
   | |   _ | |   | | |  __'.     | |             |  __  |    |  _| _   | |   _   | |    |  ___/ / ___ \     | |  | | 
  _| |__/ |\  `-'  /_| |  \ \_  _| |_  _______  _| |  | |_  _| |__/ | _| |__/ | _| |_  _| |_  _/ /   \ \_  _| |_.' / 
 |________| `.___.'|____||____||_____||_______||____||____||________||________||_____||_____||____| |____||______.'  
                                                                                                                     
]]


Config.VersionCheck = true
Config.VersionCheckOmitLatest = false -- if true, will not print anything unless your version is outdated


Config.Locale = 'en' -- de or en

Config.InteractionKey = 38 -- key for interacting with the marker. E = 38

Config.LoopWait = 20 -- how long should the wait in the loop for sliding the helipad be? Longer = better performance, shorter = smoother
-- 20ms is equivalent to about every second frame at 60 fps, no matter what you set here it will never update more than once per frame


Config.HelipadModel = `your_helipad_model` -- the 3d model of the helipad. Make sure it is loaded properly. It needs a .ytyp that is loaded with data_file 'DLC_ITYP_REQUEST' 'stream/helipad.ytyp' in the fxmanifest.lua of the resource that contains the model


-- for interacting with the helipad you can use markers, or buttons. Markers are just press E, 
-- buttons are buttons spawned as prop with an optional additional pressing animation and marker
-- comment out marker/button to disable, but keep one of them enabled
Config.Helipads = {
    {   -- helipad 1, add as many more as you'd like by copy pasting this
        job = nil, -- the job that's allowed to use this, or nil/false to allow for everyone
        defaultPosition = "inside", -- this can be inside or outside. This determines whether the helipad spawns on the inside or outside on script start
        slideDuration = 30 * 1000, -- the time it takes in ms to go from inside->outside and the other way around
        coords = { -- you'll have to figure out the coords by trial and error until it looks good :/
            outsideX = -1342.90649, -- the outside coords for the helipad
            outsideY = -3350.28442,

            insideX = -1363.129, -- the inside coords for the helipad
            insideY = -3338.609,

            zPos = 12.9856071, -- z coord for the helipad
            rotation = -30.0, -- rotation of the helipad model
        },
        button = {
            position = vector3(-1365.6, -3343.3188, 14.1),
            rotation = vector3(0.0, 0.0, 150.0),
            model = `h4_prop_h4_casino_button_01b`,
            anim = { -- comment out to disable
                dict = "anim_heist@hs3f@ig6_push_button@",
                anim = "push_button",
                playerPos = vector4(-1364.35, -3343.0, 12.9408, 155.3572),
                duration = 1800 -- duration of the anim in ms
            },
        },
        marker = { -- comment out to disable
            position = vector3(-1365.3372, -3342.9775, 12.9408),
            type = 1, -- documentation for marker types: https://docs.fivem.net/docs/game-references/markers/
            rotation = vector3(0.0, 0.0, 0.0),
            scale = 1.0, -- marker size. Has to be a float (with decimal point)
            color = { -- Markers color as standard RGB value (0 - 255)
                r = 110,
                g = 243,
                b = 243
            },
            transparency = 100, -- marker transparency from 0 - 255. 0 = invisible, 255 = not transparent at all
            bop = false, -- if true, the marker will bop up and down
            faceCamera = false, -- if true, the marker will always sync its rotation towards the player
            rotate = false, -- if true, the marker will always rotate around itself
        }
    },
}


-- these are used as offsets when attatching the helicopter to the helipad while moving
Config.DefaultOffset = vector3(0.0, 0.0, 1.0) -- used when no custom value is specified for the model
Config.CustomOffsets = { -- use this to change the position for different helicopters that have different shapes or where the model center is placed differently. Adjust this if you heli floats in the air or bugs in the ground while moving
    [`cargobob`] = vector3(0.0, 0.0, 1.5),
}
