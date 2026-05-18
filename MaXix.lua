-- ========================================================================
-- MAXIX HUX V15.2 - TRUE ARSENAL (ULTIMATE EDITION + VEHICULES)
-- ========================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

getgenv().Toggles = {}
getgenv().TargetPlayer = nil
getgenv().HitboxSize = 5
getgenv().SpamText = "MaXix HuX domine !"
getgenv().Tracers = {}
getgenv().Skeletons = {}

-- Nettoyage des dessins si un joueur quitte
Players.PlayerRemoving:Connect(function(player)
    if getgenv().Tracers[player] then getgenv().Tracers[player]:Remove(); getgenv().Tracers[player] = nil end
    if getgenv().Skeletons[player] then
        for _, line in pairs(getgenv().Skeletons[player]) do line:Remove() end
        getgenv().Skeletons[player] = nil
    end
end)

-- ========================================================================
-- 1. BULLE FLOTTANTE MOBILE
-- ========================================================================
local function CreateBubble()
    local uiParent
    pcall(function() if CoreGui:FindFirstChild("RobloxGui") then uiParent = CoreGui end end)
    if not uiParent then uiParent = LocalPlayer:WaitForChild("PlayerGui") end
    if uiParent:FindFirstChild("MaXixBubble") then uiParent.MaXixBubble:Destroy() end

    local BubbleGui = Instance.new("ScreenGui", uiParent); BubbleGui.Name = "MaXixBubble"; BubbleGui.ResetOnSpawn = false
    local BubbleButton = Instance.new("ImageButton", BubbleGui); BubbleButton.Size = UDim2.new(0, 45, 0, 45); BubbleButton.Position = UDim2.new(0.5, 0, 0.05, 0)
    BubbleButton.BackgroundColor3 = Color3.fromRGB(15, 15, 18); BubbleButton.Image = "rbxassetid://15017260580"
    BubbleButton.BackgroundTransparency = 0.3; BubbleButton.ImageTransparency = 0.3
    Instance.new("UICorner", BubbleButton).CornerRadius = UDim.new(1, 0)
    local stroke = Instance.new("UIStroke", BubbleButton); stroke.Color = Color3.fromRGB(99, 102, 241); stroke.Thickness = 2; stroke.Transparency = 0.3

    local dragging, dragStart, startPos
    BubbleButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = BubbleButton.Position
            BubbleButton.BackgroundTransparency = 0; BubbleButton.ImageTransparency = 0
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart; BubbleButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
            dragging = false; BubbleButton.BackgroundTransparency = 0.3; BubbleButton.ImageTransparency = 0.3
        end
    end)
    BubbleButton.MouseButton1Click:Connect(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.RightControl, false, game)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.RightControl, false, game)
    end)
end
CreateBubble()

-- ========================================================================
-- 2. CHARGEMENT FLUENT
-- ========================================================================
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local Window = Fluent:CreateWindow({
    Title = "MaXix HuX", SubTitle = "V15.2 Ultimate Arsenal", 
    TabWidth = 130, Size = UDim2.fromOffset(580, 420), 
    Acrylic = true, Theme = "Darker", MinimizeKey = Enum.KeyCode.RightControl
})

local Tabs = {
    Term = Window:AddTab({Title="Terminal", Icon="terminal"}),
    Mouv = Window:AddTab({Title="Mouvements", Icon="user"}),
    Combat = Window:AddTab({Title="Combat", Icon="crosshair"}),
    Vis = Window:AddTab({Title="Visuels", Icon="eye"}),
    Avatar = Window:AddTab({Title="Avatar", Icon="user-cog"}),
    Objets = Window:AddTab({Title="Objets/Véhicules", Icon="car"}), -- NOUVEL ONGLET
    Map = Window:AddTab({Title="Map/Monde", Icon="globe"}),
    Troll = Window:AddTab({Title="Troll", Icon="users"}),
    Fun = Window:AddTab({Title="Fun/Spam", Icon="smile"}),
    Hubs = Window:AddTab({Title="Hubs Externes", Icon="box"}),
    Secu = Window:AddTab({Title="Système", Icon="shield"})
}

-- ========================================================================
-- HOOK SILENT AIM
-- ========================================================================
local function GetClosestPlayer()
    local dist = math.huge
    local target = nil
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local pos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
            if onScreen then
                local mag = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                if mag < dist then dist = mag; target = p end
            end
        end
    end
    return target
end

pcall(function()
    local oldIndex = nil
    oldIndex = hookmetamethod(game, "__index", function(self, key)
        if getgenv().Toggles.SilentAim and not checkcaller() and self == Mouse and (key == "Hit" or key == "Target") then
            local tgt = GetClosestPlayer()
            if tgt and tgt.Character and tgt.Character:FindFirstChild("Head") then
                if key == "Hit" then return tgt.Character.Head.CFrame end
                if key == "Target" then return tgt.Character.Head end
            end
        end
        return oldIndex(self, key)
    end)
end)

-- ========================================================================
-- 3. TERMINAL
-- ========================================================================
Tabs.Term:AddInput("Console", {
    Title = "Commande (/cmd)", Default = "", Numeric = false, Finished = true,
    Callback = function(text)
        local args = string.split(string.lower(text), " ")
        local cmd = args[1]
        if cmd == "/fly" then getgenv().Toggles.Fly = true elseif cmd == "/unfly" then getgenv().Toggles.Fly = false
        elseif cmd == "/noclip" then getgenv().Toggles.Noc = true elseif cmd == "/clip" then getgenv().Toggles.Noc = false
        elseif cmd == "/ws" and args[2] then LocalPlayer.Character.Humanoid.WalkSpeed = tonumber(args[2])
        elseif cmd == "/jp" and args[2] then LocalPlayer.Character.Humanoid.JumpPower = tonumber(args[2])
        elseif cmd == "/day" then Lighting.ClockTime = 14 elseif cmd == "/night" then Lighting.ClockTime = 0
        elseif cmd == "/heal" then LocalPlayer.Character.Humanoid.Health = LocalPlayer.Character.Humanoid.MaxHealth
        elseif cmd == "/btools" then Instance.new("HopperBin", LocalPlayer.Backpack).BinType = 1
        end
    end
})
Tabs.Term:AddParagraph({Title="Liste", Content="/fly, /unfly, /noclip, /clip, /ws [num], /jp [num], /day, /night, /heal, /btools"})

-- ========================================================================
-- 4. MOUVEMENTS
-- ========================================================================
Tabs.Mouv:AddSection("Pouvoirs Physiques")
Tabs.Mouv:AddToggle("NC", {Title="NoClip Universel", Default=false}):OnChanged(function(v) getgenv().Toggles.Noc = v end)
Tabs.Mouv:AddToggle("Fly", {Title="Vol (Fly)", Default=false}):OnChanged(function(v) getgenv().Toggles.Fly = v end)
Tabs.Mouv:AddToggle("InfJ", {Title="Saut Infini", Default=false}):OnChanged(function(v) getgenv().Toggles.InfJ = v end)
Tabs.Mouv:AddToggle("Jesus", {Title="Marcher sur l'eau", Default=false}):OnChanged(function(v) getgenv().Toggles.Jesus = v end)
Tabs.Mouv:AddToggle("Spin", {Title="Spinbot", Default=false}):OnChanged(function(v) getgenv().Toggles.Spin = v end)
Tabs.Mouv:AddToggle("Bhop", {Title="Bunny Hop", Default=false}):OnChanged(function(v) getgenv().Toggles.Bhop = v end)
Tabs.Mouv:AddToggle("AntiRagdoll", {Title="Anti-Ragdoll/Stun", Default=false}):OnChanged(function(v) getgenv().Toggles.AntiRag = v end)
Tabs.Mouv:AddToggle("AntiFling", {Title="Anti-Fling (Ancrer)", Default=false}):OnChanged(function(v) if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then LocalPlayer.Character.HumanoidRootPart.Anchored = v end end)

Tabs.Mouv:AddSection("Vitesse & Saut")
Tabs.Mouv:AddInput("WSInp", {Title="Vitesse Exacte", Default="16", Numeric=true, Finished=true, Callback=function(v) LocalPlayer.Character.Humanoid.WalkSpeed = tonumber(v) end})
Tabs.Mouv:AddInput("JPInp", {Title="Saut Exact", Default="50", Numeric=true, Finished=true, Callback=function(v) LocalPlayer.Character.Humanoid.JumpPower = tonumber(v) end})

-- ========================================================================
-- 5. COMBAT
-- ========================================================================
Tabs.Combat:AddSection("Assistances de Tir")
Tabs.Combat:AddToggle("Aimbot", {Title="Aimbot (Caméra Lock)", Default=false}):OnChanged(function(v) getgenv().Toggles.Aimbot = v end)
Tabs.Combat:AddToggle("SilentAim", {Title="Silent Aim (Tir Magique Invisible)", Default=false}):OnChanged(function(v) getgenv().Toggles.SilentAim = v end)
Tabs.Combat:AddToggle("TriggerBot", {Title="TriggerBot (Tir Auto au survol)", Default=false}):OnChanged(function(v) getgenv().Toggles.TriggerBot = v end)
Tabs.Combat:AddToggle("Hitbox", {Title="Activer Hitbox Expander", Default=false}):OnChanged(function(v) getgenv().Toggles.Hitbox = v end)
Tabs.Combat:AddToggle("AuraFling", {Title="Aura Fling (Tornade Mortelle)", Default=false}):OnChanged(function(v) getgenv().Toggles.AuraFling = v end)

Tabs.Combat:AddSection("Taille Hitbox")
Tabs.Combat:AddButton({Title="Hitbox : Moyenne (x5)", Callback=function() getgenv().HitboxSize = 5 end})
Tabs.Combat:AddButton({Title="Hitbox : Massive (x15)", Callback=function() getgenv().HitboxSize = 15 end})

-- ========================================================================
-- 6. VISUELS
-- ========================================================================
Tabs.Vis:AddSection("ESP (Extrasensoriel)")
Tabs.Vis:AddToggle("EspBox", {Title="ESP Boxes (Chams Rouges)", Default=false}):OnChanged(function(v) getgenv().Toggles.EspBox = v end)
Tabs.Vis:AddToggle("EspName", {Title="ESP Noms", Default=false}):OnChanged(function(v) getgenv().Toggles.EspName = v end)
Tabs.Vis:AddToggle("EspTracer", {Title="ESP Tracers (Lignes vers joueurs)", Default=false}):OnChanged(function(v) getgenv().Toggles.EspTracer = v end)
Tabs.Vis:AddToggle("EspSkeleton", {Title="ESP Squelette (Skeleton)", Default=false}):OnChanged(function(v) getgenv().Toggles.EspSkeleton = v end)

Tabs.Vis:AddSection("Monde & Filtres")
Tabs.Vis:AddToggle("Fullbright", {Title="Vision Nocturne", Default=false}):OnChanged(function(v) Lighting.GlobalShadows = not v; Lighting.Brightness = v and 3 or 1 end)
Tabs.Vis:AddToggle("Xray", {Title="X-Ray (Murs transparents)", Default=false}):OnChanged(function(v) for _,p in pairs(Workspace:GetDescendants()) do if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.LocalTransparencyModifier = v and 0.5 or 0 end end end)

-- ========================================================================
-- 7. AVATAR / JOUEUR (GOD MODE & ANTI-MENOTTES AMÉLIORÉS)
-- ========================================================================
Tabs.Avatar:AddSection("Pouvoirs Divins Vrais")
Tabs.Avatar:AddToggle("GodMode", {Title="Vrai God Mode (Invincible)", Default=false}):OnChanged(function(v) 
    getgenv().Toggles.GodMode = v 
    if v and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        -- Force la vie à l'infini et empêche l'état mort
        LocalPlayer.Character.Humanoid.MaxHealth = math.huge
        LocalPlayer.Character.Humanoid.Health = math.huge
        pcall(function() LocalPlayer.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false) end)
    else
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.MaxHealth = 100
            pcall(function() LocalPlayer.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true) end)
        end
    end
end)

Tabs.Avatar:AddToggle("AntiMenottes", {Title="Anti-Menottes/Grab (Destructeur de Liens)", Default=false}):OnChanged(function(v) 
    getgenv().Toggles.AntiMenottes = v 
    if not v and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetChildren()) do if part:IsA("BasePart") then part.CanTouch = true end end
    end
end)

Tabs.Avatar:AddSection("Postures & Actions")
Tabs.Avatar:AddButton({Title="S'asseoir", Callback=function() LocalPlayer.Character.Humanoid.Sit = true end})
Tabs.Avatar:AddButton({Title="Suicide (Reset)", Callback=function() LocalPlayer.Character:BreakJoints() end})

local TPTool = Instance.new("Tool"); TPTool.Name = "Click TP"; TPTool.RequiresHandle = false
Tabs.Avatar:AddToggle("TPTool", {Title="Outil Click-to-TP", Default=false}):OnChanged(function(v) TPTool.Parent = v and LocalPlayer.Backpack or nil end)
TPTool.Activated:Connect(function() if Mouse.Hit and LocalPlayer.Character then LocalPlayer.Character:PivotTo(CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0))) end end)

-- ========================================================================
-- 8. OBJETS & VÉHICULES (NOUVEAU)
-- ========================================================================
Tabs.Objets:AddSection("Armes & Outils (Visuel/Local)")
Tabs.Objets:AddButton({Title="Se donner un Pistolet (Local)", Callback=function()
    local tool = Instance.new("Tool", LocalPlayer.Backpack); tool.Name = "MaXix Gun"; tool.RequiresHandle = false
    tool.Activated:Connect(function()
        local sound = Instance.new("Sound", Workspace); sound.SoundId = "rbxassetid://131158698"; sound.Volume = 2; sound:Play()
        game:GetService("Debris"):AddItem(sound, 2)
        -- Effet visuel basique
        if Mouse.Target then
            local part = Instance.new("Part", Workspace); part.Size = Vector3.new(0.2, 0.2, 0.2); part.BrickColor = BrickColor.new("Bright yellow")
            part.Position = Mouse.Hit.Position; part.Anchored = true
            game:GetService("Debris"):AddItem(part, 0.1)
        end
    end)
    Fluent:Notify({Title="Arme", Content="Pistolet ajouté à l'inventaire !", Duration=2})
end})

Tabs.Objets:AddSection("Manipulation des Véhicules")
Tabs.Objets:AddButton({Title="Bring Unanchored Vehicles (Voler les voitures)", Callback=function()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("VehicleSeat") and v.Parent then
            local model = v:FindFirstAncestorOfClass("Model")
            if model and model.PrimaryPart then
                model:SetPrimaryPartCFrame(LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 5, -5))
            else
                v.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 5, -5)
            end
        end
    end
    Fluent:Notify({Title="Véhicules", Content="Toutes les voitures libres ont été téléportées !", Duration=2})
end})

Tabs.Objets:AddInput("CarSpeed", {Title="Vitesse de la voiture (Actuelle)", Default="150", Numeric=true, Finished=true, Callback=function(v)
    local seat = LocalPlayer.Character.Humanoid.SeatPart
    if seat and seat:IsA("VehicleSeat") then
        seat.MaxSpeed = tonumber(v)
        Fluent:Notify({Title="Véhicule", Content="Vitesse définie sur "..v, Duration=2})
    else
        Fluent:Notify({Title="Erreur", Content="Tu dois être assis dans une voiture !", Duration=2})
    end
end})

-- ========================================================================
-- 9. MAP & MONDE
-- ========================================================================
Tabs.Map:AddSection("Destruction de Map (Client)")
Tabs.Map:AddButton({Title="Détruire KillBricks (Lave/Acide)", Callback=function() local c=0 for _,v in pairs(Workspace:GetDescendants()) do if v:IsA("TouchTransmitter") then v.Parent:Destroy() c=c+1 end end end})
Tabs.Map:AddButton({Title="Détruire les Portes", Callback=function() for _,v in pairs(Workspace:GetDescendants()) do if v:IsA("Model") and string.find(string.lower(v.Name), "door") then v:Destroy() end end end})

-- ========================================================================
-- 10. TROLL & JOUEURS
-- ========================================================================
local PlayerDropdown = Tabs.Troll:AddDropdown("PlayerSelect", {Title = "Cible Actuelle", Values = {"Aucun"}, Multi = false, Default = 1, Callback = function(v) getgenv().TargetPlayer = Players:FindFirstChild(v) end})
Tabs.Troll:AddButton({Title="Rafraîchir Liste", Callback=function() local l={}; for _,p in pairs(Players:GetPlayers()) do if p~=LocalPlayer then table.insert(l, p.Name) end end if #l==0 then table.insert(l,"Aucun") end PlayerDropdown:SetValues(l) end})
Tabs.Troll:AddButton({Title="TP sur la Cible", Callback=function() if getgenv().TargetPlayer and getgenv().TargetPlayer.Character then LocalPlayer.Character:PivotTo(getgenv().TargetPlayer.Character:GetPivot()) end end})
Tabs.Troll:AddToggle("LoopTP", {Title="Loop TP (S'attacher)", Default=false}):OnChanged(function(v) getgenv().Toggles.LoopTP = v end)

Tabs.Troll:AddSection("Destruction Globale")
Tabs.Troll:AddButton({Title="Bring All (Téléporter tous sur moi)", Callback=function() for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then p.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame end end end})
Tabs.Troll:AddToggle("InvisFling", {Title="Fling Furtif (Invisible + Destructeur)", Default=false}):OnChanged(function(v) 
    getgenv().Toggles.InvisFling = v 
    if not v and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.RotVelocity = Vector3.new(0, 0, 0)
        for _, p in pairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Transparency = 0 end end
    end
end)

-- ========================================================================
-- 11. FUN & SPAMMER
-- ========================================================================
Tabs.Fun:AddToggle("SpamOn", {Title="Activer Chat Spammer", Default=false}):OnChanged(function(v) getgenv().Toggles.Spam = v end)
Tabs.Fun:AddInput("SpamText", {Title="Texte Personnalisé", Default="MaXix HuX gère !", Numeric=false, Finished=true, Callback=function(v) getgenv().SpamText = v end})

task.spawn(function() 
    while task.wait(2) do 
        if getgenv().Toggles.Spam and getgenv().SpamText ~= "" then 
            pcall(function() game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(getgenv().SpamText, "All") end) 
            pcall(function() game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync(getgenv().SpamText) end)
        end 
    end 
end)

-- ========================================================================
-- 12. HUBS EXTERNES
-- ========================================================================
Tabs.Hubs:AddButton({Title="Charger SimpleSpy V3 (New)", Callback=function() loadstring(game:HttpGet("https://raw.githubusercontent.com/78n/SimpleSpy/main/SimpleSpySource.lua"))() end})
Tabs.Hubs:AddButton({Title="Charger Infinite Yield", Callback=function() loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))() end})

-- ========================================================================
-- 13. SÉCURITÉ & SYSTÈME (SAVE & KEYBINDS)
-- ========================================================================
local configPath = "MaXixHuX_Config.json"
Tabs.Secu:AddButton({Title="Sauvegarder la Config", Callback=function()
    if writefile then
        local data = { Hitbox = getgenv().HitboxSize, Spam = getgenv().SpamText }
        writefile(configPath, HttpService:JSONEncode(data))
        Fluent:Notify({Title="Système", Content="Configuration sauvegardée !", Duration=2})
    end
end})
Tabs.Secu:AddButton({Title="Charger la Config", Callback=function()
    if readfile and isfile and isfile(configPath) then
        local s, data = pcall(function() return HttpService:JSONDecode(readfile(configPath)) end)
        if s and data then
            if data.Hitbox then getgenv().HitboxSize = data.Hitbox end
            if data.Spam then getgenv().SpamText = data.Spam end
            Fluent:Notify({Title="Système", Content="Configuration chargée !", Duration=2})
        end
    end
end})

Tabs.Secu:AddSection("Raccourcis Clavier Rapides")
Tabs.Secu:AddKeybind("Key_Noclip", {Title = "Touche NoClip", Mode = "Toggle", Default = "Z", Callback = function(v) getgenv().Toggles.Noc = v end})
Tabs.Secu:AddKeybind("Key_Aimbot", {Title = "Touche Aimbot", Mode = "Toggle", Default = "C", Callback = function(v) getgenv().Toggles.Aimbot = v end})

-- ========================================================================
-- BOUCLE MAÎTRESSE (CORE LOOP)
-- ========================================================================
UserInputService.JumpRequest:Connect(function() if getgenv().Toggles.InfJ and LocalPlayer.Character then LocalPlayer.Character.Humanoid:ChangeState("Jumping") end end)

local skeletonConnections = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"}, {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"}, {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
    {"Head", "Torso"}, {"Torso", "Right Arm"}, {"Torso", "Left Arm"}, {"Torso", "Right Leg"}, {"Torso", "Left Leg"}
}

local lastClick = 0
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end

    -- VRAI GOD MODE CONTINU
    if getgenv().Toggles.GodMode and char:FindFirstChild("Humanoid") then 
        char.Humanoid.MaxHealth = math.huge
        char.Humanoid.Health = math.huge
    end

    -- ANTI-MENOTTES / GRAB (DESTRUCTEUR DE SOUDURES)
    if getgenv().Toggles.AntiMenottes then 
        for _, part in pairs(char:GetChildren()) do 
            if part:IsA("BasePart") then part.CanTouch = false end 
            -- Détruit toute soudure extérieure (menottes, cordes, grab)
            if part:IsA("Weld") or part:IsA("WeldConstraint") or part:IsA("RopeConstraint") then
                part:Destroy()
            end
        end 
    end

    -- MOUVEMENTS & TROLL
    if getgenv().Toggles.Noc then for _, p in pairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end
    if getgenv().Toggles.Fly and char:FindFirstChild("HumanoidRootPart") then char.HumanoidRootPart.Velocity = Vector3.new(0, 50, 0) end
    if getgenv().Toggles.Spin and char:FindFirstChild("HumanoidRootPart") then char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(50), 0) end
    if getgenv().Toggles.AuraFling and char:FindFirstChild("HumanoidRootPart") then char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(90), 0) end
    if getgenv().Toggles.LoopTP and getgenv().TargetPlayer and getgenv().TargetPlayer.Character and getgenv().TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then char.HumanoidRootPart.CFrame = getgenv().TargetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2) end
    
    -- FLING FURTIF
    if getgenv().Toggles.InvisFling and char:FindFirstChild("HumanoidRootPart") then
        for _, p in pairs(char:GetDescendants()) do
            if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Transparency = 1; p.CanCollide = false end
        end
        char.HumanoidRootPart.RotVelocity = Vector3.new(0, 999999, 0)
    end

    -- TRIGGERBOT
    if getgenv().Toggles.TriggerBot and typeof(mouse1click) == "function" then
        local target = Mouse.Target
        if target and target.Parent and target.Parent:FindFirstChild("Humanoid") and target.Parent.Name ~= LocalPlayer.Name then
            if tick() - lastClick > 0.1 then mouse1click(); lastClick = tick() end
        end
    end

    -- AIMBOT
    if getgenv().Toggles.Aimbot then
        local closest = GetClosestPlayer()
        if closest then Camera.CFrame = CFrame.new(Camera.CFrame.Position, closest.Character.Head.Position) end
    end

    -- BOUCLE SUR TOUS LES JOUEURS (ESP, HITBOX, SKELETON)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            
            -- Hitbox
            if getgenv().Toggles.Hitbox and p.Character:FindFirstChild("Head") then 
                p.Character.Head.Size = Vector3.new(getgenv().HitboxSize, getgenv().HitboxSize, getgenv().HitboxSize)
                p.Character.Head.Transparency = 0.5; p.Character.Head.CanCollide = false 
            end

            -- ESP Box & Name
            if getgenv().Toggles.EspBox and not p.Character:FindFirstChild("MaXixCham") then local hl = Instance.new("Highlight", p.Character); hl.Name = "MaXixCham"; hl.FillColor = Color3.fromRGB(255, 0, 0); hl.FillTransparency = 0.5
            elseif not getgenv().Toggles.EspBox and p.Character:FindFirstChild("MaXixCham") then p.Character.MaXixCham:Destroy() end
            
            if getgenv().Toggles.EspName and p.Character:FindFirstChild("Head") and not p.Character.Head:FindFirstChild("MaXixName") then
                local bgui = Instance.new("BillboardGui", p.Character.Head); bgui.Name = "MaXixName"; bgui.Size = UDim2.new(0, 100, 0, 40); bgui.AlwaysOnTop = true
                local text = Instance.new("TextLabel", bgui); text.Size = UDim2.new(1,0,1,0); text.BackgroundTransparency = 1; text.TextColor3 = Color3.fromRGB(255, 255, 255); text.Text = p.Name
            elseif not getgenv().Toggles.EspName and p.Character:FindFirstChild("Head") and p.Character.Head:FindFirstChild("MaXixName") then
                p.Character.Head.MaXixName:Destroy()
            end

            -- ESP TRACERS
            if getgenv().Toggles.EspTracer and p.Character:FindFirstChild("HumanoidRootPart") then
                local vector, onScreen = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                if not getgenv().Tracers[p] then getgenv().Tracers[p] = Drawing.new("Line"); getgenv().Tracers[p].Thickness = 1.5; getgenv().Tracers[p].Color = Color3.fromRGB(255, 0, 50) end
                if onScreen then
                    getgenv().Tracers[p].Visible = true; getgenv().Tracers[p].From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y); getgenv().Tracers[p].To = Vector2.new(vector.X, vector.Y)
                else getgenv().Tracers[p].Visible = false end
            elseif getgenv().Tracers[p] then getgenv().Tracers[p].Visible = false end

            -- ESP SKELETON
            if not getgenv().Skeletons[p] then getgenv().Skeletons[p] = {} end
            if getgenv().Toggles.EspSkeleton then
                for _, joint in ipairs(skeletonConnections) do
                    local part1 = p.Character:FindFirstChild(joint[1])
                    local part2 = p.Character:FindFirstChild(joint[2])
                    if part1 and part2 then
                        local pos1, vis1 = Camera:WorldToViewportPoint(part1.Position)
                        local pos2, vis2 = Camera:WorldToViewportPoint(part2.Position)
                        local lineId = joint[1]..joint[2]
                        if not getgenv().Skeletons[p][lineId] then
                            getgenv().Skeletons[p][lineId] = Drawing.new("Line"); getgenv().Skeletons[p][lineId].Thickness = 1.5; getgenv().Skeletons[p][lineId].Color = Color3.fromRGB(255, 255, 255)
                        end
                        if vis1 or vis2 then
                            getgenv().Skeletons[p][lineId].Visible = true; getgenv().Skeletons[p][lineId].From = Vector2.new(pos1.X, pos1.Y); getgenv().Skeletons[p][lineId].To = Vector2.new(pos2.X, pos2.Y)
                        else getgenv().Skeletons[p][lineId].Visible = false end
                    end
                end
            else
                for _, line in pairs(getgenv().Skeletons[p]) do line.Visible = false end
            end
        end
    end
end)

Window:SelectTab(1)
Fluent:Notify({Title = "MaXix HuX V15.2", Content = "God Mode & Anti-Menottes V2 + Véhicules !", Duration = 5})
