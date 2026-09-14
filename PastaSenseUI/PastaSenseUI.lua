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
PastaSenseUI.Version = "1.0.0"
PastaSenseUI.Flags = {} -- flag -> { Value = any, Set = fn }

-- // Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
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
	l.Font = font or Enum.Font.GothamMedium
	l.TextSize = size or 13
	l.TextColor3 = color or Theme.Text
	l.TextXAlignment = align or Enum.TextXAlignment.Left
	l.TextTruncate = Enum.TextTruncate.AtEnd
	l.Parent = parent
	return l
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

	-- Sidebar
	local Sidebar = Instance.new("Frame")
	Sidebar.Name = "Sidebar"
	Sidebar.Size = UDim2.new(0, 185, 1, 0)
	Sidebar.BackgroundColor3 = Theme.Sidebar
	Sidebar.BorderSizePixel = 0
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
	Dollar.Font = Enum.Font.GothamBold
	Dollar.TextSize = 16
	Dollar.TextColor3 = Theme.Text
	Dollar.Text = "$"
	Dollar.Parent = Sidebar

	local UserLabel = Label(Sidebar, userName, 13, Theme.Text, Enum.Font.GothamMedium)
	UserLabel.Position = UDim2.new(0, 42, 0, 14)
	UserLabel.Size = UDim2.new(1, -56, 0, 22)

	local PanelBtn = Instance.new("TextButton")
	PanelBtn.Size = UDim2.new(0, 26, 0, 26)
	PanelBtn.Position = UDim2.new(0, 198, 0, 12)
	PanelBtn.BackgroundColor3 = Theme.Card
	PanelBtn.Text = "[]"
	PanelBtn.Font = Enum.Font.GothamBold
	PanelBtn.TextSize = 12
	PanelBtn.TextColor3 = Theme.Hint
	PanelBtn.AutoButtonColor = false
	PanelBtn.Parent = Main
	Corner(PanelBtn, 6)

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

	local CurrentTabLabel = Label(Topbar, "rage", 13, Theme.Hint, Enum.Font.GothamMedium)
	CurrentTabLabel.Position = UDim2.new(0, 52, 0, 14)
	CurrentTabLabel.Size = UDim2.new(0, 200, 0, 22)

	local SearchBox = Instance.new("TextBox")
	SearchBox.Size = UDim2.new(0, 30, 0, 30)
	SearchBox.AnchorPoint = Vector2.new(1, 0)
	SearchBox.Position = UDim2.new(1, -10, 0, 10)
	SearchBox.BackgroundColor3 = Theme.Card
	SearchBox.Text = ""
	SearchBox.PlaceholderText = "Search"
	SearchBox.Font = Enum.Font.Gotham
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
		end
	end)
	PanelBtn.MouseButton1Click:Connect(function()
		Main.Visible = not Main.Visible
		-- panel button stays visible? keep main toggle simple:
		if not Main.Visible then
			-- show a tiny floating reopen via same key; keep button inside main so nothing to do
			Main.Visible = true
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
		local tabIcon = tabOpts.Icon or "*"

		-- Sidebar button
		local Btn = Instance.new("TextButton")
		Btn.Size = UDim2.new(1, 0, 0, 36)
		Btn.BackgroundColor3 = Theme.Sidebar
		Btn.AutoButtonColor = false
		Btn.Text = ""
		Btn.Parent = TabList
		Corner(Btn, 8)

		local IconL = Label(Btn, tabIcon, 14, Theme.Hint, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
		IconL.Size = UDim2.new(0, 30, 1, 0)
		IconL.Position = UDim2.new(0, 4, 0, 0)

		local NameL = Label(Btn, tabName, 13, Theme.Hint, Enum.Font.GothamMedium)
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
		Columns.Size = UDim2.new(1, 0, 1, -46)
		Columns.Position = UDim2.new(0, 0, 0, 46)
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
				local T = Label(Scroll, string.upper(title or "SECTION"), 11, Theme.Section, Enum.Font.GothamBold)
				T.Size = UDim2.new(1, 0, 0, 18)
				T.LayoutOrder = self._order
				table.insert(self._tab._elements, { Name = title, Frame = T, SectionTitle = T })
				return self
			end

			local function trackCard(name, frame)
				self._order = self._order + 1
				frame.LayoutOrder = self._order
				table.insert(self._tab._elements, { Name = name, Frame = frame })
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

				Label(Card, name, 13, Theme.Text, Enum.Font.GothamMedium).Size = UDim2.new(1, -70, 1, 0)

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

				local Top = Instance.new("Frame")
				Top.Size = UDim2.new(1, 0, 0, 20)
				Top.BackgroundTransparency = 1
				Top.Parent = Card
				local NL = Label(Top, name, 13, Theme.Text, Enum.Font.GothamMedium)
				NL.Size = UDim2.new(1, -60, 1, 0)
				local VL = Label(Top, tostring(def) .. suffix, 12, Theme.Hint, Enum.Font.Gotham, Enum.TextXAlignment.Right)
				VL.Size = UDim2.new(0, 60, 1, 0)
				VL.Position = UDim2.new(1, -60, 0, 0)

				local BarBg = Instance.new("TextButton")
				BarBg.Size = UDim2.new(1, 0, 0, 4)
				BarBg.Position = UDim2.new(0, 0, 0, 34)
				BarBg.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
				BarBg.Text = ""
				BarBg.AutoButtonColor = false
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

				local dragging = false
				local function updateFromInput(input)
					local absPos = BarBg.AbsolutePosition
					local absSize = BarBg.AbsoluteSize
					local t = math.clamp((input.Position.X - absPos.X) / math.max(absSize.X, 1), 0, 1)
					apply(min + (max - min) * t)
				end
				BarBg.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = true
						updateFromInput(input)
					end
				end)
				UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
				end)
				UserInputService.InputChanged:Connect(function(input)
					if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
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
				Card.ClipsDescendants = false

				Label(Card, name, 13, Theme.Text, Enum.Font.GothamMedium).Size = UDim2.new(0.45, 0, 1, 0)

				local Box = Instance.new("TextButton")
				Box.Size = UDim2.new(0.55, -4, 0, 28)
				Box.AnchorPoint = Vector2.new(1, 0.5)
				Box.Position = UDim2.new(1, 0, 0.5, 0)
				Box.BackgroundColor3 = Theme.Input
				Box.Text = tostring(def) .. "   v"
				Box.Font = Enum.Font.Gotham
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
					B.Font = Enum.Font.Gotham
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
				Card.Font = Enum.Font.GothamMedium
				Card.TextSize = 13
				Card.TextColor3 = Theme.Text
				Card.AutoButtonColor = false
				Card.Parent = Scroll
				Corner(Card, 10)
				trackCard(name, Card)
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

				Label(Card, name, 13, Theme.Text, Enum.Font.GothamMedium).Size = UDim2.new(0.55, 0, 1, 0)
				local KeyBtn = Instance.new("TextButton")
				KeyBtn.Size = UDim2.new(0, 70, 0, 26)
				KeyBtn.AnchorPoint = Vector2.new(1, 0.5)
				KeyBtn.Position = UDim2.new(1, 0, 0.5, 0)
				KeyBtn.BackgroundColor3 = Theme.Input
				KeyBtn.Text = def.Name
				KeyBtn.Font = Enum.Font.Gotham
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
						PastaSenseUI.Flags[flag] = { Value = current, Set = function(v) current = v KeyBtn.Text = v.Name end }
						pcall(cb, current)
					elseif not listening and not gpe and input.KeyCode == current then
						pcall(cb, current)
					end
				end)
				registerFlag(flag, current, function(v) current = v KeyBtn.Text = v.Name end)
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

				Label(Card, name, 13, Theme.Text, Enum.Font.GothamMedium).Size = UDim2.new(1, -50, 1, 0)
				local Prev = Instance.new("TextButton")
				Prev.Size = UDim2.new(0, 28, 0, 28)
				Prev.AnchorPoint = Vector2.new(1, 0.5)
				Prev.Position = UDim2.new(1, 0, 0.5, 0)
				Prev.BackgroundColor3 = def
				Prev.Text = ""
				Prev.AutoButtonColor = false
				Prev.Parent = Card
				Corner(Prev, 8)

				local presets = {
					Color3.fromRGB(255,255,255), Color3.fromRGB(180,255,120),
					Color3.fromRGB(255,120,120), Color3.fromRGB(120,180,255),
					Color3.fromRGB(255,220,120), Color3.fromRGB(200,120,255),
				}
				local idx = 1
				local function apply(v, silent)
					Prev.BackgroundColor3 = v
					PastaSenseUI.Flags[flag] = { Value = v, Set = apply }
					if not silent then pcall(cb, v) end
				end
				Prev.MouseButton1Click:Connect(function()
					idx = idx % #presets + 1
					apply(presets[idx])
				end)
				registerFlag(flag, def, apply)
				pcall(cb, def)
				return { Set = apply }
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

				local Box = Instance.new("TextBox")
				Box.Size = UDim2.new(1, 0, 1, 0)
				Box.BackgroundColor3 = Theme.Input
				Box.Text = def
				Box.PlaceholderText = ph
				Box.Font = Enum.Font.Gotham
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

		-- weapon pill-bar like screenshot
		function Tab:AddWeaponBar(items, callback)
			WeaponBarHolder.Visible = true
			Columns.Size = UDim2.new(1, 0, 1, -46)
			self._weaponCallback = callback
			for i, itemName in ipairs(items) do
				local B = Instance.new("TextButton")
				B.Size = UDim2.new(0, 110, 0, 28)
				B.BackgroundColor3 = (i == 1) and Theme.Accent or Theme.Sidebar
				B.Text = tostring(itemName)
				B.Font = Enum.Font.GothamMedium
				B.TextSize = 12
				B.TextColor3 = (i == 1) and Theme.AccentText or Theme.Hint
				B.AutoButtonColor = false
				B.Parent = WeaponScroll
				Corner(B, 14)
				table.insert(self._weaponButtons, B)
				B.MouseButton1Click:Connect(function()
					for _, other in ipairs(self._weaponButtons) do
						other.BackgroundColor3 = Theme.Sidebar
						other.TextColor3 = Theme.Hint
					end
					B.BackgroundColor3 = Theme.Accent
					B.TextColor3 = Theme.AccentText
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
				for _, ch in ipairs(t._button:GetChildren()) do
					if ch:IsA("TextLabel") then ch.TextColor3 = Theme.Hint end
				end
			end
			Page.Visible = true
			Btn.BackgroundColor3 = Theme.Card
			for _, ch in ipairs(Btn:GetChildren()) do
				if ch:IsA("TextLabel") then ch.TextColor3 = Theme.Text end
			end
			Window._activeTab = Tab
			CurrentTabLabel.Text = tabName
			SearchBox.Text = ""
		end
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

	function Window:Destroy()
		pcall(function() ScreenGui:Destroy() end)
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
