
local Chams = {}

function Chams.New(S, connections)
    local M = {}
    M.Original = {}
    M.Frame = 0
    M.Sweep = 0

    function M.Restore()
        for part, orig in pairs(M.Original) do
            pcall(function()
                if part.Parent then
                    part.Material = orig.M
                    part.Color = orig.C
                end
            end)
        end
        table.clear(M.Original)
    end

    function M.Update()
        if (not S.Chams_Enabled) and (not S.SelfChams_Enabled) then return end
        M.Frame = M.Frame + 1
        if M.Frame % 2 == 1 then return end
        M.Sweep = M.Sweep + 1
        if M.Sweep >= 90 then
            M.Sweep = 0
            local dead = {}
            for part in pairs(M.Original) do
                if part.Parent == nil then dead[#dead + 1] = part end
            end
            for _, part in ipairs(dead) do M.Original[part] = nil end
        end
        local mat = Enum.Material[S.Chams_Material] or Enum.Material.ForceField
        local selfMat = Enum.Material[S.SelfChams_Material] or Enum.Material.ForceField
        for _, player in pairs(game:GetService("Players"):GetPlayers()) do
            if player.Character then
                local isSelf = player == game:GetService("Players").LocalPlayer
                local m, c
                if isSelf then
                    if S.SelfChams_Enabled then
                        m = selfMat
                        c = S.SelfChams_Color
                    elseif S.Chams_Enabled then
                        m = mat
                        c = S.SelfChams_Color
                    else
                        continue
                    end
                else
                    if not S.Chams_Enabled then continue end
                    m = mat
                    c = S.Chams_Color
                end
                for _, part in ipairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        if not M.Original[part] then
                            M.Original[part] = { M = part.Material, C = part.Color }
                        end
                        if part.Material ~= m then part.Material = m end
                        if part.Color ~= c then part.Color = c end
                    end
                end
            end
        end
    end

    function M.Cleanup()
        M.Restore()
    end

    return M
end

return Chams
