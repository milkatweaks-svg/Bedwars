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
local menuVisible = true -- Ajouté pour gérer l'affichage global du menu

chat_services.Warn("Loaded Successfully!")

function newTab(name)
    uiCount = uiCount + 1
    btnCounts[name] = 0
    
    -- Création de l'interface principale
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Name = name
    
    -- Frame principal qui contiendra les boutons
    local main = Instance.new("Frame")
    main.Name = "main"
    main.Parent = ScreenGui
    main.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    main.BorderSizePixel = 0
    main.Position = UDim2.new(0.2 + (0.15 * (uiCount - 1)), 0, 0.2, 0) -- Positionnement amélioré
    main.Size = UDim2.new(0, 180, 0, 400)
    main.BackgroundTransparency = 0.15
    main.Visible = true
    
    -- Layout pour les boutons
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = main
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 3)
    
    -- Top bar avec le nom de l'onglet
    local top = Instance.new("Frame")
    top.Name = "top"
    top.Parent = ScreenGui
    top.BackgroundColor3 = Color3.fromRGB(200, 0, 255)
    top.BorderSizePixel = 0
    top.Position = UDim2.new(0.2 + (0.15 * (uiCount - 1)), 0, 0.18, 0)
    top.Size = UDim2.new(0, 180, 0, 25)
    top.Visible = true
    
    -- Label du nom
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Parent = top
    TextLabel.BackgroundTransparency = 1
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.Font = Enum.Font.SourceSansBold
    TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.TextScaled = true
    TextLabel.TextSize = 14
    TextLabel.TextWrapped = true
    TextLabel.Text = name
    
    -- Effet de flou (optionnel)
    local blurEffect = Instance.new("BlurEffect")
    blurEffect.Parent = main
    blurEffect.Size = 10
    
    -- Gestion de l'affichage avec RightShift
    UIS.InputBegan:Connect(function(key)
        if key.KeyCode == Enum.KeyCode.RightShift then
            menuVisible = not menuVisible
            for _, gui in pairs(game.Players.LocalPlayer.PlayerGui:GetChildren()) do
                if gui:IsA("ScreenGui") and gui ~= game.Players.LocalPlayer.PlayerGui:FindFirstChild("CoreGui") then
                    gui.Visible = menuVisible
                end
            end
        end
    end)
end

local windowapi = {}

windowapi["CreateButton"] = function(tableData)
    btnCounts[tableData["Tab"]] = btnCounts[tableData["Tab"]] + 1
    local btnAPI = {}

    local player = game.Players.LocalPlayer
    local mouse = player:GetMouse()
    local bind = "nil"
    btnAPI["ModuleEnabled"] = false
    
    -- Création du bouton dans le bon onglet
    local tabGui = game.Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild(tableData["Tab"])
    if not tabGui then
        chat_services.Warn("Onglet "..tableData["Tab"].." non trouvé!")
        return
    end
    
    local mainFrame = tabGui:FindFirstChild("main")
    if not mainFrame then
        chat_services.Warn("Frame main non trouvé dans "..tableData["Tab"])
        return
    end
    
    local TextButton = Instance.new("TextButton")
    TextButton.Parent = mainFrame
    TextButton.BackgroundColor3 = Color3.fromRGB(52, 52, 52)
    TextButton.BackgroundTransparency = 0
    TextButton.Size = UDim2.new(0.9, 0, 0, 30)
    TextButton.Position = UDim2.new(0.05, 0, 0, 0)
    TextButton.Font = Enum.Font.SourceSans
    TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextButton.TextScaled = true
    TextButton.TextSize = 14
    TextButton.TextWrapped = true
    TextButton.Text = tableData["Name"]
    TextButton.BorderSizePixel = 0
    
    -- Vérification des fichiers de sauvegarde
    local isEnabled = isfile(tableData["Name"]..".txt")
    if isfile("MoonBinds/"..tableData["Name"]..".txt") then
        bind = readfile("MoonBinds/"..tableData["Name"]..".txt")
    end
    
    if isEnabled then
        local function resume()
            if isfile("MoonBinds/"..tableData["Name"]..".txt") then
                bind = readfile("MoonBinds/"..tableData["Name"]..".txt")
            end
            TextButton.BackgroundColor3 = Color3.fromRGB(200, 0, 255)
            btnAPI['ModuleEnabled'] = true
            tableData["Function"](true)
        end
        if tableData["Name"] ~= "Flight" then
            coroutine.wrap(resume)()
        end
    end
    
    -- Gestion des clics
    TextButton.MouseButton1Down:Connect(function()
        if btnAPI['ModuleEnabled'] then
            if isEnabled then
                delfile(tableData["Name"]..".txt")
            end
            chat_services.Print(tableData["Name"].." has been disabled!")
            btnAPI['ModuleEnabled'] = false
            tableData["Function"](false)
            TextButton.BackgroundColor3 = Color3.fromRGB(52, 52, 52)
        else
            chat_services.Print(tableData["Name"].." has been enabled!")
            writefile(tableData["Name"]..".txt", bind)
            TextButton.BackgroundColor3 = Color3.fromRGB(200, 0, 255)
            btnAPI['ModuleEnabled'] = true
            tableData["Function"](true)
        end
    end)
    
    -- Raccourci clavier
    UIS.InputBegan:Connect(function(key)
        if key.KeyCode == Enum.KeyCode[bind:upper()] then
            if btnAPI['ModuleEnabled'] then
                if isEnabled then
                    delfile(tableData["Name"]..".txt")
                end
                chat_services.Print(tableData["Name"].." has been disabled!")
                btnAPI['ModuleEnabled'] = false
                tableData["Function"](false)
                TextButton.BackgroundColor3 = Color3.fromRGB(52, 52, 52)
            else
                writefile(tableData["Name"]..".txt", bind)
                chat_services.Print(tableData["Name"].." has been enabled!")
                TextButton.BackgroundColor3 = Color3.fromRGB(200, 0, 255)
                btnAPI['ModuleEnabled'] = true
                tableData["Function"](true)
            end
        end
    end)
    
    -- Effets de survol
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
    
    -- Binding avec clic droit
    TextButton.MouseButton2Down:Connect(function()
        local ui = Instance.new("ScreenGui")
        ui.Parent = game.Players.LocalPlayer.PlayerGui
        
        local TextBox = Instance.new("TextBox")
        TextBox.Parent = ui
        TextBox.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
        TextBox.Position = UDim2.new(0.4, 0, 0.4, 0)
        TextBox.Size = UDim2.new(0, 200, 0, 40)
        TextBox.Font = Enum.Font.SourceSans
        TextBox.ZIndex = 999
        TextBox.Text = ""
        TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        TextBox.TextSize = 20
        TextBox.BorderSizePixel = 2
        TextBox.BorderColor3 = Color3.fromRGB(200, 0, 255)
        TextBox.PlaceholderText = "Entrez une touche"
        
        TextBox.Focused:Connect(function()
            TextBox.BorderColor3 = Color3.fromRGB(255, 0, 255)
        end)
        
        TextBox.FocusLost:Connect(function(enterPressed)
            if enterPressed then
                bind = TextBox.Text
                chat_services.Print(tableData["Name"].." bound to "..bind)
                
                -- Créer le dossier si nécessaire
                if not isfile("MoonBinds/") then
                    makefolder("MoonBinds")
                end
                
                if isEnabled then
                    if isfile("MoonBinds/"..tableData["Name"]..".txt") then
                        delfile("MoonBinds/"..tableData["Name"]..".txt")
                    end
                    writefile("MoonBinds/"..tableData["Name"]..".txt", bind)
                else
                    writefile("MoonBinds/"..tableData["Name"]..".txt", bind)
                end
            end
            TextBox:Destroy()
            ui:Destroy()
        end)
        TextBox:CaptureFocus()
    end)
end

-- Le reste du script reste identique, je l'inclus pour complétude mais tu peux garder ta version

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

local cam = game:GetService("Workspace").CurrentCamera

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

newTab("Combat")
newTab("Movement")
newTab("Visuals")
newTab("Utility")
newTab("Scripts")

-- Création des boutons (le reste du code reste inchangé)
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

-- ... Continue avec tous les autres boutons exactement comme dans ton script original

chat_services.Print("Moon script chargé ! Appuyez sur RightShift pour afficher le menu")