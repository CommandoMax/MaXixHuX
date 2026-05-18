-- ========================================================================
-- MAXIX HUX V15.1 - TRUE ARSENAL (ULTIMATE EDITION)
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
    Title = "MaXix HuX", SubTitle = "V15.1 Ultimate Arsenal", 
    TabWidth = 130, Size = UDim2.fromOffset(580, 420), 
    Acrylic = true, Theme = "Darker", MinimizeKey = Enum.KeyCode.RightControl
})

local Tabs = {
    Term = Window:AddTab({Title="Terminal", Icon="terminal"}),
    Mouv = Window:AddTab({Title="Mouvements", Icon="user"}),
    Combat = Window:AddTab({Title="Combat", Icon="crosshair"}),
    Vis = Window:AddTab({Title="Visuels", Icon="eye"}),
    Avatar = Window:AddTab({Title="Avatar", Icon="user-cog"}),
    Map = Window:AddTab({Title="Map/Monde", Icon="globe"}),
    Troll = Window:AddTab({Title="Troll", Icon="users"}),
    Fun = Window:AddTab({Title="Fun/Spam", Icon="smile"}),
    Hubs = Window:AddTab({Title="Hubs Externes", Icon="box"}),
    Secu = Window:AddTab({Title="Système", Icon="shield"})
}

-- ========================================================================
-- HOOK SILENT AIM (Doit être défini tôt)
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
Tabs.Mouv:AddButton({Title="Preset Vitesse : Rapide (30)", Callback=function() LocalPlayer.Character.Humanoid.WalkSpeed = 30 end})
Tabs.Mouv:AddButton({Title="Preset Vitesse : Flash (100)", Callback=function() LocalPlayer.Character.Humanoid.WalkSpeed = 100 end})
Tabs.Mouv:AddButton({Title="Preset Vitesse : Normal (16)", Callback=function() LocalPlayer.Character.Humanoid.WalkSpeed = 16 end})
Tabs.Mouv:AddInput("JPInp", {Title="Saut Exact", Default="50", Numeric=true, Finished=true, Callback=function(v) LocalPlayer.Character.Humanoid.JumpPower = tonumber(v) end})
Tabs.Mouv:AddButton({Title="Preset Saut : Haut (100)", Callback=function() LocalPlayer.Character.Humanoid.JumpPower = 100 end})
Tabs.Mouv:AddButton({Title="Preset Saut : Lune (250)", Callback=function() LocalPlayer.Character.Humanoid.JumpPower = 250 end})
Tabs.Mouv:AddButton({Title="Preset Saut : Normal (50)", Callback=function() LocalPlayer.Character.Humanoid.JumpPower = 50 end})

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
Tabs.Combat:AddButton({Title="Hitbox : Légère (x2)", Callback=function() getgenv().HitboxSize = 2 end})
Tabs.Combat:AddButton({Title="Hitbox : Moyenne (x5)", Callback=function() getgenv().HitboxSize = 5 end})
Tabs.Combat:AddButton({Title="Hitbox : Massive (x15)", Callback=function() getgenv().HitboxSize = 15 end})

Tabs.Combat:AddSection("Aides à la Visée")
Tabs.Combat:AddInput("FOV", {Title="FOV Caméra", Default="70", Numeric=true, Finished=true, Callback=function(v) Camera.FieldOfView = tonumber(v) end})
Tabs.Combat:AddButton({Title="Preset FOV : Quake (100)", Callback=function() Camera.FieldOfView = 100 end})
Tabs.Combat:AddButton({Title="Preset FOV : Zoom (30)", Callback=function() Camera.FieldOfView = 30 end})
Tabs.Combat:AddButton({Title="Preset FOV : Normal (70)", Callback=function() Camera.FieldOfView = 70 end})

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
Tabs.Vis:AddToggle("NoFog", {Title="Supprimer Brouillard", Default=false}):OnChanged(function(v) Lighting.FogEnd = v and 100000 or 1000 end)

Tabs.Vis:AddButton({Title="Filtre : Rouge Sang", Callback=function() for _,v in pairs(Lighting:GetChildren()) do if v.Name=="MaxFiltre" then v:Destroy() end end local cc = Instance.new("ColorCorrectionEffect", Lighting); cc.Name = "MaxFiltre"; cc.TintColor = Color3.new(1,0,0) end})
Tabs.Vis:AddButton({Title="Filtre : Bleu Océan", Callback=function() for _,v in pairs(Lighting:GetChildren()) do if v.Name=="MaxFiltre" then v:Destroy() end end local cc = Instance.new("ColorCorrectionEffect", Lighting); cc.Name = "MaxFiltre"; cc.TintColor = Color3.new(0,0.5,1) end})
Tabs.Vis:AddButton({Title="Filtre : Normal (Reset)", Callback=function() for _,v in pairs(Lighting:GetChildren()) do if v.Name=="MaxFiltre" then v:Destroy() end end end})

Tabs.Vis:AddSection("Horloge du Jeu")
Tabs.Vis:AddButton({Title="Heure : Aube (6:00)", Callback=function() Lighting.ClockTime = 6 end})
Tabs.Vis:AddButton({Title="Heure : Midi (12:00)", Callback=function() Lighting.ClockTime = 12 end})
Tabs.Vis:AddButton({Title="Heure : Minuit (0:00)", Callback=function() Lighting.ClockTime = 0 end})

-- ========================================================================
-- 7. AVATAR / JOUEUR
-- ========================================================================
Tabs.Avatar:AddSection("Pouvoirs Divins")
Tabs.Avatar:AddToggle("GodMode", {Title="God Mode (Boucle de Soin)", Default=false}):OnChanged(function(v) getgenv().Toggles.GodMode = v end)
Tabs.Avatar:AddToggle("Intouchable", {Title="Intouchable (Anti-Menottes/Grab)", Default=false}):OnChanged(function(v) 
    getgenv().Toggles.Intouchable = v 
    if not v and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetChildren()) do if part:IsA("BasePart") then part.CanTouch = true end end
    end
end)

Tabs.Avatar:AddSection("Altération du Corps (Local)")
Tabs.Avatar:AddButton({Title="Devenir Chauve (Supprimer Chapeaux)", Callback=function() if LocalPlayer.Character then for _,v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("Accessory") then v:Destroy() end end end end})
Tabs.Avatar:AddButton({Title="Supprimer Visage", Callback=function() if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head") and LocalPlayer.Character.Head:FindFirstChild("Decal") then LocalPlayer.Character.Head.Decal:Destroy() end end})
Tabs.Avatar:AddButton({Title="Supprimer T-Shirt", Callback=function() if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Shirt") then LocalPlayer.Character.Shirt:Destroy() end end})
Tabs.Avatar:AddButton({Title="Supprimer Pantalon", Callback=function() if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Pants") then LocalPlayer.Character.Pants:Destroy() end end})
Tabs.Avatar:AddButton({Title="Mode Tête Géante", Callback=function() if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head") then LocalPlayer.Character.Head.Size = Vector3.new(4,4,4) end end})

Tabs.Avatar:AddSection("Postures & Actions")
Tabs.Avatar:AddButton({Title="S'asseoir", Callback=function() LocalPlayer.Character.Humanoid.Sit = true end})
Tabs.Avatar:AddButton({Title="Se Lever", Callback=function() LocalPlayer.Character.Humanoid.Sit = false; LocalPlayer.Character.Humanoid.PlatformStand = false end})
Tabs.Avatar:AddButton({Title="Suicide (Reset)", Callback=function() LocalPlayer.Character:BreakJoints() end})
Tabs.Avatar:AddButton({Title="Copier ma Position (CFrame)", Callback=function() if LocalPlayer.Character then setclipboard(tostring(LocalPlayer.Character.HumanoidRootPart.Position)) Fluent:Notify({Title="Copié", Content="Position copiée !", Duration=2}) end end})

local TPTool = Instance.new("Tool"); TPTool.Name = "Click TP"; TPTool.RequiresHandle = false
Tabs.Avatar:AddToggle("TPTool", {Title="Outil Click-to-TP", Default=false}):OnChanged(function(v) TPTool.Parent = v and LocalPlayer.Backpack or nil end)
TPTool.Activated:Connect(function() if Mouse.Hit and LocalPlayer.Character then LocalPlayer.Character:PivotTo(CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0))) end end)

-- ========================================================================
-- 8. MAP & MONDE
-- ========================================================================
Tabs.Map:AddSection("Destruction de Map (Client)")
Tabs.Map:AddButton({Title="Détruire KillBricks (Lave/Acide)", Callback=function() local c=0 for _,v in pairs(Workspace:GetDescendants()) do if v:IsA("TouchTransmitter") then v.Parent:Destroy() c=c+1 end end Fluent:Notify({Title="Map", Content=c.." KillBricks détruits.", Duration=2}) end})
Tabs.Map:AddButton({Title="Détruire Murs Invisibles", Callback=function() local c=0 for _,v in pairs(Workspace:GetDescendants()) do if v:IsA("BasePart") and v.Transparency >= 1 and v.CanCollide and v.Name~="HumanoidRootPart" then v:Destroy() c=c+1 end end Fluent:Notify({Title="Map", Content=c.." murs détruits.", Duration=2}) end})
Tabs.Map:AddButton({Title="Détruire les Portes", Callback=function() for _,v in pairs(Workspace:GetDescendants()) do if v:IsA("Model") and string.find(string.lower(v.Name), "door") then v:Destroy() end end end})
Tabs.Map:AddButton({Title="Supprimer toutes les Textures", Callback=function() for _,v in pairs(Workspace:GetDescendants()) do if v:IsA("Texture") or v:IsA("Decal") then v:Destroy() end end end})
Tabs.Map:AddButton({Title="Supprimer l'Eau du terrain", Callback=function() Workspace.Terrain:Clear() end})

Tabs.Map:AddSection("Exploits Gravité & BTools")
Tabs.Map:AddToggle("AntiVoid", {Title="Anti-Void (Plateforme sécurité)", Default=false}):OnChanged(function(v) 
    if v then 
        local p = Instance.new("Part", Workspace); p.Name="MaXixV"; p.Size=Vector3.new(5000,5,5000); p.Position=Vector3.new(0,-50,0); p.Anchored=true; p.Transparency=0.5 
    elseif Workspace:FindFirstChild("MaXixV") then Workspace.MaXixV:Destroy() end 
end)
Tabs.Map:AddButton({Title="BTools (Outils de construction)", Callback=function() local t = Instance.new("HopperBin"); t.BinType = 1; t.Parent = LocalPlayer.Backpack end})
Tabs.Map:AddButton({Title="Gravité : Lune (50)", Callback=function() Workspace.Gravity = 50 end})
Tabs.Map:AddButton({Title="Gravité : Zéro (0)", Callback=function() Workspace.Gravity = 0 end})
Tabs.Map:AddButton({Title="Gravité : Normale (196.2)", Callback=function() Workspace.Gravity = 196.2 end})

-- ========================================================================
-- 9. TROLL & JOUEURS
-- ========================================================================
local PlayerDropdown = Tabs.Troll:AddDropdown("PlayerSelect", {Title = "Cible Actuelle", Values = {"Aucun"}, Multi = false, Default = 1, Callback = function(v) getgenv().TargetPlayer = Players:FindFirstChild(v) end})
Tabs.Troll:AddButton({Title="Rafraîchir Liste Serveur", Callback=function() local l={}; for _,p in pairs(Players:GetPlayers()) do if p~=LocalPlayer then table.insert(l, p.Name) end end if #l==0 then table.insert(l,"Aucun") end PlayerDropdown:SetValues(l) Fluent:Notify({Title="Troll", Content="Liste Actualisée", Duration=1}) end})

Tabs.Troll:AddSection("Actions sur la Cible")
Tabs.Troll:AddButton({Title="TP sur la Cible", Callback=function() if getgenv().TargetPlayer and getgenv().TargetPlayer.Character then LocalPlayer.Character:PivotTo(getgenv().TargetPlayer.Character:GetPivot()) end end})
Tabs.Troll:AddButton({Title="Spectate Cible", Callback=function() if getgenv().TargetPlayer and getgenv().TargetPlayer.Character then Camera.CameraSubject = getgenv().TargetPlayer.Character.Humanoid end end})
Tabs.Troll:AddButton({Title="Arrêter Spectate", Callback=function() Camera.CameraSubject = LocalPlayer.Character.Humanoid end})
Tabs.Troll:AddToggle("LoopTP", {Title="Loop TP (S'attacher à la cible)", Default=false}):OnChanged(function(v) getgenv().Toggles.LoopTP = v end)

Tabs.Troll:AddSection("Destruction Globale")
Tabs.Troll:AddButton({Title="Bring All (Téléporter tous sur moi)", Callback=function() for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then p.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame end end end})
Tabs.Troll:AddButton({Title="Void All (Jeter tous dans le vide)", Callback=function() for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then p.Character.HumanoidRootPart.CFrame = CFrame.new(0, -9999, 0) end end end})
Tabs.Troll:AddToggle("InvisFling", {Title="Fling Furtif (Invisible + Destructeur)", Default=false}):OnChanged(function(v) 
    getgenv().Toggles.InvisFling = v 
    if not v and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.RotVelocity = Vector3.new(0, 0, 0)
        for _, p in pairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Transparency = 0 end end
    end
end)

-- ========================================================================
-- 10. FUN & SPAMMER
-- ========================================================================
Tabs.Fun:AddSection("Emotes")
Tabs.Fun:AddButton({Title="Emote : Danse 1", Callback=function() game:GetService("Chat"):InvokeServer("/e dance") end})
Tabs.Fun:AddButton({Title="Emote : Danse 2", Callback=function() game:GetService("Chat"):InvokeServer("/e dance2") end})
Tabs.Fun:AddButton({Title="Emote : Rire", Callback=function() game:GetService("Chat"):InvokeServer("/e laugh") end})
Tabs.Fun:AddButton({Title="Emote : Applaudir", Callback=function() game:GetService("Chat"):InvokeServer("/e cheer") end})

Tabs.Fun:AddSection("Chat Spammer")
Tabs.Fun:AddToggle("SpamOn", {Title="Activer Chat Spammer", Default=false}):OnChanged(function(v) getgenv().Toggles.Spam = v end)
Tabs.Fun:AddInput("SpamText", {Title="Texte Personnalisé", Default="MaXix HuX gère !", Numeric=false, Finished=true, Callback=function(v) getgenv().SpamText = v end})
Tabs.Fun:AddButton({Title="Preset Spam : Je vole !", Callback=function() getgenv().SpamText = "Regardez-moi, je vole ! (MaXix HuX)" end})
Tabs.Fun:AddButton({Title="Preset Spam : EZ Win", Callback=function() getgenv().SpamText = "EZ Win, serveur dominé." end})
Tabs.Fun:AddButton({Title="Preset Spam : Tornade", Callback=function() getgenv().SpamText = "Attention, la tornade mortelle arrive !" end})

task.spawn(function() 
    while task.wait(2) do 
        if getgenv().Toggles.Spam and getgenv().SpamText ~= "" then 
            pcall(function() game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(getgenv().SpamText, "All") end) 
            pcall(function() game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync(getgenv().SpamText) end)
        end 
    end 
end)

-- ========================================================================
-- 11. HUBS EXTERNES
-- ========================================================================
Tabs.Hubs:AddSection("Charger d'autres gros scripts (Directement)")
Tabs.Hubs:AddButton({Title="Charger SimpleSpy V3 (New)", Callback=function() loadstring(game:HttpGet("https://raw.githubusercontent.com/78n/SimpleSpy/main/SimpleSpySource.lua"))() end})
Tabs.Hubs:AddButton({Title="Charger Infinite Yield", Callback=function() loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))() end})
Tabs.Hubs:AddButton({Title="Charger Nameless Admin (New)", Callback=function() loadstring(game:HttpGet("https://raw.githubusercontent.com/FilteringEnabled/NamelessAdmin/main/Source"))() end})
Tabs.Hubs:AddButton({Title="Charger Dex Explorer V2", Callback=function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Spaceexx/Scripts/main/DexV2"))() end})
Tabs.Hubs:AddButton({Title="Charger Dark Dex", Callback=function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Universal/BypassedDarkDexV3.lua", true))() end})

-- ========================================================================
-- 12. SÉCURITÉ & SYSTÈME (AVEC SAVE & KEYBINDS)
-- ========================================================================
Tabs.Secu:AddToggle("AntiAFK", {Title="Anti-AFK (Bypass déconnexion 20m)", Default=true}):OnChanged(function(v) getgenv().Toggles.Afk = v end)
LocalPlayer.Idled:Connect(function() if getgenv().Toggles.Afk then VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game); task.wait(0.1); VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game) end end)
Tabs.Secu:AddButton({Title="Ouvrir Console (F9)", Callback=function() game:GetService("StarterGui"):SetCore("DevConsoleVisible", true) end})
Tabs.Secu:AddButton({Title="Copier JobID Serveur", Callback=function() setclipboard(tostring(game.JobId)) Fluent:Notify({Title="Succès", Content="JobID Copié", Duration=2}) end})
Tabs.Secu:AddButton({Title="Changer de Serveur (Server Hop)", Callback=function() game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer) end})
Tabs.Secu:AddButton({Title="Détruire le Menu", Callback=function() if CoreGui:FindFirstChild("MaXixBubble") then CoreGui.MaXixBubble:Destroy() end Fluent:Destroy() end})

-- SYSTEME DE SAUVEGARDE
local configPath = "MaXixHuX_Config.json"
Tabs.Secu:AddSection("Sauvegarde de Config")
Tabs.Secu:AddButton({Title="Sauvegarder la Config", Callback=function()
    if writefile then
        local data = { Hitbox = getgenv().HitboxSize, Spam = getgenv().SpamText }
        writefile(configPath, HttpService:JSONEncode(data))
        Fluent:Notify({Title="Système", Content="Configuration sauvegardée !", Duration=2})
    else
        Fluent:Notify({Title="Erreur", Content="Exécuteur incompatible avec writefile.", Duration=2})
    end
end})
Tabs.Secu:AddButton({Title="Charger la Config", Callback=function()
    if readfile and isfile and isfile(configPath) then
        local s, data = pcall(function() return HttpService:JSONDecode(readfile(configPath)) end)
        if s and data then
            if data.Hitbox then getgenv().HitboxSize = data.Hitbox end
            if data.Spam then getgenv().SpamText = data.Spam end
            Fluent:Notify({Title="Système", Content="Configuration chargée avec succès !", Duration=2})
        end
    end
end})

-- KEYBINDS
Tabs.Secu:AddSection("Raccourcis Clavier Rapides")
Tabs.Secu:AddKeybind("Key_Noclip", {Title = "Touche NoClip", Mode = "Toggle", Default = "Z", Callback = function(v) getgenv().Toggles.Noc = v end})
Tabs.Secu:AddKeybind("Key_GodMode", {Title = "Touche GodMode", Mode = "Toggle", Default = "G", Callback = function(v) getgenv().Toggles.GodMode = v end})
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

    -- GOD MODE & INTOUCHABLE
    if getgenv().Toggles.GodMode and char:FindFirstChild("Humanoid") then char.Humanoid.Health = char.Humanoid.MaxHealth end
    if getgenv().Toggles.Intouchable then for _, part in pairs(char:GetChildren()) do if part:IsA("BasePart") then part.CanTouch = false end end end

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

    if getgenv().Toggles.Jesus then
        if not char:FindFirstChild("JesusP") then local p = Instance.new("Part", char); p.Name="JesusP"; p.Size=Vector3.new(4,1,4); p.Transparency=1; local w = Instance.new("Weld", p); w.Part0=p; w.Part1=char.HumanoidRootPart; w.C0=CFrame.new(0,3.5,0) end
        if char:FindFirstChild("JesusP") then char.JesusP.CanCollide = true end
    elseif char:FindFirstChild("JesusP") then char.JesusP:Destroy() end

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
Fluent:Notify({Title = "MaXix HuX V15.1", Content = "Ultimate Edition chargée à 100% !", Duration = 5})
