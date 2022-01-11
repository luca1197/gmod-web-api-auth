util.AddNetworkString("GWAA:Auth")

/*
	Check if API is available
*/
hook.Add("InitPostEntity", "GWAA:CheckAPIServer", function()

	GWAA.GetAPIStatus(function(available, info)
		GWAA.PrintToConsole(available and "API is available" or "API is NOT available")

		if istable(info) then
			GWAA.APIInfo = info
		end
	end)

	hook.Remove("InitPostEntity", "GWAA:CheckAPIServer")

end)

/*
	Auth user on GWAA:Ready
*/
function GWAA.AuthPlayer(ply)

	if not IsValid(ply) or not ply.GWAA_Ready then return end

	GWAA.CreatePlayerSession(ply, function(success, jwt)
		
		if not success or not isstring(jwt) then
			GWAA.PrintToConsole("Failed to authenticate " .. ply:Name() .. " (" .. ply:SteamID() .. ")")
			return
		end

		local jwtExpiration = 60 * 30 -- Fallback value
		if GWAA.APIInfo and isnumber(GWAA.APIInfo["jwt_expiration"]) then
			jwtExpiration = GWAA.APIInfo["jwt_expiration"] - 60 -- Re-auth users a bit earlier so that they will always have a valid session
		end

		ply.GWAA_Expiration = CurTime() + jwtExpiration
		
		net.Start("GWAA:Auth")
		net.WriteString(jwt)
		net.Send(ply)
	
	end)

end

hook.Add("GWAA:Ready", "GWAA:AuthOnReady", function(ply)

	GWAA.PrintToConsole("Authenticating " .. ply:Name() .. " (" .. ply:SteamID() .. ")")
	GWAA.AuthPlayer(ply)

end)

/*
	Re-auth player if JWT is about to expire
*/
timer.Create("GWAA:AuthRefresh", 15, 0, function()

	for _, v in ipairs(player.GetHumans()) do
		
		if not v.GWAA_Ready or not isnumber(v.GWAA_Expiration) then continue end

		if CurTime() > v.GWAA_Expiration then
			GWAA.AuthPlayer(v)
		end

	end

end)