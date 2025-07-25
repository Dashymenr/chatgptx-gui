
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Create main GUI
local MainGui = Instance.new("ScreenGui", CoreGui)
MainGui.Name = "ChatGPT_X"
MainGui.ResetOnSpawn = false
MainGui.IgnoreGuiInset = true

-- Variables
local VehicleTeleportDelay = 1
local Waypoints = {}
local CurrentTeleportIndex = 0
local Teleporting = false

-- UI Utility Functions
local function makeShadow(instance)
	local shadow = Instance.new("ImageLabel")
	shadow.Name = "Shadow"
	shadow.BackgroundTransparency = 1
	shadow.Image = "rbxassetid://1316045217"
	shadow.ImageColor3 = Color3.new(0, 0, 0)
	shadow.ImageTransparency = 0.5
	shadow.ScaleType = Enum.ScaleType.Slice
	shadow.SliceCenter = Rect.new(10, 10, 118, 118)
	shadow.Size = UDim2.new(1, 30, 1, 30)
	shadow.Position = UDim2.new(0, -15, 0, -15)
	shadow.ZIndex = instance.ZIndex - 1
	shadow.Parent = instance
end

local function squircleStyle(frame)
	frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	frame.BorderSizePixel = 0
	frame.BackgroundTransparency = 0
	frame.ClipsDescendants = true
	frame.AutomaticSize = Enum.AutomaticSize.None
	frame.ZIndex = 2
	frame.SizeConstraint = Enum.SizeConstraint.RelativeXY

	local uicorner = Instance.new("UICorner", frame)
	uicorner.CornerRadius = UDim.new(0, 12)
end

local function createButton(text, parent)
	local btn = Instance.new("TextButton", parent)
	btn.Size = UDim2.new(1, -10, 0, 30)
	btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.GothamBold
	btn.Text = text
	btn.TextScaled = true
	squircleStyle(btn)
	makeShadow(btn)
	return btn
end

-- Main Frame
local Frame = Instance.new("Frame", MainGui)
Frame.Size = UDim2.new(0, 500, 0, 280)
Frame.Position = UDim2.new(0.5, -250, 0.5, -140)
Frame.BackgroundTransparency = 0
squircleStyle(Frame)
makeShadow(Frame)

-- Minimize Button
local MinBtn = Instance.new("TextButton", Frame)
MinBtn.Text = "—"
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 20
MinBtn.TextColor3 = Color3.new(1, 0, 0)
MinBtn.Size = UDim2.new(0, 32, 0, 32)
MinBtn.Position = UDim2.new(1, -38, 0, 6)
MinBtn.BackgroundTransparency = 1
MinBtn.ZIndex = 3

-- Title
local Title = Instance.new("TextLabel", Frame)
Title.Text = "ChatGPT X"
Title.Font = Enum.Font.GothamSemibold
Title.TextScaled = true
Title.TextColor3 = Color3.new(1, 0, 0)
Title.Size = UDim2.new(0, 150, 0, 32)
Title.Position = UDim2.new(0, 10, 0, 6)
Title.BackgroundTransparency = 1

-- Tab Buttons
local TabHolder = Instance.new("Frame", Frame)
TabHolder.Position = UDim2.new(0, 0, 0, 40)
TabHolder.Size = UDim2.new(1, 0, 0, 36)
TabHolder.BackgroundTransparency = 1

local AutoFarmTab = createButton("Auto Farm", TabHolder)
AutoFarmTab.Position = UDim2.new(0, 8, 0, 0)
AutoFarmTab.Size = UDim2.new(0, 120, 0, 36)

local TerminalsTab = createButton("Terminals", TabHolder)
TerminalsTab.Position = UDim2.new(0, 140, 0, 0)
TerminalsTab.Size = UDim2.new(0, 120, 0, 36)

-- Tab Content Areas
local ContentFrame = Instance.new("Frame", Frame)
ContentFrame.Position = UDim2.new(0, 0, 0, 80)
ContentFrame.Size = UDim2.new(1, 0, 1, -80)
ContentFrame.BackgroundTransparency = 1

local AutoFarmFrame = Instance.new("Frame", ContentFrame)
AutoFarmFrame.Size = UDim2.new(1, 0, 1, 0)
AutoFarmFrame.BackgroundTransparency = 1

local TerminalsFrame = Instance.new("Frame", ContentFrame)
TerminalsFrame.Size = UDim2.new(1, 0, 1, 0)
TerminalsFrame.BackgroundTransparency = 1
TerminalsFrame.Visible = false

-- Waypoint UI (Auto Farm)
local WaypointList = Instance.new("ScrollingFrame", AutoFarmFrame)
WaypointList.Size = UDim2.new(0.5, -10, 1, -10)
WaypointList.Position = UDim2.new(0, 10, 0, 5)
WaypointList.ScrollBarThickness = 6
WaypointList.BackgroundTransparency = 1
WaypointList.CanvasSize = UDim2.new(0, 0, 0, 0)

local UIListLayout = Instance.new("UIListLayout", WaypointList)
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local ControlPanel = Instance.new("Frame", AutoFarmFrame)
ControlPanel.Size = UDim2.new(0.5, -20, 1, -10)
ControlPanel.Position = UDim2.new(0.5, 10, 0, 5)
ControlPanel.BackgroundTransparency = 1

-- Control Buttons
local StartBtn = createButton("▶ Start", ControlPanel)
StartBtn.Position = UDim2.new(0, 0, 0, 0)

local StopBtn = createButton("■ Stop", ControlPanel)
StopBtn.Position = UDim2.new(0, 0, 0, 40)

local DelayLabel = Instance.new("TextLabel", ControlPanel)
DelayLabel.Text = "Delay: " .. tostring(VehicleTeleportDelay) .. "s"
DelayLabel.Font = Enum.Font.Gotham
DelayLabel.TextColor3 = Color3.new(1, 1, 1)
DelayLabel.BackgroundTransparency = 1
DelayLabel.Size = UDim2.new(1, 0, 0, 30)
DelayLabel.Position = UDim2.new(0, 0, 0, 90)

-- Mark Button
local MarkBtn = createButton("Mark", ControlPanel)
MarkBtn.Position = UDim2.new(0, 0, 0, 130)

-- Tab Switching
AutoFarmTab.MouseButton1Click:Connect(function()
	AutoFarmFrame.Visible = true
	TerminalsFrame.Visible = false
	AutoFarmTab.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	TerminalsTab.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
end)

TerminalsTab.MouseButton1Click:Connect(function()
	AutoFarmFrame.Visible = false
	TerminalsFrame.Visible = true
	TerminalsTab.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	AutoFarmTab.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
end)

-- Vehicle Teleport Logic
local function teleportVehicleTo(pos)
	local char = LocalPlayer.Character
	if not char then return end
	local human = char:FindFirstChildWhichIsA("Humanoid")
	if not human then return end
	for _, desc in ipairs(workspace:GetDescendants()) do
		if desc:IsA("VehicleSeat") and desc.Occupant == human then
			local model = desc:FindFirstAncestorOfClass("Model")
			if model and model.PrimaryPart then
				model:SetPrimaryPartCFrame(CFrame.new(pos))
			end
			break
		end
	end
end

StartBtn.MouseButton1Click:Connect(function()
	if Teleporting then return end
	Teleporting = true
	task.spawn(function()
		for i, pos in ipairs(Waypoints) do
			if not Teleporting then break end
			teleportVehicleTo(pos)
			task.wait(VehicleTeleportDelay)
		end
		Teleporting = false
	end)
end)

StopBtn.MouseButton1Click:Connect(function()
	Teleporting = false
end)

MarkBtn.MouseButton1Click:Connect(function()
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local pos = hrp.Position
	table.insert(Waypoints, pos)

	local label = Instance.new("TextLabel", WaypointList)
	label.Text = "• Position " .. tostring(#Waypoints)
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Font = Enum.Font.Gotham
	label.TextScaled = true
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, -10, 0, 24)
end)

-- Handle character respawn
LocalPlayer.CharacterAdded:Connect(function()
	MainGui.Parent = CoreGui
end)
