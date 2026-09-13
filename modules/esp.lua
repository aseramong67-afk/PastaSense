
local ESP = {}

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

function ESP.New(S, ESPFlags, connections)
    local M = {}
    M.players = {}
    -- gethui есть не везде — фолбэк на CoreGui
    local guiParent = nil
    pcall(function()
        local gh = nil
        if type(_G) == "table" then
            gh = rawget(_G, "gethui")
        end
        if type(gh) == "function" then
            guiParent = gh()
        end
    end)
    if guiParent == nil then
        guiParent = game:GetService("CoreGui")
    end
    M.screengui = Instance.new("ScreenGui", guiParent)
    M.cache = Instance.new("ScreenGui", guiParent)
    M.connections = {}

    M.screengui.IgnoreGuiInset = true
    M.screengui.Name = "\0"
    M.cache.Enabled = false

    local fonts = {}; do
        -- кастомный шрифт требует isfile/writefile/getcustomasset + сеть.
        -- если чего-то нет — молча откатываемся на встроенный, ESP всё равно работает
        local ok = pcall(function()
            local isfileFn, writefileFn, delfileFn, gcaFn = nil, nil, nil, nil
            if type(_G) == "table" then
                isfileFn = rawget(_G, "isfile")
                writefileFn = rawget(_G, "writefile")
                delfileFn = rawget(_G, "delfile")
                gcaFn = rawget(_G, "getcustomasset")
            end
            assert(type(isfileFn) == "function", "no isfile")
            assert(type(writefileFn) == "function", "no writefile")
            assert(type(gcaFn) == "function", "no getcustomasset")
            local function Register_Font(Name, Weight, Style, Asset)
                if not isfileFn(Asset.Id) then
                    writefileFn(Asset.Id, Asset.Font)
                end
                if isfileFn(Name .. ".font") and type(delfileFn) == "function" then
                    delfileFn(Name .. ".font")
                end
                local Data = {
                    name = Name,
                    faces = {
                        {
                            name = "Normal",
                            weight = Weight,
                            style = Style,
                            assetId = gcaFn(Asset.Id),
                        },
                    },
                }
                writefileFn(Name .. ".font", HttpService:JSONEncode(Data))
                return gcaFn(Name .. ".font")
            end
            local ProggyTiny = Register_Font("adwdawdwadadwadawdawdawdawd!", 100, "Normal", {
                Id = "ProggyTinyyyy.ttf",
                Font = game:HttpGet("https://github.com/i77lhm/storage/raw/refs/heads/main/fonts/ProggyTiny.ttf"),
            })
            fonts = {
                main = Font.new(ProggyTiny, Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            }
        end)
        if not ok or not fonts.main then
            pcall(function()
                fonts = { main = Font.fromEnum(Enum.Font.Code) }
            end)
        end
    end

    local function curCamera() return workspace.CurrentCamera end

    local vec2 = Vector2.new
    local vec3 = Vector3.new
    local dim2 = UDim2.new
    local dim = UDim.new
    local dim_offset = UDim2.fromOffset
    local rgb = Color3.fromRGB
    local esp = M

    function esp:get_screen_pos(world_position)
        local viewport_size = curCamera().ViewportSize
        local local_position = curCamera().CFrame:pointToObjectSpace(world_position)
        local aspect_ratio = viewport_size.x / viewport_size.y
        local half_height = -local_position.z * math.tan(math.rad(curCamera().FieldOfView / 2))
        local half_width = aspect_ratio * half_height
        local far_plane_corner = Vector3.new(-half_width, half_height, local_position.z)
        local relative_position = local_position - far_plane_corner
        local screen_x = relative_position.x / (half_width * 2)
        local screen_y = -relative_position.y / (half_height * 2)
        local is_on_screen = -local_position.z > 0 and screen_x >= 0 and screen_x <= 1 and screen_y >= 0 and screen_y <= 1
        return Vector3.new(screen_x * viewport_size.x, screen_y * viewport_size.y, -local_position.z), is_on_screen
    end

    function esp:box_solve(torso)
        if not torso then return nil, nil, nil end
        local ViewportTop = torso.Position + (torso.CFrame.UpVector * 1.8) + curCamera().CFrame.UpVector
        local ViewportBottom = torso.Position - (torso.CFrame.UpVector * 2.5) - curCamera().CFrame.UpVector
        local Distance = (torso.Position - curCamera().CFrame.p).Magnitude
        local Top, TopIsRendered = esp:get_screen_pos(ViewportTop)
        local Bottom, BottomIsRendered = esp:get_screen_pos(ViewportBottom)
        local Width = math.max(math.floor(math.abs(Top.X - Bottom.X)), 3)
        local Height = math.max(math.floor(math.max(math.abs(Bottom.Y - Top.Y), Width / 2)), 3)
        local BoxSize = Vector2.new(math.floor(math.max(Height / 1.5, Width)), Height)
        local BoxPosition = Vector2.new(math.floor(Top.X * 0.5 + Bottom.X * 0.5 - BoxSize.X * 0.5), math.floor(math.min(Top.Y, Bottom.Y)))
        return BoxSize, BoxPosition, TopIsRendered, Distance
    end

    function esp:create(instance, options)
        local ins = Instance.new(instance)
        for prop, value in options do
            if value ~= nil then
                ins[prop] = value
            end
        end
        return ins
    end

    local function buildName(player)
        local d = ESPFlags["Name_DisplayName"]
        local u = ESPFlags["Name_UserName"]
        if d and u then
            return string.format("%s (@%s)", player.DisplayName, player.Name)
        elseif d then
            return player.DisplayName
        elseif u then
            return "@" .. player.Name
        else
            return ""
        end
    end

    function esp:create_object(player)
        esp[player.Name] = { objects = {}, info = { character = nil, humanoid = nil, rootpart = nil } }
        local data = esp[player.Name]
        local objects = data.objects

        objects["holder"] = esp:create("Frame", {
            Parent = esp.screengui;
            Name = "\0";
            BackgroundTransparency = 1;
            Position = dim2(0, 0, 0, 0);
            Visible = false;
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(0, 0, 0, 0);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255);
        })

        objects["box_outline"] = esp:create("UIStroke", {
            Parent = (ESPFlags["Boxes"] and ESPFlags["Box_Type"] ~= "Corner" and objects["holder"]) or esp.cache;
            LineJoinMode = Enum.LineJoinMode.Miter;
        })

        objects["name"] = esp:create("TextLabel", {
            FontFace = fonts.main;
            Parent = objects["holder"];
            TextColor3 = ESPFlags["Name_Color"].Color;
            BorderColor3 = rgb(0, 0, 0);
            Text = buildName(player);
            Name = "\0";
            TextStrokeTransparency = 0;
            AnchorPoint = vec2(0, 1);
            Size = dim2(1, 0, 0, 0);
            BackgroundTransparency = 1;
            Position = dim2(0, 0, 0, -5);
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.Y;
            TextSize = 9;
        })

        objects["box_handler"] = esp:create("Frame", {
            Parent = (ESPFlags["Boxes"] and ESPFlags["Box_Type"] ~= "Corner" and objects["holder"]) or esp.cache;
            Name = "\0";
            BackgroundTransparency = 1;
            Position = dim2(0, 1, 0, 1);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, -2, 1, -2);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255);
        })

        objects["box_color"] = esp:create("UIStroke", {
            Color = rgb(255, 255, 255);
            LineJoinMode = Enum.LineJoinMode.Miter;
            Name = "\0";
            Parent = objects["box_handler"];
        })

        objects["outline"] = esp:create("Frame", {
            Parent = objects["box_handler"];
            Name = "\0";
            BackgroundTransparency = 1;
            Position = dim2(0, 1, 0, 1);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, -2, 1, -2);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255);
        })

        esp:create("UIStroke", {
            Parent = objects["outline"];
            LineJoinMode = Enum.LineJoinMode.Miter;
        })

        -- Corner Boxes
        objects["corners"] = esp:create("Frame", {
            Visible = true;
            BorderColor3 = rgb(0, 0, 0);
            Parent = ESPFlags["Boxes"] and ESPFlags["Box_Type"] == "Corner" and objects["holder"] or esp.cache;
            BackgroundTransparency = 1;
            Position = dim2(0, -1, 0, 2);
            Name = "\0";
            Size = dim2(1, 0, 1, 0);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255);
        })

        objects["1"] = esp:create("Frame", {
            Parent = objects["corners"];
            Name = "line";
            Position = dim2(0, 0, 0, -2);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(0.4, 0, 0, 3);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(0, 0, 0);
        })
        esp:create("Frame", {
            Parent = objects["1"];
            Position = dim2(0, 1, 0, 1);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, -2, 1, -2);
            BorderSizePixel = 0;
            BackgroundColor3 = ESPFlags["Box_Color"].Color;
        })

        objects["2"] = esp:create("Frame", {
            Parent = objects["corners"];
            Name = "line";
            Position = dim2(0, 0, 0, 1);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(0, 3, 0.25, 0);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(0, 0, 0);
        })
        esp:create("Frame", {
            Parent = objects["2"];
            Position = dim2(0, 1, 0, -2);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, -2, 1, 1);
            BorderSizePixel = 0;
            BackgroundColor3 = ESPFlags["Box_Color"].Color;
        })

        objects["3"] = esp:create("Frame", {
            AnchorPoint = vec2(1, 0);
            Parent = objects["corners"];
            Name = "line";
            Position = dim2(1, 0, 0, -2);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(0.4, 0, 0, 3);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(0, 0, 0);
        })
        esp:create("Frame", {
            Parent = objects["3"];
            Position = dim2(0, 1, 0, 1);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, -2, 1, -2);
            BorderSizePixel = 0;
            BackgroundColor3 = ESPFlags["Box_Color"].Color;
        })

        objects["4"] = esp:create("Frame", {
            AnchorPoint = vec2(1, 0);
            Parent = objects["corners"];
            Name = "line";
            Position = dim2(1, 0, 0, 1);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(0, 3, 0.25, 0);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(0, 0, 0);
        })
        esp:create("Frame", {
            Parent = objects["4"];
            Position = dim2(0, 1, 0, -2);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, -2, 1, 1);
            BorderSizePixel = 0;
            BackgroundColor3 = ESPFlags["Box_Color"].Color;
        })

        objects["5"] = esp:create("Frame", {
            AnchorPoint = vec2(0, 1);
            Parent = objects["corners"];
            Name = "line";
            Position = dim2(0, 0, 1, -2);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(0.4, 0, 0, 3);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(0, 0, 0);
        })
        esp:create("Frame", {
            Parent = objects["5"];
            Position = dim2(0, 1, 0, 1);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, -2, 1, -2);
            BorderSizePixel = 0;
            BackgroundColor3 = ESPFlags["Box_Color"].Color;
        })

        objects["6"] = esp:create("Frame", {
            BorderColor3 = rgb(0, 0, 0);
            Rotation = 180;
            Parent = objects["corners"];
            Name = "line";
            Position = dim2(0, 0, 1, -5);
            AnchorPoint = vec2(0, 1);
            Size = dim2(0, 3, 0.25, 0);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(0, 0, 0);
        })
        esp:create("Frame", {
            Parent = objects["6"];
            Position = dim2(0, 1, 0, -2);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, -2, 1, 1);
            BorderSizePixel = 0;
            BackgroundColor3 = ESPFlags["Box_Color"].Color;
        })

        objects["7"] = esp:create("Frame", {
            AnchorPoint = vec2(1, 1);
            Parent = objects["corners"];
            Name = "line";
            Position = dim2(1, 0, 1, -2);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(0.4, 0, 0, 3);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(0, 0, 0);
        })
        esp:create("Frame", {
            Parent = objects["7"];
            Position = dim2(0, 1, 0, 1);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, -2, 1, -2);
            BorderSizePixel = 0;
            BackgroundColor3 = ESPFlags["Box_Color"].Color;
        })

        objects["8"] = esp:create("Frame", {
            BorderColor3 = rgb(0, 0, 0);
            Rotation = 180;
            Parent = objects["corners"];
            Name = "line";
            Position = dim2(1, 0, 1, -5);
            AnchorPoint = vec2(1, 1);
            Size = dim2(0, 3, 0.25, 0);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(0, 0, 0);
        })
        esp:create("Frame", {
            Parent = objects["8"];
            Position = dim2(0, 1, 0, -2);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, -2, 1, 1);
            BorderSizePixel = 0;
            BackgroundColor3 = ESPFlags["Box_Color"].Color;
        })

        -- Healthbar
        objects["healthbar_holder"] = esp:create("Frame", {
            AnchorPoint = vec2(1, 0);
            Parent = ESPFlags["Healthbar"] and objects["holder"] or esp.cache;
            Name = "\0";
            Position = dim2(0, -5, 0, -1);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(0, 4, 1, 2);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(0, 0, 0);
        })
        objects["healthbar"] = esp:create("Frame", {
            Parent = objects["healthbar_holder"];
            Name = "\0";
            Position = dim2(0, 1, 0, 1);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, -2, 1, -2);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255);
        })

        -- Distance
        objects["distance"] = esp:create("TextLabel", {
            FontFace = fonts.main;
            TextColor3 = ESPFlags["Distance_Color"].Color;
            BorderColor3 = rgb(0, 0, 0);
            Text = "127st";
            Parent = ESPFlags["Distance"] and objects["holder"] or esp.cache;
            TextStrokeTransparency = 0;
            Name = "\0";
            Size = dim2(1, 0, 0, 0);
            BackgroundTransparency = 1;
            Position = dim2(0, 0, 1, 5);
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.Y;
            TextSize = 9;
        })

        -- Weapon
        objects["weapon"] = esp:create("TextLabel", {
            FontFace = fonts.main;
            TextColor3 = ESPFlags["Weapon_Color"].Color;
            BorderColor3 = rgb(0, 0, 0);
            Text = "[ak-47]";
            Parent = esp.cache;
            TextStrokeTransparency = 0;
            Name = "\0";
            Size = dim2(1, 0, 0, 0);
            BackgroundTransparency = 1;
            Position = dim2(0, 0, 1, 19);
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.Y;
            TextSize = 9;
        })

        -- data functions
        data.health_changed = function(value)
            if not ESPFlags["Healthbar"] then return end
            local humanoid = data.info.humanoid
            local multiplier = value / humanoid.MaxHealth
            local hpHigh, hpLow
            local LocalP = Players.LocalPlayer
            local isSelf = player == LocalP
            local sameTeam = (not isSelf) and player.Team ~= nil and player.Team == LocalP.Team
            if isSelf then
                hpHigh = S.Self_Health_High
                hpLow = S.Self_Health_Low
            elseif sameTeam then
                hpHigh = S.Teammate_Health_High
                hpLow = S.Teammate_Health_Low
            else
                hpHigh = ESPFlags["Health_High"].Color
                hpLow = ESPFlags["Health_Low"].Color
            end
            local color = hpLow:Lerp(hpHigh, multiplier)
            objects["healthbar"].Size = UDim2.new(1, -2, multiplier, -2)
            objects["healthbar"].Position = UDim2.new(0, 1, 1 - multiplier, 1)
            objects["healthbar"].BackgroundColor3 = color
        end

        data.tool_added = function(item)
            if not item:IsA("Tool") then return end
            local exists = data.info.character:FindFirstChild(item.Name)
            objects["weapon"].Text = item.Name
            objects["weapon"].Parent = exists and objects["holder"] or esp.cache
        end

        data.refresh_offsets = function()
            local offset = 5
            if objects["distance"].Parent == objects["holder"] then
                offset = offset + 5
                objects["weapon"].Position = dim2(0, 0, 1, offset)
            end
            if objects["weapon"].Parent == objects["holder"] then
                offset = offset + 5
                objects["weapon"].Position = dim2(0, 0, 1, offset)
            end
        end

        data.refresh_descendants = function()
            local character = player.Character
            if not character then return end
            local humanoid = character:WaitForChild("Humanoid", 5)
            if not humanoid then return end
            data.info.character = character
            data.info.humanoid = humanoid
            table.insert(connections, humanoid.HealthChanged:Connect(data.health_changed))
            table.insert(connections, character.ChildAdded:Connect(data.tool_added))
            table.insert(connections, character.ChildRemoved:Connect(data.tool_added))
            data.health_changed(data.info.humanoid.Health)
        end

        -- init / connections
        data.refresh_descendants()
        if data.info.humanoid then
            data.health_changed(data.info.humanoid.Health)
        end
        table.insert(connections, player.CharacterAdded:Connect(data.refresh_descendants))
        local startChar = player.Character
        local tool = startChar and startChar:FindFirstChildOfClass("Tool")
        if tool then data.tool_added(tool) end
    end

    function esp:remove_object(player)
        local holder = esp[player.Name]
        if not holder then return end
        local objects = holder.objects
        objects["holder"]:Destroy()
        esp[player.Name] = nil
    end

    function esp:refresh_elements()
        for _, v in Players:GetPlayers() do
            if not v.Character then continue end
            local path = esp[v.Name]
            local objects = path and path.objects
            if not objects then continue end
            local LocalPlayer = Players.LocalPlayer
            local isSelfR = v == LocalPlayer
            local sameTeamR = (not isSelfR) and v.Team ~= nil and v.Team == LocalPlayer.Team
            local boxCR, nameCR, distCR, wepCR
            if isSelfR then
                boxCR = S.Self_Box_Color
                nameCR = S.Self_Name_Color
                distCR = S.Self_Distance_Color
                wepCR = S.Self_Weapon_Color
            elseif sameTeamR then
                boxCR = S.Teammate_Box_Color
                nameCR = S.Teammate_Name_Color
                distCR = S.Teammate_Distance_Color
                wepCR = S.Teammate_Weapon_Color
            else
                boxCR = ESPFlags["Box_Color"].Color
                nameCR = ESPFlags["Name_Color"].Color
                distCR = ESPFlags["Distance_Color"].Color
                wepCR = ESPFlags["Weapon_Color"].Color
            end
            local anyEsp = S.ESP_Enabled or S.Teammates_Enabled or S.SelfESP_Enabled
            objects.holder.Parent = anyEsp and esp.screengui or esp.cache

            objects["name"].Parent = ESPFlags["Names"] and objects["holder"] or esp.cache
            objects["name"].TextColor3 = nameCR
            objects["name"].Text = buildName(v)

            local is_corner = ESPFlags["Box_Type"] == "Corner"
            if ESPFlags["Boxes"] then
                objects["corners"].Parent = (is_corner and objects["holder"]) or esp.cache
                objects["box_handler"].Parent = (is_corner and esp.cache or objects["holder"])
                objects["box_outline"].Parent = (is_corner and esp.cache or objects["holder"])
            else
                objects["corners"].Parent = esp.cache
                objects["box_handler"].Parent = esp.cache
                objects["box_outline"].Parent = esp.cache
            end
            objects["box_color"].Color = boxCR
            for _, corner in objects["corners"]:GetChildren() do
                corner.Frame.BackgroundColor3 = boxCR
            end
            objects["healthbar_holder"].Parent = ESPFlags["Healthbar"] and objects["holder"] or esp.cache
            objects["weapon"].TextColor3 = wepCR
            objects["weapon"].Parent = ESPFlags["Weapon"] and v.Character:FindFirstChildOfClass("Tool") and objects["holder"] or esp.cache
            objects["distance"].TextColor3 = distCR
            objects["distance"].Parent = ESPFlags["Distance"] and objects["holder"] or esp.cache
        end
    end

    return M
end

return ESP
