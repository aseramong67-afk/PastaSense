
local Aimbot = {}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

function Aimbot.New(S, connections, rayParams)
    local M = {}
    M.Visibility_Cache = {}

    local circleOk, circle = pcall(function() return Drawing.new("Circle") end)
    if circleOk and circle then
        M.FOVCircle = circle
        circle.Thickness = 1
        circle.Color = Color3.fromRGB(255, 255, 255)
        circle.Transparency = 1
        circle.Filled = false
        circle.Visible = false
    else
        M.FOVCircle = nil
    end

    function M.GetVisibility(targetId, char)
        local currentTime = tick()
        if M.Visibility_Cache[targetId] and (currentTime - M.Visibility_Cache[targetId].lastUpdate) < 0.1 then
            return M.Visibility_Cache[targetId].isVisible
        end
        local cam = workspace.CurrentCamera
        if not cam then return false end
        local partsToCheck = {
            char:FindFirstChild("Head"),
            char:FindFirstChild("HumanoidRootPart"),
            char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"),
            char:FindFirstChild("Right Arm") or char:FindFirstChild("RightUpperArm"),
            char:FindFirstChild("Left Arm") or char:FindFirstChild("LeftUpperArm"),
            char:FindFirstChild("Right Leg") or char:FindFirstChild("RightUpperLeg"),
            char:FindFirstChild("Left Leg") or char:FindFirstChild("LeftUpperLeg"),
        }
        local origin = cam.CFrame.Position
        local isVisible = false
        for _, part in pairs(partsToCheck) do
            if part and part:IsA("BasePart") then
                local result = workspace:Raycast(origin, part.Position - origin, rayParams)
                if result and result.Instance:IsDescendantOf(char) then
                    isVisible = true
                    break
                end
            end
        end
        M.Visibility_Cache[targetId] = { isVisible = isVisible, lastUpdate = currentTime }
        return isVisible
    end

    function M.GetClosestTarget()
        if not S.Aimbot_Enabled then return nil end
        local cam = workspace.CurrentCamera
        if not cam then return nil end
        local target = nil
        local shortestDistance = S.Aimbot_ToggleMode and S.Aim_FOV_Toggle or S.Aim_FOV_Hold
        local mousePos = UserInputService:GetMouseLocation()
        local LocalPlayer = Players.LocalPlayer

        local function CheckTarget(entityId, character)
            local aimPart
            if S.Hitbox == "Torso" then
                aimPart = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso") or character:FindFirstChild("HumanoidRootPart")
            elseif S.Hitbox == "Random" then
                local parts = {}
                for _, n in ipairs({ "Head", "UpperTorso", "Torso", "HumanoidRootPart" }) do
                    local p = character:FindFirstChild(n)
                    if p then parts[#parts + 1] = p end
                end
                aimPart = #parts > 0 and parts[math.random(1, #parts)] or nil
            else
                aimPart = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
            end
            if not aimPart then return end
            if (cam.CFrame.Position - aimPart.Position).Magnitude > S.Aim_MaxDistance then return end
            if S.DeathCheck then
                local hum = character:FindFirstChildOfClass("Humanoid")
                if not hum or hum.Health <= 0 then return end
            end
            local screenPos, onScreen = cam:WorldToViewportPoint(aimPart.Position)
            if onScreen then
                local distanceToMouse = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                if distanceToMouse < shortestDistance then
                    if S.Aimbot_WallCheck then
                        if M.GetVisibility(entityId, character) then
                            target = aimPart
                            shortestDistance = distanceToMouse
                        end
                    else
                        target = aimPart
                        shortestDistance = distanceToMouse
                    end
                end
            end
        end

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local sameTeam = player.Team ~= nil and player.Team == LocalPlayer.Team
                if (not S.TeamCheck) or not sameTeam then
                    CheckTarget(tostring(player.UserId), player.Character)
                end
            end
        end
        return target
    end

    function M.UpdateFOV()
        local fc = M.FOVCircle
        if not fc then return end
        fc.Visible = S.Show_FOV
        if S.Show_FOV then
            fc.Position = UserInputService:GetMouseLocation()
            fc.Radius = S.Aimbot_ToggleMode and S.Aim_FOV_Toggle or S.Aim_FOV_Hold
        end
    end

    function M.Cleanup()
        pcall(function()
            M.FOVCircle.Visible = false
            M.FOVCircle:Remove()
        end)
    end

    return M
end

return Aimbot
