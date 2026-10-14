-- ============================================
-- Project Astra Lite v7
-- Combat + Visuals + Misc + AimBot + HeadScale Hitbox
-- ============================================
repeat task.wait(0.1) until game:IsLoaded()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local GUI_PARENT = CoreGui

-- ===================== CONFIG =====================
local A = {}
_G.A = A

A.BG = Color3.fromRGB(20,20,24)
A.PANEL = Color3.fromRGB(24,24,29)
A.DROPBG = Color3.fromRGB(22,22,27)
A.BARBG = Color3.fromRGB(28,28,34)
A.CHECKBG = Color3.fromRGB(26,26,31)
A.WHITE = Color3.fromRGB(235,235,235)
A.GRAY = Color3.fromRGB(145,145,150)
A.ACCENT = Color3.fromRGB(255,25,120)

-- Visuals
A.espEnabled = false
A.espBox = true
A.espName = true
A.espHealth = true
A.espDistance = true
A.espWeapon = true
A.espBoxColor = Color3.fromRGB(255,255,255)
A.espNameColor = Color3.fromRGB(255,255,255)
A.espDistColor = Color3.fromRGB(255,255,255)
A.espWeapColor = Color3.fromRGB(255,200,0)
A.espCache = {}

A.noFogEnabled = false
A.fullbrightEnabled = false
A.cameraFovEnabled = false
A.cameraFovValue = 120
A.gammaEnabled = false
A.gammaValue = 10
A.gammaColor = Color3.fromRGB(128,128,128)
A.fogEnabled = false
A.fogStart = 100
A.fogEnd = 500
A.fogColor = Color3.fromRGB(128,128,128)

-- Custom Hands
A.customHandsEnabled = false
A.customHandsColor = Color3.fromRGB(160,32,240)
A.customHandsTransp = 0.55
A.customHandsRainbow = false
A.customHandsHue = 0.75
A.activeLockedArms = {}

-- Custom Guns
A.customGunsEnabled = false
A.customGunsColor = Color3.fromRGB(255,80,255)
A.customGunsTransp = 0.4
A.customGunsRainbow = false
A.customGunsHue = 0.85
A.TARGET_MODEL_NAME = "WoodHammer_ClientADSViewModel"

-- Combat - Hitbox (НОВАЯ СИСТЕМА)
A.hitboxEnabled = false
A.hitboxSize = 5
A.hitboxOriginalScale = {}
A.hitboxOnlyOthers = true

-- Combat - AimBot
A.aimbotEnabled = false
A.aimbotFOV = 175
A.aimbotPart = "Head"
A.aimbotSmoothness = 0.35
A.aimbotMaxDistance = 400
A.aimbotVisibleCheck = true
A.aimbotBulletSpeed = 600
A.aimbotGravity = 196.2
A.aimbotGravityMult = 1
A.aimbotDropFrac = 0.25
A.aimbotPredictionMult = 1.0
A.aimbotVerticalPrediction = true
A.aimbotCircleColor = Color3.fromRGB(255,0,0)
A.aimbotUseKeybind = false
A.aimbotKeybind = Enum.KeyCode.E
A.aimbotUseButton = true
A.aimbotBtnPos = UDim2.new(0, 20, 0, 100)
A.aimbotBtnLocked = false
A.aimbotBtn = nil
A.aimbotCircle = nil
A.aimbotInfoLabel = nil

-- Misc
A.noClipEnabled = false
A.slideFlyEnabled = false
A.slideSpeed = 23
A.slideHeight = 4
A.slideFullControl = false
A.slideAntiDetect = true
A.manipulationEnabled = false
A.manipulationDrop = 0.8
A.longNeckEnabled = false
A.slideActive = false
A.slidePlatform = nil
A.slideConn = nil

-- GUI State
A.guiVisible = true
A.guiLocked = false

-- ===================== UTILS =====================
A.Stroke = function(parent, thickness)
    local s = Instance.new("UIStroke")
    s.Color = A.ACCENT
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

A.MakeText = function(parent, value, pos, size, ts, col)
    local l = Instance.new("TextLabel")
    l.Position = pos
    l.Size = size
    l.BackgroundTransparency = 1
    l.BorderSizePixel = 0
    l.Text = value
    l.TextColor3 = col or A.WHITE
    l.Font = Enum.Font.Code
    l.TextSize = ts or 13
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextYAlignment = Enum.TextYAlignment.Center
    l.Parent = parent
    return l
end

A.Checkbox = function(parent, label, default, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1,0,0,24)
    container.BackgroundTransparency = 1
    container.Parent = parent
    local box = Instance.new("TextButton")
    box.Size = UDim2.fromOffset(18,18)
    box.Position = UDim2.fromOffset(0,3)
    box.BackgroundColor3 = A.CHECKBG
    box.BorderSizePixel = 0
    box.Text = ""
    box.AutoButtonColor = false
    box.Parent = container
    A.Stroke(box,1)
    local fill = Instance.new("Frame")
    fill.Position = UDim2.fromOffset(3,3)
    fill.Size = UDim2.fromOffset(12,12)
    fill.BackgroundColor3 = A.ACCENT
    fill.BorderSizePixel = 0
    fill.Visible = default and true or false
    fill.Parent = box
    A.MakeText(container, label, UDim2.fromOffset(26,0), UDim2.new(1,-26,1,0), 13, A.WHITE)
    local state = default
    box.MouseButton1Click:Connect(function()
        state = not state
        fill.Visible = state
        if callback then pcall(callback, state) end
    end)
    return container
end

A.Slider = function(parent, label, minV, maxV, default, callback, suffix)
    suffix = suffix or ""
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1,0,0,44)
    container.BackgroundTransparency = 1
    container.Parent = parent
    A.MakeText(container, label, UDim2.fromOffset(0,0), UDim2.new(1,-60,0,18), 12, A.WHITE)
    local valLabel = A.MakeText(container, tostring(default)..suffix, UDim2.new(1,-60,0,0), UDim2.fromOffset(60,18), 12, A.ACCENT)
    valLabel.TextXAlignment = Enum.TextXAlignment.Right
    local bar = Instance.new("Frame")
    bar.Position = UDim2.fromOffset(0,22)
    bar.Size = UDim2.new(1,0,0,18)
    bar.BackgroundColor3 = A.BARBG
    bar.BorderSizePixel = 0
    bar.Parent = container
    A.Stroke(bar,1)
    local ratio = maxV > minV and (default - minV)/(maxV - minV) or 0
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(ratio,0,1,0)
    fill.BackgroundColor3 = A.ACCENT
    fill.BorderSizePixel = 0
    fill.Parent = bar
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromScale(1,1)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 5
    btn.Parent = bar
    local dragging = false
    local function update(input)
        local sizeX = bar.AbsoluteSize.X
        if sizeX <= 0 then return end
        local x = input.Position.X - bar.AbsolutePosition.X
        local r = math.clamp(x/sizeX, 0, 1)
        fill.Size = UDim2.new(r,0,1,0)
        local v = math.floor(minV + (maxV-minV)*r + 0.5)
        valLabel.Text = tostring(v)..suffix
        if callback then pcall(callback, v) end
    end
    btn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(i)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            update(i)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    return container
end

A.Dropdown = function(parent, label, options, default, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1,0,0,52)
    container.BackgroundTransparency = 1
    container.ClipsDescendants = false
    container.ZIndex = 50
    container.Parent = parent
    A.MakeText(container, label, UDim2.fromOffset(0,0), UDim2.new(1,0,0,18), 12, A.WHITE)
    local drop = Instance.new("Frame")
    drop.Position = UDim2.fromOffset(0,20)
    drop.Size = UDim2.new(1,0,0,28)
    drop.BackgroundColor3 = A.DROPBG
    drop.BorderSizePixel = 0
    drop.ZIndex = 51
    drop.Parent = container
    A.Stroke(drop,1)
    local selText = A.MakeText(drop, default or (options[1] or ""), UDim2.fromOffset(8,0), UDim2.new(1,-30,1,0), 12, A.WHITE)
    selText.ZIndex = 52
    local arrow = A.MakeText(drop, "v", UDim2.new(1,-22,0,0), UDim2.fromOffset(20,28), 11, A.WHITE)
    arrow.TextXAlignment = Enum.TextXAlignment.Center
    arrow.ZIndex = 52
    local click = Instance.new("TextButton")
    click.Size = UDim2.fromScale(1,1)
    click.BackgroundTransparency = 1
    click.Text = ""
    click.ZIndex = 55
    click.Parent = drop
    local menu = Instance.new("Frame")
    menu.Position = UDim2.fromOffset(0,29)
    menu.Size = UDim2.new(1,0,0,#options*24)
    menu.BackgroundColor3 = A.DROPBG
    menu.BorderSizePixel = 0
    menu.Visible = false
    menu.ZIndex = 100
    menu.Parent = drop
    A.Stroke(menu,1)
    for i,opt in ipairs(options) do
        local ob = Instance.new("TextButton")
        ob.Position = UDim2.fromOffset(0,(i-1)*24)
        ob.Size = UDim2.new(1,0,0,24)
        ob.BackgroundColor3 = A.DROPBG
        ob.BorderSizePixel = 0
        ob.Text = opt
        ob.TextColor3 = A.WHITE
        ob.Font = Enum.Font.Code
        ob.TextSize = 12
        ob.TextXAlignment = Enum.TextXAlignment.Left
        ob.AutoButtonColor = false
        ob.ZIndex = 101
        ob.Parent = menu
        Instance.new("UIPadding",ob).PaddingLeft = UDim.new(0,8)
        ob.MouseButton1Click:Connect(function()
            selText.Text = opt
            menu.Visible = false
            if callback then pcall(callback, opt) end
        end)
    end
    click.MouseButton1Click:Connect(function()
        menu.Visible = not menu.Visible
    end)
    return container
end

A.Section = function(parent, title)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,0,0,24)
    f.BackgroundColor3 = A.PANEL
    f.BorderSizePixel = 0
    f.Parent = parent
    A.Stroke(f,1)
    A.MakeText(f,title,UDim2.fromOffset(8,0),UDim2.new(1,-16,1,0),13,A.ACCENT)
    return f
end

-- ===================== COLOR PICKER =====================
local PickerGui = Instance.new("ScreenGui")
PickerGui.Name = "AstraColorPicker"
PickerGui.ResetOnSpawn = false
PickerGui.DisplayOrder = 99999
PickerGui.Parent = GUI_PARENT

local PickerMain = Instance.new("Frame")
PickerMain.Size = UDim2.fromOffset(280,260)
PickerMain.BackgroundColor3 = A.PANEL
PickerMain.BorderSizePixel = 0
PickerMain.Visible = false
PickerMain.ZIndex = 500
PickerMain.Parent = PickerGui
A.Stroke(PickerMain,1.5)
A.MakeText(PickerMain,"Color Picker",UDim2.fromOffset(10,6),UDim2.new(1,-50,0,20),13,A.WHITE)

local PickerClose = Instance.new("TextButton")
PickerClose.Size = UDim2.fromOffset(20,20)
PickerClose.Position = UDim2.new(1,-26,0,5)
PickerClose.BackgroundColor3 = Color3.fromRGB(200,40,40)
PickerClose.BorderSizePixel = 0
PickerClose.Text = "x"
PickerClose.TextColor3 = A.WHITE
PickerClose.Font = Enum.Font.Code
PickerClose.TextSize = 11
PickerClose.AutoButtonColor = false
PickerClose.Parent = PickerMain
Instance.new("UICorner",PickerClose).CornerRadius = UDim.new(0,4)
PickerClose.MouseButton1Click:Connect(function() PickerMain.Visible = false end)

local Palette = Instance.new("Frame")
Palette.Position = UDim2.fromOffset(10,34)
Palette.Size = UDim2.fromOffset(200,150)
Palette.BackgroundColor3 = Color3.fromHSV(0,1,1)
Palette.BorderSizePixel = 0
Palette.ZIndex = 501
Palette.Parent = PickerMain
Instance.new("UICorner",Palette).CornerRadius = UDim.new(0,3)

local WhiteLayer = Instance.new("Frame")
WhiteLayer.Size = UDim2.fromScale(1,1)
WhiteLayer.BackgroundColor3 = Color3.new(1,1,1)
WhiteLayer.BorderSizePixel = 0
WhiteLayer.ZIndex = 502
WhiteLayer.Parent = Palette
Instance.new("UIGradient",WhiteLayer).Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)})

local BlackLayer = Instance.new("Frame")
BlackLayer.Size = UDim2.fromScale(1,1)
BlackLayer.BackgroundColor3 = Color3.new(0,0,0)
BlackLayer.BorderSizePixel = 0
BlackLayer.ZIndex = 503
BlackLayer.Parent = Palette
local BG2 = Instance.new("UIGradient",BlackLayer)
BG2.Rotation = 90
BG2.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)})

local PaletteCursor = Instance.new("Frame")
PaletteCursor.AnchorPoint = Vector2.new(0.5,0.5)
PaletteCursor.Size = UDim2.fromOffset(10,10)
PaletteCursor.BackgroundTransparency = 1
PaletteCursor.BorderSizePixel = 0
PaletteCursor.ZIndex = 510
PaletteCursor.Parent = Palette
local PCS = Instance.new("UIStroke",PaletteCursor)
PCS.Color = Color3.new(1,1,1)
PCS.Thickness = 2

local HueBar = Instance.new("Frame")
HueBar.Position = UDim2.fromOffset(220,34)
HueBar.Size = UDim2.fromOffset(20,150)
HueBar.BackgroundColor3 = Color3.new(1,1,1)
HueBar.BorderSizePixel = 0
HueBar.ZIndex = 501
HueBar.Parent = PickerMain
Instance.new("UICorner",HueBar).CornerRadius = UDim.new(0,4)
local HG = Instance.new("UIGradient",HueBar)
HG.Rotation = 90
HG.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
    ColorSequenceKeypoint.new(0.166, Color3.fromRGB(255,0,255)),
    ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0,0,255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)),
    ColorSequenceKeypoint.new(0.666, Color3.fromRGB(0,255,0)),
    ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255,255,0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0)),
})

local HueCursor = Instance.new("Frame")
HueCursor.AnchorPoint = Vector2.new(0.5,0.5)
HueCursor.Size = UDim2.fromOffset(24,4)
HueCursor.BackgroundColor3 = Color3.new(1,1,1)
HueCursor.BorderSizePixel = 0
HueCursor.ZIndex = 520
HueCursor.Parent = HueBar
A.Stroke(HueCursor,1)

local RGBLabel = A.MakeText(PickerMain,"RGB: 255,255,255",UDim2.fromOffset(10,190),UDim2.fromOffset(200,18),11,A.WHITE)

local ApplyBtn = Instance.new("TextButton")
ApplyBtn.Position = UDim2.fromOffset(10,214)
ApplyBtn.Size = UDim2.fromOffset(230,26)
ApplyBtn.BackgroundColor3 = A.ACCENT
ApplyBtn.BorderSizePixel = 0
ApplyBtn.Text = "Apply"
ApplyBtn.TextColor3 = A.WHITE
ApplyBtn.Font = Enum.Font.Code
ApplyBtn.TextSize = 12
ApplyBtn.AutoButtonColor = false
ApplyBtn.Parent = PickerMain
Instance.new("UICorner",ApplyBtn).CornerRadius = UDim.new(0,4)
A.Stroke(ApplyBtn,1)

local HSV_h, HSV_s, HSV_v = 0, 1, 1
local PickColor = Color3.new(1,1,1)
local PaletteDrag, HueDrag = false, false
local PickTarget = nil

local function UpdatePick()
    Palette.BackgroundColor3 = Color3.fromHSV(HSV_h,1,1)
    PickColor = Color3.fromHSV(HSV_h,HSV_s,HSV_v)
    PaletteCursor.Position = UDim2.new(HSV_s,0,1-HSV_v,0)
    HueCursor.Position = UDim2.new(0.5,0,HSV_h,0)
    RGBLabel.Text = string.format("RGB: %d, %d, %d",
        math.floor(PickColor.R*255+0.5),
        math.floor(PickColor.G*255+0.5),
        math.floor(PickColor.B*255+0.5))
end

local function UpdatePalettePos(input)
    local pos = Palette.AbsolutePosition
    local size = Palette.AbsoluteSize
    if size.X <= 0 or size.Y <= 0 then return end
    HSV_s = math.clamp((input.Position.X - pos.X)/size.X, 0, 1)
    HSV_v = 1 - math.clamp((input.Position.Y - pos.Y)/size.Y, 0, 1)
    UpdatePick()
end

local function UpdateHuePos(input)
    local pos = HueBar.AbsolutePosition
    local size = HueBar.AbsoluteSize
    if size.Y <= 0 then return end
    HSV_h = math.clamp((input.Position.Y - pos.Y)/size.Y, 0, 1)
    UpdatePick()
end

Palette.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        PaletteDrag = true
        UpdatePalettePos(i)
    end
end)
HueBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        HueDrag = true
        UpdateHuePos(i)
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if i.UserInputType ~= Enum.UserInputType.MouseMovement and i.UserInputType ~= Enum.UserInputType.Touch then return end
    if PaletteDrag then UpdatePalettePos(i) end
    if HueDrag then UpdateHuePos(i) end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        PaletteDrag = false
        HueDrag = false
    end
end)

ApplyBtn.MouseButton1Click:Connect(function()
    if PickTarget then PickTarget(PickColor) end
    PickerMain.Visible = false
end)

local function OpenColorPicker(startColor, callback)
    local h,s,v = startColor:ToHSV()
    HSV_h, HSV_s, HSV_v = h, s, v
    PickTarget = callback
    UpdatePick()
    local vp = Camera.ViewportSize
    local px = math.clamp(vp.X/2 - 140, 5, vp.X - 290)
    local py = math.clamp(vp.Y/2 - 130, 5, vp.Y - 270)
    PickerMain.Position = UDim2.fromOffset(px, py)
    PickerMain.Visible = true
end

A.ColorRow = function(parent, label, getColor, setColor)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1,0,0,24)
    container.BackgroundTransparency = 1
    container.Parent = parent
    A.MakeText(container, label, UDim2.fromOffset(0,0), UDim2.new(1,-60,1,0), 13, A.WHITE)
    local btn = Instance.new("TextButton")
    btn.AnchorPoint = Vector2.new(1,0)
    btn.Position = UDim2.new(1,0,0,2)
    btn.Size = UDim2.fromOffset(50,20)
    btn.BackgroundColor3 = getColor()
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = container
    A.Stroke(btn,1)
    btn.MouseButton1Click:Connect(function()
        OpenColorPicker(getColor(), function(c)
            btn.BackgroundColor3 = c
            setColor(c)
        end)
    end)
    return container
end

-- ===================== MAIN GUI =====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ProjectAstraLite"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = GUI_PARENT

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(700,500)
Main.BackgroundColor3 = A.BG
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = ScreenGui
local MainScale = Instance.new("UIScale")
MainScale.Scale = 0.65
MainScale.Parent = Main
A.Stroke(Main,1.5)

local function CenterMain()
    local vp = Camera.ViewportSize
    local w = Main.Size.X.Offset * MainScale.Scale
    local h = Main.Size.Y.Offset * MainScale.Scale
    Main.Position = UDim2.fromOffset((vp.X-w)/2,(vp.Y-h)/2)
end
CenterMain()

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1,0,0,41)
TitleBar.BackgroundColor3 = Color3.fromRGB(30,20,35)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main
local TG = Instance.new("UIGradient", TitleBar)
TG.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(60,20,80)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(120,30,120)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(40,15,60)),
})
A.MakeText(TitleBar, "Project Astra Lite v7", UDim2.fromOffset(12,0), UDim2.new(1,-24,1,0), 14, A.WHITE)

local Tabs = Instance.new("Frame")
Tabs.Position = UDim2.fromOffset(0,42)
Tabs.Size = UDim2.new(1,0,0,40)
Tabs.BackgroundColor3 = A.BG
Tabs.BorderSizePixel = 0
Tabs.Parent = Main

local TabNames = {"Combat","Visuals","Misc"}
local TabButtons = {}
for i,name in ipairs(TabNames) do
    local b = Instance.new("TextButton")
    b.Position = UDim2.new((i-1)/3,0,0,0)
    b.Size = UDim2.new(1/3,0,1,0)
    b.BackgroundTransparency = 1
    b.BorderSizePixel = 0
    b.Text = name
    b.TextColor3 = i==1 and A.WHITE or A.GRAY
    b.Font = Enum.Font.Code
    b.TextSize = 14
    b.AutoButtonColor = false
    b.Parent = Tabs
    TabButtons[i] = b
end

local SepLine = Instance.new("Frame")
SepLine.Position = UDim2.new(0,0,0,82)
SepLine.Size = UDim2.new(1,0,0,1)
SepLine.BackgroundColor3 = A.ACCENT
SepLine.BorderSizePixel = 0
SepLine.Parent = Main

local Pages = {}
local ScrollsL = {}
local ScrollsR = {}

for i,name in ipairs(TabNames) do
    local page = Instance.new("Frame")
    page.Name = name
    page.Position = UDim2.fromOffset(0,83)
    page.Size = UDim2.new(1,0,1,-83)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.Visible = (i==1)
    page.Parent = Main

    local left = Instance.new("ScrollingFrame")
    left.Position = UDim2.new(0,0,0,0)
    left.Size = UDim2.new(0.5,-4,1,0)
    left.BackgroundTransparency = 1
    left.BorderSizePixel = 0
    left.ScrollBarThickness = 3
    left.ScrollBarImageColor3 = A.ACCENT
    left.AutomaticCanvasSize = Enum.AutomaticSize.Y
    left.CanvasSize = UDim2.new()
    left.Parent = page
    local layoutL = Instance.new("UIListLayout",left)
    layoutL.Padding = UDim.new(0,4)
    layoutL.SortOrder = Enum.SortOrder.LayoutOrder
    local padL = Instance.new("UIPadding",left)
    padL.PaddingTop = UDim.new(0,8)
    padL.PaddingLeft = UDim.new(0,8)
    padL.PaddingRight = UDim.new(0,4)
    padL.PaddingBottom = UDim.new(0,8)

    local right = Instance.new("ScrollingFrame")
    right.Position = UDim2.new(0.5,4,0,0)
    right.Size = UDim2.new(0.5,-4,1,0)
    right.BackgroundTransparency = 1
    right.BorderSizePixel = 0
    right.ScrollBarThickness = 3
    right.ScrollBarImageColor3 = A.ACCENT
    right.AutomaticCanvasSize = Enum.AutomaticSize.Y
    right.CanvasSize = UDim2.new()
    right.Parent = page
    local layoutR = Instance.new("UIListLayout",right)
    layoutR.Padding = UDim.new(0,4)
    layoutR.SortOrder = Enum.SortOrder.LayoutOrder
    local padR = Instance.new("UIPadding",right)
    padR.PaddingTop = UDim.new(0,8)
    padR.PaddingLeft = UDim.new(0,4)
    padR.PaddingRight = UDim.new(0,8)
    padR.PaddingBottom = UDim.new(0,8)

    Pages[i] = page
    ScrollsL[i] = left
    ScrollsR[i] = right
end

local function SelectTab(index)
    for i,page in ipairs(Pages) do page.Visible = (i==index) end
    for i,btn in ipairs(TabButtons) do
        btn.TextColor3 = i==index and A.WHITE or A.GRAY
    end
end
for i,btn in ipairs(TabButtons) do
    btn.MouseButton1Click:Connect(function() SelectTab(i) end)
end
SelectTab(1)

-- SIDE PANEL
local Side = Instance.new("Frame")
Side.Name = "AstraSide"
Side.Size = UDim2.fromOffset(161,87)
Side.Position = UDim2.fromOffset(68,185)
Side.BackgroundColor3 = A.BG
Side.BorderSizePixel = 0
Side.Parent = ScreenGui
local SideScale = Instance.new("UIScale")
SideScale.Scale = 0.65
SideScale.Parent = Side
A.Stroke(Side,1)

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(1,0,0,43)
ToggleButton.BackgroundTransparency = 1
ToggleButton.BorderSizePixel = 0
ToggleButton.Text = "Toggle UI"
ToggleButton.TextColor3 = A.WHITE
ToggleButton.Font = Enum.Font.Code
ToggleButton.TextSize = 14
ToggleButton.AutoButtonColor = false
ToggleButton.Parent = Side

local SideSep = Instance.new("Frame")
SideSep.Position = UDim2.fromOffset(0,43)
SideSep.Size = UDim2.new(1,0,0,1)
SideSep.BackgroundColor3 = A.ACCENT
SideSep.BorderSizePixel = 0
SideSep.Parent = Side

local LockButton = Instance.new("TextButton")
LockButton.Position = UDim2.fromOffset(0,44)
LockButton.Size = UDim2.new(1,0,0,43)
LockButton.BackgroundTransparency = 1
LockButton.BorderSizePixel = 0
LockButton.Text = "Lock UI"
LockButton.TextColor3 = A.WHITE
LockButton.Font = Enum.Font.Code
LockButton.TextSize = 14
LockButton.AutoButtonColor = false
LockButton.Parent = Side

ToggleButton.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)
LockButton.MouseButton1Click:Connect(function()
    A.guiLocked = not A.guiLocked
    LockButton.Text = A.guiLocked and "Unlock UI" or "Lock UI"
    LockButton.TextColor3 = A.guiLocked and Color3.fromRGB(255,80,80) or A.WHITE
end)

local sideDrag = false
local sideDragStart, sideStartPos
Side.InputBegan:Connect(function(i)
    if A.guiLocked then return end
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        sideDrag = true
        sideDragStart = i.Position
        sideStartPos = Side.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if sideDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - sideDragStart
        Side.Position = UDim2.fromOffset(sideStartPos.X.Offset + d.X, sideStartPos.Y.Offset + d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        sideDrag = false
    end
end)

local draggingUI = false
local dragUIStart, startUIPos
TitleBar.InputBegan:Connect(function(i)
    if A.guiLocked then return end
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        draggingUI = true
        dragUIStart = i.Position
        startUIPos = Main.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if draggingUI and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - dragUIStart
        Main.Position = UDim2.fromOffset(startUIPos.X.Offset + d.X, startUIPos.Y.Offset + d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        draggingUI = false
    end
end)

UserInputService.InputBegan:Connect(function(inp, gpe)
    if not gpe and inp.KeyCode == Enum.KeyCode.Insert then
        Main.Visible = not Main.Visible
    end
end)

-- ===================== COMBAT TAB =====================
local CL = ScrollsL[1]
local CR = ScrollsR[1]

A.Section(CL, "AIMBOT")
A.Checkbox(CL, "Enable AimBot", false, function(v)
    A.aimbotEnabled = v
    if A.aimbotCircle then A.aimbotCircle.Visible = v end
end)
A.Slider(CL, "FOV", 10, 500, 175, function(v) A.aimbotFOV = v end)
A.Slider(CL, "Smoothness (x0.01)", 0, 100, 35, function(v) A.aimbotSmoothness = v/100 end)
A.Slider(CL, "Max Distance", 50, 1000, 400, function(v) A.aimbotMaxDistance = v end)
A.Dropdown(CL, "Aim Part", {"Head","HumanoidRootPart","Torso","UpperTorso"}, "Head", function(v) A.aimbotPart = v end)
A.Checkbox(CL, "Visible Check", true, function(v) A.aimbotVisibleCheck = v end)
A.Checkbox(CL, "Use Keybind", false, function(v) A.aimbotUseKeybind = v end)
A.Checkbox(CL, "Use Button", true, function(v)
    A.aimbotUseButton = v
    if A.aimbotBtn then A.aimbotBtn.Visible = v end
end)
A.Checkbox(CL, "Button Lock", false, function(v)
    A.aimbotBtnLocked = v
    if A.aimbotBtn then A.aimbotBtn.Active = not v end
end)
A.ColorRow(CL, "Circle Color", function() return A.aimbotCircleColor end, function(c)
    A.aimbotCircleColor = c
    if A.aimbotCircle then A.aimbotCircle.Color = c end
end)

A.Section(CL, "HITBOX EXPANDER")
A.Checkbox(CL, "Enable Hitbox", false, function(v)
    A.hitboxEnabled = v
    if not v then
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                pcall(function() 
                    local head = player.Character:FindFirstChild("Head")
                    local hum = player.Character:FindFirstChildOfClass("Humanoid")
                    if hum then
                        local hs = hum:FindFirstChild("HeadScale")
                        if hs then hs.Value = 1 end
                    end
                    if head then
                        local mesh = head:FindFirstChildOfClass("SpecialMesh")
                        if mesh then mesh.Scale = Vector3.new(1,1,1) end
                        if A.hitboxOriginalScale[head] then
                            head.Size = A.hitboxOriginalScale[head]
                        end
                    end
                end)
            end
        end
        A.hitboxOriginalScale = {}
    end
end)
A.Checkbox(CL, "Only Others (not me)", true, function(v) A.hitboxOnlyOthers = v end)
A.Slider(CL, "Hitbox Size", 1, 15, 5, function(v) A.hitboxSize = v end)

A.Section(CR, "MISC COMBAT")
A.Checkbox(CR, "Long Neck", false, function(v)
    A.longNeckEnabled = v
    if LP.Character then
        local bottom = LP.Character:FindFirstChild("Bottom")
        if bottom then
            local prism = bottom:FindFirstChild("PrismaticConstraint")
            if prism then
                if v then
                    prism.UpperLimit = 6
                    prism.LowerLimit = 6
                else
                    prism.UpperLimit = 3
                    prism.LowerLimit = 1.65
                end
            end
        end
    end
end)

-- ===================== VISUALS TAB =====================
local VL = ScrollsL[2]
local VR = ScrollsR[2]

A.Section(VL, "ESP")
A.Checkbox(VL, "Enable ESP", false, function(v) A.espEnabled = v end)
A.Checkbox(VL, "Box", true, function(v) A.espBox = v end)
A.ColorRow(VL, "Box Color", function() return A.espBoxColor end, function(c) A.espBoxColor = c end)
A.Checkbox(VL, "Name", true, function(v) A.espName = v end)
A.ColorRow(VL, "Name Color", function() return A.espNameColor end, function(c) A.espNameColor = c end)
A.Checkbox(VL, "Health", true, function(v) A.espHealth = v end)
A.Checkbox(VL, "Distance", true, function(v) A.espDistance = v end)
A.ColorRow(VL, "Dist Color", function() return A.espDistColor end, function(c) A.espDistColor = c end)
A.Checkbox(VL, "Weapon", true, function(v) A.espWeapon = v end)
A.ColorRow(VL, "Weapon Color", function() return A.espWeapColor end, function(c) A.espWeapColor = c end)

A.Section(VL, "CAMERA / WORLD")
A.Checkbox(VL, "Custom FOV", false, function(v) A.cameraFovEnabled = v end)
A.Slider(VL, "FOV Value", 60, 160, 120, function(v) A.cameraFovValue = v end)
A.Checkbox(VL, "No Fog", false, function(v)
    A.noFogEnabled = v
    if not v then
        Lighting.FogEnd = 100000
        Lighting.FogStart = 0
    end
end)
A.Checkbox(VL, "Fullbright", false, function(v)
    A.fullbrightEnabled = v
    if not v then
        Lighting.Brightness = 1
        Lighting.GlobalShadows = true
        Lighting.FogEnd = 100000
    end
end)

A.Section(VR, "GAMMA")
A.Checkbox(VR, "Enable Gamma", false, function(v)
    A.gammaEnabled = v
    if v then
        Lighting.Ambient = A.gammaColor
        Lighting.OutdoorAmbient = A.gammaColor
        Lighting.Brightness = A.gammaValue/10
    else
        Lighting.Ambient = Color3.fromRGB(128,128,128)
        Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128)
        Lighting.Brightness = 1
    end
end)
A.ColorRow(VR, "Gamma Color", function() return A.gammaColor end, function(c)
    A.gammaColor = c
    if A.gammaEnabled then
        Lighting.Ambient = c
        Lighting.OutdoorAmbient = c
    end
end)
A.Slider(VR, "Brightness (x0.1)", 1, 50, 10, function(v)
    A.gammaValue = v
    if A.gammaEnabled then Lighting.Brightness = v/10 end
end)

A.Section(VR, "FOG")
A.Checkbox(VR, "Enable Fog", false, function(v)
    A.fogEnabled = v
    if v then
        Lighting.FogStart = A.fogStart
        Lighting.FogEnd = A.fogEnd
        Lighting.FogColor = A.fogColor
    else
        Lighting.FogEnd = 100000
        Lighting.FogStart = 0
    end
end)
A.ColorRow(VR, "Fog Color", function() return A.fogColor end, function(c)
    A.fogColor = c
    if A.fogEnabled then Lighting.FogColor = c end
end)
A.Slider(VR, "Fog Start", 0, 2000, 100, function(v)
    A.fogStart = v
    if A.fogEnabled then Lighting.FogStart = v end
end)
A.Slider(VR, "Fog End", 50, 5000, 500, function(v)
    A.fogEnd = v
    if A.fogEnabled then Lighting.FogEnd = v end
end)

A.Section(VR, "CUSTOM HANDS")
A.Checkbox(VR, "Enable Custom Hands", false, function(v)
    A.customHandsEnabled = v
    if v then A.SetupCustomHands() end
end)
A.Checkbox(VR, "Rainbow Hands", false, function(v) A.customHandsRainbow = v end)
A.ColorRow(VR, "Hands Color", function() return A.customHandsColor end, function(c)
    A.customHandsColor = c
    for part,_ in pairs(A.activeLockedArms) do
        pcall(function()
            part.Color = c
            part.Transparency = A.customHandsTransp
        end)
    end
end)
A.Slider(VR, "Hands Transparency", 0, 100, 55, function(v)
    A.customHandsTransp = v/100
    for part,_ in pairs(A.activeLockedArms) do
        pcall(function() part.Transparency = v/100 end)
    end
end, "%")

A.Section(VR, "CUSTOM GUNS")
A.Checkbox(VR, "Enable Custom Guns", false, function(v) A.customGunsEnabled = v end)
A.Checkbox(VR, "Rainbow Guns", false, function(v) A.customGunsRainbow = v end)
A.ColorRow(VR, "Guns Color", function() return A.customGunsColor end, function(c) A.customGunsColor = c end)
A.Slider(VR, "Guns Transparency", 0, 100, 40, function(v) A.customGunsTransp = v/100 end, "%")

-- ===================== MISC TAB =====================
local ML = ScrollsL[3]
local MR = ScrollsR[3]

A.Section(ML, "MOVEMENT")
A.Checkbox(ML, "Noclip", false, function(v) A.noClipEnabled = v end)

A.Section(ML, "SLIDE FLY")
A.Checkbox(ML, "Enable Slide Fly", false, function(v) A.slideFlyEnabled = v end)
A.Checkbox(ML, "Full Control (Air)", false, function(v) A.slideFullControl = v end)
A.Checkbox(ML, "Anti-Detect", true, function(v) A.slideAntiDetect = v end)
A.Slider(ML, "Slide Speed", 15, 30, 23, function(v) A.slideSpeed = v end)
A.Slider(ML, "Slide Height", 1, 8, 4, function(v) A.slideHeight = v end)

A.Section(MR, "MANIPULATION")
A.Checkbox(MR, "Enable Manipulation", false, function(v) A.manipulationEnabled = v end)
A.Slider(MR, "Drop Amount (x0.1)", 1, 50, 8, function(v) A.manipulationDrop = v/10 end, " st")

-- ===================== HITBOX SYSTEM (НОВЫЙ) =====================
local function ResizeHead(character, size)
    if not character then return end
    local head = character:FindFirstChild("Head")
    if not head or not head:IsA("BasePart") then return end
    
    -- R15: через Humanoid.HeadScale
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        local headScale = humanoid:FindFirstChild("HeadScale")
        if headScale and headScale:IsA("NumberValue") then
            if headScale.Value ~= size then
                headScale.Value = size
            end
            return
        end
    end
    
    -- R6 / кастом: через SpecialMesh.Scale или Size
    local mesh = head:FindFirstChildOfClass("SpecialMesh")
    if mesh then
        if mesh.Scale ~= Vector3.new(size, size, size) then
            mesh.Scale = Vector3.new(size, size, size)
        end
    else
        if not A.hitboxOriginalScale[head] then
            A.hitboxOriginalScale[head] = head.Size
        end
        local targetSize = Vector3.new(size * 2, size, size)
        if head.Size ~= targetSize then
            head.Size = targetSize
        end
    end
end

task.spawn(function()
    while true do
        task.wait(0.5)
        if A.hitboxEnabled then
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character then
                    if A.hitboxOnlyOthers and player == LP then
                        continue
                    end
                    pcall(ResizeHead, player.Character, A.hitboxSize)
                end
            end
        end
    end
end)

-- ===================== AIMBOT SYSTEM =====================
local function GetScreenCenter()
    local V = Camera.ViewportSize
    return Vector2.new(V.X / 2, V.Y / 2)
end

local function WorldToScreenManual(WorldPos)
    local CamCF = Camera.CFrame
    local Viewport = Camera.ViewportSize
    local Focal = (Viewport.Y / 2) / math.tan(math.rad(Camera.FieldOfView / 2))
    local Rel = CamCF:PointToObjectSpace(WorldPos)
    if Rel.Z >= 0 then return nil end
    return Vector2.new(
        (Rel.X / -Rel.Z) * Focal + Viewport.X / 2,
        (-Rel.Y / -Rel.Z) * Focal + Viewport.Y / 2
    )
end

local function IsVisible(targetPart)
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LP.Character, targetPart.Parent}
    local result = workspace:Raycast(origin, direction, params)
    return result == nil
end

local function GetClosestTarget(CenterPoint)
    local BestPart, BestRoot, BestPlayer, BestDist = nil, nil, nil, A.aimbotFOV
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LP and player.Character then
            local Root = player.Character:FindFirstChild("HumanoidRootPart")
            local AimPart = player.Character:FindFirstChild(A.aimbotPart) or Root
            local Hum = player.Character:FindFirstChildOfClass("Humanoid")
            if Root and AimPart and Hum and Hum.Health > 0 then
                local ScreenPos = WorldToScreenManual(AimPart.Position)
                if ScreenPos then
                    local Dist = (ScreenPos - CenterPoint).Magnitude
                    if Dist < BestDist then
                        local dist3D = (AimPart.Position - Camera.CFrame.Position).Magnitude
                        if dist3D <= A.aimbotMaxDistance then
                            if not A.aimbotVisibleCheck or IsVisible(AimPart) then
                                BestDist = Dist
                                BestPart = AimPart
                                BestRoot = Root
                                BestPlayer = player
                            end
                        end
                    end
                end
            end
        end
    end
    return BestPart, BestRoot, BestPlayer
end

local function PredictPosition(Origin, CurrentHead, Root)
    if not Root then return CurrentHead, 0, 0 end
    local vel = Root.AssemblyLinearVelocity or Vector3.zero
    if not A.aimbotVerticalPrediction then
        vel = Vector3.new(vel.X, 0, vel.Z)
    end
    local v = A.aimbotBulletSpeed
    local g = A.aimbotGravity * A.aimbotGravityMult
    local frac = A.aimbotDropFrac
    local t = (CurrentHead - Origin).Magnitude / v
    local Predicted = CurrentHead
    for _ = 1, 5 do
        Predicted = CurrentHead + vel * (t * A.aimbotPredictionMult)
        local tGrav = t * (1 - frac)
        local dropComp = 0.5 * g * tGrav * tGrav * 0.5
        Predicted = Predicted + Vector3.new(0, dropComp, 0)
        t = (Predicted - Origin).Magnitude / v
    end
    return Predicted, (Predicted - Origin).Magnitude, t
end

local function AimAt(TargetPos)
    local currentCF = Camera.CFrame
    local targetCF = CFrame.new(currentCF.Position, TargetPos)
    if A.aimbotSmoothness <= 0 then
        Camera.CFrame = targetCF
    else
        local alpha = 1 - A.aimbotSmoothness
        Camera.CFrame = currentCF:Lerp(targetCF, alpha)
    end
end

-- AimBot Button
local AimBtnGui = Instance.new("ScreenGui")
AimBtnGui.Name = "AstraAimBtn"
AimBtnGui.ResetOnSpawn = false
AimBtnGui.Parent = GUI_PARENT

local AimBtn = Instance.new("TextButton")
AimBtn.Size = UDim2.fromOffset(120,50)
AimBtn.Position = A.aimbotBtnPos
AimBtn.BackgroundColor3 = Color3.fromRGB(200,0,0)
AimBtn.TextColor3 = A.WHITE
AimBtn.Text = "AIMBOT: OFF"
AimBtn.TextScaled = true
AimBtn.Font = Enum.Font.GothamBold
AimBtn.BorderSizePixel = 0
AimBtn.Parent = AimBtnGui
Instance.new("UICorner",AimBtn).CornerRadius = UDim.new(0,10)
A.Stroke(AimBtn,2)
A.aimbotBtn = AimBtn

local aimDrag = false
local aimDragStart, aimStartPos
AimBtn.InputBegan:Connect(function(i)
    if A.aimbotBtnLocked then return end
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        aimDrag = true
        aimDragStart = i.Position
        aimStartPos = AimBtn.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if aimDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - aimDragStart
        AimBtn.Position = UDim2.fromOffset(aimStartPos.X.Offset + d.X, aimStartPos.Y.Offset + d.Y)
        A.aimbotBtnPos = AimBtn.Position
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        aimDrag = false
    end
end)

AimBtn.MouseButton1Click:Connect(function()
    A.aimbotEnabled = not A.aimbotEnabled
    if A.aimbotEnabled then
        AimBtn.Text = "AIMBOT: ON"
        AimBtn.BackgroundColor3 = Color3.fromRGB(0,200,0)
    else
        AimBtn.Text = "AIMBOT: OFF"
        AimBtn.BackgroundColor3 = Color3.fromRGB(200,0,0)
    end
end)

if Drawing then
    A.aimbotCircle = Drawing.new("Circle")
    A.aimbotCircle.Thickness = 1
    A.aimbotCircle.NumSides = 64
    A.aimbotCircle.Radius = A.aimbotFOV
    A.aimbotCircle.Filled = false
    A.aimbotCircle.Transparency = 1
    A.aimbotCircle.Color = A.aimbotCircleColor
    A.aimbotCircle.Visible = false
end

local InfoGui = Instance.new("ScreenGui")
InfoGui.Name = "AstraAimInfo"
InfoGui.ResetOnSpawn = false
InfoGui.Parent = GUI_PARENT
local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.fromOffset(200,20)
InfoLabel.Position = UDim2.new(0, 20, 0, 160)
InfoLabel.BackgroundTransparency = 1
InfoLabel.TextColor3 = A.WHITE
InfoLabel.Text = ""
InfoLabel.TextScaled = true
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.Parent = InfoGui
A.aimbotInfoLabel = InfoLabel

UserInputService.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if A.aimbotUseKeybind and inp.KeyCode == A.aimbotKeybind then
        A.aimbotEnabled = true
    end
end)
UserInputService.InputEnded:Connect(function(inp)
    if A.aimbotUseKeybind and inp.KeyCode == A.aimbotKeybind then
        A.aimbotEnabled = false
    end
end)

-- ===================== ESP SYSTEM =====================
local function createESP(player)
    if A.espCache[player] then return end
    if not Drawing then return end
    local o = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        HPBar = Drawing.new("Square"),
        HPBg = Drawing.new("Square"),
        Dist = Drawing.new("Text"),
        Weapon = Drawing.new("Text"),
    }
    o.Box.Filled = false
    o.Box.Thickness = 1.5
    o.Name.Size = 14
    o.Name.Center = true
    o.Name.Outline = true
    o.HPBg.Filled = true
    o.HPBg.Color = Color3.fromRGB(40,40,40)
    o.HPBar.Filled = true
    o.Dist.Size = 12
    o.Dist.Center = true
    o.Dist.Outline = true
    o.Weapon.Size = 12
    o.Weapon.Center = true
    o.Weapon.Outline = true
    for _,d in pairs(o) do d.Visible = false end
    A.espCache[player] = o
end

local function removeESP(player)
    if A.espCache[player] then
        for _,d in pairs(A.espCache[player]) do pcall(function() d:Remove() end) end
        A.espCache[player] = nil
    end
end

Players.PlayerAdded:Connect(function(p) if p ~= LP then createESP(p) end end)
Players.PlayerRemoving:Connect(removeESP)
for _,p in ipairs(Players:GetPlayers()) do if p ~= LP then createESP(p) end end

-- ===================== CUSTOM HANDS =====================
local TARGET_ARM_NAMES = {["RightArm"]=true,["LeftArm"]=true,["SleeveL"]=true,["SleeveR"]=true}

local function ForceHandsStyle(part)
    if not part or not part.Parent then return end
    local pbr = part:FindFirstChildOfClass("SurfaceAppearance")
    if pbr then pbr:Destroy() end
    local sm = part:FindFirstChildOfClass("SpecialMesh")
    if sm and sm.TextureId ~= "" then sm.TextureId = "" end
    if part:IsA("MeshPart") and part.TextureID ~= "" then part.TextureID = "" end
    for _,c in ipairs(part:GetChildren()) do
        if c:IsA("Texture") or c:IsA("Decal") then c:Destroy() end
    end
    part.Color = A.customHandsColor
    part.Transparency = A.customHandsTransp
    part.Material = Enum.Material.Neon
end

local function BindArm(part)
    if A.activeLockedArms[part] then return end
    A.activeLockedArms[part] = true
    ForceHandsStyle(part)
end

function A.SetupCustomHands()
    for _,obj in ipairs(game:GetDescendants()) do
        if obj:IsA("BasePart") and TARGET_ARM_NAMES[obj.Name] then BindArm(obj) end
    end
end

LP.CharacterAdded:Connect(function()
    A.activeLockedArms = {}
    if A.customHandsEnabled then
        task.wait(0.5)
        A.SetupCustomHands()
    end
end)

-- ===================== MAIN LOOP =====================
RunService.RenderStepped:Connect(function(dt)
    if A.customHandsEnabled then
        local char = LP.Character
        if char then
            for _,p in ipairs(char:GetChildren()) do
                if p:IsA("BasePart") and TARGET_ARM_NAMES[p.Name] then
                    if not A.activeLockedArms[p] then BindArm(p) end
                    if A.customHandsRainbow then
                        A.customHandsHue = (A.customHandsHue + dt * 0.3) % 1
                        p.Color = Color3.fromHSV(A.customHandsHue, 0.85, 1)
                    else
                        p.Color = A.customHandsColor
                    end
                    p.Transparency = A.customHandsTransp
                    p.Material = Enum.Material.Neon
                end
            end
        end
    end

    if A.customGunsEnabled then
        local vm = Camera:FindFirstChild(A.TARGET_MODEL_NAME)
        if vm then
            if A.customGunsRainbow then
                A.customGunsHue = (A.customGunsHue + dt * 0.3) % 1
            end
            local col = A.customGunsRainbow and Color3.fromHSV(A.customGunsHue, 0.85, 1) or A.customGunsColor
            for _, obj in ipairs(vm:GetDescendants()) do
                if obj:IsA("BasePart") or obj:IsA("MeshPart") then
                    if obj.Name ~= "HumanoidRootPart" and obj.Name ~= "CameraBone" then
                        for _, child in ipairs(obj:GetChildren()) do
                            if child:IsA("Texture") or child:IsA("Decal") then
                                child:Destroy()
                            elseif child:IsA("SpecialMesh") then
                                child.TextureId = ""
                            end
                        end
                        obj.Material = Enum.Material.Neon
                        obj.Transparency = A.customGunsTransp
                        obj.Color = col
                    end
                end
            end
        end
    end

    if A.slideActive and A.slideFullControl then
        local char = LP.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hrp and hum then
                local moveDir = hum.MoveDirection
                local vertical = 0
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vertical = vertical + 1 end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then vertical = vertical - 1 end
                local totalMove = moveDir + Vector3.new(0, vertical, 0)
                if totalMove.Magnitude > 0 then
                    local step = A.slideSpeed * 0.0165
                    hrp.CFrame = hrp.CFrame + (totalMove.Unit * step)
                end
            end
        end
    end

    if A.longNeckEnabled and LP.Character then
        local bottom = LP.Character:FindFirstChild("Bottom")
        if bottom then
            local prism = bottom:FindFirstChild("PrismaticConstraint")
            if prism then
                pcall(function()
                    prism.UpperLimit = 6
                    prism.LowerLimit = 6
                end)
            end
        end
    end

    for player, o in pairs(A.espCache) do
        local char = player.Character
        if A.espEnabled and char then
            local root = char:FindFirstChild("HumanoidRootPart")
            local head = char:FindFirstChild("Head")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if root and head and hum and hum.Health > 0 then
                local headPos, on1 = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,0.5,0))
                local legPos, on2 = Camera:WorldToViewportPoint(root.Position - Vector3.new(0,3,0))
                if on1 and on2 then
                    local boxH = math.abs(headPos.Y - legPos.Y)
                    local boxW = boxH / 1.6
                    local bx = headPos.X - boxW/2
                    local by = headPos.Y
                    if A.espBox then
                        o.Box.Size = Vector2.new(boxW, boxH)
                        o.Box.Position = Vector2.new(bx, by)
                        o.Box.Color = A.espBoxColor
                        o.Box.Visible = true
                    else o.Box.Visible = false end
                    if A.espName then
                        o.Name.Text = player.Name
                        o.Name.Position = Vector2.new(headPos.X, by-16)
                        o.Name.Color = A.espNameColor
                        o.Name.Visible = true
                    else o.Name.Visible = false end
                    if A.espHealth then
                        local hp = math.clamp(hum.Health/hum.MaxHealth, 0, 1)
                        local barH = boxH * hp
                        o.HPBg.Size = Vector2.new(4, boxH)
                        o.HPBg.Position = Vector2.new(bx-6, by)
                        o.HPBg.Visible = true
                        o.HPBar.Size = Vector2.new(4, barH)
                        o.HPBar.Position = Vector2.new(bx-6, by+(boxH-barH))
                        o.HPBar.Color = Color3.fromHSV(hp*0.33, 1, 1)
                        o.HPBar.Visible = true
                    else
                        o.HPBg.Visible = false
                        o.HPBar.Visible = false
                    end
                    if A.espDistance then
                        local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                        local d = myRoot and math.floor((myRoot.Position - root.Position).Magnitude) or 0
                        o.Dist.Text = d.." studs"
                        o.Dist.Position = Vector2.new(headPos.X, legPos.Y+4)
                        o.Dist.Color = A.espDistColor
                        o.Dist.Visible = true
                    else o.Dist.Visible = false end
                    if A.espWeapon then
                        local handModel = char:FindFirstChild("HandModel")
                        o.Weapon.Text = handModel and handModel:GetAttribute("name") or "None"
                        o.Weapon.Position = Vector2.new(headPos.X, legPos.Y+18)
                        o.Weapon.Color = A.espWeapColor
                        o.Weapon.Visible = true
                    else o.Weapon.Visible = false end
                else
                    for _,d in pairs(o) do d.Visible = false end
                end
            else
                for _,d in pairs(o) do d.Visible = false end
            end
        else
            for _,d in pairs(o) do d.Visible = false end
        end
    end

    if A.cameraFovEnabled then
        if Camera.FieldOfView ~= A.cameraFovValue then
            Camera.FieldOfView = A.cameraFovValue
        end
    end

    if A.aimbotCircle then
        local center = GetScreenCenter()
        A.aimbotCircle.Position = center
        A.aimbotCircle.Radius = A.aimbotFOV
        A.aimbotCircle.Color = A.aimbotCircleColor
        A.aimbotCircle.Visible = A.aimbotEnabled
    end

    if A.aimbotInfoLabel then
        A.aimbotInfoLabel.Visible = A.aimbotEnabled
    end

    if A.aimbotBtn then
        A.aimbotBtn.Visible = A.aimbotUseButton
    end
end)

-- ===================== AIMBOT BINDTORENDERSTEP =====================
RunService:BindToRenderStep("AstraAimBot", Enum.RenderPriority.Camera.Value + 1, function()
    if not A.aimbotEnabled then return end
    if not LP.Character then return end
    
    local center = GetScreenCenter()
    local AimPart, BestRoot, BestPlayer = GetClosestTarget(center)
    
    if AimPart and BestRoot then
        local Origin = Camera.CFrame.Position
        local Predicted, Dist, FlightTime = PredictPosition(Origin, AimPart.Position, BestRoot)
        AimAt(Predicted)
        if A.aimbotInfoLabel then
            A.aimbotInfoLabel.Text = string.format("%s | %.0f st | %.3f s", BestPlayer.Name, Dist, FlightTime)
        end
    else
        if A.aimbotInfoLabel then
            A.aimbotInfoLabel.Text = ""
        end
    end
end)

-- ===================== HEARTBEAT =====================
RunService.Heartbeat:Connect(function()
    if A.noFogEnabled then
        Lighting.FogEnd = 1e6
        Lighting.FogStart = 1e5
    end
    if A.fullbrightEnabled then
        Lighting.Brightness = 3
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
    end
    if A.noClipEnabled then
        local char = LP.Character
        if char then
            for _,p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end
end)

-- ===================== SLIDE FLY =====================
local TargetEvent = ReplicatedStorage:WaitForChild("MovementAnimState", 10)
if TargetEvent then
    local lastSlideTime = 0
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        if self == TargetEvent and method == "FireServer" and args[1] == "Slide" and A.slideFlyEnabled then
            local now = tick()
            if now - lastSlideTime < 0.5 then
                return oldNamecall(self, ...)
            end
            lastSlideTime = now
            
            local Character = LP.Character
            if Character then
                local HRP = Character:FindFirstChild("HumanoidRootPart")
                local Hum = Character:FindFirstChildOfClass("Humanoid")
                if HRP and Hum then
                    if A.slideAntiDetect then
                        HRP.AssemblyLinearVelocity = Vector3.new(
                            HRP.AssemblyLinearVelocity.X,
                            A.slideHeight * 8,
                            HRP.AssemblyLinearVelocity.Z
                        )
                        task.wait(0.1)
                    else
                        HRP.CFrame = HRP.CFrame * CFrame.new(0, A.slideHeight, 0)
                    end
                    
                    if A.slidePlatform and A.slidePlatform.Parent then
                        A.slidePlatform:Destroy()
                    end
                    local platform = Instance.new("Part")
                    platform.Name = "AstraSlidePlatform"
                    platform.Size = A.slideAntiDetect and Vector3.new(80, 0.3, 80) or Vector3.new(250, 0.5, 250)
                    platform.Transparency = 1
                    platform.Anchored = true
                    platform.CanCollide = true
                    platform.Material = Enum.Material.SmoothPlastic
                    platform.CFrame = CFrame.new(HRP.Position.X, HRP.Position.Y - 2.8, HRP.Position.Z)
                    platform.Parent = workspace
                    A.slidePlatform = platform
                    
                    A.slideActive = true
                    
                    if A.slideConn then A.slideConn:Disconnect() end
                    A.slideConn = RunService.Heartbeat:Connect(function()
                        if A.slideActive and HRP and HRP.Parent and Hum and Hum.Parent then
                            if not A.slideFullControl then
                                local step = A.slideSpeed * (A.slideAntiDetect and 0.7 or 1) * 0.0165                                if Hum.MoveDirection.Magnitude > 0 then
                                    HRP.CFrame = HRP.CFrame + (Hum.MoveDirection * step)
                                else
                                    HRP.CFrame = HRP.CFrame + (HRP.CFrame.LookVector * step)
                                end
                            end
                        else
                            if A.slideConn then A.slideConn:Disconnect() end
                        end
                    end)
                    
                    if A.manipulationEnabled then
                        task.spawn(function()
                            while A.slideActive and HRP and HRP.Parent do
                                task.wait(0.5)
                                if not A.slideActive then break end
                                if HRP and HRP.Parent then
                                    HRP.CFrame = HRP.CFrame - Vector3.new(0, A.manipulationDrop, 0)
                                end
                            end
                        end)
                    end
                    
                    task.delay(A.slideAntiDetect and 1.0 or 1.5, function()
                        A.slideActive = false
                        if A.slideConn then A.slideConn:Disconnect() end
                        if A.slidePlatform and A.slidePlatform.Parent then
                            A.slidePlatform:Destroy()
                        end
                    end)
                end
            end
        end
        return oldNamecall(self, ...)
    end)
end

print("[Astra Lite v7] Загружено | Insert - скрыть/показать")