--[[ 
    Silent Assassin - Master Script [FINAL VERSION]
    Full Features: ESP, Fly, ShiftLock, Speed, Kill All (Data Fixed)
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local Window = Rayfield:CreateWindow({
   Name = "Silent Assassin - Ultimate Tool",
   LoadingTitle = "Đang tối ưu hóa dữ liệu...",
   LoadingSubtitle = "Phiên bản ổn định nhất",
   KeySystem = false
})

local MainTab = Window:CreateTab("Main", "user")
local CombatTab = Window:CreateTab("Combat", "sword")
local MiscTab = Window:CreateTab("Misc", "settings")

_G.Settings = { ESP = false, FlySpeed = 50, Flying = false, ShiftLock = false }

-- [1. ESP ENGINE]
local function CreateESP(player)
    local espObj = Drawing.new("Square")
    espObj.Thickness = 1.5
    espObj.Filled = false
    espObj.Color = Color3.fromRGB(255, 0, 0)
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not _G.Settings.ESP or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or player.Character.Humanoid.Health <= 0 then
            espObj:Remove()
            connection:Disconnect()
            player:SetAttribute("HasESP", nil)
            return
        end
        local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
        if onScreen then
            local size = (Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position - Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position + Vector3.new(0, 3, 0)).Y) * 0.5
            espObj.Size = Vector2.new(size * 1.5, size * 2.5)
            espObj.Position = Vector2.new(pos.X - espObj.Size.X / 2, pos.Y - espObj.Size.Y / 2)
            espObj.Visible = true
        else espObj.Visible = false end
    end)
end

task.spawn(function()
    while true do
        if _G.Settings.ESP then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and not player:GetAttribute("HasESP") then
                    player:SetAttribute("HasESP", true)
                    CreateESP(player)
                end
            end
        end
        task.wait(0.5)
    end
end)

-- [2. MAIN CONTROLS]
MainTab:CreateToggle({Name = "ESP Box (Tự động)", Callback = function(V) _G.Settings.ESP = V end})

local FlyConn
MainTab:CreateToggle({Name = "Bật Fly (Thông minh)", Callback = function(Value)
    _G.Settings.Flying = Value
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if Value then
        local bv = Instance.new("BodyVelocity", root)
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(0, 0, 0)
        FlyConn = RunService.RenderStepped:Connect(function()
            if _G.Settings.Flying then
                local moveDir = LocalPlayer.Character.Humanoid.MoveDirection
                if moveDir.Magnitude > 0 then
                    bv.Velocity = (Camera.CFrame.LookVector * moveDir.Z * _G.Settings.FlySpeed) + (Camera.CFrame.RightVector * moveDir.X * _G.Settings.FlySpeed)
                else bv.Velocity = Vector3.new(0, 0, 0) end
            else bv:Destroy(); if FlyConn then FlyConn:Disconnect() end end
        end)
    else if FlyConn then FlyConn:Disconnect() end; for _,v in pairs(root:GetChildren()) do if v:IsA("BodyVelocity") then v:Destroy() end end end
end})

MainTab:CreateToggle({Name = "Shift Lock (Khóa góc)", Callback = function(Value)
    _G.Settings.ShiftLock = Value
    RunService.RenderStepped:Connect(function()
        if _G.Settings.ShiftLock and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.Humanoid.AutoRotate = false
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(LocalPlayer.Character.HumanoidRootPart.Position, Vector3.new(Mouse.Hit.p.X, LocalPlayer.Character.HumanoidRootPart.Position.Y, Mouse.Hit.p.Z))
        else LocalPlayer.Character.Humanoid.AutoRotate = true end
    end)
end})

-- [3. KILL ALL (FIXED DATA)]
CombatTab:CreateButton({Name = "Kill All (Fixed Attack)", Callback = function()
    local Remote = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("GameRemoteFunction")
    local Tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not Tool then Rayfield:Notify({Title = "Lỗi", Content = "Hãy cầm vũ khí!"}); return end
    
    local function vec(x,y,z) return {x=x, y=y, z=z} end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local pos = player.Character.HumanoidRootPart.Position
            local myPos = LocalPlayer.Character.HumanoidRootPart.Position
            
            local args = {
                "AttemptWeaponHit",
                {
                    damage = 100, tool = Tool, enemyModel = player.Character,
                    hitboxSize = vec(9, 14, 8), hitboxOffset = vec(0, 0, -1.5),
                    weaponDefinition = {
                        attackCycle = {
                            ["1"] = {knockbackMul=1, slowMult=0.2, attackTime=0.65, lungeMul=1, slowTime=1.5},
                            ["4"] = {lungeMult=2.25, attackTime=0.98, slowMult=0.2, knockbackMult=2.25, slowTime=1.5}
                        },
                        attackOrder = {"1", "4"}
                    }
                },
                {{enemyModel = player.Character, origin = vec(myPos.X, myPos.Y, myPos.Z), distance = 1}}
            }
            pcall(function() Remote:InvokeServer(unpack(args)) end)
            task.wait(0.05)
        end
    end
end})

-- [4. MISC]
MiscTab:CreateButton({Name = "Anti-AFK (Treo máy)", Callback = function()
    local vu = game:GetService("VirtualUser")
    game:GetService("Players").LocalPlayer.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end})

Rayfield:Notify({Title = "Hoàn tất", Content = "Script đã nạp toàn bộ tính năng!", Duration = 3})
