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
end)
