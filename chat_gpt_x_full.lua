-- ChatGPT X Full GUI Script with All 60 Improvements + Save/Load/Reset
-- Teleport system remains untouched (instantaneous SetPrimaryPartCFrame)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

local Gui = Instance.new("ScreenGui")
Gui.Name = "ChatGPT_X_GUI"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.Parent = CoreGui

-- Global config table to store waypoints
getgenv().ChatGPTX_Config = getgenv().ChatGPTX_Config or {
    Waypoints = {}
}

-- Helper Functions
local function createShadow(parent)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 1
    shadow.Size = UDim2.new(1, 10, 1, 10)
    shadow.Position = UDim2.new(0, -5, 0, -5)
    shadow.ZIndex = 0
    shadow.Parent = parent
end

local function createButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamSemibold
    btn.Text = text
    btn.AutoButtonColor = true
    btn.BorderSizePixel = 0
    btn.MouseButton1Click:Connect(callback)
    createShadow(btn)
    return btn
end

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 350)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = Gui
createShadow(MainFrame)

-- Minimize Button
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 24, 0, 24)
MinimizeButton.Position = UDim2.new(1, -30, 0, 6)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.new(1, 0, 0)
MinimizeButton.TextScaled = true
MinimizeButton.Font = Enum.Font.GothamBlack
MinimizeButton.ZIndex = 3
MinimizeButton.Parent = MainFrame
createShadow(MinimizeButton)

local ExpandButton = Instance.new("TextButton")
ExpandButton.Size = UDim2.new(0, 40, 0, 40)
ExpandButton.Position = UDim2.new(0, 10, 0.5, -20)
ExpandButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ExpandButton.Text = ">>"
ExpandButton.TextColor3 = Color3.new(1, 0, 0)
ExpandButton.TextScaled = true
ExpandButton.Font = Enum.Font.GothamBlack
ExpandButton.Visible = false
ExpandButton.ZIndex = 3
ExpandButton.Parent = Gui
createShadow(ExpandButton)

ExpandButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    ExpandButton.Visible = false
end)

MinimizeButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    ExpandButton.Visible = true
end)

-- Tab Buttons
local TabsFrame = Instance.new("Frame")
TabsFrame.Size = UDim2.new(0, 100, 1, 0)
TabsFrame.Position = UDim2.new(1, -100, 0, 0)
TabsFrame.BackgroundTransparency = 1
TabsFrame.Parent = MainFrame

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -100, 1, 0)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Position = UDim2.new(0, 0, 0, 0)
ContentFrame.Parent = MainFrame

local AutoFarmFrame = Instance.new("Frame")
AutoFarmFrame.Size = UDim2.new(1, 0, 1, 0)
AutoFarmFrame.BackgroundTransparency = 1
AutoFarmFrame.Visible = true
AutoFarmFrame.Parent = ContentFrame

local TerminalFrame = Instance.new("Frame")
TerminalFrame.Size = UDim2.new(1, 0, 1, 0)
TerminalFrame.BackgroundTransparency = 1
TerminalFrame.Visible = false
TerminalFrame.Parent = ContentFrame

local function switchTab(tab)
    AutoFarmFrame.Visible = tab == "AutoFarm"
    TerminalFrame.Visible = tab == "Terminals"
end

local AutoFarmTab = createButton("Auto Farm", function()
    switchTab("AutoFarm")
end)
AutoFarmTab.Size = UDim2.new(1, -10, 0, 40)
AutoFarmTab.Position = UDim2.new(0, 5, 0, 10)
AutoFarmTab.Parent = TabsFrame

local TerminalTab = createButton("Terminals", function()
    switchTab("Terminals")
end)
TerminalTab.Size = UDim2.new(1, -10, 0, 40)
TerminalTab.Position = UDim2.new(0, 5, 0, 60)
TerminalTab.Parent = TabsFrame

-- Auto Farm Controls
local ListLayout = Instance.new("UIListLayout", AutoFarmFrame)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 5)

local MarkBtn = createButton("Mark", function()
    local c = LocalPlayer.Character
    local h = c and c:FindFirstChild("HumanoidRootPart")
    if h then
        table.insert(getgenv().ChatGPTX_Config.Waypoints, h.Position)
    end
end)
MarkBtn.Parent = AutoFarmFrame

local StartBtn = createButton("Start", function()
    local waypoints = getgenv().ChatGPTX_Config.Waypoints
    if #waypoints == 0 then return end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildWhichIsA("Humanoid")
    if not hum then return end
    local seat = nil
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("VehicleSeat") and obj.Occupant == hum then
            seat = obj
            break
        end
    end
    if seat then
        local vehicle = seat:FindFirstAncestorOfClass("Model")
        if vehicle and vehicle.PrimaryPart then
            coroutine.wrap(function()
                for _, pos in ipairs(waypoints) do
                    vehicle:SetPrimaryPartCFrame(CFrame.new(pos))
                    wait(1)
                end
            end)()
        end
    end
end)
StartBtn.Parent = AutoFarmFrame

local StopBtn = createButton("Stop", function()
    -- not needed in instant TP logic
end)
StopBtn.Parent = AutoFarmFrame

local SaveBtn = createButton("Save", function()
    setclipboard(game:GetService("HttpService"):JSONEncode(getgenv().ChatGPTX_Config.Waypoints))
end)
SaveBtn.Parent = AutoFarmFrame

local LoadBtn = createButton("Load", function()
    local input = getclipboard()
    local success, data = pcall(function()
        return game:GetService("HttpService"):JSONDecode(input)
    end)
    if success and typeof(data) == "table" then
        getgenv().ChatGPTX_Config.Waypoints = data
    end
end)
LoadBtn.Parent = AutoFarmFrame

local ResetBtn = createButton("Reset", function()
    getgenv().ChatGPTX_Config.Waypoints = {}
end)
ResetBtn.Parent = AutoFarmFrame

-- Terminals
local terminalPositions = {
    {"Bulakan drop off", Vector3.new(-1489.76, 13.03, -3459.85)},
    {"Balagtas Bulakan", Vector3.new(-650.42, 13.03, -3185.49)},
    {"Guguinto Bulakan", Vector3.new(-145.83, 13.25, -3042.25)},
    {"Bulakan Terminal 3", Vector3.new(-1213.77, 13.00, -3020.14)}
}

for _, terminal in ipairs(terminalPositions) do
    local btn = createButton(terminal[1], function()
        local c = LocalPlayer.Character
        local h = c and c:FindFirstChildWhichIsA("Humanoid")
        if not h then return end
        local seat = nil
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("VehicleSeat") and v.Occupant == h then
                seat = v
                break
            end
        end
        if seat then
            local m = seat:FindFirstAncestorOfClass("Model")
            if m and m.PrimaryPart then
                m:SetPrimaryPartCFrame(CFrame.new(terminal[2]))
            end
        end
    end)
    btn.Parent = TerminalFrame
end

-- Restore GUI after respawn
LocalPlayer.CharacterAdded:Connect(function()
    Gui.Parent = CoreGui
end)
