--[[ 
    Silent Assassin - Ultimate Advanced Toolkit
    Phiên bản tối ưu hóa cho di động: ESP Tự động quét, Fly thông minh, ShiftLock
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local Window = Rayfield:CreateWindow({
   Name = "Silent Assassin - Ultimate Tool",
   LoadingTitle = "Đang khởi tạo...",
   LoadingSubtitle = "Hệ thống hỗ trợ AI Collaborator",
   KeySystem = false
})

local MainTab = Window:CreateTab("Main", nil)

_G.Settings = {
    ESP = false,
    FlySpeed = 50,
    FlyEnabled = false,
    ShiftLock = false
}

-- [ESP ENGINE: Tự động quét liên tục]
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
        else
            espObj.Visible = false
        end
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

MainTab:CreateToggle({Name = "ESP Box (Tự động cập nhật)", Callback = function(V) _G.Settings.ESP = V end})

-- [FLY ENGINE: Bay theo hướng nhìn, chỉ bay khi di chuyển]
local FlyConn
MainTab:CreateInput({Name = "Tốc độ bay", PlaceholderText = "50", Callback = function(Text) _G.Settings.FlySpeed = tonumber(Text) or 50 end})

MainTab:CreateToggle({
    Name = "Bật/Tắt Fly (Thông minh)",
    Callback = function(Value)
        _G.Settings.FlyEnabled = Value
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        if Value then
            local bv = Instance.new("BodyVelocity", root)
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bv.Velocity = Vector3.new(0, 0, 0)
            
            FlyConn = RunService.RenderStepped:Connect(function()
                if _G.Settings.FlyEnabled then
                    local moveDir = LocalPlayer.Character.Humanoid.MoveDirection
                    if moveDir.Magnitude > 0 then
                        bv.Velocity = (Camera.CFrame.LookVector * moveDir.Z * _G.Settings.FlySpeed) + (Camera.CFrame.RightVector * moveDir.X * _G.Settings.FlySpeed)
                    else
                        bv.Velocity = Vector3.new(0, 0, 0)
                    end
                else
                    bv:Destroy()
                    if FlyConn then FlyConn:Disconnect() end
                end
            end)
        else
            if FlyConn then FlyConn:Disconnect() end
            for _, v in pairs(root:GetChildren()) do if v:IsA("BodyVelocity") then v:Destroy() end end
        end
    end
})

-- [SHIFT LOCK ENGINE: Khóa tâm nhìn]
MainTab:CreateToggle({
    Name = "Shift Lock (Khóa góc nhìn)",
    Callback = function(Value)
        _G.Settings.ShiftLock = Value
        RunService.RenderStepped:Connect(function()
            if _G.Settings.ShiftLock and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.Humanoid.AutoRotate = false
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(LocalPlayer.Character.HumanoidRootPart.Position, Vector3.new(Mouse.Hit.p.X, LocalPlayer.Character.HumanoidRootPart.Position.Y, Mouse.Hit.p.Z))
            else
                LocalPlayer.Character.Humanoid.AutoRotate = true
            end
        end)
    end
})

-- [SPEED ENGINE: Có nút kích hoạt riêng]
local CurrentSpeed = 16
MainTab:CreateInput({Name = "Nhập tốc độ chạy", PlaceholderText = "16", Callback = function(Text) CurrentSpeed = tonumber(Text) or 16 end})
MainTab:CreateButton({
    Name = "Kích hoạt tốc độ",
    Callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = CurrentSpeed
            Rayfield:Notify({Title = "Thông báo", Content = "Đã chỉnh Speed thành: "..CurrentSpeed, Duration = 2})
        end
    end
})

Rayfield:Notify({Title = "Hoàn tất", Content = "Script đã nạp toàn bộ tính năng!", Duration = 3})
