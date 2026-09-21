--// WRECK MINER
--// Full updated version

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local PathfindingService = game:GetService("PathfindingService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--==================================================
-- CONFIG
--==================================================

local INVENTORY_LIMIT = 365

local WRECK_ARRIVAL_DISTANCE = 7
local SELLER_ARRIVAL_DISTANCE = 7
local WALL_ARRIVAL_DISTANCE = 5

local SELLER_JUMP_INTERVAL = 4

local DEFAULT_WALKSPEED = 16

local RESOURCE_NAMES = {
	"Opal",
	"Rock",
	"LapisLazuli",
	"Illite",
	"Tungsten",
	"Aquamarine",
	"Uraninite",
	"Bismuth",
	"Jadeite",
	"Painite",
	"Green Zircon"
}

--==================================================
-- SETTINGS
--==================================================

local TargetTiers = {
	[1] = true,
	[2] = true,
	[3] = true,
	[4] = true,
	[5] = true
}

local FallbackToTier1 = true
local PrioritizeHigherTiers = false
local CurrentWalkSpeed = DEFAULT_WALKSPEED

--==================================================
-- STATE
--==================================================

local Enabled = false
local State = "Idle"
local TargetWreck = nil

--==================================================
-- GUI
--==================================================

local ExistingGui = PlayerGui:FindFirstChild("WreckMinerGui")

if ExistingGui then
	ExistingGui:Destroy()
end

local Gui = Instance.new("ScreenGui")
Gui.Name = "WreckMinerGui"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = PlayerGui

--==================================================
-- MAIN PANEL
--==================================================

local Panel = Instance.new("Frame")
Panel.Name = "Panel"
Panel.Size = UDim2.fromOffset(290, 365)
Panel.Position = UDim2.fromOffset(30, 200)
Panel.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Panel.BorderSizePixel = 0
Panel.Parent = Gui

local PanelCorner = Instance.new("UICorner")
PanelCorner.CornerRadius = UDim.new(0, 12)
PanelCorner.Parent = Panel

local PanelStroke = Instance.new("UIStroke")
PanelStroke.Color = Color3.fromRGB(65, 65, 75)
PanelStroke.Thickness = 1.5
PanelStroke.Parent = Panel

--==================================================
-- TITLE
--==================================================

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -90, 0, 30)
Title.Position = UDim2.fromOffset(14, 8)
Title.BackgroundTransparency = 1
Title.Text = "Wreck Miner"
Title.TextColor3 = Color3.fromRGB(240, 240, 245)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Panel

--==================================================
-- STATUS
--==================================================

local Status = Instance.new("TextLabel")
Status.Name = "Status"
Status.Size = UDim2.new(1, -90, 0, 25)
Status.Position = UDim2.fromOffset(14, 40)
Status.BackgroundTransparency = 1
Status.Text = "Disabled"
Status.TextColor3 = Color3.fromRGB(150, 150, 160)
Status.TextSize = 13
Status.Font = Enum.Font.Gotham
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Parent = Panel

--==================================================
-- MAIN SWITCH
--==================================================

local Switch = Instance.new("Frame")
Switch.Name = "Switch"
Switch.Size = UDim2.fromOffset(58, 32)
Switch.Position = UDim2.new(1, -72, 0, 18)
Switch.BackgroundColor3 = Color3.fromRGB(65, 65, 75)
Switch.BorderSizePixel = 0
Switch.Parent = Panel

local SwitchCorner = Instance.new("UICorner")
SwitchCorner.CornerRadius = UDim.new(1, 0)
SwitchCorner.Parent = Switch

local Knob = Instance.new("Frame")
Knob.Name = "Knob"
Knob.Size = UDim2.fromOffset(26, 26)
Knob.Position = UDim2.fromOffset(3, 3)
Knob.BackgroundColor3 = Color3.fromRGB(235, 235, 240)
Knob.BorderSizePixel = 0
Knob.Parent = Switch

local KnobCorner = Instance.new("UICorner")
KnobCorner.CornerRadius = UDim.new(1, 0)
KnobCorner.Parent = Knob

local Toggle = Instance.new("TextButton")
Toggle.Name = "Toggle"
Toggle.Size = UDim2.fromScale(1, 1)
Toggle.BackgroundTransparency = 1
Toggle.BorderSizePixel = 0
Toggle.Text = ""
Toggle.AutoButtonColor = false
Toggle.ZIndex = 10
Toggle.Parent = Switch

--==================================================
-- WALK SPEED
--==================================================

local WalkSpeedLabel = Instance.new("TextLabel")
WalkSpeedLabel.Name = "WalkSpeedLabel"
WalkSpeedLabel.Size = UDim2.fromOffset(100, 25)
WalkSpeedLabel.Position = UDim2.fromOffset(14, 78)
WalkSpeedLabel.BackgroundTransparency = 1
WalkSpeedLabel.Text = "WalkSpeed"
WalkSpeedLabel.TextColor3 = Color3.fromRGB(220, 220, 225)
WalkSpeedLabel.TextSize = 14
WalkSpeedLabel.Font = Enum.Font.GothamMedium
WalkSpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
WalkSpeedLabel.Parent = Panel

local WalkSpeedInput = Instance.new("TextBox")
WalkSpeedInput.Name = "WalkSpeedInput"
WalkSpeedInput.Size = UDim2.fromOffset(105, 30)
WalkSpeedInput.Position = UDim2.new(1, -119, 0, 73)
WalkSpeedInput.BackgroundColor3 = Color3.fromRGB(40, 40, 47)
WalkSpeedInput.BorderSizePixel = 0
WalkSpeedInput.Text = tostring(DEFAULT_WALKSPEED)
WalkSpeedInput.TextColor3 = Color3.fromRGB(240, 240, 245)
WalkSpeedInput.PlaceholderText = "Speed"
WalkSpeedInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
WalkSpeedInput.TextSize = 14
WalkSpeedInput.Font = Enum.Font.Gotham
WalkSpeedInput.ClearTextOnFocus = false
WalkSpeedInput.Parent = Panel

local WalkSpeedCorner = Instance.new("UICorner")
WalkSpeedCorner.CornerRadius = UDim.new(0, 7)
WalkSpeedCorner.Parent = WalkSpeedInput

local WalkSpeedStroke = Instance.new("UIStroke")
WalkSpeedStroke.Color = Color3.fromRGB(65, 65, 75)
WalkSpeedStroke.Thickness = 1
WalkSpeedStroke.Parent = WalkSpeedInput

--==================================================
-- TIER SWITCHES
--==================================================

local TierSwitches = {}

local function CreateTierSwitch(Tier, Y)

	local Label = Instance.new("TextLabel")
	Label.Name = "Tier" .. Tier .. "Label"
	Label.Size = UDim2.fromOffset(150, 25)
	Label.Position = UDim2.fromOffset(14, Y)
	Label.BackgroundTransparency = 1
	Label.Text = "Target Tier " .. Tier
	Label.TextColor3 = Color3.fromRGB(220, 220, 225)
	Label.TextSize = 14
	Label.Font = Enum.Font.GothamMedium
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Panel

	local Frame = Instance.new("Frame")
	Frame.Name = "Tier" .. Tier .. "Switch"
	Frame.Size = UDim2.fromOffset(48, 26)
	Frame.Position = UDim2.new(1, -64, 0, Y - 1)
	Frame.BackgroundColor3 = Color3.fromRGB(55, 175, 90)
	Frame.BorderSizePixel = 0
	Frame.Parent = Panel

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(1, 0)
	Corner.Parent = Frame

	local TierKnob = Instance.new("Frame")
	TierKnob.Name = "Knob"
	TierKnob.Size = UDim2.fromOffset(20, 20)
	TierKnob.Position = UDim2.new(1, -23, 0, 3)
	TierKnob.BackgroundColor3 = Color3.fromRGB(235, 235, 240)
	TierKnob.BorderSizePixel = 0
	TierKnob.Parent = Frame

	local TierKnobCorner = Instance.new("UICorner")
	TierKnobCorner.CornerRadius = UDim.new(1, 0)
	TierKnobCorner.Parent = TierKnob

	local Button = Instance.new("TextButton")
	Button.Name = "Button"
	Button.Size = UDim2.fromScale(1, 1)
	Button.BackgroundTransparency = 1
	Button.BorderSizePixel = 0
	Button.Text = ""
	Button.AutoButtonColor = false
	Button.ZIndex = 10
	Button.Parent = Frame

	TierSwitches[Tier] = {
		Frame = Frame,
		Knob = TierKnob,
		Button = Button
	}

	Button.Activated:Connect(function()

		TargetTiers[Tier] = not TargetTiers[Tier]

		if TargetTiers[Tier] then

			Frame.BackgroundColor3 =
				Color3.fromRGB(55, 175, 90)

			TierKnob.Position =
				UDim2.new(1, -23, 0, 3)

		else

			Frame.BackgroundColor3 =
				Color3.fromRGB(65, 65, 75)

			TierKnob.Position =
				UDim2.fromOffset(3, 3)

			-- Force a new search if the current target
			-- belongs to the tier that was disabled.
			if TargetWreck then

				local Tiers = getWreckTiers()

				if Tiers and Tiers[Tier] then

					if TargetWreck:IsDescendantOf(
						Tiers[Tier]
					) then

						TargetWreck = nil

					end

				end

			end

		end

	end)

end

CreateTierSwitch(1, 113)
CreateTierSwitch(2, 143)
CreateTierSwitch(3, 173)
CreateTierSwitch(4, 203)
CreateTierSwitch(5, 233)

--==================================================
-- FALLBACK TO TIER 1
--==================================================

local FallbackLabel = Instance.new("TextLabel")
FallbackLabel.Name = "FallbackLabel"
FallbackLabel.Size = UDim2.fromOffset(190, 25)
FallbackLabel.Position = UDim2.fromOffset(14, 263)
FallbackLabel.BackgroundTransparency = 1
FallbackLabel.Text = "Fallback to Tier 1"
FallbackLabel.TextColor3 = Color3.fromRGB(220, 220, 225)
FallbackLabel.TextSize = 14
FallbackLabel.Font = Enum.Font.GothamMedium
FallbackLabel.TextXAlignment = Enum.TextXAlignment.Left
FallbackLabel.Parent = Panel

local FallbackSwitch = Instance.new("Frame")
FallbackSwitch.Name = "FallbackSwitch"
FallbackSwitch.Size = UDim2.fromOffset(48, 26)
FallbackSwitch.Position = UDim2.new(1, -64, 0, 262)
FallbackSwitch.BackgroundColor3 = Color3.fromRGB(55, 175, 90)
FallbackSwitch.BorderSizePixel = 0
FallbackSwitch.Parent = Panel

local FallbackCorner = Instance.new("UICorner")
FallbackCorner.CornerRadius = UDim.new(1, 0)
FallbackCorner.Parent = FallbackSwitch

local FallbackKnob = Instance.new("Frame")
FallbackKnob.Name = "Knob"
FallbackKnob.Size = UDim2.fromOffset(20, 20)
FallbackKnob.Position = UDim2.new(1, -23, 0, 3)
FallbackKnob.BackgroundColor3 = Color3.fromRGB(235, 235, 240)
FallbackKnob.BorderSizePixel = 0
FallbackKnob.Parent = FallbackSwitch

local FallbackKnobCorner = Instance.new("UICorner")
FallbackKnobCorner.CornerRadius = UDim.new(1, 0)
FallbackKnobCorner.Parent = FallbackKnob

local FallbackButton = Instance.new("TextButton")
FallbackButton.Name = "Button"
FallbackButton.Size = UDim2.fromScale(1, 1)
FallbackButton.BackgroundTransparency = 1
FallbackButton.BorderSizePixel = 0
FallbackButton.Text = ""
FallbackButton.AutoButtonColor = false
FallbackButton.ZIndex = 10
FallbackButton.Parent = FallbackSwitch

FallbackButton.Activated:Connect(function()
	FallbackToTier1 = not FallbackToTier1
	TargetWreck = nil

	if FallbackToTier1 then
		FallbackSwitch.BackgroundColor3 = Color3.fromRGB(55, 175, 90)
		FallbackKnob.Position = UDim2.new(1, -23, 0, 3)
	else
		FallbackSwitch.BackgroundColor3 = Color3.fromRGB(65, 65, 75)
		FallbackKnob.Position = UDim2.fromOffset(3, 3)
	end
end)

--==================================================
-- PRIORITIZE HIGHER TIERS
--==================================================

local PriorityLabel = Instance.new("TextLabel")
PriorityLabel.Name = "PriorityLabel"
PriorityLabel.Size = UDim2.fromOffset(190, 25)
PriorityLabel.Position = UDim2.fromOffset(14, 293)
PriorityLabel.BackgroundTransparency = 1
PriorityLabel.Text = "Prioritize Higher Tiers"
PriorityLabel.TextColor3 = Color3.fromRGB(220, 220, 225)
PriorityLabel.TextSize = 14
PriorityLabel.Font = Enum.Font.GothamMedium
PriorityLabel.TextXAlignment = Enum.TextXAlignment.Left
PriorityLabel.Parent = Panel

local PrioritySwitch = Instance.new("Frame")
PrioritySwitch.Name = "PrioritySwitch"
PrioritySwitch.Size = UDim2.fromOffset(48, 26)
PrioritySwitch.Position = UDim2.new(1, -64, 0, 292)
PrioritySwitch.BackgroundColor3 = Color3.fromRGB(65, 65, 75)
PrioritySwitch.BorderSizePixel = 0
PrioritySwitch.Parent = Panel

local PriorityCorner = Instance.new("UICorner")
PriorityCorner.CornerRadius = UDim.new(1, 0)
PriorityCorner.Parent = PrioritySwitch

local PriorityKnob = Instance.new("Frame")
PriorityKnob.Name = "Knob"
PriorityKnob.Size = UDim2.fromOffset(20, 20)
PriorityKnob.Position = UDim2.fromOffset(3, 3)
PriorityKnob.BackgroundColor3 = Color3.fromRGB(235, 235, 240)
PriorityKnob.BorderSizePixel = 0
PriorityKnob.Parent = PrioritySwitch

local PriorityKnobCorner = Instance.new("UICorner")
PriorityKnobCorner.CornerRadius = UDim.new(1, 0)
PriorityKnobCorner.Parent = PriorityKnob

local PriorityButton = Instance.new("TextButton")
PriorityButton.Name = "Button"
PriorityButton.Size = UDim2.fromScale(1, 1)
PriorityButton.BackgroundTransparency = 1
PriorityButton.BorderSizePixel = 0
PriorityButton.Text = ""
PriorityButton.AutoButtonColor = false
PriorityButton.ZIndex = 10
PriorityButton.Parent = PrioritySwitch

PriorityButton.Activated:Connect(function()

	PrioritizeHigherTiers =
		not PrioritizeHigherTiers

	TargetWreck = nil

	if PrioritizeHigherTiers then

		PrioritySwitch.BackgroundColor3 =
			Color3.fromRGB(55, 175, 90)

		PriorityKnob.Position =
			UDim2.new(1, -23, 0, 3)

	else

		PrioritySwitch.BackgroundColor3 =
			Color3.fromRGB(65, 65, 75)

		PriorityKnob.Position =
			UDim2.fromOffset(3, 3)

	end

end)

--==================================================
-- DRAGGING
--==================================================

local DragArea = Instance.new("TextButton")
DragArea.Name = "DragArea"
DragArea.Size = UDim2.new(1, -82, 0, 65)
DragArea.Position = UDim2.fromOffset(0, 0)
DragArea.BackgroundTransparency = 1
DragArea.BorderSizePixel = 0
DragArea.Text = ""
DragArea.AutoButtonColor = false
DragArea.ZIndex = 5
DragArea.Parent = Panel

local Dragging = false
local DragStart
local StartPosition

DragArea.InputBegan:Connect(function(Input)

	if Input.UserInputType ==
		Enum.UserInputType.MouseButton1 then

		Dragging = true
		DragStart = Input.Position
		StartPosition = Panel.Position

	end

end)

DragArea.InputEnded:Connect(function(Input)

	if Input.UserInputType ==
		Enum.UserInputType.MouseButton1 then

		Dragging = false

	end

end)

UserInputService.InputChanged:Connect(function(Input)

	if not Dragging then
		return
	end

	if Input.UserInputType ~=
		Enum.UserInputType.MouseMovement then
		return
	end

	local Delta =
		Input.Position - DragStart

	Panel.Position =
		UDim2.new(
			StartPosition.X.Scale,
			StartPosition.X.Offset + Delta.X,
			StartPosition.Y.Scale,
			StartPosition.Y.Offset + Delta.Y
		)

end)

--==================================================
-- CHARACTER HELPERS
--==================================================

local function GetCharacter()
	return Player.Character
end

local function GetHumanoid()

	local Character = GetCharacter()

	if not Character then
		return nil
	end

	return Character:FindFirstChildOfClass(
		"Humanoid"
	)

end

local function GetRoot()

	local Character = GetCharacter()

	if not Character then
		return nil
	end

	return Character:FindFirstChild(
		"HumanoidRootPart"
	)

end

--==================================================
-- WALK SPEED
--==================================================

local function ApplyWalkSpeed()

	local Humanoid = GetHumanoid()

	if Humanoid then
		Humanoid.WalkSpeed =
			CurrentWalkSpeed
	end

end

local function SetWalkSpeed(Value)

	if typeof(Value) ~= "number" then
		return
	end

	if Value < 0 then
		Value = 0
	end

	CurrentWalkSpeed = Value

	ApplyWalkSpeed()

end

WalkSpeedInput.FocusLost:Connect(function()

	local Value =
		tonumber(WalkSpeedInput.Text)

	if Value then

		if Value < 0 then
			Value = 0
		end

		SetWalkSpeed(Value)

		WalkSpeedInput.Text =
			tostring(Value)

	else

		WalkSpeedInput.Text =
			tostring(CurrentWalkSpeed)

	end

end)

Player.CharacterAdded:Connect(function(Character)

	local Humanoid =
		Character:WaitForChild(
			"Humanoid"
		)

	Humanoid.WalkSpeed =
		CurrentWalkSpeed

end)

--==================================================
-- POSITION HELPER
--==================================================

local function GetPosition(Object)

	if not Object then
		return nil
	end

	if Object:IsA("BasePart") then
		return Object.Position
	end

	if Object:IsA("Model") then

		if Object.PrimaryPart then
			return Object.PrimaryPart.Position
		end

		local Part =
			Object:FindFirstChildWhichIsA(
				"BasePart",
				true
			)

		if Part then
			return Part.Position
		end

	end

	return nil

end

--==================================================
-- GAME REFERENCES
--==================================================

local function GetWreckTiers()

	local Containers =
		workspace:FindFirstChild(
			"Containers"
		)

	if not Containers then
		return nil
	end

	local TrainStation =
		Containers:FindFirstChild(
			"TrainStationContainer"
		)

	if not TrainStation then
		return nil
	end

	local RuinedStation =
		TrainStation:FindFirstChild(
			"RuinedStationContainer"
		)

	if not RuinedStation then
		return nil
	end

	local WreckContainer =
		RuinedStation:FindFirstChild(
			"WreckContainer"
		)

	if not WreckContainer then
		return nil
	end

	local Tiers = {}

	for Tier = 1, 5 do

		Tiers[Tier] =
			WreckContainer:FindFirstChild(
				"Tier" .. Tier
			)

	end

	return Tiers

end

local function GetSeller()

	local Containers =
		workspace:FindFirstChild(
			"Containers"
		)

	if not Containers then
		return nil
	end

	local InterfaceZone =
		Containers:FindFirstChild(
			"InterfaceZoneContainer"
		)

	if not InterfaceZone then
		return nil
	end

	return InterfaceZone:FindFirstChild(
		"RuinedStationFrame"
	)

end

local function GetWall()

	local Etc =
		workspace:FindFirstChild(
			"etc"
		)

	if not Etc then
		return nil
	end

	return Etc:FindFirstChild(
		"Wall"
	)

end

--==================================================
-- STOP MOVEMENT
--==================================================

local function StopMovement()

	local Humanoid = GetHumanoid()
	local Root = GetRoot()

	if Humanoid and Root then
		Humanoid:MoveTo(Root.Position)
	end

end

--==================================================
-- DIRECT MOVEMENT
--==================================================

local function MoveDirectlyTo(Position)

	local Humanoid = GetHumanoid()

	if Humanoid and Position then
		Humanoid:MoveTo(Position)
	end

end

--==================================================
-- WRECK LIST
--==================================================

local function GetWrecksInTier(Tier)

	local Wrecks = {}

	if not Tier then
		return Wrecks
	end

	for _, Object in ipairs(
		Tier:GetChildren()
	) do

		local Wreck = nil

		-- Preserve the existing WreckModel
		-- lookup behavior.
		if Object:IsA("NumberValue")
			or Object:IsA("IntValue") then

			Wreck =
				Object:FindFirstChild(
					"WreckModel"
				)

		else

			Wreck =
				Object:FindFirstChild(
					"WreckModel"
				)

		end

		if Wreck
			and Wreck:IsA("Model")
			and GetPosition(Wreck) then

			table.insert(
				Wrecks,
				Wreck
			)

		end

	end

	return Wrecks

end

--==================================================
-- WRECK VALIDATION
--==================================================

local function IsValidWreck(Wreck)

	if not Wreck then
		return false
	end

	if not Wreck:IsA("Model") then
		return false
	end

	if not Wreck.Parent then
		return false
	end

	if not GetPosition(Wreck) then
		return false
	end

	local Tiers =
		GetWreckTiers()

	if not Tiers then
		return false
	end

	for Tier = 1, 5 do

		if TargetTiers[Tier]
			and Tiers[Tier]
			and Wreck:IsDescendantOf(
				Tiers[Tier]
			) then

			return true

		end

	end

	return false

end

--==================================================
-- NEAREST WRECK IN TIER
--==================================================

local function GetNearestWreckInTier(Tier)

	local Root = GetRoot()

	if not Root or not Tier then
		return nil
	end

	local Nearest = nil
	local NearestDistance = math.huge

	for _, Wreck in ipairs(
		GetWrecksInTier(Tier)
	) do

		local Position =
			GetPosition(Wreck)

		if Position then

			local Distance =
				(
					Root.Position -
					Position
				).Magnitude

			if Distance <
				NearestDistance then

				NearestDistance =
					Distance

				Nearest =
					Wreck

			end

		end

	end

	return Nearest

end

--==================================================
-- FIND WRECK
--==================================================

local function GetNearestWreck()

	local Tiers = GetWreckTiers()

	if not Tiers then
		return nil
	end

	local Root = GetRoot()
	if not Root then
		return nil
	end

	-- Build the list of tiers that are currently eligible.
	-- Tier 1 can be used as a fallback only when no selected
	-- higher tier (2–5) has any available wrecks.
	local EligibleTiers = {}

	for Tier = 2, 5 do
		if TargetTiers[Tier] and Tiers[Tier] then
			if #GetWrecksInTier(Tiers[Tier]) > 0 then
				table.insert(EligibleTiers, Tier)
			end
		end
	end

	if #EligibleTiers == 0 then
		if FallbackToTier1 and Tiers[1] then
			EligibleTiers = {1}
		elseif TargetTiers[1] and Tiers[1] then
			EligibleTiers = {1}
		end
	end

	if #EligibleTiers == 0 then
		return nil
	end

	-- Higher-tier priority: search the highest eligible tier first.
	if PrioritizeHigherTiers then
		for Tier = 5, 2, -1 do
			if table.find(EligibleTiers, Tier) then
				local Wreck = GetNearestWreckInTier(Tiers[Tier])
				if Wreck then
					return Wreck
				end
			end
		end

		if table.find(EligibleTiers, 1) then
			return GetNearestWreckInTier(Tiers[1])
		end

		return nil
	end

	-- Normal behavior: choose the nearest wreck among the
	-- currently eligible tiers.
	local Nearest = nil
	local NearestDistance = math.huge

	for _, Tier in ipairs(EligibleTiers) do
		local Wreck = GetNearestWreckInTier(Tiers[Tier])
		if Wreck then
			local Position = GetPosition(Wreck)
			if Position then
				local Distance = (Root.Position - Position).Magnitude
				if Distance < NearestDistance then
					NearestDistance = Distance
					Nearest = Wreck
				end
			end
		end
	end

	return Nearest

end

--==================================================
-- INVENTORY
--==================================================

local function GetInventory()

	local DataFolder =
		Player:FindFirstChild(
			"DataFolder"
		)

	if not DataFolder then
		return nil
	end

	return DataFolder:FindFirstChild(
		"ItemInventory"
	)

end

local function GetResourceAmount(Name)

	local Inventory =
		GetInventory()

	if not Inventory then
		return 0
	end

	local Item =
		Inventory:FindFirstChild(Name)

	if not Item then
		return 0
	end

	if Item:IsA("NumberValue")
		or Item:IsA("IntValue") then

		return Item.Value

	end

	return 0

end

local function GetTotalResources()

	local Total = 0

	for _, Name in ipairs(
		RESOURCE_NAMES
	) do

		Total +=
			GetResourceAmount(Name)

	end

	return Total

end

--==================================================
-- PATH CREATION
--==================================================

local function CreatePath(Destination)

	local Root = GetRoot()

	if not Root then
		return nil
	end

	local Path =
		PathfindingService:CreatePath({
			AgentRadius = 2,
			AgentHeight = 5,
			AgentCanJump = true,
			AgentCanClimb = true,
			AgentJumpHeight = 10,
			AgentMaxSlope = 45,
			WaypointSpacing = 3
		})

	local Success =
		pcall(function()

			Path:ComputeAsync(
				Root.Position,
				Destination
			)

		end)

	if not Success then
		return nil
	end

	if Path.Status ~=
		Enum.PathStatus.Success then

		return nil

	end

	return Path

end

--==================================================
-- STANDARD PATHFINDING
--==================================================

local function PathfindTo(
	Destination,
	ArrivalDistance
)

	while Enabled do

		local Humanoid = GetHumanoid()
		local Root = GetRoot()

		if not Humanoid or not Root then
			return false
		end

		if (
			Root.Position -
			Destination
		).Magnitude <= ArrivalDistance then

			StopMovement()
			return true

		end

		local Path =
			CreatePath(Destination)

		if not Path then

			task.wait(0.2)
			continue

		end

		local Waypoints =
			Path:GetWaypoints()

		if #Waypoints < 2 then

			task.wait(0.1)
			continue

		end

		local Failed = false

		for Index = 2, #Waypoints do

			if not Enabled then
				return false
			end

			Humanoid = GetHumanoid()
			Root = GetRoot()

			if not Humanoid or not Root then
				return false
			end

			local Waypoint =
				Waypoints[Index]

			if Waypoint.Action ==
				Enum.PathWaypointAction.Jump then

				Humanoid.Jump = true

			end

			Humanoid:MoveTo(
				Waypoint.Position
			)

			local StartTime =
				os.clock()

			while Enabled do

				Humanoid = GetHumanoid()
				Root = GetRoot()

				if not Humanoid or not Root then
					return false
				end

				if Waypoint.Action ==
					Enum.PathWaypointAction.Jump then

					Humanoid.Jump = true

				end

				Humanoid:MoveTo(
					Waypoint.Position
				)

				local Distance =
					(
						Root.Position -
						Waypoint.Position
					).Magnitude

				if Distance <= 3 then
					break
				end

				if os.clock() -
					StartTime > 2.5 then

					Failed = true
					break

				end

				if (
					Root.Position -
					Destination
				).Magnitude <=
					ArrivalDistance then

					StopMovement()
					return true

				end

				task.wait(0.05)

			end

			if Failed then
				break
			end

		end

		task.wait(0.05)

	end

	return false

end

--==================================================
-- PATHFINDING TO SELLER
--==================================================

local function PathfindToSeller(
	Destination,
	ArrivalDistance
)

	local Jumping = true

	task.spawn(function()

		while Jumping and Enabled do

			local Humanoid =
				GetHumanoid()

			if Humanoid then

				Humanoid.Jump = true

				Humanoid:ChangeState(
					Enum.HumanoidStateType.Jumping
				)

			end

			task.wait(
				SELLER_JUMP_INTERVAL
			)

		end

	end)

	local Result =
		PathfindTo(
			Destination,
			ArrivalDistance
		)

	Jumping = false

	return Result

end

--==================================================
-- NORMAL MOVEMENT TO WALL
--==================================================

local function MoveToWallNormally()

	local Wall =
		GetWall()

	if not Wall then

		Status.Text =
			"Wall not found"

		return false

	end

	local Position =
		GetPosition(Wall)

	if not Position then
		return false
	end

	local Root =
		GetRoot()

	if not Root then
		return false
	end

	local Distance =
		(
			Root.Position -
			Position
		).Magnitude

	if Distance <=
		WALL_ARRIVAL_DISTANCE then

		StopMovement()

		return true

	end

	Status.Text =
		"Going to tunnel..."

	MoveDirectlyTo(Position)

	return false

end

--==================================================
-- GO TO SELLER
--==================================================

local function GoToSeller()

	local Seller =
		GetSeller()

	if not Seller then

		Status.Text =
			"Seller not found"

		return false

	end

	local Position =
		GetPosition(Seller)

	if not Position then
		return false
	end

	Status.Text =
		"Going to seller..."

	return PathfindToSeller(
		Position,
		SELLER_ARRIVAL_DISTANCE
	)

end

--==================================================
-- RETURN TO WALL
--==================================================

local function ReturnToWall()

	local Wall =
		GetWall()

	if not Wall then

		Status.Text =
			"Wall not found"

		return false

	end

	local Position =
		GetPosition(Wall)

	if not Position then
		return false
	end

	Status.Text =
		"Returning to tunnel..."

	return PathfindTo(
		Position,
		WALL_ARRIVAL_DISTANCE
	)

end

--==================================================
-- SELLING WAIT
--==================================================

local function WaitForSelling()

	while Enabled do

		local Total =
			GetTotalResources()

		Status.Text =
			"Selling: " ..
			tostring(Total)

		if Total <= 0 then
			return true
		end

		task.wait(0.2)

	end

	return false

end

--==================================================
-- MAIN TOGGLE
--==================================================

Toggle.Activated:Connect(function()

	Enabled =
		not Enabled

	TargetWreck = nil

	if Enabled then

		State = "Mining"

		Status.Text =
			"Searching..."

		Switch.BackgroundColor3 =
			Color3.fromRGB(
				55,
				175,
				90
			)

		Knob.Position =
			UDim2.new(
				1,
				-29,
				0,
				3
			)

	else

		State = "Idle"

		Status.Text =
			"Disabled"

		StopMovement()

		Switch.BackgroundColor3 =
			Color3.fromRGB(
				65,
				65,
				75
			)

		Knob.Position =
			UDim2.fromOffset(
				3,
				3
			)

	end

end)

--==================================================
-- MAIN AUTOMATION LOOP
--==================================================

task.spawn(function()

	while true do

		task.wait(0.1)

		if not Enabled then
			continue
		end

		--==================================================
		-- MINING
		--==================================================

		if State == "Mining" then

			-- Inventory full:
			-- FIRST move normally to the tunnel wall.
			if GetTotalResources() >=
				INVENTORY_LIMIT then

				TargetWreck = nil

				State =
					"GoingToWallBeforeSelling"

				continue

			end

			-- Continuously verify the current wreck.
			if TargetWreck
				and not IsValidWreck(
					TargetWreck
				) then

				TargetWreck = nil

				Status.Text =
					"Searching..."

			end

			if not TargetWreck then

				TargetWreck =
					GetNearestWreck()

				if not TargetWreck then

					Status.Text =
						"No wrecks found"

					continue

				end

			end

			local Position =
				GetPosition(TargetWreck)

			local Root =
				GetRoot()

			if not Position or not Root then

				TargetWreck = nil
				continue

			end

			local Distance =
				(
					Root.Position -
					Position
				).Magnitude

			if Distance <=
				WRECK_ARRIVAL_DISTANCE then

				Status.Text =
					"At wreck"

			else

				Status.Text =
					"Moving to wreck"

				MoveDirectlyTo(
					Position
				)

			end

		--==================================================
		-- NORMAL MOVEMENT TO WALL BEFORE SELLING
		--==================================================

		elseif State ==
			"GoingToWallBeforeSelling" then

			local Reached =
				MoveToWallNormally()

			if not Enabled then
				continue
			end

			if Reached then

				State =
					"GoingToSeller"

			end

		--==================================================
		-- PATHFIND TO SELLER
		--==================================================

		elseif State ==
			"GoingToSeller" then

			local Reached =
				GoToSeller()

			if not Enabled then
				continue
			end

			if Reached then

				State =
					"Selling"

				Status.Text =
					"Waiting for sale..."

			else

				-- If seller pathfinding fails,
				-- return to the wall normally and
				-- try the seller again.
				State =
					"GoingToWallBeforeSelling"

			end

		--==================================================
		-- SELLING
		--==================================================

		elseif State ==
			"Selling" then

			local Finished =
				WaitForSelling()

			if not Enabled then
				continue
			end

			if Finished then

				State =
					"Returning"

			end

		--==================================================
		-- PATHFIND BACK TO WALL
		--==================================================

		elseif State ==
			"Returning" then

			local Reached =
				ReturnToWall()

			if not Enabled then
				continue
			end

			if Reached then

				TargetWreck = nil

				State =
					"Mining"

				Status.Text =
					"Searching..."

			else

				task.wait(0.5)

			end

		end

	end

end)

ApplyWalkSpeed()
