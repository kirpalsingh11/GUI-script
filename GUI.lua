
-- ⚡ CHEAT SIMULATOR - ULTIMATE NEON RAGE MENU ⚡
-- All features fixed + 10 new super cheats
-- LocalScript in StarterGui

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = Workspace.CurrentCamera

-- ============= NEON COLOR SYSTEM =============
local neonPink = Color3.fromRGB(255, 20, 147)
local neonCyan = Color3.fromRGB(0, 255, 255)
local neonGreen = Color3.fromRGB(57, 255, 20)
local neonPurple = Color3.fromRGB(191, 0, 255)
local neonOrange = Color3.fromRGB(255, 140, 0)
local neonYellow = Color3.fromRGB(255, 255, 0)
local neonRed = Color3.fromRGB(255, 30, 30)
local neonBlue = Color3.fromRGB(30, 144, 255)
local darkBg = Color3.fromRGB(8, 8, 15)
local darkPanel = Color3.fromRGB(12, 12, 22)
local neonColors = {neonPink, neonCyan, neonGreen, neonPurple, neonOrange, neonYellow, neonBlue}

local rainbowIndex = 1
local rainbowEnabled = true

spawn(function()
	while task.wait(0.05) do
		if rainbowEnabled then
			rainbowIndex = rainbowIndex % #neonColors + 1
		end
	end
end)

-- ============= GUI SETUP =============
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NeonCheatMenu"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 370, 0, 460)
mainFrame.Position = UDim2.new(0.5, -185, 0.08, 0)
mainFrame.BackgroundColor3 = darkBg
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui
mainFrame.ClipsDescendants = true

local borderGlow = Instance.new("Frame")
borderGlow.Size = UDim2.new(1, 4, 1, 4)
borderGlow.Position = UDim2.new(0, -2, 0, -2)
borderGlow.BackgroundColor3 = neonPink
borderGlow.BorderSizePixel = 0
borderGlow.BackgroundTransparency = 0.3
borderGlow.Parent = mainFrame
borderGlow.ZIndex = 0

spawn(function()
	while task.wait(0.1) do
		if rainbowEnabled then
			borderGlow.BackgroundColor3 = neonColors[rainbowIndex]
		end
	end
end)

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 34)
titleBar.BackgroundColor3 = darkPanel
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleGlow = Instance.new("Frame")
titleGlow.Size = UDim2.new(1, 0, 0, 2)
titleGlow.Position = UDim2.new(0, 0, 1, 0)
titleGlow.BackgroundColor3 = neonPink
titleGlow.BorderSizePixel = 0
titleGlow.Parent = titleBar

spawn(function()
	while task.wait(0.1) do
		if rainbowEnabled then
			titleGlow.BackgroundColor3 = neonColors[rainbowIndex]
		end
	end
end)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -30, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.Text = "⚡ ULTIMATE CHEAT MENU ⚡"
title.TextColor3 = neonPink
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBlack
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

spawn(function()
	while task.wait(0.1) do
		if rainbowEnabled then
			title.TextColor3 = neonColors[rainbowIndex]
		end
	end
end)

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 26, 0, 26)
closeButton.Position = UDim2.new(1, -30, 0, 4)
closeButton.Text = "✕"
closeButton.BackgroundColor3 = neonRed
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 16
closeButton.BorderSizePixel = 0
closeButton.Parent = mainFrame
Instance.new("UICorner", closeButton).CornerRadius = UDim.new(0, 13)

-- Tab System
local tabs = {}
local tabNames = {"⚔️ Combat", "🔫 Rage", "👁️ Visuals", "🎮 Movement", "🧨 Troll", "😂 Memes", "⚙️ Config"}
local tabPages = {}
local activeTab = 1

local tabContainer = Instance.new("ScrollingFrame")
tabContainer.Size = UDim2.new(1, 0, 0, 32)
tabContainer.Position = UDim2.new(0, 0, 0, 36)
tabContainer.BackgroundColor3 = darkPanel
tabContainer.BorderSizePixel = 0
tabContainer.CanvasSize = UDim2.new(0, #tabNames * 55, 0, 0)
tabContainer.ScrollBarThickness = 0
tabContainer.Parent = mainFrame

for i, name in ipairs(tabNames) do
	local tab = Instance.new("TextButton")
	tab.Size = UDim2.new(0, 50, 1, -2)
	tab.Position = UDim2.new(0, (i-1)*52 + 2, 0, 1)
	tab.Text = name
	tab.BackgroundColor3 = i == 1 and neonPurple or Color3.fromRGB(20, 20, 30)
	tab.TextColor3 = Color3.fromRGB(255, 255, 255)
	tab.Font = Enum.Font.GothamBold
	tab.TextSize = 8
	tab.BorderSizePixel = 0
	tab.Parent = tabContainer
	Instance.new("UICorner", tab).CornerRadius = UDim.new(0, 4)
	
	local page = Instance.new("ScrollingFrame")
	page.Size = UDim2.new(1, -6, 1, -74)
	page.Position = UDim2.new(0, 3, 0, 70)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.CanvasSize = UDim2.new(0, 0, 0, 900)
	page.ScrollBarThickness = 4
	page.ScrollBarImageColor3 = neonPurple
	page.Visible = (i == 1)
	page.Parent = mainFrame
	tabPages[i] = page
	
	tab.MouseButton1Click:Connect(function()
		for j, t in ipairs(tabs) do
			t.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
			tabPages[j].Visible = false
		end
		tab.BackgroundColor3 = neonPurple
		page.Visible = true
		activeTab = i
	end)
	
	tabs[i] = tab
end

-- ============= HELPER FUNCTIONS =============
local yOffsets = {}

local function getY(pageNum)
	if not yOffsets[pageNum] then yOffsets[pageNum] = 5 end
	local y = yOffsets[pageNum]
	yOffsets[pageNum] = y + 28
	return y
end

local function addSection(pageNum, text)
	local y = getY(pageNum) + 5
	local section = Instance.new("Frame")
	section.Size = UDim2.new(1, -10, 0, 20)
	section.Position = UDim2.new(0, 5, 0, y)
	section.BackgroundColor3 = neonPurple
	section.BackgroundTransparency = 0.7
	section.BorderSizePixel = 0
	section.Parent = tabPages[pageNum]
	Instance.new("UICorner", section).CornerRadius = UDim.new(0, 3)
	
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 1, 0)
	lbl.Text = text
	lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 10
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Position = UDim2.new(0, 8, 0, 0)
	lbl.Parent = section
	
	yOffsets[pageNum] = yOffsets[pageNum] + 10
	return y
end

local function addToggle(pageNum, text, y, default, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 24)
	btn.Position = UDim2.new(0, 5, 0, y)
	btn.Text = "  " .. (default and "✅" or "❌") .. "  " .. text
	btn.BackgroundColor3 = default and Color3.fromRGB(20, 40, 20) or Color3.fromRGB(40, 15, 15)
	btn.TextColor3 = default and neonGreen or neonRed
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 10
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.BorderSizePixel = 0
	btn.Parent = tabPages[pageNum]
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
	
	local state = default
	btn.MouseButton1Click:Connect(function()
		state = not state
		btn.Text = "  " .. (state and "✅" or "❌") .. "  " .. text
		btn.BackgroundColor3 = state and Color3.fromRGB(20, 40, 20) or Color3.fromRGB(40, 15, 15)
		btn.TextColor3 = state and neonGreen or neonRed
		if callback then callback(state) end
	end)
	return function() return state end
end

local function addSlider(pageNum, text, min, max, step, default, y, callback)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -10, 0, 14)
	lbl.Position = UDim2.new(0, 5, 0, y)
	lbl.Text = text .. ": " .. default
	lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 9
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = tabPages[pageNum]
	
	local bg = Instance.new("TextButton")
	bg.Size = UDim2.new(1, -10, 0, 5)
	bg.Position = UDim2.new(0, 5, 0, y + 15)
	bg.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
	bg.BorderSizePixel = 0
	bg.Text = ""
	bg.Parent = tabPages[pageNum]
	Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 2)
	
	local fill = Instance.new("Frame")
	fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
	fill.BackgroundColor3 = neonPurple
	fill.BorderSizePixel = 0
	fill.Parent = bg
	
	local value = default
	bg.MouseButton1Click:Connect(function()
		value = value + step
		if value > max then value = min end
		lbl.Text = text .. ": " .. value
		fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
		if callback then callback(value) end
	end)
	
	return function() return value end
end

local function addButton(pageNum, text, y, color, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 24)
	btn.Position = UDim2.new(0, 5, 0, y)
	btn.Text = text
	btn.BackgroundColor3 = color or neonPurple
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 10
	btn.BorderSizePixel = 0
	btn.Parent = tabPages[pageNum]
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
	
	btn.MouseButton1Click:Connect(callback or function() end)
	return btn
end

local function addKeybind(pageNum, text, y, defaultKey, callback)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0.5, -5, 0, 20)
	lbl.Position = UDim2.new(0, 5, 0, y)
	lbl.Text = text
	lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 9
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = tabPages[pageNum]
	
	local bindBtn = Instance.new("TextButton")
	bindBtn.Size = UDim2.new(0.5, -5, 0, 20)
	bindBtn.Position = UDim2.new(0.5, 5, 0, y)
	bindBtn.Text = defaultKey or "[ NONE ]"
	bindBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
	bindBtn.TextColor3 = neonCyan
	bindBtn.Font = Enum.Font.GothamBold
	bindBtn.TextSize = 9
	bindBtn.BorderSizePixel = 0
	bindBtn.Parent = tabPages[pageNum]
	Instance.new("UICorner", bindBtn).CornerRadius = UDim.new(0, 3)
	
	local currentKey = defaultKey
	local listening = false
	
	bindBtn.MouseButton1Click:Connect(function()
		listening = true
		bindBtn.Text = "[ ... ]"
		bindBtn.TextColor3 = neonYellow
	end)
	
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if listening and input.KeyCode ~= Enum.KeyCode.Unknown then
			currentKey = input.KeyCode.Name
			bindBtn.Text = "[" .. currentKey .. "]"
			bindBtn.TextColor3 = neonCyan
			listening = false
			if callback then callback(currentKey) end
		end
	end)
	
	return function() return currentKey end
end

-- ============= STATE VARIABLES =============
-- Kill Aura
local kaEnabled = true
local kaRange = 15
local kaDamage = 25
local kaThroughWalls = false

-- Silent Aim
local saEnabled = true
local saHitParts = {"Head", "HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso"}
local saHitIndex = 1
local saFOV = 120
local saWallCheck = true

-- Triggerbot
local tbEnabled = false
local tbDelay = 0.1

-- Spinbot
local sbEnabled = false
local sbSpeed = 10

-- Speed Hack
local shEnabled = false
local shSpeed = 50
local shOriginalSpeed = 16

-- Fly
local flyEnabled = false
local flySpeed = 50
local flyAlignPos, flyAlignOri, flyAttach0, flyAttach1 = nil, nil, nil, nil

-- Infinite Jump
local infJumpEnabled = false

-- God Mode
local godEnabled = false

-- ESP
local espEnabled = true
local espBoxes = true
local espNames = true
local espTracers = false
local espHealth = true
local espDistance = 1000

-- FOV Changer
local fovEnabled = false
local fovValue = 90
local originalFOV = 70

-- Chat Spammer
local spamEnabled = false
local spamMessages = {"?", "lol", "nice cheat", "imagine dying", "skill issue", "💀", "L + ratio", "cope", "cheat simulator > life", "stay mad"}
local spamIndex = 1

-- Fake Lag
local lagEnabled = false
local lagAmount = 0.2

-- Streamer Mode
local streamerMode = false

-- ============= NEW FEATURES STATE =============
-- 1. Teleport
local teleportEnabled = false
local teleportTarget = nil

-- 2. Anti-Aim (makes enemies miss)
local antiAimEnabled = false
local antiAimAngle = 0

-- 3. Rapid Fire
local rapidFireEnabled = false
local rapidFireRate = 0.05

-- 4. Aimbot FOV Circle (visual FOV indicator)
local fovCircleEnabled = false

-- 5. Auto Respawn
local autoRespawnEnabled = false

-- 6. NoClip
local noclipEnabled = false

-- 7. Reach (extended hit distance)
local reachEnabled = false
local reachDistance = 20

-- 8. Anti-Kick (fake)
local antiKickEnabled = false

-- 9. ESP Chams (see through walls material)
local chamsEnabled = false

-- 10. Server Hop
local serverHopEnabled = false

-- Keybinds
local keybinds = {}

-- Report Count
local reportCount = 0

-- ============= TAB 1: COMBAT =============
addSection(1, "⚔️ KILL AURA")
addToggle(1, "Kill Aura", getY(1), true, function(s) kaEnabled = s end)
addSlider(1, "Range", 5, 100, 5, 15, getY(1), function(v) kaRange = v end)
addSlider(1, "Damage", 5, 500, 5, 25, getY(1), function(v) kaDamage = v end)
addToggle(1, "Through Walls", getY(1), false, function(s) kaThroughWalls = s end)
addKeybind(1, "KA Key", getY(1), "K", function(key) keybinds["KillAura"] = key end)

addSection(1, "🎯 TRIGGERBOT")
addToggle(1, "Triggerbot", getY(1), false, function(s) tbEnabled = s end)
addSlider(1, "Delay (ms)", 0, 500, 25, 100, getY(1), function(v) tbDelay = v / 1000 end)

addSection(1, "🔫 RAPID FIRE")
addToggle(1, "Rapid Fire", getY(1), false, function(s) rapidFireEnabled = s end)
addSlider(1, "Fire Rate (s)", 0.01, 0.5, 0.01, 0.05, getY(1), function(v) rapidFireRate = v end)

addSection(1, "📏 REACH")
addToggle(1, "Reach Hack", getY(1), false, function(s) reachEnabled = s end)
addSlider(1, "Reach Distance", 15, 500, 5, 20, getY(1), function(v) reachDistance = v end)

addSection(1, "💀 GOD MODE")
addToggle(1, "God Mode", getY(1), false, function(s) godEnabled = s end)

addSection(1, "🔄 AUTO RESPAWN")
addToggle(1, "Auto Respawn", getY(1), false, function(s) autoRespawnEnabled = s end)

-- ============= TAB 2: RAGE =============
addSection(2, "🔫 SILENT AIM")
addToggle(2, "Silent Aim", getY(2), true, function(s) saEnabled = s end)

local saHitPartLabel = Instance.new("TextLabel")
saHitPartLabel.Size = UDim2.new(1, -10, 0, 14)
saHitPartLabel.Position = UDim2.new(0, 5, 0, getY(2))
saHitPartLabel.Text = "Hit Part: Head"
saHitPartLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
saHitPartLabel.BackgroundTransparency = 1
saHitPartLabel.Font = Enum.Font.Gotham
saHitPartLabel.TextSize = 10
saHitPartLabel.TextXAlignment = Enum.TextXAlignment.Left
saHitPartLabel.Parent = tabPages[2]

addButton(2, "Cycle Hit Part ▶", getY(2), neonCyan, function()
	saHitIndex = saHitIndex + 1
	if saHitIndex > #saHitParts then saHitIndex = 1 end
	saHitPartLabel.Text = "Hit Part: " .. saHitParts[saHitIndex]
end)
addSlider(2, "FOV", 30, 360, 10, 120, getY(2), function(v) saFOV = v end)
addToggle(2, "Wall Check", getY(2), true, function(s) saWallCheck = s end)

addSection(2, "🌀 SPINBOT")
addToggle(2, "Spinbot", getY(2), false, function(s) sbEnabled = s end)
addSlider(2, "Spin Speed", 1, 50, 1, 10, getY(2), function(v) sbSpeed = v end)

addSection(2, "🛡️ ANTI-AIM")
addToggle(2, "Anti-Aim", getY(2), false, function(s) antiAimEnabled = s end)

addSection(2, "🚫 ANTI-KICK (FAKE)")
addToggle(2, "Anti-Kick", getY(2), false, function(s) antiKickEnabled = s end)

addSection(2, "🌐 SERVER HOP")
addToggle(2, "Server Hop", getY(2), false, function(s)
	serverHopEnabled = s
	if s then
		StarterGui:SetCore("SendNotification", {
			Title = "🌐 Server Hop",
			Text = "Searching for new server...",
			Duration = 2,
		})
		task.wait(2)
		pcall(function()
			TeleportService:Teleport(game.PlaceId, player)
		end)
	end
end)

-- ============= TAB 3: VISUALS =============
addSection(3, "👁️ ESP")
addToggle(3, "ESP Master", getY(3), true, function(s) espEnabled = s end)
addToggle(3, "Boxes", getY(3), true, function(s) espBoxes = s end)
addToggle(3, "Names", getY(3), true, function(s) espNames = s end)
addToggle(3, "Tracers", getY(3), false, function(s) espTracers = s end)
addToggle(3, "Health Bars", getY(3), true, function(s) espHealth = s end)
addSlider(3, "Max Distance", 100, 5000, 100, 1000, getY(3), function(v) espDistance = v end)

addSection(3, "👻 CHAMS (WALLHACK)")
addToggle(3, "Chams", getY(3), false, function(s) chamsEnabled = s end)

addSection(3, "📷 FOV CHANGER")
addToggle(3, "FOV Changer", getY(3), false, function(s)
	fovEnabled = s
	camera.FieldOfView = s and fovValue or originalFOV
end)
addSlider(3, "FOV Value", 30, 180, 5, 90, getY(3), function(v)
	fovValue = v
	if fovEnabled then camera.FieldOfView = v end
end)

addSection(3, "🎯 AIMBOT FOV CIRCLE")
addToggle(3, "FOV Circle", getY(3), false, function(s) fovCircleEnabled = s end)

addSection(3, "🌈 NEON MENU")
addToggle(3, "Rainbow Mode", getY(3), true, function(s) rainbowEnabled = s end)

addSection(3, "📺 STREAMER MODE")
addToggle(3, "Streamer Mode", getY(3), false, function(s)
	streamerMode = s
	screenGui.Enabled = not s
end)

-- ============= TAB 4: MOVEMENT =============
addSection(4, "⚡ SPEED HACK")
addToggle(4, "Speed Hack", getY(4), false, function(s)
	shEnabled = s
	local char = player.Character
	if char then
		local hum = char:FindFirstChild("Humanoid")
		if hum then
			if s then shOriginalSpeed = hum.WalkSpeed; hum.WalkSpeed = shSpeed
			else hum.WalkSpeed = shOriginalSpeed end
		end
	end
end)
addSlider(4, "Speed", 20, 200, 5, 50, getY(4), function(v)
	shSpeed = v
	if shEnabled and player.Character then
		local hum = player.Character:FindFirstChild("Humanoid")
		if hum then hum.WalkSpeed = v end
	end
end)

addSection(4, "🕊️ FLY")
addToggle(4, "Fly", getY(4), false, function(s)
	flyEnabled = s
	if s then enableFly() else disableFly() end
end)
addSlider(4, "Fly Speed", 10, 200, 10, 50, getY(4), function(v) flySpeed = v end)

addSection(4, "🐇 INFINITE JUMP")
addToggle(4, "Infinite Jump", getY(4), false, function(s) infJumpEnabled = s end)

addSection(4, "🚀 NOCLIP")
addToggle(4, "NoClip", getY(4), false, function(s)
	noclipEnabled = s
	if player.Character then
		local hum = player.Character:FindFirstChild("Humanoid")
		if hum then hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, not s) end
		for _, part in ipairs(player.Character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = not s
			end
		end
	end
end)

addSection(4, "📍 TELEPORT")
addToggle(4, "Click Teleport", getY(4), false, function(s) teleportEnabled = s end)

-- ============= TAB 5: TROLL =============
addSection(5, "💬 CHAT SPAMMER")
addToggle(5, "Chat Spammer", getY(5), false, function(s) spamEnabled = s end)
addButton(5, "Add Custom Message", getY(5), neonOrange, function()
	table.insert(spamMessages, "custom spam " .. #spamMessages)
end)

addSection(5, "🎵 SOUND SPAM")
local soundSpamEnabled = false
local spamSoundId = "rbxassetid://9120386436" -- Default annoying sound
addToggle(5, "Sound Spam", getY(5), false, function(s)
	soundSpamEnabled = s
	if not s then
		for _, v in ipairs(Workspace:GetDescendants()) do
			if v:IsA("Sound") and v.Name == "SpamSound" then v:Destroy() end
		end
	end
end)

addSection(5, "💥 EXPLODE ALL")
addButton(5, "Explode Everyone", getY(5), neonRed, function()
	for _, target in ipairs(Players:GetPlayers()) do
		if target == player then continue end
		local char = target.Character
		if char then
			local root = char:FindFirstChild("HumanoidRootPart")
			if root then
				local explosion = Instance.new("Explosion")
				explosion.Position = root.Position
				explosion.BlastRadius = 15
				explosion.BlastPressure = 500000
				explosion.DestroyJointRadiusPercent = 0
				explosion.Parent = Workspace
			end
		end
	end
	StarterGui:SetCore("SendNotification", {
		Title = "💥 EXPLOSION",
		Text = "Everyone exploded. Oops.",
		Duration = 3,
	})
end)

addSection(5, "🥶 FREEZE ALL")
addButton(5, "Freeze Everyone", getY(5), neonCyan, function()
	for _, target in ipairs(Players:GetPlayers()) do
		if target == player then continue end
		local char = target.Character
		if char then
			local root = char:FindFirstChild("HumanoidRootPart")
			if root then
				root.Anchored = true
				task.wait(3)
				root.Anchored = false
			end
		end
	end
	StarterGui:SetCore("SendNotification", {
		Title = "🥶 FREEZE",
		Text = "Everyone frozen for 3 seconds!",
		Duration = 3,
	})
end)

addSection(5, "🔥 FLING ALL")
addButton(5, "Fling Everyone", getY(5), neonOrange, function()
	for _, target in ipairs(Players:GetPlayers()) do
		if target == player then continue end
		local char = target.Character
		if char then
			local root = char:FindFirstChild("HumanoidRootPart")
			if root then
				local bv = Instance.new("BodyVelocity")
				bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
				bv.Velocity = Vector3.new(math.random(-500, 500), math.random(200, 500), math.random(-500, 500))
				bv.Parent = root
				game:GetService("Debris"):AddItem(bv, 0.5)
			end
		end
	end
	StarterGui:SetCore("SendNotification", {
		Title = "🔥 FLING",
		Text = "YEET! Everyone go fly!",
		Duration = 3,
	})
end)

addSection(5, "👕 STEAL CLOTHING")
addButton(5, "Steal Everyone's Clothes", getY(5), neonPink, function()
	for _, target in ipairs(Players:GetPlayers()) do
		if target == player then continue end
		local char = target.Character
		if char then
			for _, v in ipairs(char:GetChildren()) do
				if v:IsA("Clothing") or v:IsA("Accessory") then
					v:Destroy()
				end
			end
		end
	end
	StarterGui:SetCore("SendNotification", {
		Title = "👕 STOLEN",
		Text = "Everyone's clothes are gone. Naked server!",
		Duration = 3,
	})
end)

addSection(5, "🪑 SIT ALL")
addButton(5, "Force Sit Everyone", getY(5), neonYellow, function()
	for _, target in ipairs(Players:GetPlayers()) do
		if target == player then continue end
		local char = target.Character
		if char then
			local hum = char:FindFirstChild("Humanoid")
			if hum then hum.Sit = true end
		end
	end
	StarterGui:SetCore("SendNotification", {
		Title = "🪑 SIT DOWN",
		Text = "Everyone take a seat!",
		Duration = 3,
	})
end)

addSection(5, "😱 JUMPSCARE ALL")
addButton(5, "Jumpscare Everyone", getY(5), neonRed, function()
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://4608675390"
	sound.Volume = 10
	sound.Parent = Workspace
	sound:Play()
	game:GetService("Debris"):AddItem(sound, 3)
	
	for _, target in ipairs(Players:GetPlayers()) do
		if target == player then continue end
		StarterGui:SetCore("SendNotification", {
			Title = "👻 BOO!",
			Text = target.Name .. " got jumpscared!",
			Duration = 2,
		})
	end
end)

-- ============= TAB 6: MEMES =============
addSection(6, "📊 REPORT COUNTER")
local reportLabel = Instance.new("TextLabel")
reportLabel.Size = UDim2.new(1, -10, 0, 20)
reportLabel.Position = UDim2.new(0, 5, 0, getY(6))
reportLabel.Text = "Reports: 0"
reportLabel.TextColor3 = neonYellow
reportLabel.BackgroundTransparency = 1
reportLabel.Font = Enum.Font.GothamBold
reportLabel.TextSize = 11
reportLabel.Parent = tabPages[6]

addButton(6, "Simulate Report 💀", getY(6), neonRed, function()
	reportCount = reportCount + 1
	reportLabel.Text = "Reports: " .. reportCount .. " — IMAGINE REPORTING LMAO"
	StarterGui:SetCore("SendNotification", {
		Title = "⚠️ Player Reported You",
		Text = "Someone reported you for cheating! ...in Cheat Simulator. Bruh.",
		Duration = 3,
	})
end)

addSection(6, "❌ FAKE CRASH")
addButton(6, "Crash Server (Fake)", getY(6), neonRed, function()
	StarterGui:SetCore("SendNotification", {
		Title = "💥 CRASHING SERVER...",
		Text = "3... 2... 1... just kidding lol",
		Duration = 4,
	})
end)

addSection(6, "🔓 UNBAN ME")
addButton(6, "Unban Me", getY(6), neonGreen, function()
	StarterGui:SetCore("SendNotification", {
		Title = "🔓 UNBAN REQUEST",
		Text = "lol no. you're banned forever.",
		Duration = 3,
	})
end)

addSection(6, "🏆 TOGGLE SKILL")
addButton(6, "Toggle Skill", getY(6), neonYellow, function()
	kaEnabled = false; saEnabled = false; sbEnabled = false
	shEnabled = false; flyEnabled = false; godEnabled = false
	infJumpEnabled = false; espEnabled = false; tbEnabled = false
	fovEnabled = false; noclipEnabled = false; antiAimEnabled = false
	rapidFireEnabled = false; reachEnabled = false; chamsEnabled = false
	
	if flyEnabled then disableFly() end
	if player.Character then
		local hum = player.Character:FindFirstChild("Humanoid")
		if hum then hum.Health = 0 end
	end
	
	StarterGui:SetCore("SendNotification", {
		Title = "💀 SKILL ACTIVATED",
		Text = "All cheats disabled. You died. Pure skill issue.",
		Duration = 4,
	})
end)

addSection(6, "😈 FAKE LAG")
addToggle(6, "Fake Lag", getY(6), false, function(s) lagEnabled = s end)
addSlider(6, "Lag Amount (s)", 0.05, 2, 0.05, 0.2, getY(6), function(v) lagAmount = v end)

addSection(6, "📋 COPY CONFIG")
addButton(6, "Copy Config to Clipboard", getY(6), neonGreen, function()
	local config = {
		kaEnabled = kaEnabled, kaRange = kaRange, kaDamage = kaDamage,
		saEnabled = saEnabled, saHitIndex = saHitIndex, saFOV = saFOV,
		sbEnabled = sbEnabled, sbSpeed = sbSpeed,
		shEnabled = shEnabled, shSpeed = shSpeed,
		espEnabled = espEnabled, espBoxes = espBoxes, espNames = espNames,
		tbEnabled = tbEnabled, godEnabled = godEnabled,
		fovEnabled = fovEnabled, fovValue = fovValue,
		noclipEnabled = noclipEnabled, reachEnabled = reachEnabled,
		antiAimEnabled = antiAimEnabled, chamsEnabled = chamsEnabled,
		rapidFireEnabled = rapidFireEnabled
	}
	local json = HttpService:JSONEncode(config)
	if setclipboard then
		setclipboard(json)
		StarterGui:SetCore("SendNotification", {
			Title = "📋 COPIED",
			Text = "Config copied to clipboard!",
			Duration = 2,
		})
	end
end)

-- ============= TAB 7: CONFIG =============
addSection(7, "💾 PRESETS")
addButton(7, "Rage Preset (All ON)", getY(7), neonRed, function()
	kaEnabled = true; saEnabled = true; sbEnabled = true
	shEnabled = true; espEnabled = true; tbEnabled = true
	godEnabled = true; kaThroughWalls = true; saWallCheck = false
	kaRange = 100; kaDamage = 500; sbSpeed = 30; shSpeed = 200
	noclipEnabled = true; antiAimEnabled = true; rapidFireEnabled = true
	reachEnabled = true; chamsEnabled = true; flyEnabled = true
	
	if not flyEnabled then flyEnabled = true; enableFly() end
	if player.Character then
		local hum = player.Character:FindFirstChild("Humanoid")
		if hum then hum.WalkSpeed = 200 end
		for _, part in ipairs(player.Character:GetDescendants()) do
			if part:IsA("BasePart") then part.CanCollide = false end
		end
	end
	
	StarterGui:SetCore("SendNotification", {
		Title = "😈 RAGE MODE",
		Text = "Maximum degeneracy. No mercy.",
		Duration = 3,
	})
end)

addButton(7, "Closet Preset (Subtle)", getY(7), neonCyan, function()
	kaEnabled = true; saEnabled = true; sbEnabled = false
	shEnabled = false; espEnabled = true; tbEnabled = false
	godEnabled = false; kaThroughWalls = false; saWallCheck = true
	kaRange = 10; kaDamage = 5; saFOV = 30
	noclipEnabled = false; antiAimEnabled = false; rapidFireEnabled = false
	reachEnabled = false; chamsEnabled = false; flyEnabled = false
	
	disableFly()
	
	StarterGui:SetCore("SendNotification", {
		Title = "🤫 CLOSET MODE",
		Text = "Subtle cheating. They'll never know... probably.",
		Duration = 3,
	})
end)

addButton(7, "Troll Preset", getY(7), neonOrange, function()
	spamEnabled = true; soundSpamEnabled = true; teleportEnabled = true
	lagEnabled = true; antiAimEnabled = true; sbEnabled = true
	sbSpeed = 50
	
	StarterGui:SetCore("SendNotification", {
		Title = "🧌 TROLL MODE",
		Text = "Maximum annoyance activated!",
		Duration = 3,
	})
end)

addButton(7, "Reset All", getY(7), neonRed, function()
	kaEnabled = false; saEnabled = false; sbEnabled = false
	shEnabled = false; espEnabled = false; tbEnabled = false
	godEnabled = false; flyEnabled = false; infJumpEnabled = false
	fovEnabled = false; spamEnabled = false; lagEnabled = false
	noclipEnabled = false; antiAimEnabled = false; rapidFireEnabled = false
	reachEnabled = false; chamsEnabled = false; teleportEnabled = false
	
	disableFly()
	if player.Character then
		local hum = player.Character:FindFirstChild("Humanoid")
		if hum then hum.WalkSpeed = 16 end
		for _, part in ipairs(player.Character:GetDescendants()) do
			if part:IsA("BasePart") then part.CanCollide = true end
		end
	end
	camera.FieldOfView = originalFOV
	
	StarterGui:SetCore("SendNotification", {
		Title = "🔄 RESET",
		Text = "All cheats disabled. Playing legit... like a chump.",
		Duration = 3,
	})
end)

addKeybind(7, "Menu Toggle", getY(7), "RightShift", function(key) keybinds["MenuToggle"] = key end)

-- ============= CORE LOGIC =============

-- Wall Check Utility
local function isWallBetween(pos1, pos2, ignoreList)
	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = ignoreList or {player.Character}
	rayParams.FilterType = Enum.RaycastFilterType.Blacklist
	local rayResult = Workspace:Raycast(pos1, (pos2 - pos1).Unit * (pos2 - pos1).Magnitude, rayParams)
	return rayResult ~= nil
end

-- FLY SYSTEM (FIXED)
function enableFly()
	local char = player.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChild("Humanoid")
	if not root or not hum then return end
	
	hum.PlatformStand = true
	
	flyAttach0 = Instance.new("Attachment")
	flyAttach0.Parent = root
	flyAttach1 = Instance.new("Attachment")
	flyAttach1.Parent = root
	
	flyAlignPos = Instance.new("AlignPosition")
	flyAlignPos.Attachment0 = flyAttach0
	flyAlignPos.MaxForce = 1000000
	flyAlignPos.MaxVelocity = 1000000
	flyAlignPos.Responsiveness = 200
	flyAlignPos.RigidityEnabled = false
	flyAlignPos.Parent = root
	
	flyAlignOri = Instance.new("AlignOrientation")
	flyAlignOri.Attachment0 = flyAttach1
	flyAlignOri.MaxTorque = 1000000
	flyAlignOri.MaxAngularVelocity = 1000000
	flyAlignOri.Responsiveness = 200
	flyAlignOri.RigidityEnabled = false
	flyAlignOri.Parent = root
	
	spawn(flyLoop)
end

function disableFly()
	if flyAlignPos then flyAlignPos:Destroy(); flyAlignPos = nil end
	if flyAlignOri then flyAlignOri:Destroy(); flyAlignOri = nil end
	if flyAttach0 then flyAttach0:Destroy(); flyAttach0 = nil end
	if flyAttach1 then flyAttach1:Destroy(); flyAttach1 = nil end
	
	if player.Character then
		local hum = player.Character:FindFirstChild("Humanoid")
		if hum then hum.PlatformStand = false end
	end
end

function flyLoop()
	while flyEnabled and flyAlignPos and flyAlignOri and task.wait() do
		local char = player.Character
		if not char then break end
		local root = char:FindFirstChild("HumanoidRootPart")
		if not root then break end
		
		local direction = Vector3.zero
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction += camera.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction -= camera.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction -= camera.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction += camera.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction += Vector3.new(0, 1, 0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then direction -= Vector3.new(0, 1, 0) end
		
		flyAlignPos.Position = root.Position + direction * flySpeed * 0.15
		flyAlignOri.CFrame = camera.CFrame
	end
end

-- Get Best Target for Silent Aim
local function getBestSATarget()
	local closest = nil
	local closestAngle = saFOV
	
	for _, target in ipairs(Players:GetPlayers()) do
		if target == player then continue end
		local char = target.Character
		if not char then continue end
		local hum = char:FindFirstChild("Humanoid")
		if not hum or hum.Health <= 0 then continue end
		local targetPart = char:FindFirstChild(saHitParts[saHitIndex])
		if not targetPart then continue end
		
		if saWallCheck then
			if isWallBetween(camera.CFrame.Position, targetPart.Position, {player.Character}) then continue end
		end
		
		local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
		if not onScreen then continue end
		local mousePos = Vector2.new(mouse.X, mouse.Y)
		local targetPos = Vector2.new(screenPos.X, screenPos.Y)
		local dist = (mousePos - targetPos).Magnitude
		local angle = (dist / camera.ViewportSize.X) * camera.FieldOfView
		
		if angle < closestAngle then
			closestAngle = angle
			closest = targetPart
		end
	end
	return closest
end

-- Kill Aura
RunService.Heartbeat:Connect(function()
	if not kaEnabled then return end
	local char = player.Character
	if not char then return end
	local hum = char:FindFirstChild("Humanoid")
	if not hum or hum.Health <= 0 then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	
	for _, target in ipairs(Players:GetPlayers()) do
		if target == player then continue end
		local tChar = target.Character
		if not tChar then continue end
		local tHum = tChar:FindFirstChild("Humanoid")
		if not tHum or tHum.Health <= 0 then continue end
		local tRoot = tChar:FindFirstChild("HumanoidRootPart")
		if not tRoot then continue end
		
		local dist = (root.Position - tRoot.Position).Magnitude
		if dist > kaRange then continue end
		if not kaThroughWalls and isWallBetween(root.Position, tRoot.Position, {char, tChar}) then continue end
		
		tHum:TakeDamage(kaDamage)
	end
end)

-- Spinbot + Anti-Aim
RunService.RenderStepped:Connect(function()
	local char = player.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	
	if sbEnabled then
		root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(sbSpeed), 0)
	end
	
	if antiAimEnabled then
		antiAimAngle = antiAimAngle + 15
		root.CFrame = root.CFrame * CFrame.Angles(math.rad(math.sin(antiAimAngle / 10) * 45), 0, math.rad(math.cos(antiAimAngle / 10) * 45))
	end
end)

-- God Mode
RunService.Heartbeat:Connect(function()
	if not godEnabled then return end
	local char = player.Character
	if not char then return end
	local hum = char:FindFirstChild("Humanoid")
	if hum and hum.Health < hum.MaxHealth then
		hum.Health = hum.MaxHealth
	end
end)

-- Auto Respawn
player.CharacterAdded:Connect(function(char)
	local hum = char:WaitForChild("Humanoid")
	hum.Died:Connect(function()
		if autoRespawnEnabled then
			task.wait(0.5)
			pcall(function()
				player:LoadCharacter()
			end)
		end
	end)
	
	if shEnabled then
		hum.WalkSpeed = shSpeed
	end
	
	if noclipEnabled then
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") then part.CanCollide = false end
		end
	end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
	if infJumpEnabled and player.Character then
		local hum = player.Character:FindFirstChild("Humanoid")
		if hum then
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)

-- Silent Aim (metatable hook)
local oldNamecall, oldIndex
local mt = getrawmetatable(game)
oldNamecall = mt.__namecall
oldIndex = mt.__index
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
	local method = getnamecallmethod()
	local args = {...}
	
	if method == "FireServer" and saEnabled then
		local targetPart = getBestSATarget()
		if targetPart then
			for i, arg in ipairs(args) do
				if typeof(arg) == "Vector3" then
					args[i] = targetPart.Position
					break
				end
			end
			return oldNamecall(self, unpack(args))
		end
	end
	
	return oldNamecall(self, ...)
end)

setreadonly(mt, true)

-- Triggerbot
local tbLastShot = 0
RunService.RenderStepped:Connect(function()
	if not tbEnabled then return end
	if tick() - tbLastShot < tbDelay then return end
	
	local targetPart = getBestSATarget()
	if targetPart then
		tbLastShot = tick()
		mouse1click()
	end
end)

function mouse1click()
	mouse1press(true)
	task.wait(0.05)
	mouse1press(false)
end

function mouse1press(down)
	pcall(function()
		game:GetService("VirtualInputManager"):SendMouseButtonEvent(mouse.X, mouse.Y, 0, down, game, 0)
	end)
end

-- Rapid Fire
RunService.RenderStepped:Connect(function()
	if not rapidFireEnabled then return end
	if not UserInputService:IsMouseButtonPressed(0) then return end
	
	task.wait(rapidFireRate)
	mouse1click()
end)

-- Teleport
mouse.Button1Down:Connect(function()
	if not teleportEnabled then return end
	if not player.Character then return end
	local root = player.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	
	local mouseHit = mouse.Hit
	if mouseHit then
		root.CFrame = CFrame.new(mouseHit.Position + Vector3.new(0, 3, 0))
	end
end)

-- FOV Circle
local fovCircleDrawing = nil
RunService.RenderStepped:Connect(function()
	if fovCircleDrawing then fovCircleDrawing:Remove(); fovCircleDrawing = nil end
	
	if not fovCircleEnabled then return end
	
	fovCircleDrawing = Drawing.new("Circle")
	fovCircleDrawing.Visible = true
	fovCircleDrawing.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
	fovCircleDrawing.Radius = (saFOV / camera.FieldOfView) * (camera.ViewportSize.X / 2)
	fovCircleDrawing.Color = neonPink
	fovCircleDrawing.Thickness = 1.5
	fovCircleDrawing.Filled = false
	fovCircleDrawing.Transparency = 0.5
end)

-- ESP (GUI Fallback)
local espGuiFolder = Instance.new("Folder")
espGuiFolder.Name = "ESPFolder"
espGuiFolder.Parent = screenGui
local espBillboards = {}

RunService.RenderStepped:Connect(function()
	for _, billboard in pairs(espBillboards) do
		pcall(function() billboard:Destroy() end)
	end
	espBillboards = {}
	
	if not espEnabled then return end
	if streamerMode then return end
	
	for _, target in ipairs(Players:GetPlayers()) do
		if target == player then continue end
		local char = target.Character
		if not char then continue end
		local hum = char:FindFirstChild("Humanoid")
		if not hum or hum.Health <= 0 then continue end
		local head = char:FindFirstChild("Head")
		local root = char:FindFirstChild("HumanoidRootPart")
		if not head or not root then continue end
		
		local headPos, onScreen = camera:WorldToViewportPoint(head.Position)
		if not onScreen then continue end
		
		local dist = (camera.CFrame.Position - root.Position).Magnitude
		if dist > espDistance then continue end
		
		local scale = math.clamp(200 / dist, 0.5, 2)
		
		if espBoxes then
			local boxSize = Vector2.new(45 * scale, 75 * scale)
			local boxPos = Vector2.new(headPos.X - boxSize.X/2, headPos.Y - boxSize.Y/2)
			
			local outline = Instance.new("Frame")
			outline.Size = UDim2.new(0, boxSize.X, 0, boxSize.Y)
			outline.Position = UDim2.new(0, boxPos.X, 0, boxPos.Y)
			outline.BackgroundColor3 = neonPink
			outline.BackgroundTransparency = 0.5
			outline.BorderSizePixel = 0
			outline.Parent = espGuiFolder
			
			local inner = Instance.new("Frame")
			inner.Size = UDim2.new(1, -2, 1, -2)
			inner.Position = UDim2.new(0, 1, 0, 1)
			inner.BackgroundTransparency = 1
			inner.BorderSizePixel = 1
			inner.BorderColor3 = neonPink
			inner.Parent = outline
			
			table.insert(espBillboards, outline)
		end
		
		if espNames then
			local nameLabel = Instance.new("TextLabel")
			nameLabel.Size = UDim2.new(0, 100 * scale, 0, 16 * scale)
			nameLabel.Position = UDim2.new(0, headPos.X - 50 * scale, 0, headPos.Y - 55 * scale)
			nameLabel.Text = target.Name
			nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			nameLabel.BackgroundTransparency = 1
			nameLabel.Font = Enum.Font.GothamBold
			nameLabel.TextSize = 12 * scale
			nameLabel.TextStrokeTransparency = 0
			nameLabel.Parent = espGuiFolder
			table.insert(espBillboards, nameLabel)
		end
		
		if espTracers then
			local tracer = Instance.new("Frame")
			local startPos = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y)
			local endPos = Vector2.new(headPos.X, headPos.Y)
			local midPoint = (startPos + endPos) / 2
			local length = (startPos - endPos).Magnitude
			local angle = math.atan2(endPos.Y - startPos.Y, endPos.X - startPos.X)
			
			tracer.Size = UDim2.new(0, length, 0, 1)
			tracer.Position = UDim2.new(0, midPoint.X - length/2, 0, midPoint.Y)
			tracer.Rotation = math.deg(angle)
			tracer.BackgroundColor3 = neonCyan
			tracer.BorderSizePixel = 0
			tracer.BackgroundTransparency = 0.5
			tracer.Parent = espGuiFolder
			table.insert(espBillboards, tracer)
		end
		
		if espHealth then
			local hp = hum.Health / hum.MaxHealth
			local bw, bh = 4 * scale, 75 * scale
			local bx, by = headPos.X - 27 * scale, headPos.Y - bh/2
			
			local bg = Instance.new("Frame")
			bg.Size = UDim2.new(0, bw, 0, bh)
			bg.Position = UDim2.new(0, bx, 0, by)
			bg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
			bg.BorderSizePixel = 0
			bg.Parent = espGuiFolder
			table.insert(espBillboards, bg)
			
			local bar = Instance.new("Frame")
			bar.Size = UDim2.new(0, bw, hp, 0)
			bar.Position = UDim2.new(0, 0, 1 - hp, 0)
			bar.BackgroundColor3 = Color3.fromRGB(0, 255, 0):Lerp(Color3.fromRGB(255, 0, 0), 1 - hp)
			bar.BorderSizePixel = 0
			bar.Parent = bg
		end
	end
end)

-- Chams (Highlight through walls)
RunService.RenderStepped:Connect(function()
	if not chamsEnabled then return end
	
	for _, target in ipairs(Players:GetPlayers()) do
		if target == player then continue end
		local char = target.Character
		if not char then continue end
		
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") and part.Transparency >= 0 then
				local highlight = part:FindFirstChildOfClass("Highlight")
				if not highlight then
					highlight = Instance.new("Highlight")
					highlight.FillColor = neonPink
					highlight.OutlineColor = neonCyan
					highlight.FillTransparency = 0.5
					highlight.OutlineTransparency = 0
					highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					highlight.Parent = part
				end
			end
		end
	end
end)

-- Sound Spam
spawn(function()
	while task.wait(1) do
		if soundSpamEnabled then
			for _, target in ipairs(Players:GetPlayers()) do
				if target == player then continue end
				local char = target.Character
				if char and char:FindFirstChild("Head") then
					local sound = Instance.new("Sound")
					sound.SoundId = spamSoundId
					sound.Volume = 3
					sound.Parent = char.Head
					sound:Play()
					game:GetService("Debris"):AddItem(sound, 2)
				end
			end
		end
	end
end)

-- Chat Spammer (Legacy + Modern)
spawn(function()
	while task.wait(2) do
		if spamEnabled and player.Character then
			local hum = player.Character:FindFirstChild("Humanoid")
			if hum and hum.Health > 0 then
				local msg = spamMessages[spamIndex]
				spamIndex = spamIndex % #spamMessages + 1
				
				pcall(function()
					ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
				end)
				pcall(function()
					local chatService = game:GetService("TextChatService")
					if chatService.ChatInputBarConfiguration.TargetTextChannel then
						chatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(msg)
					end
				end)
			end
		end
	end
end)

-- Fake Lag
spawn(function()
	while task.wait() do
		if lagEnabled then
			task.wait(lagAmount)
		end
	end
end)

-- Anti-Kick (fake messages)
spawn(function()
	while task.wait(30) do
		if antiKickEnabled then
			StarterGui:SetCore("SendNotification", {
				Title = "🛡️ Anti-Kick",
				Text = "Blocked kick attempt. You're safe.",
				Duration = 2,
			})
		end
	end
end)

-- Keybind Handler
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	for action, key in pairs(keybinds) do
		if input.KeyCode == Enum.KeyCode[key] then
			if action == "KillAura" then
				kaEnabled = not kaEnabled
				StarterGui:SetCore("SendNotification", {
					Title = "⚡ Kill Aura",
					Text = kaEnabled and "ON" or "OFF",
					Duration = 1,
				})
			elseif action == "MenuToggle" then
				mainFrame.Visible = not mainFrame.Visible
			end
		end
	end
end)

-- Cleanup
local function cleanup()
	pcall(function()
		local mt = getrawmetatable(game)
		setreadonly(mt, false)
		mt.__namecall = oldNamecall
		mt.__index = oldIndex
		setreadonly(mt, true)
	end)
	
	for _, d in pairs(espBillboards) do pcall(function() d:Destroy() end) end
	espBillboards = {}
	
	disableFly()
	
	if player.Character then
		local hum = player.Character:FindFirstChild("Humanoid")
		if hum then hum.WalkSpeed = 16; hum.PlatformStand = false end
		for _, part in ipairs(player.Character:GetDescendants()) do
			if part:IsA("BasePart") then part.CanCollide = true end
			local highlight = part:FindFirstChildOfClass("Highlight")
			if highlight then highlight:Destroy() end
		end
	end
	
	for _, v in ipairs(Workspace:GetDescendants()) do
		if v:IsA("Sound") and v.Name == "SpamSound" then v:Destroy() end
	end
	
	camera.FieldOfView = originalFOV
	
	if fovCircleDrawing then fovCircleDrawing:Remove() end
end

closeButton.MouseButton1Click:Connect(function()
	cleanup()
	screenGui:Destroy()
end)
screenGui.Destroying:Connect(cleanup)

-- Init
originalFOV = camera.FieldOfView

print("⚡ ULTIMATE CHEAT MENU LOADED ⚡")
print("7 Tabs | 30+ Features | Fixed Fly + ESP")
print("New: Teleport, Anti-Aim, Rapid Fire, NoClip, Reach, Chams, Server Hop")
print("New: Auto Respawn, Aimbot FOV Circle, Anti-Kick + Troll Features")
print("Explode, Freeze, Fling, Steal Clothes, Force Sit, Jumpscare!")
print("Enjoy the chaos, you absolute menace.")
