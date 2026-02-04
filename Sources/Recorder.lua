return function(ctx)
    if not ctx or not ctx.Window then
        return
    end

    local Window = ctx.Window
    local replicated_storage = ctx.replicated_storage or game:GetService("ReplicatedStorage")
    local http_service = ctx.http_service or game:GetService("HttpService")
    local game_state = ctx.game_state or "UNKNOWN"
    local workspace_ref = ctx.workspace or workspace

    local players_service = game:GetService("Players")
    local local_player = ctx.local_player or players_service.LocalPlayer or players_service.PlayerAdded:Wait()

    _G.record_strat = _G.record_strat or false

    local spawned_towers = {}
    local tower_count = 0

    local function record_action(command_str)
        if not _G.record_strat then return end
        if appendfile then
            appendfile("Strat.txt", command_str .. "\n")
        end
    end

    local RecorderTab = Window:Tab({Title = "Recorder", Icon = "camera"}) do
        local Recorder = RecorderTab:CreateLogger({
            Title = "RECORDER:",
            Size = UDim2.new(0, 330, 0, 230)
        })

        RecorderTab:Button({
            Title = "START",
            Desc = "",
            Callback = function()
                Recorder:Clear()
                Recorder:Log("Recorder started")

                local current_mode = "Unknown"
                local current_map = "Unknown"
                
                local state_folder = replicated_storage:FindFirstChild("State")
                if state_folder then
                    current_mode = state_folder.Difficulty.Value
                    current_map = state_folder.Map.Value
                end

                local tower1, tower2, tower3, tower4, tower5 = "None", "None", "None", "None", "None"
                local current_modifiers = "" 
                local state_replicators = replicated_storage:FindFirstChild("StateReplicators")

                if state_replicators then
                    for _, folder in ipairs(state_replicators:GetChildren()) do
                        if folder.Name == "PlayerReplicator" and folder:GetAttribute("UserId") == local_player.UserId then
                            local equipped = folder:GetAttribute("EquippedTowers")
                            if type(equipped) == "string" then
                                local cleaned_json = equipped:match("%[.*%]") 
                                
                                local success, tower_table = pcall(function()
                                    return http_service:JSONDecode(cleaned_json)
                                end)

                                if success and type(tower_table) == "table" then
                                    tower1 = tower_table[1] or "None"
                                    tower2 = tower_table[2] or "None"
                                    tower3 = tower_table[3] or "None"
                                    tower4 = tower_table[4] or "None"
                                    tower5 = tower_table[5] or "None"
                                end
                            end
                        end

                        if folder.Name == "ModifierReplicator" then
                            local raw_votes = folder:GetAttribute("Votes")
                            if type(raw_votes) == "string" then
                                local cleaned_json = raw_votes:match("{.*}") 
                                
                                local success, mod_table = pcall(function()
                                    return http_service:JSONDecode(cleaned_json)
                                end)

                                if success and type(mod_table) == "table" then
                                    local mods = {}
                                    for mod_name, _ in pairs(mod_table) do
                                        table.insert(mods, mod_name .. " = true")
                                    end
                                    current_modifiers = table.concat(mods, ", ")
                                end
                            end
                        end
                    end
                end

                Recorder:Log("Mode: " .. current_mode)
                Recorder:Log("Map: " .. current_map)
                Recorder:Log("Towers: " .. tower1 .. ", " .. tower2)
                Recorder:Log(tower3 .. ", " .. tower4 .. ", " .. tower5)

                _G.record_strat = true

                if writefile then 
                    local config_header = string.format([[
local TDS = loadstring(game:HttpGet("https://raw.githubusercontent.com/DuxiiT/auto-strat/refs/heads/main/Library.lua"))()

TDS:Loadout("%s", "%s", "%s", "%s", "%s")
TDS:Mode("%s")
TDS:GameInfo("%s", {%s})

]], tower1, tower2, tower3, tower4, tower5, current_mode, current_map, current_modifiers)

                    writefile("Strat.txt", config_header)
                end

                Window:Notify({
                    Title = "ADS",
                    Desc = "Recorder has started, you may place down your towers now.",
                    Time = 3,
                    Type = "normal"
                })
            end
        })

        RecorderTab:Button({
            Title = "STOP",
            Desc = "",
            Callback = function()
                _G.record_strat = false
                Recorder:Clear()
                Recorder:Log("Strategy saved, you may find it in \nyour workspace folder called 'Strat.txt'")
                Window:Notify({
                    Title = "ADS",
                    Desc = "Recording has been saved! Check your workspace folder for Strat.txt",
                    Time = 3,
                    Type = "normal"
                })
            end
        })

        if game_state == "GAME" then
            local towers_folder = workspace_ref:WaitForChild("Towers", 5)

            towers_folder.ChildAdded:Connect(function(tower)
                if not _G.record_strat then return end
                
                local replicator = tower:WaitForChild("TowerReplicator", 5)
                if not replicator then return end

                local owner_id = replicator:GetAttribute("OwnerId")
                if owner_id and owner_id ~= local_player.UserId then return end

                tower_count = tower_count + 1
                local my_index = tower_count
                spawned_towers[tower] = my_index

                local tower_name = replicator:GetAttribute("Name") or tower.Name
                local raw_pos = replicator:GetAttribute("Position")
                
                local pos_x, pos_y, pos_z
                if typeof(raw_pos) == "Vector3" then
                    pos_x, pos_y, pos_z = raw_pos.X, raw_pos.Y, raw_pos.Z
                else
                    local p = tower:GetPivot().Position
                    pos_x, pos_y, pos_z = p.X, p.Y, p.Z
                end
                
                local command = 'TDS:Place("' .. tower_name .. '", ' .. tostring(pos_x) .. ', ' .. tostring(pos_y) .. ', ' .. tostring(pos_z) .. ')'
                record_action(command)
                Recorder:Log("Placed " .. tower_name .. " (Index: " .. my_index .. ")")

                replicator:GetAttributeChangedSignal("Upgrade"):Connect(function()
                    if not _G.record_strat then return end
                    record_action(string.format('TDS:Upgrade(%d)', my_index))
                    Recorder:Log("Upgraded Tower " .. my_index)
                end)
            end)

            towers_folder.ChildRemoved:Connect(function(tower)
                if not _G.record_strat then return end
                
                local my_index = spawned_towers[tower]
                if my_index then
                    record_action(string.format('TDS:Sell(%d)', my_index))
                    Recorder:Log("Sold Tower " .. my_index)
                    
                    spawned_towers[tower] = nil
                end
            end)
        end
    end
end
