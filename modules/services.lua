
local Services = {}

-- cloneref есть не во всех экзекуторах — мягкий фолбэк на identity
local _cloneref = nil
pcall(function()
    if type(_G) == "table" then
        local f = rawget(_G, "cloneref")
        if type(f) == "function" then
            _cloneref = f
        end
    end
end)
if type(_cloneref) ~= "function" then
    _cloneref = function(x) return x end
end
local function cref(x)
    local ok, r = pcall(_cloneref, x)
    if ok and r ~= nil then
        return r
    end
    return x
end
local cloneref = cref
Services.Workspace = cloneref(game:GetService("Workspace"))
Services.HttpService = cloneref(game:GetService("HttpService"))
Services.Debris = cloneref(game:GetService("Debris"))
Services.Players = cloneref(game:GetService("Players"))
Services.TweenService = cloneref(game:GetService("TweenService"))
Services.RunService = cloneref(game:GetService("RunService"))
Services.CoreGui = cloneref(game:GetService("CoreGui"))
Services.UserInputService = cloneref(game:GetService("UserInputService"))
Services.TeleportService = cloneref(game:GetService("TeleportService"))
Services.Lighting = cloneref(game:GetService("Lighting"))
Services.ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
Services.Stats = cloneref(game:GetService("Stats"))
Services.GuiService = cloneref(game:GetService("GuiService"))
Services.SoundService = cloneref(game:GetService("SoundService"))

Services.LocalPlayer = Services.Players.LocalPlayer
-- камеры может не быть в момент инжекта — не падаем, подхватим позже через workspace.CurrentCamera
Services.Camera = Services.Workspace:FindFirstChildWhichIsA("Camera")
if Services.Camera == nil then
    pcall(function()
        Services.Camera = workspace.CurrentCamera
    end)
end
if Services.Camera ~= nil then
    local ok, vp = pcall(function() return Services.Camera.ViewportSize end)
    if ok and vp then
        Services.Viewport = vp
    else
        Services.Viewport = Vector2.new(1920, 1080)
    end
else
    Services.Viewport = Vector2.new(1920, 1080)
end

Services.OriginalAmbient = Services.Lighting.Ambient
Services.OriginalBrightness = Services.Lighting.Brightness

Services.rayParams = RaycastParams.new()
Services.rayParams.FilterType = Enum.RaycastFilterType.Exclude

function Services.RefreshRayFilter()
    local list = {}
    local char = Services.LocalPlayer.Character
    local cam = Services.Workspace.CurrentCamera
    if char then table.insert(list, char) end
    if cam then table.insert(list, cam) end
    Services.rayParams.FilterDescendantsInstances = list
end

Services.vec2 = Vector2.new
Services.vec3 = Vector3.new
Services.dim2 = UDim2.new
Services.dim = UDim.new
Services.rect = Rect.new
Services.cfr = CFrame.new
Services.empty_cfr = Services.cfr()
Services.point_object_space = Services.empty_cfr.PointToObjectSpace
Services.angle = CFrame.Angles
Services.dim_offset = UDim2.fromOffset

Services.color = Color3.new
Services.rgb = Color3.fromRGB
Services.hex = Color3.fromHex
Services.hsv = Color3.fromHSV
Services.rgbseq = ColorSequence.new
Services.rgbkey = ColorSequenceKeypoint.new
Services.numseq = NumberSequence.new
Services.numkey = NumberSequenceKeypoint.new

return Services
