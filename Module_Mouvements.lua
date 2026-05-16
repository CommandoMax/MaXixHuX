return function(Tab, Fluent)
    local LocalPlayer = game:GetService("Players").LocalPlayer
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")

    Tab:AddSection("Physique Principale")
    
    Tab:AddInput("WS", {Title="Vitesse Personnalisée", Default="16", Numeric=true, Finished=true, Callback=function(v) LocalPlayer.Character.Humanoid.WalkSpeed = tonumber(v) end})
    Tab:AddInput("JP", {Title="Saut Personnalisé", Default="50", Numeric=true, Finished=true, Callback=function(v) LocalPlayer.Character.Humanoid.JumpPower = tonumber(v) end})
    
    Tab:AddToggle("NC", {Title="NoClip Universel", Default=false}):OnChanged(function(v) getgenv().Toggles.Noc = v end)
    Tab:AddToggle("InfJ", {Title="Saut Infini", Default=false}):OnChanged(function(v) getgenv().Toggles.InfJ = v end)
    Tab:AddToggle("Fly", {Title="Fly Basique", Default=false}):OnChanged(function(v) getgenv().Toggles.Fly = v end)
    Tab:AddToggle("Jesus", {Title="Marcher sur l'eau", Default=false}):OnChanged(function(v) getgenv().Toggles.Jesus = v end)

    -- Boucle locale au module pour le NoClip, Fly, etc.
    RunService.RenderStepped:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end

        if getgenv().Toggles.Noc then 
            for _, p in pairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end 
        end
        if getgenv().Toggles.Fly and char:FindFirstChild("HumanoidRootPart") then 
            char.HumanoidRootPart.Velocity = Vector3.new(0, 50, 0) 
        end
        if getgenv().Toggles.Jesus then
            if not char:FindFirstChild("JesusP") then 
                local p = Instance.new("Part", char); p.Name="JesusP"; p.Size=Vector3.new(4,1,4); p.Transparency=1
                local w = Instance.new("Weld", p); w.Part0=p; w.Part1=char.HumanoidRootPart; w.C0=CFrame.new(0,3.5,0) 
            end
            if char:FindFirstChild("JesusP") then char.JesusP.CanCollide = true end
        else
            if char and char:FindFirstChild("JesusP") then char.JesusP:Destroy() end
        end
    end)

    UserInputService.JumpRequest:Connect(function() 
        if getgenv().Toggles.InfJ and LocalPlayer.Character then LocalPlayer.Character.Humanoid:ChangeState("Jumping") end 
    end)
end
