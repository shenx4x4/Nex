local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local AetherUI = {}

-- Theme
local Theme = {
    Background = Color3.fromRGB(20, 20, 25),
    Secondary = Color3.fromRGB(30, 30, 35),
    Accent = Color3.fromRGB(100, 150, 255),
    Text = Color3.fromRGB(240, 240, 240),
    TextDark = Color3.fromRGB(150, 150, 150),
    Stroke = Color3.fromRGB(50, 50, 60),
    Transparency = 0.85
}

local function CreateTween(instance, info, properties)
    local tween = TweenService:Create(instance, info, properties)
    tween:Play()
    return tween
end

local function MakeDraggable(topbarobject, object)
    local Dragging = false
    local DragInput = nil
    local DragStart = nil
    local StartPosition = nil

    local function Update(input)
        local Delta = input.Position - DragStart
        local pos = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
        CreateTween(object, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = pos})
    end

    topbarobject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPosition = object.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    topbarobject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            Update(input)
        end
    end)
end

function AetherUI.CreateWindow(titleText)
    local Window = {}
    
    local parentUI = nil
    if RunService:IsStudio() then
        parentUI = Players.LocalPlayer:WaitForChild("PlayerGui")
    else
        local success = pcall(function() parentUI = CoreGui end)
        if not success then parentUI = Players.LocalPlayer:WaitForChild("PlayerGui") end
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AetherUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = parentUI

    -- Clean up previous instances with same name to avoid duplicates
    for _, gui in pairs(parentUI:GetChildren()) do
        if gui.Name == "AetherUI" and gui ~= ScreenGui then
            gui:Destroy()
        end
    end

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 450, 0, 300)
    MainFrame.Position = UDim2.new(0.5, -225, 0.5, -150)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.BackgroundTransparency = Theme.Transparency
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = false
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Theme.Stroke
    MainStroke.Thickness = 1
    MainStroke.Parent = MainFrame

    local Topbar = Instance.new("Frame")
    Topbar.Name = "Topbar"
    Topbar.Size = UDim2.new(1, 0, 0, 40)
    Topbar.BackgroundTransparency = 1
    Topbar.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -60, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = titleText or "Aether UI"
    Title.TextColor3 = Theme.Text
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Topbar

    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Name = "Minimize"
    MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    MinimizeBtn.Position = UDim2.new(1, -40, 0, 5)
    MinimizeBtn.BackgroundTransparency = 1
    MinimizeBtn.Text = "-"
    MinimizeBtn.TextColor3 = Theme.Text
    MinimizeBtn.TextSize = 20
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.Parent = Topbar

    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, -20, 1, -50)
    ContentContainer.Position = UDim2.new(0, 10, 0, 40)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.ClipsDescendants = true
    ContentContainer.Parent = MainFrame

    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Name = "ScrollFrame"
    ScrollFrame.Size = UDim2.new(1, 0, 1, 0)
    ScrollFrame.BackgroundTransparency = 1
    ScrollFrame.ScrollBarThickness = 2
    ScrollFrame.ScrollBarImageColor3 = Theme.Accent
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ScrollFrame.Parent = ContentContainer

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 8)
    UIListLayout.Parent = ScrollFrame

    local UIPadding = Instance.new("UIPadding")
    UIPadding.PaddingTop = UDim.new(0, 5)
    UIPadding.PaddingLeft = UDim.new(0, 5)
    UIPadding.PaddingRight = UDim.new(0, 15)
    UIPadding.PaddingBottom = UDim.new(0, 5)
    UIPadding.Parent = ScrollFrame

    UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
    end)

    MakeDraggable(Topbar, MainFrame)

    local Minimized = false
    MinimizeBtn.MouseButton1Click:Connect(function()
        Minimized = not Minimized
        if Minimized then
            CreateTween(ContentContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, -20, 0, 0)})
            CreateTween(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 450, 0, 40)})
        else
            CreateTween(ContentContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, -20, 1, -50)})
            CreateTween(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 450, 0, 300)})
        end
    end)

    local NotifContainer = Instance.new("Frame")
    NotifContainer.Name = "NotifContainer"
    NotifContainer.Size = UDim2.new(0, 250, 1, -20)
    NotifContainer.Position = UDim2.new(1, -260, 0, 10)
    NotifContainer.BackgroundTransparency = 1
    NotifContainer.Parent = ScreenGui

    local NotifList = Instance.new("UIListLayout")
    NotifList.SortOrder = Enum.SortOrder.LayoutOrder
    NotifList.Padding = UDim.new(0, 10)
    NotifList.VerticalAlignment = Enum.VerticalAlignment.Bottom
    NotifList.Parent = NotifContainer

    function Window.CreateNotification(title, text, duration)
        duration = duration or 3
        
        local Notif = Instance.new("Frame")
        Notif.Size = UDim2.new(1, 0, 0, 60)
        Notif.Position = UDim2.new(1, 20, 0, 0)
        Notif.BackgroundColor3 = Theme.Background
        Notif.BackgroundTransparency = 1
        Notif.Parent = NotifContainer

        local NCorner = Instance.new("UICorner")
        NCorner.CornerRadius = UDim.new(0, 6)
        NCorner.Parent = Notif

        local NStroke = Instance.new("UIStroke")
        NStroke.Color = Theme.Accent
        NStroke.Thickness = 1
        NStroke.Transparency = 1
        NStroke.Parent = Notif

        local NTitle = Instance.new("TextLabel")
        NTitle.Size = UDim2.new(1, -20, 0, 20)
        NTitle.Position = UDim2.new(0, 10, 0, 5)
        NTitle.BackgroundTransparency = 1
        NTitle.Text = title
        NTitle.TextColor3 = Theme.Text
        NTitle.TextSize = 14
        NTitle.Font = Enum.Font.GothamBold
        NTitle.TextXAlignment = Enum.TextXAlignment.Left
        NTitle.TextTransparency = 1
        NTitle.Parent = Notif

        local NDesc = Instance.new("TextLabel")
        NDesc.Size = UDim2.new(1, -20, 0, 30)
        NDesc.Position = UDim2.new(0, 10, 0, 25)
        NDesc.BackgroundTransparency = 1
        NDesc.Text = text
        NDesc.TextColor3 = Theme.TextDark
        NDesc.TextSize = 12
        NDesc.Font = Enum.Font.Gotham
        NDesc.TextXAlignment = Enum.TextXAlignment.Left
        NDesc.TextWrapped = true
        NDesc.TextTransparency = 1
        NDesc.Parent = Notif

        CreateTween(Notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = Theme.Transparency, Position = UDim2.new(0, 0, 0, 0)})
        CreateTween(NStroke, TweenInfo.new(0.3), {Transparency = 0})
        CreateTween(NTitle, TweenInfo.new(0.3), {TextTransparency = 0})
        CreateTween(NDesc, TweenInfo.new(0.3), {TextTransparency = 0})

        task.delay(duration, function()
            local fadeInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            CreateTween(Notif, fadeInfo, {BackgroundTransparency = 1, Position = UDim2.new(1, 20, 0, 0)})
            CreateTween(NStroke, fadeInfo, {Transparency = 1})
            CreateTween(NTitle, fadeInfo, {TextTransparency = 1})
            CreateTween(NDesc, fadeInfo, {TextTransparency = 1})
            task.wait(0.35)
            Notif:Destroy()
        end)
    end

    function Window.CreateLabel(text)
        local Label = {}
        
        local LblFrame = Instance.new("Frame")
        LblFrame.Size = UDim2.new(1, 0, 0, 30)
        LblFrame.BackgroundTransparency = 1
        LblFrame.Parent = ScrollFrame
        
        local LblText = Instance.new("TextLabel")
        LblText.Size = UDim2.new(1, -10, 1, 0)
        LblText.Position = UDim2.new(0, 5, 0, 0)
        LblText.BackgroundTransparency = 1
        LblText.Text = text
        LblText.TextColor3 = Theme.Text
        LblText.TextSize = 14
        LblText.Font = Enum.Font.Gotham
        LblText.TextXAlignment = Enum.TextXAlignment.Left
        LblText.Parent = LblFrame

        function Label.SetText(newTxt)
            LblText.Text = newTxt
        end
        
        return Label
    end

    function Window.CreateButton(text, callback)
        local BtnFrame = Instance.new("TextButton")
        BtnFrame.Size = UDim2.new(1, 0, 0, 36)
        BtnFrame.BackgroundColor3 = Theme.Secondary
        BtnFrame.BackgroundTransparency = Theme.Transparency
        BtnFrame.Text = ""
        BtnFrame.AutoButtonColor = false
        BtnFrame.Parent = ScrollFrame

        local BCorner = Instance.new("UICorner")
        BCorner.CornerRadius = UDim.new(0, 6)
        BCorner.Parent = BtnFrame

        local BStroke = Instance.new("UIStroke")
        BStroke.Color = Theme.Stroke
        BStroke.Thickness = 1
        BStroke.Parent = BtnFrame

        local BText = Instance.new("TextLabel")
        BText.Size = UDim2.new(1, 0, 1, 0)
        BText.BackgroundTransparency = 1
        BText.Text = text
        BText.TextColor3 = Theme.Text
        BText.TextSize = 14
        BText.Font = Enum.Font.GothamSemibold
        BText.Parent = BtnFrame

        BtnFrame.MouseEnter:Connect(function()
            CreateTween(BtnFrame, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent})
        end)

        BtnFrame.MouseLeave:Connect(function()
            CreateTween(BtnFrame, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Secondary})
        end)

        BtnFrame.MouseButton1Down:Connect(function()
            CreateTween(BtnFrame, TweenInfo.new(0.1), {Size = UDim2.new(0.98, 0, 0, 34)})
        end)

        BtnFrame.MouseButton1Up:Connect(function()
            CreateTween(BtnFrame, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, 36)})
            if callback then callback() end
        end)
    end

    function Window.CreateToggle(text, default, callback)
        local Toggle = {}
        local toggled = default or false

        local TFrame = Instance.new("TextButton")
        TFrame.Size = UDim2.new(1, 0, 0, 36)
        TFrame.BackgroundColor3 = Theme.Secondary
        TFrame.BackgroundTransparency = Theme.Transparency
        TFrame.Text = ""
        TFrame.AutoButtonColor = false
        TFrame.Parent = ScrollFrame

        local TCorner = Instance.new("UICorner")
        TCorner.CornerRadius = UDim.new(0, 6)
        TCorner.Parent = TFrame

        local TStroke = Instance.new("UIStroke")
        TStroke.Color = Theme.Stroke
        TStroke.Thickness = 1
        TStroke.Parent = TFrame

        local TText = Instance.new("TextLabel")
        TText.Size = UDim2.new(1, -50, 1, 0)
        TText.Position = UDim2.new(0, 10, 0, 0)
        TText.BackgroundTransparency = 1
        TText.Text = text
        TText.TextColor3 = Theme.Text
        TText.TextSize = 14
        TText.Font = Enum.Font.Gotham
        TText.TextXAlignment = Enum.TextXAlignment.Left
        TText.Parent = TFrame

        local IndicatorBg = Instance.new("Frame")
        IndicatorBg.Size = UDim2.new(0, 40, 0, 20)
        IndicatorBg.Position = UDim2.new(1, -50, 0.5, -10)
        IndicatorBg.BackgroundColor3 = Theme.Background
        IndicatorBg.Parent = TFrame

        local ICorner = Instance.new("UICorner")
        ICorner.CornerRadius = UDim.new(1, 0)
        ICorner.Parent = IndicatorBg

        local Indicator = Instance.new("Frame")
        Indicator.Size = UDim2.new(0, 16, 0, 16)
        Indicator.Position = UDim2.new(0, 2, 0.5, -8)
        Indicator.BackgroundColor3 = Theme.TextDark
        Indicator.Parent = IndicatorBg

        local IndCorner = Instance.new("UICorner")
        IndCorner.CornerRadius = UDim.new(1, 0)
        IndCorner.Parent = Indicator

        local function UpdateVisuals()
            if toggled then
                CreateTween(IndicatorBg, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent})
                CreateTween(Indicator, TweenInfo.new(0.2), {Position = UDim2.new(1, -18, 0.5, -8), BackgroundColor3 = Theme.Text})
            else
                CreateTween(IndicatorBg, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Background})
                CreateTween(Indicator, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = Theme.TextDark})
            end
        end

        UpdateVisuals()

        TFrame.MouseButton1Click:Connect(function()
            toggled = not toggled
            UpdateVisuals()
            if callback then callback(toggled) end
        end)

        function Toggle.Set(state)
            toggled = state
            UpdateVisuals()
            if callback then callback(toggled) end
        end

        function Toggle.GetState()
            return toggled
        end

        return Toggle
    end

    function Window.CreateSlider(text, min, max, default, callback)
        local Slider = {}
        local value = math.clamp(default or min, min, max)

        local SFrame = Instance.new("Frame")
        SFrame.Size = UDim2.new(1, 0, 0, 50)
        SFrame.BackgroundColor3 = Theme.Secondary
        SFrame.BackgroundTransparency = Theme.Transparency
        SFrame.Parent = ScrollFrame

        local SCorner = Instance.new("UICorner")
        SCorner.CornerRadius = UDim.new(0, 6)
        SCorner.Parent = SFrame

        local SStroke = Instance.new("UIStroke")
        SStroke.Color = Theme.Stroke
        SStroke.Thickness = 1
        SStroke.Parent = SFrame

        local SText = Instance.new("TextLabel")
        SText.Size = UDim2.new(1, -20, 0, 20)
        SText.Position = UDim2.new(0, 10, 0, 5)
        SText.BackgroundTransparency = 1
        SText.Text = text
        SText.TextColor3 = Theme.Text
        SText.TextSize = 13
        SText.Font = Enum.Font.Gotham
        SText.TextXAlignment = Enum.TextXAlignment.Left
        SText.Parent = SFrame

        local ValText = Instance.new("TextLabel")
        ValText.Size = UDim2.new(0, 50, 0, 20)
        ValText.Position = UDim2.new(1, -60, 0, 5)
        ValText.BackgroundTransparency = 1
        ValText.Text = tostring(value)
        ValText.TextColor3 = Theme.Accent
        ValText.TextSize = 13
        ValText.Font = Enum.Font.GothamBold
        ValText.TextXAlignment = Enum.TextXAlignment.Right
        ValText.Parent = SFrame

        local Track = Instance.new("TextButton")
        Track.Size = UDim2.new(1, -20, 0, 6)
        Track.Position = UDim2.new(0, 10, 0, 32)
        Track.BackgroundColor3 = Theme.Background
        Track.Text = ""
        Track.AutoButtonColor = false
        Track.Parent = SFrame

        local TCorner = Instance.new("UICorner")
        TCorner.CornerRadius = UDim.new(1, 0)
        TCorner.Parent = Track

        local Fill = Instance.new("Frame")
        local startPct = (value - min) / (max - min)
        Fill.Size = UDim2.new(startPct, 0, 1, 0)
        Fill.BackgroundColor3 = Theme.Accent
        Fill.Parent = Track

        local FCorner = Instance.new("UICorner")
        FCorner.CornerRadius = UDim.new(1, 0)
        FCorner.Parent = Fill

        local Knob = Instance.new("Frame")
        Knob.Size = UDim2.new(0, 14, 0, 14)
        Knob.Position = UDim2.new(1, -7, 0.5, -7)
        Knob.BackgroundColor3 = Theme.Text
        Knob.Parent = Fill

        local KCorner = Instance.new("UICorner")
        KCorner.CornerRadius = UDim.new(1, 0)
        KCorner.Parent = Knob

        local sliding = false

        local function UpdateValue(input)
            local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
            value = math.floor((min + pos * (max - min)) + 0.5)
            ValText.Text = tostring(value)
            CreateTween(Fill, TweenInfo.new(0.1), {Size = UDim2.new(pos, 0, 1, 0)})
            if callback then callback(value) end
        end

        Track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                sliding = true
                UpdateValue(input)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                sliding = false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                UpdateValue(input)
            end
        end)

        return Slider
    end

    function Window.CreateDiscordButton(inviteLink)
        local DBtn = Instance.new("TextButton")
        DBtn.Size = UDim2.new(1, 0, 0, 36)
        DBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
        DBtn.BackgroundTransparency = 0.2
        DBtn.Text = "Join Discord"
        DBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        DBtn.TextSize = 14
        DBtn.Font = Enum.Font.GothamBold
        DBtn.AutoButtonColor = false
        DBtn.Parent = ScrollFrame

        local DCorner = Instance.new("UICorner")
        DCorner.CornerRadius = UDim.new(0, 6)
        DCorner.Parent = DBtn

        DBtn.MouseEnter:Connect(function()
            CreateTween(DBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0})
        end)

        DBtn.MouseLeave:Connect(function()
            CreateTween(DBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.2})
        end)

        DBtn.MouseButton1Click:Connect(function()
            local success, _ = pcall(function()
                if setclipboard then
                    setclipboard(inviteLink)
                end
            end)
            Window.CreateNotification("Discord", "Copied invite link to clipboard!", 3)
        end)
    end

    function Window.Destroy()
        ScreenGui:Destroy()
    end

    return Window
end

return AetherUI
