--// ===============================
--// CONFIG
--// ===============================
getgenv().whscript = "Reconnect Logger"
getgenv().webhookexecUrl = "https://discord.com/api/webhooks/1457043568223977606/Ikc8Hk35FsKTfgL-cIxYk9jNCzKbbQRLhpjZtoWvqF8dFJ_Ovsh0E1ZW7un5hZ1arPVk"
getgenv().ExecLogSecret = false -- Delta tidak support secret

--// ===============================
--// SERVICES
--// ===============================
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local Stats = game:GetService("Stats")
local MarketplaceService = game:GetService("MarketplaceService")

local player = Players.LocalPlayer
local PLACE_ID = game.PlaceId
local FIRST_JOB_ID = game.JobId

--// ===============================
--// ANTI DOUBLE EXEC (DELTA)
--// ===============================
if CoreGui:FindFirstChild("ReconnectExec") then
    warn("Script already executed")
    return
end

local flag = Instance.new("Folder")
flag.Name = "ReconnectExec"
flag.Parent = CoreGui

--// ===============================
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
