-- ============================================================
--  CHEAT SIMULATOR · ALL-IN-ONE v3 (server + client + mobile)
--  INSTALL: place this ONE Script in ServerScriptService. Done.
--
--  TEMPLATE INTEGRATION (scaffold using real inventory blocks):
--  Block items must be Tools in the Backpack, e.g. "Red Wool".
--  If your Bedwars template places blocks through a RemoteEvent,
--  add its name to PLACE_REMOTE_NAMES below and scaffold will
--  fire it. Tool:Activate() is also tried as a fallback.
-- ============================================================

local RunService = game:GetService("RunService")

if RunService:IsClient() then
-- ############################################################
--  CLIENT HALF
-- ############################################################

    -- ── C1 · SERVICES & DEVICE ──────────────────────────────
    local Players              = game:GetService("Players")
    local UserInputService     = game:GetService("UserInputService")
    local TweenService         = game:GetService("TweenService")
    local Lighting             = game:GetService("Lighting")
    local SoundService         = game:GetService("SoundService")
    local ContextActionService = game:GetService("ContextActionService")
    local Workspace            = game:GetService("Workspace")
    local ReplicatedStorage    = game:GetService("ReplicatedStorage")

    local LocalPlayer = Players.LocalPlayer
    local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")
    local cam         = Workspace.CurrentCamera
    local isMobile    = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

    local Remotes = ReplicatedStorage:WaitForChild("CheatSimRemotes", 15)
    local function R(name) return Remotes and Remotes:FindFirstChild(name) end

    -- ── C2 · CONFIG + TEMPLATE INTEGRATION ──────────────────
    local BLOCK_KEYWORDS     = {"wool","wood","plank","stone","brick","oak","concrete","marble"}
    local PLACE_REMOTE_NAMES = {"PlaceBlock","PlaceEvent","Place","Build","BlockPlace","BridgePlace"}
    local TRY_TEMPLATE_REMOTE = true -- set false if you hardcode the remote below

    local CFG = {
        Aimbot=false, AimbotRange=120, AimbotSmooth=0.18, AimbotHead=true,
        AimbotFOV=90, AimbotVisible=true,
        KillAura=false, KillAuraRange=40, KillAuraDmg=12, KillAuraRate=0.45,
        KillChase=false,
        AutoSwing=false, TriggerBot=false, SilentAim=false,
        CritBoost=false, RangeExtend=false, AntiKB=false,
        Scaffold=false, ScaffoldY=5, ScaffoldLife=7, ScaffoldInv=true,
        Speed=false, SpeedMult=2.2, SpeedX3=false,
        HighJump=false, JumpPower=110, InfJump=false,
        Fly=false, FlySpeed=55, Noclip=false, Ghost=false, ClickTP=false,
        AutoBridge=false,
        BedESP=false, GenESP=false, Radar=false,
        CoinMagnet=false, AutoFarm=false, FastRespawn=false,
        LootAlert=false, KillNotify=false,
        PlayerESP=false, FullBright=false, Chams=false, Hitboxes=false,
        DangerAlert=false, ZoomHack=false, RainbowUI=false,
    }
    local BRIDGE_MAT = Enum.Material.SmoothPlastic
    local TEAM_COLOR_MAP = {
        red=Color3.fromRGB(255,70,70), blue=Color3.fromRGB(70,130,255),
        green=Color3.fromRGB(70,220,90), yellow=Color3.fromRGB(255,220,60),
        purple=Color3.fromRGB(180,90,255), white=Color3.fromRGB(240,240,240),
        pink=Color3.fromRGB(255,120,190), cyan=Color3.fromRGB(80,230,230),
        orange=Color3.fromRGB(255,150,50), black=Color3.fromRGB(70,70,80),
    }

    -- ── C3 · HELPERS ────────────────────────────────────────
    local function getChar() return LocalPlayer.Character end
    local function getHRP()  local c = getChar() return c and c:FindFirstChild("HumanoidRootPart") end
    local function getHum()  local c = getChar() return c and c:FindFirstChildOfClass("Humanoid") end
    local function safe(fn)
        local ok, err = pcall(fn)
        if not ok then warn("[CheatSim] " .. tostring(err)) end
    end

    local cfgCallbacks = {}
    local updateStatusPill = function() end
    local Win, _winStroke, TargetLbl
    local function setConfig(key, value)
        CFG[key] = value
        updateStatusPill()
        for _, fn in ipairs(cfgCallbacks[key] or {}) do safe(function() fn(value) end) end
    end

    -- movement control hook (so auto-walk never fights the player)
    local controls
    pcall(function()
        controls = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")):GetControls()
    end)
    local function playerMoving()
        if controls then
            local ok, mv = pcall(controls.GetMoveVector, controls)
            if ok and typeof(mv) == "Vector3" and mv.Magnitude > 0.1 then return true end
        end
        if not isMobile then
            for _, k in ipairs({Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D}) do
                if UserInputService:IsKeyDown(k) then return true end
            end
        end
        return false
    end

    -- ── C4 · TOASTS + SOUND ─────────────────────────────────
    local pingSound = Instance.new("Sound")
    pingSound.SoundId = "rbxasset://sounds/electronicpingshort.wav"
    pingSound.Volume = 0.4
    pingSound.Parent = SoundService

    local toastHolder = Instance.new("Frame")
    toastHolder.Size = UDim2.new(0, 250, 1, 0)
    toastHolder.Position = UDim2.new(1, -260, 0, 10)
    toastHolder.BackgroundTransparency = 1
    toastHolder.Parent = PlayerGui
    Instance.new("UIListLayout", toastHolder).Padding = UDim.new(0, 6)

    local function toast(msg, color)
        safe(function()
            local t = Instance.new("Frame")
            t.Size = UDim2.new(1, 0, 0, 30)
            t.BackgroundColor3 = color or Color3.fromRGB(45,70,190)
            t.BackgroundTransparency = 0.15
            t.BorderSizePixel = 0
            t.Parent = toastHolder
            Instance.new("UICorner", t).CornerRadius = UDim.new(0, 8)
            local l = Instance.new("TextLabel", t)
            l.Size = UDim2.new(1, -12, 1, 0)
            l.Position = UDim2.new(0, 8, 0, 0)
            l.BackgroundTransparency = 1
            l.Text = msg
            l.TextColor3 = Color3.new(1,1,1)
            l.Font = Enum.Font.GothamBold
            l.TextSize = 12
            l.TextXAlignment = Enum.TextXAlignment.Left
            t.Position = UDim2.new(1, 40, 0, 0)
            TweenService:Create(t, TweenInfo.new(0.2, Enum.EasingStyle.Back), {Position = UDim2.new(0,0,0,0)}):Play()
            task.delay(2.5, function()
                TweenService:Create(t, TweenInfo.new(0.3), {BackgroundTransparency = 1, Position = UDim2.new(1, 40, 0, 0)}):Play()
                task.wait(0.3)
                t:Destroy()
            end)
        end)
    end

    -- ── C5 · SMART BLOCK PLACEMENT (uses YOUR inventory) ────
    local blockFolder = Instance.new("Folder")
    blockFolder.Name = "CS_Blocks"
    blockFolder.Parent = Workspace

    local function findPlaceableBlock()
        local containers = {}
        if getChar() then table.insert(containers, getChar()) end
        local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
        if bp then table.insert(containers, bp) end
        local fallback
        for _, cont in ipairs(containers) do
            for _, t in ipairs(cont:GetChildren()) do
                if t:IsA("Tool") then
                    local n = t.Name:lower()
                    for _, kw in ipairs(BLOCK_KEYWORDS) do
                        if n:find(kw) then
                            if n:find("wool") then return t end -- wool = bedwars priority
                            fallback = fallback or t
                        end
                    end
                end
            end
        end
        return fallback
    end

    local function toolBlockColor(tool)
        if not tool then return nil end
        for _, d in ipairs(tool:GetDescendants()) do
            if d:IsA("BasePart") then return d.Color end
        end
        return nil
    end

    local function myTeamColor()
        local t = LocalPlayer.Team
        return (t and t.TeamColor.Color) or Color3.fromRGB(70,130,255)
    end

    local _lastRealPlace = 0
    local function tryRealPlace(tool, position)
        if os.clock() - _lastRealPlace < 0.3 then return end
        _lastRealPlace = os.clock()
        task.spawn(function()
            safe(function()
                local char, hum = getChar(), getHum()
                if not (char and hum and tool and tool.Parent) then return end
                if tool.Parent ~= char then hum:EquipTool(tool) end
                task.wait(0.08)
                if TRY_TEMPLATE_REMOTE then
                    for _, name in ipairs(PLACE_REMOTE_NAMES) do
                        local r = ReplicatedStorage:FindFirstChild(name, true)
                        if r and r:IsA("RemoteEvent") then
                            pcall(function() r:FireServer(position, tool.Name) end)
                            pcall(function() r:FireServer(tool.Name, position) end)
                            break
                        end
                    end
                end
                pcall(function() tool:Activate() end)
            end)
        end)
    end

    -- places a block using your inventory tool (color-matched) + safety net
    local function placeSmartBlock(size, cframe, life, name)
        local tool = CFG.ScaffoldInv and findPlaceableBlock() or nil
        local color = toolBlockColor(tool) or myTeamColor()
        if tool then tryRealPlace(tool, cframe.Position) end
        local b = Instance.new("Part")
        b.Size = size
        b.CFrame = cframe
        b.Anchored = true
        b.Material = BRIDGE_MAT
        b.Color = color
        b.Name = name
        b.Parent = blockFolder
        task.delay(life - 1, function()
            if b.Parent then TweenService:Create(b, TweenInfo.new(1), {Transparency = 1}):Play() end
        end)
        task.delay(life, function() if b.Parent then b:Destroy() end end)
    end

    -- ── C6 · TARGETING (sticky + LOS) ───────────────────────
    local function canSee(part)
        local hrp = getHRP()
        if not (hrp and part and part.Parent) then return false end
        local rp = RaycastParams.new()
        rp.FilterDescendantsInstances = {getChar(), part.Parent}
        rp.FilterType = Enum.RaycastFilterType.Exclude
        return Workspace:Raycast(hrp.Position, part.Position - hrp.Position, rp) == nil
    end

    local curTarget = nil
    local function targetValid(part, range)
        if not (part and part.Parent) then return false end
        local hum = part.Parent:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return false end
        local hrp = getHRP()
        if not hrp then return false end
        if (hrp.Position - part.Position).Magnitude > range then return false end
        if CFG.AimbotVisible and not canSee(part) then return false end
        return true
    end

    local function getTarget(range)
        if targetValid(curTarget, range) then return curTarget end -- stickiness
        curTarget = nil
        local hrp = getHRP()
        if not hrp then return nil end
        local best, bd = nil, range
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local part = (CFG.AimbotHead and p.Character:FindFirstChild("Head"))
                    or p.Character:FindFirstChild("HumanoidRootPart")
                    or p.Character:FindFirstChild("Head")
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if part and hum and hum.Health > 0 then
                    local d = (hrp.Position - part.Position).Magnitude
                    if d < bd and ((not CFG.AimbotVisible) or canSee(part)) then
                        best = part; bd = d
                    end
                end
            end
        end
        curTarget = best
        return best
    end

    local lastDamage = {}
    local function dealDamage(targetChar, amount)
        safe(function()
            local remote = R("DamageRemote")
            if remote then
                remote:FireServer(targetChar, amount)
            else
                local hum = targetChar:FindFirstChildOfClass("Humanoid")
                if hum then hum:TakeDamage(amount) end
            end
            lastDamage[targetChar] = os.clock()
        end)
    end

    local function crosshairEnemy(range)
        local ray = cam:ViewportPointToRay(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
        local rp = RaycastParams.new()
        rp.FilterDescendantsInstances = {getChar()}
        rp.FilterType = Enum.RaycastFilterType.Exclude
        local hit = Workspace:Raycast(ray.Origin, ray.Direction * range, rp)
        if hit then
            local model = hit.Instance:FindFirstAncestorOfClass("Model")
            if model then
                local hum = model:FindFirstChildOfClass("Humanoid")
                local plr = Players:GetPlayerFromCharacter(model)
                if hum and hum.Health > 0 and plr and plr ~= LocalPlayer then
                    return model, hum
                end
            end
        end
        return nil
    end

    -- ── C7 · CHEAT TICKS ────────────────────────────────────
    local tickAimbot, tickKillAura, tickAutoSwing, tickTriggerBot
    local tickScaffold, tickAutoBridge, tickFly, tickAntiKB, tickNoclip
    local tickAutoFarm, tickMagnet, tickTargetLabel

    function tickAimbot()
        if not CFG.Aimbot then return end
        local part = getTarget(CFG.AimbotRange)
        if not part then return end
        local dir = (part.Position - cam.CFrame.Position).Unit
        local dot = math.clamp(cam.CFrame.LookVector:Dot(dir), -1, 1)
        if math.deg(math.acos(dot)) > CFG.AimbotFOV then return end -- outside FOV = no lock
        cam.CFrame = cam.CFrame:Lerp(CFrame.lookAt(cam.CFrame.Position, part.Position), CFG.AimbotSmooth)
    end

    local _killTimer, _swingTimer, _trigTimer = 0, 0, 0
    local _chaseTimer, _wasChasing = 0, false
    local function stopChase()
        if _wasChasing then
            _wasChasing = false
            local hum, hrp = getHum(), getHRP()
            if hum and hrp then hum:MoveTo(hrp.Position) end
        end
    end

    function tickKillAura(dt)
        if not CFG.KillAura then stopChase() return end
        local hrp = getHRP()
        if not hrp then stopChase() return end
        local range = CFG.KillAuraRange * (CFG.RangeExtend and 1.6 or 1)
        local target = getTarget(range * 2.5) -- chase radius is wider
        if not target then stopChase() return end
        local dist = (hrp.Position - target.Position).Magnitude
        local dmg = CFG.KillAuraDmg * (CFG.CritBoost and 1.25 or 1)
        if dist <= range then
            stopChase()
            _killTimer += dt
            if _killTimer >= CFG.KillAuraRate then
                _killTimer = 0
                hrp.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(target.Position.X, hrp.Position.Y, target.Position.Z))
                dealDamage(target.Parent, dmg)
            end
        elseif CFG.KillChase and not CFG.Fly and not playerMoving() then
            _chaseTimer -= dt
            if _chaseTimer <= 0 then
                _chaseTimer = 0.2
                _wasChasing = true
                local hum = getHum()
                if hum then hum:MoveTo(Vector3.new(target.Position.X, hrp.Position.Y, target.Position.Z)) end
            end
        else
            stopChase()
        end
    end

    function tickAutoSwing(dt)
        if not CFG.AutoSwing then return end
        _swingTimer += dt
        if _swingTimer < CFG.KillAuraRate * 0.6 then return end
        _swingTimer = 0
        local target = getTarget(25)
        if target then
            dealDamage(target.Parent, CFG.KillAuraDmg * (CFG.CritBoost and 1.25 or 1))
        end
    end

    function tickTriggerBot(dt)
        if not CFG.TriggerBot then return end
        _trigTimer += dt
        if _trigTimer < 0.5 then return end
        _trigTimer = 0
        local model = crosshairEnemy(CFG.AimbotRange)
        if model then dealDamage(model, 6) end
    end

    local _scaffTimer = 0
    function tickScaffold(dt)
        if not CFG.Scaffold then return end
        _scaffTimer = math.max(0, _scaffTimer - dt)
        if _scaffTimer > 0 then return end
        local hrp = getHRP()
        if not hrp then return end
        local pos, vel = hrp.Position, hrp.AssemblyLinearVelocity
        if pos.Y > CFG.ScaffoldY or vel.Y >= -4 then return end
        local rp = RaycastParams.new()
        rp.FilterDescendantsInstances = {getChar()}
        rp.FilterType = Enum.RaycastFilterType.Exclude
        if Workspace:Raycast(pos, Vector3.new(0,-5,0), rp) then return end
        _scaffTimer = 0.3
        placeSmartBlock(Vector3.new(9,1,9), CFrame.new(pos.X, pos.Y - 3.5, pos.Z), CFG.ScaffoldLife, "ScaffoldBlock")
    end

    local _bridgeTimer = 0
    function tickAutoBridge(dt)
        if not CFG.AutoBridge then return end
        _bridgeTimer += dt
        if _bridgeTimer < 0.25 then return end
        _bridgeTimer = 0
        local hrp = getHRP()
        if not hrp then return end
        if not isMobile and not UserInputService:IsKeyDown(Enum.KeyCode.W) then return end
        local front = hrp.CFrame * CFrame.new(0, -2.5, -5)
        local rp = RaycastParams.new()
        rp.FilterDescendantsInstances = {getChar()}
        rp.FilterType = Enum.RaycastFilterType.Exclude
        if Workspace:Raycast(front.Position, Vector3.new(0,-3,0), rp) then return end
        if not Workspace:Raycast(front.Position, Vector3.new(0,-60,0), rp) then
            placeSmartBlock(Vector3.new(4,1,4), CFrame.new(front.Position + Vector3.new(0,-1,0)), 12, "BridgeBlock")
        end
    end

    local function applySpeed()
        local hum = getHum()
        if not hum then return end
        if CFG.SpeedX3 then hum.WalkSpeed = 48
        elseif CFG.Speed then hum.WalkSpeed = 16 * CFG.SpeedMult
        else hum.WalkSpeed = 16 end
    end

    function tickNoclip()
        if not CFG.Noclip then return end
        local c = getChar()
        if not c then return end
        for _, part in ipairs(c:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end

    -- FLY (smoothed, mobile buttons)
    local FLY_BTNS = {
        {name="CSFlyFwd", label="▲", flag="F"}, {name="CSFlyBack", label="▼", flag="B"},
        {name="CSFlyLeft", label="◀", flag="L"}, {name="CSFlyRight", label="▶", flag="R"},
        {name="CSFlyUp", label="⬆", flag="U"}, {name="CSFlyDown", label="⬇", flag="D"},
    }
    local flyTouch = {F=false, B=false, L=false, R=false, U=false, D=false}
    local function flyBtnHandler(actionName, inputState)
        for _, d in ipairs(FLY_BTNS) do
            if d.name == actionName then flyTouch[d.flag] = (inputState == Enum.UserInputState.Begin) break end
        end
        return Enum.ContextActionResult.Sink
    end
    local function setFlyButtons(on)
        if not isMobile then return end
        for _, d in ipairs(FLY_BTNS) do
            if on then
                ContextActionService:BindAction(d.name, flyBtnHandler, true)
                ContextActionService:SetTitle(d.name, d.label)
            else
                ContextActionService:UnbindAction(d.name)
                flyTouch[d.flag] = false
            end
        end
    end

    local _flyAtt, _flyLV, _flyAO, _flyVel = nil, nil, nil, Vector3.zero
    local function startFly()
        local hrp = getHRP()
        if not hrp then return end
        local hum = getHum()
        if hum then hum.PlatformStand = true end
        _flyVel = Vector3.zero
        _flyAtt = Instance.new("Attachment"); _flyAtt.Parent = hrp
        _flyLV = Instance.new("LinearVelocity")
        _flyLV.Attachment0 = _flyAtt
        _flyLV.MaxForce = math.huge
        _flyLV.VectorVelocity = Vector3.zero
        _flyLV.Parent = hrp
        _flyAO = Instance.new("AlignOrientation")
        _flyAO.Mode = Enum.OrientationAlignmentMode.OneAttachment
        _flyAO.Attachment0 = _flyAtt
        _flyAO.Responsiveness = 60
        _flyAO.CFrame = hrp.CFrame
        _flyAO.Parent = hrp
    end
    local function stopFly()
        local hum = getHum()
        if hum then hum.PlatformStand = false end
        if _flyLV then _flyLV:Destroy(); _flyLV = nil end
        if _flyAO then _flyAO:Destroy(); _flyAO = nil end
        if _flyAtt then _flyAtt:Destroy(); _flyAtt = nil end
    end
    function tickFly()
        if not CFG.Fly then
            if _flyLV then stopFly() end
            return
        end
        if not _flyLV then startFly() end
        local hrp = getHRP()
        if not hrp or not _flyLV then return end
        local UIS = UserInputService
        local cf, mv = cam.CFrame, Vector3.zero
        if flyTouch.F or UIS:IsKeyDown(Enum.KeyCode.W)         then mv += cf.LookVector  end
        if flyTouch.B or UIS:IsKeyDown(Enum.KeyCode.S)         then mv -= cf.LookVector  end
        if flyTouch.L or UIS:IsKeyDown(Enum.KeyCode.A)         then mv -= cf.RightVector end
        if flyTouch.R or UIS:IsKeyDown(Enum.KeyCode.D)         then mv += cf.RightVector end
        if flyTouch.U or UIS:IsKeyDown(Enum.KeyCode.Space)     then mv += Vector3.yAxis  end
        if flyTouch.D or UIS:IsKeyDown(Enum.KeyCode.LeftShift) then mv -= Vector3.yAxis  end
        local desired = mv.Magnitude > 0 and mv.Unit * CFG.FlySpeed or Vector3.zero
        _flyVel = _flyVel:Lerp(desired, 0.25) -- smooth acceleration
        _flyLV.VectorVelocity = _flyVel
        _flyAO.CFrame = cf
    end

    local lastVel = Vector3.zero
    function tickAntiKB()
        if not CFG.AntiKB then lastVel = Vector3.zero return end
        local hrp = getHRP()
        if not hrp then return end
        local v = hrp.AssemblyLinearVelocity
        if Vector3.new(v.X - lastVel.X, 0, v.Z - lastVel.Z).Magnitude > 40 then
            hrp.AssemblyLinearVelocity = Vector3.new(lastVel.X * 0.2, v.Y, lastVel.Z * 0.2)
        end
        lastVel = v
    end

    local _farmTimer, _farmCache, _farmCacheTimer, _farmMoveTimer = 0, {}, 0, 0
    local FARM_KEYWORDS = {"iron","gold","emerald","diamond","coin","gem"}
    local function scanFarmTargets()
        _farmCache = {}
        local scanned = 0
        for _, obj in ipairs(Workspace:GetDescendants()) do
            scanned += 1
            if scanned > 3000 then break end
            if obj:IsA("BasePart") then
                local n = obj.Name:lower()
                for _, kw in ipairs(FARM_KEYWORDS) do
                    if n:find(kw) then table.insert(_farmCache, obj) break end
                end
            end
        end
    end
    function tickAutoFarm(dt)
        if not CFG.AutoFarm then return end
        _farmCacheTimer -= dt
        if _farmCacheTimer <= 0 then _farmCacheTimer = 10; scanFarmTargets() end
        _farmTimer -= dt
        if _farmTimer > 0 then return end
        _farmTimer = 1.5
        local hrp, hum = getHRP(), getHum()
        if not (hrp and hum) then return end
        local best, bd = nil, 150
        for _, part in ipairs(_farmCache) do
            if part.Parent then
                local d = (part.Position - hrp.Position).Magnitude
                if d < bd then best = part; bd = d end
            end
        end
        if best then
            local hl = best:FindFirstChild("CS_FarmHL") or Instance.new("Highlight")
            hl.Name = "CS_FarmHL"
            hl.FillColor = Color3.fromRGB(255, 215, 0)
            hl.FillTransparency = 0.5
            hl.OutlineTransparency = 0
            hl.Parent = best
            task.delay(2, function() if hl.Parent then hl:Destroy() end end)
            if bd > 6 and not playerMoving() then -- never fight your controls
                _farmMoveTimer -= 1.5
                if _farmMoveTimer <= 0 then
                    _farmMoveTimer = 0.25
                    hum:MoveTo(best.Position)
                end
            end
        end
    end

    local _magTimer = 0
    function tickMagnet(dt)
        if not CFG.CoinMagnet then return end
        _magTimer -= dt
        if _magTimer > 0 then return end
        _magTimer = 2
        local remote = R("MagnetRemote")
        if remote then remote:FireServer() end
    end

    function tickTargetLabel()
        if not TargetLbl then return end
        local active = CFG.Aimbot or CFG.KillAura or CFG.AutoSwing or CFG.TriggerBot
        if active and curTarget and curTarget.Parent then
            local plr = Players:GetPlayerFromCharacter(curTarget.Parent)
            local hrp = getHRP()
            local d = hrp and math.floor((hrp.Position - curTarget.Position).Magnitude) or 0
            TargetLbl.Text = "🎯 " .. (plr and plr.DisplayName or "?") .. " • " .. d .. "m"
        else
            TargetLbl.Text = ""
        end
    end

    -- ── C8 · VISUALS ────────────────────────────────────────
    local _espBoards = {}

    local function makeESPBoard(p)
        local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local bb = Instance.new("BillboardGui")
        bb.Size = UDim2.new(0,150,0,56)
        bb.StudsOffset = Vector3.new(0,3.5,0)
        bb.AlwaysOnTop = true
        bb.Adornee = hrp
        bb.Parent = PlayerGui
        local lbl = Instance.new("TextLabel", bb)
        lbl.Name = "ESPLbl"
        lbl.Size = UDim2.new(1,0,0,18)
        lbl.BackgroundTransparency = 1
        lbl.TextStrokeTransparency = 0.3
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 13
        local dist = Instance.new("TextLabel", bb)
        dist.Name = "ESPDist"
        dist.Size = UDim2.new(1,0,0,14)
        dist.Position = UDim2.new(0,0,0,18)
        dist.BackgroundTransparency = 1
        dist.TextColor3 = Color3.fromRGB(200,210,240)
        dist.TextStrokeTransparency = 0.4
        dist.Font = Enum.Font.Gotham
        dist.TextSize = 11
        local hbBG = Instance.new("Frame", bb)
        hbBG.Name = "HBG"
        hbBG.Size = UDim2.new(1,-30,0,6)
        hbBG.Position = UDim2.new(0,15,0,38)
        hbBG.BackgroundColor3 = Color3.fromRGB(40,10,10)
        hbBG.BorderSizePixel = 0
        Instance.new("UICorner", hbBG).CornerRadius = UDim.new(1,0)
        local hb = Instance.new("Frame", hbBG)
        hb.Name = "HB"
        hb.Size = UDim2.new(1,0,1,0)
        hb.BackgroundColor3 = Color3.fromRGB(80,255,100)
        hb.BorderSizePixel = 0
        Instance.new("UICorner", hb).CornerRadius = UDim.new(1,0)
        _espBoards[p] = bb
    end

    local function tickESP()
        for p, bb in pairs(_espBoards) do
            if not CFG.PlayerESP or not p.Parent then
                bb:Destroy(); _espBoards[p] = nil
            elseif p.Character then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                local ohrp = p.Character:FindFirstChild("HumanoidRootPart")
                local lbl, dist, hb = bb:FindFirstChild("ESPLbl"), bb:FindFirstChild("ESPDist"), bb:FindFirstChild("HBG") and bb.HBG:FindFirstChild("HB")
                if lbl and hum then
                    local col = p.Team and p.Team.TeamColor.Color or Color3.fromRGB(255,80,80)
                    lbl.TextColor3 = col
                    lbl.Text = "👤 " .. p.DisplayName
                    if dist and ohrp and getHRP() then
                        dist.Text = math.floor((ohrp.Position - getHRP().Position).Magnitude) .. "m"
                    end
                    if hb then
                        local f = math.clamp(hum.Health / math.max(1, hum.MaxHealth), 0, 1)
                        hb.Size = UDim2.new(f, 0, 1, 0)
                        hb.BackgroundColor3 = Color3.fromRGB(255, 80, 80):Lerp(Color3.fromRGB(80,255,100), f)
                    end
                end
            end
        end
        if not CFG.PlayerESP then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and not _espBoards[p] and p.Character then
                makeESPBoard(p)
            end
        end
    end

    local function guessTeam(name)
        local n = name:lower()
        for team in pairs(TEAM_COLOR_MAP) do
            if n:find(team) then return team end
        end
        return nil
    end

    local _bedBoards, _bedPrev, _bedTimer = {}, {}, 0
    local function tickBedESP(dt)
        if not CFG.BedESP then
            for _, e in ipairs(_bedBoards) do e.bb:Destroy() end
            _bedBoards, _bedPrev = {}, {}
            return
        end
        local hrp = getHRP()
        for _, e in ipairs(_bedBoards) do -- live distance
            if e.part.Parent and hrp then
                e.lbl.Text = "🛏️ " .. e.team .. " • " .. math.floor((e.part.Position - hrp.Position).Magnitude) .. "m"
            end
        end
        _bedTimer -= dt
        if _bedTimer > 0 then return end
        _bedTimer = 2
        local found = {}
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local n = obj.Name:lower()
                if n:find("bed") or n:find("target") then table.insert(found, obj) end
            end
        end
        for prev in pairs(_bedPrev) do -- destroyed-bed detection
            local still = false
            for _, obj in ipairs(found) do if obj == prev then still = true break end end
            if not still then
                toast("🛏️ A bed was DESTROYED!", Color3.fromRGB(190,40,60))
                pingSound.PlaybackSpeed = 0.7
                pingSound:Play()
            end
        end
        for _, e in ipairs(_bedBoards) do e.bb:Destroy() end
        _bedBoards, _bedPrev = {}, {}
        for _, obj in ipairs(found) do
            local team = guessTeam(obj.Name) or guessTeam(obj.Parent and obj.Parent.Name or "")
                or guessTeam(obj.Parent and obj.Parent.Parent and obj.Parent.Parent.Name or "") or "BED"
            local bb = Instance.new("BillboardGui")
            bb.Size, bb.StudsOffset, bb.AlwaysOnTop, bb.Adornee = UDim2.new(0,130,0,26), Vector3.new(0,4,0), true, obj
            bb.Parent = PlayerGui
            local lbl = Instance.new("TextLabel", bb)
            lbl.Size = UDim2.new(1,0,1,0)
            lbl.BackgroundTransparency = 1
            lbl.TextColor3 = TEAM_COLOR_MAP[team] or Color3.fromRGB(255,220,50)
            lbl.TextStrokeTransparency = 0.3
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 13
            lbl.Text = "🛏️ " .. string.upper(team)
            table.insert(_bedBoards, {bb = bb, part = obj, lbl = lbl, team = team})
            _bedPrev[obj] = true
        end
    end

    local _genBoards, _genTimer = {}, 0
    local function tickGenESP(dt)
        if not CFG.GenESP then
            for _, e in ipairs(_genBoards) do e.bb:Destroy() end
            _genBoards = {}
            return
        end
        local hrp = getHRP()
        for _, e in ipairs(_genBoards) do
            if e.part.Parent and hrp then
                e.lbl.Text = "💎 " .. e.part.Name .. " • " .. math.floor((e.part.Position - hrp.Position).Magnitude) .. "m"
            end
        end
        _genTimer -= dt
        if _genTimer > 0 then return end
        _genTimer = 5
        for _, e in ipairs(_genBoards) do e.bb:Destroy() end
        _genBoards = {}
        local keywords = {"generator","gen","spawner","iron","gold","emerald","diamond"}
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local n = obj.Name:lower()
                for _, kw in ipairs(keywords) do
                    if n:find(kw) then
                        local bb = Instance.new("BillboardGui")
                        bb.Size, bb.StudsOffset, bb.AlwaysOnTop, bb.Adornee = UDim2.new(0,130,0,26), Vector3.new(0,5,0), true, obj
                        bb.Parent = PlayerGui
                        local lbl = Instance.new("TextLabel", bb)
                        lbl.Size = UDim2.new(1,0,1,0)
                        lbl.BackgroundTransparency = 1
                        lbl.TextColor3 = Color3.fromRGB(100,220,255)
                        lbl.TextStrokeTransparency = 0.3
                        lbl.Font = Enum.Font.GothamBold
                        lbl.TextSize = 12
                        lbl.Text = "💎 " .. obj.Name
                        table.insert(_genBoards, {bb = bb, part = obj, lbl = lbl})
                        break
                    end
                end
            end
        end
    end

    local function applyVisuals(p)
        local char = p.Character
        if not char or p == LocalPlayer then return end
        local teamCol = p.Team and p.Team.TeamColor.Color or Color3.fromRGB(255,70,70)
        if CFG.Chams then
            local hl = char:FindFirstChild("CS_Cham") or Instance.new("Highlight")
            hl.Name = "CS_Cham"
            hl.FillColor = teamCol
            hl.FillTransparency = 0.65
            hl.OutlineColor = teamCol
            hl.OutlineTransparency = 0
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Parent = char
        else
            local hl = char:FindFirstChild("CS_Cham")
            if hl then hl:Destroy() end
        end
        for _, partName in ipairs({"HumanoidRootPart","Head"}) do
            local part = char:FindFirstChild(partName)
            if part then
                local existing = part:FindFirstChild("CS_HB")
                if CFG.Hitboxes and not existing then
                    local sb = Instance.new("SelectionBox")
                    sb.Name = "CS_HB"
                    sb.Adornee = part
                    sb.LineThickness = 0.03
                    sb.Color3 = teamCol
                    sb.SurfaceColor3 = teamCol
                    sb.Parent = part
                elseif not CFG.Hitboxes and existing then
                    existing:Destroy()
                end
            end
        end
    end
    local function refreshVisualsAll()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then applyVisuals(p) end
        end
    end

    local _radarGui = nil
    local function buildRadar()
        if _radarGui then _radarGui:Destroy() end
        _radarGui = Instance.new("ScreenGui")
        _radarGui.Name = "CSRadar"
        _radarGui.ResetOnSpawn = false
        _radarGui.Parent = PlayerGui
        local bg = Instance.new("Frame", _radarGui)
        bg.Name = "BG"
        bg.Size = UDim2.new(0,140,0,140)
        bg.Position = UDim2.new(1,-155,1,-155)
        bg.BackgroundColor3 = Color3.fromRGB(8,10,18)
        bg.BackgroundTransparency = 0.35
        bg.BorderSizePixel = 0
        Instance.new("UICorner", bg).CornerRadius = UDim.new(1,0)
        local you = Instance.new("Frame", bg)
        you.Size = UDim2.new(0,7,0,7)
        you.Position = UDim2.new(0.5,-3,0.5,-3)
        you.BackgroundColor3 = Color3.fromRGB(80,255,100)
        you.BorderSizePixel = 0
        Instance.new("UICorner", you).CornerRadius = UDim.new(1,0)
    end

    local function tickRadar()
        if not CFG.Radar then
            if _radarGui then _radarGui:Destroy(); _radarGui = nil end
            return
        end
        if not _radarGui then buildRadar() end
        local bg = _radarGui:FindFirstChild("BG")
        local hrp = getHRP()
        if not (bg and hrp) then return end
        for _, d in ipairs(bg:GetChildren()) do
            if d.Name == "RDot" or d.Name == "BDot" then d:Destroy() end
        end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local ohrp = p.Character:FindFirstChild("HumanoidRootPart")
                if ohrp then
                    local rel = cam.CFrame:VectorToObjectSpace(ohrp.Position - hrp.Position)
                    local dot = Instance.new("Frame", bg)
                    dot.Name = "RDot"
                    dot.Size = UDim2.new(0,6,0,6)
                    dot.Position = UDim2.new(0, math.clamp(70 + rel.X * 1.4, 4, 136) - 3, 0, math.clamp(70 + rel.Z * 1.4, 4, 136) - 3)
                    dot.BackgroundColor3 = Color3.fromRGB(255,60,60)
                    dot.BorderSizePixel = 0
                    Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)
                end
            end
        end
        if CFG.BedESP then -- bed dots
            for _, e in ipairs(_bedBoards) do
                if e.part.Parent then
                    local rel = cam.CFrame:VectorToObjectSpace(e.part.Position - hrp.Position)
                    local dot = Instance.new("Frame", bg)
                    dot.Name = "BDot"
                    dot.Size = UDim2.new(0,7,0,7)
                    dot.Position = UDim2.new(0, math.clamp(70 + rel.X * 1.4, 4, 136) - 3, 0, math.clamp(70 + rel.Z * 1.4, 4, 136) - 3)
                    dot.BackgroundColor3 = Color3.fromRGB(255,220,60)
                    dot.BorderSizePixel = 0
                end
            end
        end
    end

    local fbSaved = nil
    local function setFullBright(on)
        if on then
            fbSaved = {b = Lighting.Brightness, a = Lighting.Ambient, oa = Lighting.OutdoorAmbient, g = Lighting.GlobalShadows, f = Lighting.FogEnd}
            Lighting.Brightness = 3
            Lighting.Ambient = Color3.fromRGB(150,150,150)
            Lighting.OutdoorAmbient = Color3.fromRGB(150,150,150)
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 1e6
        elseif fbSaved then
            Lighting.Brightness = fbSaved.b
            Lighting.Ambient = fbSaved.a
            Lighting.OutdoorAmbient = fbSaved.oa
            Lighting.GlobalShadows = fbSaved.g
            Lighting.FogEnd = fbSaved.f
        end
    end

    local dangerFrame
    local _dangerCooldown = 0
    local function tickDanger(dt)
        if not CFG.DangerAlert or not dangerFrame then return end
        _dangerCooldown = math.max(0, _dangerCooldown - dt)
        if _dangerCooldown > 0 then return end
        local hrp = getHRP()
        if not hrp then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local ohrp = p.Character:FindFirstChild("HumanoidRootPart")
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if ohrp and hum and hum.Health > 0 then
                    local dir = (ohrp.Position - hrp.Position)
                    if dir.Magnitude < 22 and hrp.CFrame.LookVector:Dot(dir.Unit) < -0.3 then
                        _dangerCooldown = 2
                        pingSound.PlaybackSpeed = 1.3
                        pingSound:Play()
                        dangerFrame.BackgroundTransparency = 0.75
                        TweenService:Create(dangerFrame, TweenInfo.new(0.8), {BackgroundTransparency = 1}):Play()
                        return
                    end
                end
            end
        end
    end

    local BASE_STROKE = Color3.fromRGB(50, 65, 120)
    local _rainbowHue = 0
    local function tickRainbow(dt)
        if not CFG.RainbowUI or not _winStroke then return end
        _rainbowHue = (_rainbowHue + dt * 0.25) % 1
        _winStroke.Color = Color3.fromHSV(_rainbowHue, 0.85, 1)
    end

    local lootConn = nil
    local LOOT_KEYWORDS = {"diamond","emerald","legendary","rare","chest"}
    local function setLootAlert(on)
        if lootConn then lootConn:Disconnect(); lootConn = nil end
        if on then
            lootConn = Workspace.DescendantAdded:Connect(function(obj)
                if obj:IsA("BasePart") then
                    local n = obj.Name:lower()
                    for _, kw in ipairs(LOOT_KEYWORDS) do
                        if n:find(kw) then
                            toast("📦 Rare loot: " .. obj.Name, Color3.fromRGB(180,60,190))
                            pingSound:Play()
                            break
                        end
                    end
                end
            end)
        end
    end

    -- kill notify + streaks
    local killConns = {}
    local _streak, _lastKillT = 0, 0
    local function hookKillNotify(p)
        if killConns[p] then return end
        killConns[p] = p.CharacterAdded:Connect(function(char)
            local hum = char:WaitForChild("Humanoid", 10)
            if not hum then return end
            hum.Died:Connect(function()
                if CFG.KillNotify and (lastDamage[char] or 0) + 5 > os.clock() then
                    local now = os.clock()
                    _streak = (now - _lastKillT < 8) and _streak + 1 or 1
                    _lastKillT = now
                    local names = {[2]="DOUBLE KILL",[3]="TRIPLE KILL",[4]="QUAD KILL",[5]="RAMPAGE"}
                    local extra = names[_streak] and ("  🔥 " .. names[_streak] .. "!")
                        or (_streak > 5 and ("  🔥 UNSTOPPABLE x" .. _streak) or "")
                    toast("☠️ Eliminated " .. p.DisplayName .. extra, Color3.fromRGB(190,40,60))
                end
            end)
        end)
    end

    local zoomMobileOn = false
    local function setZoom(on)
        TweenService:Create(cam, TweenInfo.new(0.25), {FieldOfView = on and 25 or 70}):Play()
    end
    local function setZoomButton(on)
        if not isMobile then return end
        if on then
            ContextActionService:BindAction("CSZoom", function(_, state)
                if state == Enum.UserInputState.Begin then
                    zoomMobileOn = not zoomMobileOn
                    setZoom(zoomMobileOn)
                end
                return Enum.ContextActionResult.Sink
            end, true)
            ContextActionService:SetTitle("CSZoom", "🔍")
        else
            ContextActionService:UnbindAction("CSZoom")
            zoomMobileOn = false
            setZoom(false)
        end
    end

    -- ── C9 · INPUT ──────────────────────────────────────────
    local _jumpCd = 0
    UserInputService.JumpRequest:Connect(function()
        if os.clock() < _jumpCd then return end
        if CFG.HighJump then
            local hum = getHum()
            if hum then
                _jumpCd = os.clock() + 0.4
                hum.JumpPower = CFG.JumpPower
                task.delay(0.15, function()
                    local h = getHum()
                    if h then h.JumpPower = 50 end
                end)
            end
        end
        if CFG.InfJump then
            local hum = getHum()
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end)

    local HOTKEYS = {
        [Enum.KeyCode.F] = {"Fly", "✈️ Fly"},
        [Enum.KeyCode.G] = {"Ghost", "👻 Ghost Mode"},
        [Enum.KeyCode.N] = {"Noclip", "🌀 Noclip"},
        [Enum.KeyCode.X] = {"Speed", "⚡ Speed Hack"},
        [Enum.KeyCode.K] = {"KillAura", "💀 Kill Aura"},
        [Enum.KeyCode.R] = {"Radar", "📡 Radar"},
        [Enum.KeyCode.B] = {"BedESP", "🛏️ Bed ESP"},
    }

    local _tpCd = 0
    local function flashAt(pos)
        local p = Instance.new("Part")
        p.Shape = Enum.PartType.Ball
        p.Anchored, p.CanCollide = true, false
        p.Material = Enum.Material.Neon
        p.Color = Color3.fromRGB(120,160,255)
        p.Size = Vector3.new(3,3,3)
        p.Position = pos
        p.Transparency = 0.3
        p.Parent = blockFolder
        TweenService:Create(p, TweenInfo.new(0.5), {Transparency = 1, Size = Vector3.new(0.4,0.4,0.4)}):Play()
        task.delay(0.55, function() p:Destroy() end)
    end

    UserInputService.InputBegan:Connect(function(inp, proc)
        if proc then return end
        if inp.KeyCode == Enum.KeyCode.RightAlt then
            if Win then Win.Visible = not Win.Visible end
            return
        end
        if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then
            if CFG.SilentAim then
                local model = crosshairEnemy(CFG.AimbotRange)
                if model then dealDamage(model, 8) end
            end
            if CFG.ClickTP and os.clock() >= _tpCd then
                local hrp = getHRP()
                if hrp then
                    local loc = UserInputService:GetMouseLocation()
                    local ray = cam:ScreenPointToRay(loc.X, loc.Y)
                    local rp = RaycastParams.new()
                    rp.FilterDescendantsInstances = {getChar()}
                    rp.FilterType = Enum.RaycastFilterType.Exclude
                    local hit = Workspace:Raycast(ray.Origin, ray.Direction * 1000, rp)
                    if hit then
                        _tpCd = os.clock() + 0.35
                        flashAt(hit.Position + Vector3.new(0, 1, 0))
                        hrp.CFrame = CFrame.new(hit.Position + Vector3.new(0, 3, 0))
                    end
                end
            end
        end
        if inp.UserInputType == Enum.UserInputType.MouseButton2 and CFG.ZoomHack then
            setZoom(true)
        end
        local hk = HOTKEYS[inp.KeyCode]
        if hk then
            local newVal = not (CFG[hk[1]] == true)
            setConfig(hk[1], newVal)
            toast(hk[2] .. (newVal and ": ON" or ": OFF"),
                newVal and Color3.fromRGB(30,150,70) or Color3.fromRGB(120,60,60))
        end
    end)

    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton2 and CFG.ZoomHack then
            setZoom(false)
        end
    end)

    -- ── C10 · LIFECYCLE ─────────────────────────────────────
    local function onNewPlayer(p)
        if p == LocalPlayer then return end
        hookKillNotify(p)
        p.CharacterAdded:Connect(function()
            task.wait(0.3)
            applyVisuals(p)
        end)
    end
    for _, p in ipairs(Players:GetPlayers()) do onNewPlayer(p) end
    Players.PlayerAdded:Connect(onNewPlayer)
    Players.PlayerRemoving:Connect(function(p)
        if _espBoards[p] then _espBoards[p]:Destroy(); _espBoards[p] = nil end
        if killConns[p] then killConns[p]:Disconnect(); killConns[p] = nil end
    end)

    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.5)
        safe(applySpeed)
        if CFG.Fly then setConfig("Fly", false) end
        refreshVisualsAll()
        if CFG.Ghost then
            local g = R("GhostRemote")
            if g then g:FireServer(true) end
        end
    end)

    -- ── C11 · GUI ───────────────────────────────────────────
    local SG = Instance.new("ScreenGui")
    SG.Name = "CheatSimulatorUI"
    SG.ResetOnSpawn = false
    SG.DisplayOrder = 10
    SG.IgnoreGuiInset = true
    SG.Parent = PlayerGui

    Win = Instance.new("Frame", SG)
    Win.Name = "Window"
    Win.Size = UDim2.new(0, 360, 0, 500)
    Win.Position = UDim2.new(0, 20, 0.5, -250)
    Win.BackgroundColor3 = Color3.fromRGB(13, 15, 23)
    Win.BorderSizePixel = 0
    Win.Active = true
    Instance.new("UICorner", Win).CornerRadius = UDim.new(0, 12)

    local function fitWindow()
        local vp = cam.ViewportSize
        if isMobile then
            local w = math.clamp(vp.X * 0.64, 250, 340)
            local h = math.clamp(vp.Y * 0.62, 280, 470)
            Win.Size = UDim2.new(0, w, 0, h)
            Win.Position = UDim2.new(0.5, -w/2, 0.5, -h/2)
        end
    end
    fitWindow()
    cam:GetPropertyChangedSignal("ViewportSize"):Connect(fitWindow)

    _winStroke = Instance.new("UIStroke", Win)
    _winStroke.Color = BASE_STROKE
    _winStroke.Thickness = 1.5

    -- locked-target HUD (top of screen)
    TargetLbl = Instance.new("TextLabel", SG)
    TargetLbl.Size = UDim2.new(0, 200, 0, 20)
    TargetLbl.Position = UDim2.new(0.5, -100, 0, 8)
    TargetLbl.BackgroundTransparency = 1
    TargetLbl.Text = ""
    TargetLbl.TextColor3 = Color3.fromRGB(120,255,140)
    TargetLbl.TextStrokeTransparency = 0.4
    TargetLbl.Font = Enum.Font.GothamBold
    TargetLbl.TextSize = 14

    local fabGui = Instance.new("ScreenGui")
    fabGui.Name = "CSFab"
    fabGui.ResetOnSpawn = false
    fabGui.DisplayOrder = 11
    fabGui.IgnoreGuiInset = true
    fabGui.Parent = PlayerGui
    local fab = Instance.new("TextButton", fabGui)
    fab.Size = UDim2.new(0, 48, 0, 48)
    fab.Position = UDim2.new(0, 12, 1, -72)
    fab.BackgroundColor3 = Color3.fromRGB(70, 100, 255)
    fab.BackgroundTransparency = 0.25
    fab.Text = "CS"
    fab.TextColor3 = Color3.new(1,1,1)
    fab.Font = Enum.Font.GothamBold
    fab.TextSize = 16
    fab.BorderSizePixel = 0
    Instance.new("UICorner", fab).CornerRadius = UDim.new(1, 0)
    fab.MouseButton1Click:Connect(function()
        Win.Visible = not Win.Visible
        fab.BackgroundColor3 = Win.Visible and Color3.fromRGB(30,150,70) or Color3.fromRGB(70,100,255)
    end)

    local TBar = Instance.new("Frame", Win)
    TBar.Size = UDim2.new(1, 0, 0, 46)
    TBar.BackgroundColor3 = Color3.fromRGB(18, 22, 36)
    TBar.BorderSizePixel = 0
    Instance.new("UICorner", TBar).CornerRadius = UDim.new(0, 12)
    local TFix = Instance.new("Frame", TBar)
    TFix.Size = UDim2.new(1, 0, 0, 12)
    TFix.Position = UDim2.new(0, 0, 1, -12)
    TFix.BackgroundColor3 = Color3.fromRGB(18, 22, 36)
    TFix.BorderSizePixel = 0

    local dragging, dragStart, startPos = false, nil, nil
    TBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Win.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    local Icon = Instance.new("Frame", TBar)
    Icon.Size = UDim2.new(0, 30, 0, 30)
    Icon.Position = UDim2.new(0, 10, 0.5, -15)
    Icon.BackgroundColor3 = Color3.fromRGB(70, 100, 255)
    Icon.BorderSizePixel = 0
    Instance.new("UICorner", Icon).CornerRadius = UDim.new(0, 7)
    local IconLbl = Instance.new("TextLabel", Icon)
    IconLbl.Size = UDim2.new(1,0,1,0)
    IconLbl.BackgroundTransparency = 1
    IconLbl.Text = "CS"
    IconLbl.TextColor3 = Color3.new(1,1,1)
    IconLbl.Font = Enum.Font.GothamBold
    IconLbl.TextSize = 13

    local TitleLbl = Instance.new("TextLabel", TBar)
    TitleLbl.Size = UDim2.new(0,160,0,20)
    TitleLbl.Position = UDim2.new(0,48,0,7)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = "Cheat Simulator"
    TitleLbl.TextColor3 = Color3.fromRGB(240,245,255)
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.TextSize = 14
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left

    local SubLbl = Instance.new("TextLabel", TBar)
    SubLbl.Size = UDim2.new(0,160,0,14)
    SubLbl.Position = UDim2.new(0,48,0,26)
    SubLbl.BackgroundTransparency = 1
    SubLbl.Text = isMobile and "Bedwars Edition • Mobile" or "Bedwars Edition • PRO"
    SubLbl.TextColor3 = Color3.fromRGB(80, 100, 160)
    SubLbl.Font = Enum.Font.Gotham
    SubLbl.TextSize = 11
    SubLbl.TextXAlignment = Enum.TextXAlignment.Left

    local StatPill = Instance.new("Frame", TBar)
    StatPill.Size = UDim2.new(0,70,0,20)
    StatPill.Position = UDim2.new(1,-160,0.5,-10)
    StatPill.BackgroundColor3 = Color3.fromRGB(60,70,100)
    StatPill.BorderSizePixel = 0
    Instance.new("UICorner", StatPill).CornerRadius = UDim.new(1,0)
    local StatLbl = Instance.new("TextLabel", StatPill)
    StatLbl.Size = UDim2.new(1,0,1,0)
    StatLbl.BackgroundTransparency = 1
    StatLbl.Text = "● IDLE"
    StatLbl.TextColor3 = Color3.new(1,1,1)
    StatLbl.Font = Enum.Font.GothamBold
    StatLbl.TextSize = 10

    updateStatusPill = function()
        local n = 0
        for _, v in pairs(CFG) do
            if type(v) == "boolean" and v then n += 1 end
        end
        if n > 0 then
            StatPill.BackgroundColor3 = Color3.fromRGB(20,180,80)
            StatLbl.Text = "● " .. n .. " ON"
        else
            StatPill.BackgroundColor3 = Color3.fromRGB(60,70,100)
            StatLbl.Text = "● IDLE"
        end
    end

    local CloseBtn = Instance.new("TextButton", TBar)
    CloseBtn.Size = UDim2.new(0,26,0,26)
    CloseBtn.Position = UDim2.new(1,-34,0.5,-13)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(190,50,50)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.new(1,1,1)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 12
    CloseBtn.BorderSizePixel = 0
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0,6)
    CloseBtn.MouseButton1Click:Connect(function() Win.Visible = false end)

    local TabBar = Instance.new("Frame", Win)
    TabBar.Size = UDim2.new(1,-16,0,32)
    TabBar.Position = UDim2.new(0,8,0,52)
    TabBar.BackgroundColor3 = Color3.fromRGB(18,22,36)
    TabBar.BorderSizePixel = 0
    Instance.new("UICorner", TabBar).CornerRadius = UDim.new(0,8)
    local TBLayout = Instance.new("UIListLayout", TabBar)
    TBLayout.FillDirection = Enum.FillDirection.Horizontal
    TBLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    TBLayout.Padding = UDim.new(0,4)
    Instance.new("UIPadding", TabBar).PaddingLeft = UDim.new(0,5)

    local Body = Instance.new("ScrollingFrame", Win)
    Body.Size = UDim2.new(1,-16,1,-104)
    Body.Position = UDim2.new(0,8,0,90)
    Body.BackgroundTransparency = 1
    Body.BorderSizePixel = 0
    Body.ScrollBarThickness = 3
    Body.ScrollBarImageColor3 = Color3.fromRGB(70,90,200)
    Body.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Body.CanvasSize = UDim2.new(0,0,0,0)
    local BLayout = Instance.new("UIListLayout", Body)
    BLayout.Padding = UDim.new(0,6)
    BLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local HintBar = Instance.new("Frame", Win)
    HintBar.Size = UDim2.new(1,-16,0,22)
    HintBar.Position = UDim2.new(0,8,1,-28)
    HintBar.BackgroundColor3 = Color3.fromRGB(18,22,36)
    HintBar.BorderSizePixel = 0
    Instance.new("UICorner", HintBar).CornerRadius = UDim.new(0,6)
    local HintLbl = Instance.new("TextLabel", HintBar)
    HintLbl.Size = UDim2.new(1,-8,1,0)
    HintLbl.Position = UDim2.new(0,8,0,0)
    HintLbl.BackgroundTransparency = 1
    HintLbl.Text = isMobile
        and "Tap CS to open • Fly buttons appear while flying"
        or "RightAlt=panel  F=Fly G=Ghost N=Noclip X=Speed K=Aura R=Radar B=Bed"
    HintLbl.TextColor3 = Color3.fromRGB(70,85,130)
    HintLbl.Font = Enum.Font.Gotham
    HintLbl.TextSize = 10
    HintLbl.TextXAlignment = Enum.TextXAlignment.Left

    local ACTIVE_COLOR = Color3.fromRGB(70,100,255)
    local IDLE_COLOR = Color3.fromRGB(36,42,64)

    local function mkToggle(parent, icon, title, desc, cfgKey, order, onChange)
        local row = Instance.new("Frame", parent)
        row.Size = UDim2.new(1,0,0,56)
        row.BackgroundColor3 = Color3.fromRGB(20,24,38)
        row.BorderSizePixel = 0
        row.LayoutOrder = order
        Instance.new("UICorner", row).CornerRadius = UDim.new(0,9)
        local accent = Instance.new("Frame", row)
        accent.Size = UDim2.new(0,3,0,36)
        accent.Position = UDim2.new(0,0,0.5,-18)
        accent.BackgroundColor3 = IDLE_COLOR
        accent.BorderSizePixel = 0
        Instance.new("UICorner", accent).CornerRadius = UDim.new(0,3)
        local iconLbl = Instance.new("TextLabel", row)
        iconLbl.Size = UDim2.new(0,30,0,30)
        iconLbl.Position = UDim2.new(0,10,0.5,-15)
        iconLbl.BackgroundColor3 = Color3.fromRGB(26,30,50)
        iconLbl.Text = icon
        iconLbl.TextSize = 16
        iconLbl.Font = Enum.Font.GothamBold
        iconLbl.TextColor3 = Color3.new(1,1,1)
        iconLbl.BorderSizePixel = 0
        Instance.new("UICorner", iconLbl).CornerRadius = UDim.new(0,7)
        local tlbl = Instance.new("TextLabel", row)
        tlbl.Size = UDim2.new(1,-110,0,20)
        tlbl.Position = UDim2.new(0,48,0,9)
        tlbl.BackgroundTransparency = 1
        tlbl.Text = title
        tlbl.TextColor3 = Color3.fromRGB(225,230,245)
        tlbl.Font = Enum.Font.GothamBold
        tlbl.TextSize = 13
        tlbl.TextXAlignment = Enum.TextXAlignment.Left
        local dlbl = Instance.new("TextLabel", row)
        dlbl.Size = UDim2.new(1,-110,0,16)
        dlbl.Position = UDim2.new(0,48,0,30)
        dlbl.BackgroundTransparency = 1
        dlbl.Text = desc
        dlbl.TextColor3 = Color3.fromRGB(85,100,140)
        dlbl.Font = Enum.Font.Gotham
        dlbl.TextSize = 11
        dlbl.TextXAlignment = Enum.TextXAlignment.Left
        local pillBG = Instance.new("Frame", row)
        pillBG.Size = UDim2.new(0,44,0,24)
        pillBG.Position = UDim2.new(1,-54,0.5,-12)
        pillBG.BackgroundColor3 = IDLE_COLOR
        pillBG.BorderSizePixel = 0
        Instance.new("UICorner", pillBG).CornerRadius = UDim.new(1,0)
        local knob = Instance.new("Frame", pillBG)
        knob.Size = UDim2.new(0,18,0,18)
        knob.Position = UDim2.new(0,3,0.5,-9)
        knob.BackgroundColor3 = Color3.fromRGB(150,160,200)
        knob.BorderSizePixel = 0
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)
        local function refresh(animate)
            local state = CFG[cfgKey] == true
            local ti = TweenInfo.new(animate and 0.15 or 0, Enum.EasingStyle.Quad)
            TweenService:Create(pillBG, ti, {BackgroundColor3 = state and ACTIVE_COLOR or IDLE_COLOR}):Play()
            TweenService:Create(knob, ti, {Position = state and UDim2.new(0,23,0.5,-9) or UDim2.new(0,3,0.5,-9),
                BackgroundColor3 = state and Color3.new(1,1,1) or Color3.fromRGB(150,160,200)}):Play()
            TweenService:Create(accent, ti, {BackgroundColor3 = state and ACTIVE_COLOR or IDLE_COLOR}):Play()
            TweenService:Create(iconLbl, ti, {BackgroundColor3 = state and Color3.fromRGB(40,55,140) or Color3.fromRGB(26,30,50)}):Play()
        end
        refresh(false)
        cfgCallbacks[cfgKey] = cfgCallbacks[cfgKey] or {}
        table.insert(cfgCallbacks[cfgKey], function(val)
            refresh(true)
            if onChange then onChange(val) end
        end)
        local btn = Instance.new("TextButton", row)
        btn.Size = UDim2.new(1,0,1,0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.ZIndex = 5
        btn.MouseButton1Click:Connect(function()
            setConfig(cfgKey, not (CFG[cfgKey] == true))
        end)
        return row
    end

    local slidingSlider = nil
    local function mkSlider(parent, label, min, max, key, order, suffix, onChange)
        local row = Instance.new("Frame", parent)
        row.Size = UDim2.new(1,0,0,44)
        row.BackgroundColor3 = Color3.fromRGB(20,24,38)
        row.BorderSizePixel = 0
        row.LayoutOrder = order
        Instance.new("UICorner", row).CornerRadius = UDim.new(0,9)
        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(1,-76,0,16)
        lbl.Position = UDim2.new(0,12,0,5)
        lbl.BackgroundTransparency = 1
        lbl.Text = label
        lbl.TextColor3 = Color3.fromRGB(225,230,245)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        local valLbl = Instance.new("TextLabel", row)
        valLbl.Size = UDim2.new(0,60,0,16)
        valLbl.Position = UDim2.new(1,-70,0,5)
        valLbl.BackgroundTransparency = 1
        valLbl.Text = ""
        valLbl.TextColor3 = Color3.fromRGB(120,150,255)
        valLbl.Font = Enum.Font.GothamBold
        valLbl.TextSize = 12
        valLbl.TextXAlignment = Enum.TextXAlignment.Right
        local bar = Instance.new("Frame", row)
        bar.Size = UDim2.new(1,-24,0,8)
        bar.Position = UDim2.new(0,12,0,28)
        bar.BackgroundColor3 = IDLE_COLOR
        bar.BorderSizePixel = 0
        Instance.new("UICorner", bar).CornerRadius = UDim.new(1,0)
        local fill = Instance.new("Frame", bar)
        fill.Size = UDim2.new(0.5,0,1,0)
        fill.BackgroundColor3 = ACTIVE_COLOR
        fill.BorderSizePixel = 0
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)
        local knob = Instance.new("Frame", bar)
        knob.Size = UDim2.new(0,14,0,14)
        knob.Position = UDim2.new(0.5,-7,0.5,-7)
        knob.BackgroundColor3 = Color3.new(1,1,1)
        knob.BorderSizePixel = 0
        knob.ZIndex = 2
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)
        local function setFromFraction(frac)
            frac = math.clamp(frac, 0, 1)
            local v = math.round((min + (max - min) * frac) * 100) / 100
            CFG[key] = v
            fill.Size = UDim2.new(frac, 0, 1, 0)
            knob.Position = UDim2.new(frac, -7, 0.5, -7)
            valLbl.Text = tostring(v) .. (suffix or "")
            if onChange then onChange(v) end
        end
        setFromFraction((CFG[key] - min) / (max - min))
        cfgCallbacks[key] = cfgCallbacks[key] or {}
        table.insert(cfgCallbacks[key], function()
            setFromFraction((CFG[key] - min) / (max - min))
        end)
        bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                slidingSlider = {set = setFromFraction, bar = bar}
            end
        end)
        return row
    end

    UserInputService.InputChanged:Connect(function(input)
        if slidingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local bar = slidingSlider.bar
            local frac = (input.Position.X - bar.AbsolutePosition.X) / math.max(1, bar.AbsoluteSize.X)
            slidingSlider.set(frac)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            slidingSlider = nil
        end
    end)

    local function mkSection(parent, text, order)
        local f = Instance.new("Frame", parent)
        f.Size = UDim2.new(1,0,0,22)
        f.BackgroundTransparency = 1
        f.LayoutOrder = order
        local l = Instance.new("TextLabel", f)
        l.Size = UDim2.new(1,-4,1,0)
        l.Position = UDim2.new(0,4,0,0)
        l.BackgroundTransparency = 1
        l.Text = text
        l.TextColor3 = Color3.fromRGB(60,80,140)
        l.Font = Enum.Font.GothamBold
        l.TextSize = 10
        l.TextXAlignment = Enum.TextXAlignment.Left
    end

    local function mkSaveBtn(parent, order)
        local btn = Instance.new("TextButton", parent)
        btn.Size = UDim2.new(1,0,0,36)
        btn.BackgroundColor3 = Color3.fromRGB(45,70,190)
        btn.Text = "💾  Save Config"
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
        btn.BorderSizePixel = 0
        btn.LayoutOrder = order
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,9)
        btn.MouseButton1Click:Connect(function()
            local remote = R("ConfigRemote")
            if not remote then
                toast("⚠️ Server not running", Color3.fromRGB(160,60,60))
                return
            end
            local data = {}
            for k, v in pairs(CFG) do
                if type(v) == "boolean" or type(v) == "number" then data[k] = v end
            end
            remote:FireServer("save", data)
            toast("💾 Saving config...", Color3.fromRGB(45,70,190))
        end)
    end

    local tabData = {}
    local TABS = {
        {name="Combat", icon="⚔️"}, {name="Movement", icon="🏃"},
        {name="Utility", icon="🔧"}, {name="Visual", icon="👁️"},
    }
    local function selectTab(name)
        for tabName, d in pairs(tabData) do
            d.frame.Visible = (tabName == name)
            d.btn.BackgroundColor3 = (tabName == name)
                and Color3.fromRGB(60,90,220) or Color3.fromRGB(28,34,56)
        end
    end
    for _, t in ipairs(TABS) do
        local btn = Instance.new("TextButton", TabBar)
        btn.Size = isMobile and UDim2.new(0.25,-4,0,24) or UDim2.new(0,78,0,24)
        btn.BackgroundColor3 = Color3.fromRGB(28,34,56)
        btn.Text = t.icon .. " " .. t.name
        btn.TextColor3 = Color3.fromRGB(170,185,220)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 10
        btn.BorderSizePixel = 0
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,7)
        local frame = Instance.new("Frame", Body)
        frame.Name = t.name
        frame.Size = UDim2.new(1,0,0,0)
        frame.AutomaticSize = Enum.AutomaticSize.Y
        frame.BackgroundTransparency = 1
        frame.Visible = false
        local fl = Instance.new("UIListLayout", frame)
        fl.Padding = UDim.new(0,5)
        fl.SortOrder = Enum.SortOrder.LayoutOrder
        tabData[t.name] = {btn = btn, frame = frame}
        btn.MouseButton1Click:Connect(function() selectTab(t.name) end)
    end
    local function getTab(name) return tabData[name].frame end

    -- COMBAT
    local CT = getTab("Combat")
    mkSection(CT, "── FREE ─────────────────────────────", 0)
    mkToggle(CT, "⚡", "Aimbot", "Smart lock • FOV-limited • sticky", "Aimbot", 1)
    mkSlider(CT, "Aimbot FOV", 15, 180, "AimbotFOV", 2, "°")
    mkToggle(CT, "🎯", "Head Snap", "Aimbot targets the head", "AimbotHead", 3)
    mkToggle(CT, "👁️", "Visible Only", "Won't lock through walls", "AimbotVisible", 4)
    mkToggle(CT, "💀", "Kill Aura", "Attacks all enemies in range  [K]", "KillAura", 5)
    mkSlider(CT, "Kill Aura Range", 10, 60, "KillAuraRange", 6, " studs")
    mkToggle(CT, "🏃", "Auto Chase", "Kill Aura RUNS you to targets", "KillChase", 7)
    mkSection(CT, "── PREMIUM (free for testing) ─────────", 8)
    mkToggle(CT, "⚔️", "Auto Swing", "Auto-attacks nearest enemy", "AutoSwing", 9)
    mkToggle(CT, "🖱️", "Trigger Bot", "Fires when crosshair is on enemy", "TriggerBot", 10)
    mkToggle(CT, "🎭", "Silent Aim", "Tap/click anywhere to hit", "SilentAim", 11)
    mkToggle(CT, "🔥", "Crit Boost", "+25% damage on all attacks", "CritBoost", 12)
    mkToggle(CT, "🏹", "Range Extend", "Kill Aura range x1.6", "RangeExtend", 13)
    mkToggle(CT, "🛡️", "Anti-Knockback", "Cancels knockback spikes", "AntiKB", 14)
    mkSaveBtn(CT, 100)

    -- MOVEMENT
    local MV = getTab("Movement")
    mkSection(MV, "── FREE ─────────────────────────────", 0)
    mkToggle(MV, "⚡", "Speed Hack", "Boost walk speed  [X]", "Speed", 1, applySpeed)
    mkSlider(MV, "Speed Multiplier", 1.2, 5, "SpeedMult", 2, "x", applySpeed)
    mkToggle(MV, "🦘", "High Jump", "Massive jump (0.4s cooldown)", "HighJump", 3)
    mkToggle(MV, "🧱", "Anti-Void Scaffold", "Places YOUR blocks under you", "Scaffold", 4)
    mkToggle(MV, "🎒", "Use My Blocks", "Scaffold/Bridge consume real wool", "ScaffoldInv", 5)
    mkSection(MV, "── PREMIUM (free for testing) ─────────", 6)
    mkToggle(MV, "✈️", "Fly", "Smooth flight • touch buttons  [F]", "Fly", 7, function(on)
        setFlyButtons(on)
        if not on then stopFly() end
    end)
    mkSlider(MV, "Fly Speed", 20, 120, "FlySpeed", 8, " spd")
    mkToggle(MV, "🔄", "Infinite Jump", "Spam jump mid-air", "InfJump", 9)
    mkToggle(MV, "🌀", "Noclip", "Walk through walls  [N]", "Noclip", 10)
    mkToggle(MV, "🌉", "Auto Bridge", "Bridges ahead with YOUR blocks", "AutoBridge", 11)
    mkToggle(MV, "👣", "Click TP", "Tap anywhere • 0.35s cooldown", "ClickTP", 12)
    mkToggle(MV, "👻", "Ghost Mode", "Phase through players  [G]", "Ghost", 13, function(on)
        local remote = R("GhostRemote")
        if remote then remote:FireServer(on) end
    end)
    mkToggle(MV, "💨", "Speed Boost x3", "Triple speed (very obvious lol)", "SpeedX3", 14, applySpeed)
    mkSaveBtn(MV, 100)

    -- UTILITY
    local UT = getTab("Utility")
    mkSection(UT, "── FREE ─────────────────────────────", 0)
    mkToggle(UT, "🛏️", "Bed ESP", "Team • distance • destroy alerts  [B]", "BedESP", 1)
    mkToggle(UT, "💎", "Generator ESP", "Live distance to every gen", "GenESP", 2)
    mkToggle(UT, "📡", "Radar", "Players + beds, rotates  [R]", "Radar", 3)
    mkSection(UT, "── PREMIUM (free for testing) ─────────", 4)
    mkToggle(UT, "💰", "Coin Magnet", "Drops fly to you (tweened)", "CoinMagnet", 5)
    mkToggle(UT, "🤖", "Auto Farm", "Walks to resources when idle", "AutoFarm", 6)
    mkToggle(UT, "⏱️", "Fast Respawn", "Respawn in 1s (server-wide)", "FastRespawn", 7, function(on)
        local remote = R("FastRespawnRemote")
        if remote then remote:FireServer(on) end
    end)
    mkToggle(UT, "📦", "Loot Alert", "Pings when rare loot spawns", "LootAlert", 8, setLootAlert)
    mkToggle(UT, "🔔", "Kill Notify", "Toasts + kill streaks 🔥", "KillNotify", 9)
    mkSaveBtn(UT, 100)

    -- VISUAL
    local VS = getTab("Visual")
    mkSection(VS, "── FREE ─────────────────────────────", 0)
    mkToggle(VS, "👤", "Player ESP", "Team color • health bar • distance", "PlayerESP", 1)
    mkToggle(VS, "💡", "Full Bright", "Max brightness everywhere", "FullBright", 2, setFullBright)
    mkToggle(VS, "🔍", "Zoom Hack", "PC: right-click • Mobile: 🔍 btn", "ZoomHack", 3, function(on)
        setZoomButton(on)
        if not on then setZoom(false) end
    end)
    mkSection(VS, "── PREMIUM (free for testing) ─────────", 4)
    mkToggle(VS, "🎨", "Chams", "TEAM-COLORED glow outlines", "Chams", 5, refreshVisualsAll)
    mkToggle(VS, "📐", "Hitboxes", "Team-colored hitbox outlines", "Hitboxes", 6, refreshVisualsAll)
    mkToggle(VS, "⚠️", "Danger Alert", "Flash when enemy behind you", "DangerAlert", 7)
    mkToggle(VS, "🌈", "Rainbow UI", "Animated panel border", "RainbowUI", 8, function(on)
        if not on and _winStroke then _winStroke.Color = BASE_STROKE end
    end)
    mkSaveBtn(VS, 100)

    selectTab("Combat")
    updateStatusPill()
    Win.Visible = not isMobile

    -- ── C12 · CONFIG SYNC ───────────────────────────────────
    local syncRemote = R("ConfigSync")
    if syncRemote then
        syncRemote.OnClientEvent:Connect(function(kind, data)
            if kind == "save_ok" then
                toast("✅ Config saved to your account!", Color3.fromRGB(30,150,70))
            elseif kind == "save_fail" then
                toast("❌ Save failed (enable Studio API access)", Color3.fromRGB(160,60,60))
            elseif kind == "load" and type(data) == "table" then
                for k, v in pairs(data) do
                    if CFG[k] ~= nil then setConfig(k, v) end
                end
                applySpeed()
                setFullBright(CFG.FullBright)
                refreshVisualsAll()
                setLootAlert(CFG.LootAlert)
                setFlyButtons(CFG.Fly)
                setZoomButton(CFG.ZoomHack)
                if CFG.Ghost then local g = R("GhostRemote") if g then g:FireServer(true) end end
                if CFG.FastRespawn then local f = R("FastRespawnRemote") if f then f:FireServer(true) end end
                toast("📂 Config loaded!", Color3.fromRGB(45,70,190))
            end
        end)
        local cfgRemote = R("ConfigRemote")
        if cfgRemote then cfgRemote:FireServer("load") end
    end

    -- ── C13 · MAIN LOOP ─────────────────────────────────────
    RunService.Heartbeat:Connect(function(dt)
        safe(function() tickAimbot() end)
        safe(function() tickKillAura(dt) end)
        safe(function() tickAutoSwing(dt) end)
        safe(function() tickTriggerBot(dt) end)
        safe(function() tickScaffold(dt) end)
        safe(function() tickAutoBridge(dt) end)
        safe(function() tickFly(dt) end)
        safe(function() tickAntiKB(dt) end)
        safe(function() tickNoclip() end)
        safe(function() tickAutoFarm(dt) end)
        safe(function() tickMagnet(dt) end)
        safe(function() tickESP() end)
        safe(function() tickBedESP(dt) end)
        safe(function() tickGenESP(dt) end)
        safe(function() tickRadar() end)
        safe(function() tickDanger(dt) end)
        safe(function() tickRainbow(dt) end)
        safe(function() tickTargetLabel() end)
    end)

    print("[CheatSimulator] PRO edition loaded — smart scaffold, auto chase, sticky aimbot.")

else
-- ############################################################
--  SERVER HALF
-- ############################################################
    local Players           = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local DataStoreService  = game:GetService("DataStoreService")
    local PhysicsService    = game:GetService("PhysicsService")
    local TweenService      = game:GetService("TweenService")

    local MAX_RANGE, MAX_DMG, COOLDOWN = 60, 15, 0.25
    local BLOCK_TEAM_DAMAGE = false
    local RESOURCE_FOLDER   = "Resources"
    local RESOURCE_NAMES    = {"coin","gem","drop","iron","gold","emerald","diamond"}
    local MAGNET_RANGE      = 45
    local DEFAULT_RESPAWN   = 5
    local FAST_RESPAWN      = 1

    local remotes = Instance.new("Folder")
    remotes.Name = "CheatSimRemotes"
    remotes.Parent = ReplicatedStorage
    local function mkRemote(name)
        local r = Instance.new("RemoteEvent")
        r.Name = name
        r.Parent = remotes
        return r
    end
    local DamageRemote      = mkRemote("DamageRemote")
    local GhostRemote       = mkRemote("GhostRemote")
    local FastRespawnRemote = mkRemote("FastRespawnRemote")
    local MagnetRemote      = mkRemote("MagnetRemote")
    local ConfigRemote      = mkRemote("ConfigRemote")
    local ConfigSync        = mkRemote("ConfigSync")

    local lastHit = {}
    DamageRemote.OnServerEvent:Connect(function(player, targetChar, amount)
        if typeof(targetChar) ~= "Instance" or not targetChar:IsA("Model") then return end
        local hum = targetChar:FindFirstChildOfClass("Humanoid")
        local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
        local myHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not (hum and targetHRP and myHRP) or hum.Health <= 0 then return end
        local targetPlayer = Players:GetPlayerFromCharacter(targetChar)
        if targetPlayer == player then return end
        if BLOCK_TEAM_DAMAGE and targetPlayer and targetPlayer.Team ~= nil
            and targetPlayer.Team == player.Team then return end
        if (targetHRP.Position - myHRP.Position).Magnitude > MAX_RANGE then return end
        local t = os.clock()
        if (lastHit[player] or 0) + COOLDOWN > t then return end
        lastHit[player] = t
        hum:TakeDamage(math.clamp(tonumber(amount) or 0, 0, MAX_DMG))
    end)

    pcall(function()
        PhysicsService:RegisterCollisionGroup("Ghosted")
        PhysicsService:CollisionGroupSetCollidable("Ghosted", "Default", false)
    end)
    local ghosted = {}
    GhostRemote.OnServerEvent:Connect(function(player, on)
        ghosted[player] = on and true or nil
        local char = player.Character
        if not char then return end
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                p.CollisionGroup = on and "Ghosted" or "Default"
            end
        end
    end)

    local fastUsers = {}
    local function syncRespawnTime()
        local any = false
        for _ in pairs(fastUsers) do any = true break end
        Players.RespawnTime = any and FAST_RESPAWN or DEFAULT_RESPAWN
    end
    FastRespawnRemote.OnServerEvent:Connect(function(player, on)
        if on == true then fastUsers[player] = true else fastUsers[player] = nil end
        syncRespawnTime()
    end)

    local pulled = setmetatable({}, {__mode = "k"})
    MagnetRemote.OnServerEvent:Connect(function(player)
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local now = os.clock()
        local container = Workspace:FindFirstChild(RESOURCE_FOLDER) or Workspace
        local scanned = 0
        for _, part in ipairs(container:GetDescendants()) do
            scanned += 1
            if scanned > 3000 then break end
            if part:IsA("BasePart") and not part.Anchored
                and not part:IsDescendantOf(char)
                and (pulled[part] or 0) < now then
                local n = part.Name:lower()
                for _, kw in ipairs(RESOURCE_NAMES) do
                    if n:find(kw) then
                        if (part.Position - hrp.Position).Magnitude <= MAGNET_RANGE then
                            pulled[part] = now + 4
                            TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingStyle.Out),
                                {CFrame = hrp.CFrame * CFrame.new(math.random(-2,2), 0.5, math.random(-2,2))}):Play()
                        end
                        break
                    end
                end
            end
        end
    end)

    local store
    pcall(function() store = DataStoreService:GetDataStore("CheatSim_Configs") end)
    ConfigRemote.OnServerEvent:Connect(function(player, action, data)
        if action == "save" and store and type(data) == "table" then
            local clean = {}
            for k, v in pairs(data) do
                if type(v) == "boolean" or type(v) == "number" then clean[k] = v end
            end
            local ok = pcall(function() store:SetAsync("p_" .. player.UserId, clean) end)
            ConfigSync:FireClient(player, ok and "save_ok" or "save_fail")
        elseif action == "load" and store then
            local ok, saved = pcall(function() return store:GetAsync("p_" .. player.UserId) end)
            if ok and type(saved) == "table" then
                ConfigSync:FireClient(player, "load", saved)
            end
        end
    end)

    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(char)
            task.wait(0.3)
            if ghosted[player] then
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.CollisionGroup = "Ghosted" end
                end
            end
        end)
        task.spawn(function()
            local container = player:WaitForChild("PlayerScripts", 30)
                or player:WaitForChild("PlayerGui", 15)
            if not container then return end
            local clone = script:Clone()
            clone.Name = "CheatSimClient"
            clone.RunContext = Enum.RunContext.Client
            clone.Parent = container
        end)
    end)
    for _, p in ipairs(Players:GetPlayers()) do
        task.spawn(function()
            local container = p:FindFirstChild("PlayerScripts") or p:FindFirstChild("PlayerGui")
            if container then
                local clone = script:Clone()
                clone.Name = "CheatSimClient"
                clone.RunContext = Enum.RunContext.Client
                clone.Parent = container
            end
        end)
    end

    Players.PlayerRemoving:Connect(function(player)
        lastHit[player] = nil
        ghosted[player] = nil
        if fastUsers[player] then
            fastUsers[player] = nil
            syncRespawnTime()
        end
    end)

    print("[CheatSimulator] Server ready (PRO).")
end
