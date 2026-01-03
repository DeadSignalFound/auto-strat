local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local guiParent = gethui and gethui() or game:GetService("CoreGui")

local old = guiParent:FindFirstChild("TDSGui")
if old then old:Destroy() end

local TDSGui = Instance.new("ScreenGui")
TDSGui.Name = "TDSGui"
TDSGui.Parent = guiParent
TDSGui.ResetOnSpawn = false
TDSGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Main = Instance.new("Frame")
Main.Parent = TDSGui
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.Size = UDim2.new(0.45, 0, 0.6, 0)
Main.BackgroundColor3 = Color3.fromRGB(18,18,18)
Main.BorderSizePixel = 0
Main.ZIndex = 1
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,12)

local Header = Instance.new("Frame")
Header.Parent = Main
Header.Size = UDim2.new(1,0,0,52)
Header.BackgroundColor3 = Color3.fromRGB(22,22,22)
Header.BorderSizePixel = 0
Header.ZIndex = 2
Instance.new("UICorner", Header).CornerRadius = UDim.new(0,12)

local Title = Instance.new("TextLabel")
Title.Parent = Header
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1,-20,1,0)
Title.Position = UDim2.new(0,10,0,0)
Title.Font = Enum.Font.GothamSemibold
Title.Text = "Pure Strategy"
Title.TextColor3 = Color3.fromRGB(220,220,220)
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 3

local Body = Instance.new("Frame")
Body.Parent = Main
Body.Position = UDim2.new(0,0,0,52)
Body.Size = UDim2.new(1,0,1,-52)
Body.BackgroundColor3 = Color3.fromRGB(24,24,24)
Body.BorderSizePixel = 0
Body.ZIndex = 1
Instance.new("UICorner", Body).CornerRadius = UDim.new(0,10)

local Padding = Instance.new("UIPadding")
Padding.Parent = Body
Padding.PaddingTop = UDim.new(0,10)
Padding.PaddingBottom = UDim.new(0,10)
Padding.PaddingLeft = UDim.new(0,10)
Padding.PaddingRight = UDim.new(0,10)

local Console = Instance.new("ScrollingFrame")
Console.Parent = Body
Console.Size = UDim2.new(1,0,1,0)
Console.CanvasSize = UDim2.new()
Console.ScrollBarImageColor3 = Color3.fromRGB(90,90,90)
Console.ScrollBarThickness = 3
Console.BackgroundTransparency = 1
Console.BorderSizePixel = 0
Console.ZIndex = 2
Console.AutomaticCanvasSize = Enum.AutomaticSize.None

local Layout = Instance.new("UIListLayout")
Layout.Parent = Console
Layout.Padding = UDim.new(0,6)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	Console.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y + 10)
end)

local Toggle = Instance.new("TextButton")
Toggle.Parent = TDSGui
Toggle.Size = UDim2.new(0,120,0,34)
Toggle.Position = UDim2.new(0,14,1,-48)
Toggle.Text = "Toggle GUI"
Toggle.Font = Enum.Font.GothamBold
Toggle.TextSize = 14
Toggle.TextColor3 = Color3.fromRGB(220,220,220)
Toggle.BackgroundColor3 = Color3.fromRGB(32,32,32)
Toggle.ZIndex = 10
Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0,8)

local visible = true
local tweenInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function setVisible(state)
	visible = state
	local goal = {BackgroundTransparency = state and 0 or 1}
	TweenService:Create(Main, tweenInfo, goal):Play()
	Main.Visible = true
	task.delay(0.18, function()
		if not visible then Main.Visible = false end
	end)
end

Toggle.MouseButton1Click:Connect(function()
	setVisible(not visible)
end)

UIS.InputBegan:Connect(function(i,gp)
	if gp then return end
	if i.KeyCode == Enum.KeyCode.Delete then
		setVisible(not visible)
	end
end)

do
	local dragging, dragStart, startPos
	Header.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = i.Position
			startPos = Main.Position
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = i.Position - dragStart
			Main.Position = startPos + UDim2.new(0, delta.X, 0, delta.Y)
		end
	end)
	UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
end

shared.AutoStratGUI = {
	Console = Console,
	Main = Main
}