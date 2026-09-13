local Effects = {}

local Lighting = game:GetService("Lighting")

local function NewLighting(S, origAmbient, origBrightness)
    local M = {}
    M.OriginalAmbient = origAmbient
    M.OriginalBrightness = origBrightness

    function M.Update()
        if S.Fullbright_Enabled then
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.Brightness = 2
        elseif S.Ambient_Enabled then
            Lighting.Ambient = S.Ambient_Color
            Lighting.Brightness = M.OriginalBrightness
        else
            Lighting.Ambient = M.OriginalAmbient
            Lighting.Brightness = M.OriginalBrightness
        end
    end

    function M.Cleanup()
        pcall(function()
            Lighting.Ambient = M.OriginalAmbient
            Lighting.Brightness = M.OriginalBrightness
        end)
    end

    return M
end

function Effects.New(S, origAmbient, origBrightness)
    return {
        Light = NewLighting(S, origAmbient, origBrightness),
    }
end

return Effects
