-- ==========================================
-- Nex Library
-- Non-OOP, Glassmorphism, Draggable, Minimized
-- ==========================================

local Nex = {}

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- Determine the safest location to place UI
local success, result = pcall(function() return CoreGui.Name end)
local UIParent = success and CoreGui or Players.LocalPlayer:WaitForChild("PlayerGui")

function Nex.CreateWindow(options)
    local title = type(options) == "table" and options.Title or options or "Nex Library"
    local WindowFunctions = {}
    
    local UI = Instance.new("ScreenGui")
    UI.Name = "NexLibraryUI_" .. tostring(math.random(1000, 9999))
    UI.ResetOnSpawn = false
    UI.Parent = UIParent
    
    -- Main Window (Glassmorphism inspired)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 450, 0, 350)
    MainFrame.Position = UDim2.new(0.5, -225, 0.5, -175)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    MainFrame.BackgroundTransparency = 0.25 -- Glass effect
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = UI
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = MainFrame

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(255, 255, 255)
    UIStroke.Transparency = 0.85
    UIStroke.Thickness = 1
    UIStroke.Parent = MainFrame
    
    -- Topbar
    local Topbar = Instance.new("Frame")
    Topbar.Name = "Topbar"
    Topbar.Size = UDim2.new(1, 0, 0, 45)
    Topbar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Topbar.BackgroundTransparency = 0.5
    Topbar.BorderSizePixel = 0
    Topbar.Parent = MainFrame
    
    local TopbarLine = Instance.new("Frame")
    TopbarLine.Size = UDim2.new(1, 0, 0, 1)
    TopbarLine.Position = UDim2.new(0, 0, 1, 0)
    TopbarLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TopbarLine.BackgroundTransparency = 0.9
    TopbarLine.BorderSizePixel = 0
    TopbarLine.Parent = Topbar
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -90, 1, 0)
    TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title
    TitleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Topbar
    
    -- Minimize Button
    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    MinimizeBtn.Position = UDim2.new(1, -40, 0.5, -15)
    MinimizeBtn.BackgroundTransparency = 1
    MinimizeBtn.Text = "-"
    MinimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.TextSize = 20
    MinimizeBtn.Parent = Topbar
    
    -- Container for elements
    local ContentContainer = Instance.new("ScrollingFrame")
    ContentContainer.Name = "Container"
    ContentContainer.Size = UDim2.new(1, -20, 1, -60)
    ContentContainer.Position = UDim2.new(0, 10, 0, 55)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.ScrollBarThickness = 2
    ContentContainer.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
    ContentContainer.ScrollBarImageTransparency = 0.8
    ContentContainer.Parent = MainFrame
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 8)
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = ContentContainer
    
    local UIPadding = Instance.new("UIPadding")
    UIPadding.PaddingTop = UDim.new(0, 2)
    UIPadding.PaddingBottom = UDim.new(0, 10)
    UIPadding.Parent = ContentContainer
    
    -- Dragging Logic
    local dragging, dragInput, dragStart, startPos
    Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    Topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- Minimize Logic
    local Minimized = false
    MinimizeBtn.MouseButton1Click:Connect(function()
        Minimized = not Minimized
        if Minimized then
            TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = UDim2.new(0, 450, 0, 45)}):Play()
            MinimizeBtn.Text = "+"
        else
            TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = UDim2.new(0, 450, 0, 350)}):Play()
            MinimizeBtn.Text = "-"
        end
    end)
    
    -- Auto resize scroll frame
    UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ContentContainer.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
    end)
    
    -- Element Functions (Non-OOP)
    
    function WindowFunctions.CreateButton(text, callback)
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, -10, 0, 35)
        Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Button.BackgroundTransparency = 0.95
        Button.Text = text or "Button"
        Button.TextColor3 = Color3.fromRGB(230, 230, 230)
        Button.Font = Enum.Font.GothamMedium
        Button.TextSize = 13
        Button.BorderSizePixel = 0
        Button.Parent = ContentContainer
        
        local BCorner = Instance.new("UICorner")
        BCorner.CornerRadius = UDim.new(0, 6)
        BCorner.Parent = Button
        
        local BStroke = Instance.new("UIStroke")
        BStroke.Color = Color3.fromRGB(255, 255, 255)
        BStroke.Transparency = 0.9
        BStroke.Thickness = 1
        BStroke.Parent = Button
        
        Button.MouseEnter:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundTransparency = 0.85}):Play()
        end)
        Button.MouseLeave:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundTransparency = 0.95}):Play()
        end)
        
        Button.MouseButton1Click:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundTransparency = 0.7}):Play()
            task.wait(0.1)
            TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundTransparency = 0.85}):Play()
            if callback then callback() end
        end)
    end
    
    function WindowFunctions.CreateToggle(text, defaultState, callback)
        local toggled = defaultState or false
        
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Size = UDim2.new(1, -10, 0, 40)
        ToggleFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ToggleFrame.BackgroundTransparency = 0.95
        ToggleFrame.BorderSizePixel = 0
        ToggleFrame.Parent = ContentContainer
        
        local TCorner = Instance.new("UICorner")
        TCorner.CornerRadius = UDim.new(0, 6)
        TCorner.Parent = ToggleFrame
        
        local TStroke = Instance.new("UIStroke")
        TStroke.Color = Color3.fromRGB(255, 255, 255)
        TStroke.Transparency = 0.9
        TStroke.Thickness = 1
        TStroke.Parent = ToggleFrame
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -60, 1, 0)
        Label.Position = UDim2.new(0, 15, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = text or "Toggle"
        Label.TextColor3 = Color3.fromRGB(230, 230, 230)
        Label.Font = Enum.Font.GothamMedium
        Label.TextSize = 13
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = ToggleFrame
        
        local IndicatorBg = Instance.new("Frame")
        IndicatorBg.Size = UDim2.new(0, 40, 0, 20)
        IndicatorBg.Position = UDim2.new(1, -55, 0.5, -10)
        IndicatorBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        IndicatorBg.BackgroundTransparency = 0.5
        IndicatorBg.Parent = ToggleFrame
        
        local ICorner = Instance.new("UICorner")
        ICorner.CornerRadius = UDim.new(1, 0)
        ICorner.Parent = IndicatorBg
        
        local Indicator = Instance.new("Frame")
        Indicator.Size = UDim2.new(0, 16, 0, 16)
        Indicator.Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        Indicator.BackgroundColor3 = toggled and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(150, 150, 150)
        Indicator.Parent = IndicatorBg
        
        local IndCorner = Instance.new("UICorner")
        IndCorner.CornerRadius = UDim.new(1, 0)
        IndCorner.Parent = Indicator
        
        local InvsButton = Instance.new("TextButton")
        InvsButton.Size = UDim2.new(1, 0, 1, 0)
        InvsButton.BackgroundTransparency = 1
        InvsButton.Text = ""
        InvsButton.Parent = ToggleFrame
        
        local function fire()
            toggled = not toggled
            if toggled then
                TweenService:Create(Indicator, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(1, -18, 0.5, -8), BackgroundColor3 = Color3.fromRGB(80, 200, 120)}):Play()
            else
                TweenService:Create(Indicator, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = Color3.fromRGB(150, 150, 150)}):Play()
            end
            if callback then callback(toggled) end
        end
        
        InvsButton.MouseButton1Click:Connect(fire)
        
        return {
            Set = function(state)
                if toggled ~= state then
                    fire()
                end
            end,
            GetState = function()
                return toggled
            end
        }
    end

    function WindowFunctions.CreateLabel(text)
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -10, 0, 25)
        Label.BackgroundTransparency = 1
        Label.Text = text or "Label"
        Label.TextColor3 = Color3.fromRGB(160, 160, 160)
        Label.Font = Enum.Font.GothamMedium
        Label.TextSize = 13
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = ContentContainer
        
        local Padding = Instance.new("UIPadding")
        Padding.PaddingLeft = UDim.new(0, 10)
        Padding.Parent = Label
        
        return {
            SetText = function(newText)
                Label.Text = newText
            end
        }
    end
    
    function WindowFunctions.CreateSlider(text, min, max, default, callback)
        local val = default or min
        local draggingSlider = false
        
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Size = UDim2.new(1, -10, 0, 50)
        SliderFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SliderFrame.BackgroundTransparency = 0.95
        SliderFrame.BorderSizePixel = 0
        SliderFrame.Parent = ContentContainer
        
        local SCorner = Instance.new("UICorner")
        SCorner.CornerRadius = UDim.new(0, 6)
        SCorner.Parent = SliderFrame
        
        local SStroke = Instance.new("UIStroke")
        SStroke.Color = Color3.fromRGB(255, 255, 255)
        SStroke.Transparency = 0.9
        SStroke.Thickness = 1
        SStroke.Parent = SliderFrame
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -30, 0, 20)
        Label.Position = UDim2.new(0, 15, 0, 4)
        Label.BackgroundTransparency = 1
        Label.Text = text or "Slider"
        Label.TextColor3 = Color3.fromRGB(230, 230, 230)
        Label.Font = Enum.Font.GothamMedium
        Label.TextSize = 13
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = SliderFrame
        
        local ValueLabel = Instance.new("TextLabel")
        ValueLabel.Size = UDim2.new(0, 50, 0, 20)
        ValueLabel.Position = UDim2.new(1, -65, 0, 4)
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.Text = tostring(val)
        ValueLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        ValueLabel.Font = Enum.Font.GothamMedium
        ValueLabel.TextSize = 12
        ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
        ValueLabel.Parent = SliderFrame
        
        local BarBg = Instance.new("Frame")
        BarBg.Size = UDim2.new(1, -30, 0, 6)
        BarBg.Position = UDim2.new(0, 15, 0, 32)
        BarBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        BarBg.BackgroundTransparency = 0.6
        BarBg.Parent = SliderFrame
        
        local BCorner = Instance.new("UICorner")
        BCorner.CornerRadius = UDim.new(1, 0)
        BCorner.Parent = BarBg
        
        local fillPercent = math.clamp((val - min) / (max - min), 0, 1)
        local BarFill = Instance.new("Frame")
        BarFill.Size = UDim2.new(fillPercent, 0, 1, 0)
        BarFill.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
        BarFill.Parent = BarBg
        
        local FCorner = Instance.new("UICorner")
        FCorner.CornerRadius = UDim.new(1, 0)
        FCorner.Parent = BarFill
        
        local InvsButton = Instance.new("TextButton")
        InvsButton.Size = UDim2.new(1, 0, 1, 0)
        InvsButton.Position = UDim2.new(0, 0, 0, -10)
        InvsButton.BackgroundTransparency = 1
        InvsButton.Text = ""
        InvsButton.Parent = BarBg
        
        local function updateSlider(input)
            local pos = math.clamp((input.Position.X - BarBg.AbsolutePosition.X) / BarBg.AbsoluteSize.X, 0, 1)
            val = math.floor(min + ((max - min) * pos))
            ValueLabel.Text = tostring(val)
            TweenService:Create(BarFill, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(pos, 0, 1, 0)}):Play()
            if callback then callback(val) end
        end
        
        InvsButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                draggingSlider = true
                updateSlider(input)
            end
        end)
        
        InvsButton.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                draggingSlider = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                updateSlider(input)
            end
        end)
        
        return {
            Set = function(newVal)
                val = math.clamp(newVal, min, max)
                ValueLabel.Text = tostring(val)
                TweenService:Create(BarFill, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new((val - min) / (max - min), 0, 1, 0)}):Play()
                if callback then callback(val) end
            end
        }
    end
    
    return WindowFunctions
end

return Nex
