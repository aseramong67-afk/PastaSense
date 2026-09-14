-- example.lua — демо PastaSenseUI 1в1 как на скриншоте
-- Запуск в executor:
--   local Lib = loadstring(game:HttpGet("RAW_URL_СЮДА/PastaSenseUI.lua"))()
--   loadstring(game:HttpGet("RAW_URL_СЮДА/example.lua"))()
-- Локальный тест (оба файла рядом):
--   local Lib = loadstring(readfile("PastaSenseUI.lua"))()

local LibUrls = {
	"https://raw.githubusercontent.com/aseramong67-afk/PastaSense/main/PastaSenseUI/PastaSenseUI.lua",
}

-- качаем любым доступным способом: executor game:HttpGet,
-- HttpGetAsync (Studio с включённым HTTP), request-style API.
-- Доступ к globals через rawget(_G,...), чтобы не триггерить Script Analysis.
local G = (type(rawget(_G, "getgenv")) == "function" and rawget(_G, "getgenv")()) or _G
local synT = rawget(G, "syn")
local httpT = rawget(G, "http")

local function httpGet(url)
	if typeof(game.HttpGet) == "function" then
		local ok, res = pcall(function() return game:HttpGet(url) end)
		if ok and type(res) == "string" and #res > 0 then return res, "game:HttpGet" end
	end
	do
		local ok, res = pcall(function() return game:HttpGetAsync(url) end)
		if ok and type(res) == "string" and #res > 0 then return res, "game:HttpGetAsync" end
	end
	local req = (synT and synT.request) or (httpT and httpT.request) or rawget(G, "request")
	if typeof(req) == "function" then
		local ok, res = pcall(req, { Url = url, Method = "GET" })
		if ok and res then
			local body = (type(res) == "table" and res.Body) or res
			if type(body) == "string" and #body > 0 then return body, "request" end
		end
	end
	return nil, nil
end

local compileFn = rawget(G, "loadstring")
if type(compileFn) ~= "function" then
	error("[pastasense] нет loadstring — нужен executor (Wave/Solara/Delta) или Studio")
end

local Lib
do
	local lastErr = "no urls tried"
	for _, url in ipairs(LibUrls) do
		local src, used = httpGet(url)
		if not src then
			lastErr = "скачивание не удалось (game:HttpGet/HttpGetAsync/request недоступны). Studio: Game Settings -> Security -> включить HTTP Requests, запускать через Play"
		else
			print(("[pastasense] скачано через %s, байт: %d, начало: %s"):format(
				tostring(used), #src, string.sub(string.gsub(src, "%c", "?"), 1, 80)))
			local fn, cerr = compileFn(src)
			if not fn then
				lastErr = "loadstring отказался компилировать (" .. tostring(used) .. "): " .. tostring(cerr)
			else
				local ok, res = pcall(fn)
				if ok and res then
					Lib = res
					break
				else
					lastErr = "ошибка запуска библиотеки: " .. tostring(res)
				end
			end
		end
	end
	if not Lib then
		error("[pastasense] не смог загрузить библиотеку. URL: "
			.. table.concat(LibUrls, ", ")
			.. " | ошибка: " .. tostring(lastErr))
	end
end

-- выгрузка прошлой копии
pcall(function()
	if getgenv().PastaUnload then getgenv().PastaUnload() end
end)

local Win = Lib:CreateWindow({
	Name = "pastasense",
	User = "mamasha",
	ToggleKey = Enum.KeyCode.Insert, -- скрыть/показать на Insert
	Size = UDim2.fromOffset(900, 560),
})

-- ================= RAGE (главный скрин) =================
local Rage = Win:AddTab({ Name = "rage", Icon = "+" })

Rage:AddWeaponBar(
	{ "pistols", "rifles", "smgs", "heavies", "shotguns", "scout", "awp", "autos" },
	function(current)
		print("[weapon]", current)
	end
)

local Left, Right = Rage:Columns()

-- LEFT
Left:Section("RAGEBOT")
Left:Toggle({ Name = "enabled", Default = true, Flag = "rage_enabled", Callback = function(v) print("enabled", v) end })

Left:Section("TARGETING")
Left:Slider({ Name = "hit chance", Min = 0, Max = 100, Default = 80, Suffix = "%", Flag = "rage_hitchance" })
Left:Slider({ Name = "min damage", Min = 0, Max = 120, Default = 30, Suffix = "", Flag = "rage_mindamage" })
Left:Dropdown({ Name = "hitboxes", Items = { "none", "head", "chest", "stomach", "legs" }, Default = "none", Flag = "rage_hitboxes" })
Left:Slider({ Name = "point scale", Min = 0, Max = 100, Default = 85, Suffix = "%", Flag = "rage_pointscale" })
Left:Toggle({ Name = "force body aim", Default = false, Flag = "rage_forcebaim" })

Left:Section("CLOSE COMBAT")
Left:Toggle({ Name = "force knife", Default = false, Flag = "rage_knife" })
Left:Toggle({ Name = "force zeus", Default = false, Flag = "rage_zeus" })

-- RIGHT
Right:Section("FIRING")
Right:Toggle({ Name = "silent", Default = false, Flag = "fire_silent" })
Right:Toggle({ Name = "no spread", Default = false, Flag = "fire_nospread" })
Right:Toggle({ Name = "force shot in air", Default = false, Flag = "fire_inair" })
Right:Toggle({ Name = "force shot on ground", Default = false, Flag = "fire_onground" })
Right:Toggle({ Name = "auto stop", Default = false, Flag = "fire_autostop" })

Right:Section("ANTI AIM")
Right:Toggle({ Name = "anti aim", Default = false, Flag = "aa_enabled" })

Right:Section("PEEK ASSISTANCE")
Right:Toggle({ Name = "quick peek", Default = false, Flag = "peek_quick" })
Right:Toggle({ Name = "duck peek", Default = false, Flag = "peek_duck" })

-- ================= ОСТАЛЬНЫЕ ТАБЫ =================
local Legit = Win:AddTab({ Name = "legit", Icon = "o" })
do
	local L, R = Legit:Columns()
	L:Section("AIMBOT")
	L:Toggle({ Name = "enabled", Default = false, Flag = "legit_enabled" })
	L:Slider({ Name = "smoothness", Min = 1, Max = 100, Default = 20, Suffix = "%", Flag = "legit_smooth" })
	L:Dropdown({ Name = "hitbox", Items = { "head", "chest", "nearest" }, Default = "head", Flag = "legit_hitbox" })
	R:Section("TRIGGER")
	R:Toggle({ Name = "triggerbot", Default = false, Flag = "legit_trigger" })
	R:Keybind({ Name = "trigger key", Default = Enum.KeyCode.T, Flag = "legit_triggerkey", Callback = function(k) print("trigger key", k) end })
end

local Visuals = Win:AddTab({ Name = "visuals", Icon = "[]" })
do
	local L, R = Visuals:Columns()
	L:Section("ESP")
	L:Toggle({ Name = "box esp", Default = true, Flag = "vis_box" })
	L:Toggle({ Name = "name esp", Default = true, Flag = "vis_name" })
	L:Colorpicker({ Name = "esp color", Default = Color3.fromRGB(180, 255, 120), Flag = "vis_color" })
	R:Section("WORLD")
	R:Toggle({ Name = "night mode", Default = false, Flag = "vis_night" })
	R:Slider({ Name = "fov changer", Min = 70, Max = 120, Default = 90, Flag = "vis_fov" })
end

local Misc = Win:AddTab({ Name = "miscellaneous", Icon = "*" })
do
	local L, R = Misc:Columns()
	L:Section("MOVEMENT")
	L:Toggle({ Name = "bunny hop", Default = false, Flag = "misc_bhop" })
	L:Slider({ Name = "speed", Min = 16, Max = 100, Default = 16, Flag = "misc_speed" })
	R:Section("EXTRA")
	R:Textbox({ Name = "custom prefix", Default = ";", Placeholder = "prefix...", Flag = "misc_prefix" })
	R:Button({ Name = "unload UI", Callback = function() Win:Destroy() end })
end

local ConfigTab = Win:AddTab({ Name = "config", Icon = "=" })
do
	local L, R = ConfigTab:Columns()
	L:Section("CONFIGS")
	L:Textbox({ Name = "config name", Default = "default", Flag = "cfg_name" })
	L:Button({ Name = "save config", Callback = function()
		local f = Lib.Flags["cfg_name"]
		local n = (f and f.Value) or "default"
		Win:SaveConfig(n)
		print("[pastasense] saved", n)
	end })
	R:Section("LOAD")
	R:Button({ Name = "load config", Callback = function()
		local f = Lib.Flags["cfg_name"]
		local n = (f and f.Value) or "default"
		print("[pastasense] loaded", n, Win:LoadConfig(n))
	end })
end

Win:AddTab({ Name = "inventory", Icon = "=" })
Win:AddTab({ Name = "movement", Icon = ">>" })
Win:AddTab({ Name = "scripts", Icon = "</>" })

-- пример кастомизации темы:
-- Lib:SetTheme({ Accent = Color3.fromRGB(180, 255, 120) })

print("[pastasense] UI loaded. Toggle = Insert")
