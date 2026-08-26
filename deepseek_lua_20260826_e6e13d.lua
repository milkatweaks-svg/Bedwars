--[[
     MOON BEDWARS – VERSION MOBILE
     Menu visible immédiatement après exécution
]]

repeat wait() until game:IsLoaded()

-- ========== PATCH DELTA ==========
if not isfile then
    isfile = function() return false end
    makefolder = function() end
    readfile = function() return "" end
    writefile = function() end
    delfile = function() end
end

if not request and not http_request and not syn and not syn.request then
    request = function() return {} end
else
    request = request or http_request or syn.request or function() end
end

-- ========== CHAT ==========
chat_services = {}
chat_services.Print = function(msg)
    game.StarterGui:SetCore("ChatMakeSystemMessage", {
        Text = "[Moon] "..msg,
        Color = Color3.fromRGB(177, 0, 162),
        Font = Enum.Font.Arial,
        FontSize = Enum.FontSize.Size24
    })
end
chat_services.Warn = function(msg)
    game.StarterGui:SetCore("ChatMakeSystemMessage", {
        Text = "[Moon] "..msg,
        Color = Color3.fromRGB(255, 204, 0),
        Font = Enum.Font.Arial,
        FontSize = Enum.FontSize.Size24
    })
end

-- ========== VARIABLES ==========
local lplr = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local speed = 0.1
local currentTab = "Combat"
local isMenuOpen = true -- 👈 MENU OUVERT PAR DÉFAUT

-- ========== CRÉATION DU MENU ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = lplr:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Name = "MoonMobile"

-- ========== FOND ==========
local background = Instance.new("Frame")
background.Parent = ScreenGui
background.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
background.BackgroundTransparency = 0.15
background.Size = UDim2.new(0.95, 0, 0.85, 0)
background.Position = UDim2.new(0.025, 0, 0.075, 0)
background.BorderSizePixel = 0
background.Visible = true

-- ========== TITRE ==========
local titleBar = Instance.new("Frame")
titleBar.Parent = background
titleBar.BackgroundColor3 = Color3.fromRGB(180, 0, 230)
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BorderSizePixel = 0

local titleLabel = Instance.new("TextLabel")
titleLabel.Parent = titleBar
titleLabel.BackgroundTransparency = 1
titleLabel.Size = UDim2.new(1, 0, 1, 0)
titleLabel.Text = "☾ MOON BEDWARS ☽"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold

-- ========== BOUTON FERMER ==========
local closeBtn = Instance.new("TextButton")
closeBtn.Parent = titleBar
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
closeBtn.Size = UDim2.new(0, 40, 0, 40)
closeBtn.Position = UDim2.new(1, -45, 0, 3)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextScaled = true
closeBtn.BorderSizePixel = 0
closeBtn.MouseButton1Down:Connect(function()
    background.Visible = false
    isMenuOpen = false
    -- Affiche un petit bouton pour rouvrir
    reopenBtn.Visible = true
end)

-- ========== BOUTON RÉOUVRIR ==========
local reopenBtn = Instance.new("TextButton")
reopenBtn.Parent = ScreenGui
reopenBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 230)
reopenBtn.Size = UDim2.new(0, 70, 0, 70)
reopenBtn.Position = UDim2.new(1, -85, 1, -85)
reopenBtn.Text = "☾"
reopenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
reopenBtn.TextScaled = true
reopenBtn.Font = Enum.Font.GothamBold
reopenBtn.BorderSizePixel = 0
reopenBtn.Visible = false
reopenBtn.MouseButton1Down:Connect(function()
    background.Visible = true
    isMenuOpen = true
    reopenBtn.Visible = false
    updateTabButtons()
    updateVisibleButtons(currentTab)
end)

-- ========== ONGLETS ==========
local tabFrame = Instance.new("Frame")
tabFrame.Parent = background
tabFrame.BackgroundTransparency = 1
tabFrame.Size = UDim2.new(1, 0, 0, 40)
tabFrame.Position = UDim2.new(0, 0, 0, 45)

local tabButtons = {}
local tabContainers = {}
local function createTab(name)
    local btn = Instance.new("TextButton")
    btn.Parent = tabFrame
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    btn.Size = UDim2.new(0.2, 0, 1, 0)
    btn.Position = UDim2.new((#tabButtons) * 0.2, 0, 0, 0)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.BorderSizePixel = 0
    btn.ZIndex = 2

    btn.MouseButton1Down:Connect(function()
        currentTab = name
        updateTabButtons()
        updateVisibleButtons(name)
    end)

    tabButtons[name] = btn

    -- Conteneur pour les boutons de l'onglet
    local container = Instance.new("ScrollingFrame")
    container.Parent = background
    container.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    container.BackgroundTransparency = 0.3
    container.Size = UDim2.new(1, 0, 1, -90)
    container.Position = UDim2.new(0, 0, 0, 88)
    container.CanvasSize = UDim2.new(0, 0, 0, 0)
    container.ScrollBarThickness = 8
    container.Visible = (#tabButtons == 1)
    container.Name = name .. "Container"
    container.ZIndex = 1
    tabContainers[name] = container

    return container
end

function updateTabButtons()
    for name, btn in pairs(tabButtons) do
        btn.BackgroundColor3 = (name == currentTab) and Color3.fromRGB(180, 0, 230) or Color3.fromRGB(50, 50, 60)
    end
end

function updateVisibleButtons(tabName)
    for name, container in pairs(tabContainers) do
        container.Visible = (name == tabName)
    end
end

-- ========== CRÉATION DES ONGLETS ==========
local tabs = {"Combat", "Movement", "Visuals", "Utility", "Scripts"}
for _, name in pairs(tabs) do
    createTab(name)
end
updateTabButtons()
updateVisibleButtons("Combat")

-- ========== WINDOWAPI POUR MOBILE ==========
local btnCounts = {}
for _, name in pairs(tabs) do
    btnCounts[name] = 0
end

local windowapi = {}
windowapi["CreateButton"] = function(tableData)
    local tabName = tableData["Tab"]
    local container = tabContainers[tabName]
    if not container then return end

    btnCounts[tabName] = btnCounts[tabName] + 1
    local btnAPI = {ModuleEnabled = false}
    local bind = "nil"

    local btn = Instance.new("TextButton")
    btn.Parent = container
    btn.BackgroundColor3 = Color3.fromRGB(52, 52, 52)
    btn.Size = UDim2.new(1, -20, 0, 55)
    btn.Position = UDim2.new(0, 10, 0, (btnCounts[tabName] - 1) * 62 + 10)
    btn.Text = tableData["Name"]
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.BorderSizePixel = 0
    btn.ZIndex = 2

    -- Indicateur ON/OFF
    local indicator = Instance.new("Frame")
    indicator.Parent = btn
    indicator.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    indicator.Size = UDim2.new(0, 16, 0, 16)
    indicator.Position = UDim2.new(1, -25, 0.5, -8)
    indicator.BorderSizePixel = 0
    indicator.ZIndex = 3

    local indText = Instance.new("TextLabel")
    indText.Parent = indicator
    indText.BackgroundTransparency = 1
    indText.Size = UDim2.new(1, 0, 1, 0)
    indText.Text = "OFF"
    indText.TextColor3 = Color3.fromRGB(255, 255, 255)
    indText.TextScaled = true
    indText.Font = Enum.Font.SourceSansBold
    indText.ZIndex = 4

    -- État sauvegardé
    local isEnabled = isfile(tableData["Name"]..".txt")
    if isEnabled then
        task.spawn(function()
            btn.BackgroundColor3 = Color3.fromRGB(180, 0, 230)
            btnAPI.ModuleEnabled = true
            indicator.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            indText.Text = "ON"
            tableData["Function"](true)
        end)
    end

    -- Clic pour activer/désactiver
    btn.MouseButton1Down:Connect(function()
        if btnAPI.ModuleEnabled then
            if isEnabled then delfile(tableData["Name"]..".txt") end
            btnAPI.ModuleEnabled = false
            tableData["Function"](false)
            btn.BackgroundColor3 = Color3.fromRGB(52, 52, 52)
            indicator.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            indText.Text = "OFF"
            chat_services.Print(tableData["Name"].." désactivé")
        else
            writefile(tableData["Name"]..".txt", bind)
            btnAPI.ModuleEnabled = true
            tableData["Function"](true)
            btn.BackgroundColor3 = Color3.fromRGB(180, 0, 230)
            indicator.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            indText.Text = "ON"
            chat_services.Print(tableData["Name"].." activé")
        end
    end)

    -- Appui long = bind
    local holding = false
    btn.MouseButton1Down:Connect(function()
        holding = true
        task.spawn(function()
            local t = 0
            while holding and t < 1 do
                task.wait(0.1)
                t = t + 0.1
            end
            if t >= 1 and holding then
                -- Popup bind
                local popup = Instance.new("ScreenGui")
                popup.Parent = lplr.PlayerGui
                local back = Instance.new("Frame")
                back.Parent = popup
                back.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                back.BackgroundTransparency = 0.5
                back.Size = UDim2.new(1, 0, 1, 0)
                local f = Instance.new("Frame")
                f.Parent = popup
                f.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
                f.Position = UDim2.new(0.15, 0, 0.3, 0)
                f.Size = UDim2.new(0.7, 0, 0.3, 0)
                f.BorderSizePixel = 0
                local lbl = Instance.new("TextLabel")
                lbl.Parent = f
                lbl.BackgroundTransparency = 1
                lbl.Size = UDim2.new(1, 0, 0.3, 0)
                lbl.Position = UDim2.new(0, 0, 0.1, 0)
                lbl.Text = "Touche de bind:"
                lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
                lbl.TextScaled = true
                local box = Instance.new("TextBox")
                box.Parent = f
                box.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
                box.Position = UDim2.new(0.1, 0, 0.35, 0)
                box.Size = UDim2.new(0.8, 0, 0.25, 0)
                box.Text = bind
                box.TextColor3 = Color3.fromRGB(255, 255, 255)
                box.TextSize = 20
                local ok = Instance.new("TextButton")
                ok.Parent = f
                ok.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
                ok.Position = UDim2.new(0.1, 0, 0.7, 0)
                ok.Size = UDim2.new(0.35, 0, 0.2, 0)
                ok.Text = "OK"
                ok.TextColor3 = Color3.fromRGB(255, 255, 255)
                ok.TextScaled = true
                ok.BorderSizePixel = 0
                local cancel = Instance.new("TextButton")
                cancel.Parent = f
                cancel.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
                cancel.Position = UDim2.new(0.55, 0, 0.7, 0)
                cancel.Size = UDim2.new(0.35, 0, 0.2, 0)
                cancel.Text = "✕"
                cancel.TextColor3 = Color3.fromRGB(255, 255, 255)
                cancel.TextScaled = true
                cancel.BorderSizePixel = 0
                ok.MouseButton1Down:Connect(function()
                    bind = box.Text ~= "" and box.Text or "nil"
                    chat_services.Print("Bind: "..bind)
                    if isEnabled then
                        delfile("MoonBinds/"..tableData["Name"]..".txt")
                        writefile("MoonBinds/"..tableData["Name"]..".txt", bind)
                    else
                        writefile("MoonBinds/"..tableData["Name"]..".txt", bind)
                    end
                    popup:Destroy()
                end)
                cancel.MouseButton1Down:Connect(function() popup:Destroy() end)
            end
        end)
    end)
    btn.MouseButton1Up:Connect(function() holding = false end)

    -- Mise à jour taille du container
    container.CanvasSize = UDim2.new(0, 0, 0, btnCounts[tabName] * 62 + 20)
end

-- ========== FONCTIONS UTILITAIRES ==========
function isalive(player)
    local character = player.Character
    if not character then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.Health > 0
end

local function chat(msg)
    game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
end

function AddTag(plr, tag, color)
    chat_services.Print("Tag: "..plr.." → "..tag)
end

local commands = {
    kill = function() lplr.Character.Humanoid.Health = 0 end,
    lagback = function() lplr.Character.HumanoidRootPart.CFrame = lplr.Character.HumanoidRootPart.CFrame + Vector3.new(129919212, 0, 0) end,
    freeze = function() lplr.Character.HumanoidRootPart.Anchored = true end,
    unfreeze = function() lplr.Character.HumanoidRootPart.Anchored = false end,
    ban = function() task.spawn(function() lplr:Kick("Banni!") end) end,
    crash = function() while true do print("Moon") end end,
}

-- ========== CHARGEMENT BEDWARS ==========
local KnitClient, Client, repstorage, KnockbackTable, bedwars
local cam = game:GetService("Workspace").CurrentCamera

pcall(function()
    KnitClient = debug.getupvalue(require(lplr.PlayerScripts.TS.knit).setup, 6)
    Client = require(game:GetService("ReplicatedStorage").TS.remotes).default.Client
    repstorage = game:GetService("ReplicatedStorage")
    KnockbackTable = debug.getupvalue(require(repstorage.TS.damage["knockback-util"]).KnockbackUtil.calculateKnockbackVelocity, 1)
    bedwars = {
        SprintController = KnitClient and KnitClient.Controllers.SprintController,
        ClientHandler = Client,
        AppController = pcall(require, repstorage["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out.client.controllers["app-controller"]) and require(repstorage["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out.client.controllers["app-controller"]).AppController,
        SwordController = KnitClient and KnitClient.Controllers.SwordController,
    }
end)

local BedwarsSwords = {}
pcall(function()
    BedwarsSwords = require(game:GetService("ReplicatedStorage").TS.games.bedwars["bedwars-swords"]).BedwarsSwords or {}
end)

function hashFunc(inst) return {value = inst} end

local function GetInventory(plr)
    local success, result = pcall(function()
        return require(game:GetService("ReplicatedStorage").TS.inventory["inventory-util"]).InventoryUtil.getInventory(plr)
    end)
    return success and result or {items = {}}
end

local function getSword()
    local highestPower = -9e9
    local returningItem = nil
    for _, item in pairs(GetInventory(lplr).items or {}) do
        local power = table.find(BedwarsSwords, item.itemType)
        if power and power > highestPower then
            returningItem = item
            highestPower = power
        end
    end
    return returningItem
end

local Enabled = true

-- ========== BOUTONS ==========

-- Combat
windowapi.CreateButton({
    Name = "Killaura",
    Tab = "Combat",
    Function = function(callback)
        if callback then
            repeat
                for _, v in pairs(game.Players:GetPlayers()) do
                    if v ~= lplr and v.Team ~= lplr.Team and isalive(v) and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                        local dist = (v.Character.HumanoidRootPart.Position - lplr.Character.HumanoidRootPart.Position).Magnitude
                        if dist < 18 then
                            local sword = getSword()
                            if sword and Client and bedwars.SwordRemote then
                                pcall(function()
                                    Client:Get(bedwars.SwordRemote):SendToServer({
                                        weapon = sword.tool,
                                        entityInstance = v.Character,
                                        validate = {
                                            raycast = {
                                                cameraPosition = hashFunc(cam.CFrame.Position),
                                                cursorDirection = hashFunc(Ray.new(cam.CFrame.Position, v.Character:FindFirstChild("HumanoidRootPart").Position).Unit.Direction)
                                            },
                                            targetPosition = hashFunc(v.Character:FindFirstChild("HumanoidRootPart").Position),
                                            selfPosition = hashFunc(lplr.Character:FindFirstChild("HumanoidRootPart").Position)
                                        },
                                        chargedAttack = {chargeRatio = 0.8}
                                    })
                                end)
                            end
                        end
                    end
                end
                task.wait(0.12)
            until not Enabled
        else
            Enabled = false
        end
    end
})

windowapi.CreateButton({
    Name = "Velocity",
    Tab = "Combat",
    Function = function(callback)
        if callback and KnockbackTable then
            KnockbackTable.kbDirectionStrength = 0
            KnockbackTable.kbUpwardStrength = 0
        elseif KnockbackTable then
            KnockbackTable.kbDirectionStrength = 100
            KnockbackTable.kbUpwardStrength = 100
        end
    end
})

-- Movement
windowapi.CreateButton({
    Name = "Speed",
    Tab = "Movement",
    Function = function(callback)
        if callback then
            _G.Speed1 = true
            while _G.Speed1 do
                wait()
                local hrp = lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    if UIS:IsKeyDown(Enum.KeyCode.W) then hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, -speed) end
                    if UIS:IsKeyDown(Enum.KeyCode.A) then hrp.CFrame = hrp.CFrame * CFrame.new(-speed, 0, 0) end
                    if UIS:IsKeyDown(Enum.KeyCode.S) then hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, speed) end
                    if UIS:IsKeyDown(Enum.KeyCode.D) then hrp.CFrame = hrp.CFrame * CFrame.new(speed, 0, 0) end
                end
            end
        else
            _G.Speed1 = false
        end
    end
})

windowapi.CreateButton({
    Name = "LongJump",
    Tab = "Movement",
    Function = function(callback)
        if callback then
            local hrp = lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                workspace.Gravity = 0
                local tween = game:GetService("TweenService"):Create(hrp, TweenInfo.new(0.1, Enum.EasingStyle.Bounce), {CFrame = hrp.CFrame + hrp.CFrame.LookVector * 100 + Vector3.new(0, 7, 0)})
                tween:Play()
                task.wait(0.3)
                workspace.Gravity = 196.2
            end
        else
            workspace.Gravity = 196.2
        end
    end
})

windowapi.CreateButton({
    Name = "HighJump",
    Tab = "Movement",
    Function = function(callback)
        if callback then
            workspace.Gravity = 0
            local hrp = lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.Velocity = hrp.Velocity + Vector3.new(0, 150, 0) end
        else
            workspace.Gravity = 192.6
        end
    end
})

local isFlying = false
windowapi.CreateButton({
    Name = "Flight",
    Tab = "Movement",
    Function = function(callback)
        if callback then
            isFlying = true
            repeat
                wait(0.1)
                local hrp = lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
                    if UIS:IsKeyDown(Enum.KeyCode.Space) then
                        hrp.CFrame = hrp.CFrame + Vector3.new(0, 0.03, 0)
                    elseif UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
                        hrp.CFrame = hrp.CFrame - Vector3.new(0, 0.03, 0)
                    end
                end
            until not isFlying
        else
            isFlying = false
        end
    end
})

-- Visuals
windowapi.CreateButton({
    Name = "Chams",
    Tab = "Visuals",
    Function = function(callback)
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= lplr and v.Character then
                if callback then
                    local h = Instance.new("Highlight")
                    h.Name = v.Name
                    h.FillTransparency = 0
                    h.FillColor = Color3.new(1, 0, 1)
                    h.OutlineColor = Color3.new(1, 0, 1)
                    h.OutlineTransparency = 0
                    h.Parent = v.Character
                else
                    local h = v.Character:FindFirstChildOfClass("Highlight")
                    if h then h:Destroy() end
                end
            end
        end
    end
})

-- Utility
windowapi.CreateButton({
    Name = "NoFall",
    Tab = "Utility",
    Function = function(callback)
        if callback then
            _G.NoFallEnabled = true
            repeat
                wait()
                pcall(function()
                    local ground = game:GetService("ReplicatedStorage"):FindFirstChild("rbxts_include")
                    if ground then
                        ground = ground:FindFirstChild("node_modules")
                        if ground then
                            ground = ground:FindFirstChild("@rbxts")
                            if ground then
                                ground = ground:FindFirstChild("net")
                                if ground then
                                    ground = ground:FindFirstChild("out")
                                    if ground then
                                        ground = ground:FindFirstChild("_NetManaged")
                                        if ground then ground:FireServer() end
                                    end
                                end
                            end
                        end
                    end
                end)
            until not _G.NoFallEnabled
        else
            _G.NoFallEnabled = false
        end
    end
})

windowapi.CreateButton({
    Name = "HealthAlert",
    Tab = "Utility",
    Function = function(callback)
        if callback then
            _G.HealthAlert = true
            repeat
                wait()
                if lplr.Character and lplr.Character.Humanoid and lplr.Character.Humanoid.Health < 45 then
                    chat_services.Warn("⚠️ Santé basse! "..math.floor(lplr.Character.Humanoid.Health))
                    repeat wait() until not lplr.Character or not lplr.Character.Humanoid or lplr.Character.Humanoid.Health > 45
                end
            until not _G.HealthAlert
        else
            _G.HealthAlert = false
        end
    end
})

windowapi.CreateButton({
    Name = "Sprint",
    Tab = "Utility",
    Function = function(callback)
        if callback then
            _G.SprintEnabled = true
            repeat
                wait()
                if bedwars and bedwars.SprintController and not bedwars.SprintController.sprinting then
                    pcall(function() bedwars.SprintController:startSprinting() end)
                end
            until not _G.SprintEnabled
        else
            _G.SprintEnabled = false
        end
    end
})

windowapi.CreateButton({
    Name = "AntiVoid",
    Tab = "Utility",
    Function = function(callback)
        if callback then
            _G.AntiVoid = true
            repeat
                wait()
                if lplr.Character and lplr.Character.HumanoidRootPart and lplr.Character.HumanoidRootPart.Position.Y < 10 then
                    workspace.Gravity = 0
                    local bv = Instance.new("BodyVelocity", lplr.Character.HumanoidRootPart)
                    bv.Velocity = Vector3.new(0, 100, 0)
                    task.wait(0.16)
                    bv:Destroy()
                    workspace.Gravity = 196.2
                end
            until not _G.AntiVoid
        else
            _G.AntiVoid = false
        end
    end
})

windowapi.CreateButton({
    Name = "Stealer",
    Tab = "Utility",
    Function = function(callback)
        if callback then
            _G.Stealer = true
            repeat
                wait()
                if bedwars and bedwars.AppController and pcall(function() return bedwars.AppController:isAppOpen("ChestApp") end) then
                    local chest = lplr.Character:FindFirstChild("ObservedChestFolder")
                    if chest and chest.Value then
                        for _, item in pairs(chest.Value:GetChildren()) do
                            if item:IsA("Accessory") then
                                task.spawn(function()
                                    pcall(function()
                                        if Client then
                                            Client:GetNamespace("Inventory"):Get("ChestGetItem"):CallServer(chest.Value, item)
                                        end
                                    end)
                                end)
                            end
                        end
                    end
                end
            until not _G.Stealer
        else
            _G.Stealer = false
        end
    end
})

windowapi.CreateButton({
    Name = "NoBob",
    Tab = "Utility",
    Function = function(callback)
        pcall(function()
            local vm = lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]
            if callback then
                vm:SetAttribute("ConstantManager_DEPTH_OFFSET", -3)
                vm:SetAttribute("ConstantManager_HORIZONTAL_OFFSET", 0.8)
            else
                vm:SetAttribute("ConstantManager_DEPTH_OFFSET", -0.8)
                vm:SetAttribute("ConstantManager_HORIZONTAL_OFFSET", 0.8)
            end
        end)
    end
})

-- Scripts
windowapi.CreateButton({
    Name = "HypixelFly",
    Tab = "Scripts",
    Function = function(callback)
        if callback then
            workspace.Gravity = 0
            for i = 1, 12 do
                wait()
                local hrp = lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = hrp.CFrame + hrp.CFrame.LookVector * (i > 6 and 0.1 or 1)
                end
            end
        else
            workspace.Gravity = 192.6
        end
    end
})

-- ========== MESSAGE FINAL ==========
chat_services.Print("✅ Moon Mobile chargé ! Menu visible à l'écran.")