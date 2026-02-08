-- BAĞLANTI VE ANA DEĞİŞKENLER
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

-- KAVO UI LIBRARY (Tüm Executorlar İçin Hata Kontrollü)
local status, Library = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
end)

if not status then
    warn("Kütüphane yüklenemedi!")
    return
end

local Window = Library.CreateLib("🇹🇷 1213(v1) - FULL FIX 🇹🇷", "BloodTheme")
local MainTab = Window:NewTab("Hileler")
local Section = MainTab:NewSection("Savaş ve Görsel")

-- --- AYARLAR ---
local espActive = false
local HitboxActive = false
local FlyActive = false
local FlySpeed = 50
local boxColor = Color3.fromRGB(255, 0, 0)
local hitboxSize = 12

-- --- G TUŞU (UI AÇ/KAPAT) ---
UIS.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.G then 
        Library:ToggleUI() 
    end
end)

-- --- ESP SİSTEMİ ---
Section:NewToggle("Kutu ESP", "Oyuncuları kutu içine alır.", function(state) espActive = state end)
Section:NewColorPicker("ESP Rengi", "Renk seç.", boxColor, function(c) boxColor = c end)

RS.RenderStepped:Connect(function()
    if espActive then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = p.Character.HumanoidRootPart
                local box = hrp:FindFirstChild("1213_ESP") or Instance.new("BoxHandleAdornment")
                
                box.Name = "1213_ESP"
                box.Parent = hrp
                box.AlwaysOnTop = true
                box.ZIndex = 10
                box.Transparency = 0.5
                box.Adornee = hrp
                box.Color3 = boxColor
                box.Size = Vector3.new(4, 6, 1)
            end
        end
    else
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local box = p.Character.HumanoidRootPart:FindFirstChild("1213_ESP")
                if box then box:Destroy() end
            end
        end
    end
end)

-- --- HITBOX SİSTEMİ (KAPANMA SORUNU ÇÖZÜLDÜ) ---
Section:NewToggle("Dev Hitbox", "Kapatınca anında eski haline döner.", function(state) 
    HitboxActive = state 
    
    -- EĞER KAPATILDIYSA: Döngüyü beklemeden hemen temizlik yap
    if not state then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = v.Character.HumanoidRootPart
                hrp.Size = Vector3.new(2, 2, 1) -- Orijinal Roblox Boyutu
                hrp.Transparency = 1
                hrp.Color = Color3.fromRGB(163, 162, 165)
                hrp.Material = Enum.Material.Plastic
                hrp.CanCollide = true
            end
        end
    end
end)

Section:NewSlider("Hitbox Boyutu", "Boyutu ayarla.", 25, 2, function(s) hitboxSize = s end)

RS.RenderStepped:Connect(function()
    if HitboxActive then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = v.Character.HumanoidRootPart
                -- Aktifken sürekli zorla
                hrp.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                hrp.Transparency = 0.7
                hrp.Color = Color3.fromRGB(255, 0, 0)
                hrp.Material = Enum.Material.Neon
                hrp.CanCollide = false
            end
        end
    end
end)

-- --- FLY (UÇMA) ---
Section:NewToggle("Fly (Uçma)", "W-A-S-D ile uçun.", function(state)
    FlyActive = state
    if not state then
        local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            if hrp:FindFirstChild("FlyBV") then hrp.FlyBV:Destroy() end
            if hrp:FindFirstChild("FlyBG") then hrp.FlyBG:Destroy() end
        end
    end
end)

Section:NewSlider("Fly Hızı", "Uçuş hızı.", 300, 10, function(s) FlySpeed = s end)

RS.RenderStepped:Connect(function()
    if FlyActive and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = Player.Character.HumanoidRootPart
        local cam = workspace.CurrentCamera
        
        local bv = hrp:FindFirstChild("FlyBV") or Instance.new("BodyVelocity", hrp)
        bv.Name = "FlyBV"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        
        local bg = hrp:FindFirstChild("FlyBG") or Instance.new("BodyGyro", hrp)
        bg.Name = "FlyBG"
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bg.CFrame = cam.CFrame
        
        local direction = Vector3.new(0, 0, 0)
        if UIS:IsKeyDown(Enum.KeyCode.W) then direction = direction + cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then direction = direction - cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then direction = direction - cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then direction = direction + cam.CFrame.RightVector end
        
        bv.Velocity = direction * FlySpeed
    end
end)

-- --- DİĞER ÖZELLİKLER ---
Section:NewSlider("Yürüme Hızı", "Hız.", 250, 16, function(s) 
    if Player.Character and Player.Character:FindFirstChild("Humanoid") then 
        Player.Character.Humanoid.WalkSpeed = s 
    end 
end)

Section:NewSlider("Zıplama Gücü", "Zıplama.", 500, 50, function(s) 
    if Player.Character and Player.Character:FindFirstChild("Humanoid") then 
        Player.Character.Humanoid.JumpPower = s
        Player.Character.Humanoid.UseJumpPower = true 
    end 
end)

-- --- AIMBOT ---
local AimActive = false
Section:NewToggle("Aimbot (Sağ Tık)", "Kilitlenir.", function(state) AimActive = state end)

RS.RenderStepped:Connect(function()
    if AimActive and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = nil
        local dist = math.huge
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= Player and v.Character and v.Character:FindFirstChild("Head") then
                local hum = v.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local d = (v.Character.Head.Position - Player.Character.Head.Position).Magnitude
                    if d < dist then target = v; dist = d end
                end
            end
        end
        if target then
            workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, target.Character.Head.Position)
        end
    end
end)
