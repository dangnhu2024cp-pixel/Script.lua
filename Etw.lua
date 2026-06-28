--[[ 
    Eat The World - Master Toolkit
    Features: Auto Grab, Eat, Sell & Auto Movement (SetCubes)
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local LocalPlayer = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [ĐỊNH NGHĨA REMOTE]
local CharEvents = LocalPlayer.Character:WaitForChild("Events")
local GrabRemote = CharEvents:WaitForChild("Grab")
local EatRemote = CharEvents:WaitForChild("Eat")
local SellRemote = CharEvents:WaitForChild("Sell")
local SetCubesRemote = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SetCubes")

local Window = Rayfield:CreateWindow({Name = "Eat The World - Script by 2mmlxp", LoadingTitle = "loading...", KeySystem = false})
local MainTab = Window:CreateTab("Main", nil)

_G.Settings = { Grab = false, Eat = false, Sell = false, Move = false }

-- [CORE LOOP]
task.spawn(function()
    while true do
        if _G.Settings.Grab then
            pcall(function() GrabRemote:FireServer() end)
        end
        if _G.Settings.Eat then
            pcall(function() EatRemote:FireServer() end)
        end
        if _G.Settings.Sell then
            pcall(function() SellRemote:FireServer() end)
        end
        if _G.Settings.Move then
            -- SetCubes thường cần tọa độ hoặc ID khối. 
            -- Đây là lệnh gửi vị trí nhân vật hiện tại để đồng bộ server.
            pcall(function() SetCubesRemote:FireServer(LocalPlayer.Character.HumanoidRootPart.Position) end)
        end
        task.wait(0.2) -- Delay an toàn
    end
end)

-- [MENU]
MainTab:CreateToggle({Name = "Auto Grab", Callback = function(V) _G.Settings.Grab = V end})
MainTab:CreateToggle({Name = "Auto Eat", Callback = function(V) _G.Settings.Eat = V end})
MainTab:CreateToggle({Name = "Auto Sell", Callback = function(V) _G.Settings.Sell = V end})
MainTab:CreateToggle({Name = "Auto Move (Sync SetCubes)", Callback = function(V) _G.Settings.Move = V end})

-- [EXTRA: TỐC ĐỘ]
MainTab:CreateSlider({
    Name = "Tốc độ thực thi (Delay)",
    Range = {0.05, 0.5},
    Increment = 0.05,
    Suffix = "s",
    CurrentValue = 0.2,
    Callback = function(V) task.wait(V) end
})

Rayfield:Notify({Title = "Thành công", Content = "Đã nạp full tính năng!", Duration = 3})
