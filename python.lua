if not cloneref then
    cloneref = function(...)
        return ...
    end
end

local coreGui = cloneref(game:GetService("CoreGui"))
local httpService = cloneref(game:GetService("HttpService"))
local players = cloneref(game:GetService("Players"))
local uis = cloneref(game:GetService("UserInputService"))

local ui = game:GetObjects("rbxassetid://106090592587140")[1]
local utilities = {}

utilities.dragify = {}
utilities.dragify.__index = utilities.dragify

function utilities:drag(data)
    assert(data, "missing data")
    assert(data.frame ~= nil, "missing frame")

    data = setmetatable(data, utilities.dragify)

    local dragToggle, dragInput, dragStart, startPos

    if not data.canDrag then
        data.canDrag = true
    end

    data.frame.InputBegan:Connect(function(input)
        if not data.canDrag then
            return
        end

        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and cloneref(game:GetService("UserInputService")):GetFocusedTextBox() == nil then
            dragToggle = true
            dragStart = Vector2.new(input.Position.X, input.Position.Y)
            startPos = data.frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
            end)
        end
    end)

    data.frame.InputChanged:Connect(function(input)
        if not data.canDrag then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if not data.canDrag then
            return
        end

        if input == dragInput and dragToggle then
            local inputPos = Vector2.new(input.Position.X, input.Position.Y)
            local delta = inputPos - dragStart
            local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)

            if data.dragSpeed and typeof(data.dragSpeed) == "number" then
                game:GetService("TweenService"):Create(data.frame, TweenInfo.new(data.dragSpeed), {["Position"] = position}):Play()
            else
                data.frame.Position = position
            end
        end
    end)
    
    return data
end

local localPlayer = players.LocalPlayer
local mobile = localPlayer.PlayerGui:FindFirstChild("TouchGui") and true or false

local library = {}

local mapValue = function(value, minA, maxA, minB, maxB)
    return (1 - ((value - minA) / (maxA - minA))) * minB + ((value - minA) / (maxA - minA)) * maxB
end

local round = function(value, decimals)
    local multiplier = 10^decimals
    return math.floor(value * multiplier + 0.5) / multiplier
end

local convertRGB = function(color)
    local response = {}
    table.insert(response, math.floor(color.R * 255))
    table.insert(response, math.floor(color.G * 255))
    table.insert(response, math.floor(color.B * 255))
    return response
end

library.window = {}
library.window.__index = library.window

library.messageBox = {}
library.messageBox.__index = library.messageBox

library.inputBox = {}
library.inputBox.__index = library.inputBox

library.tab = {}
library.tab.__index = library.tab

library.label = {}
library.label.__index = library.label

library.button = {}
library.button.__index = library.button

library.toggle = {}
library.toggle.__index = library.toggle

library.input = {}
library.input.__index = library.input

library.slider = {}
library.slider.__index = library.slider

library.dropdown = {}
library.dropdown.__index = library.dropdown

library.picker = {}
library.picker.__index = library.picker

library.placement = {}
library.placement.__index = library.placement

function library:createWindow(data)
    assert(data, "please provide data")
    assert(data["title"] ~= nil, "please provide a title")
    assert(data["autoshow"] ~= nil, "please provide autoshow")
    assert(data["parent"] ~= nil, "please provide a parent")
    assert(data["keycode"] ~= nil, "please provide a keycode")

    local window = setmetatable(data, library.window)
    window.__connections = {}
    window.__object = ui:Clone()
    window.__object.hide.Visible = false

    if mobile then
        window.__object.hide.Visible = true
        utilities:drag({
            frame = window.__object.hide,
            canDrag = true
        })
        table.insert(window.__connections, window.__object.hide.MouseButton1Click:Connect(function()
            window.__object.main.Visible = not window.__object.main.Visible
        end))
    else
        table.insert(window.__connections, uis.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            if input.KeyCode == window.keycode then
                window.__object.Enabled = not window.__object.Enabled
            end
        end))
    end

    window.drag = utilities:drag({
        frame = window.__object.main,
        canDrag = true
    })

    window.__object.main.title.Text = window.title
    window.__object.Parent = window.parent
    window.tabs = {}
    window.objects = isfile("NebulaHub.config") and httpService:JSONDecode(readfile("NebulaHub.config")) or {}
    window.currentTab = false

    if window.autoshow then
        window.__object.Enabled = true
    end

    if window.transparency and typeof(window.transparency) == "number" then
        window.transparency = window.transparency
    else
        window.transparency = nil
    end

    if window.color and typeof(window.color) == "Color3" then
        window.color = window.color
        window.__object.main.BackgroundColor3 = window.color
        window.__object.main.theme.tabButtons.BackgroundColor3 = window.color
    else
        window.color = nil
    end

    return window
end

function library:createMessageBox(data)
    assert(data, "please provide data")
    assert(data["text"] ~= nil, "please provide text")

    local messageBox = setmetatable(data, library.messageBox)
    messageBox.window = self
    messageBox.__object = ui.dialogs.messageBox:Clone()
    messageBox.__object.text.Text = data.text
    messageBox.__object.Parent = Instance.new("ScreenGui", coreGui)
    messageBox.__object.Visible = true

    if getgenv().NebulaHub and getgenv().NebulaHub.dialogs then
        table.insert(getgenv().NebulaHub.dialogs, messageBox.__object.Parent)
    end

    utilities:drag({
        frame = messageBox.__object,
        canDrag = true
    })

    messageBox.__object.buttons.button1.Visible = false
    messageBox.__object.buttons.button2.Visible = false

    if data.duration then
        task.delay(data.duration, function()
            if not messageBox.__object.Parent then return end
            messageBox.__object:Destroy()
            messageBox.callback(nil)
        end)
    end

    if data.button1 then
        messageBox.__object.buttons.button1.Visible = true
        messageBox.__object.buttons.button1.Text = data.button1
    end

    if data.button2 then
        messageBox.__object.buttons.button2.Visible = true
        messageBox.__object.buttons.button2.Text = data.button2
    end

    messageBox.__object.buttons.button1.MouseButton1Click:Connect(function()
        messageBox.__object:Destroy()
    end)

    messageBox.__object.buttons.button2.MouseButton1Click:Connect(function()
        messageBox.__object:Destroy()
    end)

    if data.callback then
        messageBox.__object.buttons.button1.MouseButton1Click:Connect(function()
            messageBox.callback(data.button1)
        end)
        messageBox.__object.buttons.button2.MouseButton1Click:Connect(function()
            messageBox.callback(data.button2)
        end)
    end

    return messageBox
end

function library:createInputBox(data)
    assert(data, "please provide data")
    assert(data["text"] ~= nil, "please provide text")

    local inputBox = setmetatable(data, library.inputBox)
    inputBox.window = self
    inputBox.__object = ui.dialogs.inputBox:Clone()
    inputBox.__object.text.Text = data.text
    inputBox.__object.Parent = Instance.new("ScreenGui", coreGui)
    inputBox.__object.Visible = true

    if getgenv().NebulaHub and getgenv().NebulaHub.dialogs then
        table.insert(getgenv().NebulaHub.dialogs, inputBox.__object.Parent)
    end

    utilities:drag({
        frame = inputBox.__object,
        canDrag = true
    })

    if data.duration then
        task.delay(data.duration, function()
            if not inputBox.__object.Parent then return end
            inputBox.__object:Destroy()
            inputBox.callback(nil)
        end)
    end

    if data.button then
        inputBox.__object.button.Text = data.button
    end

    inputBox.__object.button.MouseButton1Click:Connect(function()
        inputBox.__object:Destroy()
    end)

    if data.callback then
        inputBox.__object.button.MouseButton1Click:Connect(function()
            inputBox.callback(inputBox.__object.input.Text)
        end)
    end

    return inputBox
end

function library.window:save()
    writefile("NebulaHub.config", httpService:JSONEncode(self.objects))
end

function library.window:selectTab(sTab)    
    for _, tab in pairs(self.tabs) do
        tab.__object.Visible = false
        tab.__tabObject.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    end

    sTab.__object.Visible = true
    sTab.__tabObject.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
end

function library.window:createTab(data)
    assert(data, "please provide data")
    assert(data["text"] ~= nil, "please provide tab text")

    local tab = setmetatable(data, library.tab)
    tab.window = self
    tab.objects = {}
    tab.__object = self.__object.main.theme.tabs.example:Clone()
    tab.__object.Parent = self.__object.main.theme.tabs
    tab.__object.Name = tab.text
    tab.__object.Visible = false
    tab.__tabObject = self.__object.main.theme.tabButtons.ScrollingFrame.example:Clone()
    tab.__tabObject.Text = tab.text
    tab.__tabObject.Name = tab.text
    tab.__tabObject.Parent = self.__object.main.theme.tabButtons.ScrollingFrame
    tab.__tabObject.Visible = true
    tab.__tabObject.MouseButton1Down:Connect(function()
        self:selectTab(tab)
    end)

    if #self.tabs == 0 then
        self:selectTab(tab)
    end

    table.insert(self.tabs, tab)
    return tab
end

function library.tab:createLabel(data)
    assert(data, "please provide data")
    assert(data["text"] ~= nil, "please provide label text")

    local label = setmetatable(data, library.label)
    label.window = self.window
    label.tab = self
    local mainFrame = label.window.__object.elements.mainFrame:Clone()
    label.__object = label.window.__object.elements.label:Clone()
    label.__object.Parent = mainFrame
    mainFrame.Parent = label.tab.__object.contents
    label.__object.Frame.TextLabel.Text = label.text
    label.__object.Visible = true
    return label
end

function library.tab:createEmpty()
    local mainFrame = self.window.__object.elements.mainFrame:Clone()
    mainFrame.Parent = self.window.__object.contents
    return mainFrame
end

function library.tab:createButton(data)
    assert(data, "please provide data")
    assert(data["text"] ~= nil, "please provide button text")
    assert(data["callback"] ~= nil, "please provide button callback")

    local button = setmetatable(data, library.button)
    button.window = self.window
    button.tab = self
    local mainFrame = button.window.__object.elements.mainFrame:Clone()
    button.__object = button.window.__object.elements.button:Clone()
    button.__object.Parent = mainFrame
    mainFrame.Parent = button.tab.__object.contents
    button.__object.TextButton.Text = button.text
    button.__object.Visible = true
    button.__object.TextButton.MouseButton1Click:Connect(button.callback)
    return button
end

function library.tab:createToggle(data)
    assert(data, "please provide data")
    assert(data["text"] ~= nil, "please provide toggle text")
    assert(data["default"] ~= nil, "please provide toggle default")
    assert(data["callback"] ~= nil, "please provide toggle callback")

    local toggle = setmetatable(data, library.toggle)
    toggle.window = self.window
    toggle.tab = self
    local mainFrame = toggle.window.__object.elements.mainFrame:Clone()
    toggle.__object = toggle.window.__object.elements.toggle:Clone()
    toggle.__object.Parent = mainFrame
    mainFrame.Parent = toggle.tab.__object.contents
    toggle.__object.Frame.TextLabel.Text = toggle.text
    toggle.__object.Visible = true
    toggle:setValue(self.window.objects[toggle.flag or toggle.text] == nil and data.default or self.window.objects[toggle.flag or toggle.text] or false)
    toggle.__object.Frame.TextButton.MouseButton1Click:Connect(function()
        toggle:setValue(not toggle.value)
    end)
    return toggle
end

function library.toggle:setValue(data, ignore)
    assert(type(data) == "boolean", "data must be bool")
    self.value = data
    self.window.objects[self.flag or self.text] = self.value
    if self.window.autosave then
        task.spawn(self.window.save, self.window)
    end
    self.__object.Frame.TextButton.Text = data and "on" or "off"
    if not ignore then
        task.spawn(self.callback, data)
    end
end

function library.tab:createInput(data)
    assert(data, "please provide data")
    assert(data["text"] ~= nil, "please provide input text")
    assert(data["callback"] ~= nil, "please provide input callback")

    local input = setmetatable(data, library.input)
    input.window = self.window
    input.tab = self
    input.value = self.window.objects[input.flag or input.text] == nil and data.default or self.window.objects[input.flag or input.text] or false
    local mainFrame = input.window.__object.elements.mainFrame:Clone()
    input.__object = input.window.__object.elements.input:Clone()
    input.__object.Parent = mainFrame
    mainFrame.Parent = input.tab.__object.contents
    input.__object.Frame.TextLabel.Text = input.text
    input.__object.Visible = true
    input.__object.Frame.TextBox.FocusLost:Connect(function()
        input.value = input.__object.Frame.TextBox.Text
        input.callback(input.value)
    end)
    return input
end

function library.input:setValue(value)
    self.value = value
    self.window.objects[self.flag or self.text] = self.value
    if self.window.autosave then
        task.spawn(self.window.save, self.window)
    end
    task.spawn(self.callback, self.value)
end

function library.tab:createSlider(data)
    assert(data, "please provide data")
    assert(data["text"] ~= nil, "please provide slider text")
    assert(data["callback"] ~= nil, "please provide slider callback")
    assert(data["min"] ~= nil, "please provide slider minimum")
    assert(data["max"] ~= nil, "please provide slider maximum")
    assert(data["increment"] ~= nil, "please provide slider increment")
    assert(data["default"] ~= nil, "please provide slider default")
    assert((math.floor(data.default * 1e6) % math.floor(data.increment * 1e6)) == 0, "default must be divisible by increment")

    local slider = setmetatable(data, library.slider)
    slider.window = self.window
    slider.tab = self
    slider.value = math.clamp(self.window.objects[slider.flag or slider.text] == nil and data.default or self.window.objects[slider.flag or slider.text] or false, slider.min, slider.max)
    local mainFrame = slider.window.__object.elements.mainFrame:Clone()
    slider.__object = slider.window.__object.elements.slider:Clone()
    slider.__object.Parent = mainFrame
    mainFrame.Parent = slider.tab.__object.contents
    slider.__object.Frame.TextLabel.Text = slider.text
    slider.__object.Visible = true
    local sliderO = slider.__object.Frame.slider
    local fill = sliderO.Frame
    sliderO.Size = UDim2.new(0, 116, 0.7, 0)
    slider:display()
    slider.__object.Frame.slider.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        self.window.drag.canDrag = false
        local mPos = input.Position.X
        local gPos = fill.Size.X.Offset
        local diff = mPos - (fill.AbsolutePosition.X + gPos)
        local dragging = true
        local function update(input)
            if not dragging then return end
            local nMPos = input.Position.X
            local nX = math.clamp(gPos + (nMPos - mPos) + diff, 0, sliderO.Size.X.Offset)
            local newValue = mapValue(nX, 0, sliderO.Size.X.Offset, slider.min, slider.max)
            newValue = math.clamp(round(math.floor((newValue / slider.increment) + 0.5) * slider.increment, slider.increment % 1 == 0 and 0 or -math.floor(math.log10(slider.increment))), slider.min, slider.max)
            local oldValue = slider.value
            slider.value = newValue
            slider.window.objects[slider.flag or slider.text] = slider.value
            if slider.window.autosave then
                task.spawn(slider.window.save, slider.window)
            end
            slider:display()
            if oldValue ~= newValue then
                slider.callback(newValue)
            end
        end
        local inputChanged, inputEnded
        inputChanged = uis.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                update(input)
            end
        end)
        inputEnded = uis.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
                inputChanged:Disconnect()
                inputEnded:Disconnect()
                self.window.drag.canDrag = true
            end
        end)
    end)
    return slider
end

function library.slider:display()
    local sliderO = self.__object.Frame.slider
    local fill = sliderO.Frame
    sliderO.TextLabel.Text = string.format("%s/%s", self.value, self.max)
    fill.Size = UDim2.new(0, math.ceil(mapValue(self.value, self.min, self.max, 0, sliderO.Size.X.Offset)), 1, 0)
end

function library.slider:setValue(value)
    local oldvalue = self.value
    self.value = math.clamp(value, self.min, self.max)
    self.window.objects[self.flag or self.text] = self.value
    if self.window.autosave then
        task.spawn(self.window.save, self.window)
    end
    self:display()
    if self.value ~= oldvalue then
        task.spawn(self.callback)
    end
end

function library.slider:setMax(value)
    local oldvalue = self.max
    self.max = value
    self.window.objects[self.flag or self.text] = self.max
    if self.value > self.max then
        self.value = math.clamp(value, self.min, self.max)
    end
    if self.window.autosave then
        task.spawn(self.window.save, self.window)
    end
    self:display()
    if self.max ~= oldvalue then
        task.spawn(self.callback)
    end
end

function library.tab:createPicker(data)
    assert(data, "please provide data")
    assert(data["text"] ~= nil, "please provide picker text")
    assert(data["default"] ~= nil, "please provide picker default")
    assert(data["callback"] ~= nil, "please provide picker callback")
    assert(typeof(data["default"]) == "Color3", "default must be color3")

    local picker = setmetatable(data, library.picker)
    picker.window = self.window
    picker.tab = self
    picker.value, picker.raw = data.default, data.default
    local mainFrame = picker.window.__object.elements.mainFrame:Clone()
    picker.__object = picker.window.__object.elements.color:Clone()
    picker.__object.Parent = mainFrame
    mainFrame.Parent = picker.tab.__object.contents
    picker.__object.Frame.TextLabel.Text = picker.text .. " " .. table.concat(convertRGB(picker:get()), ", ")
    picker.__object.Frame.color.BackgroundColor3 = picker:get()
    picker.__object.Visible = true
    picker.__object.Frame.color.BorderSizePixel = 1
    picker.__object.Frame.color.MouseButton1Click:Connect(function()
        if not picker.colorPicker then
            picker.colorPicker = picker.window.__object.elements.picker:Clone()
            picker.colorPicker.Visible = true
            picker.colorPicker.Position = picker.__object.Frame.color.Position + UDim2.fromOffset(40, 0)
            picker.colorPicker.Parent = self.window.__object
            picker.drag = utilities:drag({
                frame = picker.colorPicker,
                canDrag = false
            })
            local isDragging, dragObject
            picker.colorPicker.InputBegan:Connect(function(input)
                if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and uis:GetFocusedTextBox() == nil then
                    local mouseX, mouseY = localPlayer:GetMouse().X, localPlayer:GetMouse().Y
                    local objects = self.window.parent:GetGuiObjectsAtPosition(mouseX, mouseY)
                    local target
                    for _, object in pairs(objects) do
                        if string.match(object.Name, "Bar") then
                            target = object
                            break
                        end
                    end
                    if not target then
                        target = picker.colorPicker
                    end
                    dragObject = target
                    self.window.drag.canDrag = false
                    isDragging = true
                    picker:input(dragObject, Vector2.new(mouseX, mouseY))
                end
            end)
            uis.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement and isDragging then
                    picker:input(dragObject, Vector2.new(localPlayer:GetMouse().X, localPlayer:GetMouse().Y))
                end
            end)
            picker.colorPicker.InputEnded:Connect(function(input)
                if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and uis:GetFocusedTextBox() == nil then
                    self.window.drag.canDrag = true
                    picker.drag.canDrag = false
                    isDragging = false
                    dragObject = nil
                end
            end)
            picker.colorPicker.color.InputBegan:Connect(function(input)
                if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and uis:GetFocusedTextBox() == nil then
                    picker.__noColor = not picker.__noColor
                    picker.colorPicker.color.selected.Visible = picker.__noColor
                    picker:update()
                end
            end)
            picker:update()
        else
            picker.colorPicker:Destroy()
            picker.colorPicker = nil
        end
    end)
    return picker
end

function library.picker:input(dragObject, position)
    local hue, _, brightness = self.value:ToHSV()
    local hVal, bVal
    if dragObject.Name == "bottomBar" then
        brightness = math.clamp((position.X - dragObject.AbsolutePosition.X) / dragObject.AbsoluteSize.X, 0, 1)
    elseif dragObject.Name == "sideBar" then
        hue = math.clamp((position.Y - dragObject.AbsolutePosition.Y) / dragObject.AbsoluteSize.Y, 0, 1)
        self.hue = hue
    else
        self.drag.canDrag = true
    end
    self.value = Color3.fromHSV(hue, 1, brightness)
    self:update(true)
end

function library.picker:get()
    local hue, saturation, brightness = self.value:ToHSV()
    return Color3.fromHSV(hue, self.__noColor and 0 or saturation, brightness)
end

function library.picker:update(input)
    if self.colorPicker then
        local hue, _, brightness = self.value:ToHSV()
        self.colorPicker.sideBar.slider.Position = UDim2.new(0, 0, input and self.hue or hue, 0)
        self.colorPicker.bottomBar.slider.Position = UDim2.new(brightness, 0, 0, 0)
        self.colorPicker.square.BackgroundColor3 = self:get()
    end
    self.__object.Frame.color.BackgroundColor3 = self:get()
    self.__object.Frame.TextLabel.Text = self.text .. " " .. table.concat(convertRGB(self:get()), ", ")
    task.spawn(self.callback, self:get())
end

function library.tab:createDropdown(data)
    assert(data, "please provide data")
    assert(data["text"] ~= nil, "please provide dropdown text")
    assert(data["callback"] ~= nil, "please provide dropdown callback")
    assert(data["options"] ~= nil, "please provide dropdown options")

    local dropdown = setmetatable(data, library.dropdown)
    dropdown.window = self.window
    dropdown.tab = self
    dropdown.value = {}
    local mainFrame = dropdown.window.__object.elements.mainFrame:Clone()
    mainFrame.ZIndex = 2
    dropdown.__object = dropdown.window.__object.elements.dropdown:Clone()
    dropdown.__object.Parent = mainFrame
    mainFrame.Parent = dropdown.tab.__object.contents
    dropdown.__object.TextButton.Text = dropdown.text
    dropdown.__object.Visible = true
    local dropdownUi = dropdown.__object.TextButton.dropdown
    local dropdownExample = dropdownUi.example
    for _, object in pairs(dropdown.options) do
        local dropdownObject = dropdownExample:Clone()
        dropdownObject.BorderSizePixel = 1
        dropdownObject.BorderColor3 = Color3.fromRGB(150, 150, 150)
        dropdownObject.TextSize = 14
        dropdownObject.Parent = dropdownUi
        dropdownObject.Text = object
        dropdownObject.Visible = true
        dropdownObject.Name = object
        dropdownObject.MouseButton1Click:Connect(function()
            dropdown:chooseValue({object})
        end)
    end
    dropdown:chooseValue(dropdown.default)
    dropdown.__object.TextButton.MouseButton1Click:Connect(function()
        dropdownUi.Visible = not dropdownUi.Visible
    end)
    return dropdown
end

function library.dropdown:chooseValue(data)
    if self.multiselect then
        table.foreach(data, function(_, object)
            if table.find(self.value, object) then
                table.remove(self.value, table.find(self.value, object))
            else
                table.insert(self.value, object)
            end
        end)
    else
        if self.value[1] == data[1] then
            self.value = {}
        else
            self.value = data
        end
    end
    self:update()
    task.spawn(self.callback, self.value)
end

function library.dropdown:setValue(data)
    self.value = data
    self:update()
    task.spawn(self.callback, self.value)
end

function library.dropdown:update()
    table.foreach(self.__object.TextButton.dropdown:GetChildren(), function(_, object)
        if not object:IsA("TextButton") then return end
        if table.find(self.value, object.Name) then
            object.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
        else
            object.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        end
    end)
end

function library.tab:createPlacement(data)
    assert(data, "please provide data")
    assert(data["text"] ~= nil, "please provide placement text")
    assert(data["callback"] ~= nil, "please provide placement callback")

    local placement = setmetatable(data, library.placement)
    placement.window = self.window
    placement.tab = self
    placement.value = {}
    local mainFrame = placement.window.__object.elements.mainFrame:Clone()
    placement.__object = placement.window.__object.elements.placement:Clone()
    placement.__object.Parent = mainFrame
    mainFrame.Parent = placement.tab.__object.contents
    placement.__object.TextLabel.Text = placement.text
    placement.__object.Visible = true
end

return library
