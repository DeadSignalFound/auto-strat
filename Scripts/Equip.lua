local TDS = {}
shared.TDS_Table = TDS

local function identify_game_state()
    local players = game:GetService("Players")
    local temp_player = players.LocalPlayer or players.PlayerAdded:Wait()
    local temp_gui = temp_player:WaitForChild("PlayerGui")
    
    while true do
        if temp_gui:FindFirstChild("LobbyGui") then
            return "LOBBY"
        elseif temp_gui:FindFirstChild("GameGui") then
            return "GAME"
        end
        task.wait(1)
    end
end

local game_state = identify_game_state()

function TDS:Addons()
    if game_state ~= "GAME" then
        return false
    end

    local url = "https://api.junkie-development.de/api/v1/luascripts/public/57fe397f76043ce06afad24f07528c9f93e97730930242f57134d0b60a2d250b/download"
    local success, code = pcall(game.HttpGet, game, url)
    if not success then
        return false
    end

    loadstring(code)()

    while not TDS.Equip do
        task.wait(0.1)
    end

    return true
end

TDS:Addons()

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EquipTowerGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 200, 0, 100)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Parent = screenGui
frame.Active = true
frame.Draggable = true

local uiCornerFrame = Instance.new("UICorner")
uiCornerFrame.CornerRadius = UDim.new(0, 4)
uiCornerFrame.Parent = frame

local title = Instance.new("TextLabel")
title.Text = "Tower Equipper"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(230, 230, 230)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.Parent = frame

local textbox = Instance.new("TextBox")
textbox.PlaceholderText = "Enter tower name..."
textbox.Size = UDim2.new(1, -20, 0, 30)
textbox.Position = UDim2.new(0, 10, 0, 40)
textbox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
textbox.TextColor3 = Color3.fromRGB(230, 230, 230)
textbox.Font = Enum.Font.SourceSans
textbox.TextSize = 18
textbox.ClearTextOnFocus = true
textbox.TextEditable = true
textbox.Parent = frame

local uiCornerTextbox = Instance.new("UICorner")
uiCornerTextbox.CornerRadius = UDim.new(0, 4)
uiCornerTextbox.Parent = textbox

textbox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local towerName = textbox.Text
        if towerName ~= "" and TDS.Equip then
            TDS:Equip(towerName)
            textbox.Text = ""
        end
    end
end)

return TDS
