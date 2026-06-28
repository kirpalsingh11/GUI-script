-- Cheat Simulator - FULL NEON RAGE MENU (All Features)
-- LocalScript in StarterGui

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")

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

-- Rainbow updater
spawn(function()
	while true do
		if rainbowEnabled then
			rainbowIndex = rainbowIndex % #neonColors + 1
		end
		wait(0.05)
	end
end)

-- ============= GUI SETUP =============
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NeonCheatMenu"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 340, 0, 420)
mainFrame.Position = UDim2.new(0.5, -170, 0.1, 0)
mainFrame.BackgroundColor3 = darkBg
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui
mainFrame.ClipsDescendants = true

-- Neon border glow
local borderGlow = Instance.new("Frame")
borderGlow.Size = UDim2.new(1, 4, 1, 4)
borderGlow.Position = UDim2.new(0, -2, 0, -2)
borderGlow.BackgroundColor3 = neonPink
borderGlow.BorderSizePixel = 0
borderGlow.BackgroundTransparency = 0.3
borderGlow.Parent = mainFrame
borderGlow.ZIndex = 0

spawn(function()
	while rainbowEnabled do
		borderGlow.BackgroundColor3 = neonColors[rainbowIndex]
		wait(0.1)
	end
end)

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = mainFrame

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
	while rainbowEnabled do
		titleGlow.BackgroundColor3 = neonColors[rainbowIndex]
		wait(0.1)
	end
end)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -30, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.Text = "⚡ CHEAT SIMULATOR ⚡"
title.TextColor3 = neonPink
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBlack
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

spawn(function()
	while rainbowEnabled do
		title.TextColor3 = neonColors[rainbowIndex]
		wait(0.1)
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
local tabNames = {"⚔️ Combat", "🔫 Rage", "👁️ Visuals", "😂 Memes", "⚙️ Config"}
local tabPages = {}
local activeTab = 1

local tabContainer = Instance.new("ScrollingFrame")
tabContainer.Size = UDim2.new(1, 0, 0, 32)
tabContainer.Position = UDim2.new(0, 0, 0, 36)
tabContainer.BackgroundColor3 = darkPanel
tabContainer.BorderSizePixel = 0
tabContainer.CanvasSize = UDim2.new(0, #tabNames * 68, 0, 0)
tabContainer.ScrollBarThickness = 0
tabContainer.Parent = mainFrame

for i, name in ipairs(tabNames) do
	local tab = Instance.new("TextButton")
	tab.Size = UDim2.new(0, 64, 1, -2)
	tab.Position = UDim2.new(0, (i-1)*66 + 2, 0, 1)
	tab.Text = name
	tab.BackgroundColor3 = i == 1 and neonPurple or Color3.fromRGB(20, 20, 30)
	tab.TextColor3 = Color3.fromRGB(255, 255, 255)
	tab.Font = Enum.Font.GothamBold
	tab.TextSize = 9
	tab.BorderSizePixel = 0
	tab.Parent = tabContainer
	Instance.new("UICorner", tab).CornerRadius = UDim.new(0, 4)
	
	local page = Instance.new("ScrollingFrame")
	page.Size = UDim2.new(1, -6, 1, -74)
	page.Position = UDim2.new(0, 3, 0, 70)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.CanvasSize = UDim2.new(0, 0, 0, 800)
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
	lbl.TextSize = 11
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
	btn.TextSize = 11
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
	lbl.TextSize = 10
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = tabPages[pageNum]
	
	local bg = Instance.new("TextButton")
	bg.Size = UDim2.new(1, -10, 0, 5)
	bg.Position = UDim2.new(0, 5, 0, y + 16)
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
	btn.Size = UDim2.new(1, -10, 0, 26)
	btn.Position = UDim2.new(0, 5, 0, y)
	btn.Text = text
	btn.BackgroundColor3 = color or neonPurple
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 11
	btn.BorderSizePixel = 0
	btn.Parent = tabPages[pageNum]
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
	
	btn.MouseButton1Click:Connect(callback or function() end)
	return btn
end

local function addKeybind(pageNum, text, y, defaultKey, callback)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0.5, -5, 0, 22)
	lbl.Position = UDim2.new(0, 5, 0, y)
	lbl.Text = text
	lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 10
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = tabPages[pageNum]
	
	local bindBtn = Instance.new("TextButton")
	bindBtn.Size = UDim2.new(0.5, -5, 0, 22)
	bindBtn.Position = UDim2.new(0.5, 5, 0, y)
	bindBtn.Text = defaultKey or "[ NONE ]"
	bindBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
	bindBtn.TextColor3 = neonCyan
	bindBtn.Font = Enum.Font.GothamBold
	bindBtn.TextSize = 10
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
	
	local inputConn
	inputConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
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
local kaTargetLock = false
local kaLockedTarget = nil

-- Silent Aim
local saEnabled = true
local saHitParts = {"Head", "HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso"}
local saHitIndex = 1
local saFOV = 120
local saWallCheck = true

-- Triggerbot
local tbEnabled = false
local tbDelay = 0.1
local tbLastShot = 0

-- Spinbot
local sbEnabled = false
local sbSpeed = 10
local sbAngle = 0

-- Speed Hack
local shEnabled = false
local shSpeed = 50
local shOriginalSpeed = 16

-- Fly
local flyEnabled = false
local flySpeed = 50
local flyBodyGyro = nil
local flyBodyVel = nil

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
local spamMessages = {"?", "lol", "nice cheat", "imagine dying", "skill issue", "💀", "L + ratio", "cope"}
local spamIndex = 1

-- Fake Lag
local lagEnabled = false
local lagAmount = 0.2

-- Streamer Mode
local streamerMode = false

-- Keybinds
local keybinds = {}

-- Report Count
local reportCount = 0

-- ============= TAB 1: COMBAT =============
addSection(1, "⚔️ KILL AURA")
kaEnabled = true
addToggle(1, "Kill Aura", getY(1), true, function(s) kaEnabled = s end)
kaRange = 15
addSlider(1, "Range", 5, 100, 5, 15, getY(1), function(v) kaRange = v end)
kaDamage = 25
addSlider(1, "Damage", 5, 500, 5, 25, getY(1), function(v) kaDamage = v end)
kaThroughWalls = false
addToggle(1, "Through Walls", getY(1), false, function(s) kaThroughWalls = s end)
kaTargetLock = false
addToggle(1, "Target Lock", getY(1), false, function(s) kaTargetLock = s end)
addKeybind(1, "Kill Aura Key", getY(1), "K", function(key) keybinds["KillAura"] = key end)

addSection(1, "🎯 TRIGGERBOT")
tbEnabled = false
addToggle(1, "Triggerbot", getY(1), false, function(s) tbEnabled = s end)
tbDelay = 0.1
addSlider(1, "Delay (ms)", 0, 500, 25, 100, getY(1), function(v) tbDelay = v / 1000 end)
addKeybind(1, "Trigger Key", getY(1), "T", function(key) keybinds["Triggerbot"] = key end)

addSection(1, "💀 GOD MODE")
godEnabled = false
addToggle(1, "God Mode", getY(1), false, function(s) godEnabled = s end)

-- ============= TAB 2: RAGE =============
addSection(2, "🔫 SILENT AIM")
saEnabled = true
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
saFOV = 120
addSlider(2, "FOV", 30, 360, 10, 120, getY(2), function(v) saFOV = v end)
saWallCheck = true
addToggle(2, "Wall Check", getY(2), true, function(s) saWallCheck = s end)

addSection(2, "🌀 SPINBOT")
sbEnabled = false
addToggle(2, "Spinbot", getY(2), false, function(s) sbEnabled = s end)
sbSpeed = 10
addSlider(2, "Spin Speed", 1, 50, 1, 10, getY(2), function(v) sbSpeed = v end)

addSection(2, "⚡ SPEED HACK")
shEnabled = false
addToggle(2, "Speed Hack", getY(2), false, function(s)
	shEnabled = s
	local char = player.Character
	if char then
		local hum = char:FindFirstChild("Humanoid")
		if hum then
			if s then
				shOriginalSpeed = hum.WalkSpeed
				hum.WalkSpeed = shSpeed
			else
				hum.WalkSpeed = shOriginalSpeed
			end
		end
	end
end)
shSpeed = 50
addSlider(2, "Speed", 20, 200, 5, 50, getY(2), function(v)
	shSpeed = v
	if shEnabled and player.Character then
		local hum = player.Character:FindFirstChild("Humanoid")
		if hum then hum.WalkSpeed = v end
	end
end)

addSection(2, "🕊️ FLY")
flyEnabled = false
addToggle(2, "Fly", getY(2), false, function(s)
	flyEnabled = s
	if s then
		enableFly()
	else
		disableFly()
	end
end)
flySpeed = 50
addSlider(2, "Fly Speed", 10, 200, 10, 50, getY(2), function(v) flySpeed = v end)

addSection(2, "🐇 INFINITE JUMP")
infJumpEnabled = false
addToggle(2, "Infinite Jump", getY(2), false, function(s) infJumpEnabled = s end)

-- ============= TAB 3: VISUALS =============
addSection(3, "👁️ ESP")
espEnabled = true
addToggle(3, "ESP Master", getY(3), true, function(s) espEnabled = s end)
espBoxes = true
addToggle(3, "Boxes", getY(3), true, function(s) espBoxes = s end)
espNames = true
addToggle(3, "Names", getY(3), true, function(s) espNames = s end)
espTracers = false
addToggle(3, "Tracers", getY(3), false, function(s) espTracers = s end)
espHealth = true
addToggle(3, "Health Bars", getY(3), true, function(s) espHealth = s end)
espDistance = 1000
addSlider(3, "Max Distance", 100, 5000, 100, 1000, getY(3), function(v) espDistance = v end)

addSection(3, "📷 FOV CHANGER")
fovEnabled = false
addToggle(3, "FOV Changer", getY(3), false, function(s)
	fovEnabled = s
	camera.FieldOfView = s and fovValue or originalFOV
end)
fovValue = 90
addSlider(3, "FOV", 30, 180, 5, 90, getY(3), function(v)
	fovValue = v
	if fovEnabled then camera.FieldOfView = v end
end)

addSection(3, "🌈 NEON MENU")
rainbowEnabled = true
addToggle(3, "Rainbow Mode", getY(3), true, function(s) rainbowEnabled = s end)

addSection(3, "📺 STREAMER MODE")
streamerMode = false
addToggle(3, "Streamer Mode", getY(3), false, function(s)
	streamerMode = s
	screenGui.Enabled = not s
end)

-- ============= TAB 4: MEMES =============
addSection(4, "💬 CHAT SPAMMER")
spamEnabled = false
addToggle(4, "Chat Spammer", getY(4), false, function(s) spamEnabled = s end)
addButton(4, "Add Custom Message", getY(4), neonOrange, function()
	local newMsg = "cheat simulator > your game"
	table.insert(spamMessages, newMsg)
end)

addSection(4, "📊 REPORT COUNTER")
local reportLabel = Instance.new("TextLabel")
reportLabel.Size = UDim2.new(1, -10, 0, 20)
reportLabel.Position = UDim2.new(0, 5, 0, getY(4))
reportLabel.Text = "Reports: 0"
reportLabel.TextColor3 = neonYellow
reportLabel.BackgroundTransparency = 1
reportLabel.Font = Enum.Font.GothamBold
reportLabel.TextSize = 12
reportLabel.Parent = tabPages[4]

addButton(4, "Simulate Report 💀", getY(4), neonRed, function()
	reportCount = reportCount + 1
	reportLabel.Text = "Reports: " .. reportCount .. " — IMAGINE REPORTING LMAO"
	StarterGui:SetCore("SendNotification", {
		Title = "⚠️ Player Reported You",
		Text = "Someone reported you for cheating! ...in Cheat Simulator. Bruh.",
		Duration = 3,
	})
end)

addSection(4, "❌ FAKE CRASH")
addButton(4, "Crash Server (Fake)", getY(4), neonRed, function()
	StarterGui:SetCore("SendNotification", {
		Title = "💥 CRASHING SERVER...",
		Text = "3... 2... 1... just kidding lol",
		Duration = 4,
	})
end)

addSection(4, "🔓 UNBAN ME")
addButton(4, "Unban Me", getY(4), neonGreen, function()
	StarterGui:SetCore("SendNotification", {
		Title = "🔓 UNBAN REQUEST",
		Text = "lol no. you're banned forever.",
		Duration = 3,
	})
end)

addSection(4, "🏆 TOGGLE SKILL")
addButton(4, "Toggle Skill", getY(4), neonYellow, function()
	-- Turn off all cheats
	kaEnabled = false
	saEnabled = false
	sbEnabled = false
	shEnabled = false
	flyEnabled = false
	godEnabled = false
	infJumpEnabled = false
	espEnabled = false
	tbEnabled = false
	fovEnabled = false
	
	if player.Character then
		local hum = player.Character:FindFirstChild("Humanoid")
		if hum then
			hum.Health = 0
		end
	end
	
	StarterGui:SetCore("SendNotification", {
		Title = "💀 SKILL ACTIVATED",
		Text = "All cheats disabled. You died. Pure skill issue.",
		Duration = 4,
	})
end)

addSection(4, "😈 FAKE LAG")
lagEnabled = false
addToggle(4, "Fake Lag", getY(4), false, function(s) lagEnabled = s end)
lagAmount = 0.2
addSlider(4, "Lag Amount (s)", 0.05, 2, 0.05, 0.2, getY(4), function(v) lagAmount = v end)

-- ============= TAB 5: CONFIG =============
addSection(5, "💾 CONFIG SYSTEM")
addButton(5, "Save Config", getY(5), neonGreen, function()
	local config = {
		kaEnabled = kaEnabled, kaRange = kaRange, kaDamage = kaDamage,
		saEnabled = saEnabled, saHitIndex = saHitIndex, saFOV = saFOV,
		sbEnabled = sbEnabled, sbSpeed = sbSpeed,
		shEnabled = shEnabled, shSpeed = shSpeed,
		espEnabled = espEnabled, espBoxes = espBoxes, espNames = espNames,
		tbEnabled = tbEnabled, godEnabled = godEnabled,
		fovEnabled = fovEnabled, fovValue = fovValue,
	}
	local json = HttpService:JSONEncode(config)
	StarterGui:SetCore("SendNotification", {
		Title = "💾 Config Saved",
		Text = "Copy this: " .. json:sub(1, 50) .. "...",
		Duration = 3,
	})
end)

addButton(5, "Rage Preset (All ON)", getY(5), neonRed, function()
	kaEnabled = true; saEnabled = true; sbEnabled = true
	shEnabled = true; espEnabled = true; tbEnabled = true
	godEnabled = true; kaThroughWalls = true; saWallCheck = false
	kaRange = 100; kaDamage = 500; sbSpeed = 30; shSpeed = 200
	
	StarterGui:SetCore("SendNotification", {
		Title = "😈 RAGE MODE",
		Text = "Maximum degeneracy activated. No going back.",
		Duration = 3,
	})
end)

addButton(5, "Closet Preset (Subtle)", getY(5), neonCyan, function()
	kaEnabled = true; saEnabled = true; sbEnabled = false
	shEnabled = false; espEnabled = true; tbEnabled = false
	godEnabled = false; kaThroughWalls = false; saWallCheck = true
	kaRange = 10; kaDamage = 5; saFOV = 30
	
	StarterGui:SetCore("SendNotification", {
		Title = "🤫 CLOSET MODE",
		Text = "Subtle cheating. They'll never know... probably.",
		Duration = 3,
	})
end)

addButton(5, "Reset All", getY(5), neonRed, function()
	kaEnabled = false; saEnabled = false; sbEnabled = false
	shEnabled = false; espEnabled = false; tbEnabled = false
	godEnabled = false; flyEnabled = false; infJumpEnabled = false
	fovEnabled = false; spamEnabled = false; lagEnabled = false
	
	if flyEnabled then disableFly() end
	if player.Character then
		local hum = player.Character:FindFirstChild("Humanoid")
		if hum then hum.WalkSpeed = 16 end
	end
	camera.FieldOfView = originalFOV
	
	StarterGui:SetCore("SendNotification", {
		Title = "🔄 RESET",
		Text = "All cheats disabled. Playing legit... like a chump.",
		Duration = 3,
	})
end)

addKeybind(5, "Menu Toggle", getY(5), "RightShift", function(key)
	keybinds["MenuToggle"] = key
end)

-- ============= CORE LOGIC =============

-- Fly System
function enableFly()
	local char = player.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	
	flyBodyGyro = Instance.new("BodyGyro")
	flyBodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
	flyBodyGyro.CFrame = root.CFrame
	flyBodyGyro.Parent = root
	
	flyBodyVel = Instance.new("BodyVelocity")
	flyBodyVel.MaxForce = Vector3.new(400000, 400000, 400000)
	flyBodyVel.Velocity = Vector3.zero
	flyBodyVel.Parent = root
end

function disableFly()
	if flyBodyGyro then flyBodyGyro:Destroy() end
	if flyBodyVel then flyBodyVel:Destroy() end
	flyBodyGyro = nil
	flyBodyVel = nil
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
	
	if kaTargetLock and kaLockedTarget then
		local tChar = kaLockedTarget.Character
		if tChar then
			local tHum = tChar:FindFirstChild("Humanoid")
			local tRoot = tChar:FindFirstChild("HumanoidRootPart")
			if tHum and tRoot and tHum.Health > 0 then
				local dist = (root.Position - tRoot.Position).Magnitude
				if dist <= kaRange then
					if kaThroughWalls or not isWallBetween(root.Position, tRoot.Position, {char, tChar}) then
						tHum:TakeDamage(kaDamage)
					end
				end
			else
				kaLockedTarget = nil
			end
		else
			kaLockedTarget = nil
		end
		return
	end
	
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
		
		if kaTargetLock and not kaLockedTarget then
			kaLockedTarget = target
		end
	end
end)

-- Spinbot
RunService.RenderStepped:Connect(function()
	if sbEnabled and player.Character then
		local root = player.Character:FindFirstChild("HumanoidRootPart")
		if root then
			sbAngle = sbAngle + sbSpeed
			root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(sbSpeed), 0)
		end
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

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
	if infJumpEnabled and player.Character then
		local hum = player.Character:FindFirstChild("Humanoid")
		if hum then
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)

-- Fly Update
RunService.Heartbeat:Connect(function()
	if not flyEnabled then return end
	if not flyBodyGyro or not flyBodyVel then return end
	local char = player.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	
	local direction = Vector3.zero
	if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + camera.CFrame.LookVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - camera.CFrame.LookVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - camera.CFrame.RightVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + camera.CFrame.RightVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction = direction + Vector3.new(0, 1, 0) end
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then direction = direction - Vector3.new(0, 1, 0) end
	
	flyBodyVel.Velocity = direction.Magnitude > 0 and direction.Unit * flySpeed or Vector3.zero
	flyBodyGyro.CFrame = camera.CFrame
end)

-- Silent Aim (metatable hook)
local oldNamecall, oldIndex
local mt = getrawmetatable(game)
oldNamecall = mt.__namecall
oldIndex = mt.__index
setreadonly(mt, false)

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

mt.__namecall = newcclosure(function(self, ...)
	local method = getnamecallmethod()
	local args = {...}
	
	if method == "FireServer" and saEnabled then
		local targetPart = getBestSATarget()
		if targetPart and self.Name:lower():find("remote") then
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
RunService.RenderStepped:Connect(function()
	if not tbEnabled then return end
	if tick() - tbLastShot < tbDelay then return end
	
	local bestTarget = getBestSATarget()
	if bestTarget then
		tbLastShot = tick()
		mouse1press()
	end
end)

function mouse1press()
	-- Simulate mouse click via virtual input
	local vim = game:GetService("VirtualInputManager")
	vim:SendMouseButtonEvent(mouse.X, mouse.Y, 0, true, game, 0)
	vim:SendMouseButtonEvent(mouse.X, mouse.Y, 0, false, game, 0)
end

-- Chat Spammer
spawn(function()
	while true do
		if spamEnabled and player.Character then
			local hum = player.Character:FindFirstChild("Humanoid")
			if hum and hum.Health > 0 then
				local msg = spamMessages[spamIndex]
				spamIndex = spamIndex % #spamMessages + 1
				
				pcall(function()
					local chatService = game:GetService("TextChatService")
					if chatService.ChatInputBarConfiguration.TargetTextChannel then
						chatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(msg)
					end
				end)
			end
		end
		wait(2)
	end
end)

-- Fake Lag
local lagConnection
lagConnection = RunService.Heartbeat:Connect(function()
	if lagEnabled then
		wait(lagAmount)
	end
end)

-- ESP (Drawing system)
local espDrawings = {}
RunService.RenderStepped:Connect(function()
	for _, d in pairs(espDrawings) do d:Remove() end
	espDrawings = {}
	
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
		
		local scale = math.clamp(200 / dist, 0.3, 2)
		
		if espBoxes then
			local boxSize = Vector2.new(45 * scale, 75 * scale)
			local boxPos = Vector2.new(headPos.X - boxSize.X/2, headPos.Y - boxSize.Y/2)
			
			local outline = Drawing.new("Square")
			outline.Visible = true; outline.Size = boxSize; outline.Position = boxPos
			outline.Color = neonPink; outline.Thickness = 2; outline.Filled = false
			table.insert(espDrawings, outline)
			
			local fill = Drawing.new("Square")
			fill.Visible = true; fill.Size = boxSize; fill.Position = boxPos
			fill.Color = Color3.fromRGB(255, 0, 0); fill.Transparency = 0.7; fill.Filled = true
			table.insert(espDrawings, fill)
		end
		
		if espNames then
			local nameText = Drawing.new("Text")
			nameText.Visible = true; nameText.Text = target.Name
			nameText.Position = Vector2.new(headPos.X, headPos.Y - 55 * scale)
			nameText.Size = 14 * scale; nameText.Color = Color3.fromRGB(255, 255, 255)
			nameText.Center = true; nameText.Outline = true
			table.insert(espDrawings, nameText)
		end
		
		if espTracers then
			local tracer = Drawing.new("Line")
			tracer.Visible = true
			tracer.From = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y)
			tracer.To = Vector2.new(headPos.X, headPos.Y)
			tracer.Color = neonCyan; tracer.Thickness = 1; tracer.Transparency = 0.4
			table.insert(espDrawings, tracer)
		end
		
		if espHealth then
			local hp = hum.Health / hum.MaxHealth
			local bw, bh = 4 * scale, 75 * scale
			local bx, by = headPos.X - 27 * scale, headPos.Y - bh/2
			
			local bg = Drawing.new("Square")
			bg.Visible = true; bg.Size = Vector2.new(bw, bh); bg.Position = Vector2.new(bx, by)
			bg.Color = Color3.fromRGB(40, 40, 40); bg.Filled = true
			table.insert(espDrawings, bg)
			
			local bar = Drawing.new("Square")
			bar.Visible = true; bar.Size = Vector2.new(bw, bh * hp)
			bar.Position = Vector2.new(bx, by + bh * (1 - hp))
			bar.Color = Color3.fromRGB(0, 255, 0):Lerp(Color3.fromRGB(255, 0, 0), 1 - hp)
			bar.Filled = true
			table.insert(espDrawings, bar)
		end
	end
end)

-- Utility
function isWallBetween(pos1, pos2, ignoreList)
	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = ignoreList or {player.Character}
	rayParams.FilterType = Enum.RaycastFilterType.Blacklist
	local rayResult = Workspace:Raycast(pos1, (pos2 - pos1).Unit * (pos2 - pos1).Magnitude, rayParams)
	return rayResult ~= nil
end

-- Speed Hack watcher
player.CharacterAdded:Connect(function(char)
	if shEnabled then
		local hum = char:WaitForChild("Humanoid")
		hum.WalkSpeed = shSpeed
	end
end)

-- Keybind handler
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
			elseif action == "Triggerbot" then
				tbEnabled = not tbEnabled
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
	for _, d in pairs(espDrawings) do d:Remove() end
	espDrawings = {}
	if flyBodyGyro then flyBodyGyro:Destroy() end
	if flyBodyVel then flyBodyVel:Destroy() end
	if player.Character then
		local hum = player.Character:FindFirstChild("Humanoid")
		if hum then hum.WalkSpeed = 16 end
	end
	camera.FieldOfView = originalFOV
end

closeButton.MouseButton1Click:Connect(function()
	cleanup()
	screenGui:Destroy()
end)
screenGui.Destroying:Connect(cleanup)

-- Init
originalFOV = camera.FieldOfView

print("⚡ CHEAT SIMULATOR - FULL NEON RAGE MENU LOADED ⚡")
print("Tabs: Combat | Rage | Visuals | Memes | Config")
print("Everything. Literally everything. Enjoy the chaos.")
