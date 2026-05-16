return function(Tab, Fluent)
    local Workspace = game:GetService("Workspace")
    local Lighting = game:GetService("Lighting")

    Tab:AddSection("Contrôle de l'Environnement")
    Tab:AddSlider("Time", {Title="Heure du Serveur (Local)", Min=0, Max=24, Default=14, Increment=1, Callback=function(v) Lighting.ClockTime = v end})
    Tab:AddSlider("Gravity", {Title="Gravité", Min=0, Max=500, Default=196.2, Increment=1, Callback=function(v) Workspace.Gravity = v end})

    Tab:AddSection("Exploits de Map")
    Tab:AddButton({Title="Détruire KillBricks (Lave/Acide)", Callback=function() 
        local count = 0
        for _,v in pairs(Workspace:GetDescendants()) do 
            if v:IsA("TouchTransmitter") then v.Parent:Destroy(); count = count + 1 end 
        end
        Fluent:Notify({Title="Map", Content=count.." KillBricks détruits.", Duration=2})
    end})

    Tab:AddButton({Title="Détruire Murs Invisibles", Callback=function() 
        local count = 0
        for _,v in pairs(Workspace:GetDescendants()) do 
            if v:IsA("BasePart") and v.Transparency >= 1 and v.CanCollide and v.Name ~= "HumanoidRootPart" then v:Destroy(); count = count + 1 end 
        end
        Fluent:Notify({Title="Map", Content=count.." Murs invisibles détruits.", Duration=2})
    end})

    Tab:AddButton({Title="Equiper BTools (Détruire Map)", Callback=function() 
        local t = Instance.new("HopperBin"); t.BinType = Enum.BinType.Hammer; t.Parent = game:GetService("Players").LocalPlayer.Backpack 
    end})

    Tab:AddSection("Optimisations (FPS Boost)")
    Tab:AddButton({Title="Supprimer les Textures", Callback=function()
        for _,v in pairs(Workspace:GetDescendants()) do if v:IsA("Texture") or v:IsA("Decal") then v:Destroy() end end
    end})
    Tab:AddButton({Title="Mode Low Poly (Terrain Lisse)", Callback=function()
        sethiddenproperty(Workspace.Terrain, "Decoration", false)
        Workspace.Terrain.WaterWaveSize = 0
        Workspace.Terrain.WaterWaveSpeed = 0
        Workspace.Terrain.WaterReflectance = 0
        Workspace.Terrain.WaterTransparency = 0
    end})
end
