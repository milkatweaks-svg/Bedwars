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

function newTab(name)
    uiCount = uiCount + 1
    btnCounts[name] = 0
    local main = Instance.new("Frame")
    local UIListLayout = Instance.new("UIListLayout")
    local top = Instance.new("Frame")
    local TextLabel = Instance.new("TextLabel")
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Name = name
    main.Name = "main"
    main.Parent = ScreenGui
    main.BackgroundColor3 = Color3.fromRGB(99, 99, 99)
    main.BorderSizePixel = 0
    main.Position = UDim2.new(0.449541271 * uiCount / 3, 0, 0.279268295, 0)
    main.Size = UDim2.new(0, 164, 0, 20)
    UIListLayout.Parent = main
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    top.Name = "top"
    top.Parent = ScreenGui
    top.BackgroundColor3 = Color3.fromRGB(200, 0, 255)
    top.BorderColor3 = Color3.fromRGB(27, 42, 53)
    top.BorderSizePixel = 0
    top.Position = UDim2.new(0.449541271 * uiCount / 3, 0, 0.2581219481, 0)
    top.Size = UDim2.new(0, 164, 0, 23)
    TextLabel.Parent = top
    TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.BackgroundTransparency = 1.000
    TextLabel.Size = UDim2.new(0, 86, 0, 23)
    TextLabel.Font = Enum.Font.SourceSans
    TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.TextScaled = true
    TextLabel.TextSize = 14.000
    TextLabel.TextWrapped = true
    TextLabel.Text = name
    
    -- Correction : définition de rainbowTop
    local rainbowTop = top
    
    local blurEffect = Instance.new("BlurEffect")
    blurEffect.Parent = main
    blurEffect.Size = 20

    UIS.InputBegan:Connect(function(key)
        if key.KeyCode == Enum.KeyCode.RightShift then
            if main.Visible == true then
                main.Visible = false
                top.Visible = false
                TextLabel.Visible = false
                blurEffect:Destroy()
                if rainbowTop then rainbowTop.Visible = false end
            else
                local blurEffect = Instance.new("BlurEffect")
                blurEffect.Parent = main
                blurEffect.Size = 20
                main.Visible = true
                top.Visible = true
                TextLabel.Visible = true
                if rainbowTop then rainbowTop.Visible = true end
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
    local TextButton = Instance.new("TextButton")
    TextButton.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")[tableData["Tab"]].main
    TextButton.BackgroundColor3 = Color3.fromRGB(52, 52, 52)
    TextButton.BackgroundTransparency = 0
    TextButton.Size = UDim2.new(0, 164, 0, 30)
    TextButton.Font = Enum.Font.SourceSans
    TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextButton.TextScaled = true
    TextButton.TextSize = 14.000
    TextButton.TextWrapped = true
    TextButton.Text = tableData["Name"]
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
    TextButton.BorderSizePixel = 0
    
    -- Correction pour Delta : utiliser les événements modernes
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

    -- Raccourci clavier (simplifié pour Delta)
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

    TextButton.MouseButton2Down:Connect(function()
        local ui = Instance.new("ScreenGui")
        ui.Parent = game.Players.LocalPlayer.PlayerGui
        local TextBox = Instance.new("TextBox")
        TextBox.Parent = ui
        TextBox.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
        TextBox.Position = UDim2.new(0.464, 0, 0.482, 0)
        TextBox.Size = UDim2.new(0, 164, 0, 30)
        TextBox.Font = Enum.Font.SourceSans
        TextBox.ZIndex = 999
        TextBox.Text = ""
        TextBox.TextColor3 = Color3.fromRGB(0, 0, 0)
        TextBox.TextSize = 14.000
        TextBox.BorderSizePixel = 0
        TextBox.Focused:Connect(function()
            TextBox.BorderSizePixel = 5
            TextBox.BorderColor3 = Color3.fromRGB(255, 0, 255)
        end)
        TextBox.FocusLost:Connect(function()
            bind = TextBox.Text
            chat_services.Print(tableData["Name"].." has been bound to key "..bind)
            TextBox:Destroy()
            ui:Destroy()
            if isEnabled then
                delfile("MoonBinds/"..tableData["Name"]..".txt")
                writefile("MoonBinds/"..tableData["Name"]..".txt", bind)
            else
                writefile("MoonBinds/"..tableData["Name"]..".txt", bind)
            end
        end)
    end)
end

local function chat(msg)
    local args = {
        [1] = msg,
        [2] = "All"
    }
    game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(unpack(args))
end

function AddTag(plr, tag, color)
    -- Version simplifiée pour Delta
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

local Enabled = true

newTab("Combat")
newTab("Movement")
newTab("Visuals")
newTab("Utility")
newTab("Scripts")

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
            local s5 = -1000
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
local flytime = 2.6
local status
Flight = windowapi.CreateButton({
    ["Name"] = "Flight",
    ["Tab"] = "Movement",
    ["Function"] = function(callback)
        if callback then
            isFlying = true
            flytimer = Instance.new("ScreenGui")
            timer = Instance.new("TextLabel")
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
            if flytimer then flytimer:Destroy() end
        end
    end,
})

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
    ["Name"] = "Health-Alert",
    ["Tab"] = "Utility",
    ["Function"] = function(callback)
        if callback then
            healthalert = true
            repeat 
                wait()
                if lplr.Character and lplr.Character.Humanoid and lplr.Character.Humanoid.Health < 45 then
                    chat_services.Warn("Low Health Warning, Your Health is Under 45!")
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

chat_services.Print("Moon script chargé ! Appuyez sur RightShift pour afficher le menu")