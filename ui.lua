local UI = {}

function UI.Build(deps, library)
    local S = deps.Config.S
    local ESPFlags = deps.Config.ESPFlags
    local esp = deps.ESP

    local function refresh()
        if esp and esp.refresh_elements then
            pcall(function() esp:refresh_elements() end)
        end
    end

    local dim2 = UDim2.new

    local window = library:window({
        name = "PastaSense | " .. os.date("%b %d %Y"),
        size = dim2(0, 604, 0, 628),
    })

    -- ============ COMBAT / AIMBOT ============
    local aimTab = window:tab({name = "Aimbot"})
    do
        local col = aimTab:column()
        local aimSec, tuneSec = col:multi_section({names = {"Aimbot", "Tuning"}})

        aimSec:toggle({
            name = "Enable Aimbot",
            flag = "Aimbot_Enabled",
            callback = function(bool) S.Aimbot_Enabled = bool end,
        })
        aimSec:toggle({
            name = "Wall Check",
            flag = "Aimbot_WallCheck",
            callback = function(bool) S.Aimbot_WallCheck = bool end,
        })
        aimSec:toggle({
            name = "Toggle Mode",
            flag = "Aimbot_ToggleMode",
            tooltip = "OFF = hold RMB, ON = FOV Toggle",
            callback = function(bool) S.Aimbot_ToggleMode = bool end,
        })
        aimSec:toggle({
            name = "Team Check",
            flag = "TeamCheck",
            callback = function(bool) S.TeamCheck = bool end,
        })
        aimSec:toggle({
            name = "Death Check",
            flag = "DeathCheck",
            callback = function(bool) S.DeathCheck = bool end,
        })
        aimSec:toggle({
            name = "Show FOV",
            flag = "Show_FOV",
            callback = function(bool) S.Show_FOV = bool end,
        })
        aimSec:dropdown({
            name = "Hitbox",
            flag = "Hitbox",
            items = {"Head", "Torso", "Random"},
            default = "Head",
            callback = function(v) S.Hitbox = v end,
        })

        tuneSec:slider({
            name = "Smoothing",
            flag = "Aim_Smoothing",
            min = 0, max = 1, interval = 0.01,
            default = S.Aim_Smoothing,
            callback = function(v) S.Aim_Smoothing = v end,
        })
        tuneSec:slider({
            name = "FOV",
            flag = "Aim_FOV",
            min = 10, max = 800, interval = 1,
            default = S.Aim_FOV_Hold,
            callback = function(v) S.Aim_FOV_Hold = v; S.Aim_FOV_Toggle = v end,
        })
        tuneSec:slider({
            name = "Max Distance",
            flag = "Aim_MaxDist",
            min = 100, max = 5000, interval = 10,
            default = S.Aim_MaxDistance,
            callback = function(v) S.Aim_MaxDistance = v end,
        })
        tuneSec:colorpicker({
            name = "Lock Color",
            flag = "Aimbot_LockColor",
            color = S.Aimbot_LockColor,
            callback = function(color) S.Aimbot_LockColor = color end,
        })
    end

    -- ============ COMBAT / TRIGGER ============
    local trigTab = window:tab({name = "Trigger"})
    do
        local col = trigTab:column()
        local sec = col:section({name = "Triggerbot"})

        sec:toggle({
            name = "Enable Trigger",
            flag = "Trigger_Enabled",
            callback = function(bool) S.Trigger_Enabled = bool end,
        })
        sec:slider({
            name = "Delay (ms)",
            flag = "Trigger_Delay",
            min = 0, max = 500, interval = 1,
            default = S.Trigger_Delay,
            callback = function(v) S.Trigger_Delay = v end,
        })
    end

    -- ============ VISUALS / ENEMIES ============
    local espTab = window:tab({name = "ESP"})
    do
        local col = espTab:column()
        local genSec = col:section({name = "General", toggle = false})
        genSec:toggle({
            name = "Enable ESP",
            flag = "Enabled",
            callback = function(bool) S.ESP_Enabled = bool; ESPFlags["Enabled"] = bool; refresh() end,
        })
        genSec:slider({
            name = "Max Distance",
            flag = "ESP_MaxDistance",
            min = 100, max = 5000, interval = 10,
            default = S.ESP_MaxDistance,
            callback = function(v) S.ESP_MaxDistance = v end,
        })

        genSec:toggle({
            name = "Names",
            flag = "Names",
            callback = function(bool) ESPFlags["Names"] = bool; refresh() end,
        }):colorpicker({
            name = "Name Color",
            flag = "Name_Color",
            color = ESPFlags["Name_Color"].Color,
            callback = function(color) ESPFlags["Name_Color"].Color = color; refresh() end,
        })

        local boxToggle = genSec:toggle({
            name = "Boxes",
            flag = "Boxes",
            callback = function(bool) ESPFlags["Boxes"] = bool; refresh() end,
        })
        boxToggle:colorpicker({
            name = "Box Color",
            flag = "Box_Color",
            color = ESPFlags["Box_Color"].Color,
            callback = function(color) ESPFlags["Box_Color"].Color = color; refresh() end,
        })

        genSec:dropdown({
            name = "Box Type",
            flag = "Box_Type",
            items = {"Corner", "Full"},
            default = "Corner",
            callback = function(v) ESPFlags["Box_Type"] = v; refresh() end,
        })

        local hpToggle = genSec:toggle({
            name = "Healthbar",
            flag = "Healthbar",
            callback = function(bool) ESPFlags["Healthbar"] = bool; refresh() end,
        })
        hpToggle:colorpicker({
            name = "High HP",
            flag = "Health_High",
            color = ESPFlags["Health_High"].Color,
            callback = function(color) ESPFlags["Health_High"].Color = color end,
        })
        hpToggle:colorpicker({
            name = "Low HP",
            flag = "Health_Low",
            color = ESPFlags["Health_Low"].Color,
            callback = function(color) ESPFlags["Health_Low"].Color = color end,
        })

        genSec:toggle({
            name = "Distance",
            flag = "Distance",
            callback = function(bool) ESPFlags["Distance"] = bool; refresh() end,
        }):colorpicker({
            name = "Distance Color",
            flag = "Distance_Color",
            color = ESPFlags["Distance_Color"].Color,
            callback = function(color) ESPFlags["Distance_Color"].Color = color; refresh() end,
        })

        genSec:toggle({
            name = "Weapon",
            flag = "Weapon",
            callback = function(bool) ESPFlags["Weapon"] = bool; refresh() end,
        }):colorpicker({
            name = "Weapon Color",
            flag = "Weapon_Color",
            color = ESPFlags["Weapon_Color"].Color,
            callback = function(color) ESPFlags["Weapon_Color"].Color = color; refresh() end,
        })
    end

    -- ============ VISUALS / TEAMMATES ============
    local tmTab = window:tab({name = "Team"})
    do
        local col = tmTab:column()
        local sec, colors = col:multi_section({names = {"Teammates", "Colors"}})

        sec:toggle({
            name = "Enable Teammates ESP",
            flag = "Teammates_Enabled",
            callback = function(bool) S.Teammates_Enabled = bool; refresh() end,
        })
        sec:colorpicker({
            name = "Box Color",
            flag = "Teammate_Box_Color",
            color = S.Teammate_Box_Color,
            callback = function(color) S.Teammate_Box_Color = color; refresh() end,
        })
        sec:colorpicker({
            name = "Name Color",
            flag = "Teammate_Name_Color",
            color = S.Teammate_Name_Color,
            callback = function(color) S.Teammate_Name_Color = color; refresh() end,
        })
        sec:colorpicker({
            name = "Weapon Color",
            flag = "Teammate_Weapon_Color",
            color = S.Teammate_Weapon_Color,
            callback = function(color) S.Teammate_Weapon_Color = color; refresh() end,
        })

        colors:colorpicker({
            name = "Health High",
            flag = "Teammate_Health_High",
            color = S.Teammate_Health_High,
            callback = function(color) S.Teammate_Health_High = color end,
        })
        colors:colorpicker({
            name = "Health Low",
            flag = "Teammate_Health_Low",
            color = S.Teammate_Health_Low,
            callback = function(color) S.Teammate_Health_Low = color end,
        })
        colors:colorpicker({
            name = "Distance Color",
            flag = "Teammate_Distance_Color",
            color = S.Teammate_Distance_Color,
            callback = function(color) S.Teammate_Distance_Color = color; refresh() end,
        })
    end

    -- ============ VISUALS / SELF ============
    local selfTab = window:tab({name = "Self"})
    do
        local col = selfTab:column()
        local sec, matSec = col:multi_section({names = {"Self ESP", "Self Material"}})

        sec:toggle({
            name = "Enable Self ESP",
            flag = "SelfESP_Enabled",
            callback = function(bool) S.SelfESP_Enabled = bool; refresh() end,
        })
        sec:colorpicker({
            name = "Box Color",
            flag = "Self_Box_Color",
            color = S.Self_Box_Color,
            callback = function(color) S.Self_Box_Color = color; refresh() end,
        })
        sec:colorpicker({
            name = "Name Color",
            flag = "Self_Name_Color",
            color = S.Self_Name_Color,
            callback = function(color) S.Self_Name_Color = color; refresh() end,
        })
        sec:colorpicker({
            name = "Weapon Color",
            flag = "Self_Weapon_Color",
            color = S.Self_Weapon_Color,
            callback = function(color) S.Self_Weapon_Color = color; refresh() end,
        })

        matSec:toggle({
            name = "Enable Self Material",
            flag = "SelfChams_Enabled",
            callback = function(bool)
                S.SelfChams_Enabled = bool
                if not bool then pcall(function() deps.Chams.RestoreSelf() end) end
            end,
        })
        matSec:dropdown({
            name = "Material",
            flag = "SelfChams_Material",
            items = {"ForceField", "Neon", "SmoothPlastic", "Plastic", "Glass"},
            default = "ForceField",
            callback = function(v) S.SelfChams_Material = v end,
        })
        matSec:colorpicker({
            name = "Color",
            flag = "SelfChams_Color",
            color = S.SelfChams_Color,
            callback = function(color) S.SelfChams_Color = color end,
        })
    end

    -- ============ WORLD / LIGHTING ============
    local worldTab = window:tab({name = "World"})
    do
        local col = worldTab:column()
        local lightSec, chamsSec = col:multi_section({names = {"Lighting", "Highlights"}})

        lightSec:toggle({
            name = "Fullbright",
            flag = "Fullbright_Enabled",
            callback = function(bool) S.Fullbright_Enabled = bool end,
        })
        lightSec:toggle({
            name = "Ambient",
            flag = "Ambient_Enabled",
            callback = function(bool) S.Ambient_Enabled = bool end,
        })
        lightSec:colorpicker({
            name = "Ambient Color",
            flag = "Ambient_Color",
            color = S.Ambient_Color,
            callback = function(color) S.Ambient_Color = color end,
        })

        chamsSec:toggle({
            name = "Enemy Highlights",
            flag = "Chams_Enabled",
            callback = function(bool)
                S.Chams_Enabled = bool
                if not bool then pcall(function() deps.Chams.RestoreHighlights() end) end
            end,
        })
        chamsSec:colorpicker({
            name = "Highlight Color",
            flag = "Chams_Color",
            color = S.Chams_Color,
            callback = function(color) S.Chams_Color = color end,
        })
        chamsSec:toggle({
            name = "Watermark",
            flag = "Watermark_Enabled",
            callback = function(bool) S.Watermark_Enabled = bool end,
        })
        chamsSec:toggle({
            name = "Tracers",
            flag = "Tracers_Enabled",
            callback = function(bool) S.Tracers_Enabled = bool end,
        })
        chamsSec:button({
            name = "Unload",
            callback = function()
                pcall(function()
                    if deps.Main and deps.Main.Unload then deps.Main.Unload()
                    elseif getgenv().PastaUnload then getgenv().PastaUnload() end
                end)
                pcall(function() library:set_menu_visibility(false) end)
            end,
        })
    end

    return window
end

return UI
