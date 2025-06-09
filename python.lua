local gameServices = game.GetService
local coreInterface = gameServices(game, "CoreGui")
local inputManager = gameServices(game, "UserInputService")
local playerRegistry = gameServices(game, "Players")
local networkHandler = gameServices(game, "HttpService")
-- Fallback for cloneref if unavailable
if not cloneref then
    cloneref = function(obj) return obj end
end

-- Create base UI programmatically
local function createBaseUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NebulaHub"
    screenGui.ResetOnSpawn = false
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 400, 0, 300)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 18
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Text = "Nebula Hub"
    titleLabel.Parent = mainFrame
    
    local panelsContainer = Instance.new("Frame")
    panelsContainer.Name = "Panels"
    panelsContainer.Size = UDim2.new(1, 0, 1, -30)
    panelsContainer.Position = UDim2.new(0, 0, 0, 30)
    panelsContainer.BackgroundTransparency = 1
    panelsContainer.Parent = mainFrame
    
    -- Switch template
    local switchTemplate = Instance.new("TextButton")
    switchTemplate.Name = "Switch"
    switchTemplate.Size = UDim2.new(1, -10, 0, 30)
    switchTemplate.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    switchTemplate.TextColor3 = Color3.fromRGB(255, 255, 255)
    switchTemplate.TextSize = 14
    switchTemplate.Font = Enum.Font.SourceSans
    switchTemplate.Text = ""
    
    local switchText = Instance.new("TextLabel")
    switchText.Name = "Text"
    switchText.Size = UDim2.new(0.8, 0, 1, 0)
    switchText.BackgroundTransparency = 1
    switchText.TextColor3 = Color3.fromRGB(255, 255, 255)
    switchText.TextSize = 14
    switchText.Font = Enum.Font.SourceSans
    switchText.TextXAlignment = Enum.TextXAlignment.Left
    switchText.Parent = switchTemplate
    
    local switchState = Instance.new("TextLabel")
    switchState.Name = "State"
    switchState.Size = UDim2.new(0.2, 0, 1, 0)
    switchState.Position = UDim2.new(0.8, 0, 0, 0)
    switchState.BackgroundTransparency = 1
    switchState.TextColor3 = Color3.fromRGB(0, 255, 0)
    switchState.TextSize = 14
    switchState.Font = Enum.Font.SourceSans
    switchState.TextXAlignment = Enum.TextXAlignment.Right
    switchState.Parent = switchTemplate
    
    switchTemplate.Parent = mainFrame
    
    -- Range template
    local rangeTemplate = Instance.new("Frame")
    rangeTemplate.Name = "Range"
    rangeTemplate.Size = UDim2.new(1, -10, 0, 50)
    rangeTemplate.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    
    local rangeLabel = Instance.new("TextLabel")
    rangeLabel.Name = "Label"
    rangeLabel.Size = UDim2.new(1, 0, 0, 20)
    rangeLabel.BackgroundTransparency = 1
    rangeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    rangeLabel.TextSize = 14
    rangeLabel.Font = Enum.Font.SourceSans
    rangeLabel.TextXAlignment = Enum.TextXAlignment.Left
    rangeLabel.Parent = rangeTemplate
    
    local rangeBar = Instance.new("Frame")
    rangeBar.Name = "Bar"
    rangeBar.Size = UDim2.new(1, -10, 0, 10)
    rangeBar.Position = UDim2.new(0, 5, 0, 25)
    rangeBar.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    rangeBar.Parent = rangeTemplate
    
    local rangeValue = Instance.new("TextLabel")
    rangeValue.Name = "Value"
    rangeValue.Size = UDim2.new(0, 50, 0, 20)
    rangeValue.Position = UDim2.new(1, -55, 0, 0)
    rangeValue.BackgroundTransparency = 1
    rangeValue.TextColor3 = Color3.fromRGB(255, 255, 255)
    rangeValue.TextSize = 14
    rangeValue.Font = Enum.Font.SourceSans
    rangeValue.Parent = rangeTemplate
    
    rangeTemplate.Parent = mainFrame
    
    -- Selector template
    local selectorTemplate = Instance.new("Frame")
    selectorTemplate.Name = "Selector"
    selectorTemplate.Size = UDim2.new(1, -10, 0, 30)
    selectorTemplate.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    
    local selectorTitle = Instance.new("TextLabel")
    selectorTitle.Name = "Title"
    selectorTitle.Size = UDim2.new(0.8, 0, 1, 0)
    selectorTitle.BackgroundTransparency = 1
    selectorTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    selectorTitle.TextSize = 14
    selectorTitle.Font = Enum.Font.SourceSans
    selectorTitle.TextXAlignment = Enum.TextXAlignment.Left
    selectorTitle.Parent = selectorTemplate
    
    local selectorCurrent = Instance.new("TextLabel")
    selectorCurrent.Name = "Current"
    selectorCurrent.Size = UDim2.new(0.2, 0, 1, 0)
    selectorCurrent.Position = UDim2.new(0.8, 0, 0, 0)
    selectorCurrent.BackgroundTransparency = 1
    selectorCurrent.TextColor3 = Color3.fromRGB(255, 255, 255)
    selectorCurrent.TextSize = 14
    selectorCurrent.Font = Enum.Font.SourceSans
    selectorCurrent.TextXAlignment = Enum.TextXAlignment.Right
    selectorCurrent.Parent = selectorTemplate
    
    local selectorClick = Instance.new("TextButton")
    selectorClick.Name = "ClickArea"
    selectorClick.Size = UDim2.new(1, 0, 1, 0)
    selectorClick.BackgroundTransparency = 1
    selectorClick.Text = ""
    selectorClick.Parent = selectorTemplate
    
    local selectorOptions = Instance.new("Frame")
    selectorOptions.Name = "Options"
    selectorOptions.Size = UDim2.new(1, 0, 0, 100)
    selectorOptions.Position = UDim2.new(0, 0, 1, 0)
    selectorOptions.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    selectorOptions.Visible = false
    selectorOptions.Parent = selectorTemplate
    
    selectorTemplate.Parent = mainFrame
    
    -- Option template
    local optionTemplate = Instance.new("TextButton")
    optionTemplate.Name = "Option"
    optionTemplate.Size = UDim2.new(1, 0, 0, 25)
    optionTemplate.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    optionTemplate.TextColor3 = Color3.fromRGB(255, 255, 255)
    optionTemplate.TextSize = 14
    optionTemplate.Font = Enum.Font.SourceSans
    optionTemplate.Parent = mainFrame
    
    -- Action template
    local actionTemplate = Instance.new("TextButton")
    actionTemplate.Name = "Action"
    actionTemplate.Size = UDim2.new(1, -10, 0, 30)
    actionTemplate.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    actionTemplate.TextColor3 = Color3.fromRGB(255, 255, 255)
    actionTemplate.TextSize = 14
    actionTemplate.Font = Enum.Font.SourceSans
    actionTemplate.Parent = mainFrame
    
    return screenGui
end

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
    hub.root = createBaseUI()
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
