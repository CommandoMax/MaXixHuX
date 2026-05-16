-- ========================================================================
-- MAXIX HUX - CORE SYSTEM v12 (8 Modules)
-- ========================================================================
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

getgenv().Toggles = {}

-- 1. LA BULLE FLOTTANTE 
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

-- 2. CHARGEMENT FLUENT
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local Window = Fluent:CreateWindow({
    Title = "MaXix HuX", SubTitle = "Cloud OS v12", 
    TabWidth = 130, Size = UDim2.fromOffset(580, 400), 
    Acrylic = true, Theme = "Darker", MinimizeKey = Enum.KeyCode.RightControl
})

-- 3. LES 8 ONGLETS (Architecture Complète)
local Tabs = {
    Mouv = Window:AddTab({Title="Mouvements", Icon="user"}),
    Combat = Window:AddTab({Title="Combat", Icon="crosshair"}),
    ESP = Window:AddTab({Title="ESP", Icon="scan"}),
    Troll = Window:AddTab({Title="Troll", Icon="users"}),
    Player = Window:AddTab({Title="Joueur", Icon="user-cog"}),
    Hote = Window:AddTab({Title="Hôte & Map", Icon="globe"}),
    Fun = Window:AddTab({Title="Fun", Icon="smile"}),
    Stats = Window:AddTab({Title="Statistiques", Icon="bar-chart"})
}

-- 4. CHARGEUR DE MODULES
local function LoadModule(fileName, tabRef)
    -- N'OUBLIE PAS DE METTRE TON PSEUDO GITHUB ICI !
    local url = "https://raw.githubusercontent.com/CommandoMax/MaXixHuX/main/" .. fileName
    local success, result = pcall(function() return loadstring(game:HttpGet(url))() end)
    
    if success and type(result) == "function" then
        result(tabRef, Fluent) 
    else
        warn("Échec du chargement : " .. fileName)
    end
end

-- 5. EXÉCUTION DES MODULES
Fluent:Notify({Title = "Cloud Sync", Content = "Démarrage des 8 modules...", Duration = 3})

LoadModule("Module_Mouvements.lua", Tabs.Mouv)
LoadModule("Module_Combat.lua", Tabs.Combat)
LoadModule("Module_ESP.lua", Tabs.ESP)
LoadModule("Module_Troll.lua", Tabs.Troll)
LoadModule("Module_Player.lua", Tabs.Player)
LoadModule("Module_Hote.lua", Tabs.Hote)
LoadModule("Module_Fun.lua", Tabs.Fun)
LoadModule("Module_Stats.lua", Tabs.Stats)

Window:SelectTab(1)
