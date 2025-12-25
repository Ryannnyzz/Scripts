-- ====== CRITICAL DEPENDENCY VALIDATION ======
local success, errorMsg = pcall(function()
    local services = {
        game = game,
        workspace = workspace,
        Players = game:GetService("Players"),
        RunService = game:GetService("RunService"),
        ReplicatedStorage = game:GetService("ReplicatedStorage"),
        HttpService = game:GetService("HttpService")
    }
    
    for serviceName, service in pairs(services) do
        if not service then
            error("Critical service missing: " .. serviceName)
        end
    end
    
    local LocalPlayer = game:GetService("Players").LocalPlayer
    if not LocalPlayer then
        error("LocalPlayer not available")
    end
    
    return true
end)

if not success then
    error("❌ [Auto Fish] Critical dependency check failed: " .. tostring(errorMsg))
    return
end

-- ====================================================================
--                        CORE SERVICES
-- ====================================================================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local humanoid
local function getHumanoid()
    local char = player.Character or player.CharacterAdded:Wait()
    humanoid = char:WaitForChild("Humanoid")
end

getHumanoid()
player.CharacterAdded:Connect(getHumanoid)
local defaultWalkSpeed = 16
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local setclipboard = setclipboard or toclipboard or set_clipboard

-- ====================================================================
--                    CONFIGURATION
-- ====================================================================
local CONFIG_FOLDER = "YanzFishIt"
local CONFIG_FILE = CONFIG_FOLDER .. "/config_" .. LocalPlayer.UserId .. ".json"

local DefaultConfig = {
    AutoFish = false,
    instantFish = false,
    AutoSell = false,
    AutoCatch = false,
    GPUSaver = false,
    BlatantMode = false,
    FishDelay = 1,
    CatchDelay = 0.2,
    SellDelay = 30,
    TeleportLocation = "Sisyphus Statue",
    AutoFavorite = true,
    FavoriteRarity = "Mythic"
}

local Config = {}
for k, v in pairs(DefaultConfig) do Config[k] = v end

-- Teleport Locations (COMPLETE LIST)
local LOCATIONS = {
["Ancient Jungle"] = CFrame.new(1831.71362, 6.62499952, -299.279175, 0.213522509, 1.25553285e-07, -0.976938128, -4.32026184e-08, 1, 1.19074642e-07, 0.976938128, 1.67811702e-08, 0.213522509),
["Christmas Island"] = CFrame.new(589.443909, 5.080366, 1699.825439),
["Christmas Island 2"] = CFrame.new(1175.601318, 23.430645, 1550.207642),
["Coral Reefs"] = CFrame.new(-3114.78198, 1.32066584, 2237.52295, -0.304758579, 1.6556676e-08, -0.952429652, -8.50574935e-08, 1, 4.46003305e-08, 0.952429652, 9.46036067e-08, -0.304758579),
["Crater Island"] = CFrame.new(1016.49072, 20.0919304, 5069.27295, 0.838976264, 3.30379857e-09, -0.544168055, 2.63538391e-09, 1, 1.01344115e-08, 0.544168055, -9.93662219e-09, 0.838976264),
["Esoteric Depths"] = CFrame.new(3248.37109, -1301.53027, 1403.82727, -0.920208454, 7.76270355e-08, 0.391428679, 4.56261056e-08, 1, -9.10549289e-08, -0.391428679, -6.5930152e-08, -0.920208454),
["Fisherman Island"] = CFrame.new(99.731415, 9.531265, 2763.851074),
["Fisherman Island 2"] = CFrame.new(34.518330, 16.785484, 2830.003906),
["Gift Factory"] = CFrame.new(1023.665833, 27.430668, 1663.685547),
["Kohana"] = CFrame.new(-663.904236, 3.04580712, 718.796875, -0.100799225, -2.14183729e-08, -0.994906783, -1.12300391e-08, 1, -2.03902459e-08, 0.994906783, 9.11752096e-09, -0.100799225),
["Lost Isle"] = CFrame.new(-3618.15698, 240.836655, -1317.45801, 1, 0, 0, 0, 1, 0, 0, 0, 1),
["Sacred Temple"] = CFrame.new(1466.92151, -21.8750591, -622.835693, -0.764787138, 8.14444334e-09, 0.644283056, 2.31097452e-08, 1, 1.4791004e-08, -0.644283056, 2.6201187e-08, -0.764787138),
["Sisyphus Statue"] = CFrame.new(-3728.21606, -135.074417, -1012.12744, -0.977224171, 7.74980258e-09, -0.212209702, 1.566994e-08, 1, -3.5640408e-08, 0.212209702, -3.81539813e-08, -0.977224171),
["Travelling Merchant"] = CFrame.new(-134.409286, 3.198100, 2767.216309),
["Treasure Room"] = CFrame.new(-3606.34985, -266.57373, -1580.97339, 0.998743415, 1.12141152e-13, -0.0501160324, -1.56847693e-13, 1, -8.88127842e-13, 0.0501160324, 8.94872392e-13, 0.998743415),
["Tropical Grove"] = CFrame.new(-2095.34106, 197.199997, 3718.08008),
["Underground Cellar"] = CFrame.new(2109.52148, -94.1875076, -708.609131, 0.418592364, 3.34794485e-08, -0.908174217, -5.24141512e-08, 1, 1.27060247e-08, 0.908174217, 4.22825366e-08, 0.418592364),
["Weather Machine"] = CFrame.new(-1488.51196, 83.1732635, 1876.30298, 1, 0, 0, 0, 1, 0, 0, 0, 1)
}

-- ====================================================================
--                     CONFIG FUNCTIONS
-- ====================================================================
local function ensureFolder()
    if not isfolder or not makefolder then return false end
    if not isfolder(CONFIG_FOLDER) then
        pcall(function() makefolder(CONFIG_FOLDER) end)
    end
    return isfolder(CONFIG_FOLDER)
end

local function saveConfig()
    if not writefile or not ensureFolder() then return end
    pcall(function()
        writefile(CONFIG_FILE, HttpService:JSONEncode(Config))
        print("[Config] Settings saved!")
    end)
end

local function loadConfig()
    if not readfile or not isfile or not isfile(CONFIG_FILE) then return end
    pcall(function()
        local data = HttpService:JSONDecode(readfile(CONFIG_FILE))
        for k, v in pairs(data) do
            if DefaultConfig[k] ~= nil then Config[k] = v end
        end
        print("[Config] Settings loaded!")
    end)
end

loadConfig()

-- ====================================================================
--                     NETWORK EVENTS
-- ====================================================================
local function getNetworkEvents()
    local net = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net
    return {
        fishing = net:WaitForChild("RE/FishingCompleted"),
        sell = net:WaitForChild("RF/SellAllItems"),
        charge = net:WaitForChild("RF/ChargeFishingRod"),
        minigame = net:WaitForChild("RF/RequestFishingMinigameStarted"),
        cancel = net:WaitForChild("RF/CancelFishingInputs"),
        equip = net:WaitForChild("RE/EquipToolFromHotbar"),
        unequip = net:WaitForChild("RE/UnequipToolFromHotbar"),
        favorite = net:WaitForChild("RE/FavoriteItem")
    }
end

local Events = getNetworkEvents()

-- ====================================================================
--                     MODULES FOR AUTO FAVORITE
-- ====================================================================
local ItemUtility = require(ReplicatedStorage.Shared.ItemUtility)
local Replion = require(ReplicatedStorage.Packages.Replion)
local PlayerData = Replion.Client:WaitReplion("Data")

-- ====================================================================
--                     RARITY SYSTEM
-- ====================================================================
local RarityTiers = {
    Common = 1,
    Uncommon = 2,
    Rare = 3,
    Epic = 4,
    Legendary = 5,
    Mythic = 6,
    Secret = 7
}

local function getRarityValue(rarity)
    return RarityTiers[rarity] or 0
end

local function getFishRarity(itemData)
    if not itemData or not itemData.Data then return "Common" end
    return itemData.Data.Rarity or "Common"
end

-- ====================================================================
--                     TELEPORT SYSTEM (from dev1.lua)
-- ====================================================================
local Teleport = {}

function Teleport.to(locationName)
    local cframe = LOCATIONS[locationName]
    if not cframe then
        warn("❌ [Teleport] Location not found: " .. tostring(locationName))
        return false
    end
    
    local success = pcall(function()
        local character = LocalPlayer.Character
        if not character then return end
        
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
        
        rootPart.CFrame = cframe
        print("✅ [Teleport] Moved to " .. locationName)
    end)
    
    return success
end

-- ====================================================================
--                     GPU SAVER
-- ====================================================================
local gpuActive = false
local whiteScreen = nil

local function enableGPU()
    if gpuActive then return end
    gpuActive = true
    
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        game.Lighting.GlobalShadows = false
        game.Lighting.FogEnd = 1
        setfpscap(8)
    end)
    
    whiteScreen = Instance.new("ScreenGui")
    whiteScreen.ResetOnSpawn = false
    whiteScreen.DisplayOrder = 999999
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    frame.Parent = whiteScreen
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 400, 0, 100)
    label.Position = UDim2.new(0.5, -200, 0.5, -50)
    label.BackgroundTransparency = 1
    label.Text = "🟢 GPU SAVER ACTIVE\n\nAuto Fish Running..."
    label.TextColor3 = Color3.new(0, 1, 0)
    label.TextSize = 28
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.Parent = frame
    
    whiteScreen.Parent = game.CoreGui
    print("[GPU] GPU Saver enabled")
end

local function disableGPU()
    if not gpuActive then return end
    gpuActive = false
    
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        game.Lighting.GlobalShadows = true
        game.Lighting.FogEnd = 100000
        setfpscap(0)
    end)
    
    if whiteScreen then
        whiteScreen:Destroy()
        whiteScreen = nil
    end
    print("[GPU] GPU Saver disabled")
end

-- ====================================================================
--                     ANTI-AFK
-- ====================================================================
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

print("[Anti-AFK] Protection enabled")

-- ====================================================================
--                     AUTO FAVORITE
-- ====================================================================
local favoritedItems = {}

local function isItemFavorited(uuid)
    local success, result = pcall(function()
        local items = PlayerData:GetExpect("Inventory").Items
        for _, item in ipairs(items) do
            if item.UUID == uuid then
                return item.Favorited == true
            end
        end
        return false
    end)
    return success and result or false
end

local function autoFavoriteByRarity()
    if not Config.AutoFavorite then return end
    
    local targetRarity = Config.FavoriteRarity
    local targetValue = getRarityValue(targetRarity)
    
    if targetValue < 6 then
        targetValue = 6
    end
    
    local favorited = 0
    local skipped = 0
    
    local success = pcall(function()
        local items = PlayerData:GetExpect("Inventory").Items
        
        if not items or #items == 0 then return end
        
        for i, item in ipairs(items) do
            local data = ItemUtility:GetItemData(item.Id)
            if data and data.Data then
                local itemName = data.Data.Name or "Unknown"
                local rarity = getFishRarity(data)
                local rarityValue = getRarityValue(rarity)
                
                if rarityValue >= targetValue and rarityValue >= 6 then
                    if not isItemFavorited(item.UUID) and not favoritedItems[item.UUID] then
                        Events.favorite:FireServer(item.UUID)
                        favoritedItems[item.UUID] = true
                        favorited = favorited + 1
                        print("[Auto Favorite] ⭐ #" .. favorited .. " - " .. itemName .. " (" .. rarity .. ")")
                        task.wait(0.3)
                    else
                        skipped = skipped + 1
                    end
                end
            end
        end
    end)
    
    if favorited > 0 then
        print("[Auto Favorite] ✅ Complete! Favorited: " .. favorited)
    end
end

task.spawn(function()
    while true do
        task.wait(10)
        if Config.AutoFavorite then
            autoFavoriteByRarity()
        end
    end
end)

-- ====================================================================
--                     FISHING LOGIC (FROM YOUR test.lua)
-- ====================================================================
local isFishing = false
local fishingActive = false

-- Helper functions
local function castRod()
    pcall(function()
        Events.equip:FireServer(1)
        task.wait(0.05)
        Events.charge:InvokeServer(1755848498.4834)
        task.wait(0.02)
        Events.minigame:InvokeServer(1.2854545116425, 1)
        print("[Fishing] 🎣 Cast")
    end)
end

local function reelIn()
    pcall(function()
        Events.fishing:FireServer()
        print("[Fishing] ✅ Reel")
    end)
end

-- BLATANT MODE: Your exact implementation
local function blatantFishingLoop()
    while fishingActive and Config.BlatantMode do
        if not isFishing then
            isFishing = true
            
            -- Step 1: Rapid fire casts (2 parallel casts)
            pcall(function()
                Events.equip:FireServer(1)
                task.wait(0.01)
                
                -- Cast 1
                task.spawn(function()
                    Events.charge:InvokeServer(1755848498.4834)
                    task.wait(0.01)
                    Events.minigame:InvokeServer(1.2854545116425, 1)
                end)
                
                task.wait(0.05)
                
                -- Cast 2 (overlapping)
                task.spawn(function()
                    Events.charge:InvokeServer(1755848498.4834)
                    task.wait(0.01)
                    Events.minigame:InvokeServer(1.2854545116425, 1)
                end)
            end)
            
            -- Step 2: Wait for fish to bite
            task.wait(Config.FishDelay)
            
            -- Step 3: Spam reel 5x to instant catch
            for i = 1, 5 do
                pcall(function() 
                    Events.fishing:FireServer() 
                end)
                task.wait(0.01)
            end
            
            -- Step 4: Short cooldown (50% faster)
            task.wait(Config.CatchDelay * 0.5)
            
            isFishing = false
            print("[Blatant] ⚡ Fast cycle")
        else
            task.wait(0.01)
        end
    end
end

-- NORMAL MODE: Your exact implementation
local function normalFishingLoop()
    while fishingActive and not Config.BlatantMode do
        if not isFishing then
            isFishing = true
            
            castRod()
            task.wait(Config.FishDelay)
            reelIn()
            task.wait(Config.CatchDelay)
            
            isFishing = false
        else
            task.wait(0.1)
        end
    end
end

-- INSTANT MODE
local function instantLoop()
    while fishingActive and not Config.BlatantMode do
        if not isFishing then
            isFishing = true
            
            castRod()
            task.wait(0.7)
            reelIn()
            task.wait(0.1)
            
            isFishing = false
        else
            task.wait(0.1)
        end
    end
end

-- Main fishing controller
local function fishingLoop()
    while fishingActive do
        if Config.BlatantMode then
            blatantFishingLoop()
        elseif Config.InstantFish then
            instantLoop()
        else
            normalFishingLoop()
        end

        task.wait(0.1)
    end
end
-- ====================================================================
--                     AUTO CATCH (SPAM SYSTEM)
-- ====================================================================
task.spawn(function()
    while true do
        if Config.AutoCatch and not isFishing then
            pcall(function() 
                Events.fishing:FireServer() 
            end)
        end
        task.wait(Config.CatchDelay)
    end
end)

-- ====================================================================
--                     AUTO SELL
-- ====================================================================
local function simpleSell()
    print("╔═══════════════════════════════════╗")
    print("[Auto Sell] 💰 Selling all non-favorited items...")
    
    local sellSuccess = pcall(function()
        return Events.sell:InvokeServer()
    end)
    
    if sellSuccess then
        print("[Auto Sell] ✅ SOLD! (Favorited fish kept safe)")
        print("╚═══════════════════════════════════╝")
    else
        warn("[Auto Sell] ❌ Sell failed")
        print("╚═══════════════════════════════════╝")
    end
end

task.spawn(function()
    while true do
        task.wait(Config.SellDelay)
        if Config.AutoSell then
            simpleSell()
        end
    end
end)

-- ====================================================================
--                     RAYFIELD UI
-- ====================================================================
    local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

    local Window = Rayfield:CreateWindow({
        Name = "🎣 Yanz Hub Fish It",
        LoadingTitle = "Instant Fishing",
        LoadingSubtitle = "Working Method Implementation",
        ConfigurationSaving = { Enabled = false }
    })
-- ====== MAIN TAB ======
local MainTab = Window:CreateTab("🏠 Main", 4483362458)

MainTab:CreateSection("Auto Fishing")

local BlatantToggle = MainTab:CreateToggle({
    Name = "🔥 BLATANT MODE (3x Faster!)",
    CurrentValue = Config.BlatantMode,
    Callback = function(value)
        Config.BlatantMode = value
        print("[Blatant Mode] " .. (value and "⚡ ENABLED - SUPER FAST!" or "🔴 Disabled - Normal speed"))
        Rayfield:Notify({
    Title = "Auto Fishing",
    Content = "[ Notify ] " .. (value and "⚡ ENABLER - BLATANT MODE!" or "🔴 Disable Blatant Mode"),
    Duration = 5,
    Image = 4483362458
})
        saveConfig()
    end
})

local AutoFishToggle = MainTab:CreateToggle({
    Name = "🎣 NORMAL MODE ( for ping 100-300ms )",
    CurrentValue = Config.AutoFish,
    Callback = function(value)
        Config.AutoFish = value
        fishingActive = value
        
        if value then
            print("[Auto Fish] 🟢 Started " .. (Config.BlatantMode and "(BLATANT MODE)" or "(Normal)"))
            Rayfield:Notify({
    Title = "Auto Fishing",
    Content = "[ Notify ] Normal mode fishing on",
    Duration = 5,
    Image = 4483362458
})
            task.spawn(fishingLoop)
        else
            print("[Auto Fish] 🔴 Stopped")
            Rayfield:Notify({
    Title = "Auto Fishing",
    Content = "[ Notify ] Normal mode fishing off",
    Duration = 5,
    Image = 4483362458
})
            pcall(function() Events.unequip:FireServer() end)
        end
        
        saveConfig()
    end
})
local instant = MainTab:CreateToggle({
    Name = "⚡ Instant Fishing ( for ping 10-50ms )",
    CurrentValue = Config.instantFish,
    Callback = function(value)
        Config.instantFish = value
        fishingActive = value
        
        if value then
            print("[instant Fish] 🟢 Started " .. (Config.BlatantMode and "(BLATANT MODE)" or "(INSTANT)"))
            Rayfield:Notify({
    Title = "Auto Fishing",
    Content = "[ Notify ] Instant Fishing On",
    Duration = 5,
    Image = 4483362458
})
            task.spawn(instantLoop)
        else
            print("[Instant Fish] 🔴 Stopped")
            Rayfield:Notify({
    Title = "Auto Fishing",
    Content = "[ Notify ] Instant Fishing Off",
    Duration = 5,
    Image = 4483362458
    })
            pcall(function() Events.unequip:FireServer() end)
        end
        
        saveConfig()
    end
})
local AutoCatchToggle = MainTab:CreateToggle({
    Name = "🎯 Auto Catch (Extra Speed)",
    CurrentValue = Config.AutoCatch,
    Callback = function(value)
        Config.AutoCatch = value
        print("[Auto Catch] " .. (value and "🟢 Enabled" or "🔴 Disabled"))
        Rayfield:Notify({
    Title = "Auto Fishing",
    Content = "[ Yanz ] " .. (value and "🟢 Enabled!" or "🔴 Disable"),
    Duration = 5,
    Image = 4483362458
})
        saveConfig()
    end
})

MainTab:CreateInput({
    Name = "Fish Delay (seconds)",
    PlaceholderText = "Default: 0.9",
    RemoveTextAfterFocusLost = false,
    Callback = function(value)
        local num = tonumber(value)
        if num and num >= 0.1 and num <= 10 then
            Config.FishDelay = num
            print("[Config] ✅ Fish delay set to " .. num .. "s")
            saveConfig()
        else
            warn("[Config] ❌ Invalid delay (must be 0.1-10)")
        end
    end
})

MainTab:CreateInput({
    Name = "Catch Delay (seconds)",
    PlaceholderText = "Default: 0.2",
    RemoveTextAfterFocusLost = false,
    Callback = function(value)
        local num = tonumber(value)
        if num and num >= 0.1 and num <= 10 then
            Config.CatchDelay = num
            print("[Config] ✅ Catch delay set to " .. num .. "s")
            saveConfig()
        else
            warn("[Config] ❌ Invalid delay (must be 0.1-10)")
        end
    end
})
-- ======================================================
-- DISABLE GAME ANIMATIONS (RAYFIELD SAFE)
-- ======================================================
local stopAnimConnections = {}
local animationDisabled = false

local function disconnectAll()
    for _, conn in ipairs(stopAnimConnections) do
        pcall(function()
            conn:Disconnect()
        end)
    end
    table.clear(stopAnimConnections)
end

local function hookAnimator(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then return end

    -- stop all current animations
    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
        pcall(function()
            track:Stop(0)
        end)
    end

    -- block future animations
    local conn = animator.AnimationPlayed:Connect(function(track)
        task.defer(function()
            if animationDisabled then
                pcall(function()
                    track:Stop(0)
                end)
            end
        end)
    end)

    table.insert(stopAnimConnections, conn)
end

local function setGameAnimationsEnabled(state)
    animationDisabled = state
    disconnectAll()

    if state then
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        hookAnimator(character)

        -- re-hook after respawn
        local respawnConn
        respawnConn = LocalPlayer.CharacterAdded:Connect(function(char)
            if animationDisabled then
                task.wait(1)
                hookAnimator(char)
            else
                respawnConn:Disconnect()
            end
        end)

        table.insert(stopAnimConnections, respawnConn)
    end
end

MainTab:CreateToggle({
    Name = "⛔ Disable Game Animations",
    CurrentValue = false,
    Callback = function(value)
        setGameAnimationsEnabled(value)

        Rayfield:Notify({
            Title = "Animation Control",
            Content = value
                and "⛔ All game animations disabled"
                or "▶ Game animations enabled",
            Duration = 4,
            Image = 4483362458
        })
    end
})

MainTab:CreateSection("Auto Sell")

local AutoSellToggle = MainTab:CreateToggle({
    Name = "💰 Auto Sell (Keeps Favorited)",
    CurrentValue = Config.AutoSell,
    Callback = function(value)
        Config.AutoSell = value
        print("[Auto Sell] " .. (value and "🟢 Enabled" or "🔴 Disabled"))
        saveConfig()
    end
})

MainTab:CreateInput({
    Name = "Sell Delay (seconds)",
    PlaceholderText = "Default: 30",
    RemoveTextAfterFocusLost = false,
    Callback = function(value)
        local num = tonumber(value)
        if num and num >= 10 and num <= 300 then
            Config.SellDelay = num
            print("[Config] ✅ Sell delay set to " .. num .. "s")
            saveConfig()
        else
            warn("[Config] ❌ Invalid delay (must be 10-300)")
        end
    end
})

MainTab:CreateButton({
    Name = "💰 Sell All Now",
    Callback = function()
        simpleSell()
    end
})

-- Misc tab
local MiscTab = Window:CreateTab("📂 Misc", nil)
MiscTab:CreateSection("👤 Players")

local AntiDrown_Enabled = false
local SavedCFrame = nil
-- Hook __namecall (Bypass Oxygen)
local rawmt = getrawmetatable(game)
setreadonly(rawmt, false)
local oldNamecall = rawmt.__namecall

rawmt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()

    if tostring(self) == "URE/UpdateOxygen"
        and method == "FireServer"
        and AntiDrown_Enabled then
        return nil
    end

    return oldNamecall(self, ...)
end)

-- Fungsi tunggu karakter siap
local function waitForCharacter()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

-- Toggle
MiscTab:CreateToggle({
    Name = "🏊 Bypass Oxygen",
    CurrentValue = false,
    Callback = function(value)
        AntiDrown_Enabled = value

        if value then
            -- ON
            Rayfield:Notify({
                Title = "Misc",
                Content = "[ Notify ] Bypass Oxygen On",
                Duration = 5,
                Image = 4483362458
            })
        else
            -- OFF
            local hrp = waitForCharacter()
            SavedCFrame = hrp.CFrame

            Rayfield:Notify({
                Title = "Misc",
                Content = "[ Notify ] Karakter reset, off bypass oxygen",
                Duration = 3,
                Image = 4483362458
            })

            task.delay(3, function()
                -- Reset karakter
                local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.Health = 0
                end

                -- Tunggu spawn ulang
                local newHRP = waitForCharacter()
                task.wait(0.3)

                -- Kembali ke posisi awal
                if SavedCFrame then
                    newHRP.CFrame = SavedCFrame
                end
            end)
        end
    end
})
local InfJumpEnabled = false
local jumpConnection

MiscTab:CreateToggle({
    Name = "👣 Infinite Jump",
    CurrentValue = false,
    Callback = function(value)
        InfJumpEnabled = value

        if value then
            jumpConnection = UserInputService.JumpRequest:Connect(function()
                if InfJumpEnabled and humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)

            Rayfield:Notify({
                Title = "Players",
                Content = "[ Notify ] Infinite Jump Enabled",
                Duration = 5,
                Image = 4483362458
            })
        else
            if jumpConnection then
                jumpConnection:Disconnect()
                jumpConnection = nil
            end

            Rayfield:Notify({
                Title = "Players",
                Content = "[ Notify ] Infinite Jump Disabled",
                Duration = 5,
                Image = 4483362458
            })
        end
    end
})
-- config
Config.WalkSpeed = Config.WalkSpeed or 16

MiscTab:CreateInput({
    Name = "🏃 WalkSpeed (1-100)",
    PlaceholderText = "Default: 16",
    RemoveTextAfterFocusLost = false,
    Callback = function(value)
        local num = tonumber(value)
        if num and num >= 1 and num <= 100 then
            Config.WalkSpeed = num

            if humanoid and humanoid.WalkSpeed ~= defaultWalkSpeed then
                humanoid.WalkSpeed = num
            end

            Rayfield:Notify({
                Title = "Players",
                Content = "[ Notify ] WalkSpeed set to " .. num,
                Duration = 5,
                Image = 4483362458
            })

            saveConfig()
        else
            Rayfield:Notify({
                Title = "Players",
                Content = "[ Error ] WalkSpeed must be 1-100",
                Duration = 5,
                Image = 4483362458
            })
        end
    end
})

local WalkSpeedEnabled = false

MiscTab:CreateToggle({
    Name = "⚡ Enable WalkSpeed",
    CurrentValue = false,
    Callback = function(value)
        WalkSpeedEnabled = value

        if humanoid then
            if value then
                humanoid.WalkSpeed = Config.WalkSpeed or 16

                Rayfield:Notify({
                    Title = "Players",
                    Content = "[ Notify ] WalkSpeed Enabled",
                    Duration = 5,
                    Image = 4483362458
                })
            else
                humanoid.WalkSpeed = defaultWalkSpeed

                Rayfield:Notify({
                    Title = "Players",
                    Content = "[ Notify ] WalkSpeed Reset to Default",
                    Duration = 5,
                    Image = 4483362458
                })
            end
        end
    end
})

-- ======================================================
-- BLACK SCREEN GUI (SAFE FOR RAYFIELD)
-- ======================================================
local BlackScreenGui = Instance.new("ScreenGui")
BlackScreenGui.Name = "YanzBlackScreen"
BlackScreenGui.IgnoreGuiInset = true
BlackScreenGui.ResetOnSpawn = false
BlackScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
BlackScreenGui.Parent = game:GetService("CoreGui") -- PENTING
local BlackFrame = Instance.new("Frame")
BlackFrame.Size = UDim2.new(2, 0, 2, 0) -- LEBIH BESAR DARI LAYAR
BlackFrame.Position = UDim2.new(-0.5, 0, -0.5, 0)
BlackFrame.BackgroundColor3 = Color3.new(0, 0, 0)
BlackFrame.BackgroundTransparency = 0
BlackFrame.Visible = false
BlackFrame.ZIndex = 1
BlackFrame.Parent = BlackScreenGui
local BlackScreenEnabled = false

local function SetBlackScreen(state)
    BlackScreenEnabled = state
    BlackFrame.Visible = state
end
MiscTab:CreateToggle({
    Name = "⬛ Black Screen",
    CurrentValue = false,
    Callback = function(value)
        SetBlackScreen(value)

        Rayfield:Notify({
            Title = "Black Screen",
            Content = value and "⬛ Black Screen Enabled" or "❌ Black Screen Disabled",
            Duration = 4,
            Image = 4483362458
        })
    end
})
-- =========================
-- HIDE NAME (RAYFIELD)
-- =========================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local HiddenObjects = {}
local HideNameEnabled = false

local function hideName(character)
    for _, obj in ipairs(character:GetDescendants()) do
        if obj:IsA("BillboardGui") then
            if obj.Enabled then
                HiddenObjects[obj] = true
                obj.Enabled = false
            end
        elseif obj:IsA("Humanoid") then
            HiddenObjects[obj] = obj.DisplayDistanceType
            obj.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        end
    end
end

local function restoreName()
    for obj, state in pairs(HiddenObjects) do
        if obj and obj.Parent then
            if obj:IsA("BillboardGui") then
                obj.Enabled = true
            elseif obj:IsA("Humanoid") then
                obj.DisplayDistanceType = state
            end
        end
    end
    table.clear(HiddenObjects)
end

local function applyHideName()
    if HideNameEnabled and LocalPlayer.Character then
        hideName(LocalPlayer.Character)
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    task.wait(0.5)
    applyHideName()
end)

-- =========================
-- RAYFIELD TOGGLE
-- =========================
MiscTab:CreateToggle({
    Name = "🙈 Hide Name",
    CurrentValue = false,
    Flag = "HideName",
    Callback = function(value)
        HideNameEnabled = value
        if value then
            applyHideName()
        else
            restoreName()
        end
    end
})
-- =========================
-- UNLIMITED ZOOM (RAYFIELD)
-- =========================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local defaultMinZoom = LocalPlayer.CameraMinZoomDistance
local defaultMaxZoom = LocalPlayer.CameraMaxZoomDistance

local UnlimitedZoomEnabled = false

local function applyZoom()
    if UnlimitedZoomEnabled then
        LocalPlayer.CameraMinZoomDistance = 0.5
        LocalPlayer.CameraMaxZoomDistance = 9999
    else
        LocalPlayer.CameraMinZoomDistance = defaultMinZoom
        LocalPlayer.CameraMaxZoomDistance = defaultMaxZoom
    end
end

-- jaga supaya tidak reset saat respawn
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.3)
    applyZoom()
end)

-- =========================
-- RAYFIELD TOGGLE
-- =========================
MiscTab:CreateToggle({
    Name = "🔭 Unlimited Zoom",
    CurrentValue = false,
    Flag = "UnlimitedZoom",
    Callback = function(value)
        UnlimitedZoomEnabled = value
        applyZoom()
    end
})
local FarmTab = Window:CreateTab("⭐ Auto Event Farm", nil)

FarmTab:CreateSection ("🌠 Event Fish")
-- ======================================================
-- FLOAT PLATFORM + AUTO EVENT FARM (RAYFIELD SAFE)
-- ======================================================

-- ===== SERVICES =====
local Workspace = game:GetService("Workspace")

-- ======================================================
-- FLOAT PLATFORM (WALK ON AIR)
-- ======================================================
local floatPlatform
local floatRunning = false

local function FloatingPlatform(state)
    floatRunning = state

    if not state then
        if floatPlatform then
            floatPlatform:Destroy()
            floatPlatform = nil
        end
        Rayfield:Notify({
            Title = "Float Platform",
            Content = "❌ Disabled",
            Duration = 3,
            Image = 4483362458
        })
        return
    end

    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")

    floatPlatform = Instance.new("Part")
    floatPlatform.Name = "FloatPlatform"
    floatPlatform.Size = Vector3.new(10, 1, 10)
    floatPlatform.Anchored = true
    floatPlatform.CanCollide = true
    floatPlatform.Transparency = 1
    floatPlatform.Parent = Workspace

    task.spawn(function()
        while floatRunning and floatPlatform and hrp and hrp.Parent do
            pcall(function()
                floatPlatform.Position = hrp.Position - Vector3.new(0, 3.5, 0)
            end)
            task.wait(0.1)
        end
    end)

    Rayfield:Notify({
        Title = "Float Platform",
        Content = "✅ Enabled",
        Duration = 3,
        Image = 4483362458
    })
end

MiscTab:CreateToggle({
    Name = "🛸 Float Platform",
    CurrentValue = false,
    Callback = FloatingPlatform
})

-- ======================================================
-- EVENT FARM SYSTEM
-- ======================================================
local eventMap = {
    ["Shark Hunt"]       = { name = "Shark Hunt", part = "Color" },
    ["Ghost Shark Hunt"] = { name = "Ghost Shark Hunt", part = "Part" },
    ["Worm Hunt"]        = { name = "Model", part = "Part" },
    ["Ghost Worm"]       = { name = "Model", part = "Part" },
    ["Megalodon Hunt"]   = { name = "Megalodon Hunt", part = "Color" },
}

local autoEvent = false
local selectedEvent = nil
local savedCFrame = nil
local alreadyTeleported = false
local teleportTime = nil

-- ======================================================
-- EVENT BLOCK (ANTI FALL)
-- ======================================================
local eventBlock

local function ToggleEventBlock(state)
    if not state then
        if eventBlock then
            eventBlock:Destroy()
            eventBlock = nil
        end
        return
    end

    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    eventBlock = Instance.new("Part")
    eventBlock.Size = Vector3.new(6, 1, 6)
    eventBlock.Anchored = true
    eventBlock.CanCollide = true
    eventBlock.Transparency = 1
    eventBlock.Parent = Workspace

    task.spawn(function()
        while autoEvent and eventBlock and hrp and hrp.Parent do
            eventBlock.Position = hrp.Position - Vector3.new(0, 3, 0)
            task.wait(0.2)
        end
    end)
end

-- ======================================================
-- FIND EVENT PART
-- ======================================================
local function getPartRecursive(obj)
    if obj:IsA("BasePart") then return obj end
    for _, v in ipairs(obj:GetChildren()) do
        local p = getPartRecursive(v)
        if p then return p end
    end
end

local function findEvent(eventName)
    local rings = Workspace:FindFirstChild("!!! MENU RINGS")
    if not rings then return end

    local props = rings:FindFirstChild("Props")
    if not props then return end

    local data = eventMap[eventName]
    if not data then return end

    local model = props:FindFirstChild(data.name)
    if not model then return end

    return model:FindFirstChild(data.part or "") or model.PrimaryPart or getPartRecursive(model)
end

-- ======================================================
-- AUTO EVENT LOOP
-- ======================================================
task.spawn(function()
    while true do
        if autoEvent and selectedEvent then
            local targetPart = findEvent(selectedEvent)

            if targetPart and not alreadyTeleported then
                local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                local hrp = char:WaitForChild("HumanoidRootPart")

                savedCFrame = hrp.CFrame
                hrp.CFrame = targetPart.CFrame + Vector3.new(0, 15, 0)

                ToggleEventBlock(true)

                alreadyTeleported = true
                teleportTime = tick()

                Rayfield:Notify({
                    Title = "Event Farm",
                    Content = "Teleported to " .. selectedEvent,
                    Duration = 4,
                    Image = 4483362458
                })

            elseif alreadyTeleported then
                if not targetPart or (tick() - teleportTime >= 900) then
                    if savedCFrame and LocalPlayer.Character then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = savedCFrame
                    end

                    ToggleEventBlock(false)
                    alreadyTeleported = false
                    teleportTime = nil

                    Rayfield:Notify({
                        Title = "Event Farm",
                        Content = "Returned to original position",
                        Duration = 4,
                        Image = 4483362458
                    })
                end
            end
        end
        task.wait(1)
    end
end)

-- ======================================================
-- RAYFIELD UI (EVENT SELECT + TOGGLE)
-- ======================================================
FarmTab:CreateDropdown({
    Name = "Select Event",
    Options = {
        "Shark Hunt",
        "Ghost Shark Hunt",
        "Worm Hunt",
        "Ghost Worm",
        "Megalodon Hunt"
    },
    CurrentOption = "",
    Callback = function(value)
        selectedEvent = value
    end
})

FarmTab:CreateToggle({
    Name = "⭐ Auto Event Farm",
    CurrentValue = false,
    Callback = function(value)
        autoEvent = value
        if not value then
            ToggleEventBlock(false)
        end
    end
})
-- ===============================
-- 🌦️ AUTO BUY WEATHER (RAYFIELD)
-- ===============================

-- =========================
-- REMOTE
-- =========================
local PurchaseWeatherRemote = ReplicatedStorage
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")
    :WaitForChild("RF/PurchaseWeatherEvent")

-- =========================
-- CONFIG
-- =========================
local WEATHER_DURATION = 900 -- 15 menit
local WeatherList = { "Storm", "Cloudy", "Snow", "Wind", "Radiant" }

-- =========================
-- STATE
-- =========================
local SelectedWeather = {}   -- dari dropdown
local WeatherActive = {}    -- yang sedang auto buy
local AutoBuyEnabled = false
local AutoBuyThread = nil

-- =========================
-- HELPER
-- =========================
local function randomDelay(min, max)
    return math.random(min * 100, max * 100) / 100
end

local function stopAllWeather()
    for k in pairs(WeatherActive) do
        WeatherActive[k] = false
    end
end

-- =========================
-- AUTO BUY LOOP
-- =========================
local function startAutoBuy()
    if AutoBuyThread then return end

    AutoBuyThread = task.spawn(function()
        while AutoBuyEnabled do
            for _, weather in ipairs(SelectedWeather) do
                if not AutoBuyEnabled then break end

                WeatherActive[weather] = true

                pcall(function()
                    PurchaseWeatherRemote:InvokeServer(weather)

                    Rayfield:Notify({
                        Title = "Auto Buy Weather",
                        Content = "Activated " .. weather,
                        Duration = 4
                    })
                end)

                task.wait(3) -- anti spam antar weather
            end

            -- tunggu durasi default
            local waitTime = WEATHER_DURATION + randomDelay(1, 5)
            task.wait(waitTime)
        end

        AutoBuyThread = nil
    end)
end

local function stopAutoBuy()
    AutoBuyEnabled = false
    stopAllWeather()
    AutoBuyThread = nil
end

-- =========================
-- UI SECTION
-- =========================
FarmTab:CreateSection("🌦️ Auto Buy Weather")

-- =========================
-- DROPDOWN (SELECT WEATHER)
-- =========================
local WeatherDropdown = FarmTab:CreateDropdown({
    Name = "Select Weather",
    Options = WeatherList,
    CurrentOption = {},
    MultiSelection = true,
    Callback = function(selected)
        SelectedWeather = selected

        if #selected > 0 then
            Rayfield:Notify({
                Title = "Weather Selected",
                Content = table.concat(selected, ", "),
                Duration = 3
            })
        end
    end
})

-- =========================
-- TOGGLE AUTO BUY
-- =========================
FarmTab:CreateToggle({
    Name = "⚡ Auto Buy Weather",
    CurrentValue = false,
    Flag = "AutoBuyWeather",
    Callback = function(value)
        AutoBuyEnabled = value

        if value then
            if #SelectedWeather == 0 then
                Rayfield:Notify({
                    Title = "Auto Buy Weather",
                    Content = "Select at least 1 weather first",
                    Duration = 4
                })
                AutoBuyEnabled = false
                return
            end

            startAutoBuy()

            Rayfield:Notify({
                Title = "Auto Buy Weather",
                Content = "Enabled for: " .. table.concat(SelectedWeather, ", "),
                Duration = 4
            })
        else
            stopAutoBuy()

            Rayfield:Notify({
                Title = "Auto Buy Weather",
                Content = "Disabled",
                Duration = 4
            })
        end
    end
})

-- ===============================
-- INFO
-- ===============================
FarmTab:CreateParagraph({
    Title = "Info",
    Content =
        "• Klik weather = Select\n" ..
        "• Klik lagi = Cancel Select\n" ..
        "• Maksimal 3 Weather\n" ..
        "• Auto Buy mengikuti duration default (15 menit)"
})
-- ====== TELEPORT TAB (from dev1.lua) ======
local TeleportTab = Window:CreateTab("🌍 Teleport", nil)
TeleportTab:CreateSection("📍 Locations")

-- =========================
-- BUILD SORTED LOCATION LIST
-- =========================
local locationNames = {}

for name in pairs(LOCATIONS) do
    table.insert(locationNames, name)
end

table.sort(locationNames)

-- =========================
-- SAFE TELEPORT FUNCTION
-- =========================
local function teleportTo(locationName)
    local cf = LOCATIONS[locationName]
    if not cf then
        Rayfield:Notify({
            Title = "Teleport Failed",
            Content = "Location not found",
            Duration = 4
        })
        return
    end

    local characters = workspace:WaitForChild("Characters", 5)
    if not characters then return end

    local char = characters:FindFirstChild(LocalPlayer.Name)
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
        or char:WaitForChild("HumanoidRootPart", 3)

    if not hrp then return end

    hrp.CFrame = cf + Vector3.new(0, 5, 0)
end

-- =========================
-- RAYFIELD DROPDOWN
-- =========================
TeleportTab:CreateDropdown({
    Name = "Select Island",
    Options = locationNames,
    CurrentOption = nil,
    MultipleOptions = false,

    Callback = function(selected)
        -- Rayfield dropdown return TABLE
        local locationName = selected[1]
        if not locationName then return end

        teleportTo(locationName)

        Rayfield:Notify({
            Title = "Teleport",
            Content = "Teleported to " .. locationName,
            Duration = 4,
            Image = 4483362458
        })
    end
})

-- ===============================
-- COPY POSITION FEATURE
-- ===============================
-- Logic
local function copyPositionXYZ()
    local player = game.Players.LocalPlayer
    local char = player.Character

    if not char then
        return false, "Character not found"
    end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        return false, "HumanoidRootPart not found"
    end

    local pos = hrp.Position

    local text =
        string.format(
            "CFrame.new(%.6f, %.6f, %.6f)",
            pos.X, pos.Y, pos.Z
        )

    if setclipboard then
        setclipboard(text)
        return true, text
    else
        return false, "Clipboard not supported"
    end
end

-- BUTTON
TeleportTab:CreateButton({
    Name = "📋 Copy Position",
    Callback = function()
        local success, result = copyPositionXYZ()

        if success then
            Rayfield:Notify({
                Title = "Copy Position",
                Content = "Copied:\n" .. result,
                Duration = 5,
                Image = 4483362458
            })
        else
            Rayfield:Notify({
                Title = "Copy Position",
                Content = "Error: " .. result,
                Duration = 5,
                Image = 4483362458
            })
        end
    end
})
-- =========================
-- TELEPORT TO PLAYER (USERNAME)
-- =========================

local function getUsernameList()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(list, p.Name) -- USERNAME
        end
    end
    table.sort(list)
    return list
end

local function teleportToPlayer(username)
    local targetPlayer = Players:FindFirstChild(username)
    if not targetPlayer then return end

    local myChar = LocalPlayer.Character
    local targetChar = targetPlayer.Character

    if not myChar or not targetChar then return end

    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")

    if myHRP and targetHRP then
        myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 3)

        Rayfield:Notify({
            Title = "Teleport",
            Content = "Teleported to " .. username,
            Duration = 4
        })
    end
end

local PlayerDropdown

PlayerDropdown = TeleportTab:CreateDropdown({
    Name = "🧍 Teleport To Player",
    Options = getUsernameList(),
    CurrentOption = {},
    Callback = function(selected)
        if typeof(selected) == "table" then
            selected = selected[1]
        end
        if selected then
            teleportToPlayer(selected)
        end
    end
})

local function refreshPlayerDropdown()
    if PlayerDropdown then
        PlayerDropdown:Refresh(getUsernameList())
    end
end

Players.PlayerAdded:Connect(function()
    task.delay(0.3, refreshPlayerDropdown)
end)

Players.PlayerRemoving:Connect(function()
    task.delay(0.3, refreshPlayerDropdown)
end)
-- ====== SETTINGS TAB ======
local SettingsTab = Window:CreateTab("⚙️ Settings", 4483362458)

SettingsTab:CreateSection("Performance")

local GPUToggle = SettingsTab:CreateToggle({
    Name = "🖥️ GPU Saver Mode",
    CurrentValue = Config.GPUSaver,
    Callback = function(value)
        Config.GPUSaver = value
        if value then
            enableGPU()
        else
            disableGPU()
        end
        saveConfig()
    end
})

SettingsTab:CreateSection("Auto Favorite")

local AutoFavoriteToggle = SettingsTab:CreateToggle({
    Name = "⭐ Auto Favorite Fish",
    CurrentValue = Config.AutoFavorite,
    Callback = function(value)
        Config.AutoFavorite = value
        print("[Auto Favorite] " .. (value and "🟢 Enabled" or "🔴 Disabled"))
        saveConfig()
    end
})

local FavoriteRarityDropdown = SettingsTab:CreateDropdown({
    Name = "Favorite Rarity (Mythic/Secret Only)",
    Options = {"Mythic", "Secret"},
    CurrentOption = Config.FavoriteRarity,
    Callback = function(option)
        Config.FavoriteRarity = option
        print("[Config] Favorite rarity set to: " .. option .. "+")
        saveConfig()
    end
})

SettingsTab:CreateButton({
    Name = "⭐ Favorite All Mythic/Secret Now",
    Callback = function()
        autoFavoriteByRarity()
    end
})

-- ====== INFO TAB ======
local InfoTab = Window:CreateTab("ℹ️ Info", 4483362458)

InfoTab:CreateParagraph({
    Title = "Developer info",
    Content = [[
Dev name : yanz (pseudonym)
dev notes : Hello, my name is Yanz, I am a beginner script developer, I have made many scripts but this script is better than the previous script, why? Because I made this script with my friend,This script is the result of a collaboration with my friend
    ]]
})

InfoTab:CreateParagraph({
    Title = "Features",
    Content = [[
• Fast Auto Fishing with BLATANT MODE
• Simple Auto Sell (keeps favorited fish)
• Auto Catch for extra speed
• GPU Saver Mode
• Anti-AFK Protection
• Auto Save Configuration
• Teleport System (dev1.lua method)
• Auto Favorite (Mythic & Secret only)
    ]]
})

InfoTab:CreateParagraph({
    Title = "Blatant Mode Explained",
    Content = [[
⚡ BLATANT MODE METHOD:
- Casts 2 rods in parallel (overlapping)
- Same wait time for fish to bite
- Spams reel 5x to instant catch
- 50% faster cooldown between casts
- Result: ~40% faster fishing!

How it's faster:
✓ Multiple casts = higher catch rate
✓ Spam reeling = instant catch
✓ Reduced cooldown = faster cycles
✗ Same fish delay (fish needs time!)
    ]]
})

-- ====== STARTUP ======
Rayfield:Notify({
    Title = "Yanz Hub Loaded",
    Content = "Instant fishing",
    Duration = 5,
    Image = 4483362458
})