-- loader.lua — полный запуск PastaSense + Seere UI

local BASE = "https://raw.githubusercontent.com/aseramong67-afk/PastaSense/main/modules/"
local UI_URL = "https://raw.githubusercontent.com/aseramong67-afk/PastaSense/main/ui.lua"
local LIB_URL = "https://raw.githubusercontent.com/aseramong67-afk/PastaSense/main/seere.lua"

-- выгрузка прошлой копии
pcall(function()
    if getgenv().PastaUnload then getgenv().PastaUnload() end
end)

local library = loadstring(game:HttpGet(LIB_URL))()
local Config = loadstring(game:HttpGet(BASE .. "config.lua"))()
local Services = loadstring(game:HttpGet(BASE .. "services.lua"))()
local AimbotMod = loadstring(game:HttpGet(BASE .. "aimbot.lua"))()
local ESPMod = loadstring(game:HttpGet(BASE .. "esp.lua"))()
local EffectsMod = loadstring(game:HttpGet(BASE .. "effects.lua"))()
local ChamsMod = loadstring(game:HttpGet(BASE .. "chams.lua"))()
local MainMod = loadstring(game:HttpGet(BASE .. "main.lua"))()
local UIMod = loadstring(game:HttpGet(UI_URL))()

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
