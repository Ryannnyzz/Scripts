
-- ==============================
-- AUTO RECONNECT (NO WEBHOOK)
-- ==============================

--// Services
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

--// Player & Server Info
local LocalPlayer = Players.LocalPlayer
local PLACE_ID = game.PlaceId
local FIRST_JOB_ID = game.JobId

-- ==============================
-- ANTI DOUBLE EXEC (DELTA SAFE)
-- ==============================
if CoreGui:FindFirstChild("RJ_EXECUTED") then
warn("Reconnect script already running")
return
end

local flag = Instance.new("Folder")
flag.Name = "RJ_EXECUTED"
flag.Parent = CoreGui

-- ==============================
-- NOTIFICATION
-- ==============================
local function notify(text)
pcall(function()
StarterGui:SetCore("SendNotification", {
Title = "Reconnect",
Text = text,
Duration = 5
})
end)
end

notify("Loaded! Auto Reconnect Active")

-- ==============================
-- RECONNECT FUNCTION
-- ==============================
local reconnecting = false

local function reconnect(reason)
if reconnecting then return end
reconnecting = true

notify("Reconnecting...\nReason: " .. tostring(reason))  

task.wait(2)  

-- reconnect ke SERVER PERTAMA  
TeleportService:TeleportToPlaceInstance(  
    PLACE_ID,  
    FIRST_JOB_ID,  
    LocalPlayer  
)

end

-- ==============================
-- TELEPORT FAILED
-- ==============================
LocalPlayer.OnTeleport:Connect(function(state)
if state == Enum.TeleportState.Failed then
reconnect("Teleport Failed")
end
end)

-- ==============================
-- DISCONNECT / MULTI DEVICE
-- ==============================
GuiService.ErrorMessageChanged:Connect(function(msg)
if msg and msg ~= "" then
reconnect(msg)
end
end)

-- ==============================
-- SERVER SHUTDOWN DETECT
-- ==============================
RunService.Heartbeat:Connect(function()
if #Players:GetPlayers() <= 1 then
reconnect("Server Shutdown")
end
end)local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")

local LP = Players.LocalPlayer
local PLACE_ID = game.PlaceId
local JOB_ID = game.JobId
local CONFIG_PATH = "autoexec/delta_reconnect_config.json"

-- =========================
-- ANTI DOUBLE EXEC
-- =========================
if CoreGui:FindFirstChild("RJ_EXECUTED") then return end
local flag = Instance.new("Folder")
flag.Name = "RJ_EXECUTED"
flag.Parent = CoreGui

-- =========================
-- LOAD CONFIG
-- =========================
local enabled = false
pcall(function()
    if isfile(CONFIG_PATH) then
        enabled = HttpService:JSONDecode(readfile(CONFIG_PATH)).enabled
    end
end)

-- =========================
-- UI CONFIRM PANEL
-- =========================
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "ReconnectPanel"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.35, 0.25)
frame.Position = UDim2.fromScale(0.325, 0.35)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.fromScale(1,0.35)
title.Text = "Enable Auto Reconnect?"
title.TextScaled = true
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1

local function button(txt, pos, callback)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.fromScale(0.4,0.3)
    b.Position = pos
    b.Text = txt
    b.TextScaled = true
    b.BackgroundColor3 = Color3.fromRGB(40,40,40)
    b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(callback)
end

button("YES", UDim2.fromScale(0.05,0.55), function()
    writefile(CONFIG_PATH, HttpService:JSONEncode({ enabled = true }))
    enabled = true
    gui:Destroy()
end)

button("NO", UDim2.fromScale(0.55,0.55), function()
    writefile(CONFIG_PATH, HttpService:JSONEncode({ enabled = false }))
    enabled = false
    gui:Destroy()
end)

-- =========================
-- NOTIFY
-- =========================
local function notify(t)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Reconnect",
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

-- default config (sekali)
if not isfile(CONFIG_PATH) then
    writefile(CONFIG_PATH, HttpService:JSONEncode({ enabled = true }))
end

-- flag supaya rejoin cuma sekali (install time)
if not isfile(FLAG_PATH) then
    writefile(FLAG_PATH, "installed")
    task.delay(1, function()
        TeleportService:TeleportToPlaceInstance(PLACE_ID, JOB_ID, LP)
    end)
endlocal Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")

local LP = Players.LocalPlayer
local PLACE_ID = game.PlaceId
local JOB_ID = game.JobId
local CONFIG_PATH = "Autoexecute/delta_reconnect_config.json"

-- =========================
-- ANTI DOUBLE EXEC
-- =========================
if CoreGui:FindFirstChild("RJ_EXECUTED") then return end
local flag = Instance.new("Folder")
flag.Name = "RJ_EXECUTED"
flag.Parent = CoreGui

-- =========================
-- LOAD CONFIG
-- =========================
local enabled = false
pcall(function()
    if isfile(CONFIG_PATH) then
        enabled = HttpService:JSONDecode(readfile(CONFIG_PATH)).enabled
    end
end)

-- =========================
-- UI PANEL
-- =========================
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "ReconnectPanel"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.35, 0.25)
frame.Position = UDim2.fromScale(0.325, 0.35)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.fromScale(1,0.35)
title.Text = "Enable Auto Reconnect?"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.TextScaled = true

local function button(txt, pos, callback)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.fromScale(0.4,0.3)
    b.Position = pos
    b.Text = txt
    b.TextScaled = true
    b.BackgroundColor3 = Color3.fromRGB(40,40,40)
    b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(callback)
end

button("YES", UDim2.fromScale(0.05,0.55), function()
    writefile(CONFIG_PATH, HttpService:JSONEncode({enabled = true}))
    enabled = true
    gui:Destroy()
end)

button("NO", UDim2.fromScale(0.55,0.55), function()
    writefile(CONFIG_PATH, HttpService:JSONEncode({enabled = false}))
    enabled = false
    gui:Destroy()
end)

-- =========================
-- NOTIFY
-- =========================
local function notify(t)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Reconnect",
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
