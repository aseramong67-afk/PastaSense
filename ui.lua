-- ui.lua — Millenium UI + привязка модулей PastaSense
-- Использование:
--   local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/i77lhm/Libraries/refs/heads/main/Millenium/Library.lua"))()
--   local Config = loadstring(game:HttpGet(... .. "modules/config.lua"))() -- или require
--   ... собери deps (Services, Aimbot, ESP, Effects, Chams, Main) ...
--   local UI = loadstring(game:HttpGet(... .. "ui.lua"))()
--   local window = UI.Build(deps, library)

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

    -- MilleniumDropdown не ставит заголовок (в библиотеке захардкожен текст "Dropdown") — правим вручную
    local function dropdown(section, props)
        local dd = section:dropdown(props)
        if props.name then
            pcall(function() dd.items["name"].Text = props.name end)
        end
        return dd
    end

    local window = library:window({
        name = "pasta",
        suffix = "sense",
        gameInfo = "PastaSense | universal",
    })

    -- ============ COMBAT ============
    window:seperator({ name = "Combat" })

    local aimPage, triggerPage = window:tab({ name = "Aimbot", tabs = { "Aimbot", "Trigger" } })

    -- Aimbot page
    do
        local leftCol = aimPage:column({})
        local rightCol = aimPage:column({})
        local section = leftCol:section({ name = "Aimbot", default = true, size = 0.6 })

        section:toggle({
            name = "Enable Aimbot",
            default = S.Aimbot_Enabled,
            seperator = true,
            type = "toggle",
            callback = function(bool) S.Aimbot_Enabled = bool end,
        })
        section:toggle({
            name = "Wall Check",
            default = S.Aimbot_WallCheck,
            seperator = true,
            type = "toggle",
            callback = function(bool) S.Aimbot_WallCheck = bool end,
        })
        section:toggle({
            name = "Toggle Mode",
            info = "OFF = hold RMB, ON = FOV Toggle",
            default = S.Aimbot_ToggleMode,
            seperator = true,
            type = "toggle",
            callback = function(bool) S.Aimbot_ToggleMode = bool end,
        })
        section:toggle({
            name = "Team Check",
            default = S.TeamCheck,
            seperator = true,
            type = "toggle",
            callback = function(bool) S.TeamCheck = bool end,
        })
        section:toggle({
            name = "Death Check",
            default = S.DeathCheck,
            seperator = true,
            type = "toggle",
            callback = function(bool) S.DeathCheck = bool end,
        })
        section:toggle({
            name = "Show FOV",
            default = S.Show_FOV,
            seperator = true,
            type = "toggle",
            callback = function(bool) S.Show_FOV = bool end,
        })

        local _ = dropdown(section, {
            name = "Hitbox",
            items = { "Head", "Torso", "Random" },
            default = S.Hitbox,
            seperator = true,
            callback = function(v) S.Hitbox = v end,
        })

        local tuning = rightCol:section({ name = "Tuning", default = true, size = 0.6 })

        tuning:slider({
            name = "Smoothing",
            min = 0, max = 1, interval = 0.01,
            default = S.Aim_Smoothing,
            seperator = true,
            callback = function(v) S.Aim_Smoothing = v end,
        })
        tuning:slider({
            name = "FOV",
            min = 10, max = 800, interval = 1,
            default = S.Aim_FOV_Hold,
            seperator = true,
            callback = function(v) S.Aim_FOV_Hold = v; S.Aim_FOV_Toggle = v end,
        })
        tuning:slider({
            name = "Max Distance",
            min = 100, max = 5000, interval = 10,
            default = S.Aim_MaxDistance,
            seperator = true,
            callback = function(v) S.Aim_MaxDistance = v end,
        })

        tuning:colorpicker({
            name = "Lock Color",
            color = S.Aimbot_LockColor,
            seperator = false,
            callback = function(color) S.Aimbot_LockColor = color end,
        })
    end

    -- Trigger page
    do
        local column = triggerPage:column({})
        local section = column:section({ name = "Triggerbot", default = true, size = 0.25 })

        section:toggle({
            name = "Enable Trigger",
            default = S.Trigger_Enabled,
            seperator = true,
            type = "toggle",
            callback = function(bool) S.Trigger_Enabled = bool end,
        })
        section:slider({
            name = "Delay (ms)",
            min = 0, max = 500, interval = 1,
            default = S.Trigger_Delay,
            seperator = false,
            callback = function(v) S.Trigger_Delay = v end,
        })
    end

    -- ============ VISUALS ============
    window:seperator({ name = "Visuals" })

    local enemies, teammates, selfTab = window:tab({ name = "Players", tabs = { "Enemies", "Teammates", "Self" } })

    -- Enemies (S.ESP_* + ESPFlags)
    do
        local leftCol = enemies:column({})
        local rightCol = enemies:column({})
        local general = leftCol:section({ name = "General", default = true, size = 0.3 })
        general:toggle({
            name = "Enable ESP",
            default = S.ESP_Enabled,
            seperator = true,
            type = "toggle",
            callback = function(bool) S.ESP_Enabled = bool; ESPFlags["Enabled"] = bool; refresh() end,
        })
        general:slider({
            name = "Max Distance",
            min = 100, max = 5000, interval = 10,
            default = S.ESP_MaxDistance,
            seperator = false,
            callback = function(v) S.ESP_MaxDistance = v end,
        })

        local elements = leftCol:section({ name = "Elements", default = true, size = 0.7 })

        -- Names + submenu (DisplayName / UserName)
        local nameToggle = elements:toggle({
            name = "Name",
            default = ESPFlags["Names"],
            seperator = true,
            type = "toggle",
            callback = function(bool) ESPFlags["Names"] = bool; refresh() end,
        })
        nameToggle:colorpicker({
            color = ESPFlags["Name_Color"].Color,
            callback = function(color) ESPFlags["Name_Color"].Color = color; refresh() end,
        })
        local nameSettings = nameToggle:settings({})
        nameSettings:toggle({
            name = "Show Display Names",
            default = ESPFlags["Name_DisplayName"],
            seperator = true,
            type = "toggle",
            callback = function(bool) ESPFlags["Name_DisplayName"] = bool; refresh() end,
        })
        nameSettings:toggle({
            name = "Show Usernames",
            default = ESPFlags["Name_UserName"],
            seperator = false,
            type = "toggle",
            callback = function(bool) ESPFlags["Name_UserName"] = bool; refresh() end,
        })

        -- Boxes + type
        local boxToggle = elements:toggle({
            name = "Boxes",
            default = ESPFlags["Boxes"],
            seperator = true,
            type = "toggle",
            callback = function(bool) ESPFlags["Boxes"] = bool; refresh() end,
        })
        boxToggle:colorpicker({
            color = ESPFlags["Box_Color"].Color,
            callback = function(color) ESPFlags["Box_Color"].Color = color; refresh() end,
        })
        dropdown(elements, {
            name = "Box Type",
            items = { "Corner", "Full" },
            default = ESPFlags["Box_Type"],
            seperator = true,
            callback = function(v) ESPFlags["Box_Type"] = v; refresh() end,
        })

        elements:toggle({
            name = "Healthbar",
            default = ESPFlags["Healthbar"],
            seperator = true,
            type = "toggle",
            callback = function(bool) ESPFlags["Healthbar"] = bool; refresh() end,
        })
        elements:toggle({
            name = "Distance",
            default = ESPFlags["Distance"],
            seperator = true,
            type = "toggle",
            callback = function(bool) ESPFlags["Distance"] = bool; refresh() end,
        })
        elements:toggle({
            name = "Weapon",
            default = ESPFlags["Weapon"],
            seperator = true,
            type = "toggle",
            callback = function(bool) ESPFlags["Weapon"] = bool; refresh() end,
        })

        local colors = rightCol:section({ name = "Colors", default = true, size = 0.45 })
        colors:colorpicker({
            name = "Health High",
            color = ESPFlags["Health_High"].Color,
            seperator = true,
            callback = function(color) ESPFlags["Health_High"].Color = color end,
        })
        colors:colorpicker({
            name = "Health Low",
            color = ESPFlags["Health_Low"].Color,
            seperator = true,
            callback = function(color) ESPFlags["Health_Low"].Color = color end,
        })
        colors:colorpicker({
            name = "Distance Color",
            color = ESPFlags["Distance_Color"].Color,
            seperator = true,
            callback = function(color) ESPFlags["Distance_Color"].Color = color; refresh() end,
        })
        colors:colorpicker({
            name = "Weapon Color",
            color = ESPFlags["Weapon_Color"].Color,
            seperator = false,
            callback = function(color) ESPFlags["Weapon_Color"].Color = color; refresh() end,
        })
    end

    -- Teammates (S.Teammate_*)
    do
        local leftCol = teammates:column({})
        local rightCol = teammates:column({})
        local section = leftCol:section({ name = "Teammates", default = true, size = 0.5 })
        section:toggle({
            name = "Enable Teammates ESP",
            default = S.Teammates_Enabled,
            seperator = true,
            type = "toggle",
            callback = function(bool) S.Teammates_Enabled = bool; refresh() end,
        })
        section:colorpicker({
            name = "Box Color",
            color = S.Teammate_Box_Color,
            seperator = true,
            callback = function(color) S.Teammate_Box_Color = color; refresh() end,
        })
        section:colorpicker({
            name = "Name Color",
            color = S.Teammate_Name_Color,
            seperator = true,
            callback = function(color) S.Teammate_Name_Color = color; refresh() end,
        })
        section:colorpicker({
            name = "Weapon Color",
            color = S.Teammate_Weapon_Color,
            seperator = false,
            callback = function(color) S.Teammate_Weapon_Color = color; refresh() end,
        })

        local colors2 = rightCol:section({ name = "Health Colors", default = true, size = 0.5 })
        colors2:colorpicker({
            name = "Health High",
            color = S.Teammate_Health_High,
            seperator = true,
            callback = function(color) S.Teammate_Health_High = color end,
        })
        colors2:colorpicker({
            name = "Health Low",
            color = S.Teammate_Health_Low,
            seperator = true,
            callback = function(color) S.Teammate_Health_Low = color end,
        })
        colors2:colorpicker({
            name = "Distance Color",
            color = S.Teammate_Distance_Color,
            seperator = false,
            callback = function(color) S.Teammate_Distance_Color = color; refresh() end,
        })
    end

    -- Self (S.Self_*)
    do
        local leftCol = selfTab:column({})
        local rightCol = selfTab:column({})
        local section = leftCol:section({ name = "Self", default = true, size = 0.5 })
        section:toggle({
            name = "Enable Self ESP",
            default = S.SelfESP_Enabled,
            seperator = true,
            type = "toggle",
            callback = function(bool) S.SelfESP_Enabled = bool; refresh() end,
        })
        section:colorpicker({
            name = "Box Color",
            color = S.Self_Box_Color,
            seperator = true,
            callback = function(color) S.Self_Box_Color = color; refresh() end,
        })
        section:colorpicker({
            name = "Name Color",
            color = S.Self_Name_Color,
            seperator = true,
            callback = function(color) S.Self_Name_Color = color; refresh() end,
        })
        section:colorpicker({
            name = "Weapon Color",
            color = S.Self_Weapon_Color,
            seperator = false,
            callback = function(color) S.Self_Weapon_Color = color; refresh() end,
        })

        local colors3 = rightCol:section({ name = "Health Colors", default = true, size = 0.5 })
        colors3:colorpicker({
            name = "Health High",
            color = S.Self_Health_High,
            seperator = true,
            callback = function(color) S.Self_Health_High = color end,
        })
        colors3:colorpicker({
            name = "Health Low",
            color = S.Self_Health_Low,
            seperator = true,
            callback = function(color) S.Self_Health_Low = color end,
        })
        colors3:colorpicker({
            name = "Distance Color",
            color = S.Self_Distance_Color,
            seperator = false,
            callback = function(color) S.Self_Distance_Color = color; refresh() end,
        })
    end

    -- ============ WORLD ============
    window:seperator({ name = "World" })

    local lightingPage, chamsPage, miscPage = window:tab({ name = "World", tabs = { "Lighting", "Chams", "Misc" } })

    do
        local leftCol = lightingPage:column({})
        local rightCol = lightingPage:column({})
        local section = leftCol:section({ name = "Lighting", default = true, size = 0.5 })
        section:toggle({
            name = "Fullbright",
            default = S.Fullbright_Enabled,
            seperator = true,
            type = "toggle",
            callback = function(bool) S.Fullbright_Enabled = bool end,
        })
        section:toggle({
            name = "Ambient",
            default = S.Ambient_Enabled,
            seperator = true,
            type = "toggle",
            callback = function(bool) S.Ambient_Enabled = bool end,
        })

        local colors4 = rightCol:section({ name = "Colors", default = true, size = 0.5 })
        colors4:colorpicker({
            name = "Ambient Color",
            color = S.Ambient_Color,
            seperator = false,
            callback = function(color) S.Ambient_Color = color end,
        })
    end

    do
        local leftCol = chamsPage:column({})
        local rightCol = chamsPage:column({})
        local section = leftCol:section({ name = "Enemy Chams", default = true, size = 0.5 })
        section:toggle({
            name = "Enable Chams",
            default = S.Chams_Enabled,
            seperator = true,
            type = "toggle",
            callback = function(bool) S.Chams_Enabled = bool end,
        })
        dropdown(section, {
            name = "Material",
            items = { "ForceField", "Neon", "SmoothPlastic", "Plastic", "Glass" },
            default = S.Chams_Material,
            seperator = true,
            callback = function(v) S.Chams_Material = v end,
        })
        section:colorpicker({
            name = "Chams Color",
            color = S.Chams_Color,
            seperator = false,
            callback = function(color) S.Chams_Color = color end,
        })

        local selfChams = rightCol:section({ name = "Self Chams", default = true, size = 0.5 })
        selfChams:toggle({
            name = "Self Chams",
            default = S.SelfChams_Enabled,
            seperator = true,
            type = "toggle",
            callback = function(bool) S.SelfChams_Enabled = bool end,
        })
        dropdown(selfChams, {
            name = "Material",
            items = { "ForceField", "Neon", "SmoothPlastic", "Plastic", "Glass" },
            default = S.SelfChams_Material,
            seperator = true,
            callback = function(v) S.SelfChams_Material = v end,
        })
        selfChams:colorpicker({
            name = "Self Color",
            color = S.SelfChams_Color,
            seperator = false,
            callback = function(color) S.SelfChams_Color = color end,
        })
    end

    do
        local column = miscPage:column({})
        local section = column:section({ name = "Misc", default = true, size = 0.35 })
        section:toggle({
            name = "Watermark",
            default = S.Watermark_Enabled,
            seperator = true,
            type = "toggle",
            callback = function(bool) S.Watermark_Enabled = bool end,
        })
        section:toggle({
            name = "Tracers",
            default = S.Tracers_Enabled,
            seperator = true,
            type = "toggle",
            callback = function(bool) S.Tracers_Enabled = bool end,
        })
        section:button({
            name = "Unload",
            callback = function()
                pcall(function()
                    if deps.Main and deps.Main.Unload then
                        deps.Main.Unload()
                    elseif getgenv().PastaUnload then
                        getgenv().PastaUnload()
                    end
                end)
                pcall(function() library:unload_menu() end)
            end,
        })
    end

    library:init_config(window)

    return window
end

return UI
