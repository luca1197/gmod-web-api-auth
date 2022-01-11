/*
	GWAA:Ready hook
*/
hook.Add("InitPostEntity", "GWAA:Ready", function()

	net.Start("GWAA:Ready")
	net.SendToServer()
	hook.Run("GWAA:Ready", LocalPlayer())
	hook.Remove("InitPostEntity", "GWAA:Ready")

end)

/*
	Authentication
*/
net.Receive("GWAA:Auth", function()

	local jwt = net.ReadString()
	if not isstring(jwt) or #jwt < 8 then return end

	if GWAA._Session_JWT == nil then
		hook.Run("GWAA:InitialAuthenticated", jwt)
	end

	hook.Run("GWAA:Authenticated", jwt)

	GWAA._Session_JWT = jwt

	GWAA.PrintToConsole("Received session")

end)

/*
	GWAA.GetSession
*/
function GWAA.GetSession()

	return GWAA._Session_JWT

end