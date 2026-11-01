-- [MADE BY SILENT GUCCI]
-- Nezux Anti Bat | gray + neon | smaller gui | stronger bg

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local CoreGui          = game:GetService("CoreGui")
local HttpService      = game:GetService("HttpService")
local GuiService       = game:GetService("GuiService")

local localPlayer = Players.LocalPlayer

local INF_JUMP_BOOST    = 55
local INF_JUMP_MIN_Y    = 35
local INF_JUMP_MAX_FALL = -120
local ANTIBAT_RANGE     = 4000

local config = {
	AntiBatEnabled    = false,
	InfJumpEnabled    = false,
	Keybind           = "V",
	UICurrentlyLocked = false,
}

local CONFIG_FILE = "nezux_antibat_config.json"
local BG_ASSET    = "rbxassetid://88464325604218"

local function saveConfig()
	if writefile then
		pcall(function()
			writefile(CONFIG_FILE, HttpService:JSONEncode(config))
		end)
	end
end

local function loadConfig()
	if isfile and isfile(CONFIG_FILE) then
		local ok, result = pcall(function()
			return HttpService:JSONDecode(readfile(CONFIG_FILE))
		end)
		if ok and type(result) == "table" then
			if type(result.Keybind) == "string"            then config.Keybind = result.Keybind end
			if type(result.AntiBatEnabled) == "boolean"    then config.AntiBatEnabled = result.AntiBatEnabled end
			if type(result.InfJumpEnabled) == "boolean"    then config.InfJumpEnabled = result.InfJumpEnabled end
			if type(result.UICurrentlyLocked) == "boolean" then config.UICurrentlyLocked = result.UICurrentlyLocked end
		end
	end
end

------------------------------------------------------------
-- Anti Bat core
------------------------------------------------------------
local antiBatConn   = nil
local antiBatActive = false

local function startAntiBat()
	if antiBatConn then return end
	antiBatActive = true
	antiBatConn = RunService.Heartbeat:Connect(function()
		if not antiBatActive then return end
		local character = localPlayer.Character
		if not character then return end
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		local v = hrp.Velocity
		hrp.Velocity = Vector3.new(
			math.random(-ANTIBAT_RANGE, ANTIBAT_RANGE),
			v.Y,
			math.random(-ANTIBAT_RANGE, ANTIBAT_RANGE)
		)
		RunService.RenderStepped:Wait()
		if hrp and hrp.Parent then
			hrp.Velocity = v
		end
	end)
end

local function stopAntiBat()
	antiBatActive = false
	if antiBatConn then
		antiBatConn:Disconnect()
		antiBatConn = nil
	end
end

------------------------------------------------------------
-- Inf Jump core
------------------------------------------------------------
local infJumpConn   = nil
local infJumpActive = false

local function applyInfJumpBoost(root)
	if not root then return end
	local velocity = root.AssemblyLinearVelocity
	if velocity.Y < INF_JUMP_MIN_Y then
		root.AssemblyLinearVelocity = Vector3.new(velocity.X, INF_JUMP_BOOST, velocity.Z)
	end
	if velocity.Y < INF_JUMP_MAX_FALL then
		root.AssemblyLinearVelocity = Vector3.new(velocity.X, INF_JUMP_MAX_FALL, velocity.Z)
	end
end

local function startInfJump()
	if infJumpConn then return end
	infJumpActive = true
	config.InfJumpEnabled = true
	infJumpConn = RunService.PreSimulation:Connect(function()
		if not infJumpActive then return end
		local char = localPlayer.Character
		if not char then return end
		local hum  = char:FindFirstChildOfClass("Humanoid")
		local root = char:FindFirstChild("HumanoidRootPart")
		if not hum or not root then return end
		local held = UserInputService:IsKeyDown(Enum.KeyCode.Space)
			or UserInputService:IsKeyDown(Enum.KeyCode.ButtonA)
			or (hum.Jump == true)
		if held then
			applyInfJumpBoost(root)
		else
			local v = root.AssemblyLinearVelocity
			if v.Y < INF_JUMP_MAX_FALL then
				root.AssemblyLinearVelocity = Vector3.new(v.X, INF_JUMP_MAX_FALL, v.Z)
			end
		end
	end)
end

local function stopInfJump()
	infJumpActive = false
	config.InfJumpEnabled = false
	if infJumpConn then
		infJumpConn:Disconnect()
		infJumpConn = nil
	end
end

------------------------------------------------------------
-- Theme: gray + cyan neon
------------------------------------------------------------
local C = {
	Bg          = Color3.fromRGB(12, 12, 16),
	Bg2         = Color3.fromRGB(18, 18, 24),
	Card        = Color3.fromRGB(28, 28, 36),
	CardSoft    = Color3.fromRGB(34, 34, 44),
	Divider     = Color3.fromRGB(50, 55, 70),
	DividerSoft = Color3.fromRGB(40, 44, 58),
	Accent      = Color3.fromRGB(0, 220, 255),      -- neon cyan
	AccentSoft  = Color3.fromRGB(0, 170, 210),
	AccentDim   = Color3.fromRGB(0, 120, 150),
	White       = Color3.fromRGB(245, 248, 255),
	Text        = Color3.fromRGB(240, 244, 255),
	TextSub     = Color3.fromRGB(160, 170, 190),
	TextDim     = Color3.fromRGB(100, 110, 130),
	Green       = Color3.fromRGB(60, 255, 160),
	Red         = Color3.fromRGB(255, 70, 90),
	Glow        = Color3.fromRGB(0, 200, 255),
}

local function tween(obj, props, t, style)
	TweenService:Create(obj, TweenInfo.new(t or 0.2, style or Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props):Play()
end

local function corner(obj, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 10)
	c.Parent = obj
	return c
end

local function stroke(obj, col, thick, trans)
	local s = Instance.new("UIStroke")
	s.Color = col or C.Divider
	s.Thickness = thick or 1
	s.Transparency = trans or 0
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = obj
	return s
end

local function gradient(obj, seq, rot)
	local g = Instance.new("UIGradient")
	g.Color = seq
	g.Rotation = rot or 0
	g.Parent = obj
	return g
end

------------------------------------------------------------
-- Cleanup
------------------------------------------------------------
for _, name in ipairs({
	"ZeyHubb.vs Anti Bat", "Clean Anti Bat", "Space Anti Bat",
	"Space X Hook Anti Bat", "Nezux Anti Bat", "NezuxAntiBat"
}) do
	local old = CoreGui:FindFirstChild(name)
	if old then old:Destroy() end
end

local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
local panelW   = isMobile and 230 or 260
local panelH   = isMobile and 268 or 292

------------------------------------------------------------
-- ScreenGui
------------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name           = "Nezux Anti Bat"
screenGui.ResetOnSpawn   = false
screenGui.DisplayOrder   = 25
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent         = CoreGui

------------------------------------------------------------
-- Main frame (clean borders, no outer glow frames)
------------------------------------------------------------
local frame = Instance.new("Frame")
frame.Name             = "Main"
frame.Size             = UDim2.fromOffset(panelW, panelH)
frame.Position         = UDim2.new(0.5, -panelW / 2, 0.5, -panelH / 2)
frame.BackgroundColor3 = C.Bg
frame.BorderSizePixel  = 0
frame.Active           = true
frame.ClipsDescendants = true
frame.Parent           = screenGui
corner(frame, 14)

-- single clean neon border
local mainStroke = stroke(frame, C.Accent, 1.5, 0.35)

------------------------------------------------------------
-- Background image (more visible)
------------------------------------------------------------
local bgImage = Instance.new("ImageLabel")
bgImage.Name = "BgImage"
bgImage.BackgroundTransparency = 1
bgImage.BorderSizePixel = 0
bgImage.Size = UDim2.new(1, 0, 1, 0)
bgImage.Position = UDim2.new(0, 0, 0, 0)
bgImage.Image = BG_ASSET
bgImage.ScaleType = Enum.ScaleType.Crop
bgImage.ImageTransparency = 0.18   -- more visible
bgImage.ZIndex = 0
bgImage.Parent = frame
corner(bgImage, 14)

-- lighter shade so bg shows through
local bgShade = Instance.new("Frame")
bgShade.Name = "BgShade"
bgShade.Size = UDim2.new(1, 0, 1, 0)
bgShade.BackgroundColor3 = Color3.fromRGB(8, 10, 16)
bgShade.BackgroundTransparency = 0.55
bgShade.BorderSizePixel = 0
bgShade.ZIndex = 1
bgShade.Parent = frame
corner(bgShade, 14)

gradient(bgShade, ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(14, 16, 24)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(8, 10, 16)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(4, 6, 12)),
}), 90)

-- thin neon side accent
local sideLine = Instance.new("Frame")
sideLine.Name = "SideLine"
sideLine.Size = UDim2.new(0, 2, 1, -20)
sideLine.Position = UDim2.new(0, 0, 0, 10)
sideLine.BackgroundColor3 = C.Accent
sideLine.BorderSizePixel = 0
sideLine.ZIndex = 3
sideLine.Parent = frame
corner(sideLine, 2)
gradient(sideLine, ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 255)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 180, 230)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 90, 140)),
}), 90)

------------------------------------------------------------
-- Header
------------------------------------------------------------
local header = Instance.new("Frame")
header.Name = "Header"
header.BackgroundTransparency = 1
header.Size = UDim2.new(1, 0, 0, 48)
header.Position = UDim2.new(0, 0, 0, 0)
header.Active = true
header.ZIndex = 6
header.Parent = frame

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.new(0, 14, 0, 8)
title.Size = UDim2.new(1, -90, 0, 18)
title.Font = Enum.Font.GothamBlack
title.Text = "NEZUX"
title.TextColor3 = C.White
title.TextSize = isMobile and 14 or 15
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 7
title.Parent = header
gradient(title, ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(0.6, Color3.fromRGB(180, 230, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 200, 255)),
}), 0)

local subtitle = Instance.new("TextLabel")
subtitle.BackgroundTransparency = 1
subtitle.Position = UDim2.new(0, 14, 0, 26)
subtitle.Size = UDim2.new(1, -90, 0, 14)
subtitle.Font = Enum.Font.GothamMedium
subtitle.Text = "ANTI BAT  ·  NEON"
subtitle.TextColor3 = C.AccentSoft
subtitle.TextSize = isMobile and 9 or 10
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.ZIndex = 7
subtitle.Parent = header

local headerLine = Instance.new("Frame")
headerLine.Size = UDim2.new(1, -20, 0, 1)
headerLine.Position = UDim2.new(0, 10, 1, -1)
headerLine.BackgroundColor3 = C.Accent
headerLine.BackgroundTransparency = 0.7
headerLine.BorderSizePixel = 0
headerLine.ZIndex = 6
headerLine.Parent = header

-- minimize
local collapseButton = Instance.new("TextButton")
collapseButton.Name = "Minimize"
collapseButton.AnchorPoint = Vector2.new(1, 0.5)
collapseButton.Position = UDim2.new(1, -10, 0.5, 0)
collapseButton.Size = UDim2.fromOffset(22, 22)
collapseButton.BackgroundColor3 = C.Card
collapseButton.BackgroundTransparency = 0.2
collapseButton.Text = "−"
collapseButton.TextColor3 = C.Text
collapseButton.TextSize = 14
collapseButton.Font = Enum.Font.GothamBlack
collapseButton.ZIndex = 8
collapseButton.AutoButtonColor = false
collapseButton.Parent = header
corner(collapseButton, 6)
stroke(collapseButton, C.AccentDim, 1, 0.5)

-- lock
local lockButton = Instance.new("TextButton")
lockButton.Name = "Lock"
lockButton.AnchorPoint = Vector2.new(1, 0.5)
lockButton.Position = UDim2.new(1, -36, 0.5, 0)
lockButton.Size = UDim2.fromOffset(22, 22)
lockButton.BackgroundColor3 = C.Card
lockButton.BackgroundTransparency = 0.2
lockButton.Text = config.UICurrentlyLocked and "🔒" or "🔓"
lockButton.TextColor3 = C.Text
lockButton.TextSize = 11
lockButton.Font = Enum.Font.GothamBlack
lockButton.ZIndex = 8
lockButton.AutoButtonColor = false
lockButton.Parent = header
corner(lockButton, 6)
stroke(lockButton, C.AccentDim, 1, 0.5)

------------------------------------------------------------
-- Content
------------------------------------------------------------
local content = Instance.new("Frame")
content.Name = "Content"
content.BackgroundTransparency = 1
content.Position = UDim2.new(0, 0, 0, 48)
content.Size = UDim2.new(1, 0, 1, -48)
content.ClipsDescendants = true
content.ZIndex = 4
content.Parent = frame

local collapsed = false
collapseButton.MouseButton1Click:Connect(function()
	collapsed = not collapsed
	if collapsed then
		tween(frame, { Size = UDim2.fromOffset(panelW, 48) }, 0.28)
		content.Visible = false
		collapseButton.Text = "+"
	else
		tween(frame, { Size = UDim2.fromOffset(panelW, panelH) }, 0.28)
		content.Visible = true
		collapseButton.Text = "−"
	end
end)

------------------------------------------------------------
-- Status
------------------------------------------------------------
local statusCard = Instance.new("Frame")
statusCard.Name = "StatusCard"
statusCard.Position = UDim2.new(0, 12, 0, 10)
statusCard.Size = UDim2.new(1, -24, 0, isMobile and 36 or 38)
statusCard.BackgroundColor3 = C.Card
statusCard.BackgroundTransparency = 0.25
statusCard.BorderSizePixel = 0
statusCard.ZIndex = 5
statusCard.Parent = content
corner(statusCard, 10)
stroke(statusCard, C.AccentDim, 1, 0.55)

local statusDot = Instance.new("Frame")
statusDot.Name = "Dot"
statusDot.Position = UDim2.new(0, 12, 0.5, -4)
statusDot.Size = UDim2.fromOffset(8, 8)
statusDot.BackgroundColor3 = C.Red
statusDot.BorderSizePixel = 0
statusDot.ZIndex = 7
statusDot.Parent = statusCard
corner(statusDot, 99)

local pulse = Instance.new("Frame")
pulse.Name = "Pulse"
pulse.AnchorPoint = Vector2.new(0.5, 0.5)
pulse.Position = UDim2.new(0.5, 0, 0.5, 0)
pulse.Size = UDim2.fromOffset(8, 8)
pulse.BackgroundColor3 = C.Red
pulse.BackgroundTransparency = 0.65
pulse.BorderSizePixel = 0
pulse.ZIndex = 6
pulse.Parent = statusDot
corner(pulse, 99)

local statusLabel = Instance.new("TextLabel")
statusLabel.BackgroundTransparency = 1
statusLabel.Position = UDim2.new(0, 28, 0, 0)
statusLabel.Size = UDim2.new(0, 70, 1, 0)
statusLabel.Font = Enum.Font.GothamMedium
statusLabel.Text = "STATUS"
statusLabel.TextColor3 = C.TextSub
statusLabel.TextSize = isMobile and 10 or 11
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.ZIndex = 7
statusLabel.Parent = statusCard

local statusValue = Instance.new("TextLabel")
statusValue.BackgroundTransparency = 1
statusValue.Position = UDim2.new(1, -78, 0, 0)
statusValue.Size = UDim2.new(0, 68, 1, 0)
statusValue.Font = Enum.Font.GothamBlack
statusValue.Text = "INACTIVE"
statusValue.TextColor3 = C.Red
statusValue.TextSize = isMobile and 11 or 12
statusValue.TextXAlignment = Enum.TextXAlignment.Right
statusValue.ZIndex = 7
statusValue.Parent = statusCard

local function refreshStatus()
	local active = antiBatActive or infJumpActive
	statusValue.Text = active and "ACTIVE" or "INACTIVE"
	statusValue.TextColor3 = active and C.Green or C.Red
	statusDot.BackgroundColor3 = active and C.Green or C.Red
	pulse.BackgroundColor3 = active and C.Green or C.Red
	-- neon border reacts to active state
	tween(mainStroke, {
		Color = active and C.Accent or C.AccentDim,
		Transparency = active and 0.15 or 0.35
	}, 0.25)
end

task.spawn(function()
	while statusDot and statusDot.Parent do
		if pulse and pulse.Parent then
			tween(pulse, { Size = UDim2.fromOffset(16, 16), BackgroundTransparency = 0.9 }, 0.65)
			task.wait(0.7)
			if pulse and pulse.Parent then
				tween(pulse, { Size = UDim2.fromOffset(8, 8), BackgroundTransparency = 0.65 }, 0.5)
			end
		end
		task.wait(0.55)
	end
end)

------------------------------------------------------------
-- Toggles
------------------------------------------------------------
local antiBatAnimate, infJumpAnimate

local function makeToggle(parent, y, label, initialState, onToggle)
	local row = Instance.new("Frame")
	row.Position = UDim2.new(0, 12, 0, y)
	row.Size = UDim2.new(1, -24, 0, isMobile and 42 or 46)
	row.BackgroundColor3 = C.Card
	row.BackgroundTransparency = 0.25
	row.BorderSizePixel = 0
	row.ZIndex = 5
	row.Parent = parent
	corner(row, 10)
	local rowStroke = stroke(row, initialState and C.Accent or C.Divider, 1, initialState and 0.35 or 0.6)

	local leftBar = Instance.new("Frame")
	leftBar.Size = UDim2.new(0, 2, 1, -12)
	leftBar.Position = UDim2.new(0, 0, 0, 6)
	leftBar.BackgroundColor3 = initialState and C.Accent or C.Divider
	leftBar.BorderSizePixel = 0
	leftBar.ZIndex = 6
	leftBar.Parent = row
	corner(leftBar, 2)

	local text = Instance.new("TextLabel")
	text.BackgroundTransparency = 1
	text.Position = UDim2.new(0, 12, 0, 5)
	text.Size = UDim2.new(0, 120, 0, 16)
	text.Font = Enum.Font.GothamBlack
	text.Text = label
	text.TextColor3 = initialState and C.White or C.TextSub
	text.TextSize = isMobile and 12 or 13
	text.TextXAlignment = Enum.TextXAlignment.Left
	text.ZIndex = 7
	text.Parent = row

	local sub = Instance.new("TextLabel")
	sub.BackgroundTransparency = 1
	sub.Position = UDim2.new(0, 12, 0, 22)
	sub.Size = UDim2.new(0, 130, 0, 14)
	sub.Font = Enum.Font.Gotham
	sub.Text = label == "Anti Bat" and "velocity jitter" or "space boost"
	sub.TextColor3 = C.TextDim
	sub.TextSize = isMobile and 9 or 10
	sub.TextXAlignment = Enum.TextXAlignment.Left
	sub.ZIndex = 7
	sub.Parent = row

	local track = Instance.new("Frame")
	track.Position = UDim2.new(1, -52, 0.5, -10)
	track.Size = UDim2.fromOffset(40, 20)
	track.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
	track.BorderSizePixel = 0
	track.ZIndex = 7
	track.Parent = row
	corner(track, 99)
	local trackStroke = stroke(track, initialState and C.Accent or C.Divider, 1.2, initialState and 0.2 or 0.55)

	local aura = Instance.new("Frame")
	aura.Name = "Aura"
	aura.Position = UDim2.new(1, -56, 0.5, -14)
	aura.Size = UDim2.fromOffset(48, 28)
	aura.BackgroundColor3 = C.Accent
	aura.BackgroundTransparency = initialState and 0.78 or 1
	aura.BorderSizePixel = 0
	aura.ZIndex = 6
	aura.Parent = row
	corner(aura, 99)

	local knob = Instance.new("Frame")
	knob.Position = initialState and UDim2.new(1, -18, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
	knob.Size = UDim2.fromOffset(14, 14)
	knob.BackgroundColor3 = initialState and C.Accent or Color3.fromRGB(160, 170, 185)
	knob.BorderSizePixel = 0
	knob.ZIndex = 8
	knob.Parent = track
	corner(knob, 99)

	local hit = Instance.new("TextButton")
	hit.Position = UDim2.new(1, -58, 0, 0)
	hit.Size = UDim2.fromOffset(50, isMobile and 42 or 46)
	hit.BackgroundTransparency = 1
	hit.Text = ""
	hit.ZIndex = 12
	hit.Parent = row

	local function animate(state)
		local pos = state and UDim2.new(1, -18, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
		local knobBg = state and C.Accent or Color3.fromRGB(160, 170, 185)
		tween(knob, { Position = pos, BackgroundColor3 = knobBg }, 0.18)
		tween(trackStroke, { Transparency = state and 0.2 or 0.55, Color = state and C.Accent or C.Divider }, 0.18)
		tween(aura, { BackgroundTransparency = state and 0.78 or 1 }, 0.2)
		tween(leftBar, { BackgroundColor3 = state and C.Accent or C.Divider }, 0.18)
		tween(text, { TextColor3 = state and C.White or C.TextSub }, 0.16)
		tween(rowStroke, { Transparency = state and 0.35 or 0.6, Color = state and C.Accent or C.Divider }, 0.18)
	end

	hit.MouseButton1Click:Connect(function()
		onToggle()
		if label == "Anti Bat" then
			animate(antiBatActive)
		else
			animate(infJumpActive)
		end
		refreshStatus()
		saveConfig()
	end)

	hit.MouseEnter:Connect(function()
		tween(row, { BackgroundTransparency = 0.12 }, 0.12)
	end)
	hit.MouseLeave:Connect(function()
		tween(row, { BackgroundTransparency = 0.25 }, 0.12)
	end)

	return animate
end

antiBatAnimate = makeToggle(content, isMobile and 54 or 56, "Anti Bat", config.AntiBatEnabled, function()
	if not antiBatActive then
		startAntiBat()
		config.AntiBatEnabled = true
	else
		stopAntiBat()
		config.AntiBatEnabled = false
	end
end)

infJumpAnimate = makeToggle(content, isMobile and 102 or 108, "Inf Jump", config.InfJumpEnabled, function()
	if not infJumpActive then
		startInfJump()
	else
		stopInfJump()
	end
end)

------------------------------------------------------------
-- Keybind
------------------------------------------------------------
local keybindCard = Instance.new("Frame")
keybindCard.Position = UDim2.new(0, 12, 0, isMobile and 152 or 162)
keybindCard.Size = UDim2.new(1, -24, 0, isMobile and 36 or 38)
keybindCard.BackgroundColor3 = C.Card
keybindCard.BackgroundTransparency = 0.25
keybindCard.BorderSizePixel = 0
keybindCard.ZIndex = 5
keybindCard.Parent = content
corner(keybindCard, 10)
stroke(keybindCard, C.Divider, 1, 0.55)

local keybindLabel = Instance.new("TextLabel")
keybindLabel.BackgroundTransparency = 1
keybindLabel.Position = UDim2.new(0, 12, 0, 0)
keybindLabel.Size = UDim2.new(0, 80, 1, 0)
keybindLabel.Font = Enum.Font.GothamMedium
keybindLabel.Text = "KEYBIND"
keybindLabel.TextColor3 = C.TextSub
keybindLabel.TextSize = isMobile and 10 or 11
keybindLabel.TextXAlignment = Enum.TextXAlignment.Left
keybindLabel.ZIndex = 7
keybindLabel.Parent = keybindCard

local keybindButton = Instance.new("TextButton")
keybindButton.AnchorPoint = Vector2.new(1, 0.5)
keybindButton.Position = UDim2.new(1, -10, 0.5, 0)
keybindButton.Size = UDim2.fromOffset(48, 22)
keybindButton.BackgroundColor3 = Color3.fromRGB(10, 14, 22)
keybindButton.BackgroundTransparency = 0.15
keybindButton.Text = config.Keybind
keybindButton.TextColor3 = C.Accent
keybindButton.TextSize = isMobile and 10 or 11
keybindButton.Font = Enum.Font.GothamBlack
keybindButton.ZIndex = 8
keybindButton.AutoButtonColor = false
keybindButton.Parent = keybindCard
corner(keybindButton, 6)
stroke(keybindButton, C.AccentDim, 1, 0.4)

local listening = false
local listenConnection = nil

keybindButton.MouseButton1Click:Connect(function()
	if listening then
		if listenConnection then listenConnection:Disconnect() listenConnection = nil end
		listening = false
		keybindButton.Text = config.Keybind
		keybindButton.TextColor3 = C.Accent
		return
	end
	listening = true
	keybindButton.Text = "..."
	keybindButton.TextColor3 = C.Red
	listenConnection = UserInputService.InputBegan:Connect(function(input)
		if not listening then return end
		if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
		if input.KeyCode == Enum.KeyCode.Escape then
			listening = false
			keybindButton.Text = config.Keybind
			keybindButton.TextColor3 = C.Accent
			if listenConnection then listenConnection:Disconnect() listenConnection = nil end
			return
		end
		config.Keybind = input.KeyCode.Name
		keybindButton.Text = config.Keybind
		keybindButton.TextColor3 = C.Accent
		listening = false
		if listenConnection then listenConnection:Disconnect() listenConnection = nil end
		saveConfig()
	end)
end)

------------------------------------------------------------
-- Footer
------------------------------------------------------------
local footer = Instance.new("Frame")
footer.Position = UDim2.new(0, 12, 1, isMobile and -34 or -36)
footer.Size = UDim2.new(1, -24, 0, 24)
footer.BackgroundTransparency = 1
footer.ZIndex = 5
footer.Parent = content

local footerLine = Instance.new("Frame")
footerLine.Size = UDim2.new(1, 0, 0, 1)
footerLine.Position = UDim2.new(0, 0, 0, 0)
footerLine.BackgroundColor3 = C.Accent
footerLine.BackgroundTransparency = 0.75
footerLine.BorderSizePixel = 0
footerLine.ZIndex = 5
footerLine.Parent = footer

local footerText = Instance.new("TextLabel")
footerText.BackgroundTransparency = 1
footerText.Position = UDim2.new(0, 0, 0, 4)
footerText.Size = UDim2.new(1, 0, 0, 16)
footerText.Font = Enum.Font.Gotham
footerText.Text = "nezux  ·  anti bat"
footerText.TextColor3 = C.TextDim
footerText.TextSize = isMobile and 9 or 10
footerText.TextXAlignment = Enum.TextXAlignment.Center
footerText.ZIndex = 6
footerText.Parent = footer

------------------------------------------------------------
-- Hotkey
------------------------------------------------------------
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
	if input.KeyCode.Name ~= config.Keybind then return end
	if not antiBatActive then
		startAntiBat()
		config.AntiBatEnabled = true
	else
		stopAntiBat()
		config.AntiBatEnabled = false
	end
	antiBatAnimate(antiBatActive)
	refreshStatus()
	saveConfig()
end)

------------------------------------------------------------
-- Drag + lock
------------------------------------------------------------
local dragging = false
local dragStart = nil
local startPos = nil
local touchIndex = nil

local function clampToViewport(pos)
	local cam = workspace.CurrentCamera
	local viewport = cam and cam.ViewportSize or Vector2.new(1280, 720)
	local inset = GuiService:GetGuiInset()
	local x = math.clamp(pos.X.Offset + pos.X.Scale * viewport.X, 0,
		math.max(0, viewport.X - frame.AbsoluteSize.X))
	local y = math.clamp(pos.Y.Offset + pos.Y.Scale * (viewport.Y - inset.Y), 0,
		math.max(0, viewport.Y - inset.Y - frame.AbsoluteSize.Y))
	return UDim2.fromOffset(x, y)
end

local function beginDrag(input)
	if config.UICurrentlyLocked then return end
	dragging = true
	dragStart = input.Position
	startPos = frame.Position
	touchIndex = input.UserInputType == Enum.UserInputType.Touch and input.UserInputIndex or nil
end

lockButton.MouseButton1Click:Connect(function()
	config.UICurrentlyLocked = not config.UICurrentlyLocked
	lockButton.Text = config.UICurrentlyLocked and "🔒" or "🔓"
	if config.UICurrentlyLocked then
		dragging = false
		touchIndex = nil
	end
	saveConfig()
end)

header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		beginDrag(input)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not dragging then return end
	local isTouch = input.UserInputType == Enum.UserInputType.Touch
	if isTouch or input.UserInputType == Enum.UserInputType.MouseMovement then
		if isTouch and touchIndex and input.UserInputIndex ~= touchIndex then return end
		local delta = input.Position - dragStart
		frame.Position = clampToViewport(UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y))
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if not dragging then return end
	local isTouch = input.UserInputType == Enum.UserInputType.Touch
	if isTouch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		if isTouch and touchIndex and input.UserInputIndex ~= touchIndex then return end
		dragging = false
		touchIndex = nil
	end
end)

------------------------------------------------------------
-- Boot
------------------------------------------------------------
loadConfig()

if config.AntiBatEnabled then
	startAntiBat()
	antiBatAnimate(true)
end
if config.InfJumpEnabled then
	startInfJump()
	infJumpAnimate(true)
end
refreshStatus()

frame.Size = UDim2.fromOffset(0, 0)
frame.BackgroundTransparency = 1
bgImage.ImageTransparency = 1
bgShade.BackgroundTransparency = 1
TweenService:Create(frame, TweenInfo.new(0.32, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
	Size = UDim2.fromOffset(panelW, panelH),
	BackgroundTransparency = 0
}):Play()
TweenService:Create(bgImage, TweenInfo.new(0.4), { ImageTransparency = 0.18 }):Play()
TweenService:Create(bgShade, TweenInfo.new(0.38), { BackgroundTransparency = 0.55 }):Play()

print("[Nezux Anti Bat] loaded — neon + smaller")
