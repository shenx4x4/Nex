
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local TargetGui = RunService:IsStudio() and PlayerGui or CoreGui

local Flux = {
    Themes = {
        Default = { Main = Color3.fromRGB(30, 30, 35), Container = Color3.fromRGB(40, 40, 45), Accent = Color3.fromRGB(80, 120, 255), Text = Color3.fromRGB(240, 240, 240), Border = Color3.fromRGB(60, 60, 65) },
        Dark = { Main = Color3.fromRGB(15, 15, 15), Container = Color3.fromRGB(20, 20, 25), Accent = Color3.fromRGB(120, 100, 255), Text = Color3.fromRGB(255, 255, 255), Border = Color3.fromRGB(40, 40, 45) },
        Light = { Main = Color3.fromRGB(240, 240, 240), Container = Color3.fromRGB(255, 255, 255), Accent = Color3.fromRGB(50, 90, 220), Text = Color3.fromRGB(20, 20, 20), Border = Color3.fromRGB(210, 210, 210) },
        Valentine = { Main = Color3.fromRGB(35, 20, 25), Container = Color3.fromRGB(45, 25, 35), Accent = Color3.fromRGB(255, 80, 120), Text = Color3.fromRGB(250, 230, 240), Border = Color3.fromRGB(70, 30, 45) }
    },
    CurrentTheme = "Default",
    Configs = {},
    Connections = {},
    ActiveElements = {}
}

-- Utility Functions
local function Tween(instance, properties, duration, style, direction)
    duration = duration or 0.25
    style = style or Enum.EasingStyle.Quad
    direction = direction or Enum.EasingDirection.Out
    local tween = TweenService:Create(instance, TweenInfo.new(duration, style, direction), properties)
    tween:Play()
    return tween
end

local function Create(class, properties)
    local inst = Instance.new(class)
    for k, v in pairs(properties or {}) do
        inst[k] = v
    end
    return inst
end

local function MakeDraggable(topbar, window)
    local dragging, dragInput, dragStart, startPos
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = window.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Notification System
local NotificationGui = Create("ScreenGui", { Name = "FluxNotifications", Parent = TargetGui })
local NotifList = Create("Frame", { Name = "NotifList", Parent = NotificationGui, BackgroundTransparency = 1, Size = UDim2.new(0, 300, 1, -40), Position = UDim2.new(1, -320, 0, 20) })
Create("UIListLayout", { Parent = NotifList, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10), VerticalAlignment = Enum.VerticalAlignment.Bottom })

function Flux.Notify(params)
    local title = params.Title or "Notification"
    local text = params.Text or ""
    local time = params.Duration or 3
    local theme = Flux.Themes[Flux.CurrentTheme]

    local notif = Create("Frame", { Parent = NotifList, Size = UDim2.new(1, 0, 0, 60), BackgroundColor3 = theme.Container, BackgroundTransparency = 1 })
    Create("UICorner", { Parent = notif, CornerRadius = UDim.new(0, 6) })
    Create("UIStroke", { Parent = notif, Color = theme.Border, Thickness = 1, Transparency = 1 })

    local lblTitle = Create("TextLabel", { Parent = notif, Text = title, Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = theme.Text, Size = UDim2.new(1, -20, 0, 25), Position = UDim2.new(0, 10, 0, 5), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1 })
    local lblText = Create("TextLabel", { Parent = notif, Text = text, Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = theme.Text, Size = UDim2.new(1, -20, 0, 25), Position = UDim2.new(0, 10, 0, 25), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1 })

    -- Enter animation
    notif.Position = UDim2.new(1, 100, 0, 0)
    Tween(notif, {BackgroundTransparency = 0, Position = UDim2.new(0, 0, 0, 0)})
    Tween(lblTitle, {TextTransparency = 0})
    Tween(lblText, {TextTransparency = 0})
    Tween(notif:FindFirstChildOfClass("UIStroke"), {Transparency = 0})

    task.delay(time, function()
        Tween(notif, {BackgroundTransparency = 1, Position = UDim2.new(1, 100, 0, 0)})
        Tween(lblTitle, {TextTransparency = 1})
        Tween(lblText, {TextTransparency = 1})
        Tween(notif:FindFirstChildOfClass("UIStroke"), {Transparency = 1})
        task.wait(0.3)
        notif:Destroy()
    end)
end

-- Core Window
function Flux.CreateWindow(params)
    local titleText = params.Title or "Flux Library"
    local themeName = params.Theme or "Default"
    if Flux.Themes[themeName] then Flux.CurrentTheme = themeName end
    local theme = Flux.Themes[Flux.CurrentTheme]

    local ScreenGui = Create("ScreenGui", { Name = "FluxUI", Parent = TargetGui })
    
    local MainFrame = Create("Frame", { Parent = ScreenGui, Size = UDim2.new(0, 600, 0, 350), Position = UDim2.new(0.5, -300, 0.5, -175), BackgroundColor3 = theme.Main, ClipsDescendants = true })
    Create("UICorner", { Parent = MainFrame, CornerRadius = UDim.new(0, 8) })
    Create("UIStroke", { Parent = MainFrame, Color = theme.Border, Thickness = 1 })

    local Topbar = Create("Frame", { Parent = MainFrame, Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = theme.Container, BorderSizePixel = 0 })
    Create("UICorner", { Parent = Topbar, CornerRadius = UDim.new(0, 8) })
    local TopbarFix = Create("Frame", { Parent = Topbar, Size = UDim2.new(1, 0, 0, 8), Position = UDim2.new(0, 0, 1, -8), BackgroundColor3 = theme.Container, BorderSizePixel = 0 })
    local Title = Create("TextLabel", { Parent = Topbar, Text = titleText, Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = theme.Text, Size = UDim2.new(1, -50, 1, 0), Position = UDim2.new(0, 15, 0, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left })
    
    local TabContainer = Create("Frame", { Parent = MainFrame, Size = UDim2.new(0, 150, 1, -40), Position = UDim2.new(0, 0, 0, 40), BackgroundColor3 = theme.Container, BorderSizePixel = 0 })
    local TabList = Create("UIListLayout", { Parent = TabContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5) })
    Create("UIPadding", { Parent = TabContainer, PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) })

    local ContentContainer = Create("Frame", { Parent = MainFrame, Size = UDim2.new(1, -150, 1, -40), Position = UDim2.new(0, 150, 0, 40), BackgroundTransparency = 1 })
    
    -- Close & Minimize
    local CloseBtn = Create("TextButton", { Parent = Topbar, Text = "X", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = theme.Text, Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -35, 0, 5), BackgroundTransparency = 1 })
    local MinBtn = Create("TextButton", { Parent = Topbar, Text = "-", Font = Enum.Font.GothamBold, TextSize = 18, TextColor3 = theme.Text, Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -70, 0, 5), BackgroundTransparency = 1 })
    
    MakeDraggable(Topbar, MainFrame)
    
    CloseBtn.MouseButton1Click:Connect(function()
        Tween(MainFrame, {Size = UDim2.new(0, 600, 0, 0), BackgroundTransparency = 1}, 0.3)
        task.wait(0.3)
        ScreenGui:Destroy()
    end)
    
    local minimized = false
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Tween(MainFrame, {Size = UDim2.new(0, 600, 0, 40)}, 0.3, Enum.EasingStyle.Exponential)
            TabContainer.Visible = false
            ContentContainer.Visible = false
        else
            Tween(MainFrame, {Size = UDim2.new(0, 600, 0, 350)}, 0.3, Enum.EasingStyle.Exponential)
            task.wait(0.3)
            TabContainer.Visible = true
            ContentContainer.Visible = true
        end
    end)

    local WindowActions = {}
    local currentTab = nil

    function WindowActions.CreateTab(tabName)
        local TabBtn = Create("TextButton", { Parent = TabContainer, Text = tabName, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = theme.Text, Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = theme.Main, AutoButtonColor = false })
        Create("UICorner", { Parent = TabBtn, CornerRadius = UDim.new(0, 6) })
        
        local Page = Create("ScrollingFrame", { Parent = ContentContainer, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ScrollBarThickness = 2, CanvasSize = UDim2.new(0, 0, 0, 0), Visible = false })
        local PageList = Create("UIListLayout", { Parent = Page, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8) })
        Create("UIPadding", { Parent = Page, PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10) })

        PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 20)
        end)

        TabBtn.MouseButton1Click:Connect(function()
            if currentTab then 
                currentTab.Btn.BackgroundColor3 = theme.Main 
                currentTab.Page.Visible = false
            end
            currentTab = {Btn = TabBtn, Page = Page}
            Tween(TabBtn, {BackgroundColor3 = theme.Accent}, 0.2)
            Page.Visible = true
            Page.Position = UDim2.new(0, 10, 0, 0)
            Page.GroupTransparency = 1
            Tween(Page, {Position = UDim2.new(0, 0, 0, 0), GroupTransparency = 0}, 0.2)
        end)

        if not currentTab then
            TabBtn.BackgroundColor3 = theme.Accent
            Page.Visible = true
            currentTab = {Btn = TabBtn, Page = Page}
        end

        local Elements = {}

        function Elements.CreateButton(btnParams)
            local title = btnParams.Title or "Button"
            local callback = btnParams.Callback or function() end

            local BtnFrame = Create("TextButton", { Parent = Page, Size = UDim2.new(1, 0, 0, 35), BackgroundColor3 = theme.Container, Text = "", AutoButtonColor = false })
            Create("UICorner", { Parent = BtnFrame, CornerRadius = UDim.new(0, 6) })
            Create("UIStroke", { Parent = BtnFrame, Color = theme.Border, Thickness = 1 })
            local BtnText = Create("TextLabel", { Parent = BtnFrame, Text = title, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = theme.Text, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1 })

            BtnFrame.MouseEnter:Connect(function() Tween(BtnFrame, {BackgroundColor3 = theme.Accent}, 0.2) end)
            BtnFrame.MouseLeave:Connect(function() Tween(BtnFrame, {BackgroundColor3 = theme.Container}, 0.2) end)
            BtnFrame.MouseButton1Down:Connect(function() Tween(BtnFrame, {Size = UDim2.new(0.98, 0, 0, 33)}, 0.1) end)
            BtnFrame.MouseButton1Up:Connect(function() Tween(BtnFrame, {Size = UDim2.new(1, 0, 0, 35)}, 0.1); callback() end)
        end

        function Elements.CreateToggle(tglParams)
            local title = tglParams.Title or "Toggle"
            local default = tglParams.Default or false
            local callback = tglParams.Callback or function() end
            local flag = tglParams.Flag or title

            local state = default
            Flux.Configs[flag] = state

            local TglFrame = Create("TextButton", { Parent = Page, Size = UDim2.new(1, 0, 0, 35), BackgroundColor3 = theme.Container, Text = "", AutoButtonColor = false })
            Create("UICorner", { Parent = TglFrame, CornerRadius = UDim.new(0, 6) })
            Create("UIStroke", { Parent = TglFrame, Color = theme.Border, Thickness = 1 })
            Create("TextLabel", { Parent = TglFrame, Text = title, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = theme.Text, Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left })

            local IndicatorWrap = Create("Frame", { Parent = TglFrame, Size = UDim2.new(0, 40, 0, 20), Position = UDim2.new(1, -50, 0.5, -10), BackgroundColor3 = theme.Main })
            Create("UICorner", { Parent = IndicatorWrap, CornerRadius = UDim.new(1, 0) })
            local IndicatorCircle = Create("Frame", { Parent = IndicatorWrap, Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = theme.TextDark })
            Create("UICorner", { Parent = IndicatorCircle, CornerRadius = UDim.new(1, 0) })

            local function UpdateState(anim)
                if state then
                    if anim then Tween(IndicatorCircle, {Position = UDim2.new(1, -18, 0.5, -8), BackgroundColor3 = Color3.new(1,1,1)}, 0.2) Tween(IndicatorWrap, {BackgroundColor3 = theme.Accent}, 0.2)
                    else IndicatorCircle.Position = UDim2.new(1, -18, 0.5, -8); IndicatorWrap.BackgroundColor3 = theme.Accent IndicatorCircle.BackgroundColor3 = Color3.new(1,1,1) end
                else
                    if anim then Tween(IndicatorCircle, {Position = UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = theme.TextDark}, 0.2) Tween(IndicatorWrap, {BackgroundColor3 = theme.Main}, 0.2)
                    else IndicatorCircle.Position = UDim2.new(0, 2, 0.5, -8); IndicatorWrap.BackgroundColor3 = theme.Main IndicatorCircle.BackgroundColor3 = theme.TextDark end
                end
                Flux.Configs[flag] = state
                callback(state)
            end
            UpdateState(false)

            TglFrame.MouseButton1Click:Connect(function()
                state = not state
                UpdateState(true)
            end)

            return {
                Set = function(s) state = s UpdateState(true) end,
                Get = function() return state end
            }
        end

        function Elements.CreateSlider(slParams)
            local title = slParams.Title or "Slider"
            local min = slParams.Min or 0
            local max = slParams.Max or 100
            local default = slParams.Default or min
            local callback = slParams.Callback or function() end
            local flag = slParams.Flag or title

            local val = default
            Flux.Configs[flag] = val

            local SlFrame = Create("Frame", { Parent = Page, Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = theme.Container })
            Create("UICorner", { Parent = SlFrame, CornerRadius = UDim.new(0, 6) })
            Create("UIStroke", { Parent = SlFrame, Color = theme.Border, Thickness = 1 })
            Create("TextLabel", { Parent = SlFrame, Text = title, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = theme.Text, Size = UDim2.new(1, -10, 0, 20), Position = UDim2.new(0, 10, 0, 5), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left })
            local ValLabel = Create("TextLabel", { Parent = SlFrame, Text = tostring(val), Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = theme.Text, Size = UDim2.new(0, 40, 0, 20), Position = UDim2.new(1, -50, 0, 5), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Right })

            local SlBg = Create("TextButton", { Parent = SlFrame, Size = UDim2.new(1, -20, 0, 6), Position = UDim2.new(0, 10, 0, 35), BackgroundColor3 = theme.Main, Text = "", AutoButtonColor = false })
            Create("UICorner", { Parent = SlBg, CornerRadius = UDim.new(1, 0) })
            local SlFill = Create("Frame", { Parent = SlBg, Size = UDim2.new((val-min)/(max-min), 0, 1, 0), BackgroundColor3 = theme.Accent })
            Create("UICorner", { Parent = SlFill, CornerRadius = UDim.new(1, 0) })

            local sliding = false
            SlBg.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = true end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = false end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local scale = math.clamp((input.Position.X - SlBg.AbsolutePosition.X) / SlBg.AbsoluteSize.X, 0, 1)
                    val = math.floor(min + ((max - min) * scale))
                    ValLabel.Text = tostring(val)
                    Flux.Configs[flag] = val
                    Tween(SlFill, {Size = UDim2.new(scale, 0, 1, 0)}, 0.1)
                    callback(val)
                end
            end)
        end

        function Elements.CreateDropdown(ddParams)
            local title = ddParams.Title or "Dropdown"
            local options = ddParams.Options or {}
            local callback = ddParams.Callback or function() end
            
            local isOpen = false
            local DdFrame = Create("Frame", { Parent = Page, Size = UDim2.new(1, 0, 0, 35), BackgroundColor3 = theme.Container, ClipsDescendants = true })
            Create("UICorner", { Parent = DdFrame, CornerRadius = UDim.new(0, 6) })
            Create("UIStroke", { Parent = DdFrame, Color = theme.Border, Thickness = 1 })
            
            local DdBtn = Create("TextButton", { Parent = DdFrame, Size = UDim2.new(1, 0, 0, 35), BackgroundTransparency = 1, Text = "" })
            local DdTitle = Create("TextLabel", { Parent = DdFrame, Text = title, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = theme.Text, Size = UDim2.new(1, -40, 0, 35), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left })
            local Arrow = Create("TextLabel", { Parent = DdFrame, Text = "+", Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = theme.Text, Size = UDim2.new(0, 30, 0, 35), Position = UDim2.new(1, -30, 0, 0), BackgroundTransparency = 1 })

            local OptList = Create("UIListLayout", { Parent = DdFrame, SortOrder = Enum.SortOrder.LayoutOrder })

            local function Toggle()
                isOpen = not isOpen
                Arrow.Text = isOpen and "-" or "+"
                local targetSize = isOpen and 35 + (#options * 35) or 35
                Tween(DdFrame, {Size = UDim2.new(1, 0, 0, targetSize)}, 0.2, Enum.EasingStyle.Exponential)
            end

            DdBtn.MouseButton1Click:Connect(Toggle)

            for i, opt in ipairs(options) do
                local OptBtn = Create("TextButton", { Parent = DdFrame, Size = UDim2.new(1, 0, 0, 35), BackgroundColor3 = theme.Container, Text = opt, Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = theme.TextDark, AutoButtonColor = false, LayoutOrder = i })
                OptBtn.MouseEnter:Connect(function() Tween(OptBtn, {BackgroundColor3 = theme.Main, TextColor3 = theme.Text}, 0.1) end)
                OptBtn.MouseLeave:Connect(function() Tween(OptBtn, {BackgroundColor3 = theme.Container, TextColor3 = theme.TextDark}, 0.1) end)
                OptBtn.MouseButton1Click:Connect(function()
                    callback(opt)
                    DdTitle.Text = title .. " : " .. opt
                    Toggle()
                end)
            end
        end

        function Elements.CreateTextbox(tbParams)
            local title = tbParams.Title or "Textbox"
            local default = tbParams.Default or ""
            local callback = tbParams.Callback or function() end

            local TbFrame = Create("Frame", { Parent = Page, Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = theme.Container })
            Create("UICorner", { Parent = TbFrame, CornerRadius = UDim.new(0, 6) })
            Create("UIStroke", { Parent = TbFrame, Color = theme.Border, Thickness = 1 })
            Create("TextLabel", { Parent = TbFrame, Text = title, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = theme.Text, Size = UDim2.new(1, -10, 0, 20), Position = UDim2.new(0, 10, 0, 5), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left })
            
            local Box = Create("TextBox", { Parent = TbFrame, Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 10, 0, 25), BackgroundColor3 = theme.Main, Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = theme.Text, Text = default, PlaceholderText = "Enter text...", ClearTextOnFocus = false })
            Create("UICorner", { Parent = Box, CornerRadius = UDim.new(0, 4) })
            
            Box.FocusLost:Connect(function()
                callback(Box.Text)
            end)
        end

        return Elements
    end

    -- Floating Toggle
    local FloatBtn = Create("TextButton", { Parent = ScreenGui, Size = UDim2.new(0, 40, 0, 40), Position = UDim2.new(0, 20, 0.5, 0), BackgroundColor3 = theme.Accent, Text = "F", Font = Enum.Font.GothamBold, TextSize = 18, TextColor3 = Color3.new(1,1,1), AutoButtonColor = false })
    Create("UICorner", { Parent = FloatBtn, CornerRadius = UDim.new(1, 0) })
    
    local fDrag, fInput, fStart, fPos
    FloatBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            fDrag = true; fStart = input.Position; fPos = FloatBtn.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if fDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local del = input.Position - fStart
            FloatBtn.Position = UDim2.new(0, fPos.X.Offset + del.X, 0, fPos.Y.Offset + del.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then fDrag = false end
    end)

    local uiVisible = true
    FloatBtn.MouseButton1Click:Connect(function()
        if not fDrag then
            uiVisible = not uiVisible
            MainFrame.Visible = uiVisible
            Tween(FloatBtn, {Size = UDim2.new(0, 35, 0, 35)}, 0.1)
            task.wait(0.1)
            Tween(FloatBtn, {Size = UDim2.new(0, 40, 0, 40)}, 0.1)
        end
    end)

    return WindowActions
end

-- Example Usage:
-- local Win = Flux.CreateWindow({Title = "My Scripts", Theme = "Dark"})
-- local Tab1 = Win.CreateTab("Main")
-- Tab1.CreateToggle({Title = "Aimbot", Callback = function(s) print(s) end})
-- Tab1.CreateSlider({Title = "Speed", Min = 16, Max = 100, Callback = function(v) print(v) end})

return Flux
