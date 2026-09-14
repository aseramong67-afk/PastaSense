-- loader.lua — полный запуск PastaSense + Seere UI

local BASE = "https://raw.githubusercontent.com/aseramong67-afk/PastaSense/main/modules/"
local UI_URL = "https://raw.githubusercontent.com/aseramong67-afk/PastaSense/main/ui.lua"
local LIB_URL = "https://raw.githubusercontent.com/aseramong67-afk/PastaSense/main/seere.lua"

-- выгрузка прошлой копии
pcall(function()
    if getgenv().PastaUnload then getgenv().PastaUnload() end
end)

local function safeLoad(name, url)
    local ok, mod = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if not ok then
        warn("[PastaSense] Failed to load " .. name .. ": " .. tostring(mod))
        return nil
    end
    return mod
end

local library = safeLoad("library", LIB_URL)
if not library then return end
local Config = safeLoad("config", BASE .. "config.lua")
if not Config then return end
local Services = safeLoad("services", BASE .. "services.lua")
if not Services then return end
local AimbotMod = safeLoad("aimbot", BASE .. "aimbot.lua")
if not AimbotMod then return end
local ESPMod = safeLoad("esp", BASE .. "esp.lua")
if not ESPMod then return end
local EffectsMod = safeLoad("effects", BASE .. "effects.lua")
if not EffectsMod then return end
local ChamsMod = safeLoad("chams", BASE .. "chams.lua")
if not ChamsMod then return end
local MainMod = safeLoad("main", BASE .. "main.lua")
if not MainMod then return end
local UIMod = safeLoad("ui", UI_URL)
if not UIMod then return end

local connections = {}

local aimbot = AimbotMod.New(Config.S, connections, Services.rayParams)
local esp = ESPMod.New(Config.S, Config.ESPFlags, connections)
local effects = EffectsMod.New(Config.S, Services.OriginalAmbient, Services.OriginalBrightness)
local chams = ChamsMod.New(Config.S, connections)

local main = MainMod.New({
    Config = Config,
    Services = Services,
    Aimbot = aimbot,
    ESP = esp,
    Effects = effects,
    Chams = chams,
    Connections = connections,
})

local window = UIMod.Build({
    Config = Config,
    Services = Services,
    Aimbot = aimbot,
    ESP = esp,
    Effects = effects,
    Chams = chams,
    Main = main,
}, library)

getgenv().PastaWindow = window
