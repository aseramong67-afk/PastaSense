--[[
	PastaSenseUI v1.0 — dark cheat UI library for Roblox executors
	Style reference: screenshot (sidebar + weapon pill-bar + 2 columns + white toggles/sliders)
	Usage:
		local Lib = loadstring(game:HttpGet("YOUR_RAW_URL/PastaSenseUI.lua"))()
		local Win = Lib:CreateWindow({ Name = "pastasense", User = "mamasha", ToggleKey = Enum.KeyCode.Insert })
		local Rage = Win:AddTab({ Name = "rage", Icon = "+" })
		... see demo.lua
	Executor friendly: gethui / protect_gui / writefile guarded with pcall.
]]

local PastaSenseUI = {}
PastaSenseUI.__index = PastaSenseUI
PastaSenseUI.Version = "1.6.0"
PastaSenseUI.Flags = {} -- flag -> { Value = any, Set = fn }

-- // Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

-- // Theme (customizable via Lib.Theme + Lib:SetTheme)
PastaSenseUI.Theme = {
	Background  = Color3.fromRGB(30, 30, 30),   -- main #1E1E1E
	Sidebar     = Color3.fromRGB(23, 23, 23),   -- #171717
	Card        = Color3.fromRGB(38, 38, 38),   -- #262626
	CardHover   = Color3.fromRGB(45, 45, 45),
	Input       = Color3.fromRGB(28, 28, 28),
	Accent      = Color3.fromRGB(255, 255, 255),-- white pill / slider / knob
	AccentText  = Color3.fromRGB(20, 20, 20),
	Text        = Color3.fromRGB(235, 235, 235),
	Hint        = Color3.fromRGB(138, 138, 138),
	Section     = Color3.fromRGB(120, 120, 120),
	Stroke      = Color3.fromRGB(55, 55, 55),
	Green       = Color3.fromRGB(180, 255, 120),
	Font        = Enum.Font.Montserrat,
	FontMedium  = Enum.Font.Montserrat,
	FontBold    = Enum.Font.MontserratBold,
}

local Theme = PastaSenseUI.Theme

-- // Helpers
local function Corner(parent, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 8)
	c.Parent = parent
	return c
end

local function Stroke(parent, color, thick)
	local s = Instance.new("UIStroke")
	s.Color = color or Theme.Stroke
	s.Thickness = thick or 1
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

local function Padding(parent, l, r, t, b)
	local p = Instance.new("UIPadding")
	p.PaddingLeft = UDim.new(0, l or 12)
	p.PaddingRight = UDim.new(0, r or 12)
	p.PaddingTop = UDim.new(0, t or 8)
	p.PaddingBottom = UDim.new(0, b or 8)
	p.Parent = parent
	return p
end

local function Label(parent, text, size, color, font, align)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Text = text
	l.Font = font or Theme.FontMedium
	l.TextSize = size or 13
	l.TextColor3 = color or Theme.Text
	l.TextXAlignment = align or Enum.TextXAlignment.Left
	l.TextTruncate = Enum.TextTruncate.AtEnd
	l.Parent = parent
	return l
end

-- Icons: встроенный пак (белые PNG 50px, icons8 ios-filled) в base64.
-- При первом запуске пишутся в workspace (PastaSenseUI/icons/) и используются.
-- Свой Icon в AddTab перекрывает дефолт: URL / "base64:..." / rbxassetid / глиф.
local DEFAULT_ICONS = {
rage = [==[base64:iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAACXBIWXMAAAsTAAALEwEAmpwYAAADG0lEQVR4nO2ZaYhOURjHL7JFlrFkSyMUhS98GJRoJISUfEGKkT2iNDV8QpZBtsiWSZK8tkGyhBLDkCUJU4qxNLYZDJnGDPPTaf50e3vV0DnnvlPvv27vub3nPvf87jnnOec8TxCklFJK3gQ0BAYDy4EYcAt4qsuUjwA5QIapGySbgOZANvCCuqtYwG2SAaABMBN4xf/rIzDX2AoigmgBHMOejhqbviG6Afexr3vGti+IlsAD3OkR0MqHVzqFe5106tWAxfjTUlcQrYFSjyBfgE4uQNbgX7m2IZoBnyIAKQOa2gSZSHQabxNke4QgW22CFEQIcs0myNsIQUpsglRGCFJhE6QqQpAqmyBmqx2VSm2CuNjp1lV3bIIcjBAkzyZIVoQg022CdIhowlcCadZABHM8ApDDViEEMgio8QjxExhgHUQwBzyC7HICIZB2wEsPEI99nNtNlPCb4zNIL6cQIZjRwFcHEJ+BYV4gQjD9gWcWIUx8uK9XiBBMeyDfAsQhoG0kEHFAo4Cr/9h448ovAEODZBPQB1gBXAI+JGj8G+AcsAzoEdQXURte7Qp09h6g/puAVcC8wIOARsA6YIYL42btKLBuOPG7GmsonrVt2KTRfihkGlMwO1NlE2E5DUxS3fXAJmAycNO4VJWvyMNN0HMjVX8IsE1puay4vEuJ2RbZBMnWNr5Y5X5AtSDmADfkhXoCd7WwmS34Q2Ch/isENgPv1MjZBl529+qqAVYrz2hUBCyxBhI/tExw2XxRoAvQPXSCHCEQo7Gqmwd8/50rBGaFQIrUUwN1FQLlQBMnQysBSJoWsVL10pM4kD8hHOCMccWhe/MBjOZrq55I6a5Bbqu8Ui/K1P3aOJCy0HMb9V+G7neGesSsK5dDdXsL1ATNjS66AHmt8ZyvcWy0Q3Pgve5zE4Ckq8HV+n0eAsnRvNgj4HLgvLLFJj9SAZywDTJccyGmObJPyctYyINtkNfaH/dsR2AaMFV2jKaowQuA6zqD7P695wLGaPjGgmQQsCjUWxk6+xuPlh7UJ1G7uG3RgalSvTgu6nalFDjWLx/aNjOTXDRjAAAAAElFTkSuQmCC]==],
legit = [==[base64:iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAACXBIWXMAAAsTAAALEwEAmpwYAAACNklEQVR4nNXazUsVURiA8SO4UMQUXAgKWpiChJC5cS2ChrkUP3DVQletQhAXkS5aJepCwXKjtWlTiwJR/wDdhIVSgaALEwUjKAwtP5448C6GC/c4986cmXMeuHA3w8xvZu58nHOVshBQC0wAH4Ff8tHfx4Ea5XrATWAGOCN7/4AloEG5FlAHLALnhO9clqlzAVAPLMhezje97EvgdhqAFjk9LoivS+A90G5746uBx8An7Lcp66qK89wfBtZkjyXdBbAKDOX0WwIqgV45Z3dxr13ZNr2NlSaIVykD5C/+dGqC/MSfjk2QffxpzwT5hj9tmyD6wc6XNkwQfb/wpQ8myAv8adoEGcWfHpkgPfjTfRPkHv7UYIKUxvxobqvfQGFWiGCSeEyP2ooRIZBZ3O9JGMgA7tcWdijH5U6BkmshgtnG3d6FQgjkKe42kAvkDm52BtwIDRHMF9zrbU4IgYzg49UqM6AcOMGdtoAClU/AHO70MC+EQBpTGpjL7DtQlDdEMK/w+Whk3OlN8x22+3rtk27YgOcpQrpiQQSuYAcpIN7EhghguhJG/DAOVEfEvE4Q0mcFETjFdhJAzFtDBDBNwB+LiM9AsXWIYAaBKwuII+BWIogAZixmhD7KrYkiAhj954A40jfczlQQAikApiIi9CxZt3Ih4FmEgbYO5VJAf45XMz071qxcDLirp8RCINat3bXjSubql7MArmQkM9q7RZLJFMVxAHEIPFA+BlQAk/IaUGZzZf8BfQ9PlEpdz7UAAAAASUVORK5CYII=]==],
visuals = [==[base64:iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAACXBIWXMAAAsTAAALEwEAmpwYAAABgUlEQVR4nO2YPUrEUBRG72AhqNNpYW+hMFqpGxBk1mJj5xTuwd5FqMhEcAlTiYVbUMksQMHCI0+uQ5Q8ksmPSe68AyEk8G5y8t3kJREJBAKLAUYQjCAYQTCCYATBCIIRBCMIRhDaxRg4AFZ1HXVRZOx587jpmsi+R+SwayJ9j0i/apEYeKTjiUyBXWAbeKMeIo/IXVUiLolBovAZ9RFpAmu6ziWRR2QmAWwBS7pMaBmS1U4q4Vrq1aWR2K6rxSoVSSYx0G3HO7Cj+0eesR+0RCT2SPwwSbSYm4mvgXNgCGx4xvy7yDSlndIYZfwHcGNfaEgkzkgiyXeLaQJDTeRK55m8NWoRiQucgJNJo0it0sgc7TQPs5oZ7fdARUiNV+/XROqRWQYugM+yB5OKk8iLa8tToKfHPwKeyxRsQiLJPbCpMuvAbdFC0sQz/w/uMX2sMj3gpMhbQ1u+R9w9cgmsSFFoF0/AngWRwgSRtiEYQTCCYATBCIIRBCMIRpBAILAYfAGZBnBpGq8oygAAAABJRU5ErkJggg==]==],
miscellaneous = [==[base64:iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAACXBIWXMAAAsTAAALEwEAmpwYAAABnklEQVR4nO2YMS8EQRSABwk5IlrJJaJRKXQ4iZ+hVWp1aE7kEkfrLygU2iuVTkSjJpprJAqNyIkofDIxkrX2bic7u2tm8752Z/a9bzNv9s0oJQiCICilgCv+0lWhwQBUaCAiniEivuGlCLAKnAKNskSAhom5kjnx2AvHgftILh1gvigRoG4EPs2UB2AiD5G9hHzegGNgOi8RYBLYBV4Tpu24SswCL4OSAh6BLWA0qwgwAmwAvSFxtFzdReQIO27i9WMjYupAz7Wh7SKynPKloug1fQbMpYnoMWbsTx2k0dO5ZBYxQWvAPtC3DKrrpzXkecuMsaFvYtecJFJ2k6Lp2OyOrsvtukCBW2C9MIGEnWYTeMpR4BnYBsZKkYgJTQEHwLuDwAdwAsyULpAgtACcZ5C4ABaVLxC6CKEvLapQ7IS+/RL6D5HvFqUZdIuCX03jkotI2zKQbsXXYnMHimRs4w9dRKpxsNKY42fYR93I5cNd8JcPGn0lY17+qw6KEEm4DnI7GbriKuINIuIbIuIbVRLpJnhc/ndegiAIygu+APcvISnzNpj2AAAAAElFTkSuQmCC]==],
config = [==[base64:iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAACXBIWXMAAAsTAAALEwEAmpwYAAAC20lEQVR4nO2av2sUQRTHN+QwaLwTwWjhD4QENBExRtGIpdhor5YG/QMisYsKElA06F+glZ1BLGwVLDRiEW0tRDGHwsVKiyTeJfeRgRdYxs3u/MrtXswXrrq3b+azO2/m7XsbRRv6DwTcA5b5Vw1gLGoXAVVW14eoHQRUgGYKyCJQioouYJhsHcxzgvuAa0BPht2IAciFDB89wCiwNzTEfuCrTKIGnE+xnTQAuZ1y/Rngu9ipWOsLBdGXELwqBh4AXZrtduCNAcgroKxdu0lugh5fs0DvWkDE9REYkLh4DvzBXPPAE+AwcACYSbF1hwH2ZECsqI6f1BNYMLCbBXa7gJgEbat12QVkC/CJ4ugzsNUaRGCOBVg6IdQATjpBxGBu5U0B3PCCEJASMJ0jxFug0xsktg3nscTmvc8QDeQU+WgZOBQS5IXlBFQaMw4MAt3yO6rWuvxno0ehIHbKrmGqp3r6ofkrA1MW/n4Bm13fJ1TKcVXyqfeWEB0GY3RYwrwG7sshfSLtRinndyUNcFUtdYDkGzbnMd43Neckx0v4adwUIjbmTc8xl5Kcpr2emuiIA4jaAHzUXAsQ6zxIAr9wIGUHkEoRQQaLsrTqrU7sAiSk9SSn11XxTOpOrdh+twE/HcdalLmOZWW76j38InDHsJiwoimLA/GZhd+XwIQqIwH9TgU+hxRFwVQynoQNxG+nFCVQ0jgnh92Q2pblNyQxYbucHgeByDmNb4ZO4wcsl1coLaiaVyiILinE5aUZVYUMAfKQ/DXpC3E2wIkfQk3gnCvEDuAHxVEN2OUConohRdOoa2PHpIhtU4H3KWJX1ZysQQzbCu/EZlhOa9e2Qm9GEbDq3fBZBaYhp3QpodEzbVhM0Bs9nVIu0rPwoF2reOvtC3Dac7ueSLn+eKwLEA5Ca/yockx3ht0VA5BLBi2NEafGTovzsv6o6GK9fDCwbj7hiFUt2/+jmg1F7voLIPGx/CY2I0YAAAAASUVORK5CYII=]==],
inventory = [==[base64:iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAjUlEQVR4nO3TsRHCMBAF0Y0cQVU29F+CqeSTEBJhM/rW7Dage6M7MPtfuXgIKQshZSGkLISUhZCymA5ireViIWRiyJ5kTbIcWOclyZbkNRKy/gr48vZjJOR2IuQ+ErLN8iP7Z4CjN/IcfSNDQ0hZCCkLIWUhpCyElIWQshBSFkLKQkhZCCkLIVeBGON7Axzn4IWh6ouvAAAAAElFTkSuQmCC]==],
movement = [==[base64:iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAACXBIWXMAAAsTAAALEwEAmpwYAAACo0lEQVR4nO2ZTYhOURiAXxllSPlZKWZKNtJIZocURb5iZ2FlVhZqFkpJKX8JC6KUxWQjG0QslDJfmeSn/CzEQj4JYwgjMoPx++j4zpfbde49Z77ce8+Z7lPTNHXO6X2+8/O+7zciJSVjD2ASsAd4DHzVv3cDrRKYxE3M3AhGRu9EGrskBPQxSqMmIaDvRBojMkZ25JGEgH6d0thZVGAbgZfAIHBJXVagAkxLGN+qXycT13N/tYDpwLmUT/YX8BA4AWwCOmIySrim70xN7UQREsuBfkZPb1SoMIAJwH7gJ83zHTis1ipKYi5wKyG4a8A6oAd47Sh0sAiJlcBHQzA/9FlviYwdDywDLlpE3hYh8sQQyFNgacoRvG8RGSxCpD8WxClgasr4rdg5lq+F/AmsomXUT5dlbBswbJFQT267Hj9RfAS44LobwHxgn/iG3jkbI8BsPf6suvT4tCu6YTI9CnGO6vEdkXzUJb4AHHCQ+ALMMhzBu+IDwDyHPkNxZBTlfAP1wFTyEjmNnc/AzMicbtx5npeIurA2DsXmTNalv1ci7yyBqJK+zTBvDTBgkwBW5yVyxuFT7UtqtgoH6IxUxi7H5EEjh3gDsBD4BCzSf88BrjjIvAAWiA9QL9Vv68BeRXZmHLABeGOR+QCsKNpDgM2xwL4Bexs9t+7neyydpMo7a7MKsB2oOiY3DDKdsfUWA/dS5jzLSqRK82xPWLMF2AIMGea8z0pkqEmJq+reWNZeb5jXl5VIbxMSA6ZkZ1h7R1rtlcUduex4R1TeOOmaF4DzhjX8Kd9d0aVGHD/yiSvAjIROsZgv6ZoFWGUQuSOhAWwziByX0MDceHVLaFD/t0GcJRIa1NvcKKoGmyKhwb+Jtiohwt9EO6zrOWslUFJSIv+F304HE3CzjTjQAAAAAElFTkSuQmCC]==],
scripts = [==[base64:iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAACXBIWXMAAAsTAAALEwEAmpwYAAABrUlEQVR4nO2YO0sDQRCAxweCVhZC6nQ+2vhIIJIindba2aSPtfa+Oi0F7bVNfoD2KQO2YmHQQm0UVMRPDqYIwSMXk12zw31V4HZm7rvdzO2eSEqKG4AJ4AhoER73wGHkIPojdA4k0JnopBWJmEAwgmAESRk2MIJgBMEIghHEc70voAjkQxepa4PJhi6ypiL7IYvcAWN6bHgIWWRHZ2PTRXLBDx9ARkWuh02kBswCqwnGXqjEHPD9y/Wi5qr5FGkC5bYtzkqCmJKOPYm5vtSWr6w1nIk8AdvAuBac1mPye5e4G2AEmASeY8Z8AqfAjOYeBbZ6aQpJROKKPCasUdW4isOHRRKRQh/T/hbdjMY2+li+hf8WOdO4HL3RdCHSz/rNacx5svvH6dL6a5FG27hXx/9DBtF+l2PGVfR6NUHORZ/tt5Po5TWvL7NOXoApbbtR++1GUXPVGLItyrE+3RKeEEd5F1TkkoBFrlQio5vFYEU2VGQXj8iA8z3owSlqn7cELLKns7GOZ2TA+bIqUidwkbwetKLPPl4RjCAYQTCCYATBCIIRBCMIRpCUFHHCD2G4tzYjCqlAAAAAAElFTkSuQmCC]==],
panel = [==[base64:iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAACXBIWXMAAAsTAAALEwEAmpwYAAAA10lEQVR4nO3XSw6DMAyE4TkIPQa0F4ceoY9LTVWJhZWFhdWEOOp8EqtGpv8ChAEZEMk3+3rWCukOCjGYAGpgAlCI4cxfSU77tY0cMpkzl+K3OXiPa9aQJXiPW8+QbQ/4Xnc2hMYhp4FCDGf+fPRhTR0C/9w4by3454Z6ay1H/8iv0DjkNFCIwQRQAxOAQgwmgBr4ByGrFquCFqsIZ74WqygoxHDma7EqabGKcOZrsYqCQgxnvr61SvrWinDm61srCgoxmABqYAJQiMEEUAPJV+eOR5UQwXk+D10sXOTAx4wAAAAASUVORK5CYII=]==],
}
local function isImageIcon(icon)
	if type(icon) == "number" then return true end
	if type(icon) ~= "string" then return false end
	local s = string.lower(icon)
	return string.sub(s, 1, 11) == "rbxassetid"
		or string.sub(s, 1, 6) == "rbx://"
		or tonumber(icon) ~= nil
end

local function normImage(icon)
	if type(icon) == "number" or tonumber(icon) then
		return "rbxassetid://" .. tostring(icon)
	end
	return icon
end

-- // Кастомные иконки через workspace инжектора.
-- Схема: скачали PNG по URL через game:HttpGet -> writefile("PastaSenseUI/icons/<key>.png")
-- -> ImageLabel.Image = getcustomasset(path). Повторно не качаем, только если файла нет.
-- Работает там где есть writefile/isfile/getcustomasset (Wave/Solara/Synapse и т.п.),
-- иначе тихо возвращаем nil и рисуется текстовый глиф.
local ICON_FOLDER = "PastaSenseUI/icons"

local function ensureIconFolder()
	pcall(function()
		if typeof(makefolder) ~= "function" then return end
		if typeof(isfolder) == "function" then
			if not isfolder("PastaSenseUI") then makefolder("PastaSenseUI") end
			if not isfolder(ICON_FOLDER) then makefolder(ICON_FOLDER) end
		else
			makefolder("PastaSenseUI")
			makefolder(ICON_FOLDER)
		end
	end)
end

local function iconPathFor(key)
	return ICON_FOLDER .. "/" .. (string.gsub(tostring(key), "[^%w_%-]", "_")) .. ".png"
end

-- Пишет PNG-байты в workspace и возвращает custom asset путь (или nil).
local function saveIconBytes(key, data)
	if type(data) ~= "string" or #data == 0 then return nil end
	if typeof(getcustomasset) ~= "function" or typeof(writefile) ~= "function" then return nil end
	local path = iconPathFor(key)
	local exists = false
	pcall(function()
		if typeof(isfile) == "function" and isfile(path) then
			exists = true
		end
	end)
	if not exists then
		ensureIconFolder()
		local wok = pcall(writefile, path, data)
		if not wok then return nil end
	end
	local ok, asset = pcall(getcustomasset, path)
	if ok and type(asset) == "string" and #asset > 0 then return asset end
	return nil
end

local function fetchWorkspaceIcon(key, url)
	if type(url) ~= "string" or string.sub(url, 1, 4) ~= "http" then return nil end
	local ok, data = pcall(function() return game:HttpGet(url) end)
	if not ok then return nil end
	return saveIconBytes(key, data)
end

-- // Base64 иконки текстом: Icon = "base64:...." или { Base64 = "...." }.
-- PNG в base64 ( certutil -encode in.png out.txt / любой онлайн-конвертер ),
-- декодируем в байты, пишем в workspace, используем через getcustomasset.
local B64ABC = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local B64D = {}
for _bi = 1, #B64ABC do
	B64D[string.sub(B64ABC, _bi, _bi)] = _bi - 1
end

local function base64Decode(data)
	if type(data) ~= "string" then return nil end
	data = string.gsub(data, "%s+", "")
	if (#data % 4) ~= 0 then return nil end
	local out = {}
	local outN = 0
	local i = 1
	local len = #data
	while i <= len do
		local c = {}
		local pad = 0
		for j = 0, 3 do
			local ch = string.sub(data, i + j, i + j)
			if ch == "=" or ch == "" then
				c[j + 1] = 0
				pad = pad + 1
			else
				local v = B64D[ch]
				if v == nil then return nil end
				c[j + 1] = v
			end
		end
		local n24 = c[1] * 262144 + c[2] * 4096 + c[3] * 64 + c[4]
		outN = outN + 1
		out[outN] = string.char(math.floor(n24 / 65536) % 256)
		if pad < 2 then
			outN = outN + 1
			out[outN] = string.char(math.floor(n24 / 256) % 256)
		end
		if pad < 1 then
			outN = outN + 1
			out[outN] = string.char(n24 % 256)
		end
		i = i + 4
	end
	return table.concat(out)
end

local function base64WorkspaceIcon(key, b64)
	if type(b64) ~= "string" then return nil end
	if string.sub(b64, 1, 7) == "base64:" then
		b64 = string.sub(b64, 8)
	end
	return saveIconBytes(key, base64Decode(b64))
end

-- Возвращает готовый Image-контент (asset id / custom asset) или nil.
-- key нужен для имени файла в workspace.
local function resolveIcon(icon, key)
	if isImageIcon(icon) then
		return normImage(icon)
	end
	if type(icon) == "table" and type(icon.Base64) == "string" then
		return base64WorkspaceIcon(key or "icon", icon.Base64)
	end
	if type(icon) == "string" then
		if string.sub(icon, 1, 7) == "base64:" then
			return base64WorkspaceIcon(key or "icon", icon)
		end
		if string.sub(icon, 1, 4) == "http" then
			return fetchWorkspaceIcon(key or icon, icon)
		end
	end
	return nil
end

-- Слот 30px под иконку слева в кнопке таба: картинка или текстовый глиф.
-- Возвращает созданный объект (ImageLabel / TextLabel).
local function TabIcon(parent, icon, tint, key)
	local image = resolveIcon(icon, key)
	if image then
		local img = Instance.new("ImageLabel")
		img.Size = UDim2.new(0, 18, 0, 18)
		img.AnchorPoint = Vector2.new(0, 0.5)
		img.Position = UDim2.new(0, 10, 0.5, 0)
		img.BackgroundTransparency = 1
		img.Image = image
		img.ImageColor3 = tint or Theme.Hint
		img.ScaleType = Enum.ScaleType.Fit
		img.Parent = parent
		return img
	end
	local l = Label(parent, tostring(icon), 14, tint or Theme.Hint, Theme.FontBold, Enum.TextXAlignment.Center)
	l.Size = UDim2.new(0, 30, 1, 0)
	l.Position = UDim2.new(0, 4, 0, 0)
	return l
end

local function paintTabIcon(iconObj, color)
	if not iconObj then return end
	if iconObj:IsA("ImageLabel") then
		iconObj.ImageColor3 = color
	elseif iconObj:IsA("TextLabel") then
		iconObj.TextColor3 = color
	end
end

local function protectGui(gui)
	pcall(function()
		local gethui = (getgenv and getgenv().gethui) or _G.gethui
		if typeof(gethui) == "function" then
			local hui = gethui()
			if hui then gui.Parent = hui return end
		end
	end)
	pcall(function()
		if typeof(get_hidden_gui) == "function" then gui.Parent = get_hidden_gui() return end
	end)
	pcall(function()
		if typeof(gethui) == "function" then gui.Parent = gethui() return end
	end)
	if not gui.Parent then
		pcall(function() gui.Parent = CoreGui end)
		if not gui.Parent then
			pcall(function() gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end)
		end
	end
	pcall(function()
		if syn and syn.protect_gui then syn.protect_gui(gui) end
		if typeof(protectgui) == "function" then protectgui(gui) end
	end)
end

local function tween(obj, props, time)
	pcall(function()
		TweenService:Create(obj, TweenInfo.new(time or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
	end)
end

local function registerFlag(flag, value, setter)
	if flag and flag ~= "" then
		PastaSenseUI.Flags[flag] = { Value = value, Set = setter }
	end
end

local function canWrite()
	return typeof(writefile) == "function" and typeof(readfile) == "function"
end

-- ============================================================================
-- WINDOW
-- ============================================================================
function PastaSenseUI:CreateWindow(opts)
	opts = opts or {}
	local winName = opts.Name or "pastasense"
	local userName = opts.User or (LocalPlayer and LocalPlayer.DisplayName or "user")
	local toggleKey = opts.ToggleKey or Enum.KeyCode.Insert
	local winSize = opts.Size or UDim2.fromOffset(900, 560)

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "PastaSenseUI"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.IgnoreGuiInset = false
	protectGui(ScreenGui)

	-- Лёгкий блюр фона (само меню остаётся чётким)
	local Blur = nil
	pcall(function()
		Blur = Instance.new("BlurEffect")
		Blur.Name = "PastaBlur"
		Blur.Size = 14
		Blur.Parent = Lighting
	end)

	-- Main
	local Main = Instance.new("Frame")
	Main.Name = "Main"
	Main.Size = winSize
	Main.Position = UDim2.new(0.5, -winSize.X.Offset / 2, 0.5, -winSize.Y.Offset / 2)
	Main.BackgroundColor3 = Theme.Background
	Main.BorderSizePixel = 0
	Main.Active = true
	Main.Parent = ScreenGui
	Corner(Main, 12)
	Stroke(Main, Theme.Stroke, 1)

	-- Подсветка краёв + мягкая тень под окном
	local EdgeGlow = Stroke(Main, Color3.fromRGB(110, 110, 110), 1)
	EdgeGlow.Transparency = 0.55
	local Shadow = Instance.new("Frame")
	Shadow.Name = "Shadow"
	Shadow.Size = UDim2.new(1, 18, 1, 18)
	Shadow.Position = UDim2.new(0, -9, 0, -5)
	Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	Shadow.BackgroundTransparency = 0.6
	Shadow.BorderSizePixel = 0
	Shadow.ZIndex = 0
	Shadow.Parent = Main
	Corner(Shadow, 15)

	-- Глубина фона + разделитель сайдбара
	local MainGrad = Instance.new("UIGradient")
	MainGrad.Rotation = 90
	MainGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212)),
	})
	MainGrad.Parent = Main
	local SideDiv = Instance.new("Frame")
	SideDiv.Size = UDim2.new(0, 1, 1, -16)
	SideDiv.Position = UDim2.new(0, 185, 0, 8)
	SideDiv.BackgroundColor3 = Theme.Stroke
	SideDiv.BackgroundTransparency = 0.3
	SideDiv.BorderSizePixel = 0
	SideDiv.Parent = Main

	-- Снежинки на фоне (поверх блюра, под меню; мелкие белые точки, не кликабельны)
	local Snow = Instance.new("Frame")
	Snow.Name = "Snow"
	Snow.Size = UDim2.new(1, 0, 1, 0)
	Snow.Position = UDim2.new(0, 0, 0, 0)
	Snow.BackgroundTransparency = 1
	Snow.ClipsDescendants = true
	Snow.ZIndex = 0
	Snow.Parent = ScreenGui
	task.spawn(function()
		local flakes = {}
		for i = 1, 45 do
			local fl = Instance.new("Frame")
			local sz = math.random(2, 5)
			fl.Size = UDim2.new(0, sz, 0, sz)
			fl.AnchorPoint = Vector2.new(0.5, 0.5)
			fl.Position = UDim2.new(math.random(), 0, math.random(), 0)
			fl.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			fl.BackgroundTransparency = 0.25 + math.random() * 0.5
			fl.BorderSizePixel = 0
			fl.Parent = Snow
			Corner(fl, 5)
			flakes[i] = {
				o = fl,
				x = fl.Position.X.Scale,
				sp = 0.0012 + math.random() * 0.0028,
				ph = math.random() * 6.28,
				sw = 0.004 + math.random() * 0.01,
			}
		end
		local t = 0
		while Snow.Parent do
			if Main.Visible and Main.Parent then
				t = t + 0.03
				for _, fl in ipairs(flakes) do
					local ny = fl.o.Position.Y.Scale + fl.sp
					if ny > 1.02 then
						ny = -0.02
						fl.x = math.random()
					end
					fl.o.Position = UDim2.new(fl.x + math.sin(t * 2 + fl.ph) * fl.sw, 0, ny, 0)
				end
			end
			task.wait(0.03)
		end
	end)

	-- Sidebar
	local Sidebar = Instance.new("Frame")
	Sidebar.Name = "Sidebar"
	Sidebar.Size = UDim2.new(0, 185, 1, 0)
	Sidebar.BackgroundColor3 = Theme.Sidebar
	Sidebar.BorderSizePixel = 0
	Sidebar.ClipsDescendants = true
	Sidebar.Parent = Main
	Corner(Sidebar, 12)
	-- fix right corners of sidebar (cover with small frame)
	local SidebarFix = Instance.new("Frame")
	SidebarFix.Size = UDim2.new(0, 12, 1, 0)
	SidebarFix.Position = UDim2.new(1, -12, 0, 0)
	SidebarFix.BackgroundColor3 = Theme.Sidebar
	SidebarFix.BorderSizePixel = 0
	SidebarFix.Parent = Sidebar

	-- User row
	local UserRow = Instance.new("Frame")
	UserRow.Size = UDim2.new(1, 0, 0, 52)
	UserRow.BackgroundTransparency = 1
	UserRow.Parent = Sidebar
	Padding(UserRow, 14, 10, 12, 6)

	local Dollar = Instance.new("TextLabel")
	Dollar.Size = UDim2.new(0, 22, 0, 22)
	Dollar.Position = UDim2.new(0, 14, 0, 14)
	Dollar.BackgroundTransparency = 1
	Dollar.Font = Theme.FontBold
	Dollar.TextSize = 16
	Dollar.TextColor3 = Theme.Text
	Dollar.Text = "$"
	Dollar.Parent = Sidebar

	local UserLabel = Label(Sidebar, userName, 13, Theme.Text, Theme.FontMedium)
	UserLabel.Position = UDim2.new(0, 42, 0, 14)
	UserLabel.Size = UDim2.new(1, -56, 0, 22)

	local PanelBtn
	do
		local panelImg = resolveIcon(DEFAULT_ICONS.panel, "panel")
		if panelImg then
			local IB = Instance.new("ImageButton")
			IB.Size = UDim2.new(0, 26, 0, 26)
			IB.Position = UDim2.new(0, 198, 0, 12)
			IB.BackgroundColor3 = Theme.Card
			IB.Image = panelImg
			IB.ImageColor3 = Theme.Hint
			IB.ScaleType = Enum.ScaleType.Fit
			IB.AutoButtonColor = false
			IB.Parent = Main
			Corner(IB, 6)
			Padding(IB, 5, 5, 5, 5)
			PanelBtn = IB
		else
			local TB = Instance.new("TextButton")
			TB.Size = UDim2.new(0, 26, 0, 26)
			TB.Position = UDim2.new(0, 198, 0, 12)
			TB.BackgroundColor3 = Theme.Card
			TB.Text = "[]"
			TB.Font = Theme.FontBold
			TB.TextSize = 12
			TB.TextColor3 = Theme.Hint
			TB.AutoButtonColor = false
			TB.Parent = Main
			Corner(TB, 6)
			PanelBtn = TB
		end
	end

	-- Tab list
	local TabList = Instance.new("ScrollingFrame")
	TabList.Size = UDim2.new(1, 0, 1, -64)
	TabList.Position = UDim2.new(0, 0, 0, 52)
	TabList.BackgroundTransparency = 1
	TabList.ScrollBarThickness = 0
	TabList.AutomaticCanvasSize = Enum.AutomaticSize.Y
	TabList.CanvasSize = UDim2.new(0, 0, 0, 0)
	TabList.Parent = Sidebar
	local TabLayout = Instance.new("UIListLayout")
	TabLayout.Padding = UDim.new(0, 2)
	TabLayout.Parent = TabList
	Padding(TabList, 10, 10, 4, 10)

	-- Topbar
	local Topbar = Instance.new("Frame")
	Topbar.Size = UDim2.new(1, -185 - 14, 0, 50)
	Topbar.Position = UDim2.new(0, 185, 0, 0)
	Topbar.BackgroundTransparency = 1
	Topbar.Parent = Main

	local CurrentTabLabel = Label(Topbar, "rage", 13, Theme.Hint, Theme.FontMedium)
	CurrentTabLabel.Position = UDim2.new(0, 52, 0, 14)
	CurrentTabLabel.Size = UDim2.new(0, 200, 0, 22)

	local SearchBox = Instance.new("TextBox")
	SearchBox.Size = UDim2.new(0, 30, 0, 30)
	SearchBox.AnchorPoint = Vector2.new(1, 0)
	SearchBox.Position = UDim2.new(1, -10, 0, 10)
	SearchBox.BackgroundColor3 = Theme.Card
	SearchBox.Text = ""
	SearchBox.PlaceholderText = "Search"
	SearchBox.Font = Theme.Font
	SearchBox.TextSize = 13
	SearchBox.TextColor3 = Theme.Text
	SearchBox.PlaceholderColor3 = Theme.Hint
	SearchBox.ClipsDescendants = true
	SearchBox.Parent = Topbar
	Corner(SearchBox, 8)

	-- Content root
	local Content = Instance.new("Frame")
	Content.Size = UDim2.new(1, -185 - 20, 1, -60)
	Content.Position = UDim2.new(0, 185 + 10, 0, 50)
	Content.BackgroundTransparency = 1
	Content.ClipsDescendants = true
	Content.Parent = Main

	local Window = {}
	Window._gui = ScreenGui
	Window._main = Main
	Window._tabs = {}
	Window._activeTab = nil
	Window._search = SearchBox
	Window.Name = winName

	-- Drag (topbar + sidebar header)
	do
		local dragging, dragStart, startPos = false, nil, nil
		local function begin(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				dragStart = input.Position
				startPos = Main.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then dragging = false end
				end)
			end
		end
		Topbar.InputBegan:Connect(begin)
		Sidebar.InputBegan:Connect(begin)
		UserInputService.InputChanged:Connect(function(input)
			if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				local delta = input.Position - dragStart
				Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end
		end)
	end

	-- Toggle visibility on Insert (default)
	UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.KeyCode == toggleKey then
			Main.Visible = not Main.Visible
			pcall(function() Blur.Enabled = Main.Visible end)
		end
	end)
	-- Кнопка [] сворачивает/разворачивает сайдбар, контент расширяется
	local sidebarOpen = true
	PanelBtn.MouseButton1Click:Connect(function()
		sidebarOpen = not sidebarOpen
		if sidebarOpen then
			Sidebar.Visible = true
			SideDiv.Visible = true
			tween(Sidebar, { Size = UDim2.new(0, 185, 1, 0) }, 0.2)
			tween(PanelBtn, { Position = UDim2.new(0, 198, 0, 12) }, 0.2)
			tween(Topbar, { Size = UDim2.new(1, -199, 0, 50), Position = UDim2.new(0, 185, 0, 0) }, 0.2)
			tween(Content, { Size = UDim2.new(1, -205, 1, -60), Position = UDim2.new(0, 195, 0, 50) }, 0.2)
		else
			tween(Sidebar, { Size = UDim2.new(0, 0, 1, 0) }, 0.2)
			tween(PanelBtn, { Position = UDim2.new(0, 13, 0, 12) }, 0.2)
			tween(Topbar, { Size = UDim2.new(1, -56, 0, 50), Position = UDim2.new(0, 46, 0, 0) }, 0.2)
			tween(Content, { Size = UDim2.new(1, -20, 1, -60), Position = UDim2.new(0, 10, 0, 50) }, 0.2)
			task.delay(0.2, function()
				if not sidebarOpen then Sidebar.Visible = false SideDiv.Visible = false end
			end)
		end
	end)

	-- Search filter
	SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
		local tab = Window._activeTab
		if not tab then return end
		local q = string.lower(SearchBox.Text or "")
		if q == "" or q == "search" then
			for _, el in ipairs(tab._elements) do
				if el.Frame then el.Frame.Visible = true end
				if el.SectionTitle then el.SectionTitle.Visible = true end
			end
			return
		end
		for _, el in ipairs(tab._elements) do
			if el.Frame and el.Name then
				el.Frame.Visible = (string.find(string.lower(el.Name), q, 1, true) ~= nil)
			end
		end
	end)
	SearchBox.Focused:Connect(function()
		tween(SearchBox, { Size = UDim2.new(0, 160, 0, 30) }, 0.18)
	end)
	SearchBox.FocusLost:Connect(function()
		if SearchBox.Text == "" then
			tween(SearchBox, { Size = UDim2.new(0, 30, 0, 30) }, 0.18)
		end
	end)

	---------------------------------------------------------------------------
	-- TAB
	---------------------------------------------------------------------------
	function Window:AddTab(tabOpts)
		tabOpts = tabOpts or {}
		local tabName = tabOpts.Name or ("tab" .. (#self._tabs + 1))
		local tabIcon = tabOpts.Icon or DEFAULT_ICONS[string.lower(tabName)] or "*"

		-- Sidebar button
		local Btn = Instance.new("TextButton")
		Btn.Size = UDim2.new(1, 0, 0, 36)
		Btn.BackgroundColor3 = Theme.Sidebar
		Btn.AutoButtonColor = false
		Btn.Text = ""
		Btn.Parent = TabList
		Corner(Btn, 8)
		local BtnStroke = Instance.new("UIStroke")
		BtnStroke.Color = Color3.fromRGB(255, 255, 255)
		BtnStroke.Transparency = 1
		BtnStroke.Thickness = 1
		BtnStroke.Parent = Btn
		local ActiveBar = Instance.new("Frame")
		ActiveBar.Size = UDim2.new(0, 3, 0, 20)
		ActiveBar.AnchorPoint = Vector2.new(0, 0.5)
		ActiveBar.Position = UDim2.new(0, 0, 0.5, 0)
		ActiveBar.BackgroundColor3 = Theme.Accent
		ActiveBar.BorderSizePixel = 0
		ActiveBar.Visible = false
		ActiveBar.Parent = Btn
		Corner(ActiveBar, 1)

		local IconL = TabIcon(Btn, tabIcon, Theme.Hint, tabName)

		local NameL = Label(Btn, tabName, 13, Theme.Hint, Theme.FontMedium)
		NameL.Size = UDim2.new(1, -40, 1, 0)
		NameL.Position = UDim2.new(0, 36, 0, 0)

		-- Page
		local Page = Instance.new("Frame")
		Page.Size = UDim2.new(1, 0, 1, 0)
		Page.BackgroundTransparency = 1
		Page.Visible = false
		Page.Parent = Content

		local WeaponBarHolder = Instance.new("Frame")
		WeaponBarHolder.Size = UDim2.new(1, 0, 0, 38)
		WeaponBarHolder.BackgroundTransparency = 1
		WeaponBarHolder.Visible = false
		WeaponBarHolder.Parent = Page

		local WeaponScroll = Instance.new("ScrollingFrame")
		WeaponScroll.Size = UDim2.new(1, 0, 1, 0)
		WeaponScroll.BackgroundColor3 = Theme.Sidebar
		WeaponScroll.ScrollBarThickness = 0
		WeaponScroll.ScrollingDirection = Enum.ScrollingDirection.X
		WeaponScroll.AutomaticCanvasSize = Enum.AutomaticSize.X
		WeaponScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
		WeaponScroll.Parent = WeaponBarHolder
		Corner(WeaponScroll, 18)
		local WL = Instance.new("UIListLayout")
		WL.FillDirection = Enum.FillDirection.Horizontal
		WL.Padding = UDim.new(0, 4)
		WL.VerticalAlignment = Enum.VerticalAlignment.Center
		WL.Parent = WeaponScroll
		Padding(WeaponScroll, 6, 6, 4, 4)

		local Columns = Instance.new("Frame")
		Columns.Size = UDim2.new(1, 0, 1, 0)
		Columns.Position = UDim2.new(0, 0, 0, 0)
		Columns.BackgroundTransparency = 1
		Columns.Parent = Page
		local ColLayout = Instance.new("UIListLayout")
		ColLayout.FillDirection = Enum.FillDirection.Horizontal
		ColLayout.Padding = UDim.new(0, 12)
		ColLayout.Parent = Columns

		local Tab = {}
		Tab.Name = tabName
		Tab._page = Page
		Tab._button = Btn
		Tab._icon = IconL
		Tab._name = NameL
		Tab._stroke = BtnStroke
		Tab._bar = ActiveBar
		Tab._elements = {}
		Tab._weaponButtons = {}
		Tab._weaponCallback = nil
		Tab._left = nil
		Tab._right = nil

		local function makeColumn()
			local Scroll = Instance.new("ScrollingFrame")
			Scroll.Size = UDim2.new(0.5, -6, 1, 0)
			Scroll.BackgroundTransparency = 1
			Scroll.ScrollBarThickness = 2
			Scroll.ScrollBarImageColor3 = Theme.Stroke
			Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
			Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
			Scroll.Parent = Columns
			local L = Instance.new("UIListLayout")
			L.Padding = UDim.new(0, 8)
			L.SortOrder = Enum.SortOrder.LayoutOrder
			L.Parent = Scroll
			Padding(Scroll, 2, 6, 2, 2)

			local Col = {}
			Col._scroll = Scroll
			Col._order = 0
			Col._tab = Tab

			function Col:Section(title)
				self._order = self._order + 1
				local Wrap = Instance.new("Frame")
				Wrap.Size = UDim2.new(1, 0, 0, 26)
				Wrap.BackgroundTransparency = 1
				Wrap.LayoutOrder = self._order
				Wrap.Parent = Scroll
				local T = Label(Wrap, string.upper(title or "SECTION"), 11, Theme.Section, Theme.FontBold)
				T.Size = UDim2.new(1, 0, 0, 16)
				local Line = Instance.new("Frame")
				Line.Size = UDim2.new(0, 26, 0, 2)
				Line.Position = UDim2.new(0, 1, 0, 19)
				Line.BackgroundColor3 = Theme.Accent
				Line.BackgroundTransparency = 0.25
				Line.BorderSizePixel = 0
				Line.Parent = Wrap
				Corner(Line, 1)
				table.insert(self._tab._elements, { Name = title, Frame = Wrap, SectionTitle = Wrap })
				return self
			end

			local function trackCard(name, frame)
				Col._order = Col._order + 1
				frame.LayoutOrder = Col._order
				table.insert(Col._tab._elements, { Name = name, Frame = frame })
			end

			-- Обводка + hover-подсветка карточек (убирает "сырость")
			local function styleCard(card)
				Stroke(card, Theme.Stroke, 1)
				card.MouseEnter:Connect(function()
					tween(card, { BackgroundColor3 = Theme.CardHover }, 0.12)
				end)
				card.MouseLeave:Connect(function()
					tween(card, { BackgroundColor3 = Theme.Card }, 0.12)
				end)
			end

			function Col:Toggle(o)
				o = o or {}
				local name = o.Name or "toggle"
				local def = (o.Default == true)
				local cb = o.Callback or function() end
				local flag = o.Flag or (Tab.Name .. "_" .. name)

				local Card = Instance.new("Frame")
				Card.Size = UDim2.new(1, 0, 0, 44)
				Card.BackgroundColor3 = Theme.Card
				Card.BorderSizePixel = 0
				Card.Parent = Scroll
				Corner(Card, 10)
				Padding(Card, 14, 14, 0, 0)
				trackCard(name, Card)
				styleCard(Card)

				Label(Card, name, 13, Theme.Text, Theme.FontMedium).Size = UDim2.new(1, -70, 1, 0)

				local Pill = Instance.new("TextButton")
				Pill.Size = UDim2.new(0, 44, 0, 24)
				Pill.AnchorPoint = Vector2.new(1, 0.5)
				Pill.Position = UDim2.new(1, 0, 0.5, 0)
				Pill.BackgroundColor3 = def and Theme.Accent or Color3.fromRGB(70, 70, 70)
				Pill.Text = ""
				Pill.AutoButtonColor = false
				Pill.Parent = Card
				Corner(Pill, 12)

				local Knob = Instance.new("Frame")
				Knob.Size = UDim2.new(0, 20, 0, 20)
				Knob.AnchorPoint = Vector2.new(0, 0.5)
				Knob.Position = def and UDim2.new(1, -22, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
				Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Knob.BorderSizePixel = 0
				Knob.Parent = Pill
				Corner(Knob, 10)
				local KnobStroke = Instance.new("UIStroke")
				KnobStroke.Color = Color3.fromRGB(170, 170, 170)
				KnobStroke.Thickness = 1
				KnobStroke.Parent = Knob

				local state = def
				local function apply(v, silent)
					state = v
					tween(Pill, { BackgroundColor3 = v and Theme.Accent or Color3.fromRGB(70, 70, 70) }, 0.15)
					tween(Knob, { Position = v and UDim2.new(1, -22, 0.5, 0) or UDim2.new(0, 2, 0.5, 0) }, 0.15)
					PastaSenseUI.Flags[flag] = { Value = v, Set = apply }
					if not silent then pcall(cb, v) end
				end
				Pill.MouseButton1Click:Connect(function() apply(not state) end)
				registerFlag(flag, state, apply)
				pcall(cb, state)
				return { Set = apply, Get = function() return state end }
			end

			function Col:Slider(o)
				o = o or {}
				local name = o.Name or "slider"
				local min, max = o.Min or 0, o.Max or 100
				local def = o.Default ~= nil and o.Default or min
				local suffix = o.Suffix or ""
				local cb = o.Callback or function() end
				local flag = o.Flag or (Tab.Name .. "_" .. name)

				local Card = Instance.new("Frame")
				Card.Size = UDim2.new(1, 0, 0, 58)
				Card.BackgroundColor3 = Theme.Card
				Card.BorderSizePixel = 0
				Card.Parent = Scroll
				Corner(Card, 10)
				Padding(Card, 14, 14, 8, 10)
				trackCard(name, Card)
				styleCard(Card)

				local Top = Instance.new("Frame")
				Top.Size = UDim2.new(1, 0, 0, 20)
				Top.BackgroundTransparency = 1
				Top.Parent = Card
				local NL = Label(Top, name, 13, Theme.Text, Theme.FontMedium)
				NL.Size = UDim2.new(1, -60, 1, 0)
				local VL = Label(Top, tostring(def) .. suffix, 12, Theme.Hint, Theme.Font, Enum.TextXAlignment.Right)
				VL.Size = UDim2.new(0, 60, 1, 0)
				VL.Position = UDim2.new(1, -60, 0, 0)

				local BarBg = Instance.new("Frame")
				BarBg.Size = UDim2.new(1, 0, 0, 4)
				BarBg.Position = UDim2.new(0, 0, 0, 34)
				BarBg.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
				BarBg.BorderSizePixel = 0
				BarBg.Parent = Card
				Corner(BarBg, 2)

				local Fill = Instance.new("Frame")
				Fill.Size = UDim2.new(0, 0, 1, 0)
				Fill.BackgroundColor3 = Theme.Accent
				Fill.BorderSizePixel = 0
				Fill.Parent = BarBg
				Corner(Fill, 2)

				local Knob = Instance.new("Frame")
				Knob.Size = UDim2.new(0, 16, 0, 16)
				Knob.AnchorPoint = Vector2.new(0.5, 0.5)
				Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Knob.BorderSizePixel = 0
				Knob.Parent = BarBg
				Corner(Knob, 8)
				local KnobStroke = Instance.new("UIStroke")
				KnobStroke.Color = Color3.fromRGB(170, 170, 170)
				KnobStroke.Thickness = 1
				KnobStroke.Parent = Knob

				local value = def
				local function render()
					local t = (max - min) == 0 and 0 or math.clamp((value - min) / (max - min), 0, 1)
					Fill.Size = UDim2.new(t, 0, 1, 0)
					Knob.Position = UDim2.new(t, 0, 0.5, 0)
					local shown = value
					if o.Decimals == nil or o.Decimals == 0 then shown = math.floor(value + 0.5) end
					VL.Text = tostring(shown) .. suffix
				end
				local function apply(v, silent)
					value = math.clamp(v, min, max)
					render()
					PastaSenseUI.Flags[flag] = { Value = value, Set = apply }
					if not silent then pcall(cb, value) end
				end
				render()
				registerFlag(flag, value, apply)
				pcall(cb, value)

				-- Невидимая широкая зона захвата: по тонкой полосе (4px) сложно попасть,
				-- а скролл колонки перехватывает драг. На время драга скролл выключаем.
				local Hitbox = Instance.new("TextButton")
				Hitbox.Size = UDim2.new(1, 0, 0, 26)
				Hitbox.Position = UDim2.new(0, 0, 0, 23)
				Hitbox.BackgroundTransparency = 1
				Hitbox.Text = ""
				Hitbox.AutoButtonColor = false
				Hitbox.Parent = Card

				local dragging = false
				local function updateFromInput(input)
					local absPos = BarBg.AbsolutePosition
					local absSize = BarBg.AbsoluteSize
					local t = math.clamp((input.Position.X - absPos.X) / math.max(absSize.X, 1), 0, 1)
					apply(min + (max - min) * t)
				end
				local function isPress(input)
					return input.UserInputType == Enum.UserInputType.MouseButton1
						or input.UserInputType == Enum.UserInputType.Touch
				end
				local function isMove(input)
					return input.UserInputType == Enum.UserInputType.MouseMovement
						or input.UserInputType == Enum.UserInputType.Touch
				end
				Hitbox.InputBegan:Connect(function(input)
					if isPress(input) then
						dragging = true
						pcall(function() Scroll.ScrollingEnabled = false end)
						updateFromInput(input)
					end
				end)
				UserInputService.InputEnded:Connect(function(input)
					if dragging and isPress(input) then
						dragging = false
						pcall(function() Scroll.ScrollingEnabled = true end)
					end
				end)
				UserInputService.InputChanged:Connect(function(input)
					if dragging and isMove(input) then
						updateFromInput(input)
					end
				end)
				return { Set = apply, Get = function() return value end }
			end

			function Col:Dropdown(o)
				o = o or {}
				local name = o.Name or "dropdown"
				local items = o.Items or { "none" }
				local def = o.Default or items[1]
				local cb = o.Callback or function() end
				local flag = o.Flag or (Tab.Name .. "_" .. name)

				local Card = Instance.new("Frame")
				Card.Size = UDim2.new(1, 0, 0, 44)
				Card.BackgroundColor3 = Theme.Card
				Card.BorderSizePixel = 0
				Card.Parent = Scroll
				Corner(Card, 10)
				Padding(Card, 14, 10, 0, 0)
				trackCard(name, Card)
				styleCard(Card)
				Card.ClipsDescendants = false

				Label(Card, name, 13, Theme.Text, Theme.FontMedium).Size = UDim2.new(0.45, 0, 1, 0)

				local Box = Instance.new("TextButton")
				Box.Size = UDim2.new(0.55, -4, 0, 28)
				Box.AnchorPoint = Vector2.new(1, 0.5)
				Box.Position = UDim2.new(1, 0, 0.5, 0)
				Box.BackgroundColor3 = Theme.Input
				Box.Text = tostring(def) .. "   v"
				Box.Font = Theme.Font
				Box.TextSize = 12
				Box.TextColor3 = Theme.Hint
				Box.AutoButtonColor = false
				Box.Parent = Card
				Corner(Box, 8)

				local List = Instance.new("Frame")
				List.Size = UDim2.new(0, 160, 0, 0)
				List.AnchorPoint = Vector2.new(1, 0)
				List.Position = UDim2.new(1, 0, 0, 40)
				List.BackgroundColor3 = Theme.Input
				List.Visible = false
				List.Parent = Card
				Corner(List, 8)
				Stroke(List, Theme.Stroke, 1)
				local LL = Instance.new("UIListLayout")
				LL.Padding = UDim.new(0, 2)
				LL.Parent = List
				Padding(List, 4, 4, 4, 4)

				local current = def
				local function close()
					List.Visible = false
					tween(List, { Size = UDim2.new(0, 160, 0, 0) }, 0.12)
				end
				local function apply(v, silent)
					current = v
					Box.Text = tostring(v) .. "   v"
					PastaSenseUI.Flags[flag] = { Value = v, Set = apply }
					if not silent then pcall(cb, v) end
				end
				for _, item in ipairs(items) do
					local B = Instance.new("TextButton")
					B.Size = UDim2.new(1, 0, 0, 26)
					B.BackgroundColor3 = Theme.Input
					B.Text = tostring(item)
					B.Font = Theme.Font
					B.TextSize = 12
					B.TextColor3 = Theme.Text
					B.AutoButtonColor = false
					B.Parent = List
					Corner(B, 6)
					B.MouseButton1Click:Connect(function() apply(item) close() end)
				end
				Box.MouseButton1Click:Connect(function()
					List.Visible = not List.Visible
					if List.Visible then
						tween(List, { Size = UDim2.new(0, 160, 0, #items * 28 + 8) }, 0.15)
					end
				end)
				registerFlag(flag, current, apply)
				pcall(cb, current)
				return { Set = apply, Get = function() return current end }
			end

			function Col:Button(o)
				o = o or {}
				local name = o.Name or "button"
				local cb = o.Callback or function() end
				local Card = Instance.new("TextButton")
				Card.Size = UDim2.new(1, 0, 0, 38)
				Card.BackgroundColor3 = Theme.Card
				Card.Text = name
				Card.Font = Theme.FontMedium
				Card.TextSize = 13
				Card.TextColor3 = Theme.Text
				Card.AutoButtonColor = false
				Card.Parent = Scroll
				Corner(Card, 10)
				trackCard(name, Card)
				styleCard(Card)
				Card.MouseButton1Click:Connect(function() pcall(cb) end)
				return Card
			end

			function Col:Keybind(o)
				o = o or {}
				local name = o.Name or "keybind"
				local def = o.Default or Enum.KeyCode.F
				local cb = o.Callback or function() end
				local flag = o.Flag or (Tab.Name .. "_" .. name)

				local Card = Instance.new("Frame")
				Card.Size = UDim2.new(1, 0, 0, 44)
				Card.BackgroundColor3 = Theme.Card
				Card.BorderSizePixel = 0
				Card.Parent = Scroll
				Corner(Card, 10)
				Padding(Card, 14, 10, 0, 0)
				trackCard(name, Card)
				styleCard(Card)

				Label(Card, name, 13, Theme.Text, Theme.FontMedium).Size = UDim2.new(0.55, 0, 1, 0)
				local KeyBtn = Instance.new("TextButton")
				KeyBtn.Size = UDim2.new(0, 70, 0, 26)
				KeyBtn.AnchorPoint = Vector2.new(1, 0.5)
				KeyBtn.Position = UDim2.new(1, 0, 0.5, 0)
				KeyBtn.BackgroundColor3 = Theme.Input
				KeyBtn.Text = def.Name
				KeyBtn.Font = Theme.Font
				KeyBtn.TextSize = 12
				KeyBtn.TextColor3 = Theme.Text
				KeyBtn.AutoButtonColor = false
				KeyBtn.Parent = Card
				Corner(KeyBtn, 6)

				local current = def
				local listening = false
				KeyBtn.MouseButton1Click:Connect(function()
					listening = true
					KeyBtn.Text = "..."
				end)
				UserInputService.InputBegan:Connect(function(input, gpe)
					if listening and input.KeyCode ~= Enum.KeyCode.Unknown then
						listening = false
						current = input.KeyCode
						KeyBtn.Text = current.Name
						PastaSenseUI.Flags[flag] = { Value = current, Set = function(v) current = v; KeyBtn.Text = v.Name end }
						pcall(cb, current)
					elseif not listening and not gpe and input.KeyCode == current then
						pcall(cb, current)
					end
				end)
				registerFlag(flag, current, function(v) current = v; KeyBtn.Text = v.Name end)
				return { Get = function() return current end }
			end

			function Col:Colorpicker(o)
				o = o or {}
				local name = o.Name or "color"
				local def = o.Default or Color3.fromRGB(255, 255, 255)
				local cb = o.Callback or function() end
				local flag = o.Flag or (Tab.Name .. "_" .. name)

				local Card = Instance.new("Frame")
				Card.Size = UDim2.new(1, 0, 0, 44)
				Card.BackgroundColor3 = Theme.Card
				Card.BorderSizePixel = 0
				Card.Parent = Scroll
				Corner(Card, 10)
				Padding(Card, 14, 10, 0, 0)
				trackCard(name, Card)
				styleCard(Card)

				Label(Card, name, 13, Theme.Text, Theme.FontMedium).Size = UDim2.new(1, -50, 1, 0)
				local Prev = Instance.new("TextButton")
				Prev.Size = UDim2.new(0, 28, 0, 28)
				Prev.AnchorPoint = Vector2.new(1, 0)
				Prev.Position = UDim2.new(1, 0, 0, 8)
				Prev.BackgroundColor3 = def
				Prev.Text = ""
				Prev.AutoButtonColor = false
				Prev.Parent = Card
				Corner(Prev, 8)

				local presets = {
					Color3.fromRGB(255,255,255), Color3.fromRGB(180,255,120),
					Color3.fromRGB(255,120,120), Color3.fromRGB(120,180,255),
					Color3.fromRGB(255,220,120), Color3.fromRGB(200,120,255),
					Color3.fromRGB(0,0,0), Color3.fromRGB(130,130,130),
				}

				local OPEN_H = 254
				local current = def
				local ch, cs, cv = def:ToHSV()

				-- Раскрывайка под карточкой (клик по превью)
				local Picker = Instance.new("Frame")
				Picker.Size = UDim2.new(1, 0, 0, 0)
				Picker.Position = UDim2.new(0, 0, 0, 44)
				Picker.BackgroundTransparency = 1
				Picker.Visible = false
				Picker.ClipsDescendants = true
				Picker.Parent = Card

				-- SV-квадрат: белый фон x градиент белый->hue, сверху чёрный градиент (value)
				local SV = Instance.new("TextButton")
				SV.Size = UDim2.new(1, 0, 0, 130)
				SV.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				SV.Text = ""
				SV.AutoButtonColor = false
				SV.Parent = Picker
				Corner(SV, 8)
				local SatGrad = Instance.new("UIGradient")
				SatGrad.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
					ColorSequenceKeypoint.new(1, Color3.fromHSV(ch, 1, 1)),
				})
				SatGrad.Parent = SV
				local Val = Instance.new("Frame")
				Val.Size = UDim2.new(1, 0, 1, 0)
				Val.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
				Val.BorderSizePixel = 0
				Val.Parent = SV
				Corner(Val, 8)
				local ValGrad = Instance.new("UIGradient")
				ValGrad.Rotation = 90
				ValGrad.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(1, 0),
				})
				ValGrad.Parent = Val
				local SVCursor = Instance.new("Frame")
				SVCursor.Size = UDim2.new(0, 12, 0, 12)
				SVCursor.AnchorPoint = Vector2.new(0.5, 0.5)
				SVCursor.BackgroundTransparency = 1
				SVCursor.Parent = SV
				Corner(SVCursor, 6)
				local SVRing = Instance.new("UIStroke")
				SVRing.Color = Color3.fromRGB(255, 255, 255)
				SVRing.Thickness = 2
				SVRing.Parent = SVCursor

				-- Полоса hue (радуга)
				local Hue = Instance.new("TextButton")
				Hue.Size = UDim2.new(1, 0, 0, 14)
				Hue.Position = UDim2.new(0, 0, 0, 138)
				Hue.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Hue.Text = ""
				Hue.AutoButtonColor = false
				Hue.Parent = Picker
				Corner(Hue, 7)
				local HueGrad = Instance.new("UIGradient")
				HueGrad.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
					ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17, 1, 1)),
					ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
					ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
					ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67, 1, 1)),
					ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
					ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1)),
				})
				HueGrad.Parent = Hue
				local HueCursor = Instance.new("Frame")
				HueCursor.Size = UDim2.new(0, 4, 0, 20)
				HueCursor.AnchorPoint = Vector2.new(0.5, 0.5)
				HueCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				HueCursor.BorderSizePixel = 0
				HueCursor.Parent = Hue
				Corner(HueCursor, 2)
				local HueRing = Instance.new("UIStroke")
				HueRing.Color = Color3.fromRGB(120, 120, 120)
				HueRing.Thickness = 1
				HueRing.Parent = HueCursor

				-- Пресеты + RGB-подпись
				local PresetRow = Instance.new("Frame")
				PresetRow.Size = UDim2.new(1, 0, 0, 24)
				PresetRow.Position = UDim2.new(0, 0, 0, 160)
				PresetRow.BackgroundTransparency = 1
				PresetRow.Parent = Picker
				local PresetLayout = Instance.new("UIListLayout")
				PresetLayout.FillDirection = Enum.FillDirection.Horizontal
				PresetLayout.Padding = UDim.new(0, 6)
				PresetLayout.Parent = PresetRow
				local RGBLabel = Label(Picker, "", 11, Theme.Hint, Theme.Font)
				RGBLabel.Size = UDim2.new(1, 0, 0, 14)
				RGBLabel.Position = UDim2.new(0, 0, 0, 188)

				local function refresh()
					Prev.BackgroundColor3 = current
					SatGrad.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
						ColorSequenceKeypoint.new(1, Color3.fromHSV(ch, 1, 1)),
					})
					SVCursor.Position = UDim2.new(cs, 0, 1 - cv, 0)
					HueCursor.Position = UDim2.new(ch, 0, 0.5, 0)
					local r = math.floor(current.R * 255 + 0.5)
					local g = math.floor(current.G * 255 + 0.5)
					local b = math.floor(current.B * 255 + 0.5)
					RGBLabel.Text = r .. ", " .. g .. ", " .. b
				end
				local function apply(v, silent)
					if typeof(v) ~= "Color3" then return end
					current = v
					ch, cs, cv = v:ToHSV()
					refresh()
					PastaSenseUI.Flags[flag] = { Value = v, Set = apply }
					if not silent then pcall(cb, v) end
				end
				for _, pc in ipairs(presets) do
					local PB = Instance.new("TextButton")
					PB.Size = UDim2.new(0, 24, 0, 24)
					PB.BackgroundColor3 = pc
					PB.Text = ""
					PB.AutoButtonColor = false
					PB.Parent = PresetRow
					Corner(PB, 6)
					PB.MouseButton1Click:Connect(function() apply(pc) end)
				end

				local function lockScroll(v)
					pcall(function() Scroll.ScrollingEnabled = not v end)
				end
				local function isPress(input)
					return input.UserInputType == Enum.UserInputType.MouseButton1
						or input.UserInputType == Enum.UserInputType.Touch
				end
				local function isMove(input)
					return input.UserInputType == Enum.UserInputType.MouseMovement
						or input.UserInputType == Enum.UserInputType.Touch
				end
				local dragSV, dragHue = false, false
				local function updateSV(input)
					local p, s = SV.AbsolutePosition, SV.AbsoluteSize
					local sx = math.clamp((input.Position.X - p.X) / math.max(s.X, 1), 0, 1)
					local sy = math.clamp((input.Position.Y - p.Y) / math.max(s.Y, 1), 0, 1)
					apply(Color3.fromHSV(ch, sx, 1 - sy))
				end
				local function updateHue(input)
					local p, s = Hue.AbsolutePosition, Hue.AbsoluteSize
					local t = math.clamp((input.Position.X - p.X) / math.max(s.X, 1), 0, 1)
					apply(Color3.fromHSV(t, cs, cv))
				end
				SV.InputBegan:Connect(function(input)
					if isPress(input) then dragSV = true lockScroll(true) updateSV(input) end
				end)
				Hue.InputBegan:Connect(function(input)
					if isPress(input) then dragHue = true lockScroll(true) updateHue(input) end
				end)
				UserInputService.InputEnded:Connect(function(input)
					if isPress(input) and (dragSV or dragHue) then
						dragSV, dragHue = false, false
						lockScroll(false)
					end
				end)
				UserInputService.InputChanged:Connect(function(input)
					if not isMove(input) then return end
					if dragSV then updateSV(input)
					elseif dragHue then updateHue(input) end
				end)

				local open = false
				Prev.MouseButton1Click:Connect(function()
					open = not open
					Picker.Visible = true
					if open then
						tween(Card, { Size = UDim2.new(1, 0, 0, OPEN_H) }, 0.18)
						tween(Picker, { Size = UDim2.new(1, 0, 0, OPEN_H - 44) }, 0.18)
					else
						tween(Card, { Size = UDim2.new(1, 0, 0, 44) }, 0.18)
						tween(Picker, { Size = UDim2.new(1, 0, 0, 0) }, 0.18)
						task.delay(0.18, function()
							if not open then Picker.Visible = false end
						end)
					end
				end)
				refresh()
				registerFlag(flag, current, apply)
				pcall(cb, current)
				return { Set = apply, Get = function() return current end }
			end

			function Col:Textbox(o)
				o = o or {}
				local name = o.Name or "textbox"
				local def = o.Default or ""
				local ph = o.Placeholder or name
				local cb = o.Callback or function() end
				local flag = o.Flag or (Tab.Name .. "_" .. name)

				local Card = Instance.new("Frame")
				Card.Size = UDim2.new(1, 0, 0, 44)
				Card.BackgroundColor3 = Theme.Card
				Card.BorderSizePixel = 0
				Card.Parent = Scroll
				Corner(Card, 10)
				Padding(Card, 14, 10, 8, 8)
				trackCard(name, Card)
				styleCard(Card)

				local Box = Instance.new("TextBox")
				Box.Size = UDim2.new(1, 0, 1, 0)
				Box.BackgroundColor3 = Theme.Input
				Box.Text = def
				Box.PlaceholderText = ph
				Box.Font = Theme.Font
				Box.TextSize = 12
				Box.TextColor3 = Theme.Text
				Box.PlaceholderColor3 = Theme.Hint
				Box.ClearTextOnFocus = false
				Box.Parent = Card
				Corner(Box, 6)
				Padding(Box, 8, 8, 0, 0)
				Box.FocusLost:Connect(function()
					PastaSenseUI.Flags[flag] = { Value = Box.Text, Set = function(v) Box.Text = v end }
					pcall(cb, Box.Text)
				end)
				registerFlag(flag, def, function(v) Box.Text = v end)
				return Box
			end

			return Col
		end

		Tab._left = makeColumn()
		Tab._right = makeColumn()

		function Tab:Columns()
			return self._left, self._right
		end

		-- weapon pill-bar like screenshot.
		-- items: {"pistols", ...} или {{Name="pistols", Icon="rbxassetid://..."}, ...}
		function Tab:AddWeaponBar(items, callback)
			WeaponBarHolder.Visible = true
			Columns.Size = UDim2.new(1, 0, 1, -46)
			Columns.Position = UDim2.new(0, 0, 0, 46)
			self._weaponCallback = callback
			local function paintWeapon(rec, active)
				rec.Btn.BackgroundColor3 = active and Theme.Accent or Theme.Sidebar
				local txtColor = active and Theme.AccentText or Theme.Hint
				if rec.Txt then rec.Txt.TextColor3 = txtColor end
				if rec.Btn and not rec.Txt then rec.Btn.TextColor3 = txtColor end
				if rec.Img then rec.Img.ImageColor3 = active and Theme.AccentText or Theme.Hint end
			end
			for i, item in ipairs(items) do
				local itemName, itemIcon
				if type(item) == "table" then
					itemName = item.Name or item[1]
					itemIcon = item.Icon or item.Image or item[2]
				else
					itemName = item
				end
				local hasImg = resolveIcon(itemIcon, itemName)
				local B = Instance.new("TextButton")
				B.Size = UDim2.new(0, hasImg and 140 or 110, 0, 28)
				B.BackgroundColor3 = (i == 1) and Theme.Accent or Theme.Sidebar
				B.AutoButtonColor = false
				B.Text = ""
				B.Parent = WeaponScroll
				Corner(B, 14)
				local rec = { Btn = B, Name = itemName }
				if hasImg then
					local Img = Instance.new("ImageLabel")
					Img.Size = UDim2.new(0, 20, 0, 20)
					Img.AnchorPoint = Vector2.new(0, 0.5)
					Img.Position = UDim2.new(0, 10, 0.5, 0)
					Img.BackgroundTransparency = 1
					Img.Image = hasImg
					Img.ScaleType = Enum.ScaleType.Fit
					Img.Parent = B
					rec.Img = Img
					local T = Label(B, tostring(itemName), 12, Theme.Hint, Theme.FontMedium)
					T.Size = UDim2.new(1, -38, 1, 0)
					T.Position = UDim2.new(0, 34, 0, 0)
					rec.Txt = T
				else
					B.Text = tostring(itemName)
					B.Font = Theme.FontMedium
					B.TextSize = 12
					B.TextColor3 = Theme.Hint
				end
				table.insert(self._weaponButtons, rec)
				paintWeapon(rec, i == 1)
				B.MouseButton1Click:Connect(function()
					for _, other in ipairs(self._weaponButtons) do
						paintWeapon(other, false)
					end
					paintWeapon(rec, true)
					if self._weaponCallback then pcall(self._weaponCallback, itemName) end
				end)
			end
			return self
		end

		function Tab:Section(title)
			return self._left:Section(title)
		end

		-- select logic
		local function select()
			for _, t in ipairs(Window._tabs) do
				t._page.Visible = false
				t._button.BackgroundColor3 = Theme.Sidebar
				paintTabIcon(t._icon, Theme.Hint)
				if t._name then t._name.TextColor3 = Theme.Hint end
				if t._stroke then t._stroke.Transparency = 1 end
				if t._bar then t._bar.Visible = false end
			end
			Page.Visible = true
			Btn.BackgroundColor3 = Theme.Card
			paintTabIcon(IconL, Theme.Text)
			NameL.TextColor3 = Theme.Text
			BtnStroke.Transparency = 0.6
			ActiveBar.Visible = true
			Window._activeTab = Tab
			CurrentTabLabel.Text = tabName
			SearchBox.Text = ""
			-- Анимация переключения: контент заезжает слева
			local targetY = WeaponBarHolder.Visible and 46 or 0
			Columns.Position = UDim2.new(0, 14, 0, targetY)
			tween(Columns, { Position = UDim2.new(0, 0, 0, targetY) }, 0.22)
		end
		-- Hover-подсветка кнопок сайдбара
		Btn.MouseEnter:Connect(function()
			if Window._activeTab ~= Tab then
				tween(Btn, { BackgroundColor3 = Theme.CardHover }, 0.12)
			end
		end)
		Btn.MouseLeave:Connect(function()
			if Window._activeTab ~= Tab then
				tween(Btn, { BackgroundColor3 = Theme.Sidebar }, 0.12)
			end
		end)
		Btn.MouseButton1Click:Connect(select)

		table.insert(Window._tabs, Tab)
		if #Window._tabs == 1 then select() end
		return Tab
	end

	---------------------------------------------------------------------------
	-- CONFIGS + THEME
	---------------------------------------------------------------------------
	function Window:SaveConfig(name)
		name = name or "default"
		local data = {}
		for flag, f in pairs(PastaSenseUI.Flags) do
			local v = f.Value
			if typeof(v) == "Color3" then
				data[flag] = { __type = "Color3", r = v.R, g = v.G, b = v.B }
			elseif typeof(v) == "EnumItem" then
				data[flag] = { __type = "KeyCode", name = v.Name }
			else
				data[flag] = v
			end
		end
		local json = HttpService:JSONEncode(data)
		if canWrite() then
			pcall(function()
				if typeof(makefolder) == "function" then makefolder("PastaSense") end
				if typeof(makefolder) == "function" then makefolder("PastaSense/configs") end
				writefile("PastaSense/configs/" .. tostring(name) .. ".json", json)
			end)
		end
		self._lastConfig = json
		return json
	end

	function Window:LoadConfig(name)
		local json = self._lastConfig
		if canWrite() and name then
			pcall(function()
				json = readfile("PastaSense/configs/" .. tostring(name) .. ".json")
			end)
		elseif type(name) == "string" and string.sub(name, 1, 1) == "{" then
			json = name
		end
		if not json then return false end
		local ok, data = pcall(HttpService.JSONDecode, HttpService, json)
		if not ok or type(data) ~= "table" then return false end
		for flag, v in pairs(data) do
			local f = PastaSenseUI.Flags[flag]
			if f and f.Set then
				local val = v
				if type(v) == "table" and v.__type == "Color3" then
					val = Color3.new(v.r, v.g, v.b)
				elseif type(v) == "table" and v.__type == "KeyCode" then
					val = Enum.KeyCode[v.name] or Enum.KeyCode.F
				end
				pcall(f.Set, val)
			end
		end
		return true
	end

	function Window:SetToggleKey(key)
		toggleKey = key
	end

	function PastaSenseUI:SetTheme(t)
		for k, v in pairs(t) do Theme[k] = v end
		-- live recolor basics
		Main.BackgroundColor3 = Theme.Background
		Sidebar.BackgroundColor3 = Theme.Sidebar
		SidebarFix.BackgroundColor3 = Theme.Sidebar
	end

	-- Предзагрузить иконки в workspace инжектора (папка PastaSenseUI/icons).
	-- map: { rage = "https://.../rage.png", ghost = "base64:...." }
	-- Возвращает таблицу { key = assetPath }. Без writefile/getcustomasset вернёт пустую.
	function PastaSenseUI:PreloadIcons(map)
		local out = {}
		if type(map) ~= "table" then return out end
		for key, v in pairs(map) do
			local asset
			if type(v) == "table" and type(v.Base64) == "string" then
				asset = base64WorkspaceIcon(key, v.Base64)
			elseif type(v) == "string" and string.sub(v, 1, 7) == "base64:" then
				asset = base64WorkspaceIcon(key, v)
			else
				asset = fetchWorkspaceIcon(key, v)
			end
			if asset then out[key] = asset end
		end
		return out
	end

	function PastaSenseUI:GetIcon(key, url)
		return fetchWorkspaceIcon(key, url)
	end

	PastaSenseUI.Base64Decode = base64Decode

	function Window:Destroy()
		pcall(function() if Blur then Blur:Destroy() end end)
		pcall(function() ScreenGui:Destroy() end)
	end

	-- Тост-уведомление справа снизу. Win:Notify("saved", 2500)
	function Window:Notify(text, ms)
		ms = ms or 2500
		local Toast = Instance.new("Frame")
		Toast.Size = UDim2.new(0, 260, 0, 46)
		Toast.AnchorPoint = Vector2.new(1, 1)
		Toast.Position = UDim2.new(1, -16, 1, 60)
		Toast.BackgroundColor3 = Theme.Card
		Toast.BorderSizePixel = 0
		Toast.Parent = ScreenGui
		Corner(Toast, 10)
		Stroke(Toast, Theme.Stroke, 1)
		Padding(Toast, 12, 12, 0, 0)
		local Bar = Instance.new("Frame")
		Bar.Size = UDim2.new(0, 3, 0, 22)
		Bar.AnchorPoint = Vector2.new(0, 0.5)
		Bar.Position = UDim2.new(0, 12, 0.5, 0)
		Bar.BackgroundColor3 = Theme.Accent
		Bar.BorderSizePixel = 0
		Bar.Parent = Toast
		Corner(Bar, 1)
		local TL = Label(Toast, tostring(text), 12, Theme.Text, Theme.FontMedium)
		TL.Size = UDim2.new(1, -26, 1, 0)
		TL.Position = UDim2.new(0, 22, 0, 0)
		TL.TextYAlignment = Enum.TextYAlignment.Center
		tween(Toast, { Position = UDim2.new(1, -16, 1, -16) }, 0.25)
		task.delay(ms / 1000, function()
			if not Toast.Parent then return end
			tween(Toast, { Position = UDim2.new(1, -16, 1, 60) }, 0.25)
			task.delay(0.25, function()
				pcall(function() Toast:Destroy() end)
			end)
		end)
		return Toast
	end

	getgenv = getgenv or (function() return _G end)
	pcall(function()
		if getgenv then
			getgenv().PastaUnload = function()
				pcall(function() ScreenGui:Destroy() end)
			end
		end
	end)

	return Window
end

return PastaSenseUI
