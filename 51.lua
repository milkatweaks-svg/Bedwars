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
local btnCounts = {}
local uiCount = 0
local moduleCount = 0

chat_services.Warn("Loaded Successfully!")

-- // RAYFIELD LIBRARY (chargement)
local Rayfield
pcall(function()
    Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/x7ry/Rayfield/main/source.lua'))()
end)

-- Si Rayfield ne charge pas, utiliser une UI de secours
if not Rayfield then
    chat_services.Warn("Rayfield n'a pas pu être chargé, utilisation de l'UI par défaut")
    -- Code UI original ici (je le mets en commentaire pour éviter la duplication)
    -- Mais on va essayer de recharger Rayfield
    wait(2)
    pcall(function()
        Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/x7ry/Rayfield/main/source.lua'))()
    end)
end

-- // Variables globales
local Enabled = true
local isFlying = nil
local nofallenabled = false
local healthalert = false
local isSprinting = false
local AntivoidEnabled = false
local stealerEnabled = false
_G.Speed1 = false

-- // Fonctions utilitaires
local function safeRequire(path)
    local success, result = pcall(require, path)
    if success then return result end
    return nil
end

local function isalive(player)
    local character = player.Character
    if not character then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    return humanoid.Health > 0
end

function hashFunc(instance) 
    return {value = instance}
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

local function GetInventory(plr)
    if not plr then return {items = {}, armor = {}} end
    local success, result = pcall(function()
        return require(game:GetService("ReplicatedStorage").TS.inventory["inventory-util"]).InventoryUtil.getInventory(plr)
    end)
    if not success then return {items = {}, armor = {}} end
    return result
end

-- // Chargement des modules Bedwars
local lplr = game.Players.LocalPlayer
local cam = game:GetService("Workspace").CurrentCamera
local repstorage = game:GetService("ReplicatedStorage")

local KnitClient = nil
local Client = nil
local KnockbackTable = nil
local bedwars = {}

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

local BedwarsSwords = safeRequire(game:GetService("ReplicatedStorage").TS.games.bedwars["bedwars-swords"])
BedwarsSwords = BedwarsSwords and BedwarsSwords.BedwarsSwords or {}

-- // CRÉATION DU MENU RAYFIELD CARRÉ (seulement si Rayfield est chargé)
if Rayfield then
    local Window = Rayfield:CreateWindow({
        Name = "Moon Menu",
        Icon = 0,
        LoadingTitle = "Moon Menu",
        LoadingSubtitle = "by Milky",
        Theme = "Dark",
        DisableRayfieldPrompts = false,
        DisableBuildWarnings = true,
        ConfigurationSaving = {
           Enabled = true,
           FolderName = "MoonHub",
           FileName = "Config"
        },
        Discord = {
           Enabled = false,
           Invite = "noinvitelink",
           RememberJoins = true
        },
        KeySystem = false,
        KeySettings = {
           Title = "Moon Menu",
           Subtitle = "Key System",
           Note = "No key required",
           FileName = "Key",
           SaveKey = false,
           GrabKeyFromSite = false,
           Key = {"Hello"}
        }
    })

    -- // TAB COMBAT
    local CombatTab = Window:CreateTab("Combat")

    -- Killaura
    local KillauraToggle = CombatTab:CreateToggle({
        Name = "Killaura",
        CurrentValue = false,
        Flag = "Killaura",
        Callback = function(callback)
            if callback then
                Enabled = true
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
            else
                Enabled = false
            end
        end
    })

    -- Velocity
    local VelocityToggle = CombatTab:CreateToggle({
        Name = "Velocity",
        CurrentValue = false,
        Flag = "Velocity",
        Callback = function(callback)
            if callback and KnockbackTable then
                KnockbackTable["kbDirectionStrength"] = 0
                KnockbackTable["kbUpwardStrength"] = 0
            elseif KnockbackTable then
                KnockbackTable["kbDirectionStrength"] = 100
                KnockbackTable["kbUpwardStrength"] = 100
            end
        end
    })

    -- // TAB MOVEMENT
    local MovementTab = Window:CreateTab("Movement")

    -- Speed
    local SpeedToggle = MovementTab:CreateToggle({
        Name = "Speed",
        CurrentValue = false,
        Flag = "Speed",
        Callback = function(callback)
            if callback then
                _G.Speed1 = true
                local You = game.Players.LocalPlayer.Name
                local UIS = game:GetService("UserInputService")
                task.spawn(function()
                    while _G.Speed1 do
                        wait()
                        local hrp = game:GetService("Workspace")[You].HumanoidRootPart
                        local speedValue = speed
                        if UIS:IsKeyDown(Enum.KeyCode.W) then
                            hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, -speedValue)
                        end
                        if UIS:IsKeyDown(Enum.KeyCode.A) then
                            hrp.CFrame = hrp.CFrame * CFrame.new(-speedValue, 0, 0)
                        end
                        if UIS:IsKeyDown(Enum.KeyCode.S) then
                            hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, speedValue)
                        end
                        if UIS:IsKeyDown(Enum.KeyCode.D) then
                            hrp.CFrame = hrp.CFrame * CFrame.new(speedValue, 0, 0)
                        end
                    end
                end)
            else
                _G.Speed1 = false
            end
        end
    })

    -- LongJump
    local LongJumpToggle = MovementTab:CreateToggle({
        Name = "LongJump",
        CurrentValue = false,
        Flag = "LongJump",
        Callback = function(callback)
            if callback then
                local chr = lplr.Character or lplr.CharacterAdded:Wait()
                local hrp = chr:WaitForChild("HumanoidRootPart")
                workspace.Gravity = 0
                local tweenService = game:GetService("TweenService")
                local tween = tweenService:Create(hrp, TweenInfo.new(0.1, Enum.EasingStyle.Bounce), {CFrame = hrp.CFrame + hrp.CFrame.LookVector * 100 + Vector3.new(0, 7, 0)})
                tween:Play()
                task.wait(0.3)
                workspace.Gravity = 196.2
            end
        end
    })

    -- HighJump
    local HighJumpToggle = MovementTab:CreateToggle({
        Name = "HighJump",
        CurrentValue = false,
        Flag = "HighJump",
        Callback = function(callback)
            if callback then
                game.Workspace.Gravity = 0
                lplr.Character.HumanoidRootPart.Velocity = lplr.Character.HumanoidRootPart.Velocity + Vector3.new(0, 150, 0)
            else
                game.Workspace.Gravity = 192.6
            end
        end
    })

    -- Flight
    local FlightToggle = MovementTab:CreateToggle({
        Name = "Flight",
        CurrentValue = false,
        Flag = "Flight",
        Callback = function(callback)
            if callback then
                isFlying = true
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
            end
        end
    })

    -- // TAB VISUALS
    local VisualsTab = Window:CreateTab("Visuals")

    -- Chams
    local ChamsToggle = VisualsTab:CreateToggle({
        Name = "Chams",
        CurrentValue = false,
        Flag = "Chams",
        Callback = function(callback)
            for _, v in pairs(game.Players:GetPlayers()) do
                if v ~= game.Players.LocalPlayer and v.Character then
                    if callback then
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
        end
    })

    -- // TAB UTILITY
    local UtilityTab = Window:CreateTab("Utility")

    -- NoFall
    local NoFallToggle = UtilityTab:CreateToggle({
        Name = "NoFall",
        CurrentValue = false,
        Flag = "NoFall",
        Callback = function(callback)
            if callback then
                nofallenabled = true
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
            else
                nofallenabled = false
            end
        end
    })

    -- Health-Alert
    local HealthAlertToggle = UtilityTab:CreateToggle({
        Name = "Health-Alert",
        CurrentValue = false,
        Flag = "Health-Alert",
        Callback = function(callback)
            if callback then
                healthalert = true
                task.spawn(function()
                    while healthalert do
                        wait()
                        if lplr.Character and lplr.Character.Humanoid and lplr.Character.Humanoid.Health < 45 then
                            chat_services.Warn("Low Health Warning, Your Health is Under 45!")
                            repeat wait() until not healthalert or not lplr.Character or not lplr.Character.Humanoid or lplr.Character.Humanoid.Health > 45
                        end
                    end
                end)
            else
                healthalert = false
            end
        end
    })

    -- Sprint
    local SprintToggle = UtilityTab:CreateToggle({
        Name = "Sprint",
        CurrentValue = false,
        Flag = "Sprint",
        Callback = function(callback)
            if callback then
                isSprinting = true
                task.spawn(function()
                    while isSprinting do
                        wait()
                        if bedwars["SprintController"] and not bedwars["SprintController"].sprinting then
                            pcall(function() bedwars["SprintController"]:startSprinting() end)
                        end
                    end
                end)
            else
                isSprinting = false
            end
        end
    })

    -- AntiVoid
    local AntiVoidToggle = UtilityTab:CreateToggle({
        Name = "AntiVoid",
        CurrentValue = false,
        Flag = "AntiVoid",
        Callback = function(callback)
            if callback then
                AntivoidEnabled = true
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
            else
                AntivoidEnabled = false
            end
        end
    })

    -- Stealer
    local StealerToggle = UtilityTab:CreateToggle({
        Name = "Stealer",
        CurrentValue = false,
        Flag = "Stealer",
        Callback = function(callback)
            if callback then
                stealerEnabled = true
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
            else
                stealerEnabled = false
            end
        end
    })

    -- NoBob
    local NoBobToggle = UtilityTab:CreateToggle({
        Name = "NoBob",
        CurrentValue = false,
        Flag = "NoBob",
        Callback = function(callback)
            if callback then
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
        end
    })

    -- // TAB SCRIPTS
    local ScriptsTab = Window:CreateTab("Scripts")

    -- HypixelFlyV2
    local HypixelFlyV2Toggle = ScriptsTab:CreateToggle({
        Name = "HypixelFlyV2",
        CurrentValue = false,
        Flag = "HypixelFlyV2",
        Callback = function(callback)
            if callback then
                game.Workspace.Gravity = 0
                for i = 1, 12 do
                    wait()
                    lplr.Character.HumanoidRootPart.CFrame = lplr.Character.HumanoidRootPart.CFrame + lplr.Character.HumanoidRootPart.CFrame.LookVector * (i > 6 and 0.1 or 1)
                end
            else
                game.Workspace.Gravity = 192.6
            end
        end
    })

    -- Raccourci RightShift pour ouvrir/fermer Rayfield
    UIS.InputBegan:Connect(function(key)
        if key.KeyCode == Enum.KeyCode.RightShift then
            if Rayfield then
                Rayfield:ToggleVisibility()
            end
        end
    end)

    chat_services.Print("Menu Rayfield chargé avec succès ! Appuyez sur RightShift pour ouvrir/fermer")
else
    -- Fallback : créer un menu simple avec des ScreenGuis si Rayfield ne charge pas
    chat_services.Warn("Impossible de charger Rayfield, création d'un menu de secours...")
    
    -- Fonction pour créer un bouton simple
    local function createFallbackUI()
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "MoonFallbackMenu"
        screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
        screenGui.ResetOnSpawn = false
        
        local mainFrame = Instance.new("Frame")
        mainFrame.Parent = screenGui
        mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        mainFrame.BorderSizePixel = 0
        mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
        mainFrame.Size = UDim2.new(0, 400, 0, 300)
        mainFrame.Visible = false
        
        local title = Instance.new("TextLabel")
        title.Parent = mainFrame
        title.BackgroundColor3 = Color3.fromRGB(177, 0, 162)
        title.BorderSizePixel = 0
        title.Size = UDim2.new(1, 0, 0, 30)
        title.Font = Enum.Font.SourceSansBold
        title.Text = "Moon Menu (Fallback)"
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.TextScaled = true
        
        local closeBtn = Instance.new("TextButton")
        closeBtn.Parent = mainFrame
        closeBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        closeBtn.BorderSizePixel = 0
        closeBtn.Position = UDim2.new(0.9, 0, 0, 0)
        closeBtn.Size = UDim2.new(0, 30, 0, 30)
        closeBtn.Font = Enum.Font.SourceSans
        closeBtn.Text = "X"
        closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeBtn.TextScaled = true
        closeBtn.MouseButton1Click:Connect(function()
            mainFrame.Visible = false
        end)
        
        local infoLabel = Instance.new("TextLabel")
        infoLabel.Parent = mainFrame
        infoLabel.BackgroundTransparency = 1
        infoLabel.Position = UDim2.new(0, 0, 0, 40)
        infoLabel.Size = UDim2.new(1, 0, 0, 50)
        infoLabel.Font = Enum.Font.SourceSans
        infoLabel.Text = "Rayfield n'a pas pu être chargé.\nUtilisez les commandes .IncreaseSpeed etc."
        infoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        infoLabel.TextScaled = true
        infoLabel.TextWrapped = true
        
        UIS.InputBegan:Connect(function(key)
            if key.KeyCode == Enum.KeyCode.RightShift then
                mainFrame.Visible = not mainFrame.Visible
            end
        end)
    end
    
    createFallbackUI()
    chat_services.Print("Menu de secours créé ! Appuyez sur RightShift pour ouvrir/fermer")
end

chat_services.Print("Moon script chargé ! Appuyez sur RightShift pour afficher le menu")