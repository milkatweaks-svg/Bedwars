--[[
     CREDITS
     Xylex - The bedwars table and 1 or 2 functions
     Springs - Some movement modules
     Damc - crappy save system, combat modules and parts of movement modules
     Dawn - parts of aura, also stopped killaura from breaking (the biggest issue)
     ADAPTATION MOBILE : Réorganisation de l'UI pour écrans tactiles
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
local isMenuOpen = false

chat_services.Warn("Loaded Successfully! Appuyez sur le bouton MENU en bas à droite")

-- VARIABLES POUR LE MENU MOBILE
local menuButton = nil
local mainFrame = nil
local scrollFrame = nil
local tabButtons = {}
local currentTab = "Combat"

-- FONCTION POUR CRÉER UN ONGLET (VERSION MOBILE)
function newTab(name)
    uiCount = uiCount + 1
    btnCounts[name] = 0
    
    -- CRÉER LE FRAME PRINCIPAL (CACHÉ PAR DÉFAUT)
    if not mainFrame then
        mainFrame = Instance.new("Frame")
        mainFrame.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
        mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        mainFrame.BorderSizePixel = 0
        mainFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
        mainFrame.Size = UDim2.new(0.9, 0, 0.8, 0)
        mainFrame.BackgroundTransparency = 0.1
        mainFrame.Visible = false
        mainFrame.ZIndex = 10
        
        -- BOUTON FERMER
        local closeBtn = Instance.new("TextButton")
        closeBtn.Parent = mainFrame
        closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        closeBtn.Size = UDim2.new(0, 40, 0, 40)
        closeBtn.Position = UDim2.new(1, -45, 0, 5)
        closeBtn.Text = "✕"
        closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeBtn.TextScaled = true
        closeBtn.ZIndex = 11
        closeBtn.MouseButton1Down:Connect(function()
            mainFrame.Visible = false
            isMenuOpen = false
            if menuButton then menuButton.Visible = true end
        end)
        
        -- ZONE DE DÉFILEMENT POUR LES ONGLETS
        scrollFrame = Instance.new("ScrollingFrame")
        scrollFrame.Parent = mainFrame
        scrollFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        scrollFrame.BackgroundTransparency = 0.3
        scrollFrame.Position = UDim2.new(0, 0, 0.1, 0)
        scrollFrame.Size = UDim2.new(1, 0, 0.85, 0)
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        scrollFrame.ScrollBarThickness = 8
        scrollFrame.ZIndex = 10
        
        -- BARRE DE TITRE
        local titleBar = Instance.new("Frame")
        titleBar.Parent = mainFrame
        titleBar.BackgroundColor3 = Color3.fromRGB(200, 0, 255)
        titleBar.Size = UDim2.new(1, 0, 0, 40)
        titleBar.Position = UDim2.new(0, 0, 0, 0)
        titleBar.ZIndex = 11
        
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Parent = titleBar
        titleLabel.BackgroundTransparency = 1
        titleLabel.Size = UDim2.new(1, 0, 1, 0)
        titleLabel.Text = "☾ MOON BEDWARS ☽"
        titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        titleLabel.TextScaled = true
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.ZIndex = 11
        
        -- CRÉER LE BOUTON MENU (en bas à droite)
        menuButton = Instance.new("TextButton")
        menuButton.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
        menuButton.BackgroundColor3 = Color3.fromRGB(200, 0, 255)
        menuButton.Size = UDim2.new(0, 70, 0, 70)
        menuButton.Position = UDim2.new(1, -85, 1, -85)
        menuButton.Text = "☾"
        menuButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        menuButton.TextScaled = true
        menuButton.Font = Enum.Font.GothamBold
        menuButton.ZIndex = 20
        menuButton.BorderSizePixel = 0
        
        -- AJOUTER UNE OMBRE AU BOUTON
        local shadow = Instance.new("Frame")
        shadow.Parent = menuButton
        shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        shadow.BackgroundTransparency = 0.3
        shadow.Size = UDim2.new(1.2, 0, 1.2, 0)
        shadow.Position = UDim2.new(-0.1, 0, -0.1, 0)
        shadow.ZIndex = -1
        
        menuButton.MouseButton1Down:Connect(function()
            if isMenuOpen then
                mainFrame.Visible = false
                isMenuOpen = false
            else
                mainFrame.Visible = true
                isMenuOpen = true
                menuButton.Visible = false
                -- Mettre à jour l'onglet actif
                updateTabButtons()
            end
        end)
    end
    
    -- CRÉER LES BOUTONS D'ONGLETS EN HAUT
    local tabBtn = Instance.new("TextButton")
    tabBtn.Parent = mainFrame
    tabBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    tabBtn.Size = UDim2.new(0.2, 0, 0, 35)
    tabBtn.Position = UDim2.new((uiCount - 1) * 0.2, 0, 0.05, 0)
    tabBtn.Text = name
    tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    tabBtn.TextScaled = true
    tabBtn.ZIndex = 11
    tabBtn.BorderSizePixel = 0
    
    tabBtn.MouseButton1Down:Connect(function()
        currentTab = name
        updateTabButtons()
        updateVisibleButtons(name)
    end)
    
    tabButtons[name] = tabBtn
    
    -- CRÉER LE CONTENEUR POUR LES BOUTONS DE CET ONGLET
    local container = Instance.new("Frame")
    container.Parent = scrollFrame
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, 0, 0, 0)
    container.Position = UDim2.new(0, 0, 0, 0)
    container.Name = name .. "Container"
    container.Visible = (uiCount == 1)
    
    -- METTRE À JOUR LA TAILLE DU SCROLL
    local function updateScrollSize()
        local totalHeight = 0
        for _, child in pairs(scrollFrame:GetChildren()) do
            if child:IsA("Frame") and child.Name:match("Container$") then
                totalHeight = totalHeight + child.Size.Y.Offset
            end
        end
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight + 50)
    end
    container.Changed:Connect(function(prop)
        if prop == "Size" then
            updateScrollSize()
        end
    end)
    
    -- STOCKER LE CONTENEUR
    btnCounts[name .. "_container"] = container
end

-- FONCTION POUR METTRE À JOUR L'AFFICHAGE DES BOUTONS D'ONGLETS
function updateTabButtons()
    for name, btn in pairs(tabButtons) do
        if name == currentTab then
            btn.BackgroundColor3 = Color3.fromRGB(200, 0, 255)
        else
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        end
    end
end

-- FONCTION POUR AFFICHER UNIQUEMENT L'ONGLET SÉLECTIONNÉ
function updateVisibleButtons(tabName)
    for _, child in pairs(scrollFrame:GetChildren()) do
        if child:IsA("Frame") and child.Name:match("Container$") then
            child.Visible = (child.Name == tabName .. "Container")
        end
    end
end

-- WINDOWAPI POUR MOBILE
local windowapi = {}

windowapi["CreateButton"] = function(tableData)
    btnCounts[tableData["Tab"]] = btnCounts[tableData["Tab"]] + 1
    local btnAPI = {}

    local player = game.Players.LocalPlayer
    local bind = "nil"
    btnAPI["ModuleEnabled"] = false
    
    -- RÉCUPÉRER LE CONTENEUR DE L'ONGLET
    local container = btnCounts[tableData["Tab"] .. "_container"]
    if not container then return end
    
    -- CRÉER LE BOUTON (VERSION MOBILE)
    local TextButton = Instance.new("TextButton")
    TextButton.Parent = container
    TextButton.BackgroundColor3 = Color3.fromRGB(52, 52, 52)
    TextButton.BackgroundTransparency = 0
    TextButton.Size = UDim2.new(1, -20, 0, 55)
    TextButton.Position = UDim2.new(0, 10, 0, (btnCounts[tableData["Tab"]] - 1) * 60 + 10)
    TextButton.Font = Enum.Font.SourceSans
    TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextButton.TextScaled = true
    TextButton.TextSize = 14.000
    TextButton.TextWrapped = true
    TextButton.Text = tableData["Name"]
    TextButton.BorderSizePixel = 0
    TextButton.ZIndex = 10
    
    -- AJOUTER UNE PETITE INDICATEUR DE STATUT
    local statusIndicator = Instance.new("Frame")
    statusIndicator.Parent = TextButton
    statusIndicator.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    statusIndicator.Size = UDim2.new(0, 15, 0, 15)
    statusIndicator.Position = UDim2.new(1, -25, 0.5, -7)
    statusIndicator.BorderSizePixel = 0
    statusIndicator.ZIndex = 11
    
    local statusText = Instance.new("TextLabel")
    statusText.Parent = statusIndicator
    statusText.BackgroundTransparency = 1
    statusText.Size = UDim2.new(1, 0, 1, 0)
    statusText.Text = "OFF"
    statusText.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusText.TextScaled = true
    statusText.Font = Enum.Font.SourceSansBold
    statusText.ZIndex = 12
    
    -- METTRE À JOUR LA TAILLE DU CONTENEUR
    container.Size = UDim2.new(1, 0, 0, btnCounts[tableData["Tab"]] * 60 + 20)
    
    local isEnabled = isfile(tableData["Name"]..".txt")
    if isEnabled then
        local function resume()
            TextButton.BackgroundColor3 = Color3.fromRGB(200, 0, 255)
            btnAPI['ModuleEnabled'] = true
            statusIndicator.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            statusText.Text = "ON"
            tableData["Function"](true)
        end
        if tableData["Name"] ~= "Flight" then
            coroutine.wrap(resume)()
        end
    end

    -- CLICK POUR ACTIVER/DÉSACTIVER (MOBILE)
    TextButton.MouseButton1Down:Connect(function()
        if btnAPI['ModuleEnabled'] then
            if isEnabled then
                delfile(tableData["Name"]..".txt")
            end
            chat_services.Print(tableData["Name"].." has been disabled!")
            btnAPI['ModuleEnabled'] = false
            tableData["Function"](false)
            TextButton.BackgroundColor3 = Color3.fromRGB(52, 52, 52)
            statusIndicator.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            statusText.Text = "OFF"
        else
            chat_services.Print(tableData["Name"].." has been enabled!")
            writefile(tableData["Name"]..".txt", bind)
            TextButton.BackgroundColor3 = Color3.fromRGB(200, 0, 255)
            btnAPI['ModuleEnabled'] = true
            tableData["Function"](true)
            statusIndicator.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            statusText.Text = "ON"
        end
    end)

    -- CLICK DROIT POUR LE BIND (APPUI LONG SUR MOBILE)
    local holdTime = 0
    local holding = false
    
    TextButton.MouseButton1Down:Connect(function()
        holding = true
        holdTime = 0
        task.spawn(function()
            while holding and holdTime < 1 do
                task.wait(0.1)
                holdTime = holdTime + 0.1
            end
            if holdTime >= 1 and holding then
                -- OUVRIRE LE BIND
                local ui = Instance.new("ScreenGui")
                ui.Parent = game.Players.LocalPlayer.PlayerGui
                ui.ZIndex = 100
                
                local back = Instance.new("Frame")
                back.Parent = ui
                back.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                back.BackgroundTransparency = 0.5
                back.Size = UDim2.new(1, 0, 1, 0)
                back.ZIndex = 100
                
                local popup = Instance.new("Frame")
                popup.Parent = ui
                popup.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                popup.Position = UDim2.new(0.2, 0, 0.3, 0)
                popup.Size = UDim2.new(0.6, 0, 0.3, 0)
                popup.ZIndex = 101
                popup.BorderSizePixel = 0
                
                local label = Instance.new("TextLabel")
                label.Parent = popup
                label.BackgroundTransparency = 1
                label.Size = UDim2.new(1, 0, 0.3, 0)
                label.Position = UDim2.new(0, 0, 0.1, 0)
                label.Text = "Entrez la touche de bind:"
                label.TextColor3 = Color3.fromRGB(255, 255, 255)
                label.TextScaled = true
                label.Font = Enum.Font.Gotham
                label.ZIndex = 102
                
                local TextBox = Instance.new("TextBox")
                TextBox.Parent = popup
                TextBox.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
                TextBox.Position = UDim2.new(0.1, 0, 0.4, 0)
                TextBox.Size = UDim2.new(0.8, 0, 0.25, 0)
                TextBox.Font = Enum.Font.SourceSans
                TextBox.Text = bind
                TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                TextBox.TextSize = 20
                TextBox.ZIndex = 102
                
                local confirmBtn = Instance.new("TextButton")
                confirmBtn.Parent = popup
                confirmBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
                confirmBtn.Position = UDim2.new(0.1, 0, 0.7, 0)
                confirmBtn.Size = UDim2.new(0.35, 0, 0.2, 0)
                confirmBtn.Text = "OK"
                confirmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                confirmBtn.TextScaled = true
                confirmBtn.ZIndex = 102
                confirmBtn.BorderSizePixel = 0
                
                local cancelBtn = Instance.new("TextButton")
                cancelBtn.Parent = popup
                cancelBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
                cancelBtn.Position = UDim2.new(0.55, 0, 0.7, 0)
                cancelBtn.Size = UDim2.new(0.35, 0, 0.2, 0)
                cancelBtn.Text = "ANNULER"
                cancelBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                cancelBtn.TextScaled = true
                cancelBtn.ZIndex = 102
                cancelBtn.BorderSizePixel = 0
                
                confirmBtn.MouseButton1Down:Connect(function()
                    bind = TextBox.Text ~= "" and TextBox.Text or "nil"
                    chat_services.Print(tableData["Name"].." has been bound to key "..bind)
                    ui:Destroy()
                    if isEnabled then
                        delfile("MoonBinds/"..tableData["Name"]..".txt")
                        writefile("MoonBinds/"..tableData["Name"]..".txt", bind)
                    else
                        writefile("MoonBinds/"..tableData["Name"]..".txt", bind)
                    end
                end)
                
                cancelBtn.MouseButton1Down:Connect(function()
                    ui:Destroy()
                end)
            end
        end)
    end)
    
    TextButton.MouseButton1Up:Connect(function()
        holding = false
    end)

    -- SURVOL POUR MOBILE (HOVER = TOUCHE MAINTAIN)
    TextButton.MouseEnter:Connect(function()
        if btnAPI["ModuleEnabled"] then
            TextButton.BackgroundColor3 = Color3.fromRGB(167, 1, 182)
        else
            TextButton.BackgroundColor3 = Color3.fromRGB(47, 47, 47)
        end
    end)
    TextButton.MouseLeave:Connect(function()
        if btnAPI["ModuleEnabled"] then
            TextButton.BackgroundColor3 = Color3.fromRGB(200, 0, 255)
        else
            TextButton.BackgroundColor3 = Color3.fromRGB(52, 52, 52)
        end
    end)
end

-- FONCTIONS DE BASE
local function chat(msg)
    local args = {[1] = msg, [2] = "All"}
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

local cam = game:GetService("Workspace").CurrentCamera
local uis = game:GetService("UserInputService")

-- PATCH POUR LES FONCTIONS NON DISPONIBLES
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

local Enabled = true

-- CRÉATION DES ONGLETS
newTab("Combat")
newTab("Movement")
newTab("Visuals")
newTab("Utility")
newTab("Scripts")

-- BOUTONS COMBAT
local Killaura = windowapi.CreateButton({
    ["Name"] = "Killaura",
    ["Tab"] = "Combat",
    ["Function"] = function(callback)
        if callback then
            repeat
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
            until not Enabled
        else
            Enabled = false
        end
    end,
})

local Velocity = windowapi.CreateButton({
    ["Name"] = "Velocity",
    ["Tab"] = "Combat",
    ["Function"] = function(callback)
        if callback and KnockbackTable then
            KnockbackTable["kbDirectionStrength"] = 0
            KnockbackTable["kbUpwardStrength"] = 0
        elseif KnockbackTable then
            KnockbackTable["kbDirectionStrength"] = 100
            KnockbackTable["kbUpwardStrength"] = 100
        end
    end,
})

-- BOUTONS MOVEMENT
local CFrameSpeed = windowapi.CreateButton({
    ["Name"] = "Speed",
    ["Tab"] = "Movement",
    ["Function"] = function(callback)
        if callback then
            local Speed = speed
            _G.Speed1 = true
            local You = game.Players.LocalPlayer.Name
            local UIS = game:GetService("UserInputService")
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
        else
            _G.Speed1 = false
        end
    end,
})

local LongJump = windowapi.CreateButton({
    ["Name"] = "LongJump",
    ["Tab"] = "Movement",
    ["Function"] = function(callback)
        if callback then
            local chr = lplr.Character or lplr.CharacterAdded:Wait()
            local hrp = chr:WaitForChild("HumanoidRootPart")
            workspace.Gravity = 0
            local tweenService = game:GetService("TweenService")
            local tween = tweenService:Create(hrp, TweenInfo.new(0.1, Enum.EasingStyle.Bounce), {CFrame = hrp.CFrame + hrp.CFrame.LookVector * 100 + Vector3.new(0, 7, 0)})
            tween:Play()
            task.wait(0.3)
            workspace.Gravity = 196.2
        else
            workspace.Gravity = 196.2
        end
    end,
})

local HighJump = windowapi.CreateButton({
    ["Name"] = "HighJump",
    ["Tab"] = "Movement",
    ["Function"] = function(callback)
        if callback then
            game.Workspace.Gravity = 0
            lplr.Character.HumanoidRootPart.Velocity = lplr.Character.HumanoidRootPart.Velocity + Vector3.new(0, 150, 0)
        else
            game.Workspace.Gravity = 192.6
        end
    end,
})

local isFlying = nil
Flight = windowapi.CreateButton({
    ["Name"] = "Flight",
    ["Tab"] = "Movement",
    ["Function"] = function(callback)
        if callback then
            isFlying = true
            UIS = game:GetService("UserInputService")
            repeat 
                wait(0.1)
                lplr.Character.HumanoidRootPart.Velocity = Vector3.new(lplr.Character.HumanoidRootPart.Velocity.X, 0, lplr.Character.HumanoidRootPart.Velocity.Z)
                if UIS:IsKeyDown(Enum.KeyCode.Space) then
                    lplr.Character.HumanoidRootPart.CFrame = lplr.Character.HumanoidRootPart.CFrame + Vector3.new(0, 0.02, 0)
                elseif UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
                    lplr.Character.HumanoidRootPart.CFrame = lplr.Character.HumanoidRootPart.CFrame - Vector3.new(0, 0.02, 0)
                end
            until not isFlying
        else
            isFlying = false
        end
    end,
})

-- BOUTONS VISUALS
local Chams = windowapi.CreateButton({
    ["Name"] = "Chams",
    ["Tab"] = "Visuals",
    ["Function"] = function(callback)
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
    end,
})

-- BOUTONS UTILITY
local NoFall = windowapi.CreateButton({
    ["Name"] = "NoFall",
    ["Tab"] = "Utility",
    ["Function"] = function(callback)
        if callback then
            nofallenabled = true
            repeat 
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
            until not nofallenabled
        else
            nofallenabled = false
        end
    end,
})

local HealthAlert = windowapi.CreateButton({
    ["Name"] = "HealthAlert",
    ["Tab"] = "Utility",
    ["Function"] = function(callback)
        if callback then
            healthalert = true
            repeat 
                wait()
                if lplr.Character and lplr.Character.Humanoid and lplr.Character.Humanoid.Health < 45 then
                    chat_services.Warn("⚠️ Low Health Warning! Health: "..math.floor(lplr.Character.Humanoid.Health))
                    repeat wait() until not lplr.Character or not lplr.Character.Humanoid or lplr.Character.Humanoid.Health > 45
                end
            until not healthalert
        else
            healthalert = false
        end
    end,
})

local Sprint = windowapi.CreateButton({
    ["Name"] = "Sprint",
    ["Tab"] = "Utility",
    ["Function"] = function(callback)
        if callback then
            isSprinting = true
            repeat 
                wait()
                if bedwars["SprintController"] and not bedwars["SprintController"].sprinting then
                    pcall(function() bedwars["SprintController"]:startSprinting() end)
                end
            until not isSprinting
        else
            isSprinting = false
        end
    end,
})

local AntiVoid = windowapi.CreateButton({
    ["Name"] = "AntiVoid",
    ["Tab"] = "Utility",
    ["Function"] = function(callback)
        if callback then
            AntivoidEnabled = true
            repeat 
                wait()
                if lplr.Character and lplr.Character.HumanoidRootPart and lplr.Character.HumanoidRootPart.Position.Y < 10 then
                    workspace.Gravity = 0
                    local y = Instance.new("BodyVelocity", lplr.Character.HumanoidRootPart)
                    y.Velocity = Vector3.new(0, 100, 0)
                    task.wait(0.16)
                    y:Destroy()
                    workspace.Gravity = 196.2
                end
            until not AntivoidEnabled
        else
            AntivoidEnabled = false
        end
    end,
})

local Stealer = windowapi.CreateButton({
    ["Name"] = "Stealer",
    ["Tab"] = "Utility",
    ["Function"] = function(callback)
        if callback then
            stealerEnabled = true
            repeat 
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
            until not stealerEnabled
        else
            stealerEnabled = false
        end
    end,
})

local NoBob = windowapi.CreateButton({
    ["Name"] = "NoBob",
    ["Tab"] = "Utility",
    ["Function"] = function(callback)
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
    end,
})

-- BOUTONS SCRIPTS
local HypixelFlyV2 = windowapi.CreateButton({
    ["Name"] = "HypixelFlyV2",
    ["Tab"] = "Scripts",
    ["Function"] = function(callback)
        if callback then
            game.Workspace.Gravity = 0
            for i = 1, 12 do
                wait()
                lplr.Character.HumanoidRootPart.CFrame = lplr.Character.HumanoidRootPart.CFrame + lplr.Character.HumanoidRootPart.CFrame.LookVector * (i > 6 and 0.1 or 1)
            end
        else
            game.Workspace.Gravity = 192.6
        end
    end,
})

-- CHAT MESSAGE FINAL
chat_services.Print("☾ Moon Mobile chargé ! Appuyez sur le bouton ☾ en bas à droite")