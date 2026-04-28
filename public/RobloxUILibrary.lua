-- =====================================================
--   Non-OOP Roblox UI Library | Executor Compatible
--   Improved: Notifications, Toggle Button, Keybind,
--   Colorpicker, Textbox, Dropdown fix, Slider fix,
--   Smooth animations, Nil-safe, Consistent styling
-- =====================================================

local CoreGui         = game:GetService("CoreGui")
local TweenService    = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService     = game:GetService("HttpService")
local RunService      = game:GetService("RunService")

local Library = {}

-- =====================================================
-- THEMES
-- =====================================================
Library.Themes = {
    Default = {
        MainParams  = {Color3.fromRGB(30, 30, 30), Color3.fromRGB(20, 20, 20)},
        Stroke      = Color3.fromRGB(60, 60, 60),
        Text        = Color3.fromRGB(255, 255, 255),
        SubText     = Color3.fromRGB(170, 170, 170),
        Accent      = Color3.fromRGB(0, 120, 215),
        AccentDark  = Color3.fromRGB(0, 90, 170),
        Element     = Color3.fromRGB(40, 40, 40),
        Hover       = Color3.fromRGB(55, 55, 55),
        TopBar      = Color3.fromRGB(25, 25, 25),
    },
    Dark = {
        MainParams  = {Color3.fromRGB(18, 18, 18), Color3.fromRGB(12, 12, 12)},
        Stroke      = Color3.fromRGB(45, 45, 45),
        Text        = Color3.fromRGB(230, 230, 230),
        SubText     = Color3.fromRGB(140, 140, 140),
        Accent      = Color3.fromRGB(220, 60, 60),
        AccentDark  = Color3.fromRGB(170, 40, 40),
        Element     = Color3.fromRGB(25, 25, 25),
        Hover       = Color3.fromRGB(38, 38, 38),
        TopBar      = Color3.fromRGB(15, 15, 15),
    },
    Light = {
        MainParams  = {Color3.fromRGB(248, 248, 248), Color3.fromRGB(232, 232, 232)},
        Stroke      = Color3.fromRGB(200, 200, 200),
        Text        = Color3.fromRGB(30, 30, 30),
        SubText     = Color3.fromRGB(100, 100, 100),
        Accent      = Color3.fromRGB(0, 140, 255),
        AccentDark  = Color3.fromRGB(0, 110, 200),
        Element     = Color3.fromRGB(238, 238, 238),
        Hover       = Color3.fromRGB(220, 220, 220),
        TopBar      = Color3.fromRGB(228, 228, 228),
    },
    Valentine = {
        MainParams  = {Color3.fromRGB(255, 228, 238), Color3.fromRGB(255, 208, 222)},
        Stroke      = Color3.fromRGB(255, 175, 200),
        Text        = Color3.fromRGB(160, 40, 75),
        SubText     = Color3.fromRGB(210, 100, 140),
        Accent      = Color3.fromRGB(255, 90, 140),
        AccentDark  = Color3.fromRGB(220, 60, 110),
        Element     = Color3.fromRGB(255, 238, 245),
        Hover       = Color3.fromRGB(255, 218, 232),
        TopBar      = Color3.fromRGB(255, 200, 218),
    },
    Midnight = {
        MainParams  = {Color3.fromRGB(14, 14, 28), Color3.fromRGB(8, 8, 18)},
        Stroke      = Color3.fromRGB(50, 50, 90),
        Text        = Color3.fromRGB(210, 210, 255),
        SubText     = Color3.fromRGB(130, 130, 190),
        Accent      = Color3.fromRGB(100, 80, 255),
        AccentDark  = Color3.fromRGB(70, 55, 200),
        Element     = Color3.fromRGB(22, 22, 45),
        Hover       = Color3.fromRGB(35, 35, 65),
        TopBar      = Color3.fromRGB(12, 12, 24),
    },
}

-- =====================================================
-- CONFIG SYSTEM
-- =====================================================
local ConfigTable = {}
local ConfigName  = "LibraryConfig.json"

local function SaveConfig()
    if writefile then
        local ok, err = pcall(function()
            writefile(ConfigName, HttpService:JSONEncode(ConfigTable))
        end)
        if not ok then
            warn("[UILibrary] SaveConfig failed:", err)
        end
    end
end

local function LoadConfig()
    if readfile and isfile and isfile(ConfigName) then
        local success, res = pcall(function()
            return HttpService:JSONDecode(readfile(ConfigName))
        end)
        if success and type(res) == "table" then
            ConfigTable = res
            return true
        end
    end
    return false
end

-- =====================================================
-- HELPER UTILITIES
-- =====================================================
local function Tween(obj, t, props, style, dir)
    style = style or Enum.EasingStyle.Quad
    dir   = dir   or Enum.EasingDirection.Out
    return TweenService:Create(obj, TweenInfo.new(t, style, dir), props)
end

local function CreateRoundedUI(Properties, Parent, CornerRadius)
    local className = Properties.ClassName or "Frame"
    Properties.ClassName = nil
    local element = Instance.new(className)
    for k, v in pairs(Properties) do
        pcall(function() element[k] = v end)
    end
    element.Parent = Parent
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = CornerRadius or UDim.new(0, 6)
    UICorner.Parent = element
    return element
end

local function AddPadding(parent, top, bottom, left, right)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, top    or 0)
    p.PaddingBottom = UDim.new(0, bottom or 0)
    p.PaddingLeft   = UDim.new(0, left   or 0)
    p.PaddingRight  = UDim.new(0, right  or 0)
    p.Parent = parent
end

local function MakeShadow(parent)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0.5, 0, 0.5, 4)
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Image = "rbxassetid://6014261993"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.Parent = parent
end

-- =====================================================
-- MAIN WINDOW
-- =====================================================
function Library.CreateWindow(WindowName, ThemeName, Options)
    WindowName = WindowName or "UI Library"
    ThemeName  = ThemeName  or "Default"
    Options    = Options    or {}

    local Theme     = Library.Themes[ThemeName] or Library.Themes.Default
    local ToggleKey = Options.ToggleKey or Enum.KeyCode.RightShift

    LoadConfig()

    -- Cleanup old instance
    local oldGui = CoreGui:FindFirstChild("CustomUI_Library_v2")
    if oldGui then oldGui:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name            = "CustomUI_Library_v2"
    ScreenGui.Parent          = CoreGui
    ScreenGui.ResetOnSpawn    = false
    ScreenGui.IgnoreGuiInset  = true
    ScreenGui.DisplayOrder    = 999

    -- =====================================================
    -- NOTIFICATION SYSTEM (top-right, stacked, animated)
    -- =====================================================
    local NotifContainer = Instance.new("Frame")
    NotifContainer.Name                = "NotifContainer"
    NotifContainer.Parent              = ScreenGui
    NotifContainer.BackgroundTransparency = 1
    NotifContainer.Position            = UDim2.new(1, -15, 0, 15)
    NotifContainer.Size                = UDim2.new(0, 260, 1, -30)
    NotifContainer.AnchorPoint         = Vector2.new(1, 0)
    NotifContainer.ZIndex              = 100

    local NotifList = Instance.new("UIListLayout")
    NotifList.Parent             = NotifContainer
    NotifList.SortOrder          = Enum.SortOrder.LayoutOrder
    NotifList.VerticalAlignment  = Enum.VerticalAlignment.Top
    NotifList.HorizontalAlignment = Enum.HorizontalAlignment.Right
    NotifList.Padding            = UDim.new(0, 6)

    local notifCount = 0

    local function Notify(title, message, duration, notifType)
        duration  = duration  or 3
        notifType = notifType or "info" -- "info" | "success" | "warning" | "error"
        notifCount = notifCount + 1

        local accentColor = Theme.Accent
        if notifType == "success" then
            accentColor = Color3.fromRGB(50, 200, 100)
        elseif notifType == "warning" then
            accentColor = Color3.fromRGB(255, 180, 0)
        elseif notifType == "error" then
            accentColor = Color3.fromRGB(220, 60, 60)
        end

        local NFrame = CreateRoundedUI({
            ClassName            = "Frame",
            BackgroundColor3     = Theme.Element,
            Size                 = UDim2.new(1, 0, 0, 0),
            ClipsDescendants     = true,
            LayoutOrder          = notifCount,
            BackgroundTransparency = 0,
        }, NotifContainer, UDim.new(0, 8))

        local NStroke = Instance.new("UIStroke")
        NStroke.Color     = accentColor
        NStroke.Thickness = 1.5
        NStroke.Parent    = NFrame

        -- Accent bar on left
        local AccentBar = Instance.new("Frame")
        AccentBar.BackgroundColor3 = accentColor
        AccentBar.BorderSizePixel  = 0
        AccentBar.Size             = UDim2.new(0, 3, 1, 0)
        AccentBar.ZIndex           = NFrame.ZIndex + 1
        AccentBar.Parent           = NFrame
        local BarCorner = Instance.new("UICorner")
        BarCorner.CornerRadius = UDim.new(0, 3)
        BarCorner.Parent = AccentBar

        local NTitle = Instance.new("TextLabel")
        NTitle.BackgroundTransparency = 1
        NTitle.Position    = UDim2.new(0, 12, 0, 8)
        NTitle.Size        = UDim2.new(1, -16, 0, 18)
        NTitle.Font        = Enum.Font.GothamBold
        NTitle.Text        = tostring(title)
        NTitle.TextColor3  = Theme.Text
        NTitle.TextSize    = 13
        NTitle.TextXAlignment = Enum.TextXAlignment.Left
        NTitle.ZIndex      = NFrame.ZIndex + 1
        NTitle.Parent      = NFrame

        local NDesc = Instance.new("TextLabel")
        NDesc.BackgroundTransparency = 1
        NDesc.Position    = UDim2.new(0, 12, 0, 28)
        NDesc.Size        = UDim2.new(1, -16, 0, 32)
        NDesc.Font        = Enum.Font.Gotham
        NDesc.Text        = tostring(message)
        NDesc.TextColor3  = Theme.SubText
        NDesc.TextSize    = 11
        NDesc.TextWrapped = true
        NDesc.TextXAlignment = Enum.TextXAlignment.Left
        NDesc.TextYAlignment = Enum.TextYAlignment.Top
        NDesc.ZIndex      = NFrame.ZIndex + 1
        NDesc.Parent      = NFrame

        -- Progress bar
        local ProgressBg = Instance.new("Frame")
        ProgressBg.BackgroundColor3 = Theme.Stroke
        ProgressBg.BorderSizePixel  = 0
        ProgressBg.Size             = UDim2.new(1, 0, 0, 2)
        ProgressBg.Position         = UDim2.new(0, 0, 1, -2)
        ProgressBg.ZIndex           = NFrame.ZIndex + 2
        ProgressBg.Parent           = NFrame

        local ProgressFill = Instance.new("Frame")
        ProgressFill.BackgroundColor3 = accentColor
        ProgressFill.BorderSizePixel  = 0
        ProgressFill.Size             = UDim2.new(1, 0, 1, 0)
        ProgressFill.ZIndex           = NFrame.ZIndex + 3
        ProgressFill.Parent           = ProgressBg

        -- Slide in
        NFrame.Position = UDim2.new(1, 10, 0, 0)
        Tween(NFrame, 0.35, {Size = UDim2.new(1, 0, 0, 70)}, Enum.EasingStyle.Back):Play()
        task.delay(0.05, function()
            Tween(NFrame, 0.3, {Position = UDim2.new(0, 0, 0, 0)}, Enum.EasingStyle.Quart):Play()
        end)

        -- Progress drain
        task.spawn(function()
            Tween(ProgressFill, duration, {Size = UDim2.new(0, 0, 1, 0)}, Enum.EasingStyle.Linear):Play()
            task.wait(duration)
            local fadeOut = Tween(NFrame, 0.3, {Position = UDim2.new(1, 10, 0, 0)}, Enum.EasingStyle.Quart)
            fadeOut:Play()
            fadeOut.Completed:Wait()
            Tween(NFrame, 0.2, {Size = UDim2.new(1, 0, 0, 0)}):Play()
            task.wait(0.25)
            NFrame:Destroy()
        end)
    end
    Library.Notify = Notify

    -- =====================================================
    -- MAIN FRAME
    -- =====================================================
    local WIN_W, WIN_H = 520, 360
    local MainFrame = CreateRoundedUI({
        ClassName        = "Frame",
        Size             = UDim2.new(0, WIN_W, 0, WIN_H),
        Position         = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2),
        BackgroundColor3 = Color3.new(1, 1, 1),
        ClipsDescendants = false,
        Active           = true,
    }, ScreenGui, UDim.new(0, 8))

    MakeShadow(MainFrame)

    -- Gradient background
    local UIGradient = Instance.new("UIGradient")
    UIGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Theme.MainParams[1]),
        ColorSequenceKeypoint.new(1, Theme.MainParams[2])
    }
    UIGradient.Rotation = 135
    UIGradient.Parent   = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color     = Theme.Stroke
    MainStroke.Thickness = 1
    MainStroke.Parent    = MainFrame

    -- Inner clip frame (keeps children clipped)
    local ClipFrame = Instance.new("Frame")
    ClipFrame.BackgroundTransparency = 1
    ClipFrame.Size             = UDim2.new(1, 0, 1, 0)
    ClipFrame.ClipsDescendants = true
    ClipFrame.Parent           = MainFrame
    local ClipCorner = Instance.new("UICorner")
    ClipCorner.CornerRadius = UDim.new(0, 8)
    ClipCorner.Parent = ClipFrame

    -- =====================================================
    -- TOP BAR
    -- =====================================================
    local TopBar = Instance.new("Frame")
    TopBar.BackgroundColor3 = Theme.TopBar
    TopBar.BorderSizePixel  = 0
    TopBar.Size             = UDim2.new(1, 0, 0, 42)
    TopBar.ZIndex           = 5
    TopBar.Parent           = ClipFrame

    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 8)
    TopCorner.Parent = TopBar

    -- Cover bottom corners of topbar
    local TopBarFix = Instance.new("Frame")
    TopBarFix.BackgroundColor3 = Theme.TopBar
    TopBarFix.BorderSizePixel  = 0
    TopBarFix.Size             = UDim2.new(1, 0, 0, 8)
    TopBarFix.Position         = UDim2.new(0, 0, 1, -8)
    TopBarFix.ZIndex           = 4
    TopBarFix.Parent           = TopBar

    -- Accent line under topbar
    local AccentLine = Instance.new("Frame")
    AccentLine.BackgroundColor3 = Theme.Accent
    AccentLine.BorderSizePixel  = 0
    AccentLine.Size             = UDim2.new(1, 0, 0, 2)
    AccentLine.Position         = UDim2.new(0, 0, 1, -2)
    AccentLine.ZIndex           = 6
    AccentLine.Parent           = TopBar

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position    = UDim2.new(0, 14, 0, 0)
    TitleLabel.Size        = UDim2.new(0.6, 0, 1, 0)
    TitleLabel.Font        = Enum.Font.GothamBold
    TitleLabel.Text        = WindowName
    TitleLabel.TextColor3  = Theme.Text
    TitleLabel.TextSize    = 15
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.ZIndex      = 6
    TitleLabel.Parent      = TopBar

    -- Keybind hint label
    local KeyHint = Instance.new("TextLabel")
    KeyHint.BackgroundTransparency = 1
    KeyHint.Position    = UDim2.new(0, 14, 0, 0)
    KeyHint.Size        = UDim2.new(0.6, 0, 1, 0)
    KeyHint.Font        = Enum.Font.Gotham
    KeyHint.Text        = "[" .. tostring(ToggleKey.Name) .. "] to toggle"
    KeyHint.TextColor3  = Theme.SubText
    KeyHint.TextSize    = 10
    KeyHint.TextXAlignment = Enum.TextXAlignment.Left
    KeyHint.TextYAlignment = Enum.TextYAlignment.Bottom
    KeyHint.ZIndex      = 6
    KeyHint.Parent      = TopBar

    -- Window control buttons
    local function MakeTopBtn(xOffset, label, hoverColor)
        local Btn = Instance.new("TextButton")
        Btn.BackgroundTransparency = 1
        Btn.Position    = UDim2.new(1, xOffset, 0, 0)
        Btn.Size        = UDim2.new(0, 36, 1, 0)
        Btn.Font        = Enum.Font.GothamBold
        Btn.Text        = label
        Btn.TextColor3  = Theme.SubText
        Btn.TextSize    = 14
        Btn.ZIndex      = 7
        Btn.AutoButtonColor = false
        Btn.Parent      = TopBar
        Btn.MouseEnter:Connect(function()
            Tween(Btn, 0.15, {TextColor3 = hoverColor}):Play()
        end)
        Btn.MouseLeave:Connect(function()
            Tween(Btn, 0.15, {TextColor3 = Theme.SubText}):Play()
        end)
        return Btn
    end

    local CloseBtn = MakeTopBtn(-36,  "✕", Color3.fromRGB(255, 70, 70))
    local MinBtn   = MakeTopBtn(-72,  "−", Theme.Text)

    -- Dragging logic (manual, more reliable than Draggable)
    local draggingWin, dragStart, startPos
    TopBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingWin = true
            dragStart   = inp.Position
            startPos    = MainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if draggingWin and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = inp.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingWin = false
        end
    end)

    local minimized = false
    local uiVisible = true

    CloseBtn.MouseButton1Click:Connect(function()
        Tween(MainFrame, 0.25, {Size = UDim2.new(0, WIN_W, 0, 0)}, Enum.EasingStyle.Quart):Play()
        task.wait(0.28)
        ScreenGui:Destroy()
    end)

    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        local targetH = minimized and 42 or WIN_H
        Tween(MainFrame, 0.35, {Size = UDim2.new(0, WIN_W, 0, targetH)}, Enum.EasingStyle.Exponential):Play()
        MinBtn.Text = minimized and "□" or "−"
    end)

    -- =====================================================
    -- FLOATING TOGGLE BUTTON (draggable)
    -- =====================================================
    local FloatBtn = CreateRoundedUI({
        ClassName        = "TextButton",
        BackgroundColor3 = Theme.Accent,
        Size             = UDim2.new(0, 46, 0, 46),
        Position         = UDim2.new(0, 20, 0, 20),
        Text             = "☰",
        Font             = Enum.Font.GothamBold,
        TextColor3       = Color3.new(1, 1, 1),
        TextSize         = 22,
        Visible          = false,
        ZIndex           = 200,
    }, ScreenGui, UDim.new(1, 0))
    MakeShadow(FloatBtn)
    FloatBtn.Shadow.ZIndex = 199

    local UIStrokeFloat = Instance.new("UIStroke")
    UIStrokeFloat.Color     = Theme.AccentDark
    UIStrokeFloat.Thickness = 2
    UIStrokeFloat.Parent    = FloatBtn

    -- Dragging for float button
    local floatDragging, floatDragStart, floatStartPos
    local floatMoved = false
    FloatBtn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            floatDragging  = true
            floatMoved     = false
            floatDragStart = inp.Position
            floatStartPos  = FloatBtn.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if floatDragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = inp.Position - floatDragStart
            if math.abs(delta.X) + math.abs(delta.Y) > 5 then
                floatMoved = true
            end
            FloatBtn.Position = UDim2.new(
                floatStartPos.X.Scale, floatStartPos.X.Offset + delta.X,
                floatStartPos.Y.Scale, floatStartPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 and floatDragging then
            floatDragging = false
            if not floatMoved then
                -- Show main UI
                uiVisible       = true
                FloatBtn.Visible = false
                MainFrame.Visible = true
                MainFrame.Size   = UDim2.new(0, WIN_W, 0, 0)
                Tween(MainFrame, 0.4, {Size = UDim2.new(0, WIN_W, 0, minimized and 42 or WIN_H)}, Enum.EasingStyle.Back):Play()
            end
        end
    end)

    -- =====================================================
    -- KEYBIND TOGGLE (RightShift by default, ignores typing)
    -- =====================================================
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        -- Also ignore if user is typing in a TextBox
        local focused = UserInputService:GetFocusedTextBox()
        if focused then return end

        if input.KeyCode == ToggleKey then
            uiVisible = not uiVisible
            if uiVisible then
                FloatBtn.Visible  = false
                MainFrame.Visible = true
                MainFrame.Size    = UDim2.new(0, WIN_W, 0, 0)
                Tween(MainFrame, 0.4, {Size = UDim2.new(0, WIN_W, 0, minimized and 42 or WIN_H)}, Enum.EasingStyle.Back):Play()
            else
                local t = Tween(MainFrame, 0.25, {Size = UDim2.new(0, WIN_W, 0, 0)}, Enum.EasingStyle.Quart)
                t:Play()
                t.Completed:Connect(function()
                    if not uiVisible then
                        MainFrame.Visible = false
                        FloatBtn.Visible  = true
                        Tween(FloatBtn, 0.3, {Size = UDim2.new(0, 46, 0, 46)}, Enum.EasingStyle.Back):Play()
                    end
                end)
            end
        end
    end)

    -- =====================================================
    -- TAB SYSTEM
    -- =====================================================
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.BackgroundColor3       = Theme.TopBar
    TabContainer.BorderSizePixel        = 0
    TabContainer.Position               = UDim2.new(0, 0, 0, 42)
    TabContainer.Size                   = UDim2.new(0, 140, 1, -42)
    TabContainer.ScrollBarThickness     = 2
    TabContainer.ScrollBarImageColor3   = Theme.Accent
    TabContainer.CanvasSize             = UDim2.new(0, 0, 0, 0)
    TabContainer.Parent                 = ClipFrame

    local TabRightBorder = Instance.new("Frame")
    TabRightBorder.BackgroundColor3 = Theme.Stroke
    TabRightBorder.BorderSizePixel  = 0
    TabRightBorder.Size             = UDim2.new(0, 1, 1, 0)
    TabRightBorder.Position         = UDim2.new(1, -1, 0, 0)
    TabRightBorder.Parent           = TabContainer

    local TabList = Instance.new("UIListLayout")
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding   = UDim.new(0, 3)
    TabList.Parent    = TabContainer
    AddPadding(TabContainer, 8, 8, 8, 8)

    TabList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabContainer.CanvasSize = UDim2.new(0, 0, 0, TabList.AbsoluteContentSize.Y + 16)
    end)

    local PagesContainer = Instance.new("Frame")
    PagesContainer.BackgroundTransparency = 1
    PagesContainer.Position               = UDim2.new(0, 142, 0, 46)
    PagesContainer.Size                   = UDim2.new(1, -148, 1, -52)
    PagesContainer.Parent                 = ClipFrame

    local allTabs  = {}
    local allPages = {}
    local firstTab = true

    local TabHandler = {}

    function TabHandler.CreateTab(TabName, TabIcon)
        local isFirst = firstTab
        if firstTab then firstTab = false end

        local TabBtn = CreateRoundedUI({
            ClassName        = "TextButton",
            BackgroundColor3 = isFirst and Theme.Accent or Theme.Element,
            Size             = UDim2.new(1, 0, 0, 34),
            Font             = Enum.Font.GothamSemiBold,
            Text             = (TabIcon and (TabIcon .. "  ") or "") .. TabName,
            TextColor3       = isFirst and Color3.new(1,1,1) or Theme.SubText,
            TextSize         = 12,
            AutoButtonColor  = false,
            ZIndex           = 3,
        }, TabContainer, UDim.new(0, 6))

        table.insert(allTabs, TabBtn)

        local Page = Instance.new("ScrollingFrame")
        Page.BackgroundTransparency      = 1
        Page.Size                        = UDim2.new(1, 0, 1, 0)
        Page.ScrollBarThickness          = 3
        Page.ScrollBarImageColor3        = Theme.Accent
        Page.Visible                     = isFirst
        Page.CanvasSize                  = UDim2.new(0, 0, 0, 0)
        Page.Parent                      = PagesContainer
        table.insert(allPages, Page)

        local PageList = Instance.new("UIListLayout")
        PageList.SortOrder = Enum.SortOrder.LayoutOrder
        PageList.Padding   = UDim.new(0, 6)
        PageList.Parent    = Page
        AddPadding(Page, 4, 8, 0, 4)

        PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 16)
        end)

        local function SelectTab()
            for _, tb in ipairs(allTabs) do
                Tween(tb, 0.25, {BackgroundColor3 = Theme.Element, TextColor3 = Theme.SubText}):Play()
            end
            for _, pg in ipairs(allPages) do
                pg.Visible = false
            end
            Tween(TabBtn, 0.25, {BackgroundColor3 = Theme.Accent, TextColor3 = Color3.new(1,1,1)}):Play()
            Page.Visible = true
        end

        TabBtn.MouseButton1Click:Connect(SelectTab)
        TabBtn.MouseEnter:Connect(function()
            if Page.Visible then return end
            Tween(TabBtn, 0.15, {BackgroundColor3 = Theme.Hover}):Play()
        end)
        TabBtn.MouseLeave:Connect(function()
            if Page.Visible then return end
            Tween(TabBtn, 0.15, {BackgroundColor3 = Theme.Element}):Play()
        end)

        -- =====================================================
        -- ELEMENTS
        -- =====================================================
        local Elements = {}

        -- ----- SECTION LABEL -----
        function Elements.CreateSection(sectionName)
            local SFrame = Instance.new("Frame")
            SFrame.BackgroundTransparency = 1
            SFrame.Size   = UDim2.new(1, -4, 0, 26)
            SFrame.Parent = Page

            local SLine = Instance.new("Frame")
            SLine.BackgroundColor3 = Theme.Stroke
            SLine.BorderSizePixel  = 0
            SLine.Size             = UDim2.new(1, 0, 0, 1)
            SLine.Position         = UDim2.new(0, 0, 0.5, 0)
            SLine.Parent           = SFrame

            local SLabel = Instance.new("TextLabel")
            SLabel.BackgroundColor3    = Theme.MainParams[1]
            SLabel.BackgroundTransparency = 0
            SLabel.BorderSizePixel     = 0
            SLabel.Position            = UDim2.new(0, 8, 0, 4)
            SLabel.Size                = UDim2.new(0, 0, 0, 18)
            SLabel.AutomaticSize       = Enum.AutomaticSize.X
            SLabel.Font                = Enum.Font.GothamBold
            SLabel.Text                = "  " .. sectionName .. "  "
            SLabel.TextColor3          = Theme.SubText
            SLabel.TextSize            = 11
            SLabel.Parent              = SFrame
        end

        -- ----- LABEL -----
        function Elements.CreateLabel(text)
            local L = Instance.new("TextLabel")
            L.BackgroundTransparency = 1
            L.Size         = UDim2.new(1, -4, 0, 24)
            L.Font         = Enum.Font.Gotham
            L.Text         = text
            L.TextColor3   = Theme.SubText
            L.TextSize     = 12
            L.TextXAlignment = Enum.TextXAlignment.Left
            L.TextWrapped  = true
            L.Parent       = Page

            local function SetText(newText)
                L.Text = newText
            end
            return {SetText = SetText}
        end

        -- ----- BUTTON -----
        function Elements.CreateButton(text, callback)
            callback = callback or function() end

            local Btn = CreateRoundedUI({
                ClassName        = "TextButton",
                BackgroundColor3 = Theme.Element,
                Size             = UDim2.new(1, -4, 0, 36),
                Font             = Enum.Font.GothamSemiBold,
                Text             = text,
                TextColor3       = Theme.Text,
                TextSize         = 13,
                AutoButtonColor  = false,
            }, Page)

            Instance.new("UIStroke", Btn).Color = Theme.Stroke

            Btn.MouseEnter:Connect(function()
                Tween(Btn, 0.15, {BackgroundColor3 = Theme.Hover}):Play()
            end)
            Btn.MouseLeave:Connect(function()
                Tween(Btn, 0.15, {BackgroundColor3 = Theme.Element}):Play()
            end)
            Btn.MouseButton1Click:Connect(function()
                local t = Tween(Btn, 0.08, {BackgroundColor3 = Theme.Accent})
                t:Play()
                t.Completed:Wait()
                Tween(Btn, 0.15, {BackgroundColor3 = Theme.Hover}):Play()
                task.spawn(callback)
            end)

            return {
                SetText = function(t) Btn.Text = t end,
                SetCallback = function(cb) callback = cb end,
            }
        end

        -- ----- TOGGLE -----
        function Elements.CreateToggle(text, default, callback)
            callback = callback or function() end
            local toggled = default or false
            if ConfigTable[text] ~= nil then toggled = ConfigTable[text] else ConfigTable[text] = toggled end

            local ToggleFrame = CreateRoundedUI({
                ClassName        = "TextButton",
                BackgroundColor3 = Theme.Element,
                Size             = UDim2.new(1, -4, 0, 36),
                Font             = Enum.Font.Gotham,
                Text             = "   " .. text,
                TextColor3       = Theme.Text,
                TextSize         = 13,
                TextXAlignment   = Enum.TextXAlignment.Left,
                AutoButtonColor  = false,
            }, Page)
            Instance.new("UIStroke", ToggleFrame).Color = Theme.Stroke

            local TrackBg = CreateRoundedUI({
                ClassName        = "Frame",
                BackgroundColor3 = toggled and Theme.Accent or Theme.Stroke,
                Size             = UDim2.new(0, 42, 0, 22),
                Position         = UDim2.new(1, -50, 0.5, -11),
            }, ToggleFrame, UDim.new(1, 0))

            local Knob = CreateRoundedUI({
                ClassName        = "Frame",
                BackgroundColor3 = Color3.new(1, 1, 1),
                Size             = UDim2.new(0, 16, 0, 16),
                Position         = toggled and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
            }, TrackBg, UDim.new(1, 0))

            local function SetState(state, silent)
                toggled = state
                ConfigTable[text] = toggled
                if not silent then SaveConfig() end
                Tween(Knob,    0.2, {Position = toggled and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)}, Enum.EasingStyle.Quart):Play()
                Tween(TrackBg, 0.2, {BackgroundColor3 = toggled and Theme.Accent or Theme.Stroke}):Play()
                if not silent then task.spawn(callback, toggled) end
            end

            ToggleFrame.MouseEnter:Connect(function()
                Tween(ToggleFrame, 0.15, {BackgroundColor3 = Theme.Hover}):Play()
            end)
            ToggleFrame.MouseLeave:Connect(function()
                Tween(ToggleFrame, 0.15, {BackgroundColor3 = Theme.Element}):Play()
            end)
            ToggleFrame.MouseButton1Click:Connect(function()
                SetState(not toggled)
            end)

            task.spawn(callback, toggled)

            return {
                SetState    = SetState,
                GetState    = function() return toggled end,
                SetCallback = function(cb) callback = cb end,
            }
        end

        -- ----- SLIDER -----
        function Elements.CreateSlider(text, min, max, default, step, callback)
            -- Allow old 4-arg call: (text, min, max, default, callback)
            if type(step) == "function" then
                callback = step
                step     = 1
            end
            callback = callback or function() end
            step     = step or 1
            min      = min  or 0
            max      = max  or 100
            local value = default or min
            if ConfigTable[text] ~= nil then value = ConfigTable[text] else ConfigTable[text] = value end
            value = math.clamp(value, min, max)

            local SliderFrame = CreateRoundedUI({
                ClassName        = "Frame",
                BackgroundColor3 = Theme.Element,
                Size             = UDim2.new(1, -4, 0, 54),
            }, Page)
            Instance.new("UIStroke", SliderFrame).Color = Theme.Stroke

            local LabelRow = Instance.new("Frame")
            LabelRow.BackgroundTransparency = 1
            LabelRow.Size     = UDim2.new(1, -16, 0, 22)
            LabelRow.Position = UDim2.new(0, 8, 0, 6)
            LabelRow.Parent   = SliderFrame

            local TextLbl = Instance.new("TextLabel")
            TextLbl.BackgroundTransparency = 1
            TextLbl.Size           = UDim2.new(1, -50, 1, 0)
            TextLbl.Font           = Enum.Font.Gotham
            TextLbl.Text           = text
            TextLbl.TextColor3     = Theme.Text
            TextLbl.TextSize       = 13
            TextLbl.TextXAlignment = Enum.TextXAlignment.Left
            TextLbl.Parent         = LabelRow

            local ValBox = CreateRoundedUI({
                ClassName        = "TextBox",
                BackgroundColor3 = Theme.TopBar,
                Size             = UDim2.new(0, 48, 1, 0),
                Position         = UDim2.new(1, -48, 0, 0),
                Font             = Enum.Font.GothamBold,
                Text             = tostring(value),
                TextColor3       = Theme.Accent,
                TextSize         = 12,
                ClearTextOnFocus = false,
            }, LabelRow, UDim.new(0, 4))

            local TrackBg = CreateRoundedUI({
                ClassName        = "Frame",
                BackgroundColor3 = Theme.Stroke,
                Size             = UDim2.new(1, -16, 0, 6),
                Position         = UDim2.new(0, 8, 0, 38),
            }, SliderFrame, UDim.new(1, 0))

            local Fill = CreateRoundedUI({
                ClassName        = "Frame",
                BackgroundColor3 = Theme.Accent,
                Size             = UDim2.new((value - min) / math.max(max - min, 0.001), 0, 1, 0),
            }, TrackBg, UDim.new(1, 0))

            local Knob = CreateRoundedUI({
                ClassName        = "Frame",
                BackgroundColor3 = Color3.new(1, 1, 1),
                Size             = UDim2.new(0, 12, 0, 12),
                Position         = UDim2.new((value - min) / math.max(max - min, 0.001), -6, 0.5, -6),
                ZIndex           = 3,
            }, TrackBg, UDim.new(1, 0))

            local function UpdateValue(newVal, silent)
                newVal = math.clamp(math.round(newVal / step) * step, min, max)
                value  = newVal
                local pct = (value - min) / math.max(max - min, 0.001)
                Tween(Fill, 0.08, {Size = UDim2.new(pct, 0, 1, 0)}):Play()
                Tween(Knob, 0.08, {Position = UDim2.new(pct, -6, 0.5, -6)}):Play()
                ValBox.Text = tostring(value)
                ConfigTable[text] = value
                if not silent then SaveConfig() end
                if not silent then task.spawn(callback, value) end
            end

            -- Mouse drag
            local sliderDragging = false
            local function GetValueFromInput(inp)
                local pct = math.clamp((inp.Position.X - TrackBg.AbsolutePosition.X) / TrackBg.AbsoluteSize.X, 0, 1)
                return min + (max - min) * pct
            end

            TrackBg.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    sliderDragging = true
                    UpdateValue(GetValueFromInput(inp))
                end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if sliderDragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
                    UpdateValue(GetValueFromInput(inp))
                end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    sliderDragging = false
                end
            end)

            -- Manual input via TextBox
            ValBox.FocusLost:Connect(function()
                local n = tonumber(ValBox.Text)
                if n then
                    UpdateValue(n)
                else
                    ValBox.Text = tostring(value)
                end
            end)

            task.spawn(callback, value)

            return {
                SetValue    = function(v) UpdateValue(v, false) end,
                GetValue    = function() return value end,
                SetCallback = function(cb) callback = cb end,
            }
        end

        -- ----- DROPDOWN -----
        function Elements.CreateDropdown(text, list, defaultIndex, callback)
            -- Handle old 3-arg call: (text, list, callback)
            if type(defaultIndex) == "function" then
                callback     = defaultIndex
                defaultIndex = 1
            end
            callback     = callback     or function() end
            defaultIndex = defaultIndex or 1
            list         = list         or {}

            local selected = list[defaultIndex] or (list[1])
            if ConfigTable[text] ~= nil then
                -- validate saved value is still in list
                local found = false
                for _, v in ipairs(list) do if v == ConfigTable[text] then found = true break end end
                if found then selected = ConfigTable[text] end
            end
            ConfigTable[text] = selected

            local ITEM_H    = 28
            local openH     = 36 + math.min(#list, 6) * ITEM_H + 4
            local isOpen    = false

            local DropOuter = CreateRoundedUI({
                ClassName        = "Frame",
                BackgroundColor3 = Theme.Element,
                Size             = UDim2.new(1, -4, 0, 36),
                ClipsDescendants = false,
                ZIndex           = 10,
            }, Page, UDim.new(0, 6))
            Instance.new("UIStroke", DropOuter).Color = Theme.Stroke

            -- Header button
            local Header = Instance.new("TextButton")
            Header.BackgroundTransparency = 1
            Header.Size            = UDim2.new(1, 0, 0, 36)
            Header.Font            = Enum.Font.Gotham
            Header.Text            = ""
            Header.TextColor3      = Theme.Text
            Header.TextSize        = 13
            Header.AutoButtonColor = false
            Header.ZIndex          = 11
            Header.Parent          = DropOuter

            local HeaderLabel = Instance.new("TextLabel")
            HeaderLabel.BackgroundTransparency = 1
            HeaderLabel.Position   = UDim2.new(0, 10, 0, 0)
            HeaderLabel.Size       = UDim2.new(1, -40, 1, 0)
            HeaderLabel.Font       = Enum.Font.Gotham
            HeaderLabel.Text       = text .. ":  " .. tostring(selected)
            HeaderLabel.TextColor3 = Theme.Text
            HeaderLabel.TextSize   = 13
            HeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
            HeaderLabel.ZIndex     = 11
            HeaderLabel.Parent     = Header

            local Arrow = Instance.new("TextLabel")
            Arrow.BackgroundTransparency = 1
            Arrow.Position   = UDim2.new(1, -32, 0, 0)
            Arrow.Size       = UDim2.new(0, 28, 1, 0)
            Arrow.Font       = Enum.Font.GothamBold
            Arrow.Text       = "▾"
            Arrow.TextColor3 = Theme.SubText
            Arrow.TextSize   = 14
            Arrow.ZIndex     = 11
            Arrow.Parent     = Header

            -- Dropdown list (overlays, not clipped)
            local ListOuter = CreateRoundedUI({
                ClassName        = "Frame",
                BackgroundColor3 = Theme.Element,
                Size             = UDim2.new(1, 0, 0, 0),
                Position         = UDim2.new(0, 0, 1, 2),
                ClipsDescendants = true,
                Visible          = false,
                ZIndex           = 50,
            }, DropOuter, UDim.new(0, 6))
            local ListOuterStroke = Instance.new("UIStroke")
            ListOuterStroke.Color = Theme.Stroke
            ListOuterStroke.Parent = ListOuter

            local ListScroll = Instance.new("ScrollingFrame")
            ListScroll.BackgroundTransparency = 1
            ListScroll.Size               = UDim2.new(1, 0, 1, 0)
            ListScroll.ScrollBarThickness = 3
            ListScroll.ScrollBarImageColor3 = Theme.Accent
            ListScroll.CanvasSize         = UDim2.new(0, 0, 0, #list * ITEM_H)
            ListScroll.ZIndex             = 51
            ListScroll.Parent             = ListOuter
            AddPadding(ListScroll, 3, 3, 0, 0)

            local ItemLayout = Instance.new("UIListLayout")
            ItemLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ItemLayout.Parent    = ListScroll

            local function RefreshHeader()
                HeaderLabel.Text = text .. ":  " .. tostring(selected)
            end

            local function Close()
                isOpen = false
                Arrow.Text = "▾"
                Tween(ListOuter, 0.2, {Size = UDim2.new(1, 0, 0, 0)}, Enum.EasingStyle.Quart):Play()
                task.delay(0.22, function() ListOuter.Visible = false end)
            end

            local function Open()
                isOpen = true
                Arrow.Text = "▴"
                ListOuter.Visible = true
                ListOuter.Size    = UDim2.new(1, 0, 0, 0)
                Tween(ListOuter, 0.25, {Size = UDim2.new(1, 0, 0, math.min(#list, 6) * ITEM_H + 6)}, Enum.EasingStyle.Quart):Play()
            end

            Header.MouseButton1Click:Connect(function()
                if isOpen then Close() else Open() end
            end)

            for i, item in ipairs(list) do
                local ItemBtn = Instance.new("TextButton")
                ItemBtn.BackgroundColor3 = Theme.Element
                ItemBtn.BorderSizePixel  = 0
                ItemBtn.Size             = UDim2.new(1, 0, 0, ITEM_H)
                ItemBtn.Font             = Enum.Font.Gotham
                ItemBtn.Text             = "  " .. tostring(item)
                ItemBtn.TextColor3       = item == selected and Theme.Accent or Theme.Text
                ItemBtn.TextSize         = 12
                ItemBtn.TextXAlignment   = Enum.TextXAlignment.Left
                ItemBtn.AutoButtonColor  = false
                ItemBtn.ZIndex           = 52
                ItemBtn.LayoutOrder      = i
                ItemBtn.Parent           = ListScroll

                ItemBtn.MouseEnter:Connect(function()
                    Tween(ItemBtn, 0.1, {BackgroundColor3 = Theme.Hover}):Play()
                end)
                ItemBtn.MouseLeave:Connect(function()
                    Tween(ItemBtn, 0.1, {BackgroundColor3 = Theme.Element}):Play()
                end)
                ItemBtn.MouseButton1Click:Connect(function()
                    -- Reset all items
                    for _, child in ipairs(ListScroll:GetChildren()) do
                        if child:IsA("TextButton") then
                            child.TextColor3 = Theme.Text
                        end
                    end
                    ItemBtn.TextColor3 = Theme.Accent
                    selected = item
                    ConfigTable[text] = selected
                    SaveConfig()
                    RefreshHeader()
                    Close()
                    task.spawn(callback, selected)
                end)
            end

            task.spawn(callback, selected)

            return {
                GetSelected = function() return selected end,
                SetSelected = function(val)
                    for _, child in ipairs(ListScroll:GetChildren()) do
                        if child:IsA("TextButton") then
                            local stripped = child.Text:sub(3)
                            child.TextColor3 = stripped == tostring(val) and Theme.Accent or Theme.Text
                        end
                    end
                    selected = val
                    RefreshHeader()
                    task.spawn(callback, selected)
                end,
                SetCallback = function(cb) callback = cb end,
            }
        end

        -- ----- TEXTBOX -----
        function Elements.CreateTextbox(text, placeholder, default, callback)
            callback    = callback    or function() end
            placeholder = placeholder or ""
            default     = default     or ""
            local val = default
            if ConfigTable[text] ~= nil then val = ConfigTable[text] else ConfigTable[text] = val end

            local TFrame = CreateRoundedUI({
                ClassName        = "Frame",
                BackgroundColor3 = Theme.Element,
                Size             = UDim2.new(1, -4, 0, 54),
            }, Page)
            Instance.new("UIStroke", TFrame).Color = Theme.Stroke

            local TLabel = Instance.new("TextLabel")
            TLabel.BackgroundTransparency = 1
            TLabel.Position    = UDim2.new(0, 10, 0, 6)
            TLabel.Size        = UDim2.new(1, -16, 0, 18)
            TLabel.Font        = Enum.Font.Gotham
            TLabel.Text        = text
            TLabel.TextColor3  = Theme.Text
            TLabel.TextSize    = 13
            TLabel.TextXAlignment = Enum.TextXAlignment.Left
            TLabel.Parent      = TFrame

            local InputBox = CreateRoundedUI({
                ClassName           = "TextBox",
                BackgroundColor3    = Theme.TopBar,
                Size                = UDim2.new(1, -16, 0, 22),
                Position            = UDim2.new(0, 8, 0, 26),
                Font                = Enum.Font.Gotham,
                Text                = val,
                PlaceholderText     = placeholder,
                PlaceholderColor3   = Theme.SubText,
                TextColor3          = Theme.Text,
                TextSize            = 12,
                ClearTextOnFocus    = false,
            }, TFrame, UDim.new(0, 4))
            AddPadding(InputBox, 0, 0, 6, 6)

            local InputStroke = Instance.new("UIStroke")
            InputStroke.Color     = Theme.Stroke
            InputStroke.Thickness = 1
            InputStroke.Parent    = InputBox

            InputBox.Focused:Connect(function()
                Tween(InputStroke, 0.15, {Color = Theme.Accent}):Play()
            end)
            InputBox.FocusLost:Connect(function(enterPressed)
                Tween(InputStroke, 0.15, {Color = Theme.Stroke}):Play()
                val = InputBox.Text
                ConfigTable[text] = val
                SaveConfig()
                task.spawn(callback, val, enterPressed)
            end)

            return {
                GetText     = function() return InputBox.Text end,
                SetText     = function(t) InputBox.Text = t val = t end,
                SetCallback = function(cb) callback = cb end,
            }
        end

        -- ----- KEYBIND -----
        function Elements.CreateKeybind(text, defaultKey, callback)
            callback   = callback   or function() end
            defaultKey = defaultKey or Enum.KeyCode.Unknown
            local boundKey = defaultKey
            if ConfigTable[text .. "_keybind"] then
                pcall(function()
                    boundKey = Enum.KeyCode[ConfigTable[text .. "_keybind"]]
                end)
            end

            local KFrame = CreateRoundedUI({
                ClassName        = "Frame",
                BackgroundColor3 = Theme.Element,
                Size             = UDim2.new(1, -4, 0, 36),
            }, Page)
            Instance.new("UIStroke", KFrame).Color = Theme.Stroke

            local KLabel = Instance.new("TextLabel")
            KLabel.BackgroundTransparency = 1
            KLabel.Position    = UDim2.new(0, 10, 0, 0)
            KLabel.Size        = UDim2.new(1, -120, 1, 0)
            KLabel.Font        = Enum.Font.Gotham
            KLabel.Text        = text
            KLabel.TextColor3  = Theme.Text
            KLabel.TextSize    = 13
            KLabel.TextXAlignment = Enum.TextXAlignment.Left
            KLabel.Parent      = KFrame

            local KeyDisplay = CreateRoundedUI({
                ClassName        = "TextButton",
                BackgroundColor3 = Theme.TopBar,
                Size             = UDim2.new(0, 100, 0, 24),
                Position         = UDim2.new(1, -108, 0.5, -12),
                Font             = Enum.Font.GothamBold,
                Text             = boundKey.Name,
                TextColor3       = Theme.Accent,
                TextSize         = 11,
                AutoButtonColor  = false,
            }, KFrame, UDim.new(0, 4))
            Instance.new("UIStroke", KeyDisplay).Color = Theme.Stroke

            local listening = false
            KeyDisplay.MouseButton1Click:Connect(function()
                if listening then return end
                listening = true
                KeyDisplay.Text      = "..."
                KeyDisplay.TextColor3 = Theme.SubText
            end)

            local keybindConn
            keybindConn = UserInputService.InputBegan:Connect(function(inp, gp)
                if not listening then
                    -- Fire callback when key is pressed (ignore typing)
                    if not gp and inp.KeyCode == boundKey then
                        local focused = UserInputService:GetFocusedTextBox()
                        if not focused then task.spawn(callback, boundKey) end
                    end
                    return
                end
                if gp then return end
                if inp.UserInputType == Enum.UserInputType.Keyboard then
                    boundKey = inp.KeyCode
                    ConfigTable[text .. "_keybind"] = boundKey.Name
                    SaveConfig()
                    KeyDisplay.Text       = boundKey.Name
                    KeyDisplay.TextColor3 = Theme.Accent
                    listening = false
                end
            end)

            return {
                GetKey      = function() return boundKey end,
                SetKey      = function(k) boundKey = k KeyDisplay.Text = k.Name end,
                SetCallback = function(cb) callback = cb end,
            }
        end

        -- ----- COLORPICKER -----
        function Elements.CreateColorPicker(text, defaultColor, callback)
            callback     = callback     or function() end
            defaultColor = defaultColor or Color3.fromRGB(255, 255, 255)

            local currentColor = defaultColor
            if ConfigTable[text .. "_color"] then
                pcall(function()
                    local t = ConfigTable[text .. "_color"]
                    currentColor = Color3.fromRGB(t[1], t[2], t[3])
                end)
            end

            local CPFrame = CreateRoundedUI({
                ClassName        = "Frame",
                BackgroundColor3 = Theme.Element,
                Size             = UDim2.new(1, -4, 0, 36),
                ClipsDescendants = false,
                ZIndex           = 20,
            }, Page)
            Instance.new("UIStroke", CPFrame).Color = Theme.Stroke

            local CPLabel = Instance.new("TextLabel")
            CPLabel.BackgroundTransparency = 1
            CPLabel.Position    = UDim2.new(0, 10, 0, 0)
            CPLabel.Size        = UDim2.new(1, -60, 1, 0)
            CPLabel.Font        = Enum.Font.Gotham
            CPLabel.Text        = text
            CPLabel.TextColor3  = Theme.Text
            CPLabel.TextSize    = 13
            CPLabel.TextXAlignment = Enum.TextXAlignment.Left
            CPLabel.ZIndex      = 21
            CPLabel.Parent      = CPFrame

            local ColorPreview = CreateRoundedUI({
                ClassName        = "TextButton",
                BackgroundColor3 = currentColor,
                Size             = UDim2.new(0, 40, 0, 24),
                Position         = UDim2.new(1, -48, 0.5, -12),
                Text             = "",
                AutoButtonColor  = false,
                ZIndex           = 21,
            }, CPFrame, UDim.new(0, 4))
            Instance.new("UIStroke", ColorPreview).Color = Theme.Stroke

            -- Picker panel
            local PANEL_H = 130
            local Panel = CreateRoundedUI({
                ClassName        = "Frame",
                BackgroundColor3 = Theme.TopBar,
                Size             = UDim2.new(1, 0, 0, PANEL_H),
                Position         = UDim2.new(0, 0, 1, 4),
                Visible          = false,
                ZIndex           = 60,
            }, CPFrame, UDim.new(0, 8))
            Instance.new("UIStroke", Panel).Color = Theme.Stroke

            -- H, S, V sliders inside panel
            local h, s, v = Color3.toHSV(currentColor)

            local function MakePickerSlider(label, yPos, trackColor)
                local Lbl = Instance.new("TextLabel")
                Lbl.BackgroundTransparency = 1
                Lbl.Position    = UDim2.new(0, 8, 0, yPos)
                Lbl.Size        = UDim2.new(0, 12, 0, 14)
                Lbl.Font        = Enum.Font.GothamBold
                Lbl.Text        = label
                Lbl.TextColor3  = Theme.SubText
                Lbl.TextSize    = 10
                Lbl.ZIndex      = 61
                Lbl.Parent      = Panel

                local Track = CreateRoundedUI({
                    ClassName        = "Frame",
                    BackgroundColor3 = trackColor or Theme.Stroke,
                    Size             = UDim2.new(1, -36, 0, 8),
                    Position         = UDim2.new(0, 22, 0, yPos + 3),
                    ZIndex           = 61,
                }, Panel, UDim.new(1, 0))

                local TrackFill = CreateRoundedUI({
                    ClassName        = "Frame",
                    BackgroundColor3 = Theme.Accent,
                    Size             = UDim2.new(0.5, 0, 1, 0),
                    ZIndex           = 62,
                }, Track, UDim.new(1, 0))

                local TrackKnob = CreateRoundedUI({
                    ClassName        = "Frame",
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    Size             = UDim2.new(0, 10, 0, 10),
                    Position         = UDim2.new(0.5, -5, 0.5, -5),
                    ZIndex           = 63,
                }, Track, UDim.new(1, 0))

                return Track, TrackFill, TrackKnob
            end

            local HTrack, HFill, HKnob = MakePickerSlider("H", 12)
            local STrack, SFill, SKnob = MakePickerSlider("S", 42)
            local VTrack, VFill, VKnob = MakePickerSlider("V", 72)

            -- Gradient for H track
            local HGrad = Instance.new("UIGradient")
            HGrad.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0,    Color3.fromHSV(0,   1, 1)),
                ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17,1, 1)),
                ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33,1, 1)),
                ColorSequenceKeypoint.new(0.5,  Color3.fromHSV(0.5, 1, 1)),
                ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67,1, 1)),
                ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83,1, 1)),
                ColorSequenceKeypoint.new(1,    Color3.fromHSV(1,   1, 1)),
            }
            HGrad.Parent = HTrack
            HFill.BackgroundTransparency = 1

            -- Hex display
            local function ColorToHex(c)
                return string.format("#%02X%02X%02X", math.floor(c.R*255), math.floor(c.G*255), math.floor(c.B*255))
            end

            local HexLabel = Instance.new("TextLabel")
            HexLabel.BackgroundTransparency = 1
            HexLabel.Position    = UDim2.new(0, 8, 0, 102)
            HexLabel.Size        = UDim2.new(1, -16, 0, 20)
            HexLabel.Font        = Enum.Font.GothamBold
            HexLabel.Text        = ColorToHex(currentColor)
            HexLabel.TextColor3  = Theme.Accent
            HexLabel.TextSize    = 11
            HexLabel.TextXAlignment = Enum.TextXAlignment.Center
            HexLabel.ZIndex      = 61
            HexLabel.Parent      = Panel

            local function UpdateColor(newH, newS, newV)
                h = math.clamp(newH or h, 0, 1)
                s = math.clamp(newS or s, 0, 1)
                v = math.clamp(newV or v, 0, 1)
                currentColor = Color3.fromHSV(h, s, v)
                ColorPreview.BackgroundColor3 = currentColor
                HexLabel.Text = ColorToHex(currentColor)
                HKnob.Position = UDim2.new(h, -5, 0.5, -5)
                SKnob.Position = UDim2.new(s, -5, 0.5, -5)
                SFill.Size     = UDim2.new(s, 0, 1, 0)
                VKnob.Position = UDim2.new(v, -5, 0.5, -5)
                VFill.Size     = UDim2.new(v, 0, 1, 0)
                SFill.BackgroundColor3 = Color3.fromHSV(h, s, 1)
                VFill.BackgroundColor3 = Color3.fromHSV(h, 1, v)
                ConfigTable[text .. "_color"] = {
                    math.floor(currentColor.R * 255),
                    math.floor(currentColor.G * 255),
                    math.floor(currentColor.B * 255)
                }
                SaveConfig()
                task.spawn(callback, currentColor)
            end

            UpdateColor(h, s, v)

            local function MakeDraggable(track, axis)
                local isDrag = false
                track.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                        isDrag = true
                        local pct = math.clamp((inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                        if axis == "H" then UpdateColor(pct, nil, nil)
                        elseif axis == "S" then UpdateColor(nil, pct, nil)
                        elseif axis == "V" then UpdateColor(nil, nil, pct) end
                    end
                end)
                UserInputService.InputChanged:Connect(function(inp)
                    if isDrag and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
                        local pct = math.clamp((inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                        if axis == "H" then UpdateColor(pct, nil, nil)
                        elseif axis == "S" then UpdateColor(nil, pct, nil)
                        elseif axis == "V" then UpdateColor(nil, nil, pct) end
                    end
                end)
                UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                        isDrag = false
                    end
                end)
            end

            MakeDraggable(HTrack, "H")
            MakeDraggable(STrack, "S")
            MakeDraggable(VTrack, "V")

            local panelOpen = false
            ColorPreview.MouseButton1Click:Connect(function()
                panelOpen = not panelOpen
                Panel.Visible = panelOpen
                if panelOpen then
                    Panel.Size = UDim2.new(1, 0, 0, 0)
                    Tween(Panel, 0.25, {Size = UDim2.new(1, 0, 0, PANEL_H)}, Enum.EasingStyle.Quart):Play()
                else
                    Tween(Panel, 0.2, {Size = UDim2.new(1, 0, 0, 0)}, Enum.EasingStyle.Quart):Play()
                    task.delay(0.22, function() Panel.Visible = false end)
                end
            end)

            return {
                GetColor    = function() return currentColor end,
                SetColor    = function(c)
                    local nh, ns, nv = Color3.toHSV(c)
                    UpdateColor(nh, ns, nv)
                end,
                SetCallback = function(cb) callback = cb end,
            }
        end

        -- ----- SEPARATOR -----
        function Elements.CreateSeparator()
            local Sep = Instance.new("Frame")
            Sep.BackgroundColor3 = Theme.Stroke
            Sep.BorderSizePixel  = 0
            Sep.Size             = UDim2.new(1, -4, 0, 1)
            Sep.Parent           = Page
        end

        return Elements
    end

    -- =====================================================
    -- CONFIG HELPERS ON TabHandler
    -- =====================================================
    function TabHandler.SaveConfig()
        SaveConfig()
        Notify("Config", "Configuration saved.", 3, "success")
    end

    function TabHandler.LoadConfig()
        if LoadConfig() then
            Notify("Config", "Configuration loaded.", 3, "success")
        else
            Notify("Config", "No config file found.", 3, "warning")
        end
    end

    function TabHandler.SetTheme(newThemeName)
        -- Runtime theme swap is complex with existing instances;
        -- This is a convenience to re-create the window with new theme.
        local t = Library.Themes[newThemeName]
        if not t then
            Notify("Theme", "Theme '" .. newThemeName .. "' not found.", 3, "error")
        else
            Notify("Theme", "Restart UI to apply new theme.", 3, "info")
        end
    end

    function TabHandler.Notify(title, message, duration, notifType)
        Notify(title, message, duration, notifType)
    end

    function TabHandler.Destroy()
        ScreenGui:Destroy()
    end

    -- Open animation
    MainFrame.Size = UDim2.new(0, WIN_W, 0, 0)
    Tween(MainFrame, 0.5, {Size = UDim2.new(0, WIN_W, 0, WIN_H)}, Enum.EasingStyle.Back):Play()

    return TabHandler
end

return Library
