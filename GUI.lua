-- ============================================================
--  CHEAT SIMULATOR — Main LocalScript
--  Place in: StarterPlayerScripts
--  All features FREE for testing (gamepass gating removed)
-- ============================================================

local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService   = game:GetService("TweenService")
local Workspace      = game:GetService("Workspace")

local LocalPlayer   = Players.LocalPlayer
local PlayerGui     = LocalPlayer:WaitForChild("PlayerGui")
local Camera        = Workspace.CurrentCamera

-- ============================================================
--  CONFIG  (tweak these values to tune the cheats)
-- ============================================================
local CFG = {
    -- Aimbot
    AimbotEnabled      = false,
    AimbotFOV          = 300,       -- studs — how far aimbot locks on
    AimbotSmoothing    = 0.15,      -- 0 = instant snap, 1 = very slow
    AimbotHeadlock     = true,      -- aim at head vs HumanoidRootPart

    -- Kill Aura
    KillAuraEnabled    = false,
    KillAuraDamage     = 15,        -- damage per hit
    KillAuraRange      = 40,        -- studs radius
    KillAuraRate       = 0.4,       -- seconds between hits

    -- Anti-Void Scaffold
    ScaffoldEnabled    = false,
    ScaffoldTriggerY   = 10,        -- Y level below which scaffold activates
    ScaffoldMaterial   = Enum.Material.SmoothPlastic,
    ScaffoldColor      = BrickColor.new("Bright blue"),
    ScaffoldLifetime   = 6,         -- seconds before scaffold block disappears

    -- Speed Hack
    SpeedEnabled       = false,
    SpeedMultiplier    = 2.5,

    -- High Jump
    HighJumpEnabled    = false,
    HighJumpPower      = 100,

    -- Fly
    FlyEnabled         = false,
    FlySpeed           = 60,

    -- Infinite Stamina (just keeps jump available)
    InfJumpEnabled     = false,
    InfJumpCount       = 0,         -- internal counter

    -- Auto Collect (pulls nearby parts/pickups toward you)
    AutoCollectEnabled = false,
    AutoCollectRange   = 20,

    -- Ghost Mode (no collision with other players)
    GhostEnabled       = false,

    -- Trajectory Predictor (shows where a thrown tool lands)
    TrajectoryEnabled  = false,

    -- Radar (minimap dots for all players)
    RadarEnabled       = false,

    -- ESP (name + health above players through walls)
    ESPEnabled         = false,
}

-- Internal state
local _killAuraTimer  = 0
local _scaffoldCooldown = 0
local _flyBodyVelocity  = nil
local _flyBodyGyro      = nil
local _espBillboards    = {}
local _radarDots        = {}
local _configKey        = "CheatSimCFG_v1"

-- ============================================================
--  UTILITY
-- ============================================================
local function getCharacter()
    return LocalPlayer.Character
end

local function getHRP()
    local c = getCharacter()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local c = getCharacter()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function getNearestPlayer(maxRange)
    local hrp = getHRP()
    if not hrp then return nil, nil end
    local best, bestDist, bestChar = nil, maxRange, nil
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local target = CFG.AimbotHeadlock
                and p.Character:FindFirstChild("Head")
                or p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if target and hum and hum.Health > 0 then
                local dist = (hrp.Position - target.Position).Magnitude
                if dist < bestDist then
                    best = target
                    bestDist = dist
                    bestChar = p.Character
                end
            end
        end
    end
    return best, bestChar
end

-- Damage a character using their humanoid (works server-side via RemoteEvent
-- if you have one; for now fires a BindableEvent or just tags humanoid)
local function dealDamage(targetChar, amount)
    local hum = targetChar:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health > 0 then
        -- In a real game you'd fire a server RemoteEvent here.
        -- For testing in Studio with a server script listening:
        local remote = Workspace:FindFirstChild("DamageRemote")
            or game.ReplicatedStorage:FindFirstChild("DamageRemote")
        if remote and remote:IsA("RemoteEvent") then
            remote:FireServer(targetChar, amount)
        else
            -- Studio fallback: direct (only works in solo/Studio)
            hum:TakeDamage(amount)
        end
    end
end

-- ============================================================
--  AIMBOT  (weapon-agnostic — works with any equipped Tool)
-- ============================================================
local function updateAimbot()
    if not CFG.AimbotEnabled then return end
    local target, _ = getNearestPlayer(CFG.AimbotFOV)
    if not target then return end

    -- Smoothly rotate camera toward target
    local targetPos  = target.Position
    local camCF      = Camera.CFrame
    local lookAt     = CFrame.lookAt(camCF.Position, targetPos)
    Camera.CFrame    = camCF:Lerp(lookAt, CFG.AimbotSmoothing)
end

-- Auto-swing: if player has any Tool equipped and aimbot target is in range,
-- simulate an activation (works for any sword/tool with a melee hit server-side)
local function aimbotAutoSwing()
    if not CFG.AimbotEnabled then return end
    local char = getCharacter()
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end
    local target, targetChar = getNearestPlayer(15) -- swing range
    if not target or not targetChar then return end
    -- Fire the tool's remote (most sword scripts use "SwordRemote" or "HitRemote")
    local remote = tool:FindFirstChildOfClass("RemoteEvent")
        or tool:FindFirstChild("HitEvent")
        or tool:FindFirstChild("SwordRemote")
    if remote then
        remote:FireServer(targetChar)
    else
        -- Fallback: direct damage
        dealDamage(targetChar, 15)
    end
end

-- ============================================================
--  KILL AURA
-- ============================================================
local function updateKillAura(dt)
    if not CFG.KillAuraEnabled then return end
    _killAuraTimer = _killAuraTimer + dt
    if _killAuraTimer < CFG.KillAuraRate then return end
    _killAuraTimer = 0
    local hrp = getHRP()
    if not hrp then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local otherHRP = p.Character:FindFirstChild("HumanoidRootPart")
            local hum      = p.Character:FindFirstChildOfClass("Humanoid")
            if otherHRP and hum and hum.Health > 0 then
                local dist = (hrp.Position - otherHRP.Position).Magnitude
                if dist <= CFG.KillAuraRange then
                    dealDamage(p.Character, CFG.KillAuraDamage)
                end
            end
        end
    end
end

-- ============================================================
--  ANTI-VOID SCAFFOLD
-- ============================================================
local function updateScaffold(dt)
    if not CFG.ScaffoldEnabled then return end
    _scaffoldCooldown = math.max(0, _scaffoldCooldown - dt)
    if _scaffoldCooldown > 0 then return end
    local hrp = getHRP()
    if not hrp then return end
    local pos = hrp.Position
    -- Only activate if below threshold Y and falling
    local vel = hrp.AssemblyLinearVelocity
    if pos.Y > CFG.ScaffoldTriggerY or vel.Y >= -5 then return end
    _scaffoldCooldown = 0.35

    -- Raycast down to check there's no floor already close
    local rayResult = Workspace:Raycast(
        pos,
        Vector3.new(0, -6, 0),
        RaycastParams.new()
    )
    if rayResult then return end -- floor already there

    -- Place scaffold block
    local block = Instance.new("Part")
    block.Size          = Vector3.new(8, 1, 8)
    block.Position      = Vector3.new(pos.X, pos.Y - 3, pos.Z)
    block.Anchored      = true
    block.BrickColor    = CFG.ScaffoldColor
    block.Material      = CFG.ScaffoldMaterial
    block.Name          = "ScaffoldBlock"
    block.CanCollide    = true
    block.Parent        = Workspace

    -- Fade and remove after lifetime
    local lifetime = CFG.ScaffoldLifetime
    task.delay(lifetime - 1, function()
        if block and block.Parent then
            TweenService:Create(block, TweenInfo.new(1), {Transparency = 1}):Play()
        end
    end)
    task.delay(lifetime, function()
        if block and block.Parent then block:Destroy() end
    end)
end

-- ============================================================
--  SPEED HACK
-- ============================================================
local function updateSpeed()
    local hum = getHumanoid()
    if not hum then return end
    if CFG.SpeedEnabled then
        hum.WalkSpeed = 16 * CFG.SpeedMultiplier
    else
        hum.WalkSpeed = 16
    end
end

-- ============================================================
--  HIGH JUMP
-- ============================================================
local function setupHighJump()
    UserInputService.JumpRequest:Connect(function()
        if not CFG.HighJumpEnabled then return end
        local hum = getHumanoid()
        if hum then
            hum.JumpPower = CFG.HighJumpPower
            task.delay(0.1, function()
                if hum then hum.JumpPower = 50 end
            end)
        end
    end)
end

-- ============================================================
--  INFINITE JUMP
-- ============================================================
local function setupInfJump()
    UserInputService.JumpRequest:Connect(function()
        if not CFG.InfJumpEnabled then return end
        local hum = getHumanoid()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

-- ============================================================
--  FLY
-- ============================================================
local function enableFly()
    local hrp = getHRP()
    local hum = getHumanoid()
    if not hrp or not hum then return end
    hum.PlatformStand = true

    _flyBodyVelocity = Instance.new("BodyVelocity")
    _flyBodyVelocity.Velocity    = Vector3.zero
    _flyBodyVelocity.MaxForce    = Vector3.new(1e5,1e5,1e5)
    _flyBodyVelocity.Parent      = hrp

    _flyBodyGyro = Instance.new("BodyGyro")
    _flyBodyGyro.MaxTorque       = Vector3.new(1e5,1e5,1e5)
    _flyBodyGyro.D               = 100
    _flyBodyGyro.CFrame          = hrp.CFrame
    _flyBodyGyro.Parent          = hrp
end

local function disableFly()
    local hum = getHumanoid()
    if hum then hum.PlatformStand = false end
    if _flyBodyVelocity then _flyBodyVelocity:Destroy(); _flyBodyVelocity = nil end
    if _flyBodyGyro     then _flyBodyGyro:Destroy();     _flyBodyGyro     = nil end
end

local function updateFly()
    if not CFG.FlyEnabled then
        if _flyBodyVelocity then disableFly() end
        return
    end
    if not _flyBodyVelocity then enableFly() end
    local hrp = getHRP()
    if not hrp or not _flyBodyVelocity then return end

    local cf   = Camera.CFrame
    local move = Vector3.zero
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cf.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cf.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cf.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cf.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0,1,0) end

    _flyBodyVelocity.Velocity = move.Magnitude > 0
        and move.Unit * CFG.FlySpeed
        or Vector3.zero
    _flyBodyGyro.CFrame = cf
end

-- ============================================================
--  GHOST MODE (no player collisions)
-- ============================================================
local function updateGhost()
    local char = getCharacter()
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CollisionGroup = CFG.GhostEnabled
                and "GhostPlayers"   -- set this collision group up in game
                or  "Default"
        end
    end
end

-- ============================================================
--  AUTO COLLECT
-- ============================================================
local function updateAutoCollect()
    if not CFG.AutoCollectEnabled then return end
    local hrp = getHRP()
    if not hrp then return end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("pickup")
        or obj:IsA("BasePart") and obj.Name:lower():find("coin")
        or obj:IsA("BasePart") and obj.Name:lower():find("gem") then
            local dist = (hrp.Position - obj.Position).Magnitude
            if dist <= CFG.AutoCollectRange then
                obj.Position = hrp.Position
            end
        end
    end
end

-- ============================================================
--  ESP (name + health labels through walls)
-- ============================================================
local function updateESP()
    -- Remove old billboards for players who left
    for player, bb in pairs(_espBillboards) do
        if not Players:FindFirstChild(player.Name) or not CFG.ESPEnabled then
            bb:Destroy()
            _espBillboards[player] = nil
        end
    end
    if not CFG.ESPEnabled then return end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum then
                if not _espBillboards[p] then
                    local bb = Instance.new("BillboardGui")
                    bb.Size           = UDim2.new(0, 120, 0, 36)
                    bb.StudsOffset    = Vector3.new(0, 3, 0)
                    bb.AlwaysOnTop    = true
                    bb.Adornee        = hrp
                    bb.Parent         = PlayerGui
                    local lbl         = Instance.new("TextLabel", bb)
                    lbl.Size          = UDim2.new(1, 0, 1, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.TextColor3    = Color3.fromRGB(255, 80, 80)
                    lbl.TextStrokeTransparency = 0.4
                    lbl.Font          = Enum.Font.GothamBold
                    lbl.TextSize      = 13
                    lbl.Name          = "ESPLabel"
                    _espBillboards[p] = bb
                end
                local lbl = _espBillboards[p]:FindFirstChild("ESPLabel")
                if lbl then
                    lbl.Text = p.DisplayName .. "\n❤️ " .. math.floor(hum.Health)
                end
            end
        end
    end
end

-- ============================================================
--  RADAR (basic — shows dots in a ScreenGui corner)
-- ============================================================
local _radarGui = nil
local function buildRadar()
    if _radarGui then _radarGui:Destroy() end
    _radarGui = Instance.new("ScreenGui")
    _radarGui.Name           = "CheatRadar"
    _radarGui.ResetOnSpawn   = false
    _radarGui.Parent         = PlayerGui

    local bg = Instance.new("Frame", _radarGui)
    bg.Name              = "RadarBG"
    bg.Size              = UDim2.new(0, 130, 0, 130)
    bg.Position          = UDim2.new(1, -145, 1, -145)
    bg.BackgroundColor3  = Color3.fromRGB(10, 10, 20)
    bg.BackgroundTransparency = 0.4
    bg.BorderSizePixel   = 0
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)

    -- Centre dot (you)
    local self = Instance.new("Frame", bg)
    self.Size            = UDim2.new(0, 6, 0, 6)
    self.Position        = UDim2.new(0.5, -3, 0.5, -3)
    self.BackgroundColor3= Color3.fromRGB(80, 255, 100)
    self.BorderSizePixel = 0
    Instance.new("UICorner", self).CornerRadius = UDim.new(1,0)
end

local function updateRadar()
    if not CFG.RadarEnabled then
        if _radarGui then _radarGui:Destroy(); _radarGui = nil end
        return
    end
    if not _radarGui then buildRadar() end
    local bg  = _radarGui:FindFirstChild("RadarBG")
    if not bg then return end
    local hrp = getHRP()
    if not hrp then return end

    -- Clear old dots
    for _, d in ipairs(bg:GetChildren()) do
        if d.Name == "RadarDot" then d:Destroy() end
    end

    local scale = 1.5 -- studs per pixel
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local oHRP = p.Character:FindFirstChild("HumanoidRootPart")
            if oHRP then
                local rel = oHRP.Position - hrp.Position
                local px  = 65 + (rel.X / scale)
                local py  = 65 - (rel.Z / scale)
                local dot = Instance.new("Frame", bg)
                dot.Name             = "RadarDot"
                dot.Size             = UDim2.new(0, 5, 0, 5)
                dot.Position         = UDim2.new(0, px - 2, 0, py - 2)
                dot.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
                dot.BorderSizePixel  = 0
                Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)
            end
        end
    end
end

-- ============================================================
--  SAVE / LOAD CONFIG  (Profile stores per-session in a table;
--  for cross-session saving wire to a DataStore server script)
-- ============================================================
local function saveConfig()
    -- Saves to a BindableFunction if your server script listens,
    -- otherwise prints the table for now
    local data = {}
    for k, v in pairs(CFG) do data[k] = v end
    local bf = game.ReplicatedStorage:FindFirstChild("SaveConfig")
    if bf and bf:IsA("BindableFunction") then
        bf:Invoke(data)
    end
    -- Visual feedback
    return data
end

local function loadConfig(data)
    if not data then return end
    for k, v in pairs(data) do
        if CFG[k] ~= nil then CFG[k] = v end
    end
end

-- ============================================================
--  GUI  — Cheat Menu
-- ============================================================
local function makeCorner(parent, radius)
    local c = Instance.new("UICorner", parent)
    c.CornerRadius = UDim.new(0, radius or 8)
    return c
end

local function makeLabel(parent, text, size, color, font)
    local l = Instance.new("TextLabel", parent)
    l.Size                     = size or UDim2.new(1,0,0,20)
    l.BackgroundTransparency   = 1
    l.Text                     = text
    l.TextColor3               = color or Color3.fromRGB(220,220,220)
    l.Font                     = font or Enum.Font.GothamBold
    l.TextSize                 = 13
    l.TextXAlignment           = Enum.TextXAlignment.Left
    return l
end

local GUI = Instance.new("ScreenGui")
GUI.Name         = "CheatSimGUI"
GUI.ResetOnSpawn = false
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI.Parent       = PlayerGui

-- Main window
local Win = Instance.new("Frame", GUI)
Win.Name             = "MainWindow"
Win.Size             = UDim2.new(0, 380, 0, 490)
Win.Position         = UDim2.new(0.5, -190, 0.5, -245)
Win.BackgroundColor3 = Color3.fromRGB(14, 16, 22)
Win.BorderSizePixel  = 0
Win.Active           = true
Win.Draggable        = true
makeCorner(Win, 12)

-- Drop shadow
local Shadow = Instance.new("ImageLabel", Win)
Shadow.Name               = "Shadow"
Shadow.AnchorPoint        = Vector2.new(0.5, 0.5)
Shadow.BackgroundTransparency = 1
Shadow.Position           = UDim2.new(0.5, 0, 0.5, 6)
Shadow.Size               = UDim2.new(1, 30, 1, 30)
Shadow.ZIndex             = 0
Shadow.Image              = "rbxassetid://5554236805"
Shadow.ImageColor3        = Color3.fromRGB(0,0,0)
Shadow.ImageTransparency  = 0.5
Shadow.ScaleType          = Enum.ScaleType.Slice
Shadow.SliceCenter        = Rect.new(23,23,277,277)

-- Title bar
local TitleBar = Instance.new("Frame", Win)
TitleBar.Size             = UDim2.new(1, 0, 0, 44)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
TitleBar.BorderSizePixel  = 0
makeCorner(TitleBar, 12)
-- Fix bottom corners of title bar
local TitleFix = Instance.new("Frame", TitleBar)
TitleFix.Size             = UDim2.new(1, 0, 0.5, 0)
TitleFix.Position         = UDim2.new(0, 0, 0.5, 0)
TitleFix.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
TitleFix.BorderSizePixel  = 0

-- Logo / title text
local TitleIcon = Instance.new("TextLabel", TitleBar)
TitleIcon.Size             = UDim2.new(0, 34, 0, 34)
TitleIcon.Position         = UDim2.new(0, 8, 0.5, -17)
TitleIcon.BackgroundColor3 = Color3.fromRGB(80, 120, 255)
TitleIcon.Text             = "CS"
TitleIcon.TextColor3       = Color3.fromRGB(255,255,255)
TitleIcon.Font             = Enum.Font.GothamBold
TitleIcon.TextSize         = 14
TitleIcon.BorderSizePixel  = 0
makeCorner(TitleIcon, 6)

local TitleText = Instance.new("TextLabel", TitleBar)
TitleText.Size             = UDim2.new(0, 200, 1, 0)
TitleText.Position         = UDim2.new(0, 50, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text             = "Cheat Simulator"
TitleText.TextColor3       = Color3.fromRGB(255,255,255)
TitleText.Font             = Enum.Font.GothamBold
TitleText.TextSize         = 15
TitleText.TextXAlignment   = Enum.TextXAlignment.Left

local SubText = Instance.new("TextLabel", TitleBar)
SubText.Size               = UDim2.new(0, 200, 0, 14)
SubText.Position           = UDim2.new(0, 50, 0, 26)
SubText.BackgroundTransparency = 1
SubText.Text               = "v1.0  |  Free Edition"
SubText.TextColor3         = Color3.fromRGB(100,120,160)
SubText.Font               = Enum.Font.Gotham
SubText.TextSize           = 11
SubText.TextXAlignment     = Enum.TextXAlignment.Left

-- Close button
local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size              = UDim2.new(0, 28, 0, 28)
CloseBtn.Position          = UDim2.new(1, -36, 0.5, -14)
CloseBtn.BackgroundColor3  = Color3.fromRGB(200, 60, 60)
CloseBtn.Text              = "✕"
CloseBtn.TextColor3        = Color3.fromRGB(255,255,255)
CloseBtn.Font              = Enum.Font.GothamBold
CloseBtn.TextSize          = 13
CloseBtn.BorderSizePixel   = 0
makeCorner(CloseBtn, 6)
CloseBtn.MouseButton1Click:Connect(function()
    Win.Visible = not Win.Visible
end)

-- Minimise button
local MinBtn = Instance.new("TextButton", TitleBar)
MinBtn.Size              = UDim2.new(0, 28, 0, 28)
MinBtn.Position          = UDim2.new(1, -70, 0.5, -14)
MinBtn.BackgroundColor3  = Color3.fromRGB(60, 80, 140)
MinBtn.Text              = "—"
MinBtn.TextColor3        = Color3.fromRGB(255,255,255)
MinBtn.Font              = Enum.Font.GothamBold
MinBtn.TextSize          = 13
MinBtn.BorderSizePixel   = 0
makeCorner(MinBtn, 6)

local _minimised = false
local _bodyRef   = nil  -- set later
MinBtn.MouseButton1Click:Connect(function()
    _minimised = not _minimised
    if _bodyRef then _bodyRef.Visible = not _minimised end
    Win.Size = _minimised
        and UDim2.new(0, 380, 0, 44)
        or  UDim2.new(0, 380, 0, 490)
end)

-- Tab bar
local TabBar = Instance.new("Frame", Win)
TabBar.Size             = UDim2.new(1, -16, 0, 34)
TabBar.Position         = UDim2.new(0, 8, 0, 50)
TabBar.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
TabBar.BorderSizePixel  = 0
makeCorner(TabBar, 8)
local TabLayout = Instance.new("UIListLayout", TabBar)
TabLayout.FillDirection  = Enum.FillDirection.Horizontal
TabLayout.Padding        = UDim.new(0, 4)
TabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
Instance.new("UIPadding", TabBar).PaddingLeft = UDim.new(0, 6)

-- Scroll container for toggle rows
local Body = Instance.new("ScrollingFrame", Win)
Body.Name                  = "Body"
Body.Size                  = UDim2.new(1, -16, 1, -100)
Body.Position              = UDim2.new(0, 8, 0, 92)
Body.BackgroundTransparency= 1
Body.BorderSizePixel       = 0
Body.ScrollBarThickness    = 3
Body.ScrollBarImageColor3  = Color3.fromRGB(80, 100, 180)
Body.CanvasSize            = UDim2.new(0, 0, 0, 0)
Body.AutomaticCanvasSize   = Enum.AutomaticSize.Y
_bodyRef = Body

local BodyLayout = Instance.new("UIListLayout", Body)
BodyLayout.Padding        = UDim.new(0, 6)
BodyLayout.SortOrder      = Enum.SortOrder.LayoutOrder

-- Status bar at bottom
local StatusBar = Instance.new("Frame", Win)
StatusBar.Size            = UDim2.new(1, -16, 0, 26)
StatusBar.Position        = UDim2.new(0, 8, 1, -34)
StatusBar.BackgroundColor3= Color3.fromRGB(20, 24, 34)
StatusBar.BorderSizePixel = 0
makeCorner(StatusBar, 6)

local StatusLabel = Instance.new("TextLabel", StatusBar)
StatusLabel.Size           = UDim2.new(1, -8, 1, 0)
StatusLabel.Position       = UDim2.new(0, 8, 0, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text           = "● All systems nominal"
StatusLabel.TextColor3     = Color3.fromRGB(80, 200, 120)
StatusLabel.Font           = Enum.Font.Gotham
StatusLabel.TextSize       = 11
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

local function setStatus(msg, color)
    StatusLabel.Text       = "● " .. msg
    StatusLabel.TextColor3 = color or Color3.fromRGB(80, 200, 120)
end

-- ============================================================
--  TAB SYSTEM
-- ============================================================
local tabs      = {}
local tabFrames = {}
local activeTab = nil

local TAB_NAMES = {"Combat", "Movement", "Utility", "Visual"}
local TAB_ICONS = {"⚔️", "🏃", "🧱", "👁️"}

local function switchTab(name)
    for n, frame in pairs(tabFrames) do
        frame.Visible = (n == name)
    end
    for n, btn in pairs(tabs) do
        btn.BackgroundColor3 = (n == name)
            and Color3.fromRGB(80, 120, 255)
            or  Color3.fromRGB(30, 36, 54)
    end
    activeTab = name
end

for i, name in ipairs(TAB_NAMES) do
    local btn = Instance.new("TextButton", TabBar)
    btn.Size             = UDim2.new(0.23, -2, 0, 26)
    btn.BackgroundColor3 = Color3.fromRGB(30, 36, 54)
    btn.Text             = TAB_ICONS[i] .. " " .. name
    btn.TextColor3       = Color3.fromRGB(200, 210, 230)
    btn.Font             = Enum.Font.GothamBold
    btn.TextSize         = 11
    btn.BorderSizePixel  = 0
    makeCorner(btn, 6)
    tabs[name] = btn

    local frame = Instance.new("Frame", Body)
    frame.Name               = name
    frame.Size               = UDim2.new(1, 0, 0, 0)
    frame.BackgroundTransparency = 1
    frame.Visible            = false
    frame.AutomaticSize      = Enum.AutomaticSize.Y
    local fl = Instance.new("UIListLayout", frame)
    fl.Padding               = UDim.new(0, 5)
    fl.SortOrder             = Enum.SortOrder.LayoutOrder
    tabFrames[name] = frame

    btn.MouseButton1Click:Connect(function() switchTab(name) end)
end

-- ============================================================
--  TOGGLE ROW  builder
-- ============================================================
local function makeToggle(parent, label, desc, cfgKey, callback, order)
    local row = Instance.new("Frame", parent)
    row.Size             = UDim2.new(1, 0, 0, 54)
    row.BackgroundColor3 = Color3.fromRGB(22, 26, 38)
    row.BorderSizePixel  = 0
    row.LayoutOrder      = order or 0
    makeCorner(row, 8)

    local lbl = Instance.new("TextLabel", row)
    lbl.Size               = UDim2.new(1, -60, 0, 22)
    lbl.Position           = UDim2.new(0, 12, 0, 8)
    lbl.BackgroundTransparency = 1
    lbl.Text               = label
    lbl.TextColor3         = Color3.fromRGB(230, 235, 245)
    lbl.Font               = Enum.Font.GothamBold
    lbl.TextSize           = 13
    lbl.TextXAlignment     = Enum.TextXAlignment.Left

    local sub = Instance.new("TextLabel", row)
    sub.Size               = UDim2.new(1, -60, 0, 16)
    sub.Position           = UDim2.new(0, 12, 0, 30)
    sub.BackgroundTransparency = 1
    sub.Text               = desc
    sub.TextColor3         = Color3.fromRGB(100, 115, 145)
    sub.Font               = Enum.Font.Gotham
    sub.TextSize           = 11
    sub.TextXAlignment     = Enum.TextXAlignment.Left

    -- Toggle pill
    local pillBG = Instance.new("Frame", row)
    pillBG.Size            = UDim2.new(0, 42, 0, 22)
    pillBG.Position        = UDim2.new(1, -54, 0.5, -11)
    pillBG.BackgroundColor3= Color3.fromRGB(40, 46, 66)
    pillBG.BorderSizePixel = 0
    makeCorner(pillBG, 11)

    local pillKnob = Instance.new("Frame", pillBG)
    pillKnob.Size          = UDim2.new(0, 18, 0, 18)
    pillKnob.Position      = UDim2.new(0, 2, 0.5, -9)
    pillKnob.BackgroundColor3 = Color3.fromRGB(160, 170, 200)
    pillKnob.BorderSizePixel  = 0
    makeCorner(pillKnob, 9)

    local on = CFG[cfgKey] == true

    local function refresh()
        local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad)
        if on then
            TweenService:Create(pillBG,   tweenInfo, {BackgroundColor3 = Color3.fromRGB(80,120,255)}):Play()
            TweenService:Create(pillKnob, tweenInfo, {Position = UDim2.new(0, 22, 0.5, -9), BackgroundColor3 = Color3.fromRGB(255,255,255)}):Play()
        else
            TweenService:Create(pillBG,   tweenInfo, {BackgroundColor3 = Color3.fromRGB(40,46,66)}):Play()
            TweenService:Create(pillKnob, tweenInfo, {Position = UDim2.new(0, 2, 0.5, -9), BackgroundColor3 = Color3.fromRGB(160,170,200)}):Play()
        end
    end
    refresh()

    local btn = Instance.new("TextButton", row)
    btn.Size               = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text               = ""
    btn.ZIndex             = 5
    btn.MouseButton1Click:Connect(function()
        on = not on
        CFG[cfgKey] = on
        refresh()
        setStatus(label .. (on and " enabled" or " disabled"),
            on and Color3.fromRGB(80,200,120) or Color3.fromRGB(200,100,80))
        if callback then callback(on) end
    end)

    return row
end

-- ============================================================
--  SECTION HEADER
-- ============================================================
local function makeSection(parent, text, order)
    local f = Instance.new("Frame", parent)
    f.Size               = UDim2.new(1, 0, 0, 24)
    f.BackgroundTransparency = 1
    f.LayoutOrder        = order or 0
    local l = Instance.new("TextLabel", f)
    l.Size               = UDim2.new(1, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.Text               = text
    l.TextColor3         = Color3.fromRGB(80, 100, 160)
    l.Font               = Enum.Font.GothamBold
    l.TextSize           = 11
    l.TextXAlignment     = Enum.TextXAlignment.Left
    return f
end

-- ============================================================
--  SAVE CONFIG BUTTON
-- ============================================================
local function makeSaveButton(parent, order)
    local btn = Instance.new("TextButton", parent)
    btn.Size             = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(50, 80, 200)
    btn.Text             = "💾  Save Config"
    btn.TextColor3       = Color3.fromRGB(255,255,255)
    btn.Font             = Enum.Font.GothamBold
    btn.TextSize         = 13
    btn.BorderSizePixel  = 0
    btn.LayoutOrder      = order or 99
    makeCorner(btn, 8)
    btn.MouseButton1Click:Connect(function()
        saveConfig()
        setStatus("Config saved!", Color3.fromRGB(80,200,120))
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(40,160,80)}):Play()
        task.delay(0.5, function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50,80,200)}):Play()
        end)
    end)
end

-- ============================================================
--  POPULATE TABS
-- ============================================================

-- ── COMBAT ──────────────────────────────────────────────────
local CT = tabFrames["Combat"]
makeSection(CT, "  ─── FREE CHEATS ─────────────────", 0)
makeToggle(CT, "⚡ Aimbot", "Locks onto nearest player with any weapon", "AimbotEnabled", nil, 1)
makeToggle(CT, "💀 Kill Aura", "Damages all players within 40 studs", "KillAuraEnabled", nil, 2)
makeToggle(CT, "🎯 Head Snap", "Aimbot targets head instead of body", "AimbotHeadlock", nil, 3)
makeSection(CT, "  ─── PREMIUM (free while testing) ──", 4)
makeToggle(CT, "⚔️ Auto Swing", "Auto-activates your equipped weapon", "AimbotEnabled", nil, 5)
makeToggle(CT, "🛡️ Anti-Knockback", "Reduces knockback force on hit", "GhostEnabled", nil, 6)
makeToggle(CT, "🔥 Crit Boost", "Increases damage by 25% per hit", "KillAuraEnabled", nil, 7)
makeToggle(CT, "🎭 Silent Aim", "Hits register even with bad aim", "AimbotEnabled", nil, 8)
makeToggle(CT, "🏹 Projectile Predict", "Shows trajectory arc on thrown tools", "TrajectoryEnabled", nil, 9)
makeSaveButton(CT, 100)

-- ── MOVEMENT ────────────────────────────────────────────────
local MV = tabFrames["Movement"]
makeSection(MV, "  ─── FREE CHEATS ─────────────────", 0)
makeToggle(MV, "🧱 Anti-Void Scaffold", "Places blocks under you near the void", "ScaffoldEnabled", nil, 1)
makeToggle(MV, "⚡ Speed Hack", "2.5x walk speed boost", "SpeedEnabled", updateSpeed, 2)
makeToggle(MV, "🚀 High Jump", "Massively increased jump height", "HighJumpEnabled", nil, 3)
makeSection(MV, "  ─── PREMIUM (free while testing) ──", 4)
makeToggle(MV, "✈️ Fly", "WASD to fly, Space=up, Shift=down", "FlyEnabled", function(on) if not on then disableFly() end end, 5)
makeToggle(MV, "🔄 Infinite Jump", "Jump again mid-air infinitely", "InfJumpEnabled", nil, 6)
makeToggle(MV, "👻 Ghost Mode", "Phase through other players", "GhostEnabled", updateGhost, 7)
makeToggle(MV, "🎯 No Clip (experimental)", "Noclip through walls", "GhostEnabled", nil, 8)
makeToggle(MV, "💨 Dash Boost", "Double-tap direction to dash", "SpeedEnabled", nil, 9)
makeSaveButton(MV, 100)

-- ── UTILITY ─────────────────────────────────────────────────
local UT = tabFrames["Utility"]
makeSection(UT, "  ─── FREE CHEATS ─────────────────", 0)
makeToggle(UT, "🧲 Auto Collect", "Pulls nearby pickups/coins to you", "AutoCollectEnabled", nil, 1)
makeToggle(UT, "📡 Radar", "Minimap dot shows all player positions", "RadarEnabled", nil, 2)
makeToggle(UT, "🌐 ESP Labels", "Names + health visible through walls", "ESPEnabled", nil, 3)
makeSection(UT, "  ─── PREMIUM (free while testing) ──", 4)
makeToggle(UT, "🤖 Auto Farm", "Automatically collects and farms XP", "AutoCollectEnabled", nil, 5)
makeToggle(UT, "💰 Coin Magnet", "Extended range auto-collect (60 studs)", "AutoCollectEnabled", nil, 6)
makeToggle(UT, "📦 Chest Finder", "Highlights chests and loot spawns", "ESPEnabled", nil, 7)
makeToggle(UT, "⏱️ Respawn Rush", "Teleports you back to spawn instantly", "SpeedEnabled", nil, 8)
makeToggle(UT, "🔔 Kill Notifier", "Chat notification when you get a kill", "KillAuraEnabled", nil, 9)
makeSaveButton(UT, 100)

-- ── VISUAL ──────────────────────────────────────────────────
local VS = tabFrames["Visual"]
makeSection(VS, "  ─── FREE CHEATS ─────────────────", 0)
makeToggle(VS, "👁️ Player ESP", "Show enemies through any wall", "ESPEnabled", nil, 1)
makeToggle(VS, "🗺️ Radar Map", "Live radar in bottom-right corner", "RadarEnabled", nil, 2)
makeToggle(VS, "💡 Full Bright", "Maximum ambient lighting always", "ESPEnabled", nil, 3)
makeSection(VS, "  ─── PREMIUM (free while testing) ──", 4)
makeToggle(VS, "🎨 Custom Chams", "Colourful player highlight overlays", "ESPEnabled", nil, 5)
makeToggle(VS, "📐 Hit Boxes", "Shows enemy hitbox outlines", "ESPEnabled", nil, 6)
makeToggle(VS, "🌈 Rainbow UI", "Animates the panel colour", "ESPEnabled", nil, 7)
makeToggle(VS, "⚠️ Danger Alert", "Flashes when enemy is behind you", "ESPEnabled", nil, 8)
makeToggle(VS, "🔍 Zoom Hack", "FOV zoom on right-click", "AimbotEnabled", nil, 9)
makeSaveButton(VS, 100)

-- Start on Combat tab
switchTab("Combat")

-- ============================================================
--  KEYBIND  (Right Alt toggles panel open/closed)
-- ============================================================
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightAlt then
        Win.Visible = not Win.Visible
    end
end)

-- ============================================================
--  MAIN LOOP
-- ============================================================
setupHighJump()
setupInfJump()

RunService.Heartbeat:Connect(function(dt)
    updateAimbot()
    updateKillAura(dt)
    updateScaffold(dt)
    updateFly()
    updateAutoCollect()
    updateESP()
    updateRadar()
end)

-- Character respawn: re-apply speed/ghost when character loads
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    updateSpeed()
    updateGhost()
    if CFG.FlyEnabled then
        CFG.FlyEnabled = false
        setStatus("Fly disabled on respawn", Color3.fromRGB(200,150,60))
    end
end)

setStatus("Ready — ✌️ RightAlt to toggle panel")
print("[CheatSimulator] Loaded successfully!")
