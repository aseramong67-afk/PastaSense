local Main = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")

function Main.New(deps)
    local S = deps.Config.S
    local ESPFlags = deps.Config.ESPFlags
    local services = deps.Services
    local aimbot = deps.Aimbot
    local esp = deps.ESP
    local light = deps.Effects.Light
    local chams = deps.Chams
    local connections = deps.Connections

    local LocalPlayer = services.LocalPlayer
    local rayParams = services.rayParams
    local RefreshRayFilter = services.RefreshRayFilter

    local ScriptUnloaded = false
    local CurrentAimTarget = nil
    local LastAimTick = {}
    local LastHealth = {}
    local AliveState = {}
    local triggerLast = 0
    local triggerHeld, triggerPressT = false, 0

    local WatermarkText = Drawing.new("Text")
    WatermarkText.Size = 13
    WatermarkText.Center = false
    WatermarkText.Outline = true
    WatermarkText.Color = Color3.fromRGB(255, 255, 255)
    WatermarkText.Transparency = 1
    WatermarkText.Visible = false
    WatermarkText.Font = Drawing.Fonts.Monospace
    local wmFrames, wmLast, wmFps = 0, tick(), 0

    local function UnloadScript()
        if ScriptUnloaded then return end
        ScriptUnloaded = true
        for _, c in ipairs(connections) do
            pcall(function() c:Disconnect() end)
        end
        pcall(function()
            WatermarkText.Visible = false
            WatermarkText:Remove()
        end)
        pcall(light.Cleanup)
        pcall(chams.Cleanup)
        pcall(aimbot.Cleanup)
        pcall(function()
            if esp and esp.screengui then esp.screengui:Destroy() end
            if esp and esp.cache then esp.cache:Destroy() end
        end)
    end

    pcall(function() getgenv().PastaUnload = UnloadScript end)

    table.insert(connections, Players.PlayerRemoving:Connect(function(player)
        local uid = tostring(player.UserId)
        AliveState[uid] = nil
        LastAimTick[uid] = nil
        LastHealth[uid] = nil
    end))

    for _, v in Players:GetPlayers() do
        esp:create_object(v)
    end
    table.insert(connections, Players.PlayerAdded:Connect(function(v)
        esp:create_object(v)
    end))
    table.insert(connections, Players.PlayerRemoving:Connect(function(v)
        esp:remove_object(v)
    end))
    esp:refresh_elements()

    local RenderConnection = RunService.RenderStepped:Connect(function()
        if ScriptUnloaded then return end
        local cam = workspace.CurrentCamera
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
        if not cam then return end

        RefreshRayFilter()

        local mousePos = UserInputService:GetMouseLocation()

        -- FOV
        aimbot.UpdateFOV()

        -- Watermark
        wmFrames = wmFrames + 1
        local wmNow = tick()
        if wmNow - wmLast >= 0.5 then
            wmFps = math.floor(wmFrames / (wmNow - wmLast) + 0.5)
            wmFrames = 0
            wmLast = wmNow
        end
        if S.Watermark_Enabled then
            local ok, ping = pcall(function() return math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue() + 0.5) end)
            WatermarkText.Text = string.format("pasta hub | %d fps | %s", wmFps, ok and (tostring(ping) .. " ms") or "--")
            WatermarkText.Position = Vector2.new(cam.ViewportSize.X - WatermarkText.TextBounds.X - 12, 10)
            WatermarkText.Visible = true
        else
            WatermarkText.Visible = false
        end

        -- Fullbright / Ambient
        light.Update()

        -- Rich ESP: скрыть всех перед обновлением
        for _, plr in pairs(Players:GetPlayers()) do
            local d = esp[plr.Name]
            if d and d.objects and d.objects["holder"] then
                d.objects["holder"].Visible = false
            end
        end

        -- Rich ESP render
        for _, player in Players:GetPlayers() do
            local data = esp[player.Name]
            if not data then continue end
            local character = data.info.character
            local humanoid = data.info.humanoid
            if not (character and humanoid) then continue end
            local objects = data.objects
            if not objects then continue end

            if S.DeathCheck and humanoid.Health <= 0 then
                objects["holder"].Visible = false
                continue
            end

            local isSelfP = player == LocalPlayer
            local sameTeamP = (not isSelfP) and player.Team ~= nil and player.Team == LocalPlayer.Team
            local showCat
            if isSelfP then
                showCat = S.SelfESP_Enabled
            elseif sameTeamP then
                showCat = S.Teammates_Enabled
            else
                showCat = S.ESP_Enabled
            end
            if not showCat then
                objects["holder"].Visible = false
                continue
            end

            local box_size, box_pos, on_screen, distance = esp:box_solve(humanoid.RootPart)
            local holder = objects["holder"]
            if not on_screen then
                holder.Visible = false
                continue
            end
            if (distance or math.huge) > (S.ESP_MaxDistance or math.huge) then
                holder.Visible = false
                continue
            end

            if holder.Visible ~= on_screen then
                holder.Visible = on_screen
            end
            local pos = UDim2.fromOffset(box_pos.X, box_pos.Y)
            if pos ~= holder.Position then
                holder.Position = UDim2.fromOffset(box_pos.X, box_pos.Y)
            end
            local size = UDim2.fromOffset(box_size.X, box_size.Y)
            if size ~= holder.Size then
                holder.Size = size
            end

            local distance_label = objects["distance"]
            if character == LocalPlayer.Character then
                if distance_label.Text ~= "" then distance_label.Text = "" end
            elseif distance_label.Text ~= tostring(math.round(distance)) .. "st" then
                distance_label.Text = tostring(math.round(distance)) .. "st"
            end

            local locked = CurrentAimTarget ~= nil and character == CurrentAimTarget
            local boxC, nameC, distC, wepC, hpHigh, hpLow
            if isSelfP then
                boxC = S.Self_Box_Color
                nameC = S.Self_Name_Color
                distC = S.Self_Distance_Color
                wepC = S.Self_Weapon_Color
                hpHigh = S.Self_Health_High
                hpLow = S.Self_Health_Low
            elseif sameTeamP then
                boxC = S.Teammate_Box_Color
                nameC = S.Teammate_Name_Color
                distC = S.Teammate_Distance_Color
                wepC = S.Teammate_Weapon_Color
                hpHigh = S.Teammate_Health_High
                hpLow = S.Teammate_Health_Low
            else
                boxC = ESPFlags["Box_Color"].Color
                nameC = ESPFlags["Name_Color"].Color
                distC = ESPFlags["Distance_Color"].Color
                wepC = ESPFlags["Weapon_Color"].Color
                hpHigh = ESPFlags["Health_High"].Color
                hpLow = ESPFlags["Health_Low"].Color
            end
            if locked then boxC = S.Aimbot_LockColor; nameC = S.Aimbot_LockColor end
            objects["name"].TextColor3 = nameC
            objects["box_color"].Color = boxC
            for _, corner in objects["corners"]:GetChildren() do
                corner.Frame.BackgroundColor3 = boxC
            end
        end

        -- Death tracking
        local nowTick = tick()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local hum = player.Character:FindFirstChildOfClass("Humanoid")
                local uid = tostring(player.UserId)
                local realAlive = (hum and hum.Health > 0) or false

                if AliveState[uid] == nil then
                    AliveState[uid] = realAlive
                elseif AliveState[uid] and not realAlive then
                    AliveState[uid] = false
                elseif realAlive and not AliveState[uid] then
                    AliveState[uid] = true
                end
            end
        end

        -- Chams
        chams.Update()

        -- Aimbot
        local wantAim = S.Aimbot_ToggleMode or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        local aimTarget = (S.Aimbot_Enabled and wantAim) and aimbot.GetClosestTarget() or nil
        CurrentAimTarget = aimTarget and aimTarget.Parent or nil
        if CurrentAimTarget then
            local owner = Players:GetPlayerFromCharacter(CurrentAimTarget)
            if owner then LastAimTick[tostring(owner.UserId)] = nowTick end
        end
        if aimTarget and mousemoverel then
            local aimPos = aimTarget.Position
            local screenPos, onScreen = cam:WorldToViewportPoint(aimPos)
            if onScreen then
                local moveX = (screenPos.X - mousePos.X) * S.Aim_Smoothing
                local moveY = (screenPos.Y - mousePos.Y) * S.Aim_Smoothing
                mousemoverel(moveX, moveY)
            end
        end

        -- Triggerbot
        do
            local wantTrigger = S.Trigger_Enabled and (mouse1click or mouse1press)
            local targetOk = false
            if wantTrigger then
                local mpos = UserInputService:GetMouseLocation()
                local mray = cam:ViewportPointToRay(mpos.X, mpos.Y)
                local hit = workspace:Raycast(mray.Origin, mray.Direction * 2000, rayParams)
                local model = hit and hit.Instance:FindFirstAncestorOfClass("Model")
                local tplr = model and Players:GetPlayerFromCharacter(model)
                if tplr and tplr ~= LocalPlayer then
                    local tsame = tplr.Team ~= nil and tplr.Team == LocalPlayer.Team
                    local thum = model:FindFirstChildOfClass("Humanoid")
                    local talive = (not S.DeathCheck) or (thum and thum.Health > 0)
                    if talive and ((not S.TeamCheck) or not tsame) and (tick() - triggerLast) >= S.Trigger_Delay / 1000 then
                        targetOk = true
                        LastAimTick[tostring(tplr.UserId)] = tick()
                    end
                end
            end
            if targetOk and not triggerHeld then
                triggerLast = tick()
                if mouse1press and mouse1release then
                    mouse1press()
                    triggerHeld = true
                    triggerPressT = tick()
                elseif mouse1click then
                    mouse1click()
                end
            elseif triggerHeld and ((not targetOk) or (tick() - triggerPressT) >= 0.05) then
                if mouse1release then mouse1release() end
                triggerHeld = false
            end
        end
    end)

    return {
        Unload = UnloadScript,
    }
end

return Main
