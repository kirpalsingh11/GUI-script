
--[[==================================================================
  BASKETBALL DUELS (MODDED EDITION) - MOD MENU v1.0
====================================================================
  WHAT THIS IS
    A full in-game mod menu for YOUR game, in ONE LocalScript.
    Toggles work with mouse click AND touch (phone / tablet / PC).

  WHERE IT GOES (Roblox Studio, 30 seconds)
    1. In the Explorer open: StarterPlayer > StarterPlayerScripts
    2. Right-click StarterPlayerScripts > Insert Object > LocalScript
    3. Open the new LocalScript, DELETE the default print line,
       and paste ALL of this code into it.
    4. Press Play. Press RIGHT CTRL (or tap the floating MOD button
       on the right edge of the screen) to open the menu.

  HOW IT FINDS YOUR GAME'S STUFF (auto-matching)
    You used an exact-copy template of the game, so most names are
    probably standard. The script matches names PARTIALLY and
    CASE-INSENSITIVELY against alias lists, e.g. the ball can be
    called "Ball", "Basketball", "GAME_BALL" ... anything containing
    "ball" works. Same for hoops, buttons and remotes.
    If something is still not found, the STATUS BAR at the top of
    the menu prints exactly which name failed, and you paste the
    real name from your Explorer into CONFIG.Names below.

  PLUGGING THE SHOT HACKS INTO YOUR SHOT SCRIPT (one line each)
    Perfect Shot   -> in your shot code where you decide make/miss:
        if _G.ModMenu and _G.ModMenu.PerfectShot then accuracy = 1 end
    Infinite Range -> at your range check:
        if _G.ModMenu and _G.ModMenu.InfiniteRange then maxRange = math.huge end
    Instant Shot   -> where you decide how long charging takes:
        if _G.ModMenu and _G.ModMenu.InstantShot then chargeTime = 0 end
    No Cooldowns   -> at your cooldown check:
        if _G.ModMenu and _G.ModMenu.NoCooldowns then cooldown = 0 end
    (Use the variable names YOUR script already uses; the idea is:
     when the flag is on, force the perfect / unlimited value.)

  WHO GETS THE MENU
    CONFIG.Access below: "Everyone" = chaos mode, every player gets
    it. "Whitelist" = only listed UserIds. "Attribute" = only
    players your server marked (game-pass owners, see comment).

  NOTE FOR SERVER-ENFORCED GAMES
    God Mode / Anti Trip / speed / jump are client-side, which is
    fine in Studio and in your game unless YOUR server scripts also
    enforce them. If they do, mirror the checks there with the
    _G.ModMenu flags (they are readable by your LocalScripts).
==================================================================]]

--==================================================================
-- CONFIG - the only part you might need to edit
--==================================================================
local CONFIG = {
	Access = {
		Mode = "Everyone", -- "Everyone" | "Whitelist" | "Attribute"
		Whitelist = {
			-- [123456789] = true, -- paste your Roblox UserId here
		},
		-- "Attribute" mode: only players with HasModMenu attribute get it.
		-- Server Script example for a paid mod menu (ServerScriptService):
		--   local MPS = game:GetService("MarketplaceService")
		--   game:GetService("Players").PlayerAdded:Connect(function(p)
		--       if MPS:UserOwnsGamePassAsync(p.UserId, 123456) then
		--           p:SetAttribute("HasModMenu", true)
		--       end
		--   end)
	},

	MenuKey = Enum.KeyCode.RightControl, -- key that opens/closes the menu

	Names = {
		-- Fill ONLY if auto-match fails (status bar will tell you).
		-- Exact names from YOUR Explorer, or leave "" for auto-match.
		Ball            = "", -- e.g. "Basketball"
		Hoop            = "", -- e.g. "Hoop1"
		DribbleButton   = "", -- e.g. "DribbleButton"
		CrossoverButton = "", -- e.g. "SpecialMove"
		StealButton     = "",
		ShootButton     = "",
		-- OPTIONAL but most reliable for bots: your RemoteEvents in
		-- ReplicatedStorage (the events your buttons fire).
		DribbleRemote   = "", -- e.g. "DribbleEvent"
		CrossoverRemote = "",
		StealRemote     = "",
		ShootRemote     = "",
	},

	Intervals = { -- how often bots act (seconds)
		Dribble   = 0.35,
		Crossover = 0.9,
		Steal     = 0.3,
		Shoot     = 0.6,
		Dunk      = 0.8,
	},

	Magnet = {
		Range = 60, -- pull the ball from up to this many studs
		Force = 60, -- pull strength
	},

	StealRange = 14, -- Auto Steal triggers when an opponent is this close (studs)
}

--==================================================================
-- SERVICES / BASIC SETUP
--==================================================================
local Players               = game:GetService("Players")
local ReplicatedStorage     = game:GetService("ReplicatedStorage")
local UserInputService      = game:GetService("UserInputService")
local TweenService          = game:GetService("TweenService")
local RunService            = game:GetService("RunService")
local VirtualInputManager   = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

-- kill any previous copy of the menu (safety, e.g. duplicate script)
if PlayerGui:FindFirstChild("ModMenuGui") then
	PlayerGui.ModMenuGui:Destroy()
end

-- access check ------------------------------------------------------
local function hasAccess()
	if RunService:IsStudio() then return true end -- always on while testing
	local mode = CONFIG.Access.Mode
	if mode == "Everyone" then return true end
	if CONFIG.Access.Whitelist[LocalPlayer.UserId] then return true end
	if mode == "Attribute" then
		return LocalPlayer:GetAttribute("HasModMenu") == true
	end
	return false
end
if not hasAccess() then return end

--==================================================================
-- SHARED FLAGS (your own scripts read these, see header)
--==================================================================
local Flags = {}
_G.ModMenu = Flags
Flags.PerfectShot   = false
Flags.InstantShot   = false
Flags.InfiniteRange = false
Flags.NoCooldowns   = false
Flags.WalkSpeed     = 16
Flags.JumpPower     = 50

--==================================================================
-- THEME
--==================================================================
local THEME = {
	Background  = Color3.fromRGB(18, 18, 24),
	Panel       = Color3.fromRGB(28, 28, 38),
	Card        = Color3.fromRGB(38, 38, 52),
	Accent      = Color3.fromRGB(255, 130, 30), -- basketball orange
	AccentDim   = Color3.fromRGB(120, 65, 15),
	Text        = Color3.fromRGB(240, 240, 245),
	TextDim     = Color3.fromRGB(160, 160, 175),
	Good        = Color3.fromRGB(60, 200, 110),
	Bad         = Color3.fromRGB(230, 75, 75),
	Font        = Enum.Font.GothamBold,
	FontMed     = Enum.Font.Gotham,
}

local function corner(parent, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 8)
	c.Parent = parent
	return c
end

local function stroke(parent, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color or THEME.AccentDim
	s.Thickness = thickness or 1.5
	s.Parent = parent
	return s
end

local function newText(parent, txt, size, color, font)
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Size = UDim2.new(1, 0, 1, 0)
	t.Font = font or THEME.Font
	t.Text = txt or ""
	t.TextSize = size or 14
	t.TextColor3 = color or THEME.Text
	t.TextWrapped = true
	t.Parent = parent
	return t
end

--==================================================================
-- NAME MATCHING (partial + case-insensitive, with alias lists)
--==================================================================
local function nameMatch(instanceName, target)
	if target == nil or target == "" then return false end
	local a = string.lower(instanceName)
	local b = string.lower(target)
	return string.find(a, b, 1, true) ~= nil
end

local function matchesAny(instanceName, aliases)
	for _, alias in ipairs(aliases) do
		if string.find(string.lower(instanceName), alias, 1, true) then
			return true
		end
	end
	return false
end

-- find a GuiButton on screen (PlayerGui, any depth) by aliases
local function findButton(aliases)
	local best
	local function scan(parent)
		for _, child in ipairs(parent:GetChildren()) do
			if child:IsA("GuiButton") then
				if matchesAny(child.Name, aliases) then
					if not best or #child.Name < #best.Name then
						best = child
					end
				end
			end
			if #child:GetChildren() > 0 then scan(child) end
		end
	end
	scan(PlayerGui)
	return best
end

-- find a RemoteEvent (ReplicatedStorage or its folders) by aliases
local function findRemote(aliases)
	local best
	local function scan(parent)
		for _, child in ipairs(parent:GetChildren()) do
			if child:IsA("RemoteEvent") then
				if matchesAny(child.Name, aliases) then
					if not best or #child.Name < #best.Name then
						best = child
					end
				end
			end
			if #child:GetChildren() > 0 then scan(child) end
		end
	end
	scan(ReplicatedStorage)
	return best
end

--==================================================================
-- GUI SHELL
--==================================================================
local gui = Instance.new("ScreenGui")
gui.Name = "ModMenuGui"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
gui.Parent = PlayerGui

local status = { text = "ready", color = THEME.TextDim }

local window = Instance.new("Frame")
window.Name = "Window"
window.AnchorPoint = Vector2.new(0.5, 0.5)
window.Position = UDim2.new(0.5, 0, 0.5, 0)
window.Size = UDim2.new(0, 460, 0, 340)
window.BackgroundColor3 = THEME.Background
window.BackgroundTransparency = 0.05
window.Visible = false
window.Parent = gui
corner(window, 12)
stroke(window, THEME.AccentDim, 1.5)

-- drag support (mouse AND touch) ---------------------------------
local dragging, dragStart, startPos
local dragConns = {}
local function makeDraggable(handle)
	local function begin(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = window.Position
			input:GetPropertyChangedSignal("UserInputState"):Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end
	table.insert(dragConns, handle.InputBegan:Connect(begin))
end
table.insert(dragConns, UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		window.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end))

-- title bar -------------------------------------------------------
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 36)
titleBar.BackgroundColor3 = THEME.Panel
titleBar.Parent = window
corner(titleBar, 12)
makeDraggable(titleBar)

local titleIcon = Instance.new("TextLabel")
titleIcon.BackgroundTransparency = 1
titleIcon.Position = UDim2.new(0, 10, 0, 0)
titleIcon.Size = UDim2.new(0, 24, 1, 0)
titleIcon.Font = THEME.Font
titleIcon.Text = "🏀"
titleIcon.TextSize = 16
titleIcon.TextColor3 = THEME.Text
titleIcon.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.BackgroundTransparency = 1
titleText.Position = UDim2.new(0, 36, 0, 0)
titleText.Size = UDim2.new(1, -120, 1, 0)
titleText.Font = THEME.Font
titleText.Text = "BASKETBALL MODS"
titleText.TextSize = 15
titleText.TextColor3 = THEME.Text
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Name = "Close"
closeBtn.AnchorPoint = Vector2.new(1, 0.5)
closeBtn.Position = UDim2.new(1, -8, 0.5, 0)
closeBtn.Size = UDim2.new(0, 28, 0, 24)
closeBtn.BackgroundColor3 = THEME.Bad
closeBtn.Font = THEME.Font
closeBtn.Text = "X"
closeBtn.TextSize = 13
closeBtn.TextColor3 = THEME.Text
closeBtn.Parent = titleBar
corner(closeBtn, 6)
closeBtn.MouseButton1Click:Connect(function() window.Visible = false end)

-- status bar ------------------------------------------------------
local statusBar = Instance.new("TextLabel")
statusBar.Name = "Status"
statusBar.Position = UDim2.new(0, 0, 1, -22)
statusBar.Size = UDim2.new(1, -16, 0, 18)
statusBar.AnchorPoint = Vector2.new(0, 1)
statusBar.BackgroundTransparency = 1
statusBar.Font = THEME.FontMed
statusBar.TextSize = 12
statusBar.TextColor3 = status.color
statusBar.TextXAlignment = Enum.TextXAlignment.Left
statusBar.Text = "status: " .. status.text
statusBar.Parent = window

local function setStatus(text, color)
	status.text = text
	status.color = color or THEME.TextDim
	statusBar.Text = "status: " .. text
	statusBar.TextColor3 = status.color
end

-- tab buttons -----------------------------------------------------
local TABS = { "PLAYER", "OFFENSE", "DRIBBLE", "DEFENSE", "CHAOS" }
local tabBar = Instance.new("Frame")
tabBar.Name = "TabBar"
tabBar.Position = UDim2.new(0, 0, 0, 40)
tabBar.Size = UDim2.new(1, 0, 0, 30)
tabBar.BackgroundTransparency = 1
tabBar.Parent = window

local tabList = Instance.new("UIListLayout")
tabList.FillDirection = Enum.FillDirection.Horizontal
tabList.Padding = UDim.new(0, 4)
tabList.Parent = tabBar

local tabButtons = {}
local pages = {}
local currentTab = "PLAYER"

local function selectTab(name)
	currentTab = name
	for tabName, btn in pairs(tabButtons) do
		if tabName == name then
			btn.BackgroundColor3 = THEME.Accent
			btn.TextColor3 = Color3.fromRGB(20, 20, 20)
		else
			btn.BackgroundColor3 = THEME.Card
			btn.TextColor3 = THEME.TextDim
		end
	end
	for pageName, page in pairs(pages) do
		page.Visible = (pageName == name)
	end
end

for _, tabName in ipairs(TABS) do
	local btn = Instance.new("TextButton")
	btn.Name = tabName
	btn.Size = UDim2.new(0, 84, 1, 0)
	btn.BackgroundColor3 = THEME.Card
	btn.Font = THEME.Font
	btn.Text = tabName
	btn.TextSize = 11
	btn.TextColor3 = THEME.TextDim
	btn.AutoButtonColor = true
	btn.Parent = tabBar
	corner(btn, 6)
	btn.MouseButton1Click:Connect(function() selectTab(tabName) end)
	tabButtons[tabName] = btn
end

-- scroll pages ----------------------------------------------------
for _, tabName in ipairs(TABS) do
	local page = Instance.new("ScrollingFrame")
	page.Name = tabName .. "Page"
	page.Position = UDim2.new(0, 8, 0, 74)
	page.Size = UDim2.new(1, -16, 1, -108)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.ScrollBarThickness = 4
	page.ScrollBarImageColor3 = THEME.AccentDim
	page.CanvasSize = UDim2.new(0, 0, 0, 0)
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.Parent = window
	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, 6)
	list.Parent = page
	pages[tabName] = page
end

-- floating MOD button (mobile opener) -----------------------------
local modBtn = Instance.new("TextButton")
modBtn.Name = "ModToggle"
modBtn.AnchorPoint = Vector2.new(1, 0.5)
modBtn.Position = UDim2.new(1, -10, 0.5, 0)
modBtn.Size = UDim2.new(0, 52, 0, 52)
modBtn.BackgroundColor3 = THEME.Accent
modBtn.Font = THEME.Font
modBtn.Text = "MOD"
modBtn.TextSize = 13
modBtn.TextColor3 = Color3.fromRGB(20, 20, 20)
modBtn.AutoButtonColor = true
modBtn.ZIndex = 5
modBtn.Parent = gui
corner(modBtn, 26)
stroke(modBtn, THEME.AccentDim, 2)
modBtn.MouseButton1Click:Connect(function()
	window.Visible = not window.Visible
end)

-- keyboard toggle -------------------------------------------------
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == CONFIG.MenuKey then
		window.Visible = not window.Visible
	end
end)

--==================================================================
-- WIDGET FACTORIES (toggle / slider / button rows)
--==================================================================
local function newRow(page, height)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -8, 0, height or 34)
	row.BackgroundColor3 = THEME.Card
	row.Parent = page
	corner(row, 8)
	return row
end

local function makeToggle(page, label, default, callback)
	local on = default or false
	local row = newRow(page)
	local labelEl = Instance.new("TextLabel")
	labelEl.BackgroundTransparency = 1
	labelEl.Position = UDim2.new(0, 10, 0, 0)
	labelEl.Size = UDim2.new(1, -70, 1, 0)
	labelEl.Font = THEME.FontMed
	labelEl.Text = label
	labelEl.TextSize = 13
	labelEl.TextColor3 = THEME.Text
	labelEl.TextXAlignment = Enum.TextXAlignment.Left
	labelEl.Parent = row

	local switch = Instance.new("TextButton")
	switch.Size = UDim2.new(0, 46, 0, 22)
	switch.AnchorPoint = Vector2.new(1, 0.5)
	switch.Position = UDim2.new(1, -10, 0.5, 0)
	switch.BackgroundColor3 = on and THEME.Good or THEME.Panel
	switch.Text = ""
	switch.Parent = row
	corner(switch, 11)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 16, 0, 16)
	knob.Position = on and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
	knob.BackgroundColor3 = THEME.Text
	knob.Parent = switch
	corner(knob, 8)

	local function render()
		TweenService:Create(switch, TweenInfo.new(0.15), {
			BackgroundColor3 = on and THEME.Good or THEME.Panel
		}):Play()
		TweenService:Create(knob, TweenInfo.new(0.15), {
			Position = on and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
		}):Play()
	end

	switch.MouseButton1Click:Connect(function()
		on = not on
		render()
		callback(on)
	end)

	return {
		set = function(v)
			on = v and true or false
			render()
			callback(on)
		end,
	}
end

local function makeSlider(page, label, min, max, default, callback)
	local row = newRow(page, 52)
	local labelEl = Instance.new("TextLabel")
	labelEl.BackgroundTransparency = 1
	labelEl.Position = UDim2.new(0, 10, 0, 2)
	labelEl.Size = UDim2.new(1, -80, 0, 18)
	labelEl.Font = THEME.FontMed
	labelEl.Text = label
	labelEl.TextSize = 13
	labelEl.TextColor3 = THEME.Text
	labelEl.TextXAlignment = Enum.TextXAlignment.Left
	labelEl.Parent = row

	local valueLabel = Instance.new("TextLabel")
	valueLabel.BackgroundTransparency = 1
	valueLabel.AnchorPoint = Vector2.new(1, 0)
	valueLabel.Position = UDim2.new(1, -10, 0, 2)
	valueLabel.Size = UDim2.new(0, 60, 0, 18)
	valueLabel.Font = THEME.Font
	valueLabel.Text = tostring(default)
	valueLabel.TextSize = 13
	valueLabel.TextColor3 = THEME.Accent
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.Parent = row

	local track = Instance.new("TextButton")
	track.BackgroundTransparency = 1 -- clicks pass to bar below via bar button
	track.Size = UDim2.new(1, -20, 0, 18)
	track.Position = UDim2.new(0, 10, 0, 26)
	track.Text = ""
	track.Parent = row

	local bar = Instance.new("Frame")
	bar.AnchorPoint = Vector2.new(0, 0.5)
	bar.Position = UDim2.new(0, 0, 0.5, 0)
	bar.Size = UDim2.new(1, 0, 0, 6)
	bar.BackgroundColor3 = THEME.Panel
	bar.Parent = track
	corner(bar, 3)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
	fill.BackgroundColor3 = THEME.Accent
	fill.Parent = bar
	corner(fill, 3)

	local draggingSlider = false
	local function setFromX(x)
		local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
		local value = math.floor(min + (max - min) * rel + 0.5)
		fill.Size = UDim2.new(rel, 0, 1, 0)
		valueLabel.Text = tostring(value)
		callback(value)
	end

	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			draggingSlider = true
			setFromX(input.Position.X)
		end
	end)
	track.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			draggingSlider = false
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			setFromX(input.Position.X)
		end
	end)

	return { set = function(v) fill.Size = UDim2.new((v - min) / (max - min), 0, 1, 0) end }
end

local function makeButton(page, label, callback)
	local row = newRow(page)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundColor3 = THEME.Panel
	btn.Font = THEME.Font
	btn.Text = label
	btn.TextSize = 13
	btn.TextColor3 = THEME.Text
	btn.AutoButtonColor = true
	btn.Parent = row
	corner(btn, 8)
	btn.MouseButton1Click:Connect(callback)
	return btn
end

--==================================================================
-- CHARACTER HELPERS
--==================================================================
local function getCharacter()
	return LocalPlayer.Character
end

local function getHumanoid()
	local char = getCharacter()
	return char and char:FindFirstChildOfClass("Humanoid")
end

local function getRoot()
	local char = getCharacter()
	return char and char:FindFirstChild("HumanoidRootPart")
end

local function onCharacter(func)
	func(LocalPlayer.Character)
	LocalPlayer.CharacterAdded:Connect(func)
end

--==================================================================
-- FEATURE STATE
--==================================================================
local state = {
	speedOn = false, jumpOn = false, infJump = false, god = false,
	noclip = false, moonGravity = false, magnetOn = false,
	infStaminaFlag = false,
	walkSpeed = 16, jumpPower = 50,
}

--==================================================================
-- BOT HELPERS (press your on-screen buttons / fire your remotes)
--==================================================================
local buttonCache = {}
local remoteCache = {}

local function getButton(kind, aliases)
	if CONFIG.Names[kind] ~= nil and CONFIG.Names[kind] ~= "" then
		if not buttonCache[kind] then
			buttonCache[kind] = findButton({ string.lower(CONFIG.Names[kind]) })
		end
		return buttonCache[kind]
	end
	if not buttonCache[kind] then
		buttonCache[kind] = findButton(aliases)
	end
	return buttonCache[kind]
end

local function getRemote(kind, aliases)
	if CONFIG.Names[kind] ~= nil and CONFIG.Names[kind] ~= "" then
		if not remoteCache[kind] then
			remoteCache[kind] = findRemote({ string.lower(CONFIG.Names[kind]) })
		end
		return remoteCache[kind]
	end
	if not remoteCache[kind] then
		remoteCache[kind] = findRemote(aliases)
	end
	return remoteCache[kind]
end

-- click a GUI button programmatically (works in Studio and live)
local function clickButton(btn)
	if not btn then return false end
	local ok = pcall(function()
		local pos = Vector2.new(
			btn.AbsolutePosition.X + btn.AbsoluteSize.X / 2,
			btn.AbsolutePosition.Y + btn.AbsoluteSize.Y / 2)
		VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, btn, 1)
		VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, btn, 1)
	end)
	return ok
end

-- one clean "do the move" call: remote first, button as fallback
local function doAction(kind, buttonAliases, remoteAliases)
	local remote = getRemote(kind .. "Remote", remoteAliases)
	if remote then
		pcall(function() remote:FireServer() end)
		return true
	end
	local btn = getButton(kind .. "Button", buttonAliases)
	if btn then
		return clickButton(btn)
	end
	return false
end

--==================================================================
-- GAME OBJECT FINDERS
--==================================================================
local function findBall()
	local ballName = CONFIG.Names.Ball
	for _, item in ipairs(workspace:GetChildren()) do
		if item:IsA("BasePart") or item:IsA("Model") then
			if ballName ~= "" and nameMatch(item.Name, ballName) then return item end
			if matchesAny(item.Name, { "ball" }) then return item end
		end
	end
	-- deeper search (one level of folders/models)
	for _, folder in ipairs(workspace:GetChildren()) do
		if folder:IsA("Model") or folder:IsA("Folder") then
			for _, item in ipairs(folder:GetChildren()) do
				if (item:IsA("BasePart") or item:IsA("Model")) and matchesAny(item.Name, { "ball" }) then
					return item
				end
			end
		end
	end
	return nil
end

local function findHoop()
	local hoopName = CONFIG.Names.Hoop
	local best
	local function scan(parent, depth)
		if depth > 2 then return end
		for _, item in ipairs(parent:GetChildren()) do
			if hoopName ~= "" and nameMatch(item.Name, hoopName) then
				return item
			end
			if matchesAny(item.Name, { "hoop", "rim", "goal", "net" }) then
				if not best then best = item end
			end
			if item:IsA("Model") or item:IsA("Folder") then
				local found = scan(item, depth + 1)
				if found then return found end
			end
		end
		return nil
	end
	local direct = scan(workspace, 0)
	if direct then return direct end
	return best
end

local function getPartOf(thing)
	if not thing then return nil end
	if thing:IsA("BasePart") then return thing end
	if thing:IsA("Model") then
		return thing:FindFirstChildWhichIsA("BasePart", true)
	end
	return nil
end

local function nearestOpponent(range)
	local root = getRoot()
	if not root then return nil, nil end
	local bestDist, bestRoot = math.huge, nil
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character then
			local other = plr.Character:FindFirstChild("HumanoidRootPart")
			if other then
				local d = (other.Position - root.Position).Magnitude
				if d < bestDist then bestDist, bestRoot = d, other end
			end
		end
	end
	if bestRoot and bestDist <= range then return bestRoot, bestDist end
	return nil, nil
end

--==================================================================
-- RUNTIME LOOPS
--==================================================================
local botsOn = {
	Dribble = false, Crossover = false, Steal = false, Shoot = false, Dunk = false,
}
local botClock = { Dribble = 0, Crossover = 0, Steal = 0, Shoot = 0, Dunk = 0 }
local auraConn = nil

local function runBots(dt)
	if not next(botsOn) then return end
	for name, active in pairs(botsOn) do
		if active then
			botClock[name] = botClock[name] + dt
			if botClock[name] >= CONFIG.Intervals[name] then
				botClock[name] = 0
				if name == "Steal" then
					-- only steal when an opponent is close
					local target = nearestOpponent(CONFIG.StealRange)
					if target then
						doAction("Steal", { "steal", "strip" }, { "steal", "strip" })
					end
				elseif name == "Dunk" then
					-- tp near the hoop then shoot
					local hoopPart = getPartOf(findHoop())
					local root = getRoot()
					if hoopPart and root then
						local behind = (root.Position - hoopPart.Position).Unit * 6
						root.CFrame = CFrame.new(hoopPart.Position + behind)
					end
					doAction("Shoot", { "shoot", "shot", "score" }, { "shoot", "shot", "score" })
				else
					local aliasMap = {
						Dribble = { { "dribble" }, { "dribble" } },
						Crossover = { { "crossover", "cross", "special", "move" },
							{ "crossover", "cross", "special" } },
						Shoot = { { "shoot", "shot", "score" }, { "shoot", "shot", "score" } },
					}
					local pair = aliasMap[name]
					if pair then
						doAction(name, pair[1], pair[2])
					end
				end
			end
		end
	end
end

RunService.Heartbeat:Connect(function(dt)
	-- keep speed / jump applied (survives respawns and server resets)
	local hum = getHumanoid()
	if hum then
		if state.speedOn then
			hum.WalkSpeed = state.walkSpeed
		end
		if state.jumpOn then
			hum.UseJumpPower = true
			hum.JumpPower = state.jumpPower
		end
		if state.god then
			hum.MaxHealth = math.huge
			hum.Health = math.huge
		end
	end

	-- noclip: walk through walls
	if state.noclip then
		local char = getCharacter()
		if char then
			for _, part in ipairs(char:GetChildren()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end
	end

	-- ball magnet
	if state.magnetOn then
		local ballPart = getPartOf(findBall())
		local root = getRoot()
		if ballPart and root and ballPart:IsA("BasePart") then
			local dist = (ballPart.Position - root.Position).Magnitude
			if dist <= CONFIG.Magnet.Range and dist > 3 then
				local dir = (root.Position - ballPart.Position).Unit
				ballPart.AssemblyLinearVelocity = dir * CONFIG.Magnet.Force
			end
		end
	end

	runBots(dt)
end)

-- moon gravity
local function applyGravity()
	workspace.Gravity = state.moonGravity and 60 or 196.2
end

-- infinite jump
UserInputService.JumpRequest:Connect(function()
	if state.infJump then
		local hum = getHumanoid()
		if hum then
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)

-- god mode stays on after respawn
onCharacter(function(char)
	if state.god then
		local hum = char:WaitForChild("Humanoid")
		hum.MaxHealth = math.huge
		hum.Health = math.huge
	end
end)

--==================================================================
-- TAB: PLAYER
--==================================================================
local speedSlider = makeSlider(pages.PLAYER, "Walk Speed", 1, 100, 16, function(v)
	state.walkSpeed = v
	Flags.WalkSpeed = v
	if state.speedOn then
		local hum = getHumanoid()
		if hum then hum.WalkSpeed = v end
	end
end)

makeToggle(pages.PLAYER, "Speed Hack (keep applied)", false, function(on)
	state.speedOn = on
	if on then
		local hum = getHumanoid()
		if hum then hum.WalkSpeed = state.walkSpeed end
		setStatus("speed hack ON (" .. state.walkSpeed .. ")", THEME.Good)
	else
		local hum = getHumanoid()
		if hum then hum.WalkSpeed = 16 end
		setStatus("speed reset", THEME.TextDim)
	end
end)

local jumpSlider = makeSlider(pages.PLAYER, "Jump Power", 20, 250, 50, function(v)
	state.jumpPower = v
	Flags.JumpPower = v
	if state.jumpOn then
		local hum = getHumanoid()
		if hum then
			hum.UseJumpPower = true
			hum.JumpPower = v
		end
	end
end)

makeToggle(pages.PLAYER, "Jump Hack (keep applied)", false, function(on)
	state.jumpOn = on
	local hum = getHumanoid()
	if on then
		if hum then
			hum.UseJumpPower = true
			hum.JumpPower = state.jumpPower
		end
		setStatus("jump hack ON (" .. state.jumpPower .. ")", THEME.Good)
	elseif hum then
		hum.JumpPower = 50
		setStatus("jump reset", THEME.TextDim)
	end
end)

makeToggle(pages.PLAYER, "Infinite Jump", false, function(on)
	state.infJump = on
	setStatus(on and "infinite jump ON" or "infinite jump off",
		on and THEME.Good or THEME.TextDim)
end)

makeToggle(pages.PLAYER, "God Mode", false, function(on)
	state.god = on
	local hum = getHumanoid()
	if on then
		if hum then
			hum.MaxHealth = math.huge
			hum.Health = math.huge
		end
		setStatus("god mode ON", THEME.Good)
	elseif hum then
		hum.MaxHealth = 100
		hum.Health = math.min(hum.Health, 100)
		setStatus("god mode off", THEME.TextDim)
	end
end)

makeToggle(pages.PLAYER, "Noclip (walk through walls)", false, function(on)
	state.noclip = on
	if not on then
		local char = getCharacter()
		if char then
			for _, part in ipairs(char:GetChildren()) do
				if part:IsA("BasePart") then
					part.CanCollide = true
				end
			end
		end
	end
	setStatus(on and "noclip ON" or "collisions restored",
		on and THEME.Good or THEME.TextDim)
end)

--==================================================================
-- TAB: OFFENSE
--==================================================================
makeToggle(pages.OFFENSE, "Perfect Shot (needs 1 line in your shot script)", false, function(on)
	Flags.PerfectShot = on
	setStatus(on and "perfect shot flag ON - add the snippet!" or "perfect shot off",
		on and THEME.Accent or THEME.TextDim)
end)

makeToggle(pages.OFFENSE, "Infinite Range (needs 1 line)", false, function(on)
	Flags.InfiniteRange = on
end)

makeToggle(pages.OFFENSE, "Instant Shot (needs 1 line)", false, function(on)
	Flags.InstantShot = on
end)

makeToggle(pages.OFFENSE, "Auto Shoot", false, function(on)
	botsOn.Shoot = on
	if on and not doAction("Shoot", { "shoot", "shot", "score" }, { "shoot", "shot", "score" }) then
		setStatus("no shoot button/remote found - see CONFIG.Names", THEME.Bad)
		botsOn.Shoot = false
		return
	end
	setStatus(on and "auto shoot ON" or "auto shoot off", on and THEME.Good or THEME.TextDim)
end)

makeToggle(pages.OFFENSE, "Auto Dunk (tp to hoop + shoot)", false, function(on)
	botsOn.Dunk = on
	setStatus(on and "auto dunk ON" or "auto dunk off", on and THEME.Good or THEME.TextDim)
end)

makeButton(pages.OFFENSE, "Teleport to Hoop", function()
	local hoopPart = getPartOf(findHoop())
	local root = getRoot()
	if hoopPart and root then
		local offset = Vector3.new(0, 6, 0) + (root.Position - hoopPart.Position).Unit * 6
		root.CFrame = CFrame.new(hoopPart.Position + offset)
		setStatus("teleported to hoop", THEME.Good)
	else
		setStatus("hoop not found - set CONFIG.Names.Hoop", THEME.Bad)
	end
end)

--==================================================================
-- TAB: DRIBBLE
--==================================================================
makeToggle(pages.DRIBBLE, "Dribble Bot (auto dribble)", false, function(on)
	botsOn.Dribble = on
	if on and not doAction("Dribble", { "dribble" }, { "dribble" }) then
		setStatus("no dribble button/remote found - see CONFIG.Names", THEME.Bad)
		botsOn.Dribble = false
		return
	end
	setStatus(on and "dribble bot ON" or "dribble bot off", on and THEME.Good or THEME.TextDim)
end)

makeToggle(pages.DRIBBLE, "Auto Crossover", false, function(on)
	botsOn.Crossover = on
	if on and not doAction("Crossover",
		{ "crossover", "cross", "special", "move" },
		{ "crossover", "cross", "special" }) then
		setStatus("no crossover button/remote found - see CONFIG.Names", THEME.Bad)
		botsOn.Crossover = false
		return
	end
	setStatus(on and "auto crossover ON" or "auto crossover off", on and THEME.Good or THEME.TextDim)
end)

makeToggle(pages.DRIBBLE, "No Cooldowns (needs 1 line)", false, function(on)
	Flags.NoCooldowns = on
end)

makeToggle(pages.DRIBBLE, "Ball Magnet", false, function(on)
	state.magnetOn = on
	if on and not getPartOf(findBall()) then
		setStatus("ball not found - set CONFIG.Names.Ball", THEME.Bad)
		state.magnetOn = false
		return
	end
	setStatus(on and "ball magnet ON" or "ball magnet off", on and THEME.Good or THEME.TextDim)
end)

makeButton(pages.DRIBBLE, "Teleport to Ball", function()
	local ballPart = getPartOf(findBall())
	local root = getRoot()
	if ballPart and root then
		root.CFrame = CFrame.new(ballPart.Position + Vector3.new(0, 4, 0))
		setStatus("teleported to ball", THEME.Good)
	else
		setStatus("ball not found - set CONFIG.Names.Ball", THEME.Bad)
	end
end)

--==================================================================
-- TAB: DEFENSE
--==================================================================
makeToggle(pages.DEFENSE, "Auto Steal", false, function(on)
	botsOn.Steal = on
	if on and not doAction("Steal", { "steal", "strip" }, { "steal", "strip" }) then
		setStatus("no steal button/remote found - see CONFIG.Names", THEME.Bad)
		botsOn.Steal = false
		return
	end
	setStatus(on and "auto steal ON (range " .. CONFIG.StealRange .. ")" or "auto steal off",
		on and THEME.Good or THEME.TextDim)
end)

makeSlider(pages.DEFENSE, "Steal Range (studs)", 4, 40, CONFIG.StealRange, function(v)
	CONFIG.StealRange = v
end)

makeToggle(pages.DEFENSE, "Anti Trip / Anti Stun", false, function(on)
	local hum = getHumanoid()
	if on then
		if hum then
			hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
			hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
		end
		setStatus("anti trip ON", THEME.Good)
	elseif hum then
		hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
		hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
	end
end)

--==================================================================
-- TAB: CHAOS
--==================================================================
makeToggle(pages.CHAOS, "Moon Gravity (everybody floats)", false, function(on)
	state.moonGravity = on
	applyGravity()
	setStatus(on and "moon gravity ON" or "gravity restored",
		on and THEME.Good or THEME.TextDim)
end)

makeToggle(pages.CHAOS, "Big Hoops (easier shots, visual)", false, function(on)
	local hoop = findHoop()
	if not hoop then
		setStatus("hoop not found - set CONFIG.Names.Hoop", THEME.Bad)
		return
	end
	local scale = on and 2 or 1
	if hoop:IsA("Model") then
		pcall(function() hoop:ScaleTo(scale) end)
	elseif hoop:IsA("BasePart") then
		pcall(function()
			if on then
				hoop.Size = hoop.Size * 2
			else
				hoop.Size = hoop.Size / 2
			end
		end)
	end
	setStatus(on and "big hoops ON" or "hoops normal", on and THEME.Good or THEME.TextDim)
end)

makeToggle(pages.CHAOS, "Rainbow Aura", false, function(on)
	if auraConn then
		auraConn:Disconnect()
		auraConn = nil
	end
	local function removeAura()
		local root = getRoot()
		if root then
			local att = root:FindFirstChild("ModAura")
			if att then att:Destroy() end
		end
	end
	if on then
		local function addAura(root)
			if root and not root:FindFirstChild("ModAura") then
				local light = Instance.new("PointLight")
				light.Name = "ModAura"
				light.Range = 14
				light.Brightness = 2
				light.Parent = root
			end
		end
		onCharacter(function(char)
			addAura(char:WaitForChild("HumanoidRootPart"))
		end)
		addAura(getRoot())
		local hue = 0
		auraConn = RunService.Heartbeat:Connect(function()
			hue = (hue + 0.005) % 1
			local root = getRoot()
			if root then
				local light = root:FindFirstChild("ModAura")
				if light then
					light.Color = Color3.fromHSV(hue, 1, 1)
				end
			end
		end)
		setStatus("rainbow aura ON", THEME.Good)
	else
		removeAura()
		setStatus("aura off", THEME.TextDim)
	end
end)

makeButton(pages.CHAOS, "PANIC - turn everything off", function()
	botsOn.Dribble = false
	botsOn.Crossover = false
	botsOn.Steal = false
	botsOn.Shoot = false
	botsOn.Dunk = false
	state.speedOn = false
	state.jumpOn = false
	state.infJump = false
	state.god = false
	state.noclip = false
	state.magnetOn = false
	state.moonGravity = false
	Flags.PerfectShot = false
	Flags.InstantShot = false
	Flags.InfiniteRange = false
	Flags.NoCooldowns = false
	applyGravity()
	local hum = getHumanoid()
	if hum then
		hum.WalkSpeed = 16
		hum.JumpPower = 50
		hum.MaxHealth = 100
		hum.Health = math.min(hum.Health, 100)
		hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
		hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
	end
	local char = getCharacter()
	if char then
		for _, part in ipairs(char:GetChildren()) do
			if part:IsA("BasePart") then
				part.CanCollide = true
			end
		end
	end
	speedSlider.set(16)
	jumpSlider.set(50)
	window.Visible = false
	print("[ModMenu] PANIC: everything off")
end)

--==================================================================
-- STARTUP
--==================================================================
selectTab("PLAYER")

-- report what auto-match found, so missing names are obvious
task.defer(function()
	task.wait(1)
	local found = {}
	if getPartOf(findBall()) then table.insert(found, "ball") end
	if findHoop() then table.insert(found, "hoop") end
	if getButton("DribbleButton", { "dribble" }) or getRemote("DribbleRemote", { "dribble" }) then
		table.insert(found, "dribble")
	end
	if getButton("StealButton", { "steal" }) or getRemote("StealRemote", { "steal" }) then
		table.insert(found, "steal")
	end
	if getButton("ShootButton", { "shoot" }) or getRemote("ShootRemote", { "shoot" }) then
		table.insert(found, "shoot")
	end
	local parts = #found > 0 and table.concat(found, " + ") or "nothing yet"
	setStatus("menu ready | found: " .. parts .. " (missing = fill CONFIG.Names)",
		THEME.Accent)
	print("[ModMenu] ready. Found: " .. parts)
	print("[ModMenu] If a toggle does nothing, copy the exact name from your Explorer into CONFIG.Names")
end)

print("[ModMenu] loaded for " .. LocalPlayer.Name)

