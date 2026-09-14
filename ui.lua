-- ui.lua вЂ” Splix UI + PastaSense module binding

local UI = {}

function UI.Build(deps, library)
    local S = deps.Config.S
    local F = deps.Config.ESPFlags
    local esp = deps.ESP
    local chams = deps.Chams

    local function safe(...)
        local ok, err = pcall(...)
        if not ok then warn("[PastaSense] " .. tostring(err)) end
        return ok
    end

    local function refresh()
        safe(esp.refresh_elements, esp)
    end

    local window = library:New({ Name = "PastaSense", Accent = Color3.fromRGB(155, 150, 219) })
    if not window then warn("[PastaSense] window is nil") return library end

    local function sec(page, name, side)
        local ok, s = pcall(function() return page:Section({ Name = name, Side = side }) end)
        if not ok or not s then warn("[PastaSense] Section '" .. name .. "' failed: " .. tostring(s)) end
        return s
    end

    -- в•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђ
    -- COMBAT
    -- в•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђ
    local cPage = window:Page({ Name = "Combat" })

    local aim = sec(cPage, "Aimbot", "left")
    if aim then
        pcall(function() aim:Toggle({Name="Enable Aimbot", Default=S.Aimbot_Enabled, Pointer="Aimbot_Enabled", Callback=function(v) S.Aimbot_Enabled=v end}) end)
        pcall(function() aim:Toggle({Name="Wall Check", Default=S.Aimbot_WallCheck, Pointer="Aimbot_WallCheck", Callback=function(v) S.Aimbot_WallCheck=v end}) end)
        pcall(function() aim:Toggle({Name="Toggle Mode", Default=S.Aimbot_ToggleMode, Pointer="Aimbot_ToggleMode", Callback=function(v) S.Aimbot_ToggleMode=v end}) end)
        pcall(function() aim:Toggle({Name="Team Check", Default=S.TeamCheck, Pointer="TeamCheck", Callback=function(v) S.TeamCheck=v end}) end)
        pcall(function() aim:Toggle({Name="Death Check", Default=S.DeathCheck, Pointer="DeathCheck", Callback=function(v) S.DeathCheck=v end}) end)
        pcall(function() aim:Toggle({Name="Show FOV", Default=S.Show_FOV, Pointer="Show_FOV", Callback=function(v) S.Show_FOV=v end}) end)
        pcall(function() aim:Dropdown({Name="Hitbox", Options={"Head","Torso","Random"}, Default=S.Hitbox, Pointer="Hitbox", Callback=function(v) S.Hitbox=v end}) end)
    end

    local tune = sec(cPage, "Tuning", "right")
    if tune then
        pcall(function() tune:Slider({Name="Smoothing", Default=math.floor(S.Aim_Smoothing*100+0.5), Minimum=0, Maximum=100, Decimals=1, Measurement="%", Pointer="Aim_Smoothing", Callback=function(v) S.Aim_Smoothing=v/100 end}) end)
        pcall(function() tune:Slider({Name="FOV", Default=S.Aim_FOV_Hold, Minimum=10, Maximum=800, Decimals=0, Pointer="Aim_FOV", Callback=function(v) S.Aim_FOV_Hold=v S.Aim_FOV_Toggle=v end}) end)
        pcall(function() tune:Slider({Name="Max Distance", Default=S.Aim_MaxDistance, Minimum=100, Maximum=5000, Decimals=0, Pointer="Aim_MaxDist", Callback=function(v) S.Aim_MaxDistance=v end}) end)
        pcall(function() tune:Colorpicker({Name="Lock Color", Default=S.Aimbot_LockColor, Pointer="Aimbot_LockColor", Callback=function(c) S.Aimbot_LockColor=c end}) end)
    end

    local trig = sec(cPage, "Triggerbot", "left")
    if trig then
        pcall(function() trig:Toggle({Name="Enable Trigger", Default=S.Trigger_Enabled, Pointer="Trigger_Enabled", Callback=function(v) S.Trigger_Enabled=v end}) end)
        pcall(function() trig:Slider({Name="Delay", Default=S.Trigger_Delay, Minimum=0, Maximum=500, Decimals=0, Measurement="ms", Pointer="Trigger_Delay", Callback=function(v) S.Trigger_Delay=v end}) end)
    end

    -- в•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђ
    -- VISUALS
    -- в•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђ
    local vPage = window:Page({ Name = "Visuals" })

    local enemy = sec(vPage, "Enemies", "left")
    if enemy then
        pcall(function() enemy:Toggle({Name="Enable ESP", Default=S.ESP_Enabled, Pointer="ESP_Enabled", Callback=function(v) S.ESP_Enabled=v F["Enabled"]=v refresh() end}) end)
        pcall(function() enemy:Slider({Name="Max Distance", Default=S.ESP_MaxDistance, Minimum=100, Maximum=5000, Decimals=0, Pointer="ESP_MaxDist", Callback=function(v) S.ESP_MaxDistance=v end}) end)

        pcall(function()
            local t = enemy:Toggle({Name="Names", Default=F["Names"], Pointer="Names", Callback=function(v) F["Names"]=v refresh() end})
            if t then t:Colorpicker({Name="Name Color", Default=F["Name_Color"].Color, Pointer="Name_Color", Callback=function(c) F["Name_Color"].Color=c refresh() end}) end
        end)
        pcall(function()
            local t = enemy:Toggle({Name="Boxes", Default=F["Boxes"], Pointer="Boxes", Callback=function(v) F["Boxes"]=v refresh() end})
            if t then t:Colorpicker({Name="Box Color", Default=F["Box_Color"].Color, Pointer="Box_Color", Callback=function(c) F["Box_Color"].Color=c refresh() end}) end
        end)
        pcall(function()
            local t = enemy:Toggle({Name="Healthbar", Default=F["Healthbar"], Pointer="Healthbar", Callback=function(v) F["Healthbar"]=v refresh() end})
            if t then
                t:Colorpicker({Name="High HP", Default=F["Health_High"].Color, Pointer="Health_High", Callback=function(c) F["Health_High"].Color=c refresh() end})
                t:Colorpicker({Name="Low HP", Default=F["Health_Low"].Color, Pointer="Health_Low", Callback=function(c) F["Health_Low"].Color=c refresh() end})
            end
        end)
        pcall(function()
            local t = enemy:Toggle({Name="Distance", Default=F["Distance"], Pointer="Distance", Callback=function(v) F["Distance"]=v refresh() end})
            if t then t:Colorpicker({Name="Distance Color", Default=F["Distance_Color"].Color, Pointer="Distance_Color", Callback=function(c) F["Distance_Color"].Color=c refresh() end}) end
        end)
        pcall(function()
            local t = enemy:Toggle({Name="Weapon", Default=F["Weapon"], Pointer="Weapon", Callback=function(v) F["Weapon"]=v refresh() end})
            if t then t:Colorpicker({Name="Weapon Color", Default=F["Weapon_Color"].Color, Pointer="Weapon_Color", Callback=function(c) F["Weapon_Color"].Color=c refresh() end}) end
        end)
        pcall(function() enemy:Dropdown({Name="Box Type", Options={"Corner","Full"}, Default=F["Box_Type"], Pointer="Box_Type", Callback=function(v) F["Box_Type"]=v refresh() end}) end)
    end

    local team = sec(vPage, "Teammates", "left")
    if team then
        pcall(function() team:Toggle({Name="Enable Teammates", Default=S.Teammates_Enabled, Pointer="Teammates_Enabled", Callback=function(v) S.Teammates_Enabled=v refresh() end}) end)
        pcall(function() team:Colorpicker({Name="Box Color", Default=S.Teammate_Box_Color, Pointer="Tm_Box", Callback=function(c) S.Teammate_Box_Color=c refresh() end}) end)
        pcall(function() team:Colorpicker({Name="Name Color", Default=S.Teammate_Name_Color, Pointer="Tm_Name", Callback=function(c) S.Teammate_Name_Color=c refresh() end}) end)
        pcall(function() team:Colorpicker({Name="Weapon Color", Default=S.Teammate_Weapon_Color, Pointer="Tm_Weapon", Callback=function(c) S.Teammate_Weapon_Color=c refresh() end}) end)
        pcall(function() team:Colorpicker({Name="HP High", Default=S.Teammate_Health_High, Pointer="Tm_HP_High", Callback=function(c) S.Teammate_Health_High=c end}) end)
        pcall(function() team:Colorpicker({Name="HP Low", Default=S.Teammate_Health_Low, Pointer="Tm_HP_Low", Callback=function(c) S.Teammate_Health_Low=c end}) end)
        pcall(function() team:Colorpicker({Name="Distance Color", Default=S.Teammate_Distance_Color, Pointer="Tm_Dist", Callback=function(c) S.Teammate_Distance_Color=c refresh() end}) end)
    end

    local self = sec(vPage, "Self", "left")
    if self then
        pcall(function() self:Toggle({Name="Enable Self ESP", Default=S.SelfESP_Enabled, Pointer="SelfESP_Enabled", Callback=function(v) S.SelfESP_Enabled=v refresh() end}) end)
        pcall(function() self:Colorpicker({Name="Box Color", Default=S.Self_Box_Color, Pointer="Self_Box", Callback=function(c) S.Self_Box_Color=c refresh() end}) end)
        pcall(function() self:Colorpicker({Name="Name Color", Default=S.Self_Name_Color, Pointer="Self_Name", Callback=function(c) S.Self_Name_Color=c refresh() end}) end)
        pcall(function() self:Colorpicker({Name="Weapon Color", Default=S.Self_Weapon_Color, Pointer="Self_Weapon", Callback=function(c) S.Self_Weapon_Color=c refresh() end}) end)
    end

    local mat = sec(vPage, "Self Material", "right")
    if mat then
        pcall(function() mat:Toggle({Name="Enable Material", Default=S.SelfChams_Enabled, Pointer="SelfChams_Enabled", Callback=function(v) S.SelfChams_Enabled=v if not v then safe(chams.RestoreSelf, chams) end end}) end)
        pcall(function() mat:Dropdown({Name="Material", Options={"ForceField","Neon","SmoothPlastic","Plastic","Glass"}, Default=S.SelfChams_Material, Pointer="SelfChams_Mat", Callback=function(v) S.SelfChams_Material=v end}) end)
        pcall(function() mat:Colorpicker({Name="Color", Default=S.SelfChams_Color, Pointer="SelfChams_Color", Callback=function(c) S.SelfChams_Color=c end}) end)
    end

    local light = sec(vPage, "Lighting", "right")
    if light then
        pcall(function() light:Toggle({Name="Fullbright", Default=S.Fullbright_Enabled, Pointer="Fullbright", Callback=function(v) S.Fullbright_Enabled=v end}) end)
        pcall(function() light:Toggle({Name="Ambient", Default=S.Ambient_Enabled, Pointer="Ambient", Callback=function(v) S.Ambient_Enabled=v end}) end)
        pcall(function() light:Colorpicker({Name="Ambient Color", Default=S.Ambient_Color, Pointer="Ambient_Color", Callback=function(c) S.Ambient_Color=c end}) end)
    end

    local hl = sec(vPage, "Highlights", "right")
    if hl then
        pcall(function() hl:Toggle({Name="Enemy Highlights", Default=S.Chams_Enabled, Pointer="Chams_Enabled", Callback=function(v) S.Chams_Enabled=v if not v then safe(chams.RestoreHighlights, chams) end end}) end)
        pcall(function() hl:Colorpicker({Name="Color", Default=S.Chams_Color, Pointer="Chams_Color", Callback=function(c) S.Chams_Color=c end}) end)
    end

    local misc = sec(vPage, "Misc", "right")
    if misc then
        pcall(function() misc:Toggle({Name="Watermark", Default=S.Watermark_Enabled, Pointer="Watermark", Callback=function(v) S.Watermark_Enabled=v end}) end)
        pcall(function() misc:Toggle({Name="Tracers", Default=S.Tracers_Enabled, Pointer="Tracers", Callback=function(v) S.Tracers_Enabled=v end}) end)
    end

    -- в•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђ
    -- SETTINGS
    -- в•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђв•ђ
    local sPage = window:Page({ Name = "Settings" })

    local menu = sec(sPage, "Menu", "left")
    if menu then
        pcall(function() menu:Keybind({Name="Menu Bind", Default=Enum.KeyCode.RightShift, Mode="Toggle", KeybindName="MenuBind", Pointer="MenuBind", Callback=function() end}) end)
        pcall(function()
            menu:Colorpicker({Name="Accent", Default=Color3.fromRGB(155,150,219), Pointer="MenuAccent", Callback=function(c)
                safe(function()
                    local old = Color3.fromRGB(155,150,219)
                    for _, v in pairs(library.drawings) do
                        local obj = v[1]
                        if obj and obj.__OBJECT_EXISTS then
                            if obj.Color == old then obj.Color = c end
                        end
                    end
                end)
            end})
        end)
        pcall(function() menu:Button({Name="Unload", Callback=function()
            safe(function() window:Unload() end)
            safe(function()
                if deps.Main and deps.Main.Unload then deps.Main.Unload()
                elseif getgenv().PastaUnload then getgenv().PastaUnload() end
            end)
        end}) end)
    end

    local info = sec(sPage, "Info", "left")
    if info then
        pcall(function() info:Label({Name="PastaSense v1.0", Middle=true}) end)
    end

    window:Initialize()
    return library
end

return UI
