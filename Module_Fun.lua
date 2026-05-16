return function(Tab, Fluent)
    local LocalPlayer = game:GetService("Players").LocalPlayer
    local Chat = game:GetService("Chat")
    local RunService = game:GetService("RunService")

    Tab:AddSection("Animations & Emotes")
    Tab:AddButton({Title="Danse 1", Callback=function() Chat:InvokeServer("/e dance") end})
    Tab:AddButton({Title="Danse 2", Callback=function() Chat:InvokeServer("/e dance2") end})
    Tab:AddButton({Title="Danse 3", Callback=function() Chat:InvokeServer("/e dance3") end})
    Tab:AddButton({Title="Rire", Callback=function() Chat:InvokeServer("/e laugh") end})
    Tab:AddButton({Title="Applaudir", Callback=function() Chat:InvokeServer("/e cheer") end})

    Tab:AddSection("Chat Spammer")
    Tab:AddInput("SpamText", {Title="Texte à spam", Default="MaXix HuX au pouvoir !", Numeric=false, Finished=true, Callback=function(v) getgenv().SpamMsg = v end})
    Tab:AddToggle("Spammer", {Title="Activer Spam", Default=false}):OnChanged(function(v) getgenv().Toggles.Spam = v end)

    task.spawn(function()
        while task.wait(2) do
            if getgenv().Toggles.Spam and getgenv().SpamMsg then
                -- Compatible avec le vieux chat et le nouveau TextChatService
                pcall(function() game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(getgenv().SpamMsg, "All") end)
                pcall(function() game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync(getgenv().SpamMsg) end)
            end
        end
    end)

    Tab:AddSection("Modifications Visuelles (Local)")
    Tab:AddButton({Title="Devenir Chauve (Enlever Cheveux/Chapeaux)", Callback=function() 
        if LocalPlayer.Character then
            for _,v in pairs(LocalPlayer.Character:GetDescendants()) do 
                if v:IsA("Accessory") then v:Destroy() end 
            end
        end
    end})
end
