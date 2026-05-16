return function(Tab, Fluent)
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Camera = game:GetService("Workspace").CurrentCamera
    local Mouse = LocalPlayer:GetMouse()
    local RunService = game:GetService("RunService")

    Tab:AddSection("Assistance Visée")
    Tab:AddToggle("Aimbot", {Title="Aimbot (Cam Lock)", Default=false}):OnChanged(function(v) getgenv().Toggles.Aimbot = v end)
    Tab:AddToggle("Hitbox", {Title="Hitbox Expander (x5)", Default=false}):OnChanged(function(v) getgenv().Toggles.Hitbox = v end)
    
    Tab:AddSection("Zone de Dégâts")
    Tab:AddToggle("AuraFling", {Title="Aura Fling (Tornade Mortelle)", Default=false}):OnChanged(function(v) getgenv().Toggles.AuraFling = v end)

    RunService.RenderStepped:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end

        -- Aimbot Mathématique
        if getgenv().Toggles.Aimbot then
            local closest, maxD = nil, math.huge
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                    local pos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
                    if onScreen then 
                        local dist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                        if dist < maxD then maxD = dist; closest = p end 
                    end
                end
            end
            if closest then Camera.CFrame = CFrame.new(Camera.CFrame.Position, closest.Character.Head.Position) end
        end

        -- Hitbox
        if getgenv().Toggles.Hitbox then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                    p.Character.Head.Size = Vector3.new(5, 5, 5)
                    p.Character.Head.Transparency = 0.5
                    p.Character.Head.CanCollide = false
                end
            end
        end

        -- Aura Fling
        if getgenv().Toggles.AuraFling and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(90), 0)
        end
    end)
end
