-- ==============================
-- AUTO EXECUTE SESSION (NO AUTOEXEC FOLDER)
-- ==============================

local HttpService = game:GetService("HttpService")
local SESSION_FILE = "delta_reconnect_session.json"

-- save session once
if writefile and readfile then
    if not isfile(SESSION_FILE) then
        writefile(SESSION_FILE, HttpService:JSONEncode({
            gameId = game.PlaceId,
            enabled = true
        }))
    end
end

-- ==============================
-- AUTO RESTORE ON TELEPORT
-- ==============================

pcall(function()
    game:GetService("Players").LocalPlayer.OnTeleport:Connect(function(state)
        if state == Enum.TeleportState.Started then
            if readfile and isfile and isfile(SESSION_FILE) then
                queue_on_teleport(readfile(SESSION_FILE))
            end
        end
    end)
end)

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

notify("Loaded! Auto Reconnect (Session Mode)")

-- ==============================
-- RECONNECT FUNCTION
-- ==============================
local reconnecting = false

local function reconnect(reason)
    if reconnecting then return end
    reconnecting = true

    notify("Reconnecting...\nReason: " .. tostring(reason))
    task.wait(2)

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
end)    task.wait(2)
    TeleportService:Teleport(PlaceId, LocalPlayer)
end

-- ==============================
-- DISCONNECT DETECT
-- ==============================
GuiService.ErrorMessageChanged:Connect(function(msg)
    if msg ~= "" then
        reconnect()
    end
end)

-- ==============================
-- TELEPORT FAIL
-- ==============================
LocalPlayer.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.Failed then
        reconnect()
    end
end)        end

        notify("Reconnected!")

        local reconnecting = false
        local function reconnect()
            if reconnecting then return end
            reconnecting = true
            notify("Reconnecting...")
            task.wait(2)

            pcall(function()
                TeleportService:TeleportToPlaceInstance(PLACE_ID, FIRST_JOB_ID, LocalPlayer)
            end)

            task.delay(5, function()
                pcall(function()
                    TeleportService:Teleport(PLACE_ID, LocalPlayer)
                end)
            end)
        end

        GuiService.ErrorMessageChanged:Connect(function(msg)
            if msg and msg ~= "" then
                reconnect()
            end
        end)

        LocalPlayer.OnTeleport:Connect(function(state)
            if state == Enum.TeleportState.Failed then
                reconnect()
            end
        end)

        RunService.Heartbeat:Connect(function()
            if #Players:GetPlayers() <= 0 then
                reconnect()
            end
        end)
    ]])
end

-- ==============================
-- NOTIFY
-- ==============================
pcall(function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "Reconnect System",
        Text = "Loaded!",
        Duration = 4
    })
end)

-- ==============================
-- MAIN RECONNECT LOGIC
-- ==============================
local reconnecting = false

local function reconnect()
    if reconnecting then return end
    reconnecting = true

    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = "Reconnect System",
            Text = "Reconnecting...",
            Duration = 4
        })
    end)

    task.wait(2)

    pcall(function()
        TeleportService:TeleportToPlaceInstance(PLACE_ID, FIRST_JOB_ID, LocalPlayer)
    end)

    task.delay(5, function()
        pcall(function()
            TeleportService:Teleport(PLACE_ID, LocalPlayer)
        end)
    end)
end

-- ==============================
-- DETECTORS
-- ==============================
GuiService.ErrorMessageChanged:Connect(function(msg)
    if msg and msg ~= "" then
        reconnect()
    end
end)

LocalPlayer.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.Failed then
        reconnect()
    end
end)

RunService.Heartbeat:Connect(function()
    if #Players:GetPlayers() <= 0 then
        reconnect()
    end
end)--// ===============================
--// NOTIFY
--// ===============================
local function notify(txt)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Reconnect",
            Text = txt,
            Duration = 5
        })
    end)
end

--// ===============================
--// WEBHOOK SEND (DELTA SAFE)
--// ===============================
local function sendWebhook(embed)
    local payload = {
        content = "@everyone",
        embeds = {embed}
    }

    pcall(function()
        HttpService:PostAsync(
            getgenv().webhookexecUrl,
            HttpService:JSONEncode(payload),
            Enum.HttpContentType.ApplicationJson
        )
    end)
end

--// ===============================
--// EXECUTION LOG
--// ===============================
local gameName = MarketplaceService:GetProductInfo(PLACE_ID).Name
local ping = tonumber(Stats.Network.ServerStatsItem["Data Ping"]:GetValueString():match("%d+")) or "N/A"

sendWebhook({
    title = "🚀 Script Execution Detected",
    description = "*Reconnect script executed successfully*",
    color = 0x3498db,
    fields = {
        {
            name = "📜 Script Info",
            value = "```Script: "..getgenv().whscript..
                    "\nTime: "..os.date("%Y-%m-%d %H:%M:%S").."```",
            inline = false
        },
        {
            name = "👤 Player",
            value = "```Username: "..player.Name..
                    "\nUserId: "..player.UserId.."```",
            inline = true
        },
        {
            name = "🎮 Game",
            value = "```"..gameName..
                    "\nPlaceId: "..PLACE_ID..
                    "\nJobId: "..FIRST_JOB_ID.."```",
            inline = false
        },
        {
            name = "📡 Network",
            value = "```Ping: "..ping.." ms```",
            inline = true
        },
        {
            name = "🔁 Join Script",
            value = "```lua\nTeleportService:TeleportToPlaceInstance("..
                    PLACE_ID..", '"..FIRST_JOB_ID.."', player)\n```",
            inline = false
        }
    },
    footer = {
        text = "Delta Reconnect Logger"
    },
    timestamp = DateTime.now():ToIsoDate()
})

notify("Loaded!")

--// ===============================
--// RECONNECT FUNCTION
--// ===============================
local function reconnect(reason)
    sendWebhook({
        title = "🔄 Reconnecting",
        description = "**Reason:** "..reason..
            "\n**JobId:** "..FIRST_JOB_ID,
        color = 0xF1C40F,
        footer = {text = "Auto Reconnect"}
    })

    task.wait(2)
    TeleportService:TeleportToPlaceInstance(
        PLACE_ID,
        FIRST_JOB_ID,
        player
    )
end

--// ===============================
--// DISCONNECT DETECT
--// ===============================
GuiService.ErrorMessageChanged:Connect(function(msg)
    if msg and msg ~= "" then
        reconnect(msg)
    end
end)

--// ===============================
--// TELEPORT FAIL
--// ===============================
player.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.Failed then
        reconnect("Teleport Failed")
    end
end)

--// ===============================
--// SERVER SHUTDOWN
--// ===============================
RunService.Heartbeat:Connect(function()
    if #Players:GetPlayers() <= 1 then
        reconnect("Server Shutdown")
    end
end)
