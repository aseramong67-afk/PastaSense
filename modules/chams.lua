
local Chams = {}

function Chams.New(S, connections)
    local M = {}
    M.Original = {}
    M.Highlights = {}

    function M.RestoreSelf()
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

    function M.RestoreHighlights()
        for _, hl in pairs(M.Highlights) do
            pcall(function() hl:Destroy() end)
        end
        table.clear(M.Highlights)
    end

    function M.Restore()
        M.RestoreSelf()
        M.RestoreHighlights()
    end

    function M.UpdateSelf()
        if not S.SelfChams_Enabled then
            M.RestoreSelf()
            return
        end
        local LocalPlayer = game:GetService("Players").LocalPlayer
        local char = LocalPlayer.Character
        if not char then return end
        local selfMat = Enum.Material[S.SelfChams_Material] or Enum.Material.ForceField
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                if not M.Original[part] then
                    M.Original[part] = { M = part.Material, C = part.Color }
                end
                if part.Material ~= selfMat then part.Material = selfMat end
                if part.Color ~= S.SelfChams_Color then part.Color = S.SelfChams_Color end
            end
        end
    end

    function M.UpdateHighlights()
        if not S.Chams_Enabled then
            M.RestoreHighlights()
            return
        end
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local char = player.Character
                if not char then
                    if M.Highlights[player] then
                        pcall(function() M.Highlights[player]:Destroy() end)
                        M.Highlights[player] = nil
                    end
                else
                    local hl = M.Highlights[player]
                    if not hl or not hl.Parent then
                        hl = Instance.new("Highlight")
                        hl.Name = "\0"
                        hl.FillTransparency = 0.5
                        hl.OutlineTransparency = 0
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.Parent = char
                        M.Highlights[player] = hl
                    end
                    if hl.FillColor ~= S.Chams_Color then hl.FillColor = S.Chams_Color end
                    if hl.OutlineColor ~= S.Chams_Color then hl.OutlineColor = S.Chams_Color end
                end
            end
        end

        for player, hl in pairs(M.Highlights) do
            if not player.Parent or not player.Character or not hl.Parent then
                pcall(function() hl:Destroy() end)
                M.Highlights[player] = nil
            end
        end
    end

    function M.Update()
        M.UpdateSelf()
        M.UpdateHighlights()
    end

    function M.Cleanup()
        M.Restore()
    end

    return M
end

return Chams
