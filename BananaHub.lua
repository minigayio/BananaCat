local UniverseID = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://apis.roblox.com/universes/v1/places/"..game.PlaceId.."/universe")).universeId
if game.PlaceId == 1537690962 or game.PlaceId == 4079902982 then
    if getgenv().betabss then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/hlamx/huhu/master/bssrewrite-obfuscated.lua"))()
elseif game.PlaceId == 7449423635 or game.PlaceId == 2753915549 or game.PlaceId == 4442272183 or game.PlaceId == 122478697296975 or UniverseID == 994732206 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/minigayio/BananaCat/refs/heads/main/BF-BananaCat.lua"))()
elseif UniverseID == 7709344486 then 
    loadstring(game:HttpGet("https://raw.githubusercontent.com/minigayio/BananaCat/refs/heads/main/BananaCat-Brainrot.lua"))()
    end
