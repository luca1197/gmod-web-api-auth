util.AddNetworkString("GWAA:Ready")

/*
	GWAA.SafeCallback
*/
function GWAA.SafeCallback(callback, ...)
	if isfunction(callback) then
		callback(...)
	end
end

/*
	API key setup
*/
local API_KEY -- Store in localy variable to improve security
if isstring(GWAA.APIKey) then

	if GWAA.APIKey == "data-file" then

		local dataFile = file.Read("gwaa_api_key.txt", "DATA")
		if isstring(dataFile) then
			API_KEY = dataFile
		else
			GWAA.PrintToConsole("GWAA.APIKey is set to data-file, but data/gwaa_api_key.txt does not exist!")
		end
		
	else

		API_KEY = GWAA.APIKey

	end

	GWAA.APIKey = nil

else

	GWAA.PrintToConsole("GWAA.APIKey not set!")

end

/*
	GWAA.GetAPIServerURL
*/
function GWAA.GetAPIServerURL()

	if not isstring(GWAA.APIServerURL) then
		return
	end

	return string.EndsWith(GWAA.APIServerURL, "/") and GWAA.APIServerURL or (GWAA.APIServerURL .. "/")

end

/*
	FetchAPIAuthed
*/
local function FetchAPIAuthed(path, params, onSuccess, onFailure)

	local apiURL = GWAA.GetAPIServerURL()
	if apiURL == "example.com/" then
		return GWAA.PrintToConsole("GWAA.APIServerURL in config is set to example.com. Please replace it with your API server URL!")
	elseif API_KEY == "example-key" then
		return GWAA.PrintToConsole("GWAA.APIKey in config is set to example-key. Please replace it with one of your API keys!")
	end

	local reqURL = apiURL .. path .. "?key=" .. API_KEY

	local paramsString = ""
	for k, v in pairs(params or {}) do
		paramsString = paramsString .. "&" .. k .. "=" .. v
	end

	http.Fetch(reqURL .. paramsString, onSuccess, onFailure)

end

/*
	GWAA.GetAPIStatus
*/
function GWAA.GetAPIStatus(callback)

	FetchAPIAuthed("status", _, function(body, _, _, code)

		if isstring(body) then -- Add API info to callback if it was returned (should always be the case)
			local info = util.JSONToTable(body)
			if istable(info) and info.ok and info.info then
				GWAA.SafeCallback(callback, true, info.info)
				return
			end
		end

		GWAA.SafeCallback(callback, true)

	end, function(err)

		GWAA.SafeCallback(callback, false)

	end)

end

/*
	GWAA.CreatePlayerSession
*/
function GWAA.CreatePlayerSession(ply, callback)

	if not IsValid(ply) then
		GWAA.SafeCallback(callback, false)
		return
	end

	FetchAPIAuthed("auth", {["steamid"] = ply:SteamID64()}, function(body)
		
		if not isstring(body) then
			GWAA.SafeCallback(callback, false)
			return
		end

		local res = util.JSONToTable(body)
		if not istable(res) or not res.ok or not isstring(res.jwt) then
			GWAA.SafeCallback(callback, false)
			return
		end

		GWAA.SafeCallback(callback, true, res.jwt)

	end, function(err)

		GWAA.PrintToConsole("Failed to create player session for " .. ply:Name() .. " (" .. ply:SteamID() .. ")")
		GWAA.SafeCallback(callback, false)

	end)

end

/*
	GWAA:Ready hook
*/
net.Receive("GWAA:Ready", function(_, ply)

	if ply.GWAA_Ready then
		return
	end

	ply.GWAA_Ready = true
	hook.Run("GWAA:Ready", ply)

end)