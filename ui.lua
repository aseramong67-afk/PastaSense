-- ui.lua — Seere UI + привязка модулей PastaSense (полная переработка)

local UI = {}

function UI.Build(deps, library)
    local S = deps.Config.S
    local F = deps.Config.ESPFlags
    local esp = deps.ESP
    local chams = deps.Chams

    -- ── helpers ────────────────────────────────────────────────────
    local syncList = {}

    local function call(fn, ...)
        return pcall(fn, ...)
    end

    local function refresh()
        call(esp.refresh_elements, esp)
    end

    local function safe(group, method, props)
        local ok, obj = call(group[method], group, props)
        return ok and obj or nil
    end

    local function toggle(group, text, flag, set)
        local t = safe(group, "addToggle", { text = text, flag = flag, callback = set })
        if not t then return nil end
        syncList[#syncList + 1] = { flag = flag }
        return t
    end

    local function toggleColor(group, text, flag, set, cFlag, cDefault, cSet)
        local t = toggle(group, text, flag, set)
        if not t then return end
        safe(t, "addColorpicker", { flag = cFlag, color = cDefault, callback = cSet })
    end

    local function slider(group, text, flag, min, max, val, set, suffix)
        safe(group, "addSlider", {
            text = text, flag = flag,
            min = min, max = max, value = val,
            callback = set,
        }, suffix)
    end

    local function color(group, text, flag, col, set)
        safe(group, "addColorpicker", {
            text = text, flag = flag, color = col, callback = set,
        })
    end

    local function list(group, text, flag, values, val, set)
        safe(group, "addList", {
            text = text, flag = flag,
            values = values, value = val, callback = set,
        })
    end

    local function btn(group, text, set)
        safe(group, "addButton", { text = text, callback = set })
    end

    local function bind(group, text, flag, key)
        safe(group, "addKeybind", { text = text, flag = flag, key = key })
    end

    -- ── COMBAT ─────────────────────────────────────────────────────
    local combat = library:addTab("Combat")

    local aim = combat:createGroup("left", "Aimbot")
    toggle(aim, "Enable Aimbot", "Aimbot_Enabled", function(b) S.Aimbot_Enabled = b end)
    toggle(aim, "Wall Check", "Aimbot_WallCheck", function(b) S.Aimbot_WallCheck = b end)
    toggle(aim, "Toggle Mode", "Aimbot_ToggleMode", function(b) S.Aimbot_ToggleMode = b end)
    toggle(aim, "Team Check", "TeamCheck", function(b) S.TeamCheck = b end)
    toggle(aim, "Death Check", "DeathCheck", function(b) S.DeathCheck = b end)
    toggle(aim, "Show FOV", "Show_FOV", function(b) S.Show_FOV = b end)
    list(aim, "Hitbox", "Hitbox", {"Head","Torso","Random"}, S.Hitbox, function(v) S.Hitbox = v end)

    local trig = combat:createGroup("center", "Triggerbot")
    toggle(trig, "Enable Trigger", "Trigger_Enabled", function(b) S.Trigger_Enabled = b end)
    slider(trig, "Delay", "Trigger_Delay", 0, 500, S.Trigger_Delay, function(v) S.Trigger_Delay = v end, "ms")

    local tune = combat:createGroup("right", "Tuning")
    slider(tune, "Smoothing", "Aim_Smoothing", 0, 100, math.floor(S.Aim_Smoothing * 100 + 0.5),
        function(v) S.Aim_Smoothing = v / 100 end, "%")
    slider(tune, "FOV", "Aim_FOV", 10, 800, S.Aim_FOV_Hold,
        function(v) S.Aim_FOV_Hold = v; S.Aim_FOV_Toggle = v end, "")
    slider(tune, "Max Distance", "Aim_MaxDist", 100, 5000, S.Aim_MaxDistance,
        function(v) S.Aim_MaxDistance = v end, "")
    color(tune, "Lock Color", "Aimbot_LockColor", S.Aimbot_LockColor,
        function(c) S.Aimbot_LockColor = c end)

    -- ── VISUALS ────────────────────────────────────────────────────
    local vis = library:addTab("Visuals")

    -- левая: enemies
    local gen = vis:createGroup("left", "General")
    toggle(gen, "Enable ESP", "ESP_Enabled", function(b)
        S.ESP_Enabled = b; F["Enabled"] = b; refresh()
    end)
    slider(gen, "Max Distance", "ESP_MaxDist", 100, 5000, S.ESP_MaxDistance,
        function(v) S.ESP_MaxDistance = v end, "")

    local el = vis:createGroup("left", "Elements")

    toggleColor(el, "Names", "ESP_Names", function(b) F["Names"] = b; refresh() end,
        "ESP_Name_Color", F["Name_Color"].Color, function(c) F["Name_Color"].Color = c; refresh() end)

    toggleColor(el, "Boxes", "ESP_Boxes", function(b) F["Boxes"] = b; refresh() end,
        "ESP_Box_Color", F["Box_Color"].Color, function(c) F["Box_Color"].Color = c; refresh() end)

    local hpToggle = toggle(el, "Healthbar", "ESP_Healthbar", function(b) F["Healthbar"] = b; refresh() end)
    if hpToggle then
        color(hpToggle, "High HP", "ESP_Health_High", F["Health_High"].Color,
            function(c) F["Health_High"].Color = c end)
        color(hpToggle, "Low HP", "ESP_Health_Low", F["Health_Low"].Color,
            function(c) F["Health_Low"].Color = c end)
    end

    toggleColor(el, "Distance", "ESP_Distance", function(b) F["Distance"] = b; refresh() end,
        "ESP_Distance_Color", F["Distance_Color"].Color, function(c) F["Distance_Color"].Color = c; refresh() end)

    toggleColor(el, "Weapon", "ESP_Weapon", function(b) F["Weapon"] = b; refresh() end,
        "ESP_Weapon_Color", F["Weapon_Color"].Color, function(c) F["Weapon_Color"].Color = c; refresh() end)

    -- центр: style + teammates + misc
    local style = vis:createGroup("center", "Style")
    list(style, "Box Type", "ESP_Box_Type", {"Corner","Full"}, F["Box_Type"],
        function(v) F["Box_Type"] = v; refresh() end)

    local tm = vis:createGroup("center", "Teammates")
    toggle(tm, "Enable Teammates", "Teammates_Enabled", function(b) S.Teammates_Enabled = b; refresh() end)

    local tmC = vis:createGroup("center", "Team Colors")
    color(tmC, "Box", "Tm_Box", S.Teammate_Box_Color, function(c) S.Teammate_Box_Color = c; refresh() end)
    color(tmC, "Name", "Tm_Name", S.Teammate_Name_Color, function(c) S.Teammate_Name_Color = c; refresh() end)
    color(tmC, "Weapon", "Tm_Weapon", S.Teammate_Weapon_Color, function(c) S.Teammate_Weapon_Color = c; refresh() end)
    color(tmC, "HP High", "Tm_High", S.Teammate_Health_High, function(c) S.Teammate_Health_High = c end)
    color(tmC, "HP Low", "Tm_Low", S.Teammate_Health_Low, function(c) S.Teammate_Health_Low = c end)
    color(tmC, "Distance", "Tm_Dist", S.Teammate_Distance_Color, function(c) S.Teammate_Distance_Color = c; refresh() end)

    local miscV = vis:createGroup("center", "Misc")
    toggle(miscV, "Watermark", "Watermark_Enabled", function(b) S.Watermark_Enabled = b end)
    toggle(miscV, "Tracers", "Tracers_Enabled", function(b) S.Tracers_Enabled = b end)

    -- правая: self + world
    local self = vis:createGroup("right", "Self")
    toggle(self, "Enable Self ESP", "SelfESP_Enabled", function(b) S.SelfESP_Enabled = b; refresh() end)
    color(self, "Box", "Self_Box", S.Self_Box_Color, function(c) S.Self_Box_Color = c; refresh() end)
    color(self, "Name", "Self_Name", S.Self_Name_Color, function(c) S.Self_Name_Color = c; refresh() end)
    color(self, "Weapon", "Self_Weapon", S.Self_Weapon_Color, function(c) S.Self_Weapon_Color = c; refresh() end)

    local mat = vis:createGroup("right", "Self Material")
    toggle(mat, "Enable Material", "SelfChams_Enabled", function(b)
        S.SelfChams_Enabled = b
        if not b then call(chams.RestoreSelf, chams) end
    end)
    list(mat, "Material", "SelfChams_Material",
        {"ForceField","Neon","SmoothPlastic","Plastic","Glass"}, S.SelfChams_Material,
        function(v) S.SelfChams_Material = v end)
    color(mat, "Color", "SelfChams_Color", S.SelfChams_Color,
        function(c) S.SelfChams_Color = c end)

    local light = vis:createGroup("right", "Lighting")
    toggle(light, "Fullbright", "Fullbright_Enabled", function(b) S.Fullbright_Enabled = b end)
    toggle(light, "Ambient", "Ambient_Enabled", function(b) S.Ambient_Enabled = b end)
    color(light, "Ambient Color", "Ambient_Color", S.Ambient_Color,
        function(c) S.Ambient_Color = c end)

    local chamsG = vis:createGroup("right", "Highlights")
    toggle(chamsG, "Enemy Highlights", "Chams_Enabled", function(b)
        S.Chams_Enabled = b
        if not b then call(chams.RestoreHighlights, chams) end
    end)
    color(chamsG, "Color", "Chams_Color", S.Chams_Color,
        function(c) S.Chams_Color = c end)

    -- ── SETTINGS ───────────────────────────────────────────────────
    local set = library:addTab("Settings")
    local menu = set:createGroup("left", "Menu")
    bind(menu, "Menu Bind", "MenuBind", Enum.KeyCode.RightShift)
    color(menu, "Accent", "MenuAccent", Color3.fromRGB(155, 150, 219), function(c)
        call(function()
            local old = library.libColor
            library.libColor = c
            if library.gui then
                for _, ins in ipairs(library.gui:GetDescendants()) do
                    if ins:IsA("GuiObject") and ins.BackgroundColor3 == old then
                        ins.BackgroundColor3 = c
                    end
                end
            end
        end)
    end)
    btn(menu, "Unload", function()
        call(function()
            if deps.Main and deps.Main.Unload then deps.Main.Unload()
            elseif getgenv().PastaUnload then getgenv().PastaUnload() end
        end)
        call(function()
            game:GetService("UserInputService").MouseBehavior =
                getgenv().PastaMouseBehavior or Enum.MouseBehavior.LockCenter
        end)
        call(function() if library.gui then library.gui:Destroy() end end)
    end)

    -- ── sync + init ────────────────────────────────────────────────
    for _, entry in ipairs(syncList) do
        call(function()
            local opt = library.options[entry.flag]
            if opt and opt.changeState then opt.changeState(false) end
        end)
    end

    pcall(function()
        if library.tabs and library.tabs[1] then
            for i, t in ipairs(library.tabs) do t.Visible = (i == 1) end
        end
    end)

    -- курсор: save/restore
    pcall(function()
        local uis = game:GetService("UserInputService")
        local gui = library.gui
        if not gui then return end
        getgenv().PastaMouseBehavior = uis.MouseBehavior
        local function apply()
            pcall(function()
                uis.MouseBehavior = gui.Enabled
                    and Enum.MouseBehavior.Default
                    or getgenv().PastaMouseBehavior
            end)
        end
        gui:GetPropertyChangedSignal("Enabled"):Connect(apply)
        apply()
    end)

    return library
end

return UI
