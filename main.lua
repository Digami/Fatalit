function obj:AddColorPicker(name, pickerOpts)
    pickerOpts = pickerOpts or {}
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 120)
    frame.Position = UDim2.new(0, 5, 0, obj.Parent.NextY + 5)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BorderSizePixel = 0
    frame.ZIndex = 5
    frame.Parent = obj.Parent.Box
    frame.Visible = obj.Enabled

    -- Título do color picker
    local title = Instance.new("TextLabel")
    title.Text = pickerOpts.Title or name
    title.Size = UDim2.new(1, -10, 0, 15)
    title.Position = UDim2.new(0, 5, 0, 2)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(180, 180, 180)
    title.Font = Enum.Font.RobotoMono
    title.TextSize = 10
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 6
    title.Parent = frame

    -- Preview da cor (quadrado)
    local preview = Instance.new("Frame")
    preview.Size = UDim2.new(0, 45, 0, 45)
    preview.Position = UDim2.new(0, 5, 0, 20)
    preview.BackgroundColor3 = pickerOpts.Default or selectedColor
    preview.BorderSizePixel = 1
    preview.BorderColor3 = c_border
    preview.ZIndex = 6
    preview.Parent = frame
    
    colorPreview = preview

    colorR, colorG, colorB = math.floor((pickerOpts.Default or selectedColor).R * 255), math.floor((pickerOpts.Default or selectedColor).G * 255), math.floor((pickerOpts.Default or selectedColor).B * 255)
    selectedColor = pickerOpts.Default or selectedColor
    obj.Value = selectedColor

    local function updateColor()
        selectedColor = Color3.fromRGB(colorR, colorG, colorB)
        preview.BackgroundColor3 = selectedColor
        obj.Value = selectedColor
        if FOVring then
            FOVring.Color = selectedColor
        end
        for _, cb in pairs(obj.OnChangedCallbacks) do
            cb()
        end
    end

    updateColor()

    -- Container para os sliders (à direita do preview)
    local slidersContainer = Instance.new("Frame")
    slidersContainer.Size = UDim2.new(1, -65, 0, 85)
    slidersContainer.Position = UDim2.new(0, 55, 0, 18)
    slidersContainer.BackgroundTransparency = 1
    slidersContainer.ZIndex = 6
    slidersContainer.Parent = frame

    -- Slider R (Vermelho)
    local rLabel = Instance.new("TextLabel")
    rLabel.Text = "R"
    rLabel.Size = UDim2.new(0, 20, 0, 18)
    rLabel.Position = UDim2.new(0, 0, 0, 0)
    rLabel.BackgroundTransparency = 1
    rLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    rLabel.Font = Enum.Font.GothamBold
    rLabel.TextSize = 12
    rLabel.ZIndex = 7
    rLabel.Parent = slidersContainer

    local rSliderBg = Instance.new("Frame")
    rSliderBg.Size = UDim2.new(1, -25, 0, 3)
    rSliderBg.Position = UDim2.new(0, 25, 0, 6)
    rSliderBg.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    rSliderBg.BorderSizePixel = 0
    rSliderBg.ZIndex = 7
    rSliderBg.Parent = slidersContainer

    local rSliderFill = Instance.new("Frame")
    rSliderFill.Size = UDim2.new((colorR / 255), 0, 1, 0)
    rSliderFill.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    rSliderFill.BorderSizePixel = 0
    rSliderFill.ZIndex = 8
    rSliderFill.Parent = rSliderBg

    local rKnob = Instance.new("Frame")
    rKnob.Size = UDim2.new(0, 8, 0, 8)
    rKnob.Position = UDim2.new((colorR / 255), -4, 0.5, -4)
    rKnob.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    rKnob.BorderSizePixel = 0
    rKnob.ZIndex = 9
    rKnob.Parent = rSliderBg

    local rValue = Instance.new("TextLabel")
    rValue.Text = tostring(colorR)
    rValue.Size = UDim2.new(0, 20, 0, 18)
    rValue.Position = UDim2.new(1, -20, 0, 0)
    rValue.BackgroundTransparency = 1
    rValue.TextColor3 = Color3.fromRGB(255, 100, 100)
    rValue.Font = Enum.Font.GothamMono
    rValue.TextSize = 10
    rValue.ZIndex = 7
    rValue.Parent = slidersContainer

    local function updateRSlider(x)
        local percent = math.clamp((x - rSliderBg.AbsolutePosition.X) / rSliderBg.AbsoluteSize.X, 0, 1)
        colorR = math.floor(percent * 255)
        rSliderFill.Size = UDim2.new(percent, 0, 1, 0)
        rKnob.Position = UDim2.new(percent, -4, 0.5, -4)
        rValue.Text = tostring(colorR)
        updateColor()
    end

    -- Slider G (Verde)
    local gLabel = Instance.new("TextLabel")
    gLabel.Text = "G"
    gLabel.Size = UDim2.new(0, 20, 0, 18)
    gLabel.Position = UDim2.new(0, 0, 0, 28)
    gLabel.BackgroundTransparency = 1
    gLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    gLabel.Font = Enum.Font.GothamBold
    gLabel.TextSize = 12
    gLabel.ZIndex = 7
    gLabel.Parent = slidersContainer

    local gSliderBg = Instance.new("Frame")
    gSliderBg.Size = UDim2.new(1, -25, 0, 3)
    gSliderBg.Position = UDim2.new(0, 25, 0, 34)
    gSliderBg.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    gSliderBg.BorderSizePixel = 0
    gSliderBg.ZIndex = 7
    gSliderBg.Parent = slidersContainer

    local gSliderFill = Instance.new("Frame")
    gSliderFill.Size = UDim2.new((colorG / 255), 0, 1, 0)
    gSliderFill.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
    gSliderFill.BorderSizePixel = 0
    gSliderFill.ZIndex = 8
    gSliderFill.Parent = gSliderBg

    local gKnob = Instance.new("Frame")
    gKnob.Size = UDim2.new(0, 8, 0, 8)
    gKnob.Position = UDim2.new((colorG / 255), -4, 0.5, -4)
    gKnob.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
    gKnob.BorderSizePixel = 0
    gKnob.ZIndex = 9
    gKnob.Parent = gSliderBg

    local gValue = Instance.new("TextLabel")
    gValue.Text = tostring(colorG)
    gValue.Size = UDim2.new(0, 20, 0, 18)
    gValue.Position = UDim2.new(1, -20, 0, 28)
    gValue.BackgroundTransparency = 1
    gValue.TextColor3 = Color3.fromRGB(100, 255, 100)
    gValue.Font = Enum.Font.GothamMono
    gValue.TextSize = 10
    gValue.ZIndex = 7
    gValue.Parent = slidersContainer

    local function updateGSlider(x)
        local percent = math.clamp((x - gSliderBg.AbsolutePosition.X) / gSliderBg.AbsoluteSize.X, 0, 1)
        colorG = math.floor(percent * 255)
        gSliderFill.Size = UDim2.new(percent, 0, 1, 0)
        gKnob.Position = UDim2.new(percent, -4, 0.5, -4)
        gValue.Text = tostring(colorG)
        updateColor()
    end

    -- Slider B (Azul)
    local bLabel = Instance.new("TextLabel")
    bLabel.Text = "B"
    bLabel.Size = UDim2.new(0, 20, 0, 18)
    bLabel.Position = UDim2.new(0, 0, 0, 56)
    bLabel.BackgroundTransparency = 1
    bLabel.TextColor3 = Color3.fromRGB(100, 150, 255)
    bLabel.Font = Enum.Font.GothamBold
    bLabel.TextSize = 12
    bLabel.ZIndex = 7
    bLabel.Parent = slidersContainer

    local bSliderBg = Instance.new("Frame")
    bSliderBg.Size = UDim2.new(1, -25, 0, 3)
    bSliderBg.Position = UDim2.new(0, 25, 0, 62)
    bSliderBg.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    bSliderBg.BorderSizePixel = 0
    bSliderBg.ZIndex = 7
    bSliderBg.Parent = slidersContainer

    local bSliderFill = Instance.new("Frame")
    bSliderFill.Size = UDim2.new((colorB / 255), 0, 1, 0)
    bSliderFill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    bSliderFill.BorderSizePixel = 0
    bSliderFill.ZIndex = 8
    bSliderFill.Parent = bSliderBg

    local bKnob = Instance.new("Frame")
    bKnob.Size = UDim2.new(0, 8, 0, 8)
    bKnob.Position = UDim2.new((colorB / 255), -4, 0.5, -4)
    bKnob.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    bKnob.BorderSizePixel = 0
    bKnob.ZIndex = 9
    bKnob.Parent = bSliderBg

    local bValue = Instance.new("TextLabel")
    bValue.Text = tostring(colorB)
    bValue.Size = UDim2.new(0, 20, 0, 18)
    bValue.Position = UDim2.new(1, -20, 0, 56)
    bValue.BackgroundTransparency = 1
    bValue.TextColor3 = Color3.fromRGB(100, 150, 255)
    bValue.Font = Enum.Font.GothamMono
    bValue.TextSize = 10
    bValue.ZIndex = 7
    bValue.Parent = slidersContainer

    local function updateBSlider(x)
        local percent = math.clamp((x - bSliderBg.AbsolutePosition.X) / bSliderBg.AbsoluteSize.X, 0, 1)
        colorB = math.floor(percent * 255)
        bSliderFill.Size = UDim2.new(percent, 0, 1, 0)
        bKnob.Position = UDim2.new(percent, -4, 0.5, -4)
        bValue.Text = tostring(colorB)
        updateColor()
    end

    -- Input handling para R
    rSliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateRSlider(UserInputService:GetMouseLocation().X)
        end
    end)

    rKnob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local dragging = true
            local conn
            conn = UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateRSlider(input.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    conn:Disconnect()
                end
            end)
        end
    end)

    -- Input handling para G
    gSliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateGSlider(UserInputService:GetMouseLocation().X)
        end
    end)

    gKnob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local dragging = true
            local conn
            conn = UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateGSlider(input.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    conn:Disconnect()
                end
            end)
        end
    end)

    -- Input handling para B
    bSliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateBSlider(UserInputService:GetMouseLocation().X)
        end
    end)

    bKnob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local dragging = true
            local conn
            conn = UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateBSlider(input.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    conn:Disconnect()
                end
            end)
        end
    end)

    obj.Parent.NextY = obj.Parent.NextY + 130
    obj.PickerFrame = frame
    return obj
end
