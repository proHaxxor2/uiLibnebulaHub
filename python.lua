local gameServices = game:GetService
local coreInterface = gameServices("CoreGui")
local inputManager = gameServices("UserInputService")
local playerRegistry = gameServices("Players")
local networkHandler = gameServices("HttpService")

-- Fallback for cloneref if unavailable
if not cloneref then
    cloneref = function(obj) return obj end
end

-- Load custom UI asset (placeholder rbxassetid)
local baseUI = game:GetObjects("rbxassetid://12345678901234")[1]
if not baseUI then error("UI asset not found") end

-- Core Hub class
local NebulaHub = {}
NebulaHub.__index = NebulaHub

-- Utility: Smooth interpolation
local function interpolate(val, minIn, maxIn, minOut, maxOut)
    return minOut + (maxOut - minOut) * ((val - minIn) / (maxIn - minIn))
end

-- Utility: Round to nearest step
local function snapToStep(val, step)
    return math.floor(val / step + 0.5) * step
end

-- Drag system
local function enableMovement(frame, speed)
    local isMoving, startPoint, originPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and not inputManager:GetFocusedTextBox() then
            isMoving = true
            startPoint = input.Position
            originPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then isMoving = false end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if isMoving and (input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - startPoint
            local newPos = UDim2.new(originPos.X.Scale, originPos.X.Offset + delta.X, originPos.Y.Scale, originPos.Y.Offset + delta.Y)
            if speed and typeof(speed) == "number" then
                gameServices("TweenService"):Create(frame, TweenInfo.new(speed), {Position = newPos}):Play()
            else
                frame.Position = newPos
            end
        end
    end)
end

-- Hub initialization
function NebulaHub.new(config)
    assert(config, "Config required")
    assert(config.title, "Title required")
    assert(config.visibleByDefault ~= nil, "Visibility state required")
    assert(config.container, "Parent container required")
    assert(config.toggleKey, "Toggle key required")

    local hub = setmetatable({}, NebulaHub)
    hub.elements = {}
    hub.state = {visible = config.visibleByDefault, configData = isfile("NebulaHub1.config") and networkHandler:JSONDecode(readfile("NebulaHub1.config")) or {}}
    hub.root = baseUI:Clone()
    hub.root.Title.Text = config.title
    hub.root.Parent = config.container

    -- Toggle visibility
    inputManager.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == config.toggleKey and not inputManager:GetFocusedTextBox() then
            hub.state.visible = not hub.state.visible
            hub.root.Visible = hub.state.visible
        end
    end)

    -- Drag support
    enableMovement(hub.root, config.dragSpeed)

    -- Initial visibility
    hub.root.Visible = hub.state.visible

    return hub
end

-- Save configuration
function NebulaHub:storeConfig()
    writefile("NebulaHub1.config", networkHandler:JSONEncode(self.state.configData))
end

-- Panel (equivalent to tab)
function NebulaHub:addPanel(label)
    assert(label, "Panel label required")
    local panel = setmetatable({label = label, items = {}, root = self.root.Panels:Clone()}, {__index = {}})
    panel.root.Name = label
    panel.root.Title.Text = label
    panel.root.Parent = self.root
    panel.root.Visible = false
    if #self.elements == 0 then panel.root.Visible = true end
    table.insert(self.elements, panel)
    return panel
end

-- Switch (toggle equivalent)
function NebulaHub:addSwitch(panel, details)
    assert(panel, "Panel required")
    assert(details.text, "Switch text required")
    assert(details.initial ~= nil, "Initial state required")
    assert(details.action, "Action callback required")

    local switch = setmetatable({}, {__index = {}})
    switch.text = details.text
    switch.state = panel.root.Config[details.text] == nil and details.initial or panel.root.Config[details.text]
    switch.callback = details.action

    local switchUI = self.root.Switch:Clone()
    switchUI.Text.Text = switch.text
    switchUI.State.Text = switch.state and "ON" or "OFF"
    switchUI.Parent = panel.root
    switchUI.Visible = true

    switchUI.MouseButton1Click:Connect(function()
        switch.state = not switch.state
        switchUI.State.Text = switch.state and "ON" or "OFF"
        panel.root.Config[details.text] = switch.state
        if self.state.visible and self.state.configData then
            self.state.configData[details.text] = switch.state
            self:storeConfig()
        end
        task.spawn(switch.callback, switch.state)
    end)

    table.insert(panel.items, switch)
    return switch
end

-- Range (slider equivalent)
function NebulaHub:addRange(panel, details)
    assert(panel, "Panel required")
    assert(details.label, "Range label required")
    assert(details.min, "Minimum value required")
    assert(details.max, "Maximum value required")
    assert(details.step, "Step value required")
    assert(details.start, "Starting value required")
    assert(details.onChange, "Change callback required")

    local range = setmetatable({}, {__index = {}})
    range.value = math.clamp(panel.root.Config[details.label] or details.start, details.min, details.max)
    range.callback = details.onChange

    local rangeUI = self.root.Range:Clone()
    rangeUI.Label.Text = details.label
    rangeUI.Value.Text = tostring(range.value)
    rangeUI.Parent = panel.root
    rangeUI.Visible = true

    rangeUI.Bar.MouseButton1Down:Connect(function(input)
        local startX = input.Position.X
        local barWidth = rangeUI.Bar.AbsoluteSize.X
        local dragging = true

        while dragging do
            local delta = inputManager:GetMouseLocation().X - startX
            local newVal = snapToStep(interpolate(delta, 0, barWidth, details.min, details.max), details.step)
            range.value = math.clamp(newVal, details.min, details.max)
            rangeUI.Value.Text = tostring(range.value)
            panel.root.Config[details.label] = range.value
            if self.state.visible and self.state.configData then
                self.state.configData[details.label] = range.value
                self:storeConfig()
            end
            task.spawn(range.callback, range.value)
            if not inputManager:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then dragging = false end
            task.wait()
        end
    end)

    table.insert(panel.items, range)
    return range
end

-- Selector (dropdown equivalent)
function NebulaHub:addSelector(panel, details)
    assert(panel, "Panel required")
    assert(details.title, "Selector title required")
    assert(details.choices, "Choices required")
    assert(details.onSelect, "Selection callback required")

    local selector = setmetatable({}, {__index = {}})
    selector.choices = details.choices
    selector.selection = panel.root.Config[details.title] or details.choices[1]
    selector.callback = details.onSelect

    local selectorUI = self.root.Selector:Clone()
    selectorUI.Title.Text = details.title
    selectorUI.Current.Text = selector.selection
    selectorUI.Parent = panel.root
    selectorUI.Visible = true

    selectorUI.ClickArea.MouseButton1Click:Connect(function()
        selectorUI.Options.Visible = not selectorUI.Options.Visible
    end)

    for _, choice in ipairs(selector.choices) do
        local option = self.root.Option:Clone()
        option.Text = choice
        option.Parent = selectorUI.Options
        option.Visible = true
        option.MouseButton1Click:Connect(function()
            selector.selection = choice
            selectorUI.Current.Text = choice
            selectorUI.Options.Visible = false
            panel.root.Config[details.title] = choice
            if self.state.visible and self.state.configData then
                self.state.configData[details.title] = choice
                self:storeConfig()
            end
            task.spawn(selector.callback, choice)
        end)
    end

    table.insert(panel.items, selector)
    return selector
end

-- Action (button equivalent)
function NebulaHub:addAction(panel, details)
    assert(panel, "Panel required")
    assert(details.name, "Action name required")
    assert(details.execute, "Execution callback required")

    local action = setmetatable({}, {__index = {}})
    action.callback = details.execute

    local actionUI = self.root.Action:Clone()
    actionUI.Name.Text = details.name
    actionUI.Parent = panel.root
    actionUI.Visible = true

    actionUI.MouseButton1Click:Connect(function()
        task.spawn(action.callback)
    end)

    table.insert(panel.items, action)
    return action
end

return NebulaHub
