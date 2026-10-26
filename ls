local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Player = Players.LocalPlayer

local Library = {}
Library.Theme = {Accent = Color3.fromRGB(135, 50, 190), Dark = Color3.fromRGB(20, 17, 29), Panel = Color3.fromRGB(36, 30, 49), Text = Color3.fromRGB(245, 239, 255)}
Library.RemImage = "" -- Coloca aqui un ID de imagen de Rem subida a Roblox: rbxassetid://123456
Library.ToggleKey = Enum.KeyCode.RightShift
Library.Windows = {}

local function make(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do obj[k] = v end
    obj.Parent = parent
    return obj
end
local function round(obj, radius)
    make("UICorner", {CornerRadius = UDim.new(0, radius or 6)}, obj)
    return obj
end
local function stroke(obj)
    make("UIStroke", {Color = Library.Theme.Accent, Transparency = .48, Thickness = 1}, obj)
end
local function label(parent, text, height)
    return make("TextLabel", {Size = UDim2.new(1, 0, 0, height or 25), BackgroundTransparency = 1, Text = tostring(text), TextColor3 = Library.Theme.Text, TextSize = 14, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left}, parent)
end
local function button(parent, text, height)
    local b = round(make("TextButton", {Size = UDim2.new(1, 0, 0, height or 29), BackgroundColor3 = Library.Theme.Panel, BackgroundTransparency = .12, Text = tostring(text), TextColor3 = Library.Theme.Text, Font = Enum.Font.GothamMedium, TextSize = 13, AutoButtonColor = true}, parent), 5)
    return b
end
local function vertical(parent, pad)
    return make("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, pad or 7)}, parent)
end
local function bindDrag(handle, frame)
    local moving, origin, initial
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            moving, origin, initial = true, input.Position, frame.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if moving and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - origin
            frame.Position = UDim2.new(initial.X.Scale, initial.X.Offset + delta.X, initial.Y.Scale, initial.Y.Offset + delta.Y)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then moving = false end
    end)
end

local old = CoreGui:FindFirstChild("StixyUILibrary")
if old then old:Destroy() end
local gui = make("ScreenGui", {Name = "StixyUILibrary", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling}, CoreGui)
Library.Gui = gui

function Library:SetRemImage(imageId)
    self.RemImage = tostring(imageId or "")
    for _, win in ipairs(self.Windows) do
        win.BackgroundImage.Image = self.RemImage
        win.BackgroundImage.Visible = self.RemImage ~= ""
    end
end

function Library:AddWindow(title, config)
    config = config or {}
    local w, h = math.max(350, config.Width or 540), math.max(270, config.Height or 410)
    local frame = round(make("Frame", {Name = "StixyWindow", Size = UDim2.fromOffset(w, h), Position = UDim2.new(.5, -w / 2 + (#self.Windows * 30), .5, -h / 2 + (#self.Windows * 30)), BackgroundColor3 = Library.Theme.Dark, ClipsDescendants = true, Active = true}, gui), 8)
    stroke(frame)
    local bg = make("ImageLabel", {Name = "RemBackground", Size = UDim2.new(1, 0, 1, -33), Position = UDim2.fromOffset(0, 33), BackgroundTransparency = 1, Image = config.Image or self.RemImage, Visible = (config.Image or self.RemImage) ~= "", ImageTransparency = .47, ScaleType = Enum.ScaleType.Crop, ZIndex = 1}, frame)
    make("Frame", {Size = UDim2.new(1, 0, 1, -33), Position = UDim2.fromOffset(0, 33), BackgroundColor3 = Library.Theme.Dark, BackgroundTransparency = .32, BorderSizePixel = 0, ZIndex = 2}, frame)
    local bar = make("Frame", {Size = UDim2.new(1, 0, 0, 33), BackgroundColor3 = Library.Theme.Accent, BorderSizePixel = 0, ZIndex = 5}, frame)
    make("UIGradient", {Color = ColorSequence.new(Library.Theme.Accent, Color3.fromRGB(77, 23, 111))}, bar)
    local titleText = make("TextLabel", {Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -90, 1, 0), BackgroundTransparency = 1, Text = title or "StixyHub", TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBold, TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6}, bar)
    local minimize = make("TextButton", {Position = UDim2.new(1, -65, 0, 0), Size = UDim2.fromOffset(32, 33), BackgroundTransparency = 1, Text = "−", TextColor3 = Color3.new(1, 1, 1), TextSize = 23, ZIndex = 6}, bar)
    local close = make("TextButton", {Position = UDim2.new(1, -33, 0, 0), Size = UDim2.fromOffset(32, 33), BackgroundTransparency = 1, Text = "×", TextColor3 = Color3.new(1, 1, 1), TextSize = 22, ZIndex = 6}, bar)
    local tabs = make("ScrollingFrame", {Position = UDim2.fromOffset(10, 40), Size = UDim2.new(1, -20, 0, 32), BackgroundColor3 = Library.Theme.Panel, BackgroundTransparency = .25, BorderSizePixel = 0, ScrollBarThickness = 2, ScrollingDirection = Enum.ScrollingDirection.X, CanvasSize = UDim2.new(), ZIndex = 4}, frame)
    round(tabs, 5)
    local tabLayout = make("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)}, tabs)
    tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() tabs.CanvasSize = UDim2.fromOffset(tabLayout.AbsoluteContentSize.X + 10, 0) end)
    local pages = make("Frame", {Position = UDim2.fromOffset(10, 80), Size = UDim2.new(1, -20, 1, -90), BackgroundTransparency = 1, ZIndex = 4}, frame)
    local resize = make("TextButton", {Position = UDim2.new(1, -20, 1, -20), Size = UDim2.fromOffset(20, 20), Text = "◢", TextColor3 = Library.Theme.Text, BackgroundTransparency = 1, TextSize = 13, ZIndex = 9}, frame)
    bindDrag(bar, frame)
    local minimized = false
    minimize.MouseButton1Click:Connect(function()
        minimized = not minimized
        tabs.Visible, pages.Visible, resize.Visible = not minimized, not minimized, not minimized
        frame.Size = minimized and UDim2.fromOffset(frame.AbsoluteSize.X, 33) or UDim2.fromOffset(w, h)
    end)
    close.MouseButton1Click:Connect(function() frame:Destroy() end)
    local resizing, startPos, startSize = false, nil, nil
    resize.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then resizing, startPos, startSize = true, input.Position, frame.AbsoluteSize end
    end)
    UIS.InputChanged:Connect(function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local d = input.Position - startPos
            w, h = math.max(350, startSize.X + d.X), math.max(270, startSize.Y + d.Y)
            frame.Size = UDim2.fromOffset(w, h)
        end
    end)
    UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then resizing = false end end)
    local win = {Frame = frame, BackgroundImage = bg, Pages = {}, Title = titleText}
    table.insert(self.Windows, win)
    function win:AddTab(name)
        local tabButton = button(tabs, name, 27)
        tabButton.Size = UDim2.fromOffset(math.max(72, #tostring(name) * 9 + 22), 27)
        local page = make("ScrollingFrame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 4, ScrollBarImageColor3 = Library.Theme.Accent, CanvasSize = UDim2.new(), Visible = false, ZIndex = 5}, pages)
        local padding = make("UIPadding", {PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 7), PaddingTop = UDim.new(0, 5)}, page)
        local layout = vertical(page, 8)
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() page.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 20) end)
        local function activate()
            for _, item in ipairs(win.Pages) do
                item.Page.Visible = false
                item.Button.BackgroundColor3 = Library.Theme.Panel
            end
            page.Visible = true
            tabButton.BackgroundColor3 = Library.Theme.Accent
        end
        tabButton.MouseButton1Click:Connect(activate)
        table.insert(win.Pages, {Page = page, Button = tabButton})
        if #win.Pages == 1 then activate() end
        local tab = {}
        function tab:AddLabel(text) return label(page, text) end
        function tab:AddButton(text, callback)
            local b = button(page, text)
            b.MouseButton1Click:Connect(function() if callback then task.spawn(callback) end end)
            return b
        end
        function tab:AddSwitch(text, initial, callback)
            local value = initial == true
            local b = button(page, "")
            local t = label(b, text)
            t.Position, t.Size = UDim2.fromOffset(10, 0), UDim2.new(1, -55, 1, 0)
            local state = round(make("Frame", {Position = UDim2.new(1, -35, .5, -9), Size = UDim2.fromOffset(26, 18), BackgroundColor3 = value and Library.Theme.Accent or Color3.fromRGB(77, 72, 83)}, b), 9)
            local function set(v)
                value = not not v
                state.BackgroundColor3 = value and Library.Theme.Accent or Color3.fromRGB(77, 72, 83)
                if callback then task.spawn(callback, value) end
            end
            b.MouseButton1Click:Connect(function() set(not value) end)
            return {Set = set, Get = function() return value end}
        end
        tab.AddToggle = tab.AddSwitch
        function tab:AddSlider(text, min, max, initial, callback)
            min, max = tonumber(min) or 0, tonumber(max) or 100
            if max <= min then max = min + 1 end
            local holder = round(make("Frame", {Size = UDim2.new(1, 0, 0, 51), BackgroundColor3 = Library.Theme.Panel, BackgroundTransparency = .12}, page), 5)
            local info = label(holder, text, 22)
            info.Position, info.Size = UDim2.fromOffset(9, 2), UDim2.new(1, -75, 0, 22)
            local valueLabel = label(holder, "", 22)
            valueLabel.Position, valueLabel.Size, valueLabel.TextXAlignment = UDim2.new(1, -66, 0, 2), UDim2.fromOffset(56, 22), Enum.TextXAlignment.Right
            local track = round(make("Frame", {Position = UDim2.new(0, 10, 0, 33), Size = UDim2.new(1, -20, 0, 8), BackgroundColor3 = Color3.fromRGB(70, 65, 80)}, holder), 4)
            local fill = round(make("Frame", {Size = UDim2.fromScale(0, 1), BackgroundColor3 = Library.Theme.Accent}, track), 4)
            local value = min
            local function set(v)
                value = math.clamp(tonumber(v) or min, min, max)
                fill.Size = UDim2.fromScale((value - min) / (max - min), 1)
                valueLabel.Text = tostring(math.floor(value * 100 + .5) / 100)
                if callback then task.spawn(callback, value) end
            end
            local sliding = false
            local function update(x) set(min + math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1) * (max - min)) end
            track.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true; update(input.Position.X) end end)
            UIS.InputChanged:Connect(function(input) if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then update(input.Position.X) end end)
            UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end end)
            set(initial or min)
            return {Set = set, Get = function() return value end}
        end
        function tab:AddDropdown(text, options, callback)
            local holder = round(make("Frame", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = Library.Theme.Panel, BackgroundTransparency = .12, ClipsDescendants = true}, page), 5)
            local head = button(holder, text .. "  ▾", 30)
            head.BackgroundTransparency = 1
            local list = make("Frame", {Position = UDim2.fromOffset(5, 33), Size = UDim2.new(1, -10, 0, 0), BackgroundTransparency = 1}, holder)
            local lay = vertical(list, 3)
            local expanded, selected = false, nil
            local function collapse()
                holder.Size = UDim2.new(1, 0, 0, expanded and (36 + lay.AbsoluteContentSize.Y) or 30)
            end
            local function choose(v)
                selected = v
                head.Text = text .. ": " .. tostring(v) .. "  ▾"
                expanded = false; collapse()
                if callback then task.spawn(callback, v) end
            end
            for _, option in ipairs(options or {}) do
                local item = button(list, option, 25)
                item.MouseButton1Click:Connect(function() choose(option) end)
            end
            head.MouseButton1Click:Connect(function() expanded = not expanded; collapse() end)
            return {Set = choose, Get = function() return selected end}
        end
        function tab:AddTextbox(text, placeholder, callback)
            local holder = round(make("Frame", {Size = UDim2.new(1, 0, 0, 56), BackgroundColor3 = Library.Theme.Panel, BackgroundTransparency = .12}, page), 5)
            local t = label(holder, text, 22)
            t.Position = UDim2.fromOffset(9, 0)
            local input = round(make("TextBox", {Position = UDim2.fromOffset(9, 25), Size = UDim2.new(1, -18, 0, 25), BackgroundColor3 = Library.Theme.Dark, PlaceholderText = placeholder or "Escribe aquí...", Text = "", TextColor3 = Library.Theme.Text, Font = Enum.Font.Gotham, TextSize = 13, ClearTextOnFocus = false}, holder), 4)
            input.FocusLost:Connect(function(enter) if callback then task.spawn(callback, input.Text, enter) end end)
            return input
        end
        function tab:AddFolder(text)
            local folder = round(make("Frame", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = Library.Theme.Panel, BackgroundTransparency = .1, ClipsDescendants = true}, page), 5)
            local head = button(folder, "▸ " .. text, 30)
            head.BackgroundTransparency = 1
            local content = make("Frame", {Position = UDim2.fromOffset(10, 34), Size = UDim2.new(1, -20, 0, 0), BackgroundTransparency = 1}, folder)
            local lay = vertical(content, 6)
            local opened = false
            local function update() folder.Size = UDim2.new(1, 0, 0, opened and 40 + lay.AbsoluteContentSize.Y or 30) end
            lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
            head.MouseButton1Click:Connect(function() opened = not opened; head.Text = (opened and "▾ " or "▸ ") .. text; update() end)
            local folderTab = {}
            for _, method in ipairs({"AddLabel", "AddButton", "AddSwitch", "AddSlider", "AddDropdown", "AddTextbox"}) do
                folderTab[method] = function(_, ...)
                    -- Reutiliza los constructores de pestaña colocando temporalmente los elementos en la carpeta.
                    local before = {}
                    for _, child in ipairs(page:GetChildren()) do before[child] = true end
                    local result = tab[method](tab, ...)
                    for _, child in ipairs(page:GetChildren()) do
                        if not before[child] and child:IsA("GuiObject") then child.Parent = content end
                    end
                    update()
                    return result
                end
            end
            folderTab.AddToggle = folderTab.AddSwitch
            return folderTab
        end
        return tab
    end
    return win, frame
end

UIS.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Library.ToggleKey then
        gui.Enabled = not gui.Enabled
    end
end)

function Library:Notify(text)
    local notice = round(make("TextLabel", {AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -15, 0, 15), Size = UDim2.fromOffset(290, 48), BackgroundColor3 = Library.Theme.Panel, TextColor3 = Library.Theme.Text, Text = tostring(text), TextWrapped = true, TextSize = 13, Font = Enum.Font.GothamMedium}, gui), 7)
    stroke(notice)
    task.delay(3, function() if notice.Parent then notice:Destroy() end end)
end

return Library
