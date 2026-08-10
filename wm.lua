--// Wreck Miner
--// LocalScript

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local PathfindingService = game:GetService("PathfindingService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--==================================================
-- CONFIGURATION
--==================================================

local INVENTORY_LIMIT = 30

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
	"Tungsten"
}

--==================================================
-- STATE
--==================================================

local Enabled = false
local State = "Idle"
local TargetWreck = nil

local CurrentWalkSpeed = DEFAULT_WALKSPEED

--==================================================
-- GUI
--==================================================

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
Panel.Size = UDim2.fromOffset(250, 130)
Panel.Position = UDim2.fromOffset(30, 200)
Panel.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Panel.BorderSizePixel = 0
Panel.Parent = Gui

local PanelCorner = Instance.new("UICorner")
PanelCorner.CornerRadius = UDim.new(0, 12)
PanelCorner.Parent = Panel

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(65, 65, 75)
Stroke.Thickness = 1.5
Stroke.Parent = Panel

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
-- SWITCH
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
-- WALK SPEED LABEL
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

--==================================================
-- WALK SPEED INPUT
--==================================================

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
-- DRAG AREA
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

	if Input.UserInputType == Enum.UserInputType.MouseButton1 then

		Dragging = true
		DragStart = Input.Position
		StartPosition = Panel.Position

	end

end)

DragArea.InputEnded:Connect(function(Input)

	if Input.UserInputType == Enum.UserInputType.MouseButton1 then
		Dragging = false
	end

end)

UserInputService.InputChanged:Connect(function(Input)

	if not Dragging then
		return
	end

	if Input.UserInputType ~= Enum.UserInputType.MouseMovement then
		return
	end

	local Delta = Input.Position - DragStart

	Panel.Position = UDim2.new(
		StartPosition.X.Scale,
		StartPosition.X.Offset + Delta.X,
		StartPosition.Y.Scale,
		StartPosition.Y.Offset + Delta.Y
	)

end)

--==================================================
-- CHARACTER FUNCTIONS
--==================================================

local function getCharacter()

	return Player.Character

end

local function getHumanoid()

	local Character = getCharacter()

	if not Character then
		return nil
	end

	return Character:FindFirstChildOfClass("Humanoid")

end

local function getRoot()

	local Character = getCharacter()

	if not Character then
		return nil
	end

	return Character:FindFirstChild("HumanoidRootPart")

end

--==================================================
-- WALKSPEED
--==================================================

local function applyWalkSpeed()

	local Humanoid = getHumanoid()

	if Humanoid then

		Humanoid.WalkSpeed = CurrentWalkSpeed

	end

end

local function setWalkSpeed(Value)

	if typeof(Value) ~= "number" then
		return
	end

	if Value < 0 then
		Value = 0
	end

	if Value ~= Value then
		return
	end

	CurrentWalkSpeed = Value

	applyWalkSpeed()

end

WalkSpeedInput.FocusLost:Connect(function()

	local Text = WalkSpeedInput.Text

	local Value = tonumber(Text)

	if Value then

		if Value < 0 then
			Value = 0
		end

		if Value ~= Value then
			Value = DEFAULT_WALKSPEED
		end

		setWalkSpeed(Value)

		WalkSpeedInput.Text =
			tostring(Value)

	else

		WalkSpeedInput.Text =
			tostring(CurrentWalkSpeed)

	end

end)

--==================================================
-- RESPAWN WALKSPEED
--==================================================

Player.CharacterAdded:Connect(function(Character)

	local Humanoid =
		Character:WaitForChild(
			"Humanoid"
		)

	Humanoid.WalkSpeed =
		CurrentWalkSpeed

end)

--==================================================
-- POSITION FUNCTION
--==================================================

local function getPosition(Object)

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

local function getWreckTiers()

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

	local Tier1 =
		WreckContainer:FindFirstChild(
			"Tier1"
		)

	local Tier2 =
		WreckContainer:FindFirstChild(
			"Tier2"
		)

	if not Tier1 or not Tier2 then
		return nil
	end

	return {
		Tier1,
		Tier2
	}

end

--==================================================

local function getSeller()

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

--==================================================

local function getWall()

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
-- MOVEMENT
--==================================================

local function stopMovement()

	local Humanoid = getHumanoid()
	local Root = getRoot()

	if Humanoid and Root then

		Humanoid:MoveTo(
			Root.Position
		)

	end

end

local function moveDirectlyTo(Position)

	local Humanoid =
		getHumanoid()

	if Humanoid and Position then

		Humanoid:MoveTo(
			Position
		)

	end

end

--==================================================
-- WRECK SEARCH
--==================================================

local function getWrecks()

	local Tiers =
		getWreckTiers()

	if not Tiers then
		return {}
	end

	local Wrecks = {}

	for _, Tier in ipairs(Tiers) do

		for _, NumberValue in
			ipairs(Tier:GetChildren()) do

			if NumberValue:IsA(
				"NumberValue"
			) then

				local Wreck =
					NumberValue:FindFirstChild(
						"WreckModel"
					)

				if Wreck
					and Wreck:IsA("Model")
					and getPosition(Wreck) then

					table.insert(
						Wrecks,
						Wreck
					)

				end

			end

		end

	end

	return Wrecks

end

--==================================================

local function isValidWreck(Wreck)

	if not Wreck then
		return false
	end

	if not Wreck:IsA("Model") then
		return false
	end

	if not Wreck.Parent then
		return false
	end

	if not getPosition(Wreck) then
		return false
	end

	local Tiers =
		getWreckTiers()

	if not Tiers then
		return false
	end

	for _, Tier in ipairs(Tiers) do

		if Wreck:IsDescendantOf(Tier) then
			return true
		end

	end

	return false

end

--==================================================

local function getNearestWreck()

	local Root =
		getRoot()

	if not Root then
		return nil
	end

	local Nearest = nil
	local NearestDistance = math.huge

	for _, Wreck in
		ipairs(getWrecks()) do

		local Position =
			getPosition(Wreck)

		if Position then

			local Distance = (
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
-- INVENTORY
--==================================================

local function getInventory()

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

--==================================================

local function getResourceAmount(Name)

	local Inventory =
		getInventory()

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

--==================================================

local function getTotalResources()

	local Total = 0

	for _, Name in
		ipairs(RESOURCE_NAMES) do

		Total +=
			getResourceAmount(Name)

	end

	return Total

end

--==================================================
-- PATH CREATION
--==================================================

local function createPath(Destination)

	local Root =
		getRoot()

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
-- NORMAL PATHFINDING
--==================================================

local function pathfindTo(
	Destination,
	ArrivalDistance
)

	while Enabled do

		local Humanoid =
			getHumanoid()

		local Root =
			getRoot()

		if not Humanoid
			or not Root then

			return false

		end

		if (
			Root.Position -
			Destination
		).Magnitude <=
			ArrivalDistance then

			stopMovement()

			return true

		end

		local Path =
			createPath(
				Destination
			)

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

			Humanoid =
				getHumanoid()

			Root =
				getRoot()

			if not Humanoid
				or not Root then

				return false

			end

			local Waypoint =
				Waypoints[Index]

			Humanoid:MoveTo(
				Waypoint.Position
			)

			local StartTime =
				os.clock()

			while Enabled do

				Humanoid =
					getHumanoid()

				Root =
					getRoot()

				if not Humanoid
					or not Root then

					return false

				end

				Humanoid:MoveTo(
					Waypoint.Position
				)

				local Distance = (
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

				task.wait(0.05)

			end

			if Failed then
				break
			end

			if (
				Root.Position -
				Destination
			).Magnitude <=
				ArrivalDistance then

				stopMovement()

				return true

			end

		end

		task.wait(0.05)

	end

	return false

end

--==================================================
-- SELLER PATHFINDING + JUMPING
--==================================================

local function pathfindToSeller(
	Destination,
	ArrivalDistance
)

	local Jumping = true

	-- Continuous jumping is ONLY active
	-- during the trip to the seller.
	task.spawn(function()

		while Jumping and Enabled do

			local Humanoid =
				getHumanoid()

			if Humanoid then

				Humanoid:ChangeState(
					Enum.HumanoidStateType.Jumping
				)

				Humanoid.Jump = true

			end

			-- Jump every 2 seconds.
			task.wait(
				SELLER_JUMP_INTERVAL
			)

		end

	end)

	local Result =
		pathfindTo(
			Destination,
			ArrivalDistance
		)

	Jumping = false

	return Result

end

--==================================================
-- GO TO SELLER
--==================================================

local function goToSeller()

	local Seller =
		getSeller()

	if not Seller then

		warn(
			"[Wreck Miner] " ..
			"Seller not found."
		)

		Status.Text =
			"Seller not found"

		return false

	end

	local Position =
		getPosition(Seller)

	if not Position then
		return false
	end

	Status.Text =
		"Going to seller..."

	stopMovement()

	return pathfindToSeller(
		Position,
		SELLER_ARRIVAL_DISTANCE
	)

end

--==================================================
-- RETURN TO WALL
--==================================================

local function goToWall()

	local Wall =
		getWall()

	if not Wall then

		warn(
			"[Wreck Miner] " ..
			"workspace.etc.Wall not found."
		)

		Status.Text =
			"Wall not found"

		return false

	end

	local Position =
		getPosition(Wall)

	if not Position then
		return false
	end

	Status.Text =
		"Returning to tunnel..."

	stopMovement()

	-- Normal pathfinding.
	-- NO jumping.
	return pathfindTo(
		Position,
		WALL_ARRIVAL_DISTANCE
	)

end

--==================================================
-- WAIT FOR SELLING
--==================================================

local function waitForSelling()

	Status.Text =
		"Waiting for sale..."

	while Enabled do

		local Total =
			getTotalResources()

		Status.Text =
			"Selling: " ..
			tostring(Total)

		-- The external autoclicker handles
		-- the Sell100 buttons.

		if Total <= 0 then

			return true

		end

		task.wait(0.2)

	end

	return false

end

--==================================================
-- TOGGLE
--==================================================

Toggle.Activated:Connect(function()

	Enabled =
		not Enabled

	TargetWreck = nil

	if Enabled then

		State =
			"Mining"

		Status.Text =
			"Searching..."

	else

		State =
			"Idle"

		Status.Text =
			"Disabled"

		stopMovement()

	end

	--==================================================
	-- SWITCH VISUAL
	--==================================================

	if Enabled then

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

			if getTotalResources() >=
				INVENTORY_LIMIT then

				TargetWreck = nil

				State =
					"GoingToSeller"

				continue

			end

			-- Constantly check whether the
			-- current wreck disappeared.
			if TargetWreck
				and not isValidWreck(
					TargetWreck
				) then

				TargetWreck = nil

				Status.Text =
					"Searching..."

			end

			if not TargetWreck then

				TargetWreck =
					getNearestWreck()

				if not TargetWreck then

					Status.Text =
						"No wrecks found"

					continue

				end

			end

			local Position =
				getPosition(
					TargetWreck
				)

			local Root =
				getRoot()

			if not Position
				or not Root then

				TargetWreck = nil
				continue

			end

			local Distance = (
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

				moveDirectlyTo(
					Position
				)

			end

		--==================================================
		-- GOING TO SELLER
		--==================================================

		elseif State ==
			"GoingToSeller" then

			local Reached =
				goToSeller()

			if not Enabled then
				continue
			end

			if Reached then

				State =
					"Selling"

				Status.Text =
					"Waiting for sale..."

			else

				State =
					"Mining"

				TargetWreck = nil

			end

		--==================================================
		-- SELLING
		--==================================================

		elseif State ==
			"Selling" then

			local Finished =
				waitForSelling()

			if not Enabled then
				continue
			end

			if Finished then

				State =
					"Returning"

			end

		--==================================================
		-- RETURNING
		--==================================================

		elseif State ==
			"Returning" then

			local Reached =
				goToWall()

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

--==================================================
-- INITIALIZE
--==================================================

applyWalkSpeed()

print(
	"[Wreck Miner] GUI loaded successfully."
)
