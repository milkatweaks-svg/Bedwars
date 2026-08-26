--[[
     CREDITS
     Xylex - The bedwars table and 1 or 2 functions
     Springs - Some movement modules
     Damc - crappy save system, combat modules and parts of movement modules
     Dawn - parts of aura, also stopped killaura from breaking (the biggest issue)
]]

local speed = 0.1

repeat wait() until game:IsLoaded()

-- Patch pour Delta : fonctions de fichier simulées
if not isfile then
    isfile = function() return false end
    makefolder = function() end
    readfile = function() return "" end
    writefile = function() end
    delfile = function() end
end

-- Patch pour les requêtes HTTP sur Delta
if not request and not http_request and not syn and not syn.request then
    request = function() 
        warn("HTTP Request non supporté sur cet exécuteur")
        return {}
    end
else
    request = request or http_request or syn.request or function() end
end

if not game.Workspace:FindFirstChild("Moon_Instance") then
    local inst = Instance.new("Part",workspace)
    inst.Name = "Moon_Instance"
end

chat_services = {}
chat_services.Print = function(msg)
    game.StarterGui:SetCore( 
        "ChatMakeSystemMessage",  { 
            Text = "[Moon] "..msg, 
            Color = Color3.fromRGB(177, 0, 162), 
            Font = Enum.Font.Arial, 
            FontSize = Enum.FontSize.Size24
        } 
    )
end
chat_services.Warn = function(msg)
    game.StarterGui:SetCore( 
        "ChatMakeSystemMessage",  { 
            Text = "[Moon] "..msg, 
            Color = Color3.fromRGB(255, 204, 0), 
            Font = Enum.Font.Arial, 
            FontSize = Enum.FontSize.Size24
        } 
    )
end

local cmdHandler = {
    [".IncreaseSpeed"] = function()
        chat_services.Print("Increased Speed Multiplier by 0.1!")
        speed = speed + 0.1
    end,
    [".DecreaseSpeed"] = function()
        chat_services.Print("Decreased Speed Multiplier by 0.1!")
        speed = speed - 0.1
    end,
    [".SafeDecreaseSpeed"] = function()
        chat_services.Print("Decreased Speed Multiplier by 0.02!")
        speed = speed - 0.02
    end,
    [".SafeIncreaseSpeed"] = function()
        chat_services.Print("Increased Speed Multiplier by 0.02!")
        speed = speed + 0.02
    end,
}
game.Players.LocalPlayer.Chatted:Connect(function(msg)
    local msg = tostring(msg)
    if cmdHandler[msg] then 
        task.wait(0.5)
        cmdHandler[msg]()
    end
end)

local UIS = game:GetService("UserInputService")

chat_services.Warn("Loaded Successfully!")

-- ===== RAYFIELD MENU =====
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()

local Window = Rayfield:CreateWindow({
    Name = "Moon",
    Icon = 0,
    LoadingTitle = "Moon Script",
    LoadingSubtitle = "by milkatweaks-svg",
    Theme = "Default",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "MoonScript",
        FileName = "Config"
    },
    Discord = {
        Enabled = false,
        Invite = "",
        RememberJoins = true
    },
    KeySystem = false
})

-- Création des onglets
local CombatTab = Window:CreateTab("Combat", 4483362458)
local MovementTab = Window:CreateTab("Movement", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483362458)
local UtilityTab = Window:CreateTab("Utility", 4483362458)
local ScriptsTab = Window:CreateTab("Scripts", 4483362458)

-- ===== Variables globales pour les modules =====
local Enabled = true
local isFlying = false
local nofallenabled = false
local healthalert = false
local isSprinting = false
local AntivoidEnabled = false
local stealerEnabled = false
local flytimer = nil

-- ===== Fonctions partagées =====
local function chat(msg)
    local args = {
        [1] = msg,
        [2] = "All"
    }
    game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(unpack(args))
end

function AddTag(plr, tag, color)
    chat_services.Print("Tag ajouté à "..plr.." : "..tag)
end

local lplr = game.Players.LocalPlayer
local oneTime
local commands = {
    ["kill"] = function()
        lplr.Character.Humanoid.Health = 0
    end,
    ["lagback"] = function()
        lplr.Character.HumanoidRootPart.CFrame = lplr.Character.HumanoidRootPart.CFrame + Vector3.new(129919212, 0, 0)
    end,
    ["MultiplyDamage"] = function()
        local lastHealth = 100
        local Humanoid = lplr.Character.Humanoid
        oneTime = true
        Humanoid.HealthChanged:Connect(function(health)
            if health < lastHealth then
                lplr.Character.Humanoid.Health = lplr.Character.Humanoid.Health - 25
            end
            lastHealth = health
        end)
    end,
    ["freeze"] = function()
        lplr.Character.HumanoidRootPart.Anchored = true
    end,
    ["unfreeze"] = function()
        lplr.Character.HumanoidRootPart.Anchored = false
    end,
    ["ban"] = function()
        task.spawn(function()
            lplr:Kick("You have been temporarily banned. Remaining ban duration: 4960 weeks 2 days 5 hours 19 minutes "..math.random(45, 59).." seconds")
        end)
    end,
    ["crash"] = function()
        while true do
            print("Moon On Top")
        end
    end,
}

local lplr = game.Players.LocalPlayer
local cam = game:GetService("Workspace").CurrentCamera
local uis = game:GetService("UserInputService")

-- Patch pour éviter les erreurs avec les fonctions non disponibles
local function safeRequire(path)
    local success, result = pcall(require, path)
    if success then return result end
    return nil
end

local KnitClient = nil
local Client = nil
local repstorage = game:GetService("ReplicatedStorage")
local KnockbackTable = nil
local bedwars = {}

-- Tentative de chargement sécurisé
pcall(function()
    KnitClient = debug.getupvalue(require(lplr.PlayerScripts.TS.knit).setup, 6)
    Client = require(game:GetService("ReplicatedStorage").TS.remotes).default.Client
    KnockbackTable = debug.getupvalue(require(game:GetService("ReplicatedStorage").TS.damage["knockback-util"]).KnockbackUtil.calculateKnockbackVelocity, 1)

    bedwars = {
        ["SprintController"] = KnitClient and KnitClient.Controllers.SprintController,
        ["ClientHandler"] = Client,
        ["AppController"] = safeRequire(repstorage["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out.client.controllers["app-controller"]) and safeRequire(repstorage["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out.client.controllers["app-controller"]).AppController,
        ["SwordController"] = KnitClient and KnitClient.Controllers.SwordController,
    }
end)

function isalive(player)
    local character = player.Character
    if not character then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    return humanoid.Health > 0
end

local BedwarsSwords = safeRequire(game:GetService("ReplicatedStorage").TS.games.bedwars["bedwars-swords"])
BedwarsSwords = BedwarsSwords and BedwarsSwords.BedwarsSwords or {}

function hashFunc(instance) 
    return {value = instance}
end

local function GetInventory(plr)
    if not plr then return {items = {}, armor = {}} end
    local success, result = pcall(function()
        return require(game:GetService("ReplicatedStorage").TS.inventory["inventory-util"]).InventoryUtil.getInventory(plr)
    end)
    if not success then return {items = {}, armor = {}} end
    return result
end

local function getSword()
    local highestPower = -9e9
    local returningItem = nil
    local inventory = GetInventory(lplr)
    for _, item in pairs(inventory.items or {}) do
        local power = table.find(BedwarsSwords, item.itemType)
        if power and power > highestPower then
            returningItem = item
            highestPower = power
        end
    end
    return returningItem
end

-- ===== CRÉATION DES ÉLÉMENTS DU MENU =====

-- Combat Tab
CombatTab:CreateToggle({
    Name = "Killaura",
    CurrentValue = false,
    Flag = "Killaura",
    Callback = function(Value)
        Enabled = Value
        if Value then
            task.spawn(function()
                while Enabled do
                    for _, v in pairs(game.Players:GetPlayers()) do
                        if v ~= lplr and v.Team ~= lplr.Team and isalive(v) and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                            local dist = (v.Character.HumanoidRootPart.Position - lplr.Character.HumanoidRootPart.Position).Magnitude
                            if dist < 18 then
                                local sword = getSword()
                                if sword and Client and bedwars["SwordRemote"] then
                                    pcall(function()
                                        Client:Get(bedwars["SwordRemote"]):SendToServer({
                                            ["weapon"] = sword.tool,
                                            ["entityInstance"] = v.Character,
                                            ["validate"] = {
                                                ["raycast"] = {
                                                    ["cameraPosition"] = hashFunc(cam.CFrame.Position),
                                                    ["cursorDirection"] = hashFunc(Ray.new(cam.CFrame.Position, v.Character:FindFirstChild("HumanoidRootPart").Position).Unit.Direction)
                                                },
                                                ["targetPosition"] = hashFunc(v.Character:FindFirstChild("HumanoidRootPart").Position),
                                                ["selfPosition"] = hashFunc(lplr.Character:FindFirstChild("HumanoidRootPart").Position)
                                            },
                                            ["chargedAttack"] = {["chargeRatio"] = 0.8}
                                        })
                                    end)
                                end
                            end
                        end
                    end
                    task.wait(0.12)
                end
            end)
        end
    end,
})

CombatTab:CreateToggle({
    Name = "Velocity",
    CurrentValue = false,
    Flag = "Velocity",
    Callback = function(Value)
        if Value and KnockbackTable then
            KnockbackTable["kbDirectionStrength"] = 0
            KnockbackTable["kbUpwardStrength"] = 0
        elseif KnockbackTable then
            KnockbackTable["kbDirectionStrength"] = 100
            KnockbackTable["kbUpwardStrength"] = 100
        end
    end,
})

-- Movement Tab
MovementTab:CreateToggle({
    Name = "Speed",
    CurrentValue = false,
    Flag = "Speed",
    Callback = function(Value)
        if Value then
            local Speed = speed
            _G.Speed1 = true
            local You = game.Players.LocalPlayer.Name
            local UIS = game:GetService("UserInputService")
            task.spawn(function()
                while _G.Speed1 do
                    wait()
                    Speed = speed
                    local hrp = game:GetService("Workspace")[You].HumanoidRootPart
                    if UIS:IsKeyDown(Enum.KeyCode.W) then
                        hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, -Speed)
                    end
                    if UIS:IsKeyDown(Enum.KeyCode.A) then
                        hrp.CFrame = hrp.CFrame * CFrame.new(-Speed, 0, 0)
                    end
                    if UIS:IsKeyDown(Enum.KeyCode.S) then
                        hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, Speed)
                    end
                    if UIS:IsKeyDown(Enum.KeyCode.D) then
                        hrp.CFrame = hrp.CFrame * CFrame.new(Speed, 0, 0)
                    end
                end
            end)
        else
            _G.Speed1 = false
        end
    end,
})

MovementTab:CreateButton({
    Name = "LongJump",
    Callback = function()
        local chr = lplr.Character or lplr.CharacterAdded:Wait()
        local hrp = chr:WaitForChild("HumanoidRootPart")
        workspace.Gravity = 0
        local tweenService = game:GetService("TweenService")
        local tween = tweenService:Create(hrp, TweenInfo.new(0.1, Enum.EasingStyle.Bounce), {CFrame = hrp.CFrame + hrp.CFrame.LookVector * 100 + Vector3.new(0, 7, 0)})
        tween:Play()
        task.wait(0.3)
        workspace.Gravity = 196.2
    end,
})

MovementTab:CreateButton({
    Name = "HighJump",
    Callback = function()
        game.Workspace.Gravity = 0
        lplr.Character.HumanoidRootPart.Velocity = lplr.Character.HumanoidRootPart.Velocity + Vector3.new(0, 150, 0)
        task.wait(0.5)
        game.Workspace.Gravity = 192.6
    end,
})

MovementTab:CreateToggle({
    Name = "Flight",
    CurrentValue = false,
    Flag = "Flight",
    Callback = function(Value)
        if Value then
            isFlying = true
            flytimer = Instance.new("ScreenGui")
            local timer = Instance.new("TextLabel")
            UIS = game:GetService("UserInputService")
            flytimer.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
            timer.Parent = flytimer
            timer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            timer.BackgroundTransparency = 1.000
            timer.Position = UDim2.new(0.499694198, 0, 0.486585349, 0)
            timer.Size = UDim2.new(0, 59, 0, 22)
            timer.Font = Enum.Font.SourceSans
            timer.Text = "Flight"
            timer.TextScaled = true
            timer.TextSize = 14.000
            timer.TextWrapped = true

            task.spawn(function()
                while isFlying do
                    wait(0.1)
                    lplr.Character.HumanoidRootPart.Velocity = Vector3.new(lplr.Character.HumanoidRootPart.Velocity.X, 0, lplr.Character.HumanoidRootPart.Velocity.Z)
                    if UIS:IsKeyDown(Enum.KeyCode.Space) then
                        lplr.Character.HumanoidRootPart.CFrame = lplr.Character.HumanoidRootPart.CFrame + Vector3.new(0, 0.02, 0)
                    elseif UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
                        lplr.Character.HumanoidRootPart.CFrame = lplr.Character.HumanoidRootPart.CFrame - Vector3.new(0, 0.02, 0)
                    end
                end
            end)
        else
            isFlying = false
            if flytimer then flytimer:Destroy() end
        end
    end,
})

-- Visuals Tab
VisualsTab:CreateToggle({
    Name = "Chams",
    CurrentValue = false,
    Flag = "Chams",
    Callback = function(Value)
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= game.Players.LocalPlayer and v.Character then
                if Value then
                    local esp = Instance.new("Highlight")
                    esp.Name = v.Name
                    esp.FillTransparency = 0
                    esp.FillColor = Color3.new(1, 0, 1)
                    esp.OutlineColor = Color3.new(1, 0, 1)
                    esp.OutlineTransparency = 0
                    esp.Parent = v.Character
                else
                    local highlight = v.Character:FindFirstChildOfClass("Highlight")
                    if highlight then highlight:Destroy() end
                end
            end
        end
    end,
})

-- Utility Tab
UtilityTab:CreateToggle({
    Name = "NoFall",
    CurrentValue = false,
    Flag = "NoFall",
    Callback = function(Value)
        nofallenabled = Value
        if Value then
            task.spawn(function()
                while nofallenabled do
                    wait()
                    pcall(function()
                        local groundHit = game:GetService("ReplicatedStorage"):FindFirstChild("rbxts_include")
                        if groundHit then
                            groundHit = groundHit:FindFirstChild("node_modules")
                            if groundHit then
                                groundHit = groundHit:FindFirstChild("@rbxts")
                                if groundHit then
                                    groundHit = groundHit:FindFirstChild("net")
                                    if groundHit then
                                        groundHit = groundHit:FindFirstChild("out")
                                        if groundHit then
                                            groundHit = groundHit:FindFirstChild("_NetManaged")
                                            if groundHit then
                                                groundHit:FireServer()
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end)
                end
            end)
        end
    end,
})

UtilityTab:CreateToggle({
    Name = "Health Alert",
    CurrentValue = false,
    Flag = "HealthAlert",
    Callback = function(Value)
        healthalert = Value
        if Value then
            task.spawn(function()
                while healthalert do
                    wait()
                    if lplr.Character and lplr.Character.Humanoid and lplr.Character.Humanoid.Health < 45 then
                        chat_services.Warn("Low Health Warning, Your Health is Under 45!")
                        repeat wait() until not healthalert or not lplr.Character or not lplr.Character.Humanoid or lplr.Character.Humanoid.Health > 45
                    end
                end
            end)
        end
    end,
})

UtilityTab:CreateToggle({
    Name = "Sprint",
    CurrentValue = false,
    Flag = "Sprint",
    Callback = function(Value)
        isSprinting = Value
        if Value then
            task.spawn(function()
                while isSprinting do
                    wait()
                    if bedwars["SprintController"] and not bedwars["SprintController"].sprinting then
                        pcall(function() bedwars["SprintController"]:startSprinting() end)
                    end
                end
            end)
        end
    end,
})

UtilityTab:CreateToggle({
    Name = "AntiVoid",
    CurrentValue = false,
    Flag = "AntiVoid",
    Callback = function(Value)
        AntivoidEnabled = Value
        if Value then
            task.spawn(function()
                while AntivoidEnabled do
                    wait()
                    if lplr.Character and lplr.Character.HumanoidRootPart and lplr.Character.HumanoidRootPart.Position.Y < 10 then
                        workspace.Gravity = 0
                        local y = Instance.new("BodyVelocity", lplr.Character.HumanoidRootPart)
                        y.Velocity = Vector3.new(0, 100, 0)
                        task.wait(0.16)
                        y:Destroy()
                        workspace.Gravity = 196.2
                    end
                end
            end)
        end
    end,
})

UtilityTab:CreateToggle({
    Name = "Stealer",
    CurrentValue = false,
    Flag = "Stealer",
    Callback = function(Value)
        stealerEnabled = Value
        if Value then
            task.spawn(function()
                while stealerEnabled do
                    wait()
                    if bedwars["AppController"] and pcall(function() return bedwars["AppController"]:isAppOpen("ChestApp") end) then
                        local chest = lplr.Character:FindFirstChild("ObservedChestFolder")
                        if chest and chest.Value then
                            local items = chest.Value:GetChildren()
                            for _, Item in pairs(items) do
                                if Item:IsA("Accessory") then
                                    task.spawn(function()
                                        pcall(function()
                                            if Client then
                                                Client:GetNamespace("Inventory"):Get("ChestGetItem"):CallServer(chest.Value, Item)
                                            end
                                        end)
                                    end)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end,
})

UtilityTab:CreateToggle({
    Name = "NoBob",
    CurrentValue = false,
    Flag = "NoBob",
    Callback = function(Value)
        if Value then
            pcall(function()
                lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_DEPTH_OFFSET", -(30 / 10))
                lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_HORIZONTAL_OFFSET", (8 / 10))
            end)
        else
            pcall(function()
                lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_DEPTH_OFFSET", -(8 / 10))
                lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_HORIZONTAL_OFFSET", (8 / 10))
            end)
        end
    end,
})

-- Scripts Tab
ScriptsTab:CreateButton({
    Name = "Hypixel Fly V2",
    Callback = function()
        game.Workspace.Gravity = 0
        for i = 1, 12 do
            wait()
            lplr.Character.HumanoidRootPart.CFrame = lplr.Character.HumanoidRootPart.CFrame + lplr.Character.HumanoidRootPart.CFrame.LookVector * (i > 6 and 0.1 or 1)
        end
        game.Workspace.Gravity = 192.6
    end,
})

-- Chargement de la configuration
Rayfield:LoadConfiguration()

chat_services.Print("Moon script chargé ! Appuyez sur RightShift pour afficher le menu")