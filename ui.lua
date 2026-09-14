-- ui.lua вЂ” Splix UI + PastaSense module binding

local UI = {}

function UI.Build(deps, library)
    local S = deps.Config.S
    local F = deps.Config.ESPFlags
    local esp = deps.ESP
    local chams = deps.Chams

    local function safe(...)
        return pcall(...)
    end

    local function refresh()
        safe(esp.refresh_elements, esp)
    end

    local window = library:New({ Name = "PastaSense", Accent = Color3.fromRGB(155, 150, 219) })

    -- в•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђ
    -- COMBAT TAB
    -- в•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђ
    local combatPage = window:Page({ Name = "Combat" })

    -- Left: Aimbot
    local aim = combatPage:Section({ Name = "Aimbot", Side = "left" })

    aim:Toggle({
        Name = "Enable Aimbot",
        Default = S.Aimbot_Enabled,
        Pointer = "Aimbot_Enabled",
        Callback = function(state)
            safe(function() S.Aimbot_Enabled = state end)
        end
    })

    aim:Toggle({
        Name = "Wall Check",
        Default = S.Aimbot_WallCheck,
        Pointer = "Aimbot_WallCheck",
        Callback = function(state)
            safe(function() S.Aimbot_WallCheck = state end)
        end
    })

    aim:Toggle({
        Name = "Toggle Mode",
        Default = S.Aimbot_ToggleMode,
        Pointer = "Aimbot_ToggleMode",
        Callback = function(state)
            safe(function() S.Aimbot_ToggleMode = state end)
        end
    })

    aim:Toggle({
        Name = "Team Check",
        Default = S.TeamCheck,
        Pointer = "TeamCheck",
        Callback = function(state)
            safe(function() S.TeamCheck = state end)
        end
    })

    aim:Toggle({
        Name = "Death Check",
        Default = S.DeathCheck,
        Pointer = "DeathCheck",
        Callback = function(state)
            safe(function() S.DeathCheck = state end)
        end
    })

    aim:Toggle({
        Name = "Show FOV",
        Default = S.Show_FOV,
        Pointer = "Show_FOV",
        Callback = function(state)
            safe(function() S.Show_FOV = state end)
        end
    })

    safe(function()
        aim:Dropdown({
            Name = "Hitbox",
            Options = { "Head", "Torso", "Random" },
            Default = S.Hitbox,
            Pointer = "Hitbox",
            Callback = function(value)
                safe(function() S.Hitbox = value end)
            end
        })
    end)

    -- Right: Tuning
    local tune = combatPage:Section({ Name = "Tuning", Side = "right" })

    tune:Slider({
        Name = "Smoothing",
        Default = math.floor(S.Aim_Smoothing * 100 + 0.5),
        Minimum = 0,
        Maximum = 100,
        Decimals = 1,
        Measurement = "%",
        Pointer = "Aim_Smoothing",
        Callback = function(value)
            safe(function() S.Aim_Smoothing = value / 100 end)
        end
    })

    tune:Slider({
        Name = "FOV",
        Default = S.Aim_FOV_Hold,
        Minimum = 10,
        Maximum = 800,
        Decimals = 0,
        Measurement = "",
        Pointer = "Aim_FOV",
        Callback = function(value)
            safe(function()
                S.Aim_FOV_Hold = value
                S.Aim_FOV_Toggle = value
            end)
        end
    })

    tune:Slider({
        Name = "Max Distance",
        Default = S.Aim_MaxDistance,
        Minimum = 100,
        Maximum = 5000,
        Decimals = 0,
        Measurement = "",
        Pointer = "Aim_MaxDistance",
        Callback = function(value)
            safe(function() S.Aim_MaxDistance = value end)
        end
    })

    tune:Colorpicker({
        Name = "Lock Color",
        Default = S.Aimbot_LockColor,
        Pointer = "Aimbot_LockColor",
        Callback = function(color, alpha)
            safe(function() S.Aimbot_LockColor = color end)
        end
    })

    -- Center: Triggerbot
    local trig = combatPage:Section({ Name = "Triggerbot", Side = "left" })

    trig:Toggle({
        Name = "Enable Trigger",
        Default = S.Trigger_Enabled,
        Pointer = "Trigger_Enabled",
        Callback = function(state)
            safe(function() S.Trigger_Enabled = state end)
        end
    })

    trig:Slider({
        Name = "Delay",
        Default = S.Trigger_Delay,
        Minimum = 0,
        Maximum = 500,
        Decimals = 0,
        Measurement = "ms",
        Pointer = "Trigger_Delay",
        Callback = function(value)
            safe(function() S.Trigger_Delay = value end)
        end
    })

    -- в•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђ
    -- VISUALS TAB
    -- в•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђ
    local visPage = window:Page({ Name = "Visuals" })

    local enemy = visPage:Section({ Name = "Enemies", Side = "left" })
    local team = visPage:Section({ Name = "Teammates", Side = "left" })
    local self = visPage:Section({ Name = "Self", Side = "left" })

    -- в”Ђв”Ђ Enemies в”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђ
    enemy:Toggle({
        Name = "Enable ESP",
        Default = S.ESP_Enabled,
        Pointer = "ESP_Enabled",
        Callback = function(state)
            safe(function()
                S.ESP_Enabled = state
                F["Enabled"] = state
                refresh()
            end)
        end
    })

    enemy:Slider({
        Name = "Max Distance",
        Default = S.ESP_MaxDistance,
        Minimum = 100,
        Maximum = 5000,
        Decimals = 0,
        Measurement = "",
        Pointer = "ESP_MaxDistance",
        Callback = function(value)
            safe(function() S.ESP_MaxDistance = value end)
        end
    })

    enemy:Toggle({
        Name = "Names",
        Default = F["Names"],
        Pointer = "Names",
        Callback = function(state)
            safe(function()
                F["Names"] = state
                refresh()
            end)
        end
    }):Colorpicker({
        Name = "Name Color",
        Default = F["Name_Color"].Color,
        Pointer = "Name_Color",
        Callback = function(color, alpha)
            safe(function()
                F["Name_Color"].Color = color
                refresh()
            end)
        end
    })

    enemy:Toggle({
        Name = "Boxes",
        Default = F["Boxes"],
        Pointer = "Boxes",
        Callback = function(state)
            safe(function()
                F["Boxes"] = state
                refresh()
            end)
        end
    }):Colorpicker({
        Name = "Box Color",
        Default = F["Box_Color"].Color,
        Pointer = "Box_Color",
        Callback = function(color, alpha)
            safe(function()
                F["Box_Color"].Color = color
                refresh()
            end)
        end
    })

    local hpToggle = enemy:Toggle({
        Name = "Healthbar",
        Default = F["Healthbar"],
        Pointer = "Healthbar",
        Callback = function(state)
            safe(function()
                F["Healthbar"] = state
                refresh()
            end)
        end
    })

    hpToggle:Colorpicker({
        Name = "High HP",
        Default = F["Health_High"].Color,
        Pointer = "Health_High",
        Callback = function(color, alpha)
            safe(function()
                F["Health_High"].Color = color
                refresh()
            end)
        end
    })

    hpToggle:Colorpicker({
        Name = "Low HP",
        Default = F["Health_Low"].Color,
        Pointer = "Health_Low",
        Callback = function(color, alpha)
            safe(function()
                F["Health_Low"].Color = color
                refresh()
            end)
        end
    })

    enemy:Toggle({
        Name = "Distance",
        Default = F["Distance"],
        Pointer = "Distance",
        Callback = function(state)
            safe(function()
                F["Distance"] = state
                refresh()
            end)
        end
    }):Colorpicker({
        Name = "Distance Color",
        Default = F["Distance_Color"].Color,
        Pointer = "Distance_Color",
        Callback = function(color, alpha)
            safe(function()
                F["Distance_Color"].Color = color
                refresh()
            end)
        end
    })

    enemy:Toggle({
        Name = "Weapon",
        Default = F["Weapon"],
        Pointer = "Weapon",
        Callback = function(state)
            safe(function()
                F["Weapon"] = state
                refresh()
            end)
        end
    }):Colorpicker({
        Name = "Weapon Color",
        Default = F["Weapon_Color"].Color,
        Pointer = "Weapon_Color",
        Callback = function(color, alpha)
            safe(function()
                F["Weapon_Color"].Color = color
                refresh()
            end)
        end
    })

    safe(function()
        enemy:Dropdown({
            Name = "Box Type",
            Options = { "Corner", "Full" },
            Default = F["Box_Type"],
            Pointer = "Box_Type",
            Callback = function(value)
                safe(function()
                    F["Box_Type"] = value
                    refresh()
                end)
            end
        })
    end)

    -- в”Ђв”Ђ Teammates в”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђ
    team:Toggle({
        Name = "Enable Teammates",
        Default = S.Teammates_Enabled,
        Pointer = "Teammates_Enabled",
        Callback = function(state)
            safe(function()
                S.Teammates_Enabled = state
                refresh()
            end)
        end
    })

    team:Colorpicker({
        Name = "Box Color",
        Default = S.Teammate_Box_Color,
        Pointer = "Teammate_Box_Color",
        Callback = function(color, alpha)
            safe(function()
                S.Teammate_Box_Color = color
                refresh()
            end)
        end
    })

    team:Colorpicker({
        Name = "Name Color",
        Default = S.Teammate_Name_Color,
        Pointer = "Teammate_Name_Color",
        Callback = function(color, alpha)
            safe(function()
                S.Teammate_Name_Color = color
                refresh()
            end)
        end
    })

    team:Colorpicker({
        Name = "Weapon Color",
        Default = S.Teammate_Weapon_Color,
        Pointer = "Teammate_Weapon_Color",
        Callback = function(color, alpha)
            safe(function()
                S.Teammate_Weapon_Color = color
                refresh()
            end)
        end
    })

    team:Colorpicker({
        Name = "HP High",
        Default = S.Teammate_Health_High,
        Pointer = "Teammate_Health_High",
        Callback = function(color, alpha)
            safe(function()
                S.Teammate_Health_High = color
                refresh()
            end)
        end
    })

    team:Colorpicker({
        Name = "HP Low",
        Default = S.Teammate_Health_Low,
        Pointer = "Teammate_Health_Low",
        Callback = function(color, alpha)
            safe(function()
                S.Teammate_Health_Low = color
                refresh()
            end)
        end
    })

    team:Colorpicker({
        Name = "Distance Color",
        Default = S.Teammate_Distance_Color,
        Pointer = "Teammate_Distance_Color",
        Callback = function(color, alpha)
            safe(function()
                S.Teammate_Distance_Color = color
                refresh()
            end)
        end
    })

    -- в”Ђв”Ђ Self в”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђ
    self:Toggle({
        Name = "Enable Self ESP",
        Default = S.SelfESP_Enabled,
        Pointer = "SelfESP_Enabled",
        Callback = function(state)
            safe(function()
                S.SelfESP_Enabled = state
                refresh()
            end)
        end
    })

    self:Colorpicker({
        Name = "Box Color",
        Default = S.Self_Box_Color,
        Pointer = "Self_Box_Color",
        Callback = function(color, alpha)
            safe(function()
                S.Self_Box_Color = color
                refresh()
            end)
        end
    })

    self:Colorpicker({
        Name = "Name Color",
        Default = S.Self_Name_Color,
        Pointer = "Self_Name_Color",
        Callback = function(color, alpha)
            safe(function()
                S.Self_Name_Color = color
                refresh()
            end)
        end
    })

    self:Colorpicker({
        Name = "Weapon Color",
        Default = S.Self_Weapon_Color,
        Pointer = "Self_Weapon_Color",
        Callback = function(color, alpha)
            safe(function()
                S.Self_Weapon_Color = color
                refresh()
            end)
        end
    })

    -- Right side: Self Material
    local mat = visPage:Section({ Name = "Self Material", Side = "right" })

    mat:Toggle({
        Name = "Enable Material",
        Default = S.SelfChams_Enabled,
        Pointer = "SelfChams_Enabled",
        Callback = function(state)
            safe(function()
                S.SelfChams_Enabled = state
                if not state and chams and chams.RestoreSelf then
                    chams:RestoreSelf()
                end
            end)
        end
    })

    safe(function()
        mat:Dropdown({
            Name = "Material",
            Options = { "ForceField", "Neon", "SmoothPlastic", "Plastic", "Glass" },
            Default = S.SelfChams_Material,
            Pointer = "SelfChams_Material",
            Callback = function(value)
                safe(function() S.SelfChams_Material = value end)
            end
        })
    end)

    mat:Colorpicker({
        Name = "Color",
        Default = S.SelfChams_Color,
        Pointer = "SelfChams_Color",
        Callback = function(color, alpha)
            safe(function() S.SelfChams_Color = color end)
        end
    })

    -- Right side: Lighting
    local light = visPage:Section({ Name = "Lighting", Side = "right" })

    light:Toggle({
        Name = "Fullbright",
        Default = S.Fullbright_Enabled,
        Pointer = "Fullbright_Enabled",
        Callback = function(state)
            safe(function() S.Fullbright_Enabled = state end)
        end
    })

    light:Toggle({
        Name = "Ambient",
        Default = S.Ambient_Enabled,
        Pointer = "Ambient_Enabled",
        Callback = function(state)
            safe(function() S.Ambient_Enabled = state end)
        end
    })

    light:Colorpicker({
        Name = "Ambient Color",
        Default = S.Ambient_Color,
        Pointer = "Ambient_Color",
        Callback = function(color, alpha)
            safe(function() S.Ambient_Color = color end)
        end
    })

    -- Right side: Highlights
    local hl = visPage:Section({ Name = "Highlights", Side = "right" })

    hl:Toggle({
        Name = "Enemy Highlights",
        Default = S.Chams_Enabled,
        Pointer = "Chams_Enabled",
        Callback = function(state)
            safe(function()
                S.Chams_Enabled = state
                if not state and chams and chams.RestoreHighlights then
                    chams:RestoreHighlights()
                end
            end)
        end
    })

    hl:Colorpicker({
        Name = "Color",
        Default = S.Chams_Color,
        Pointer = "Chams_Color",
        Callback = function(color, alpha)
            safe(function() S.Chams_Color = color end)
        end
    })

    -- Left: Misc
    local misc = visPage:Section({ Name = "Misc", Side = "left" })

    misc:Toggle({
        Name = "Watermark",
        Default = S.Watermark_Enabled,
        Pointer = "Watermark_Enabled",
        Callback = function(state)
            safe(function() S.Watermark_Enabled = state end)
        end
    })

    misc:Toggle({
        Name = "Tracers",
        Default = S.Tracers_Enabled,
        Pointer = "Tracers_Enabled",
        Callback = function(state)
            safe(function() S.Tracers_Enabled = state end)
        end
    })

    -- в•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђ
    -- SETTINGS TAB
    -- в•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђ
    local setPage = window:Page({ Name = "Settings" })

    local menu = setPage:Section({ Name = "Menu", Side = "left" })

    menu:Keybind({
        Name = "Menu Bind",
        Default = Enum.KeyCode.RightShift,
        Mode = "Toggle",
        KeybindName = "MenuBind",
        Pointer = "MenuBind",
        Callback = function() end
    })

    menu:Colorpicker({
        Name = "Accent",
        Default = Color3.fromRGB(155, 150, 219),
        Pointer = "MenuAccent",
        Callback = function(color, alpha)
            safe(function()
                local oldAccent = Color3.fromRGB(155, 150, 219)
                for _, v in pairs(library.drawings) do
                    local obj = v[1]
                    if obj and obj.__OBJECT_EXISTS then
                        if obj.Color == oldAccent then obj.Color = color end
                    end
                end
            end)
        end
    })

    menu:Button({
        Name = "Unload",
        Callback = function()
            safe(function() window:Unload() end)
            safe(function()
                if deps.Main and deps.Main.Unload then
                    deps.Main.Unload()
                elseif getgenv().PastaUnload then
                    getgenv().PastaUnload()
                end
            end)
        end
    })

    local info = setPage:Section({ Name = "Info", Side = "left" })

    info:Label({
        Name = "PastaSense v1.0",
        Middle = true
    })

    window:Initialize()

    return library
end

return UI
