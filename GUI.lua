

-- SWI SWI SWI HUB - FULL EDITION
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local existing = playerGui:FindFirstChild("SwiSwiSwiHub")
if existing then existing:Destroy() end
if _G.SwiSwiSwiCleanup then pcall(_G.SwiSwiSwiCleanup) end

local ACCENT = Color3.fromRGB(0, 230, 200)
local ACCENT2 = Color3.fromRGB(170, 0, 230)
local BG = Color3.fromRGB(8, 8, 16)
local BTN = Color3.fromRGB(24, 24, 38)
local TXT = Color3.fromRGB(235, 235, 245)
local DIM = Color3.fromRGB(140, 140, 160)
local ON = Color3.fromRGB(40, 120, 80)
local STR = Color3.fromRGB(60, 60, 90)

local function stroke(p, col, thick)
    local s = Instance.new("UIStroke")
    s.Color = col or ACCENT
    s.Thickness = thick or 1.5
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = p
    return s
end

local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6)
    c.Parent = p
    return c
end

local function tween(obj, props, time)
    local t = TweenService:Create(obj, TweenInfo.new(time or 0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

local function getChar() return player.Character end
local function getRoot()
    local c = getChar()
    if not c then return nil end
    return c:FindFirstChild("HumanoidRootPart")
end
local function getHumanoid()
    local c = getChar()
    if not c then return nil end
    return c:FindFirstChildOfClass("Humanoid")
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SwiSwiSwiHub"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleBox"
toggleBtn.Size = UDim2.new(0, 90, 0, 44)
toggleBtn.Position = UDim2.new(0, 10, 0.5, -22)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
toggleBtn.BorderSizePixel = 0
toggleBtn.Text = "GUI"
toggleBtn.TextColor3 = ACCENT
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 15
toggleBtn.AutoButtonColor = true
toggleBtn.ZIndex = 10
toggleBtn.Parent = screenGui
corner(toggleBtn, 6)
stroke(toggleBtn, ACCENT, 1.5)

local panel = Instance.new("Frame")
panel.Name = "MainPanel"
panel.Size = UDim2.new(0, 420, 0, 0)
panel.Position = UDim2.new(0.5, -210, 0.5, -280)
panel.BackgroundColor3 = BG
panel.BorderSizePixel = 0
panel.Visible = false
panel.ZIndex = 5
panel.Parent = screenGui
corner(panel, 10)
stroke(panel, ACCENT, 2)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 0, 40)
title.Position = UDim2.new(0, 8, 0, 4)
title.BackgroundTransparency = 1
title.Text = "SWI SWI SWI HUB"
title.TextColor3 = ACCENT
title.Font = Enum.Font.GothamBlack
title.TextSize = 18
title.Parent = panel
title.Active = true

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -32, 0, 6)
closeBtn.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "X"
closeBtn.TextColor3 = TXT
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 12
closeBtn.ZIndex = 7
closeBtn.Parent = panel
corner(closeBtn, 4)

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -16, 0, 14)
subtitle.Position = UDim2.new(0, 8, 0, 40)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Main: QoL  -  Advanced: Movement"
subtitle.TextColor3 = DIM
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 9
subtitle.Parent = panel

local mainTab = Instance.new("TextButton")
mainTab.Size = UDim2.new(0.5, -12, 0, 28)
mainTab.Position = UDim2.new(0, 8, 0, 58)
mainTab.BackgroundColor3 = BTN
mainTab.BorderSizePixel = 0
mainTab.Text = "Main"
mainTab.TextColor3 = TXT
mainTab.Font = Enum.Font.GothamBold
mainTab.TextSize = 13
mainTab.Parent = panel
corner(mainTab, 6)
stroke(mainTab, ACCENT, 1.5)

local advTab = Instance.new("TextButton")
advTab.Size = UDim2.new(0.5, -12, 0, 28)
advTab.Position = UDim2.new(0.5, 4, 0, 58)
advTab.BackgroundColor3 = BTN
advTab.BorderSizePixel = 0
advTab.Text = "Advanced"
advTab.TextColor3 = DIM
advTab.Font = Enum.Font.GothamBold
advTab.TextSize = 13
advTab.Parent = panel
corner(advTab, 6)
stroke(advTab, STR, 1)

local function makeTabFrame(name, visible)
    local f = Instance.new("ScrollingFrame")
    f.Name = name
    f.Size = UDim2.new(1, -16, 1, -100)
    f.Position = UDim2.new(0, 8, 0, 92)
    f.BackgroundTransparency = 1
    f.BorderSizePixel = 0
    f.ScrollBarThickness = 4
    f.ScrollBarImageColor3 = ACCENT
    f.CanvasSize = UDim2.new(0, 0, 0, 0)
    f.ScrollingDirection = Enum.ScrollingDirection.Y
    f.Visible = visible
    f.Parent = panel
    return f
end

local mainFrame = makeTabFrame("Main", true)
local advFrame = makeTabFrame("Adv", false)

local function selectTab(isMain)
    mainFrame.Visible = isMain
    advFrame.Visible = not isMain
    if isMain then
        tween(mainTab, {TextColor3 = TXT}, 0.18)
        stroke(mainTab, ACCENT, 1.5)
        tween(advTab, {TextColor3 = DIM}, 0.18)
        stroke(advTab, STR, 1)
    else
        tween(advTab, {TextColor3 = TXT}, 0.18)
        stroke(advTab, ACCENT, 1.5)
        tween(mainTab, {TextColor3 = DIM}, 0.18)
        stroke(mainTab, STR, 1)
    end
end

mainTab.MouseButton1Click:Connect(function() selectTab(true) end)
advTab.MouseButton1Click:Connect(function() selectTab(false) end)

local ROW_H = 56
local ROW_GAP = 6
local rowCounts = {Main = 0, Adv = 0}

local function setOn(btn, name, row, on)
    btn:SetAttribute("On", on)
    if on then
        btn.Text = name .. ": ON"
        tween(btn, {BackgroundColor3 = ON, TextColor3 = Color3.fromRGB(220, 255, 220)}, 0.15)
        stroke(row, ACCENT, 1.5)
    else
        btn.Text = name .. ": OFF"
        tween(btn, {BackgroundColor3 = BTN, TextColor3 = TXT}, 0.15)
        stroke(row, STR, 1)
    end
end

local function makeRow(parent, name, desc, tabName)
    local idx = rowCounts[tabName]
    rowCounts[tabName] = idx + 1
    local yPos = idx * (ROW_H + ROW_GAP)
    local row = Instance.new("Frame")
    row.Name = name
    row.Size = UDim2.new(1, -4, 0, ROW_H)
    row.Position = UDim2.new(0, 2, 0, yPos)
    row.BackgroundColor3 = BTN
    row.BorderSizePixel = 0
    row.Parent = parent
    corner(row, 6)
    stroke(row, STR, 1)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -12, 0, 26)
    b.Position = UDim2.new(0, 6, 0, 4)
    b.BackgroundColor3 = BTN
    b.BorderSizePixel = 0
    b.Text = name .. ": OFF"
    b.TextColor3 = TXT
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    b.Parent = row
    corner(b, 4)
    local d = Instance.new("TextLabel")
    d.Size = UDim2.new(1, -12, 0, 20)
    d.Position = UDim2.new(0, 6, 0, 32)
    d.BackgroundTransparency = 1
    d.Text = desc
    d.TextColor3 = DIM
    d.Font = Enum.Font.Gotham
    d.TextSize = 9
    d.TextXAlignment = Enum.TextXAlignment.Left
    d.TextWrapped = true
    d.Parent = row
    local totalNeeded = yPos + ROW_H + ROW_GAP
    if parent.CanvasSize.Y.Offset < totalNeeded then
        parent.CanvasSize = UDim2.new(0, 0, 0, totalNeeded)
    end
    return b, row
end

local isOpen = false
local function setOpen(o)
    if isOpen == o then return end
    isOpen = o
    if o then
        panel.Visible = true
        panel.Size = UDim2.new(0, 420, 0, 0)
        tween(panel, {Size = UDim2.new(0, 420, 0, 560)}, 0.28)
        toggleBtn.Text = "X"
        tween(toggleBtn, {TextColor3 = ACCENT2}, 0.18)
        stroke(toggleBtn, ACCENT2, 1.5)
    else
        local t = tween(panel, {Size = UDim2.new(0, 420, 0, 0)}, 0.22)
        t.Completed:Connect(function()
            if not isOpen then panel.Visible = false end
        end)
        toggleBtn.Text = "GUI"
        tween(toggleBtn, {TextColor3 = ACCENT}, 0.18)
        stroke(toggleBtn, ACCENT, 1.5)
    end
end

toggleBtn.MouseButton1Click:Connect(function() pcall(function() setOpen(not isOpen) end) end)
closeBtn.MouseButton1Click:Connect(function() setOpen(false) end)

do
    local dragging = false
    local dragStart, startPos
    toggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = toggleBtn.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            if delta.Magnitude > 25 then
                toggleBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end
    end)
    toggleBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

do
    local dragging = false
    local dragStart, startPos
    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = panel.Position
        end
    end)
    title.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

print("=== SWI HUB BASE LOADED ===")

pcall(function()

local flySpeed = 60
local boosting = false
local function effSpeed() return flySpeed * (boosting and 3 or 1) end

local fly, flyConn, carpet
local function clearCarpet()
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj.Name == "MagicCarpet" then obj:Destroy() end
    end
    carpet = nil
end

local function startFly()
    local root = getRoot()
    local humanoid = getHumanoid()
    if not root or not humanoid then return end
    fly = true
    clearCarpet()
    humanoid.PlatformStand = true
    local c = Instance.new("Part")
    c.Name = "MagicCarpet"
    c.Size = Vector3.new(6, 0.5, 6)
    c.Anchored = false
    c.CanCollide = false
    c.CanQuery = false
    c.CanTouch = false
    c.Transparency = 1
    c.Massless = true
    c.CFrame = root.CFrame * CFrame.new(0, -3.5, 0)
    c.Parent = Workspace
    carpet = c
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = root
    weld.Part1 = c
    weld.Parent = c
    local att = Instance.new("Attachment", c)
    local lv = Instance.new("LinearVelocity")
    lv.Attachment0 = att
    lv.MaxForce = math.huge
    lv.VectorVelocity = Vector3.new(0, 0, 0)
    lv.Parent = c
    local ao = Instance.new("AlignOrientation")
    ao.Attachment0 = att
    ao.Mode = Enum.OrientationAlignmentMode.OneAttachment
    ao.MaxTorque = math.huge
    ao.Responsiveness = 20
    ao.Parent = c
    local currentVel = Vector3.new(0, 0, 0)
    flyConn = RunService.RenderStepped:Connect(function(dt)
        if not fly or not root.Parent or not c.Parent then
            flyConn:Disconnect()
            return
        end
        local cam = Workspace.CurrentCamera.CFrame
        local look = cam.LookVector
        local flat = Vector3.new(look.X, 0, look.Z)
        if flat.Magnitude > 0.001 then
            ao.CFrame = CFrame.lookAt(Vector3.new(), flat.Unit)
        end
        local md = humanoid.MoveDirection
        local tilt = md.Magnitude
        local dir = tilt > 0 and md.Unit or Vector3.new(0, 0, 0)
        local vY = 0
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) or UserInputService:IsKeyDown(Enum.KeyCode.E) then vY = vY + 1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.Q) then vY = vY - 1 end
        local es = effSpeed()
        local target = dir * (tilt * es) + Vector3.new(0, vY, 0) * es
        currentVel = currentVel:Lerp(target, math.clamp(dt * 8, 0, 1))
        lv.VectorVelocity = currentVel
    end)
end

local function stopFly()
    fly = false
    if flyConn then flyConn:Disconnect() flyConn = nil end
    local h = getHumanoid()
    if h then h.PlatformStand = false end
    clearCarpet()
end

local flyBtn, flyRow = makeRow(advFrame, "Magic Carpet Fly", "Smooth invisible carpet. WASD=move, Space/Shift=up/down.", "Adv")
flyBtn.MouseButton1Click:Connect(function()
    local o = not flyBtn:GetAttribute("On")
    setOn(flyBtn, "Magic Carpet Fly", flyRow, o)
    if o then startFly() else stopFly() end
end)

local noclipping, noclipConn
local function startNoclip()
    noclipping = true
    noclipConn = RunService.Stepped:Connect(function()
        if not noclipping then return end
        local c = getChar()
        if not c then return end
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
        end
    end)
end
local function stopNoclip()
    noclipping = false
    if noclipConn then noclipConn:Disconnect() noclipConn = nil end
    local c = getChar()
    if c then
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.CanCollide = true end
        end
    end
end
local noclipBtn, noclipRow = makeRow(advFrame, "NoClip", "Walk through walls.", "Adv")
noclipBtn.MouseButton1Click:Connect(function()
    local o = not noclipBtn:GetAttribute("On")
    setOn(noclipBtn, "NoClip", noclipRow, o)
    if o then startNoclip() else stopNoclip() end
end)

local invisible = false
local function applyLocalInvis(s)
    local c = getChar()
    if not c then return end
    for _, p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
            if s then
                if p:GetAttribute("OT") == nil then p:SetAttribute("OT", p.Transparency) end
                p.Transparency = 1
            else
                local o = p:GetAttribute("OT")
                if o ~= nil then p.Transparency = o end
            end
        elseif p:IsA("Decal") then
            if s then
                if p:GetAttribute("OT") == nil then p:SetAttribute("OT", p.Transparency) end
                p.Transparency = 1
            else
                local o = p:GetAttribute("OT")
                if o ~= nil then p.Transparency = o end
            end
        end
    end
end
local function applyNameplateHide(s)
    local h = getHumanoid()
    if not h then return end
    if s then
        if h:GetAttribute("OD") == nil then h:SetAttribute("OD", h.DisplayDistanceType.Value) end
        if h:GetAttribute("OH") == nil then h:SetAttribute("OH", h.HealthDisplayType.Value) end
        pcall(function() h.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None end)
        pcall(function() h.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff end)
    else
        local dd, hd = h:GetAttribute("OD"), h:GetAttribute("OH")
        if dd ~= nil then pcall(function() h.DisplayDistanceType = dd end) end
        if hd ~= nil then pcall(function() h.HealthDisplayType = hd end) end
    end
end
local invisConn
local function startInvis()
    invisible = true
    applyLocalInvis(true)
    applyNameplateHide(true)
    invisConn = RunService.Heartbeat:Connect(function()
        if not invisible then return end
        local c = getChar()
        if not c then return end
        for _, p in ipairs(c:GetDescendants()) do
            if (p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" and p.Transparency ~= 1) or (p:IsA("Decal") and p.Transparency ~= 1) then
                applyLocalInvis(true)
                break
            end
        end
    end)
end
local function stopInvis()
    invisible = false
    if invisConn then invisConn:Disconnect() invisConn = nil end
    applyLocalInvis(false)
    applyNameplateHide(false)
end
local invisBtn, invisRow = makeRow(advFrame, "Invisibility", "Hides you locally + nameplate.", "Adv")
invisBtn.MouseButton1Click:Connect(function()
    local o = not invisBtn:GetAttribute("On")
    setOn(invisBtn, "Invisibility", invisRow, o)
    if o then startInvis() else stopInvis() end
end)

local lastPos, lastTpTarget, autoTpRun, autoTpInterval = nil, nil, false, 1.0
local function doTeleportTo(targetPlayer)
    pcall(function()
        local myRoot = getRoot()
        local targetRoot = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myRoot and targetRoot then
            lastPos = myRoot.Position
            lastTpTarget = targetPlayer
            local off = (targetRoot.CFrame.LookVector * -4) + Vector3.new(0, 2, 0)
            myRoot.CFrame = CFrame.new(targetRoot.Position + off, targetRoot.Position)
        end
    end)
end
local function doTeleportBack()
    pcall(function()
        if lastPos then
            local r = getRoot()
            if r then r.CFrame = CFrame.new(lastPos) end
        end
    end)
end
local function startAutoTp()
    if autoTpRun then return end
    autoTpRun = true
    task.spawn(function()
        while autoTpRun do
            local keepGoing = true
            pcall(function()
                if lastTpTarget and lastTpTarget.Character and lastTpTarget.Character:FindFirstChild("HumanoidRootPart") then
                    local myRoot = getRoot()
                    local targetRoot = lastTpTarget.Character:FindFirstChild("HumanoidRootPart")
                    if myRoot and targetRoot then
                        if not lastPos then lastPos = myRoot.Position end
                        local off = (targetRoot.CFrame.LookVector * -4) + Vector3.new(0, 2, 0)
                        myRoot.CFrame = CFrame.new(targetRoot.Position + off, targetRoot.Position)
                        task.wait(autoTpInterval)
                        if not autoTpRun then keepGoing = false return end
                        myRoot.CFrame = CFrame.new(lastPos)
                        task.wait(autoTpInterval)
                    else
                        task.wait(0.2)
                    end
                else
                    task.wait(0.2)
                end
            end)
            if not keepGoing then return end
            task.wait(0.05)
        end
    end)
end
local function stopAutoTp() autoTpRun = false end

local tpBtn, tpRow = makeRow(advFrame, "TP to Player", "Tap name to teleport.", "Adv")
local tpList = Instance.new("Frame")
tpList.Size = UDim2.new(0, 170, 0, 240)
tpList.Position = UDim2.new(0.5, -85, 0.5, -120)
tpList.BackgroundColor3 = BG
tpList.BorderSizePixel = 0
tpList.Visible = false
tpList.ZIndex = 9
tpList.Parent = screenGui
corner(tpList, 8)
stroke(tpList, ACCENT, 1.5)
local tpTitle = Instance.new("TextLabel")
tpTitle.Size = UDim2.new(1, -32, 0, 24)
tpTitle.Position = UDim2.new(0, 8, 0, 2)
tpTitle.BackgroundTransparency = 1
tpTitle.Text = "Teleport to:"
tpTitle.TextColor3 = ACCENT
tpTitle.Font = Enum.Font.GothamBold
tpTitle.TextSize = 12
tpTitle.TextXAlignment = Enum.TextXAlignment.Left
tpTitle.Parent = tpList
local tpCloseBtn = Instance.new("TextButton")
tpCloseBtn.Size = UDim2.new(0, 22, 0, 22)
tpCloseBtn.Position = UDim2.new(1, -26, 0, 3)
tpCloseBtn.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
tpCloseBtn.BorderSizePixel = 0
tpCloseBtn.Text = "X"
tpCloseBtn.TextColor3 = TXT
tpCloseBtn.Font = Enum.Font.GothamBold
tpCloseBtn.TextSize = 11
tpCloseBtn.Parent = tpList
corner(tpCloseBtn, 4)
local tpScroll = Instance.new("ScrollingFrame")
tpScroll.Size = UDim2.new(1, -14, 1, -34)
tpScroll.Position = UDim2.new(0, 7, 0, 30)
tpScroll.BackgroundTransparency = 1
tpScroll.BorderSizePixel = 0
tpScroll.ScrollBarThickness = 4
tpScroll.ScrollBarImageColor3 = ACCENT
tpScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
tpScroll.Parent = tpList

local function refreshTPList()
    local kids = tpScroll:GetChildren()
    for _, c in ipairs(kids) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    local yOff = 0
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= player then
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, 0, 0, 26)
            b.Position = UDim2.new(0, 0, 0, yOff)
            b.BackgroundColor3 = BTN
            b.BorderSizePixel = 0
            b.Text = "  " .. pl.Name
            b.TextColor3 = TXT
            b.Font = Enum.Font.Gotham
            b.TextSize = 11
            b.TextXAlignment = Enum.TextXAlignment.Left
            b.Parent = tpScroll
            corner(b, 4)
            b.MouseButton1Click:Connect(function() doTeleportTo(pl) end)
            yOff = yOff + 28
        end
    end
    tpScroll.CanvasSize = UDim2.new(0, 0, 0, yOff)
end

local function closeTpList()
    if not tpList.Visible then return end
    local t = tween(tpList, {Size = UDim2.new(0, 170, 0, 0)}, 0.18)
    t.Completed:Connect(function() tpList.Visible = false end)
    setOn(tpBtn, "TP to Player", tpRow, false)
end

tpBtn.MouseButton1Click:Connect(function()
    if tpList.Visible then
        closeTpList()
    else
        tpList.Visible = true
        refreshTPList()
        tpList.Size = UDim2.new(0, 170, 0, 0)
        tween(tpList, {Size = UDim2.new(0, 170, 0, 240)}, 0.22)
        setOn(tpBtn, "TP to Player", tpRow, true)
    end
end)
tpCloseBtn.MouseButton1Click:Connect(closeTpList)

local tpBackBtn, tpBackRow = makeRow(advFrame, "Teleport Back", "Returns to position before last TP.", "Adv")
tpBackBtn.MouseButton1Click:Connect(function() doTeleportBack() end)

local autoTpBtn, autoTpRow = makeRow(advFrame, "Auto TP", "Bounce between you and last TP target.", "Adv")
autoTpBtn.MouseButton1Click:Connect(function()
    local o = not autoTpBtn:GetAttribute("On")
    setOn(autoTpBtn, "Auto TP", autoTpRow, o)
    if o then startAutoTp() else stopAutoTp() end
end)

local aiR = Instance.new("Frame")
aiR.Size = UDim2.new(1, -4, 0, 56)
aiR.Position = UDim2.new(0, 2, 0, rowCounts["Adv"] * (56 + 6))
aiR.BackgroundColor3 = BTN
aiR.BorderSizePixel = 0
aiR.Parent = advFrame
corner(aiR, 6)
stroke(aiR, STR, 1)
rowCounts["Adv"] = rowCounts["Adv"] + 1
advFrame.CanvasSize = UDim2.new(0, 0, 0, rowCounts["Adv"] * (56 + 6))
local aiL = Instance.new("TextLabel")
aiL.Size = UDim2.new(1, -12, 0, 20)
aiL.Position = UDim2.new(0, 6, 0, 4)
aiL.BackgroundTransparency = 1
aiL.Text = "Auto TP Interval: " .. autoTpInterval .. "s"
aiL.TextColor3 = TXT
aiL.Font = Enum.Font.GothamBold
aiL.TextSize = 12
aiL.TextXAlignment = Enum.TextXAlignment.Left
aiL.Parent = aiR
local aiD = Instance.new("TextLabel")
aiD.Size = UDim2.new(1, -12, 0, 12)
aiD.Position = UDim2.new(0, 6, 0, 24)
aiD.BackgroundTransparency = 1
aiD.Text = "Time between each TP. - / + to adjust."
aiD.TextColor3 = DIM
aiD.Font = Enum.Font.Gotham
aiD.TextSize = 9
aiD.TextXAlignment = Enum.TextXAlignment.Left
aiD.Parent = aiR
local amB = Instance.new("TextButton")
amB.Size = UDim2.new(0, 46, 0, 20)
amB.Position = UDim2.new(0, 6, 0, 34)
amB.BackgroundColor3 = BTN
amB.BorderSizePixel = 0
amB.Text = "-"
amB.TextColor3 = ACCENT
amB.Font = Enum.Font.GothamBold
amB.TextSize = 14
amB.Parent = aiR
corner(amB, 4)
local apB = Instance.new("TextButton")
apB.Size = UDim2.new(0, 46, 0, 20)
apB.Position = UDim2.new(0, 56, 0, 34)
apB.BackgroundColor3 = BTN
apB.BorderSizePixel = 0
apB.Text = "+"
apB.TextColor3 = ACCENT
apB.Font = Enum.Font.GothamBold
apB.TextSize = 14
apB.Parent = aiR
corner(apB, 4)
local function updAi() aiL.Text = "Auto TP Interval: " .. autoTpInterval .. "s" end
amB.MouseButton1Click:Connect(function() autoTpInterval = math.max(0.1, autoTpInterval - 0.5) updAi() end)
apB.MouseButton1Click:Connect(function() autoTpInterval = math.min(30, autoTpInterval + 0.5) updAi() end)

local spR = Instance.new("Frame")
spR.Size = UDim2.new(1, -4, 0, 56)
spR.Position = UDim2.new(0, 2, 0, rowCounts["Adv"] * (56 + 6))
spR.BackgroundColor3 = BTN
spR.BorderSizePixel = 0
spR.Parent = advFrame
corner(spR, 6)
stroke(spR, STR, 1)
rowCounts["Adv"] = rowCounts["Adv"] + 1
advFrame.CanvasSize = UDim2.new(0, 0, 0, rowCounts["Adv"] * (56 + 6))
local spL = Instance.new("TextLabel")
spL.Size = UDim2.new(1, -12, 0, 20)
spL.Position = UDim2.new(0, 6, 0, 4)
spL.BackgroundTransparency = 1
spL.Text = "Fly Speed: " .. flySpeed
spL.TextColor3 = TXT
spL.Font = Enum.Font.GothamBold
spL.TextSize = 12
spL.TextXAlignment = Enum.TextXAlignment.Left
spL.Parent = spR
local spD = Instance.new("TextLabel")
spD.Size = UDim2.new(1, -12, 0, 12)
spD.Position = UDim2.new(0, 6, 0, 24)
spD.BackgroundTransparency = 1
spD.Text = "Hold B for x3 boost."
spD.TextColor3 = DIM
spD.Font = Enum.Font.Gotham
spD.TextSize = 9
spD.TextXAlignment = Enum.TextXAlignment.Left
spD.Parent = spR
local mB = Instance.new("TextButton")
mB.Size = UDim2.new(0, 46, 0, 20)
mB.Position = UDim2.new(0, 6, 0, 34)
mB.BackgroundColor3 = BTN
mB.BorderSizePixel = 0
mB.Text = "-"
mB.TextColor3 = ACCENT
mB.Font = Enum.Font.GothamBold
mB.TextSize = 14
mB.Parent = spR
corner(mB, 4)
local pB = Instance.new("TextButton")
pB.Size = UDim2.new(0, 46, 0, 20)
pB.Position = UDim2.new(0, 56, 0, 34)
pB.BackgroundColor3 = BTN
pB.BorderSizePixel = 0
pB.Text = "+"
pB.TextColor3 = ACCENT
pB.Font = Enum.Font.GothamBold
pB.TextSize = 14
pB.Parent = spR
corner(pB, 4)
local function updSp() spL.Text = "Fly Speed: " .. flySpeed end
mB.MouseButton1Click:Connect(function() flySpeed = math.max(10, flySpeed - 20) updSp() end)
pB.MouseButton1Click:Connect(function() flySpeed = math.min(500, flySpeed + 20) updSp() end)

makeRow(advFrame, "Boost (hold B)", "Hold B while flying for x3 speed.", "Adv")
UserInputService.InputBegan:Connect(function(i, g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.B then boosting = true end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.B then boosting = false end
end)

local landBtn = makeRow(advFrame, "Land", "Descend to nearest ground.", "Adv")
landBtn.MouseButton1Click:Connect(function()
    pcall(function()
        local r = getRoot()
        if not r then return end
        local ray = Workspace:Raycast(r.Position + Vector3.new(0, 2, 0), Vector3.new(0, -1000, 0))
        if ray then
            r.CFrame = CFrame.new(ray.Position + Vector3.new(0, 3, 0))
        end
    end)
end)

local infJump, infJumpConn
local function startInfJump()
    infJump = true
    infJumpConn = UserInputService.JumpRequest:Connect(function()
        if not infJump then return end
        local h = getHumanoid()
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
end
local function stopInfJump()
    infJump = false
    if infJumpConn then infJumpConn:Disconnect() infJumpConn = nil end
end
local ijBtn, ijRow = makeRow(advFrame, "Infinite Jump", "Jump in mid-air.", "Adv")
ijBtn.MouseButton1Click:Connect(function()
    local o = not ijBtn:GetAttribute("On")
    setOn(ijBtn, "Infinite Jump", ijRow, o)
    if o then startInfJump() else stopInfJump() end
end)

local walkA, walkC
local function startWalk()
    walkA = true
    walkC = RunService.Heartbeat:Connect(function()
        if not walkA then return end
        local h = getHumanoid()
        if h and h.WalkSpeed < 32 then h.WalkSpeed = 32 end
    end)
end
local function stopWalk()
    walkA = false
    if walkC then walkC:Disconnect() walkC = nil end
    local h = getHumanoid()
    if h then h.WalkSpeed = 16 end
end
local walkBtn, walkRow = makeRow(advFrame, "Speed Walk 2x", "Doubles walk speed.", "Adv")
walkBtn.MouseButton1Click:Connect(function()
    local o = not walkBtn:GetAttribute("On")
    setOn(walkBtn, "Speed Walk 2x", walkRow, o)
    if o then startWalk() else stopWalk() end
end)

local afkA, afkC
local function startAfk()
    afkA = true
    pcall(function()
        afkC = player.Idled:Connect(function()
            if not afkA then return end
            pcall(function()
                UserInputService:SendKeyEvent(true, Enum.KeyCode.Unknown, false, nil)
                task.wait(0.1)
                UserInputService:SendKeyEvent(false, Enum.KeyCode.Unknown, false, nil)
            end)
        end)
    end)
end
local function stopAfk()
    afkA = false
    if afkC then afkC:Disconnect() afkC = nil end
end
local afkBtn, afkRow = makeRow(advFrame, "Anti-AFK", "Prevents idle kick.", "Adv")
afkBtn.MouseButton1Click:Connect(function()
    local o = not afkBtn:GetAttribute("On")
    setOn(afkBtn, "Anti-AFK", afkRow, o)
    if o then startAfk() else stopAfk() end
end)

local nightA
local function startNight()
    nightA = true
    Lighting.Brightness = 2
    Lighting.ClockTime = 12
    Lighting.FogEnd = 100000
    Lighting.GlobalShadows = false
    Lighting.Ambient = Color3.fromRGB(180, 180, 180)
    Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
end
local function stopNight()
    nightA = false
    Lighting.Brightness = 1
    Lighting.ClockTime = 14
    Lighting.GlobalShadows = true
    Lighting.Ambient = Color3.fromRGB(70, 70, 70)
    Lighting.OutdoorAmbient = Color3.fromRGB(120, 120, 120)
end
local nightBtn, nightRow = makeRow(advFrame, "Night Vision", "Brightens entire map.", "Adv")
nightBtn.MouseButton1Click:Connect(function()
    local o = not nightBtn:GetAttribute("On")
    setOn(nightBtn, "Night Vision", nightRow, o)
    if o then startNight() else stopNight() end
end)

local hideA
local function startHide()
    hideA = true
    task.spawn(function()
        while hideA do
            pcall(function()
                for _, pl in ipairs(Players:GetPlayers()) do
                    if pl ~= player and pl.Character then
                        for _, b in ipairs(pl.Character:GetDescendants()) do
                            if b:IsA("BillboardGui") or b:IsA("SurfaceGui") then b.Enabled = false end
                        end
                    end
                end
            end)
            task.wait(2)
        end
    end)
end
local function stopHide()
    hideA = false
    pcall(function()
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= player and pl.Character then
                for _, b in ipairs(pl.Character:GetDescendants()) do
                    if b:IsA("BillboardGui") or b:IsA("SurfaceGui") then b.Enabled = true end
                end
            end
        end
    end)
end
local hideBtn, hideRow = makeRow(advFrame, "Hide Player Names", "Hides other players' name tags.", "Adv")
hideBtn.MouseButton1Click:Connect(function()
    local o = not hideBtn:GetAttribute("On")
    setOn(hideBtn, "Hide Player Names", hideRow, o)
    if o then startHide() else stopHide() end
end)

local collecting = {}
local function findResource(kw)
    local root = getRoot()
    if not root then return nil end
    local near, nd = nil, math.huge
    pcall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local n = string.lower(obj.Name)
                if string.find(n, kw) and not string.find(n, "gen") and not string.find(n, "spawn") and not string.find(n, "ui") then
                    local d = (obj.Position - root.Position).Magnitude
                    if d < nd and d < 5000 then
                        near, nd = obj, d
                    end
                end
            end
        end
    end)
    return near
end
local function startCollect(kw)
    if collecting[kw] then return end
    collecting[kw] = true
    task.spawn(function()
        while collecting[kw] do
            pcall(function()
                local r = getRoot()
                if r then
                    local t = findResource(kw)
                    if t then
                        r.CFrame = CFrame.new(t.Position + Vector3.new(0, 3, 0))
                        task.wait(0.18)
                    else
                        task.wait(0.5)
                    end
                else
                    task.wait(0.5)
                end
            end)
            task.wait(0.05)
        end
    end)
end
local function stopCollect(kw) collecting[kw] = false end

local emeraldBtn, emeraldRow = makeRow(mainFrame, "Collect Emeralds", "Auto-TPs to nearest emerald.", "Main")
emeraldBtn.MouseButton1Click:Connect(function()
    local o = not emeraldBtn:GetAttribute("On")
    setOn(emeraldBtn, "Collect Emeralds", emeraldRow, o)
    if o then startCollect("emerald") else stopCollect("emerald") end
end)
local diamondBtn, diamondRow = makeRow(mainFrame, "Collect Diamonds", "Auto-TPs to nearest diamond.", "Main")
diamondBtn.MouseButton1Click:Connect(function()
    local o = not diamondBtn:GetAttribute("On")
    setOn(diamondBtn, "Collect Diamonds", diamondRow, o)
    if o then startCollect("diamond") else stopCollect("diamond") end
end)
local ironBtn, ironRow = makeRow(mainFrame, "Collect Iron", "Auto-TPs to nearest iron.", "Main")
ironBtn.MouseButton1Click:Connect(function()
    local o = not ironBtn:GetAttribute("On")
    setOn(ironBtn, "Collect Iron", ironRow, o)
    if o then startCollect("iron") else stopCollect("iron") end
end)
local goldBtn, goldRow = makeRow(mainFrame, "Collect Gold", "Auto-TPs to nearest gold.", "Main")
goldBtn.MouseButton1Click:Connect(function()
    local o = not goldBtn:GetAttribute("On")
    setOn(goldBtn, "Collect Gold", goldRow, o)
    if o then startCollect("gold") else stopCollect("gold") end
end)

local aQ
local function startAQ()
    aQ = true
    task.spawn(function()
        while aQ do
            pcall(function()
                for _, g in ipairs(playerGui:GetChildren()) do
                    for _, b in ipairs(g:GetDescendants()) do
                        if b:IsA("TextButton") and b.Visible and b.Active then
                            local t = string.lower(b.Text or "")
                            if string.find(t, "play") or string.find(t, "queue") or string.find(t, "join") then
                                pcall(function() b:Activate() end)
                            end
                        end
                    end
                end
            end)
            task.wait(2)
        end
    end)
end
local function stopAQ() aQ = false end
local qBtn, qRow = makeRow(mainFrame, "Auto-Queue", "Auto-clicks Play/Queue.", "Main")
qBtn.MouseButton1Click:Connect(function()
    local o = not qBtn:GetAttribute("On")
    setOn(qBtn, "Auto-Queue", qRow, o)
    if o then startAQ() else stopAQ() end
end)

local bE, bH = false, {}
local function clrBE()
    for _, h in ipairs(bH) do h:Destroy() end
    bH = {}
end
local function startBE()
    bE = true
    task.spawn(function()
        while bE do
            clrBE()
            pcall(function()
                for _, o in ipairs(Workspace:GetDescendants()) do
                    if o:IsA("BasePart") and string.find(string.lower(o.Name), "bed") then
                        local h = Instance.new("Highlight")
                        h.FillColor = Color3.fromRGB(255, 80, 80)
                        h.OutlineColor = Color3.fromRGB(255, 255, 255)
                        h.FillTransparency = 0.5
                        h.Adornee = o
                        h.Parent = o
                        table.insert(bH, h)
                    end
                end
            end)
            task.wait(2)
        end
    end)
end
local function stopBE() bE = false clrBE() end
local beBtn, beRow = makeRow(mainFrame, "Bed ESP", "Red beds through walls.", "Main")
beBtn.MouseButton1Click:Connect(function()
    local o = not beBtn:GetAttribute("On")
    setOn(beBtn, "Bed ESP", beRow, o)
    if o then startBE() else stopBE() end
end)

local gE, gH = false, {}
local function clrGE()
    for _, h in ipairs(gH) do h:Destroy() end
    gH = {}
end
local function startGE()
    gE = true
    task.spawn(function()
        while gE do
            clrGE()
            pcall(function()
                for _, o in ipairs(Workspace:GetDescendants()) do
                    if o:IsA("BasePart") then
                        local n = string.lower(o.Name)
                        if string.find(n, "gen") or string.find(n, "spawn") then
                            local col = Color3.fromRGB(255, 255, 255)
                            if string.find(n, "emerald") then col = Color3.fromRGB(40, 200, 80)
                            elseif string.find(n, "diamond") then col = Color3.fromRGB(80, 200, 255)
                            elseif string.find(n, "gold") then col = Color3.fromRGB(255, 215, 0)
                            elseif string.find(n, "iron") then col = Color3.fromRGB(200, 200, 200) end
                            local h = Instance.new("Highlight")
                            h.FillColor = col
                            h.OutlineColor = Color3.fromRGB(255, 255, 255)
                            h.FillTransparency = 0.6
                            h.Adornee = o
                            h.Parent = o
                            table.insert(gH, h)
                        end
                    end
                end
            end)
            task.wait(2)
        end
    end)
end
local function stopGE() gE = false clrGE() end
local geBtn, geRow = makeRow(mainFrame, "Generator ESP", "Color-coded generators.", "Main")
geBtn.MouseButton1Click:Connect(function()
    local o = not geBtn:GetAttribute("On")
    setOn(geBtn, "Generator ESP", geRow, o)
    if o then startGE() else stopGE() end
end)

local pE, pH = false, {}
local function clrPE()
    for _, h in ipairs(pH) do h:Destroy() end
    pH = {}
end
local function startPE()
    pE = true
    task.spawn(function()
        while pE do
            clrPE()
            pcall(function()
                for _, pl in ipairs(Players:GetPlayers()) do
                    if pl ~= player and pl.Character then
                        local h = Instance.new("Highlight")
                        h.FillColor = (pl.Team == player.Team) and Color3.fromRGB(80, 150, 255) or Color3.fromRGB(255, 80, 80)
                        h.OutlineColor = Color3.fromRGB(255, 255, 255)
                        h.FillTransparency = 0.6
                        h.Adornee = pl.Character
                        h.Parent = pl.Character
                        table.insert(pH, h)
                    end
                end
            end)
            task.wait(1)
        end
    end)
end
local function stopPE() pE = false clrPE() end
local peBtn, peRow = makeRow(mainFrame, "Player ESP", "Team=blue, enemy=red.", "Main")
peBtn.MouseButton1Click:Connect(function()
    local o = not peBtn:GetAttribute("On")
    setOn(peBtn, "Player ESP", peRow, o)
    if o then startPE() else stopPE() end
end)

local aEq, aEqC
local WP = {"sword", "blade", "scythe", "axe", "dagger", "knife", "hammer", "spear"}
local function startAE()
    aEq = true
    pcall(function()
        local bp = player:WaitForChild("Backpack", 5)
        if not bp then return end
        aEqC = bp.ChildAdded:Connect(function()
            if not aEq then return end
            task.wait(0.1)
            pcall(function()
                local best, rank = nil, 0
                local function scan(ct)
                    if not ct then return end
                    for _, t in ipairs(ct:GetChildren()) do
                        if t:IsA("Tool") then
                            local n = string.lower(t.Name)
                            for r, kw in ipairs(WP) do
                                if string.find(n, kw) and r > rank then
                                    best, rank = t, r
                                    break
                                end
                            end
                        end
                    end
                end
                scan(player:FindFirstChild("Backpack"))
                scan(getChar())
                if best and best.Parent == player:FindFirstChild("Backpack") then
                    best.Parent = getChar()
                end
            end)
        end)
    end)
end
local function stopAE()
    aEq = false
    if aEqC then aEqC:Disconnect() aEqC = nil end
end
local aeBtn, aeRow = makeRow(mainFrame, "Auto-Equip Weapon", "Auto-equips best weapon.", "Main")
aeBtn.MouseButton1Click:Connect(function()
    local o = not aeBtn:GetAttribute("On")
    setOn(aeBtn, "Auto-Equip Weapon", aeRow, o)
    if o then startAE() else stopAE() end
end)

local hF = Instance.new("Frame")
hF.Size = UDim2.new(0, 150, 0, 86)
hF.Position = UDim2.new(1, -160, 1, -106)
hF.BackgroundColor3 = BG
hF.BorderSizePixel = 0
hF.Visible = false
hF.ZIndex = 8
hF.Parent = screenGui
corner(hF, 6)
stroke(hF, ACCENT, 1.5)
local hT = Instance.new("TextLabel")
hT.Size = UDim2.new(1, 0, 0, 18)
hT.BackgroundTransparency = 1
hT.Text = "  RESOURCES"
hT.TextColor3 = ACCENT
hT.Font = Enum.Font.GothamBold
hT.TextSize = 10
hT.TextXAlignment = Enum.TextXAlignment.Left
hT.Parent = hF
local hL = {}
for i, n in ipairs({"Emeralds", "Diamonds", "Iron", "Gold"}) do
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 16)
    l.Position = UDim2.new(0, 0, 0, 16 + (i-1)*16)
    l.BackgroundTransparency = 1
    l.Text = "  " .. n .. ": 0"
    l.TextColor3 = TXT
    l.Font = Enum.Font.Gotham
    l.TextSize = 10
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = hF
    hL[string.lower(n)] = l
end
local function countRes(n)
    local c = 0
    pcall(function()
        local ls = player:FindFirstChild("leaderstats")
        if ls then
            for _, s in ipairs(ls:GetChildren()) do
                if string.find(string.lower(s.Name), n) then
                    c = s.Value
                    return
                end
            end
        end
        local bp = player:FindFirstChild("Backpack")
        local ch = getChar()
        local function scan(ct)
            if not ct then return end
            for _, i in ipairs(ct:GetChildren()) do
                if string.find(string.lower(i.Name), n) then c = c + 1 end
            end
        end
        scan(bp)
        scan(ch)
    end)
    return c
end
local hC
local function startH()
    hF.Visible = true
    hC = RunService.Heartbeat:Connect(function()
        for n, l in pairs(hL) do
            l.Text = "  " .. n:sub(1,1):upper() .. n:sub(2) .. ": " .. countRes(n)
        end
    end)
end
local function stopH()
    hF.Visible = false
    if hC then hC:Disconnect() hC = nil end
end
local hBtn, hRow = makeRow(mainFrame, "Resource HUD", "Live resource counts.", "Main")
hBtn.MouseButton1Click:Connect(function()
    local o = not hBtn:GetAttribute("On")
    setOn(hBtn, "Resource HUD", hRow, o)
    if o then startH() else stopH() end
end)

local coL, coC
local function startCO()
    if not coL then
        coL = Instance.new("TextLabel")
        coL.Size = UDim2.new(0, 180, 0, 20)
        coL.Position = UDim2.new(0, 8, 0, 50)
        coL.BackgroundColor3 = BG
        coL.BorderSizePixel =0
        coL.Text = " X:0 Y:0 Z:0"
        coL.TextColor3 = ACCENT
        coL.Font = Enum.Font.GothamBold
        coL.TextSize = 10
        coL.TextXAlignment = Enum.TextXAlignment.Left
        coL.ZIndex = 9
        coL.Parent = screenGui
        corner(coL, 4)
        stroke(coL, ACCENT, 1)
    end
    coL.Visible = true
    coC = RunService.Heartbeat:Connect(function()
        local r = getRoot()
        if r then
            coL.Text = string.format(" X:%.0f  Y:%.0f  Z:%.0f", r.Position.X, r.Position.Y, r.Position.Z)
        end
    end)
end
local function stopCO()
    if coC then coC:Disconnect() coC = nil end
    if coL then coL.Visible = false end
end
local coBtn, coRow = makeRow(mainFrame, "Coordinates", "Live X/Y/Z top-left.", "Main")
coBtn.MouseButton1Click:Connect(function()
    local o = not coBtn:GetAttribute("On")
    setOn(coBtn, "Coordinates", coRow, o)
    if o then startCO() else stopCO() end
end)

player.CharacterAdded:Connect(function()
    if fly then stopFly() setOn(flyBtn, "Magic Carpet Fly", flyRow, false) end
    if noclipping then stopNoclip() setOn(noclipBtn, "NoClip", noclipRow, false) end
    if invisible then
        task.wait(0.5)
        if invisible then applyLocalInvis(true) applyNameplateHide(true) end
    end
end)

_G.SwiSwiSwiCleanup = function()
    for k in pairs(collecting) do stopCollect(k) end
    stopAQ() stopH() stopBE() stopGE() stopPE() stopAE() stopCO()
    if fly then stopFly() end
    if noclipping then stopNoclip() end
    if invisible then stopInvis() end
    if infJump then stopInfJump() end
    if walkA then stopWalk() end
    if afkA then stopAfk() end
    if nightA then stopNight() end
    if hideA then stopHide() end
    stopAutoTp()
end

end)

print("=== SWI SWI SWI HUB - FULLY LOADED ===")
