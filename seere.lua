-- Seere UI Library вЂ” РїРѕР»РЅРѕСЃС‚СЊСЋ РїРµСЂРµРїРёСЃР°РЅР° РґР»СЏ PastaSense
-- РўРѕ Р¶Рµ РІРёР·СѓР°Р»СЊРЅРѕРµ РѕС„РѕСЂРјР»РµРЅРёРµ, РёСЃРїСЂР°РІР»РµРЅРЅС‹Рµ Р±Р°РіРё, С‡РёСЃС‚С‹Р№ РєРѕРґ

local inputService = game:GetService("UserInputService")
local runService   = game:GetService("RunService")
local tweenService = game:GetService("TweenService")
local players      = game:GetService("Players")
local localPlayer  = players.LocalPlayer
local mouse        = localPlayer:GetMouse()

local menu = game:GetObjects("rbxassetid://12702460854")[1]
pcall(function() syn.protect_gui(menu) end)
menu.bg.Position = UDim2.new(0.5, -menu.bg.Size.X.Offset / 2, 0.5, -menu.bg.Size.Y.Offset / 2)
menu.Parent = (typeof(gethui) == "function" and gethui() or game:GetService("CoreGui"))
menu.bg.pre.Text = 'Pasta<font color="#9b96db">Sense</font>'

local library = {
    cheatname = "", ext = "", gamename = "",
    colorpicking = false,
    tabbuttons = {}, tabs = {}, options = {}, flags = {},
    scrolling = false,
    playing = false,
    multiZindex = 200,
    toInvis = {},
    libColor = Color3.fromRGB(155, 150, 219),
    disabledcolor = Color3.fromRGB(233, 0, 0),
    blacklisted = {
        Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D,
        Enum.UserInputType.MouseMovement,
    },
}
library.gui = menu

-- СѓРІРµРґРѕРјР»РµРЅРёСЏ С‡РµСЂРµР· Drawing (pcall вЂ” РЅРµ РІСЃРµ executors РїРѕРґРґРµСЂР¶РёРІР°СЋС‚)
pcall(function()
    library.notifyText = Drawing.new("Text")
    library.notifyText.Font = 2
    library.notifyText.Size = 13
    library.notifyText.Outline = true
    library.notifyText.Color = Color3.new(1, 1, 1)
    library.notifyText.Position = Vector2.new(10, 60)
end)

-- в”Ђв”Ђ draggable в”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђ
local function draggable(frame)
    local dragging, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragging = input
        end
    end)
    inputService.InputChanged:Connect(function(input)
        if input == dragging and not library.colorpicking then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end
draggable(menu.bg)

-- в”Ђв”Ђ tab system в”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђ
local tabholder = menu.bg.bg.bg.bg.main.group
local tabviewer = menu.bg.bg.bg.bg.tabbuttons

local keyNames = {
    [Enum.KeyCode.LeftAlt] = "LALT", [Enum.KeyCode.RightAlt] = "RALT",
    [Enum.KeyCode.LeftControl] = "LCTRL", [Enum.KeyCode.RightControl] = "RCTRL",
    [Enum.KeyCode.LeftShift] = "LSHIFT", [Enum.KeyCode.RightShift] = "RSHIFT",
    [Enum.KeyCode.Underscore] = "_", [Enum.KeyCode.Minus] = "-",
    [Enum.KeyCode.Plus] = "+", [Enum.KeyCode.Period] = ".",
    [Enum.KeyCode.Slash] = "/", [Enum.KeyCode.BackSlash] = "\\",
    [Enum.KeyCode.Question] = "?",
    [Enum.UserInputType.MouseButton1] = "MB1",
    [Enum.UserInputType.MouseButton2] = "MB2",
    [Enum.UserInputType.MouseButton3] = "MB3",
}

-- в”Ђв”Ђ library helpers в”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђ
function library:Tween(...)
    tweenService:Create(...):Play()
end

function library:notify(text)
    local nt = library.notifyText
    if not nt then return end
    if library.playing then return end
    library.playing = true
    nt.Text = text
    nt.Transparency = 0
    nt.Visible = true
    for i = 0, 1, 0.1 do task.wait() nt.Transparency = i end
    task.spawn(function()
        task.wait(3)
        for i = 1, 0, -0.1 do task.wait() nt.Transparency = i end
        library.playing = false
        nt.Visible = false
    end)
end

inputService.InputEnded:Connect(function(key)
    if key.KeyCode == (library.flags.MenuBind or Enum.KeyCode.RightShift) then
        menu.Enabled = not menu.Enabled
        library.scrolling = false
        library.colorpicking = false
        for _, v in next, library.toInvis do v.Visible = false end
    end
end)

function library:addTab(name)
    local newTab = tabholder.tab:Clone()
    local newButton = tabviewer.button:Clone()

    table.insert(library.tabs, newTab)
    newTab.Parent = tabholder
    newTab.Visible = false

    table.insert(library.tabbuttons, newButton)
    newButton.Parent = tabviewer
    newButton.Modal = true
    newButton.Visible = true
    newButton.text.Text = name
    newButton.MouseButton1Click:Connect(function()
        for _, v in next, library.tabs do v.Visible = (v == newTab) end
        for _, v in next, library.toInvis do v.Visible = false end
        for _, v in next, library.tabbuttons do
            local active = (v == newButton)
            if active then
                v.element.Visible = true
                library:Tween(v.element, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0 })
                v.text.TextColor3 = Color3.fromRGB(244, 244, 244)
            else
                library:Tween(v.element, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 })
                v.text.TextColor3 = Color3.fromRGB(144, 144, 144)
            end
        end
    end)

    local groupCount = 0
    local tab = {}

    function tab:createGroup(pos, groupname)
        groupCount -= 1

        local groupbox = Instance.new("Frame")
        groupbox.Parent = newTab[pos]
        groupbox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        groupbox.BorderColor3 = Color3.fromRGB(30, 30, 30)
        groupbox.BorderSizePixel = 2
        groupbox.Size = UDim2.new(0, 211, 0, 8)
        groupbox.ZIndex = groupCount

        local grouper = Instance.new("Frame")
        grouper.Parent = groupbox
        grouper.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        grouper.BorderColor3 = Color3.fromRGB(0, 0, 0)
        grouper.Size = UDim2.new(1, 0, 1, 0)

        local layout = Instance.new("UIListLayout")
        layout.Parent = grouper
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.SortOrder = Enum.SortOrder.LayoutOrder

        local pad = Instance.new("UIPadding")
        pad.Parent = grouper
        pad.PaddingBottom = UDim.new(0, 4)
        pad.PaddingTop = UDim.new(0, 7)

        local element = Instance.new("Frame")
        element.Name = "element"
        element.Parent = groupbox
        element.BackgroundColor3 = library.libColor
        element.BorderSizePixel = 0
        element.Size = UDim2.new(1, 0, 0, 1)

        local title = Instance.new("TextLabel")
        title.Parent = groupbox
        title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        title.BackgroundTransparency = 1
        title.BorderSizePixel = 0
        title.Position = UDim2.new(0, 17, 0, 0)
        title.ZIndex = 2
        title.Font = Enum.Font.Code
        title.Text = groupname or ""
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.TextSize = 13
        title.TextStrokeTransparency = 0
        title.TextXAlignment = Enum.TextXAlignment.Left

        local backframe = Instance.new("Frame")
        backframe.Parent = groupbox
        backframe.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        backframe.BorderSizePixel = 0
        backframe.Position = UDim2.new(0, 10, 0, -2)
        backframe.Size = UDim2.new(0, 13 + title.TextBounds.X, 0, 3)

        -- в”Ђв”Ђ group methods в”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђ
        local group = {}

        function group:addToggle(args)
            if not args.flag and args.text then args.flag = args.text end
            if not args.flag then return warn("missing flag on toggle") end
            groupbox.Size += UDim2.new(0, 0, 0, 20)
            library.multiZindex -= 1

            local holder = Instance.new("Frame")
            holder.Parent = grouper
            holder.BackgroundTransparency = 1
            holder.BorderSizePixel = 0
            holder.Size = UDim2.new(1, 0, 0, 20)
            holder.ZIndex = library.multiZindex

            local outer = Instance.new("Frame")
            outer.Parent = holder
            outer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            outer.BorderSizePixel = 3
            outer.Position = UDim2.new(0.03, 0, 0.272, 0)
            outer.Size = UDim2.new(0, 10, 0, 10)

            local mid = Instance.new("Frame")
            mid.Parent = outer
            mid.BackgroundColor3 = Color3.fromRGB(69, 23, 255)
            mid.BorderColor3 = Color3.fromRGB(30, 30, 30)
            mid.BorderSizePixel = 2
            mid.Size = UDim2.new(1, 0, 1, 0)

            local front = Instance.new("Frame")
            front.Parent = mid
            front.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            front.BorderSizePixel = 0
            front.Size = UDim2.new(1, 0, 1, 0)

            local label = Instance.new("TextLabel")
            label.Parent = holder
            label.BackgroundTransparency = 1
            label.Position = UDim2.new(0, 22, 0, 0)
            label.Size = UDim2.new(0, 0, 1, 2)
            label.Font = Enum.Font.Code
            label.Text = args.text or args.flag
            label.TextColor3 = Color3.fromRGB(155, 155, 155)
            label.TextSize = 13
            label.TextStrokeTransparency = 0
            label.TextXAlignment = Enum.TextXAlignment.Left

            local hitbox = Instance.new("TextButton")
            hitbox.Parent = holder
            hitbox.BackgroundTransparency = 1
            hitbox.BorderSizePixel = 0
            hitbox.Size = UDim2.new(1, 0, 1, 0)
            hitbox.Text = ""

            if args.disabled then
                hitbox.Visible = false
                label.TextColor3 = library.disabledcolor
                return
            end

            local state = false
            local function toggleState(newState)
                state = newState
                library.flags[args.flag] = state
                front.BackgroundColor3 = state and library.libColor or Color3.fromRGB(15, 15, 15)
                label.TextColor3 = state and Color3.fromRGB(244, 244, 244) or Color3.fromRGB(144, 144, 144)
                if args.callback then args.callback(state) end
            end

            hitbox.MouseButton1Click:Connect(function()
                state = not state
                library.flags[args.flag] = state
                mid.BorderColor3 = Color3.fromRGB(30, 30, 30)
                front.BackgroundColor3 = state and library.libColor or Color3.fromRGB(15, 15, 15)
                label.TextColor3 = state and Color3.fromRGB(244, 244, 244) or Color3.fromRGB(144, 144, 144)
                if args.callback then args.callback(state) end
            end)
            hitbox.MouseEnter:Connect(function() mid.BorderColor3 = library.libColor end)
            hitbox.MouseLeave:Connect(function() mid.BorderColor3 = Color3.fromRGB(30, 30, 30) end)

            library.flags[args.flag] = false
            library.options[args.flag] = { type = "toggle", changeState = toggleState, skipflag = args.skipflag, oldargs = args }

            -- РІРѕР·РІСЂР°С‰Р°РµРј РѕР±СЉРµРєС‚ toggle РґР»СЏ С†РµРїРѕС‡РєРё (keybind / colorpicker)
            local ret = {}
            function ret:addKeybind(kbArgs)
                if not kbArgs.flag then return warn("missing flag on keybind") end
                local waiting = false

                local kFrame = Instance.new("Frame")
                kFrame.Parent = holder
                kFrame.BackgroundTransparency = 1
                kFrame.BorderSizePixel = 0
                kFrame.Position = UDim2.new(0.72, 4, 0.272, 0)
                kFrame.Size = UDim2.new(0, 51, 0, 10)

                local kBtn = Instance.new("TextButton")
                kBtn.Parent = kFrame
                kBtn.BackgroundTransparency = 1
                kBtn.BorderSizePixel = 0
                kBtn.Position = UDim2.new(-0.271, 0, 0, 0)
                kBtn.Size = UDim2.new(1.271, 0, 1, 0)
                kBtn.Font = Enum.Font.Code
                kBtn.Text = ""
                kBtn.TextColor3 = Color3.fromRGB(155, 155, 155)
                kBtn.TextSize = 13
                kBtn.TextStrokeTransparency = 0
                kBtn.TextXAlignment = Enum.TextXAlignment.Right

                local function updateKB(val)
                    if library.colorpicking then return end
                    library.flags[kbArgs.flag] = val
                    kBtn.Text = keyNames[val] or val.Name
                end

                inputService.InputBegan:Connect(function(input)
                    local key = input.KeyCode == Enum.KeyCode.Unknown and input.UserInputType or input.KeyCode
                    if waiting then
                        if not table.find(library.blacklisted, key) then
                            waiting = false
                            library.flags[kbArgs.flag] = key
                            kBtn.Text = keyNames[key] or key.Name
                            kBtn.TextColor3 = Color3.fromRGB(155, 155, 155)
                        end
                    end
                    if not waiting and key == library.flags[kbArgs.flag] and kbArgs.callback then
                        kbArgs.callback()
                    end
                end)

                kBtn.MouseButton1Click:Connect(function()
                    if library.colorpicking then return end
                    library.flags[kbArgs.flag] = Enum.KeyCode.Unknown
                    kBtn.Text = "--"
                    kBtn.TextColor3 = library.libColor
                    waiting = true
                end)

                library.flags[kbArgs.flag] = Enum.KeyCode.Unknown
                library.options[kbArgs.flag] = { type = "keybind", changeState = updateKB, skipflag = kbArgs.skipflag, oldargs = kbArgs }
                updateKB(kbArgs.key or Enum.KeyCode.Unknown)
            end

            function ret:addColorpicker(cpArgs)
                if not cpArgs.flag and cpArgs.text then cpArgs.flag = cpArgs.text end
                if not cpArgs.flag then return warn("missing flag on colorpicker") end
                library.multiZindex -= 1

                local cpHolder = Instance.new("Frame")
                cpHolder.Parent = holder
                cpHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                cpHolder.BorderColor3 = Color3.fromRGB(0, 0, 0)
                cpHolder.BorderSizePixel = 3
                cpHolder.Position = cpArgs.second and UDim2.new(0.72, 4, 0.272, 0) or UDim2.new(0.86, 4, 0.272, 0)
                cpHolder.Size = UDim2.new(0, 20, 0, 10)

                local cpMid = Instance.new("Frame")
                cpMid.Parent = cpHolder
                cpMid.BackgroundColor3 = Color3.fromRGB(69, 23, 255)
                cpMid.BorderColor3 = Color3.fromRGB(30, 30, 30)
                cpMid.BorderSizePixel = 2
                cpMid.Size = UDim2.new(1, 0, 1, 0)

                local cpFront = Instance.new("Frame")
                cpFront.Parent = cpMid
                cpFront.BackgroundColor3 = Color3.fromRGB(240, 142, 214)
                cpFront.BorderSizePixel = 0
                cpFront.Size = UDim2.new(1, 0, 1, 0)

                local cpBtn = Instance.new("TextButton")
                cpBtn.Parent = cpFront
                cpBtn.BackgroundTransparency = 1
                cpBtn.Size = UDim2.new(1, 0, 1, 0)
                cpBtn.Text = ""

                -- popup
                local popup = Instance.new("Frame")
                popup.Name = "colorFrame"
                popup.Parent = holder
                popup.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                popup.BorderColor3 = Color3.fromRGB(0, 0, 0)
                popup.BorderSizePixel = 2
                popup.Position = UDim2.new(0.101, 0, 0.75, 0)
                popup.Size = UDim2.new(0, 137, 0, 128)
                popup.Visible = false

                local popupInner = Instance.new("Frame")
                popupInner.Parent = popup
                popupInner.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                popupInner.BorderColor3 = Color3.fromRGB(60, 60, 60)
                popupInner.Size = UDim2.new(1, 0, 1, 0)

                -- saturation picker
                local satFrame = Instance.new("Frame")
                satFrame.Parent = popupInner
                satFrame.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
                satFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
                satFrame.BorderSizePixel = 2
                satFrame.Position = UDim2.new(-0.093, 18, -0.06, 30)
                satFrame.Size = UDim2.new(0, 100, 0, 100)

                local satInner = Instance.new("Frame")
                satInner.Parent = satFrame
                satInner.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
                satInner.Size = UDim2.new(1, 0, 1, 0)
                satInner.ZIndex = 6

                local satImage = Instance.new("ImageLabel")
                satImage.Parent = satInner
                satImage.BackgroundColor3 = Color3.fromRGB(232, 0, 255)
                satImage.BorderSizePixel = 0
                satImage.Size = UDim2.new(1, 0, 1, 0)
                satImage.ZIndex = 104
                satImage.Image = "rbxassetid://2615689005"

                -- hue strip
                local hueFrame = Instance.new("Frame")
                hueFrame.Parent = popupInner
                hueFrame.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
                hueFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
                hueFrame.BorderSizePixel = 2
                hueFrame.Position = UDim2.new(0.711, 14, -0.06, 30)
                hueFrame.Size = UDim2.new(0, 20, 0, 100)

                local hueInner = Instance.new("Frame")
                hueInner.Parent = hueFrame
                hueInner.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
                hueInner.Size = UDim2.new(1, 0, 1, 0)
                hueInner.ZIndex = 6

                local hueImage = Instance.new("ImageLabel")
                hueImage.Parent = hueInner
                hueImage.BackgroundColor3 = Color3.fromRGB(255, 0, 178)
                hueImage.BorderSizePixel = 0
                hueImage.Size = UDim2.new(1, 0, 1, 0)
                hueImage.ZIndex = 104
                hueImage.Image = "rbxassetid://2615692420"

                -- title bar
                local titleBar = Instance.new("Frame")
                titleBar.Parent = popup
                titleBar.BackgroundTransparency = 1
                titleBar.BorderColor3 = Color3.fromRGB(60, 60, 60)
                titleBar.BorderSizePixel = 2
                titleBar.Position = UDim2.new(0.028, 0, 0, 2)
                titleBar.Size = UDim2.new(0, 129, 0, 14)
                titleBar.ZIndex = 5

                local titleBtn = Instance.new("TextButton")
                titleBtn.Parent = titleBar
                titleBtn.BackgroundTransparency = 1
                titleBtn.BorderSizePixel = 0
                titleBtn.Size = UDim2.new(1, 0, 1, 0)
                titleBtn.ZIndex = 5
                titleBtn.Font = Enum.Font.Code
                titleBtn.Text = cpArgs.text or cpArgs.flag
                titleBtn.TextColor3 = Color3.fromRGB(100, 100, 100)
                titleBtn.TextSize = 14
                titleBtn.TextStrokeTransparency = 0
                titleBtn.MouseButton1Click:Connect(function() popup.Visible = false end)

                cpBtn.MouseButton1Click:Connect(function()
                    popup.Visible = not popup.Visible
                    cpMid.BorderColor3 = Color3.fromRGB(30, 30, 30)
                end)
                cpBtn.MouseEnter:Connect(function() cpMid.BorderColor3 = library.libColor end)
                cpBtn.MouseLeave:Connect(function() cpMid.BorderColor3 = Color3.fromRGB(30, 30, 30) end)

                local function updateCP(value, fake)
                    if typeof(value) == "table" then value = fake end
                    library.flags[cpArgs.flag] = value
                    cpFront.BackgroundColor3 = value
                    if cpArgs.callback then cpArgs.callback(value) end
                end

                local white, black = Color3.new(1, 1, 1), Color3.new(0, 0, 0)
                local hueColors = {
                    Color3.new(1, 0, 0), Color3.new(1, 1, 0), Color3.new(0, 1, 0),
                    Color3.new(0, 1, 1), Color3.new(0, 0, 1), Color3.new(1, 0, 1),
                    Color3.new(1, 0, 0),
                }
                local hb = runService.Heartbeat
                local pickerX, pickerY, hueY = 0, 0, 0
                local oldPX, oldPY = 0, 0

                hueImage.MouseEnter:Connect(function()
                    local conn
                    conn = hueImage.InputBegan:Connect(function(input)
                        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
                        while hb:Wait() and inputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                            library.colorpicking = true
                            local pct = (hueY - hueImage.AbsolutePosition.Y) / hueImage.AbsoluteSize.Y
                            local num = math.clamp(math.floor(pct * 7 + 0.5), 1, 7)
                            local c = white:lerp(satImage.BackgroundColor3, oldPX):lerp(black, oldPY)
                            satImage.BackgroundColor3 = hueColors[num]:lerp(hueColors[math.min(num + 1, 7)], (pct * 7 + 0.5) - num)
                            updateCP(c)
                        end
                        library.colorpicking = false
                    end)
                    local leave
                    leave = hueImage.MouseLeave:Connect(function() conn:Disconnect() leave:Disconnect() end)
                end)

                satImage.MouseEnter:Connect(function()
                    local conn
                    conn = satImage.InputBegan:Connect(function(input)
                        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
                        while hb:Wait() and inputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                            library.colorpicking = true
                            local xPct = (pickerX - satImage.AbsolutePosition.X) / satImage.AbsoluteSize.X
                            local yPct = (pickerY - satImage.AbsolutePosition.Y) / satImage.AbsoluteSize.Y
                            local c = white:lerp(satImage.BackgroundColor3, xPct):lerp(black, yPct)
                            updateCP(c)
                            oldPX, oldPY = xPct, yPct
                        end
                        library.colorpicking = false
                    end)
                    local leave
                    leave = satImage.MouseLeave:Connect(function() conn:Disconnect() leave:Disconnect() end)
                end)

                hueImage.MouseMoved:Connect(function(_, y) hueY = y end)
                satImage.MouseMoved:Connect(function(x, y) pickerX, pickerY = x, y end)

                table.insert(library.toInvis, popup)
                library.flags[cpArgs.flag] = Color3.new(1, 1, 1)
                library.options[cpArgs.flag] = { type = "colorpicker", changeState = updateCP, skipflag = cpArgs.skipflag, oldargs = cpArgs }
                updateCP(cpArgs.color or Color3.new(1, 1, 1))
            end

            return ret
        end

        function group:addButton(args)
            if not args.callback or not args.text then return warn("missing args on button") end
            groupbox.Size += UDim2.new(0, 0, 0, 22)

            local wrap = Instance.new("Frame")
            wrap.Parent = grouper
            wrap.BackgroundTransparency = 1
            wrap.BorderSizePixel = 0
            wrap.Size = UDim2.new(1, 0, 0, 21)

            local bg = Instance.new("Frame")
            bg.Parent = wrap
            bg.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            bg.BorderColor3 = Color3.fromRGB(0, 0, 0)
            bg.BorderSizePixel = 2
            bg.Position = UDim2.new(0.02, -1, 0, 0)
            bg.Size = UDim2.new(0, 205, 0, 15)

            local main = Instance.new("Frame")
            main.Parent = bg
            main.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            main.BorderColor3 = Color3.fromRGB(60, 60, 60)
            main.Size = UDim2.new(1, 0, 1, 0)

            local grad = Instance.new("UIGradient")
            grad.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(105, 105, 105)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(121, 121, 121)),
            }
            grad.Rotation = 90
            grad.Parent = main

            local btn = Instance.new("TextButton")
            btn.Parent = main
            btn.BackgroundTransparency = 1
            btn.BorderSizePixel = 0
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.Font = Enum.Font.Code
            btn.Text = args.text
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.TextSize = 13
            btn.TextStrokeTransparency = 0

            btn.MouseButton1Click:Connect(function()
                if not library.colorpicking then args.callback() end
            end)
            btn.MouseEnter:Connect(function() main.BorderColor3 = library.libColor end)
            btn.MouseLeave:Connect(function() main.BorderColor3 = Color3.fromRGB(60, 60, 60) end)
        end

        function group:addSlider(args, sub)
            if not args.flag or not args.max then return warn("missing args on slider") end
            groupbox.Size += UDim2.new(0, 0, 0, 30)

            local wrap = Instance.new("Frame")
            wrap.Parent = grouper
            wrap.BackgroundTransparency = 1
            wrap.BorderSizePixel = 0
            wrap.Size = UDim2.new(1, 0, 0, 30)

            local label = Instance.new("TextLabel")
            label.Parent = wrap
            label.BackgroundTransparency = 1
            label.Position = UDim2.new(0.03, -1, 0, 7)
            label.ZIndex = 2
            label.Font = Enum.Font.Code
            label.Text = args.text or args.flag
            label.TextColor3 = Color3.fromRGB(244, 244, 244)
            label.TextSize = 13
            label.TextStrokeTransparency = 0
            label.TextXAlignment = Enum.TextXAlignment.Left

            local bg = Instance.new("Frame")
            bg.Parent = wrap
            bg.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            bg.BorderColor3 = Color3.fromRGB(0, 0, 0)
            bg.BorderSizePixel = 2
            bg.Position = UDim2.new(0.02, -1, 0, 16)
            bg.Size = UDim2.new(0, 205, 0, 10)

            local main = Instance.new("Frame")
            main.Parent = bg
            main.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            main.BorderColor3 = Color3.fromRGB(50, 50, 50)
            main.Size = UDim2.new(1, 0, 1, 0)

            local grad = Instance.new("UIGradient")
            grad.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(105, 105, 105)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(121, 121, 121)),
            }
            grad.Rotation = 90
            grad.Parent = main

            local fill = Instance.new("Frame")
            fill.Parent = main
            fill.BackgroundColor3 = library.libColor
            fill.BackgroundTransparency = 0.2
            fill.BorderColor3 = Color3.fromRGB(60, 60, 60)
            fill.BorderSizePixel = 0
            fill.Size = UDim2.new(0, 1, 1, 0)

            local valText = Instance.new("TextLabel")
            valText.Parent = main
            valText.BackgroundTransparency = 1
            valText.Position = UDim2.new(0.5, 0, 0.5, 0)
            valText.Font = Enum.Font.Code
            valText.Text = ""
            valText.TextColor3 = Color3.fromRGB(255, 255, 255)
            valText.TextSize = 14
            valText.TextStrokeTransparency = 0

            local hitbox = Instance.new("TextButton")
            hitbox.Parent = main
            hitbox.BackgroundTransparency = 1
            hitbox.Size = UDim2.new(1, 0, 1, 0)
            hitbox.Text = ""

            local entered, scrolling = false, false

            local function updateVal(value)
                if library.colorpicking then return end
                value = math.clamp(value, args.min, args.max)
                fill:TweenSize(UDim2.new((value - args.min) / (args.max - args.min), 0, 1, 0), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.01)
                valText.Text = math.floor(value) .. (sub or "")
                library.flags[args.flag] = value
                if args.callback then args.callback(value) end
            end

            local function doScroll()
                if scrolling or library.scrolling or not newTab.Visible or library.colorpicking then return end
                while inputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and menu.Enabled do
                    runService.RenderStepped:Wait()
                    library.scrolling = true
                    scrolling = true
                    valText.TextColor3 = Color3.fromRGB(255, 255, 255)
                    local value = args.min + ((mouse.X - hitbox.AbsolutePosition.X) / hitbox.AbsoluteSize.X) * (args.max - args.min)
                    updateVal(math.floor(value))
                end
                if not menu.Enabled then entered = false end
                scrolling = false
                library.scrolling = false
            end

            hitbox.MouseEnter:Connect(function()
                if library.colorpicking or scrolling or entered then return end
                entered = true
                main.BorderColor3 = library.libColor
                while entered do task.wait() doScroll() end
            end)
            hitbox.MouseLeave:Connect(function()
                entered = false
                main.BorderColor3 = Color3.fromRGB(60, 60, 60)
            end)

            library.flags[args.flag] = 0
            library.options[args.flag] = { type = "slider", changeState = updateVal, skipflag = args.skipflag, oldargs = args }
            updateVal(args.value or 0)
        end

        function group:addList(args)
            if not args.flag or not args.values then return warn("missing args on list") end
            groupbox.Size += UDim2.new(0, 0, 0, 35)
            library.multiZindex -= 1

            local wrap = Instance.new("Frame")
            wrap.Parent = grouper
            wrap.BackgroundTransparency = 1
            wrap.BorderSizePixel = 0
            wrap.Size = UDim2.new(1, 0, 0, 35)
            wrap.ZIndex = library.multiZindex

            local label = Instance.new("TextLabel")
            label.Parent = wrap
            label.BackgroundTransparency = 1
            label.Position = UDim2.new(0.03, -1, 0, 7)
            label.ZIndex = 2
            label.Font = Enum.Font.Code
            label.Text = args.text or args.flag
            label.TextColor3 = Color3.fromRGB(244, 244, 244)
            label.TextSize = 13
            label.TextStrokeTransparency = 0
            label.TextXAlignment = Enum.TextXAlignment.Left

            local bg = Instance.new("Frame")
            bg.Parent = wrap
            bg.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            bg.BorderColor3 = Color3.fromRGB(0, 0, 0)
            bg.BorderSizePixel = 2
            bg.Position = UDim2.new(0.02, -1, 0, 16)
            bg.Size = UDim2.new(0, 205, 0, 15)

            local main = Instance.new("ScrollingFrame")
            main.Parent = bg
            main.Active = true
            main.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            main.BorderColor3 = Color3.fromRGB(60, 60, 60)
            main.Size = UDim2.new(1, 0, 1, 0)
            main.CanvasSize = UDim2.new(0, 0, 0, 0)
            main.ScrollBarThickness = 0

            local grad = Instance.new("UIGradient")
            grad.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(105, 105, 105)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(121, 121, 121)),
            }
            grad.Rotation = 90
            grad.Parent = main

            local dropBtn = Instance.new("TextButton")
            dropBtn.Parent = main
            dropBtn.BackgroundTransparency = 1
            dropBtn.Size = UDim2.new(1, 0, 1, 0)
            dropBtn.Text = ""

            local triangle = Instance.new("ImageLabel")
            triangle.Parent = main
            triangle.BackgroundTransparency = 1
            triangle.BorderSizePixel = 0
            triangle.Position = UDim2.new(1, -11, 0.5, -3)
            triangle.Size = UDim2.new(0, 7, 0, 6)
            triangle.ZIndex = 3
            triangle.Image = "rbxassetid://8532000591"

            local valText = Instance.new("TextLabel")
            valText.Parent = main
            valText.BackgroundTransparency = 1
            valText.Position = UDim2.new(0, 2, 0, 7)
            valText.ZIndex = 2
            valText.Font = Enum.Font.Code
            valText.Text = ""
            valText.TextColor3 = Color3.fromRGB(244, 244, 244)
            valText.TextSize = 13
            valText.TextStrokeTransparency = 0
            valText.TextXAlignment = Enum.TextXAlignment.Left

            -- dropdown holder
            local dropdown = Instance.new("Frame")
            dropdown.Name = "frame"
            dropdown.Parent = wrap
            dropdown.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            dropdown.BorderColor3 = Color3.fromRGB(0, 0, 0)
            dropdown.BorderSizePixel = 2
            dropdown.Position = UDim2.new(0.03, -1, 0.605, 15)
            dropdown.Size = UDim2.new(0, 203, 0, 0)
            dropdown.Visible = false
            dropdown.ZIndex = library.multiZindex

            local dHolder = Instance.new("Frame")
            dHolder.Name = "holder"
            dHolder.Parent = dropdown
            dHolder.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            dHolder.BorderColor3 = Color3.fromRGB(60, 60, 60)
            dHolder.Size = UDim2.new(1, 0, 1, 0)

            local dLayout = Instance.new("UIListLayout")
            dLayout.Parent = dHolder
            dLayout.SortOrder = Enum.SortOrder.LayoutOrder

            local function updateList(value)
                if value == nil then valText.Text = "nil" return end
                if not table.find(library.options[args.flag].values, value) then
                    value = library.options[args.flag].values[1]
                end
                library.flags[args.flag] = value
                for _, child in next, dHolder:GetChildren() do
                    if child.ClassName ~= "Frame" then continue end
                    child.off.TextColor3 = (child.Name == value) and Color3.new(1, 1, 1) or Color3.new(0.65, 0.65, 0.65)
                end
                dropdown.Visible = false
                valText.Text = value
                if args.callback then args.callback(value) end
            end

            local function refreshList(tbl)
                for _, child in next, dHolder:GetChildren() do
                    if child.ClassName == "Frame" then child:Destroy() end
                end
                dropdown.Size = UDim2.new(0, 203, 0, 0)
                for _, v in pairs(tbl) do
                    dropdown.Size += UDim2.new(0, 0, 0, 20)
                    local item = Instance.new("Frame")
                    item.Name = v
                    item.Parent = dHolder
                    item.BackgroundTransparency = 1
                    item.Size = UDim2.new(1, 0, 0, 20)

                    local iBtn = Instance.new("TextButton")
                    iBtn.Parent = item
                    iBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                    iBtn.BackgroundTransparency = 0.85
                    iBtn.BorderSizePixel = 0
                    iBtn.Size = UDim2.new(1, 0, 1, 0)
                    iBtn.Text = ""

                    local iTxt = Instance.new("TextLabel")
                    iTxt.Name = "off"
                    iTxt.Parent = item
                    iTxt.BackgroundTransparency = 1
                    iTxt.Position = UDim2.new(0, 4, 0, 0)
                    iTxt.Size = UDim2.new(0, 0, 1, 0)
                    iTxt.Font = Enum.Font.Code
                    iTxt.Text = v
                    iTxt.TextColor3 = Color3.new(1, 1, 1)
                    iTxt.TextSize = 14
                    iTxt.TextStrokeTransparency = 0
                    iTxt.TextXAlignment = Enum.TextXAlignment.Left

                    iBtn.MouseButton1Click:Connect(function() updateList(v) end)
                end
                library.options[args.flag].values = tbl
                updateList(table.find(tbl, library.flags[args.flag]) and library.flags[args.flag] or tbl[1])
            end

            dropBtn.MouseButton1Click:Connect(function()
                if not library.colorpicking then dropdown.Visible = not dropdown.Visible end
            end)
            dropBtn.MouseEnter:Connect(function() main.BorderColor3 = library.libColor end)
            dropBtn.MouseLeave:Connect(function() main.BorderColor3 = Color3.fromRGB(60, 60, 60) end)

            table.insert(library.toInvis, dropdown)
            library.flags[args.flag] = ""
            library.options[args.flag] = { type = "list", changeState = updateList, values = args.values, refresh = refreshList, skipflag = args.skipflag, oldargs = args }
            refreshList(args.values)
            updateList(args.value or args.values[1])
        end

        function group:addColorpicker(args)
            if not args.flag then return warn("missing flag on colorpicker") end
            groupbox.Size += UDim2.new(0, 0, 0, 20)
            library.multiZindex -= 1

            local cpWrap = Instance.new("Frame")
            cpWrap.Parent = grouper
            cpWrap.BackgroundTransparency = 1
            cpWrap.BorderSizePixel = 0
            cpWrap.Size = UDim2.new(1, 0, 0, 20)
            cpWrap.ZIndex = library.multiZindex

            local cpLabel = Instance.new("TextLabel")
            cpLabel.Parent = cpWrap
            cpLabel.BackgroundTransparency = 1
            cpLabel.Position = UDim2.new(0.02, -1, 0, 10)
            cpLabel.Font = Enum.Font.Code
            cpLabel.Text = args.text or args.flag
            cpLabel.TextColor3 = Color3.fromRGB(244, 244, 244)
            cpLabel.TextSize = 13
            cpLabel.TextStrokeTransparency = 0
            cpLabel.TextXAlignment = Enum.TextXAlignment.Left

            local cpOuter = Instance.new("Frame")
            cpOuter.Parent = cpWrap
            cpOuter.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            cpOuter.BorderColor3 = Color3.fromRGB(0, 0, 0)
            cpOuter.BorderSizePixel = 3
            cpOuter.Position = UDim2.new(0.86, 4, 0.272, 0)
            cpOuter.Size = UDim2.new(0, 20, 0, 10)

            local cpMid = Instance.new("Frame")
            cpMid.Parent = cpOuter
            cpMid.BackgroundColor3 = Color3.fromRGB(69, 23, 255)
            cpMid.BorderColor3 = Color3.fromRGB(30, 30, 30)
            cpMid.BorderSizePixel = 2
            cpMid.Size = UDim2.new(1, 0, 1, 0)

            local cpFront = Instance.new("Frame")
            cpFront.Parent = cpMid
            cpFront.BackgroundColor3 = Color3.fromRGB(240, 142, 214)
            cpFront.BorderSizePixel = 0
            cpFront.Size = UDim2.new(1, 0, 1, 0)

            local cpBtn = Instance.new("TextButton")
            cpBtn.Parent = cpWrap
            cpBtn.BackgroundTransparency = 1
            cpBtn.Size = UDim2.new(0, 202, 0, 22)
            cpBtn.Text = ""
            cpBtn.ZIndex = args.ontop and library.multiZindex or (library.multiZindex - 1)

            -- popup (same as toggle colorpicker)
            local popup = Instance.new("Frame")
            popup.Parent = cpWrap
            popup.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            popup.BorderColor3 = Color3.fromRGB(0, 0, 0)
            popup.BorderSizePixel = 2
            popup.Position = UDim2.new(0.101, 0, 0.75, 0)
            popup.Size = UDim2.new(0, 137, 0, 128)
            popup.Visible = false

            local popupBg = Instance.new("Frame")
            popupBg.Parent = popup
            popupBg.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            popupBg.BorderColor3 = Color3.fromRGB(60, 60, 60)
            popupBg.Size = UDim2.new(1, 0, 1, 0)

            local satFrame = Instance.new("Frame")
            satFrame.Parent = popupBg
            satFrame.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
            satFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
            satFrame.BorderSizePixel = 2
            satFrame.Position = UDim2.new(-0.093, 18, -0.06, 30)
            satFrame.Size = UDim2.new(0, 100, 0, 100)

            local satInner = Instance.new("Frame")
            satInner.Parent = satFrame
            satInner.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
            satInner.Size = UDim2.new(1, 0, 1, 0)
            satInner.ZIndex = 6

            local satImg = Instance.new("ImageLabel")
            satImg.Parent = satInner
            satImg.BackgroundColor3 = Color3.fromRGB(232, 0, 255)
            satImg.BorderSizePixel = 0
            satImg.Size = UDim2.new(1, 0, 1, 0)
            satImg.ZIndex = 104
            satImg.Image = "rbxassetid://2615689005"

            local hueFrame = Instance.new("Frame")
            hueFrame.Parent = popupBg
            hueFrame.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
            hueFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
            hueFrame.BorderSizePixel = 2
            hueFrame.Position = UDim2.new(0.711, 14, -0.06, 30)
            hueFrame.Size = UDim2.new(0, 20, 0, 100)

            local hueInner = Instance.new("Frame")
            hueInner.Parent = hueFrame
            hueInner.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
            hueInner.Size = UDim2.new(1, 0, 1, 0)
            hueInner.ZIndex = 6

            local hueImg = Instance.new("ImageLabel")
            hueImg.Parent = hueInner
            hueImg.BackgroundColor3 = Color3.fromRGB(255, 0, 178)
            hueImg.BorderSizePixel = 0
            hueImg.Size = UDim2.new(1, 0, 1, 0)
            hueImg.ZIndex = 104
            hueImg.Image = "rbxassetid://2615692420"

            local titleBar = Instance.new("Frame")
            titleBar.Parent = popup
            titleBar.BackgroundTransparency = 1
            titleBar.BorderColor3 = Color3.fromRGB(60, 60, 60)
            titleBar.BorderSizePixel = 2
            titleBar.Position = UDim2.new(0.028, 0, 0, 2)
            titleBar.Size = UDim2.new(0, 129, 0, 14)
            titleBar.ZIndex = 5

            local titleBtn = Instance.new("TextButton")
            titleBtn.Parent = titleBar
            titleBtn.BackgroundTransparency = 1
            titleBtn.BorderSizePixel = 0
            titleBtn.Size = UDim2.new(1, 0, 1, 0)
            titleBtn.ZIndex = 5
            titleBtn.Font = Enum.Font.Code
            titleBtn.Text = args.text or args.flag
            titleBtn.TextColor3 = Color3.fromRGB(100, 100, 100)
            titleBtn.TextSize = 14
            titleBtn.TextStrokeTransparency = 0
            titleBtn.MouseButton1Click:Connect(function() popup.Visible = false end)

            cpBtn.MouseButton1Click:Connect(function()
                popup.Visible = not popup.Visible
                cpMid.BorderColor3 = Color3.fromRGB(30, 30, 30)
            end)
            cpBtn.MouseEnter:Connect(function() cpMid.BorderColor3 = library.libColor end)
            cpBtn.MouseLeave:Connect(function() cpMid.BorderColor3 = Color3.fromRGB(30, 30, 30) end)

            local function updateVal(value, fake)
                if typeof(value) == "table" then value = fake end
                library.flags[args.flag] = value
                cpFront.BackgroundColor3 = value
                if args.callback then args.callback(value) end
            end

            local white, black = Color3.new(1, 1, 1), Color3.new(0, 0, 0)
            local hueColors = {
                Color3.new(1, 0, 0), Color3.new(1, 1, 0), Color3.new(0, 1, 0),
                Color3.new(0, 1, 1), Color3.new(0, 0, 1), Color3.new(1, 0, 1),
                Color3.new(1, 0, 0),
            }
            local hb = runService.Heartbeat
            local pickerX, pickerY, hueY = 0, 0, 0
            local oldPX, oldPY = 0, 0

            hueImg.MouseEnter:Connect(function()
                local conn
                conn = hueImg.InputBegan:Connect(function(input)
                    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
                    while hb:Wait() and inputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                        library.colorpicking = true
                        local pct = (hueY - hueImg.AbsolutePosition.Y) / hueImg.AbsoluteSize.Y
                        local num = math.clamp(math.floor(pct * 7 + 0.5), 1, 7)
                        local c = white:lerp(satImg.BackgroundColor3, oldPX):lerp(black, oldPY)
                        satImg.BackgroundColor3 = hueColors[num]:lerp(hueColors[math.min(num + 1, 7)], (pct * 7 + 0.5) - num)
                        updateVal(c)
                    end
                    library.colorpicking = false
                end)
                local leave
                leave = hueImg.MouseLeave:Connect(function() conn:Disconnect() leave:Disconnect() end)
            end)

            satImg.MouseEnter:Connect(function()
                local conn
                conn = satImg.InputBegan:Connect(function(input)
                    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
                    while hb:Wait() and inputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                        library.colorpicking = true
                        local xPct = (pickerX - satImg.AbsolutePosition.X) / satImg.AbsoluteSize.X
                        local yPct = (pickerY - satImg.AbsolutePosition.Y) / satImg.AbsoluteSize.Y
                        local c = white:lerp(satImg.BackgroundColor3, xPct):lerp(black, yPct)
                        updateVal(c)
                        oldPX, oldPY = xPct, yPct
                    end
                    library.colorpicking = false
                end)
                local leave
                leave = satImg.MouseLeave:Connect(function() conn:Disconnect() leave:Disconnect() end)
            end)

            hueImg.MouseMoved:Connect(function(_, y) hueY = y end)
            satImg.MouseMoved:Connect(function(x, y) pickerX, pickerY = x, y end)

            table.insert(library.toInvis, popup)
            library.flags[args.flag] = Color3.new(1, 1, 1)
            library.options[args.flag] = { type = "colorpicker", changeState = updateVal, skipflag = args.skipflag, oldargs = args }
            updateVal(args.color or Color3.new(1, 1, 1))
        end

        function group:addKeybind(args)
            if not args.flag then return warn("missing flag on keybind") end
            groupbox.Size += UDim2.new(0, 0, 0, 20)
            local waiting = false

            local wrap = Instance.new("Frame")
            wrap.Parent = grouper
            wrap.BackgroundTransparency = 1
            wrap.BorderSizePixel = 0
            wrap.Size = UDim2.new(1, 0, 0, 20)

            local label = Instance.new("TextLabel")
            label.Parent = wrap
            label.BackgroundTransparency = 1
            label.Position = UDim2.new(0.02, -1, 0, 10)
            label.Font = Enum.Font.Code
            label.Text = args.text or args.flag
            label.TextColor3 = Color3.fromRGB(244, 244, 244)
            label.TextSize = 13
            label.TextStrokeTransparency = 0
            label.TextXAlignment = Enum.TextXAlignment.Left

            local kBtn = Instance.new("TextButton")
            kBtn.Parent = wrap
            kBtn.BackgroundTransparency = 1
            kBtn.BorderSizePixel = 0
            kBtn.Position = UDim2.new(0, 0, 0, 0)
            kBtn.Size = UDim2.new(0.02, 0, 1, 0)
            kBtn.Font = Enum.Font.Code
            kBtn.Text = "--"
            kBtn.TextColor3 = Color3.fromRGB(155, 155, 155)
            kBtn.TextSize = 13
            kBtn.TextStrokeTransparency = 0
            kBtn.TextXAlignment = Enum.TextXAlignment.Right

            local function updateKB(val)
                if library.colorpicking then return end
                library.flags[args.flag] = val
                kBtn.Text = keyNames[val] or val.Name
            end

            inputService.InputBegan:Connect(function(input)
                local key = input.KeyCode == Enum.KeyCode.Unknown and input.UserInputType or input.KeyCode
                if waiting then
                    if not table.find(library.blacklisted, key) then
                        waiting = false
                        library.flags[args.flag] = key
                        kBtn.Text = keyNames[key] or key.Name
                        kBtn.TextColor3 = Color3.fromRGB(155, 155, 155)
                    end
                end
                if not waiting and key == library.flags[args.flag] and args.callback then
                    args.callback()
                end
            end)

            kBtn.MouseButton1Click:Connect(function()
                if library.colorpicking then return end
                library.flags[args.flag] = Enum.KeyCode.Unknown
                kBtn.Text = "..."
                kBtn.TextColor3 = Color3.new(0.2, 0.2, 0.2)
                waiting = true
            end)

            library.flags[args.flag] = Enum.KeyCode.Unknown
            library.options[args.flag] = { type = "keybind", changeState = updateKB, skipflag = args.skipflag, oldargs = args }
            updateKB(args.key or Enum.KeyCode.Unknown)
        end

        function group:addTextbox(args)
            if not args.flag then return warn("missing flag on textbox") end
            groupbox.Size += UDim2.new(0, 0, 0, 35)

            local wrap = Instance.new("Frame")
            wrap.Parent = grouper
            wrap.BackgroundTransparency = 1
            wrap.BorderSizePixel = 0
            wrap.Size = UDim2.new(1, 0, 0, 35)
            wrap.ZIndex = 10

            local label = Instance.new("TextLabel")
            label.Parent = wrap
            label.BackgroundTransparency = 1
            label.Position = UDim2.new(0.03, -1, 0, 7)
            label.ZIndex = 2
            label.Font = Enum.Font.Code
            label.Text = args.text or args.flag
            label.TextColor3 = Color3.fromRGB(244, 244, 244)
            label.TextSize = 13
            label.TextStrokeTransparency = 0
            label.TextXAlignment = Enum.TextXAlignment.Left

            local bg = Instance.new("Frame")
            bg.Parent = wrap
            bg.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            bg.BorderColor3 = Color3.fromRGB(0, 0, 0)
            bg.BorderSizePixel = 2
            bg.Position = UDim2.new(0.02, -1, 0, 16)
            bg.Size = UDim2.new(0, 205, 0, 15)

            local main = Instance.new("ScrollingFrame")
            main.Parent = bg
            main.Active = true
            main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            main.BorderColor3 = Color3.fromRGB(30, 30, 30)
            main.Size = UDim2.new(1, 0, 1, 0)
            main.CanvasSize = UDim2.new(0, 0, 0, 0)
            main.ScrollBarThickness = 0

            local grad = Instance.new("UIGradient")
            grad.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(105, 105, 105)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(121, 121, 121)),
            }
            grad.Rotation = 90
            grad.Parent = main

            local box = Instance.new("TextBox")
            box.Parent = main
            box.BackgroundTransparency = 1
            box.Selectable = false
            box.Size = UDim2.new(1, 0, 1, 0)
            box.Font = Enum.Font.Code
            box.Text = args.value or ""
            box.TextColor3 = Color3.fromRGB(255, 255, 255)
            box.TextSize = 13
            box.TextStrokeTransparency = 0
            box.TextXAlignment = Enum.TextXAlignment.Left

            box:GetPropertyChangedSignal("Text"):Connect(function()
                if library.colorpicking then return end
                library.flags[args.flag] = box.Text
                args.value = box.Text
                if args.callback then args.callback() end
            end)

            library.flags[args.flag] = args.value or ""
            library.options[args.flag] = { type = "textbox", changeState = function(text) box.Text = text end, skipflag = args.skipflag, oldargs = args }
        end

        function group:addDivider()
            groupbox.Size += UDim2.new(0, 0, 0, 10)

            local wrap = Instance.new("Frame")
            wrap.Parent = grouper
            wrap.BackgroundTransparency = 1
            wrap.BorderSizePixel = 0
            wrap.Size = UDim2.new(0, 202, 0, 10)

            local bg = Instance.new("Frame")
            bg.Parent = wrap
            bg.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            bg.BorderColor3 = Color3.fromRGB(0, 0, 0)
            bg.BorderSizePixel = 2
            bg.Position = UDim2.new(0.02, 0, 0, 4)
            bg.Size = UDim2.new(0, 191, 0, 1)

            local main = Instance.new("Frame")
            main.Parent = bg
            main.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            main.BorderColor3 = Color3.fromRGB(60, 60, 60)
            main.Size = UDim2.new(0, 191, 0, 1)
        end

        return group, groupbox
    end

    return tab
end

-- в”Ђв”Ђ config helpers (РЅРµ РёСЃРїРѕР»СЊР·СѓСЋС‚СЃСЏ Р±РµР· filesystem, РЅРѕ API СЃРѕРІРјРµСЃС‚РёРј) в”Ђв”Ђ
function library:createConfig()
    local name = library.flags["config_name"]
    if name == "" then return library:notify("Put a name goofy") end
    local jig = {}
    for i, v in next, library.flags do
        if library.options[i] and library.options[i].skipflag then continue end
        if typeof(v) == "Color3" then jig[i] = { v.R, v.G, v.B }
        elseif typeof(v) == "EnumItem" then jig[i] = { string.split(tostring(v), ".")[2], string.split(tostring(v), ".")[3] }
        else jig[i] = v end
    end
    pcall(function() writefile("OsirisCFGS/" .. name .. ".cfg", game:GetService("HttpService"):JSONEncode(jig)) end)
    library:notify("Created " .. name .. ".cfg")
end

function library:loadConfig()
    local name = library.flags["selected_config"]
    local ok, raw = pcall(readfile, "OsirisCFGS/" .. name .. ".cfg")
    if not ok then return library:notify("Config not found!") end
    local config = game:GetService("HttpService"):JSONDecode(raw)
    for i, v in next, library.options do
        task.spawn(function()
            pcall(function()
                if config[i] then
                    if v.type == "colorpicker" then v.changeState(Color3.new(config[i][1], config[i][2], config[i][3]))
                    elseif v.type == "keybind" then v.changeState(Enum[config[i][1]][config[i][2]])
                    elseif config[i] ~= library.flags[i] then v.changeState(config[i]) end
                else
                    if v.type == "toggle" then v.changeState(false)
                    elseif v.type == "slider" then v.changeState(v.oldargs.value or 0)
                    elseif v.type == "colorpicker" then v.changeState(v.oldargs.color or Color3.new(1, 1, 1)) end
                end
            end)
        end)
    end
    library:notify("Loaded " .. name .. ".cfg")
end

return library
