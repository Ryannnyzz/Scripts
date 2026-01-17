-- ==============================
-- AUTO RECONNECT (ORIGINAL)
-- ==============================

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local GuiService = game:GetService("GuiService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId

-- ==============================
-- NOTIFICATION
-- ==============================
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "Auto Reconnect",
        Text = "Loaded",
        Duration = 4
    })
end)

-- ==============================
-- RECONNECT FUNCTION
-- ==============================
local reconnecting = false
local function reconnect()
    if reconnecting then return end
    reconnecting = true
    task.wait(2)
    TeleportService:Teleport(PlaceId, LocalPlayer)
end

-- ==============================
-- TELEPORT FAILED
-- ==============================
LocalPlayer.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.Failed then
        reconnect()
    end
end)

-- ==============================
-- DISCONNECT / KICK DETECT
-- ==============================
GuiService.ErrorMessageChanged:Connect(function(msg)
    if msg ~= "" then
        reconnect()
    end
end)Frame.BackgroundTransparency = 1

Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 28)
Title.Position = UDim2.new(0, 10, 0, 8)
Title.Text = "Loaded!"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.BackgroundTransparency = 1
Title.TextXAlignment = Left
Title.Parent = Frame

local Desc = Instance.new("TextLabel")
Desc.Size = UDim2.new(1, -20, 0, 28)
Desc.Position = UDim2.new(0, 10, 0, 38)
Desc.Text = ""
Desc.TextColor3 = Color3.fromRGB(200, 200, 200)
Desc.Font = Enum.Font.Gotham
Desc.TextSize = 13
Desc.BackgroundTransparency = 1
Desc.TextXAlignment = Left
Desc.Parent = Frame

local function Notify(title, desc, duration)
    duration = duration or 4
    Title.Text = title
    Desc.Text = desc

    Frame.BackgroundTransparency = 0.15
    TweenService:Create(
        Frame,
        TweenInfo.new(0.4, Enum.EasingStyle.Quint),
        { Position = UDim2.new(1, -20, 1, -120) }
    ):Play()

    task.wait(duration)

    TweenService:Create(
        Frame,
        TweenInfo.new(0.4, Enum.EasingStyle.Quint),
        { Position = UDim2.new(1, 20, 1, -120) }
    ):Play()

    task.wait(0.4)
    Frame.BackgroundTransparency = 1
end

-- ===============================
-- INITIAL NOTIFY
-- ===============================
Notify(
    "Loaded!",
    _G.ServerInfo.IsPrivate and "Private Server Detected" or "Public Server Detected"
)

-- ===============================
-- REJOIN FUNCTION
-- ===============================
local function RejoinServer()
    task.wait(2)

    pcall(function()
        if _G.ServerInfo.IsPrivate then
            TeleportService:TeleportToPrivateServer(
                _G.ServerInfo.PlaceId,
                game.PrivateServerId,
                { LocalPlayer }
            )
        else
            TeleportService:TeleportToPlaceInstance(
                _G.ServerInfo.PlaceId,
                _G.ServerInfo.JobId,
                LocalPlayer
            )
        end
    end)
end

-- ===============================
-- DETECT DISCONNECT / ERROR
-- ===============================
GuiService.ErrorMessageChanged:Connect(function()
    Notify("Reconnecting...", "Connection lost")
    RejoinServer()
end)

-- Teleport fail / account collision
LocalPlayer.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.Failed then
        Notify("Reconnecting...", "Teleport failed")
        RejoinServer()
    end
end)

-- Backup safety loop
task.spawn(function()
    while task.wait(10) do
        if not LocalPlayer.Parent then
            RejoinServer()
            break
        end
    end
end)  Title = "Reconnect",
            Text = t,
            Duration = 4
        })
    end)
end

notify("Reconnect loaded")

-- =========================
-- RECONNECT LOGIC
-- =========================
local reconnecting = false
local function reconnect(reason)
    if not enabled or reconnecting then return end
    reconnecting = true
    notify("Reconnecting...\n"..tostring(reason))
    task.wait(2)
    TeleportService:TeleportToPlaceInstance(PLACE_ID, JOB_ID, LP)
end

LP.OnTeleport:Connect(function(s)
    if s == Enum.TeleportState.Failed then
        reconnect("Teleport Failed")
    end
end)

GuiService.ErrorMessageChanged:Connect(function(msg)
    if msg ~= "" then
        reconnect(msg)
    end
end)

RunService.Heartbeat:Connect(function()
    if #Players:GetPlayers() <= 1 then
        reconnect("Server Shutdown")
    end
end)
    ]])
end

-- =========================
-- SAVE DEFAULT CONFIG
-- =========================
if writefile then
    writefile(CONFIG_PATH, HttpService:JSONEncode({ enabled = true }))
end

-- =========================
-- IMMEDIATE REJOIN LAST JOB
-- =========================
task.delay(1, function()
    TeleportService:TeleportToPlaceInstance(PLACE_ID, JOB_ID, LP)
end)
