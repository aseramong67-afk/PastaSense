-- ui.lua — Seere UI + привязка модулей PastaSense
-- API: library:addTab(name) -> tab
--      tab:createGroup("left"|"center"|"right", name) -> group
--      group:addToggle({text, flag, callback}) -> toggle
--      toggle:addColorpicker({text?, flag, color?, callback?})
--      group:addSlider({text, flag, min, max, value, callback}, suffix) -- только целые числа!
--      group:addList({text, flag, values, value, callback})
--      group:addButton({text, callback})
--      group:addColorpicker({text, flag, color, callback})

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

    -- seere тоглы всегда стартуют ВЫКЛ — после построения синкаем из S
    local togglesToSync = {}
    local function tg(group, text, flag, get, set)
        group:addToggle({ text = text, flag = flag, callback = set })
        togglesToSync[#togglesToSync + 1] = { flag, get }
    end

    -- ============ AIMBOT ============
    local aimTab = library:addTab("Aimbot")
    local gAim = aimTab:createGroup("left", "Aimbot")
    tg(gAim, "Enable Aimbot", "Aimbot_Enabled", function() return S.Aimbot_Enabled end, function(b) S.Aimbot_Enabled = b end)
    tg(gAim, "Wall Check", "Aimbot_WallCheck", function() return S.Aimbot_WallCheck end, function(b) S.Aimbot_WallCheck = b end)
    tg(gAim, "Toggle Mode", "Aimbot_ToggleMode", function() return S.Aimbot_ToggleMode end, function(b) S.Aimbot_ToggleMode = b end)
    tg(gAim, "Team Check", "TeamCheck", function() return S.TeamCheck end, function(b) S.TeamCheck = b end)
    tg(gAim, "Death Check", "DeathCheck", function() return S.DeathCheck end, function(b) S.DeathCheck = b end)
    tg(gAim, "Show FOV", "Show_FOV", function() return S.Show_FOV end, function(b) S.Show_FOV = b end)
    gAim:addList({
        text = "Hitbox", flag = "Hitbox",
        values = { "Head", "Torso", "Random" }, value = S.Hitbox,
        callback = function(v) S.Hitbox = v end,
    })

    local gTune = aimTab:createGroup("right", "Tuning")
    gTune:addSlider({
        text = "Smoothing", flag = "Aim_Smoothing", min = 0, max = 100,
        value = math.floor(S.Aim_Smoothing * 100 + 0.5),
        callback = function(v) S.Aim_Smoothing = v / 100 end,
    }, "%")
    gTune:addSlider({
        text = "FOV", flag = "Aim_FOV", min = 10, max = 800, value = S.Aim_FOV_Hold,
        callback = function(v) S.Aim_FOV_Hold = v; S.Aim_FOV_Toggle = v end,
    }, "")
    gTune:addSlider({
        text = "Max Distance", flag = "Aim_MaxDist", min = 100, max = 5000, value = S.Aim_MaxDistance,
        callback = function(v) S.Aim_MaxDistance = v end,
    }, "")
    gTune:addColorpicker({
        text = "Lock Color", flag = "Aimbot_LockColor", color = S.Aimbot_LockColor,
        callback = function(c) S.Aimbot_LockColor = c end,
    })

    -- ============ TRIGGER ============
    local trigTab = library:addTab("Trigger")
    local gTrig = trigTab:createGroup("left", "Triggerbot")
    tg(gTrig, "Enable Trigger", "Trigger_Enabled", function() return S.Trigger_Enabled end, function(b) S.Trigger_Enabled = b end)
    gTrig:addSlider({
        text = "Delay", flag = "Trigger_Delay", min = 0, max = 500, value = S.Trigger_Delay,
        callback = function(v) S.Trigger_Delay = v end,
    }, "ms")

    -- ============ ENEMIES ============
    local espTab = library:addTab("Enemies")
    local gGen = espTab:createGroup("left", "General")
    tg(gGen, "Enable ESP", "ESP_Enabled", function() return S.ESP_Enabled end, function(b) S.ESP_Enabled = b; ESPFlags["Enabled"] = b; refresh() end)
    gGen:addSlider({
        text = "Max Distance", flag = "ESP_MaxDist", min = 100, max = 5000, value = S.ESP_MaxDistance,
        callback = function(v) S.ESP_MaxDistance = v end,
    }, "")

    local gEl = espTab:createGroup("left", "Elements")
    local tNames = gEl:addToggle({ text = "Names", flag = "ESP_Names", callback = function(b) ESPFlags["Names"] = b; refresh() end })
    togglesToSync[#togglesToSync + 1] = { "ESP_Names", function() return ESPFlags["Names"] end }
    tNames:addColorpicker({ flag = "ESP_Name_Color", color = ESPFlags["Name_Color"].Color,
        callback = function(c) ESPFlags["Name_Color"].Color = c; refresh() end })

    local tBoxes = gEl:addToggle({ text = "Boxes", flag = "ESP_Boxes", callback = function(b) ESPFlags["Boxes"] = b; refresh() end })
    togglesToSync[#togglesToSync + 1] = { "ESP_Boxes", function() return ESPFlags["Boxes"] end }
    tBoxes:addColorpicker({ flag = "ESP_Box_Color", color = ESPFlags["Box_Color"].Color,
        callback = function(c) ESPFlags["Box_Color"].Color = c; refresh() end })

    local tHP = gEl:addToggle({ text = "Healthbar", flag = "ESP_Healthbar", callback = function(b) ESPFlags["Healthbar"] = b; refresh() end })
    togglesToSync[#togglesToSync + 1] = { "ESP_Healthbar", function() return ESPFlags["Healthbar"] end }
    tHP:addColorpicker({ text = "High HP", flag = "ESP_Health_High", color = ESPFlags["Health_High"].Color,
        callback = function(c) ESPFlags["Health_High"].Color = c end })
    tHP:addColorpicker({ text = "Low HP", flag = "ESP_Health_Low", color = ESPFlags["Health_Low"].Color, second = true,
        callback = function(c) ESPFlags["Health_Low"].Color = c end })

    local tDist = gEl:addToggle({ text = "Distance", flag = "ESP_Distance", callback = function(b) ESPFlags["Distance"] = b; refresh() end })
    togglesToSync[#togglesToSync + 1] = { "ESP_Distance", function() return ESPFlags["Distance"] end }
    tDist:addColorpicker({ flag = "ESP_Distance_Color", color = ESPFlags["Distance_Color"].Color,
        callback = function(c) ESPFlags["Distance_Color"].Color = c; refresh() end })

    local tWpn = gEl:addToggle({ text = "Weapon", flag = "ESP_Weapon", callback = function(b) ESPFlags["Weapon"] = b; refresh() end })
    togglesToSync[#togglesToSync + 1] = { "ESP_Weapon", function() return ESPFlags["Weapon"] end }
    tWpn:addColorpicker({ flag = "ESP_Weapon_Color", color = ESPFlags["Weapon_Color"].Color,
        callback = function(c) ESPFlags["Weapon_Color"].Color = c; refresh() end })

    local gStyle = espTab:createGroup("right", "Style")
    gStyle:addList({
        text = "Box Type", flag = "ESP_Box_Type",
        values = { "Corner", "Full" }, value = ESPFlags["Box_Type"],
        callback = function(v) ESPFlags["Box_Type"] = v; refresh() end,
    })

    -- ============ TEAMMATES ============
    local tmTab = library:addTab("Teammates")
    local gTm = tmTab:createGroup("left", "Teammates")
    tg(gTm, "Enable Teammates ESP", "Teammates_Enabled", function() return S.Teammates_Enabled end, function(b) S.Teammates_Enabled = b; refresh() end)

    local gTmC = tmTab:createGroup("right", "Colors")
    gTmC:addColorpicker({ text = "Box Color", flag = "Tm_Box", color = S.Teammate_Box_Color,
        callback = function(c) S.Teammate_Box_Color = c; refresh() end })
    gTmC:addColorpicker({ text = "Name Color", flag = "Tm_Name", color = S.Teammate_Name_Color,
        callback = function(c) S.Teammate_Name_Color = c; refresh() end })
    gTmC:addColorpicker({ text = "Weapon Color", flag = "Tm_Weapon", color = S.Teammate_Weapon_Color,
        callback = function(c) S.Teammate_Weapon_Color = c; refresh() end })
    gTmC:addColorpicker({ text = "Health High", flag = "Tm_High", color = S.Teammate_Health_High,
        callback = function(c) S.Teammate_Health_High = c end })
    gTmC:addColorpicker({ text = "Health Low", flag = "Tm_Low", color = S.Teammate_Health_Low,
        callback = function(c) S.Teammate_Health_Low = c end })
    gTmC:addColorpicker({ text = "Distance Color", flag = "Tm_Dist", color = S.Teammate_Distance_Color,
        callback = function(c) S.Teammate_Distance_Color = c; refresh() end })

    -- ============ SELF ============
    local selfTab = library:addTab("Self")
    local gSelf = selfTab:createGroup("left", "Self ESP")
    tg(gSelf, "Enable Self ESP", "SelfESP_Enabled", function() return S.SelfESP_Enabled end, function(b) S.SelfESP_Enabled = b; refresh() end)
    gSelf:addColorpicker({ text = "Box Color", flag = "Self_Box", color = S.Self_Box_Color,
        callback = function(c) S.Self_Box_Color = c; refresh() end })
    gSelf:addColorpicker({ text = "Name Color", flag = "Self_Name", color = S.Self_Name_Color,
        callback = function(c) S.Self_Name_Color = c; refresh() end })
    gSelf:addColorpicker({ text = "Weapon Color", flag = "Self_Weapon", color = S.Self_Weapon_Color,
        callback = function(c) S.Self_Weapon_Color = c; refresh() end })

    local gMat = selfTab:createGroup("right", "Self Material")
    tg(gMat, "Enable Self Material", "SelfChams_Enabled", function() return S.SelfChams_Enabled end, function(b)
        S.SelfChams_Enabled = b
        if not b then pcall(function() deps.Chams.RestoreSelf() end) end
    end)
    gMat:addList({
        text = "Material", flag = "SelfChams_Material",
        values = { "ForceField", "Neon", "SmoothPlastic", "Plastic", "Glass" }, value = S.SelfChams_Material,
        callback = function(v) S.SelfChams_Material = v end,
    })
    gMat:addColorpicker({ text = "Color", flag = "SelfChams_Color", color = S.SelfChams_Color,
        callback = function(c) S.SelfChams_Color = c end })

    -- ============ WORLD ============
    local worldTab = library:addTab("World")
    local gLight = worldTab:createGroup("left", "Lighting")
    tg(gLight, "Fullbright", "Fullbright_Enabled", function() return S.Fullbright_Enabled end, function(b) S.Fullbright_Enabled = b end)
    tg(gLight, "Ambient", "Ambient_Enabled", function() return S.Ambient_Enabled end, function(b) S.Ambient_Enabled = b end)
    gLight:addColorpicker({ text = "Ambient Color", flag = "Ambient_Color", color = S.Ambient_Color,
        callback = function(c) S.Ambient_Color = c end })

    local gChams = worldTab:createGroup("right", "Highlights")
    tg(gChams, "Enemy Highlights", "Chams_Enabled", function() return S.Chams_Enabled end, function(b)
        S.Chams_Enabled = b
        if not b then pcall(function() deps.Chams.RestoreHighlights() end) end
    end)
    gChams:addColorpicker({ text = "Highlight Color", flag = "Chams_Color", color = S.Chams_Color,
        callback = function(c) S.Chams_Color = c end })

    -- ============ MISC ============
    local miscTab = library:addTab("Misc")
    local gMisc = miscTab:createGroup("left", "Misc")
    tg(gMisc, "Watermark", "Watermark_Enabled", function() return S.Watermark_Enabled end, function(b) S.Watermark_Enabled = b end)
    tg(gMisc, "Tracers", "Tracers_Enabled", function() return S.Tracers_Enabled end, function(b) S.Tracers_Enabled = b end)
    gMisc:addButton({ text = "Unload", callback = function()
        pcall(function()
            if deps.Main and deps.Main.Unload then deps.Main.Unload()
            elseif getgenv().PastaUnload then getgenv().PastaUnload() end
        end)
        pcall(function() if library.gui then library.gui:Destroy() end end)
    end })

    -- синк тоглов из конфига (seere стартует все ВЫКЛ)
    for _, pair in ipairs(togglesToSync) do
        pcall(function()
            local opt = library.options[pair[1]]
            if opt and opt.changeState then opt.changeState(pair[2]() == true) end
        end)
    end

    -- открыть первую вкладку
    pcall(function()
        if library.tabs and library.tabs[1] then
            for i, t in ipairs(library.tabs) do t.Visible = (i == 1) end
        end
    end)

    -- курсор: пока меню открыто — свободный (Default), закрыли — вернуть захват (LockCenter),
    -- иначе камера после закрытия вертится только с зажатой ПКМ
    pcall(function()
        local uis = game:GetService("UserInputService")
        local gui = library.gui
        if gui then
            local function apply()
                pcall(function()
                    if gui.Enabled then
                        uis.MouseBehavior = Enum.MouseBehavior.Default
                    else
                        uis.MouseBehavior = Enum.MouseBehavior.LockCenter
                    end
                end)
            end
            gui:GetPropertyChangedSignal("Enabled"):Connect(apply)
            apply()
        end
    end)

    return library
end

return UI
