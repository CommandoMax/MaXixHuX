return function(Tab, Fluent)
    local RunService = game:GetService("RunService")
    local StatsService = game:GetService("Stats")
    local Players = game:GetService("Players")

    Tab:AddSection("Moniteur Système")

    -- On crée un paragraphe qu'on va mettre à jour en temps réel
    local Monitor = Tab:AddParagraph({
        Title = "📡 Statistiques en temps réel",
        Content = "Chargement des données..."
    })

    Tab:AddSection("Informations Serveur")
    Tab:AddParagraph({
        Title = "Détails de l'Instance",
        Content = "Jeu ID : " .. game.PlaceId .. "\n" ..
                  "Job ID : " .. game.JobId .. "\n" ..
                  "Version : " .. game.PlaceVersion
    })

    Tab:AddButton({Title="Copier le Job ID", Callback=function() 
        setclipboard(tostring(game.JobId))
        Fluent:Notify({Title="Stats", Content="Job ID copié !", Duration=2})
    end})

    -- Boucle de mise à jour du FPS et du Ping
    local lastTime = tick()
    local frameCount = 0
    local fps = 0

    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local currentTime = tick()
        if currentTime - lastTime >= 1 then
            fps = frameCount
            frameCount = 0
            lastTime = currentTime
            
            -- Récupération du Ping (Network)
            local ping = 0
            pcall(function() ping = math.floor(StatsService.Network.ServerStatsItem["Data Ping"]:GetValue()) end)

            local playerCount = #Players:GetPlayers()

            Monitor:SetDesc(
                "🟢 FPS : " .. tostring(fps) .. "\n" ..
                "📶 Ping : " .. tostring(ping) .. " ms\n" ..
                "👥 Joueurs : " .. tostring(playerCount) .. " / " .. tostring(Players.MaxPlayers)
            )
        end
    end)
end
