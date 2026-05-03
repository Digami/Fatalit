-- SERVIÇOS
local Player = game.Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

-- ESTADOS INICIAIS
local aimbotEnabled = true
local fov = 150
local smoothing = 0.5
local uiVisible = true
local currentTab = "Main"
local selectedTarget = "Everyone" -- Padrão agora é mirar em todos
local glowESPEnabled = false

local circleColor = Color3.fromRGB(150, 100, 255)
local selectedColor = circleColor
local rainbowMode = false
local colorPreview = nil
local colorR, colorG, colorB = 150, 100, 255

local wallCheck = true
local teamCheck = false
local targetPart = "Head"
local toggleGuiKey = Enum.KeyCode.Insert 

-- CONFIGURAÇÕES DO CÍRCULO
local hasDrawing, DrawingLib = pcall(function() return Drawing end)
local FOVring = nil

if hasDrawing and DrawingLib then
    FOVring = Drawing.new("Circle")
    FOVring.Visible = true
    FOVring.Thickness = 1
    FOVring.Color = circleColor
end

-- PALETA EXTERNAL
local c_bg = Color3.fromRGB(10, 10, 10)
local c_subbg = Color3.fromRGB(15, 15, 15)
local c_sidebar = Color3.fromRGB(12, 12, 12)
local c_accent = Color3.fromRGB(150, 100, 255)
local c_border = Color3.fromRGB(30, 30, 30)
local c_text = Color3.fromRGB(200, 200, 200)

-- TENTA COLOCAR NO COREGUI, SE FALHAR VAI PRO PLAYERGUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Gemini_External_Final_Merged"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global 

local success, _ = pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not success then
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
end

-- UI PRINCIPAL
local OuterFrame = Instance.new("Frame")
OuterFrame.Size = UDim2.new(0, 560, 0, 410)
OuterFrame.Position = UDim2.new(0.5, -280, 0.5, -205)
OuterFrame.BackgroundColor3 = c_border
OuterFrame.BorderSizePixel = 0
OuterFrame.Active = true
OuterFrame.Draggable = true
OuterFrame.Parent = ScreenGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(1, -2, 1, -2)
MainFrame.Position = UDim2.new(0, 1, 0, 1)
MainFrame.BackgroundColor3 = c_bg
MainFrame.BorderSizePixel = 0
MainFrame.Parent = OuterFrame

local AccentLine = Instance.new("Frame")
AccentLine.Size = UDim2.new(1, 0, 0, 2)
AccentLine.BackgroundColor3 = c_accent
AccentLine.BorderSizePixel = 0
AccentLine.ZIndex = 5
AccentLine.Parent = MainFrame

local Canvas = Instance.new("Frame")
Canvas.Size = UDim2.new(1, 0, 1, 0)
Canvas.BackgroundTransparency = 1
Canvas.Parent = MainFrame

-- SIDEBAR
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 110, 1, -2)
Sidebar.Position = UDim2.new(0, 0, 0, 2)
Sidebar.BackgroundColor3 = c_sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Canvas

local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, -120, 1, -20)
TabContainer.Position = UDim2.new(0, 120, 0, 10)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = Canvas

local Tabs = {
    Main = Instance.new("Frame", TabContainer),
    Visuals = Instance.new("Frame", TabContainer),
    Settings = Instance.new("Frame", TabContainer)
}

for _, t in pairs(Tabs) do
    t.Size = UDim2.new(1, 0, 1, 0)
    t.BackgroundTransparency = 1
    t.Visible = false
end
Tabs.Main.Visible = true

-- [FUNÇÕES DE CRIAÇÃO UI]
local function createGroupbox(title, parent, pos, size)
    local outline = Instance.new("Frame")
    outline.Size = size
    outline.Position = pos
    outline.BackgroundColor3 = c_border
    outline.BorderSizePixel = 0
    outline.Parent = parent

    local box = Instance.new("Frame")
    box.Size = UDim2.new(1, -2, 1, -2)
    box.Position = UDim2.new(0, 1, 0, 1)
    box.BackgroundColor3 = c_subbg
    box.BorderSizePixel = 0
    box.Parent = outline

    local label = Instance.new("TextLabel")
    label.Text = title:upper()
    label.Size = UDim2.new(0, 0, 0, 10)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.TextColor3 = Color3.fromRGB(150, 150, 150)
    label.Font = Enum.Font.RobotoMono
    label.TextSize = 11
    label.BackgroundTransparency = 1
    label.Parent = box

    return box
end

local function createToggle(name, parent, pos, state, callback)
    local tgl = Instance.new("TextButton")
    tgl.Size = UDim2.new(1, 0, 0, 22)
    tgl.Position = pos
    tgl.BackgroundTransparency = 1
    tgl.Text = "  " .. name
    tgl.TextColor3 = c_text
    tgl.Font = Enum.Font.SourceSans
    tgl.TextSize = 14
    tgl.TextXAlignment = Enum.TextXAlignment.Left
    tgl.ZIndex = 2
    tgl.Parent = parent

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 10, 0, 10)
    indicator.Position = UDim2.new(1, -20, 0.5, -5)
    indicator.BackgroundColor3 = state and c_accent or Color3.fromRGB(30, 30, 30)
    indicator.BorderSizePixel = 0
    indicator.ZIndex = 3
    indicator.Parent = tgl

    tgl.MouseButton1Click:Connect(function()
        local s = callback()
        indicator.BackgroundColor3 = s and c_accent or Color3.fromRGB(30, 30, 30)
    end)
end

local function createDropdown(name, parent, pos, options, callback)
    local label = Instance.new("TextLabel")
    label.Text = "  " .. name:upper()
    label.Size = UDim2.new(1, 0, 0, 15)
    label.Position = pos
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(130, 130, 130)
    label.Font = Enum.Font.RobotoMono
    label.TextSize = 10
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 5 
    label.Parent = parent

    local opened = false
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 22)
    btn.Position = UDim2.new(0, 5, 0, pos.Y.Offset + 18)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    btn.BorderColor3 = Color3.fromRGB(40, 40, 40)
    btn.Text = options[1]
    btn.TextColor3 = c_accent
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 13
    btn.ZIndex = 10 
    btn.Parent = parent

    local container = Instance.new("ScrollingFrame")
    container.Size = UDim2.new(1, 0, 0, 0)
    container.Position = UDim2.new(0, 0, 1, 1)
    container.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    container.BorderColor3 = Color3.fromRGB(40, 40, 40)
    container.Visible = false
    container.ZIndex = 100 
    container.ScrollBarThickness = 2
    container.ScrollBarImageColor3 = c_accent
    container.CanvasSize = UDim2.new(0, 0, 0, #options * 20)
    container.Parent = btn

    local layout = Instance.new("UIListLayout", container)
    
    for _, opt in pairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, 0, 0, 20)
        optBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        optBtn.BorderSizePixel = 0
        optBtn.Text = opt
        optBtn.TextColor3 = c_text
        optBtn.Font = Enum.Font.SourceSans
        optBtn.TextSize = 12
        optBtn.ZIndex = 101 
        optBtn.Parent = container

        optBtn.MouseButton1Click:Connect(function()
            btn.Text = opt
            opened = false
            container.Visible = false
            container.Size = UDim2.new(1, 0, 0, 0)
            btn.ZIndex = 10 
            callback(opt)
        end)
    end

    btn.MouseButton1Click:Connect(function()
        opened = not opened
        container.Visible = opened
        if opened then
            btn.ZIndex = 100 
            container.Size = UDim2.new(1, 0, 0, math.min(#options * 20, 100))
        else
            btn.ZIndex = 10
            container.Size = UDim2.new(1, 0, 0, 0)
        end
    end)
end

local function createSlider(name, parent, pos, min, max, start, callback)
    local label = Instance.new("TextLabel")
    label.Text = name:upper()
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = pos
    label.BackgroundTransparency = 1
    label.TextColor3 = c_text
    label.Font = Enum.Font.SourceSans
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent

    local valLabel = Instance.new("TextLabel")
    valLabel.Text = tostring(start)
    valLabel.Size = UDim2.new(1, -10, 0, 20)
    valLabel.Position = pos
    valLabel.BackgroundTransparency = 1
    valLabel.TextColor3 = c_accent
    valLabel.Font = Enum.Font.RobotoMono
    valLabel.TextSize = 12
    valLabel.TextXAlignment = Enum.TextXAlignment.Right
    valLabel.Parent = parent

    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -10, 0, 4)
    sliderBg.Position = UDim2.new(0, 5, 0, pos.Y.Offset + 22)
    sliderBg.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = parent

    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((start - min)/(max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = c_accent
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBg

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = UDim2.new((start - min)/(max - min), -6, 0.5, -6)
    knob.AnchorPoint = Vector2.new(0, 0)
    knob.BackgroundColor3 = c_accent
    knob.BorderSizePixel = 0
    knob.Active = true
    knob.Parent = sliderBg

    local dragging = false

    local function updateFromX(x)
        local percent = math.clamp((x - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (max - min) * percent)
        sliderFill.Size = UDim2.new(percent, 0, 1, 0)
        knob.Position = UDim2.new(percent, -6, 0.5, -6)
        valLabel.Text = tostring(value)
        callback(value)
    end

    local function beginDrag()
        dragging = true
        OuterFrame.Draggable = false
    end

    local function endDrag()
        dragging = false
        OuterFrame.Draggable = true
    end

    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            beginDrag()
            updateFromX(UserInputService:GetMouseLocation().X)
        end
    end)

    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            beginDrag()
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateFromX(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseButton1 then
            endDrag()
        end
    end)
end

local function updateColorPreview(color)
    if colorPreview then
        colorPreview.BackgroundColor3 = color
    end
end

local function resetColorSelection()
    selectedColor = circleColor
    colorR, colorG, colorB = math.floor(circleColor.R * 255), math.floor(circleColor.G * 255), math.floor(circleColor.B * 255)
    updateColorPreview(selectedColor)
end

local function applyColorSelection()
    circleColor = selectedColor
    if FOVring then
        FOVring.Color = circleColor
    end
end

local function createTabBtn(name, pos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.Position = UDim2.new(0, 0, 0, pos)
    btn.BackgroundTransparency = 1
    btn.Text = name:upper()
    btn.TextColor3 = (currentTab == name) and c_accent or Color3.fromRGB(100, 100, 100)
    btn.Font = Enum.Font.RobotoMono
    btn.TextSize = 12
    btn.Parent = Sidebar

    btn.MouseButton1Click:Connect(function()
        currentTab = name
        for n, f in pairs(Tabs) do f.Visible = (n == name) end
        for _, b in pairs(Sidebar:GetChildren()) do
            if b:IsA("TextButton") then
                b.TextColor3 = (b.Text == name:upper()) and c_accent or Color3.fromRGB(100, 100, 100)
            end
        end
    end)
end

createTabBtn("Main", 50)
createTabBtn("Visuals", 90)
createTabBtn("Settings", 130)

-- ==========================================
-- LÓGICA AUXILIAR (BUSCAR JOGADOR MAIS PRÓXIMO)
-- ==========================================
local function GetClosestPlayer()
    local closest = nil
    local shortestDistance = fov

    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= Player and p.Character and p.Character:FindFirstChild(targetPart) then
            -- Verifica se o jogador está na tela
            local pos, onScreen = Camera:WorldToViewportPoint(p.Character[targetPart].Position)
            if onScreen then
                local distance = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                -- Verifica se está dentro do círculo de FOV
                if distance < shortestDistance then
                    closest = p
                    shortestDistance = distance
                end
            end
        end
    end
    return closest
end

-- ==========================================
-- ABA MAIN: SETTINGS (ESQUERDA)
-- ==========================================
-- ==========================================
-- ABA MAIN: SETTINGS (ESQUERDA)
-- ==========================================
local mainBox = createGroupbox("Aimbot Master", Tabs.Main, UDim2.new(0, 5, 0, 15), UDim2.new(0, 210, 0, 260))

createToggle("Enable Aimbot", mainBox, UDim2.new(0, 5, 0, 25), aimbotEnabled, function()
    aimbotEnabled = not aimbotEnabled
    return aimbotEnabled
end)

createDropdown("Target Hitbox", mainBox, UDim2.new(0, 5, 0, 55), {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"}, function(val)
    targetPart = val
end)

createToggle("Ignore Walls", mainBox, UDim2.new(0, 5, 0, 105), wallCheck, function()
    wallCheck = not wallCheck
    return wallCheck
end)

createToggle("Ignore Allies", mainBox, UDim2.new(0, 5, 0, 130), teamCheck, function()
    teamCheck = not teamCheck
    return teamCheck
end)

-- ESTE É O NOVO BOTÃO NO QUADRADO VERMELHO
createToggle("Glowing ESP (Neon)", mainBox, UDim2.new(0, 5, 0, 155), glowESPEnabled, function()
    glowESPEnabled = not glowESPEnabled
    return glowESPEnabled
end)
-- ==========================================
-- ABA MAIN: SELEÇÃO DE ALVO (DIREITA)
-- ==========================================
local targetBox = createGroupbox("Target Selection", Tabs.Main, UDim2.new(0, 225, 0, 15), UDim2.new(0, 210, 0, 260))

local DropBtn = Instance.new("TextButton")
DropBtn.Size = UDim2.new(1, -10, 0, 30)
DropBtn.Position = UDim2.new(0, 5, 0, 15)
DropBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
DropBtn.Text = "ALVO: TODOS"
DropBtn.TextColor3 = c_accent
DropBtn.Font = Enum.Font.SourceSansBold
DropBtn.TextSize = 13
DropBtn.Parent = targetBox

local ScrollList = Instance.new("ScrollingFrame")
ScrollList.Size = UDim2.new(1, -10, 1, -55)
ScrollList.Position = UDim2.new(0, 5, 0, 50)
ScrollList.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
ScrollList.BorderSizePixel = 0
ScrollList.Visible = false -- Inicia fechado
ScrollList.ScrollBarThickness = 3
ScrollList.Parent = targetBox

local Layout = Instance.new("UIListLayout", ScrollList)
Layout.Padding = UDim.new(0, 5)

local function RefreshList()
    for _, item in pairs(ScrollList:GetChildren()) do
        if item:IsA("TextButton") then item:Destroy() end
    end

    -- BOTÃO FIXO "EVERYONE"
    local allBtn = Instance.new("TextButton")
    allBtn.Size = UDim2.new(1, -5, 0, 35)
    allBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    allBtn.Text = "🎯  Everyone"
    allBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    allBtn.Font = Enum.Font.SourceSansBold
    allBtn.Parent = ScrollList
    allBtn.MouseButton1Click:Connect(function()
        selectedTarget = "Everyone"
        DropBtn.Text = "ALVO: TODOS"
        ScrollList.Visible = false
    end)

    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= Player then
            local pBtn = Instance.new("TextButton")
            pBtn.Size = UDim2.new(1, -5, 0, 40)
            pBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            pBtn.Text = p.DisplayName 
            pBtn.TextColor3 = Color3.new(1, 1, 1)
            pBtn.Font = Enum.Font.SourceSans
            pBtn.TextSize = 14
            pBtn.TextXAlignment = Enum.TextXAlignment.Left
            pBtn.Parent = ScrollList

            local margin = Instance.new("UIPadding")
            margin.PaddingLeft = UDim.new(0, 45) 
            margin.Parent = pBtn

            local pImg = Instance.new("ImageLabel")
            pImg.Size = UDim2.new(0, 30, 0, 30)
            pImg.Position = UDim2.new(0, -40, 0.5, -15)
            pImg.BackgroundTransparency = 1
            pImg.Parent = pBtn
            
            task.spawn(function()
                local content, isLoaded = game.Players:GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
                if isLoaded then pImg.Image = content end
            end)

            pBtn.MouseButton1Click:Connect(function()
                selectedTarget = p
                DropBtn.Text = "ALVO: " .. p.DisplayName:upper()
                ScrollList.Visible = false
            end)
        end
    end
    ScrollList.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y)
end

DropBtn.MouseButton1Click:Connect(function()
    if ScrollList.Visible then
        ScrollList.Visible = false
    else
        RefreshList()
        ScrollList.Visible = true
    end
end)

-- ==========================================
-- ABA VISUALS
-- ==========================================
local aimVisualsBox = createGroupbox("Aimbot Precision", Tabs.Visuals, UDim2.new(0, 5, 0, 15), UDim2.new(0.95, 0, 0, 180))

createSlider("FOV Radius", aimVisualsBox, UDim2.new(0, 5, 0, 30), 10, 800, 150, function(v)
    fov = v
end)

createSlider("Smoothness (%)", aimVisualsBox, UDim2.new(0, 5, 0, 80), 1, 100, 50, function(v)
    smoothing = v / 100
end)

local colorPanel = {
    Box = createGroupbox("Color Panel", Tabs.Visuals, UDim2.new(0, 5, 0, 120), UDim2.new(0.95, 0, 0, 220)),
    NextY = 25
}

function colorPanel:AddToggle(id, opts)
    opts = opts or {}
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(1, 0, 0, 24)
    toggle.Position = UDim2.new(0, 0, 0, self.NextY)
    toggle.BackgroundTransparency = 1
    toggle.Text = "  " .. (opts.Text or id)
    toggle.TextColor3 = c_text
    toggle.Font = Enum.Font.SourceSans
    toggle.TextSize = 14
    toggle.TextXAlignment = Enum.TextXAlignment.Left
    toggle.Parent = self.Box

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 10, 0, 10)
    indicator.Position = UDim2.new(1, -20, 0.5, -5)
    indicator.BackgroundColor3 = opts.Default and c_accent or Color3.fromRGB(30, 30, 30)
    indicator.BorderSizePixel = 0
    indicator.Parent = toggle

    local obj = {
        Enabled = opts.Default == nil and false or opts.Default,
        Parent = self,
        PickerFrame = nil
    }

    function obj:AddColorPicker(name, pickerOpts)
        pickerOpts = pickerOpts or {}
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 150)
        frame.Position = UDim2.new(0, 0, 0, obj.Parent.NextY + 30)
        frame.BackgroundColor3 = c_subbg
        frame.BorderSizePixel = 0
        frame.Parent = obj.Parent.Box
        frame.Visible = obj.Enabled

        local title = Instance.new("TextLabel")
        title.Text = pickerOpts.Title or name
        title.Size = UDim2.new(1, -10, 0, 18)
        title.Position = UDim2.new(0, 5, 0, 5)
        title.BackgroundTransparency = 1
        title.TextColor3 = c_text
        title.Font = Enum.Font.RobotoMono
        title.TextSize = 12
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = frame

        local preview = Instance.new("Frame")
        preview.Size = UDim2.new(0, 60, 0, 60)
        preview.Position = UDim2.new(0, 5, 0, 30)
        preview.BackgroundColor3 = pickerOpts.Default or selectedColor
        preview.BorderSizePixel = 0
        preview.Parent = frame

        colorR, colorG, colorB = math.floor((pickerOpts.Default or selectedColor).R * 255), math.floor((pickerOpts.Default or selectedColor).G * 255), math.floor((pickerOpts.Default or selectedColor).B * 255)
        selectedColor = pickerOpts.Default or selectedColor

        local function updateColor()
            selectedColor = Color3.fromRGB(colorR, colorG, colorB)
            preview.BackgroundColor3 = selectedColor
            if FOVring then
                FOVring.Color = selectedColor
            end
        end

        updateColor()

        createSlider("Red", frame, UDim2.new(0, 80, 0, 30), 0, 255, colorR, function(v)
            colorR = v
            updateColor()
        end)

        createSlider("Green", frame, UDim2.new(0, 80, 0, 70), 0, 255, colorG, function(v)
            colorG = v
            updateColor()
        end)

        createSlider("Blue", frame, UDim2.new(0, 80, 0, 110), 0, 255, colorB, function(v)
            colorB = v
            updateColor()
        end)

        obj.Parent.NextY = obj.Parent.NextY + 160
        obj.PickerFrame = frame
        return {Frame = frame, Preview = preview}
    end

    toggle.MouseButton1Click:Connect(function()
        obj.Enabled = not obj.Enabled
        indicator.BackgroundColor3 = obj.Enabled and c_accent or Color3.fromRGB(30, 30, 30)
        if obj.PickerFrame then
            obj.PickerFrame.Visible = obj.Enabled
        end
        if not obj.Enabled then
            resetColorSelection()
        end
    end)

    self.NextY = self.NextY + 30
    return obj
end

local Toggle = colorPanel:AddToggle("MyToggle", {
    Text = "This is a toggle",
    Default = true
})

local ColorPicker = Toggle:AddColorPicker("ColorPicker1", {
    Default = Color3.new(1, 0, 0),
    Title = "Some color"
})

-- ==========================================
-- LÓGICA DO AIMBOT (INTEGRADA)
-- ==========================================
RunService.RenderStepped:Connect(function()
    if FOVring then
        local mouse = UserInputService:GetMouseLocation()
        FOVring.Position = mouse
        FOVring.Radius = fov
        if rainbowMode then
            selectedColor = Color3.fromHSV((tick() * 0.2) % 1, 1, 1)
            circleColor = selectedColor
            if colorPreview then
                colorPreview.BackgroundColor3 = selectedColor
            end
        end
        FOVring.Color = circleColor
        FOVring.Visible = aimbotEnabled and uiVisible
    end
    
    if aimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        -- PARTE INTEGRADA AQUI:
        local target = (selectedTarget == "Everyone") and GetClosestPlayer() or selectedTarget

        if target and target.Character and target.Character:FindFirstChild(targetPart) then
            local pos = target.Character[targetPart].Position
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, pos), 1 - smoothing)
        end
    end
end)

-- Tecla Insert para abrir/fechar o menu
UserInputService.InputBegan:Connect(function(i)
    if i.KeyCode == toggleGuiKey then
        uiVisible = not uiVisible
        OuterFrame.Visible = uiVisible
    end
end)
