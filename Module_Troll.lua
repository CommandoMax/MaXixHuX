return function(Tab, Fluent)
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Camera = game:GetService("Workspace").CurrentCamera
    getgenv().TargetPlayer = nil

    Tab:AddSection("Ciblage Dynamique")
    
    local PlayerDropdown = Tab:AddDropdown("PlayerSelect", {
        Title = "Cible Actuelle", Values = {"Aucun"}, Multi = false, Default = 1, 
        Callback = function(v) getgenv().TargetPlayer = Players:FindFirstChild(v) end
    })

    Tab:AddButton({Title="Rafraîchir la liste des joueurs", Callback=function() 
        local list = {}
        for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(list, p.Name) end end
        if #list == 0 then table.insert(list, "Aucun autre joueur") end
        PlayerDropdown:SetValues(list) 
        Fluent:Notify({Title="Ciblage", Content="Liste mise à jour", Duration=2})
    end})

    Tab:AddSection("Actions sur la Cible")

    Tab:AddButton({Title="Se Téléporter (TP)", Callback=function() 
        if getgenv().TargetPlayer and getgenv().TargetPlayer.Character and getgenv().TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then 
            LocalPlayer.Character.HumanoidRootPart.CFrame = getgenv().TargetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3) 
        end 
    end})
    
    Tab:AddButton({Title="Spectate", Callback=function() 
        if getgenv().TargetPlayer and getgenv().TargetPlayer.Character then Camera.CameraSubject = getgenv().TargetPlayer.Character.Humanoid end 
    end})
    
    Tab:AddButton({Title="Un-Spectate", Callback=function() Camera.CameraSubject = LocalPlayer.Character.Humanoid end})

    Tab:AddToggle("LoopTP", {Title="Loop TP (S'attacher)", Default=false}):OnChanged(function(v) getgenv().Toggles.LoopTP = v end)

    game:GetService("RunService").RenderStepped:Connect(function()
        if getgenv().Toggles.LoopTP and getgenv().TargetPlayer and getgenv().TargetPlayer.Character and getgenv().TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then 
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = getgenv().TargetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2) 
            end
        end
    end)
end
