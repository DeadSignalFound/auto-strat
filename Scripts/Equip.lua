local Towers = {
    "Scout","Sniper","Paintballer","Demoman","Hunter","Soldier","Militant",
    "Freezer","Assassin","Shotgunner","Pyromancer","Ace Pilot","Medic","Farm",
    "Rocketeer","Trapper","Military Base","Crook Boss",
    "Electroshocker","Commander","Warden","Cowboy","DJ Booth","Minigunner",
    "Ranger","Pursuit","Gatling Gun","Turret","Mortar","Mercenary Base",
    "Brawler","Necromancer","Accelerator","Engineer","Hacker",
    "Gladiator","Commando","Slasher","Frost Blaster","Archer","Swarmer",
    "Toxic Gunner","Sledger","Executioner","Elf Camp","Jester","Cryomancer",
    "Hallow Punk","Harvester","Snowballer","Elementalist",
    "Firework Technician","Biologist","Warlock","Spotlight Tech","Mecha Base"
}

local function normalize(str)
    return string.lower(str):gsub("%s+", "")
end

local function resolveTower(input)
    local n = normalize(input)
    for _, tower in ipairs(Towers) do
        if normalize(tower):find(n, 1, true) then
            return tower
        end
    end
end

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

    local success, code = pcall(game.HttpGet, game,
        "https://api.junkie-development.de/api/v1/luascripts/public/57fe397f76043ce06afad24f07528c9f93e97730930242f57134d0b60a2d250b/download"
    )
    if not success then
        return false
    end

    loadstring(code)()

    while not TDS.Equip do
        task.wait()
    end

    return true
end

TDS:Addons()

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EquipTowerGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 100)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)

local title = Instance.new("TextLabel")
title.Text = "Tower Equipper"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(230, 230, 230)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.Parent = frame

local textbox = Instance.new("TextBox")
textbox.PlaceholderText = "Type tower name..."
textbox.Size = UDim2.new(1, -20, 0, 30)
textbox.Position = UDim2.new(0, 10, 0, 40)
textbox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
textbox.TextColor3 = Color3.fromRGB(230, 230, 230)
textbox.Font = Enum.Font.SourceSans
textbox.TextSize = 18
textbox.ClearTextOnFocus = false
textbox.Text = ""
textbox.Parent = frame

Instance.new("UICorner", textbox).CornerRadius = UDim.new(0, 4)

local buffer = ""

textbox:GetPropertyChangedSignal("Text"):Connect(function()
    buffer = textbox.Text
    textbox.Text = ""
end)

textbox.FocusLost:Connect(function(enterPressed)
    if enterPressed and TDS.Equip then
        local tower = resolveTower(buffer)
        if tower then
            TDS:Equip(tower)
        end
        buffer = ""
    end
end)

return TDS
