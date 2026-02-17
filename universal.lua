-- Load YANZ GUI
local yanz = loadstring(game:HttpGet("https://raw.githubusercontent.com/Ryannnyzz/Scripts/refs/heads/main/gui.lua"))()

-- ================= TAB INFO =================
yanz:SetInfo({
    Game = game.Name,
    Player = game.Players.LocalPlayer.Name,
    UserId = game.Players.LocalPlayer.UserId,
    JobId = game.JobId
})

-- ================= TAB PLAYER =================
local playerTab = yanz:AddTab("Player")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ===== FLY =====
local flying = false
local flySpeed = 50
local bv

yanz:Toggle(playerTab, "Fly", function(v)
    flying = v

    if flying then
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")

        bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(1e9,1e9,1e9)
        bv.Parent = hrp

        RunService:BindToRenderStep("YANZ_FLY", 0, function()
            bv.Velocity = workspace.CurrentCamera.CFrame.LookVector * flySpeed
        end)
    else
        RunService:UnbindFromRenderStep("YANZ_FLY")
        if bv then bv:Destroy() end
    end
end)

-- ===== SPEED SLIDER =====
yanz:Slider(playerTab, "WalkSpeed", 16, 200, function(v)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = v end
end)

-- ===== INFINITE JUMP =====
local infJump = false

yanz:Toggle(playerTab, "Infinite Jump", function(v)
    infJump = v
end)

game:GetService("UserInputService").JumpRequest:Connect(function()
    if infJump then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState("Jumping") end
    end
end)

-- ===== JUMP POWER SLIDER =====
yanz:Slider(playerTab, "Jump Power", 50, 200, function(v)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.JumpPower = v end
end)

-- ================= TAB OTHER =================
local otherTab = yanz:AddTab("Other")

-- ===== ESP PLAYER =====
local espEnabled = false
local espFolder = Instance.new("Folder", workspace)
espFolder.Name = "YANZ_ESP"

local function createESP(plr)
    if plr == LocalPlayer then return end

    local box = Instance.new("BoxHandleAdornment")
    box.Size = Vector3.new(4,6,2)
    box.AlwaysOnTop = true
    box.ZIndex = 5
    box.Color3 = Color3.new(1,0,0)
    box.Name = plr.Name
    box.Parent = espFolder

    RunService.RenderStepped:Connect(function()
        if espEnabled and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            box.Adornee = plr.Character.HumanoidRootPart
        else
            box.Adornee = nil
        end
    end)
end

yanz:Toggle(otherTab, "ESP Player", function(v)
    espEnabled = v

    if v then
        for _,p in pairs(Players:GetPlayers()) do
            createESP(p)
        end
    else
        espFolder:ClearAllChildren()
    end
end)

Players.PlayerAdded:Connect(function(p)
    if espEnabled then
        createESP(p)
    end
end)

-- ===== NOCLIP =====
local noclip = false

yanz:Toggle(otherTab, "Noclip", function(v)
    noclip = v
end)

RunService.Stepped:Connect(function()
    if noclip and LocalPlayer.Character then
        for _,part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)
