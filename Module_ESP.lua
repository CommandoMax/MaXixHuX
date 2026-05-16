return function(Tab, Fluent)
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local RunService = game:GetService("RunService")

    Tab:AddSection("Extra Sensory Perception")
    Tab:AddToggle("EspBox", {Title="ESP Boxes (Chams)", Default=false}):OnChanged(function(v) getgenv().Toggles.EspBox = v end)
    Tab:AddToggle("EspName", {Title="ESP Noms", Default=false}):OnChanged(function(v) getgenv().Toggles.EspName = v end)

    Tab:AddSection("Filtres Environnement")
    Tab:AddToggle("Fullbright", {Title="Vision Nocturne", Default=false}):OnChanged(function(v) 
        game:GetService("Lighting").GlobalShadows = not v 
        game:GetService("Lighting").Brightness = v and 3 or 1 
    end)
    Tab:AddToggle("Xray", {Title="X-Ray (Murs transparents)", Default=false}):OnChanged(function(v) 
        for _,p in pairs(game:GetService("Workspace"):GetDescendants()) do 
            if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.LocalTransparencyModifier = v and 0.5 or 0 end 
        end 
    end)

    RunService.RenderStepped:Connect(function()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                -- Chams
                if getgenv().Toggles.EspBox and not p.Character:FindFirstChild("MaXixCham") then 
                    local hl = Instance.new("Highlight", p.Character); hl.Name = "MaXixCham"; hl.FillColor = Color3.fromRGB(255, 0, 0); hl.FillTransparency = 0.5
                elseif not getgenv().Toggles.EspBox and p.Character:FindFirstChild("MaXixCham") then 
                    p.Character.MaXixCham:Destroy() 
                end
                
                -- Names
                if getgenv().Toggles.EspName and p.Character:FindFirstChild("Head") and not p.Character.Head:FindFirstChild("MaXixName") then
                    local bgui = Instance.new("BillboardGui", p.Character.Head); bgui.Name = "MaXixName"; bgui.Size = UDim2.new(0, 100, 0, 40); bgui.AlwaysOnTop = true
                    local text = Instance.new("TextLabel", bgui); text.Size = UDim2.new(1,0,1,0); text.BackgroundTransparency = 1; text.TextColor3 = Color3.fromRGB(255, 255, 255); text.Text = p.Name
                elseif not getgenv().Toggles.EspName and p.Character:FindFirstChild("Head") and p.Character.Head:FindFirstChild("MaXixName") then
                    p.Character.Head.MaXixName:Destroy()
                end
            end
        end
    end)
end
