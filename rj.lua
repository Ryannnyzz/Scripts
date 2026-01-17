-- ==============================
-- DISCORD WEBHOOK RECONNECT LOG
-- ==============================

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId
local JobId = game.JobId

local WEBHOOK_URL = "ISI_WEBHOOK_DISCORD_KAMU"

-- ==============================
-- SEND WEBHOOK
-- ==============================
local function sendWebhook(title, description, color)
    local data = {
        username = "Reconnect Logger",
        embeds = {{
            title = title,
            description = description,
            color = color or 65280,
            footer = {
                text = "Roblox Reconnect Logger"
            },
            timestamp = DateTime.now():ToIsoDate()
        }}
    }

    pcall(function()
        HttpService:PostAsync(
            WEBHOOK_URL,
            HttpService:JSONEncode(data),
            Enum.HttpContentType.ApplicationJson
        )
    end)
end

-- ==============================
-- NOTIFY IN GAME
-- ==============================
local function notify(text)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = "Reconnect",
            Text = text,
            Duration = 5
        })
    end)
end

-- ==============================
-- ON LOAD
-- ==============================
sendWebhook(
    "✅ Script Loaded",
    "**Player:** " .. LocalPlayer.Name ..
    "\n**PlaceId:** " .. PlaceId ..
    "\n**JobId:** " .. JobId,
    5763719
)

notify("Loaded!")

-- ==============================
-- AUTO RECONNECT FUNCTION
-- ==============================
local function reconnect()
    sendWebhook(
        "🔄 Reconnecting...",
        "**Player:** " .. LocalPlayer.Name ..
        "\n**PlaceId:** " .. PlaceId,
        16776960
    )

    task.wait(2)
    TeleportService:Teleport(PlaceId, LocalPlayer)
end

-- ==============================
-- KICK / ERROR DETECTION
-- ==============================
LocalPlayer.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.Failed then
        sendWebhook(
            "❌ Teleport Failed",
            "**Player:** " .. LocalPlayer.Name,
            16711680
        )
    end
end)

-- ==============================
-- SERVER SHUTDOWN DETECT
-- ==============================
game:GetService("RunService").Heartbeat:Connect(function()
    if #Players:GetPlayers() <= 0 then
        sendWebhook(
            "⚠️ Server Shutdown",
            "Server closed unexpectedly",
            16744192
        )
        reconnect()
    end
end)

-- ==============================
-- DISCONNECT / MULTI DEVICE
-- ==============================
GuiService.ErrorMessageChanged:Connect(function(msg)
    if msg ~= "" then
        sendWebhook(
            "🚫 Disconnected",
            "**Reason:** " .. msg,
            16711680
        )
        reconnect()
    end
end)
