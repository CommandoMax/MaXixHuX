return function(Tab, Fluent)
    local LocalPlayer = game:GetService("Players").LocalPlayer
    local Camera = game:GetService("Workspace").CurrentCamera

    Tab:AddSection("Utilitaires Personnels")
    
    local TPTool = Instance.new("Tool"); TPTool.Name = "Click TP"; TPTool.RequiresHandle = false
    Tab:AddToggle("TPTool", {Title="Equiper Outil Click-to-TP", Default=false}):OnChanged(function(v) TPTool.Parent = v and LocalPlayer.Backpack or nil end)
    TPTool.Activated:Connect(function() 
        local Mouse = LocalPlayer:GetMouse()
        if Mouse.Hit and LocalPlayer.Character then LocalPlayer.Character:PivotTo(CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0))) end 
    end)

    Tab:AddInput("FOV", {Title="Modifier FOV (Champ de vision)", Default="70", Numeric=true, Finished=true, Callback=function(v) Camera.FieldOfView = tonumber(v) end})

    Tab:AddSection("Actions Rapides")
    Tab:AddButton({Title="Se Soigner (Si supporté)", Callback=function() if LocalPlayer.Character then LocalPlayer.Character.Humanoid.Health = LocalPlayer.Character.Humanoid.MaxHealth end end})
    Tab:AddButton({Title="S'asseoir", Callback=function() if LocalPlayer.Character then LocalPlayer.Character.Humanoid.Sit = true end end})
    Tab:AddButton({Title="Se Lever", Callback=function() if LocalPlayer.Character then LocalPlayer.Character.Humanoid.Sit = false; LocalPlayer.Character.Humanoid.PlatformStand = false end end})
    Tab:AddButton({Title="Reset Character (Suicide)", Callback=function() if LocalPlayer.Character then LocalPlayer.Character:BreakJoints() end end})
    
    Tab:AddSection("Informations Techniques")
    Tab:AddButton({Title="Copier Coordonnées (CFrame)", Callback=function() 
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local pos = LocalPlayer.Character.HumanoidRootPart.Position
            setclipboard(tostring(pos))
            Fluent:Notify({Title="Copie", Content="Position copiée dans le presse-papier !", Duration=2})
        end
    end})
    Tab:AddButton({Title="Ouvrir Console Développeur (F9)", Callback=function() game:GetService("StarterGui"):SetCore("DevConsoleVisible", true) end})
end
