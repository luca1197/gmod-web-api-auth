GWAA = GWAA or {}
GWAA.ColorPrefix = Color(57, 119, 234)
GWAA.ColorText = Color(230, 230, 230)

function GWAA.PrintToConsole(msg)
	MsgC(GWAA.ColorText, "[", GWAA.ColorPrefix, "gmod-web-api-auth", GWAA.ColorText, "] ", GWAA.ColorText, msg .. "\n")
end

local StartTime = SysTime()
GWAA.PrintToConsole("Loading started!")

function GWAA.LoadDirectory(dir)

	local files, dirs = file.Find(dir .. "*", "LUA")
	for _, fileName in ipairs(files) do
		local isServer = string.StartsWith(fileName, "sv")
		if isServer and not string.EndsWith(fileName, "_nl") then
			GWAA.PrintToConsole("Loading serverside file: " .. dir .. fileName)
			if SERVER then
				include(dir .. fileName)
			end
		end

		local isClient = string.StartsWith(fileName, "cl")
		if isClient and not string.EndsWith(fileName, "_nl") then
			GWAA.PrintToConsole("Loading clientside file: " .. dir .. fileName)
			if SERVER then
				AddCSLuaFile(dir .. fileName)
			end
			if CLIENT then
				include(dir .. fileName)
			end
		end

		if (string.StartsWith(fileName, "config") or string.StartsWith(fileName, "sh")) and not string.EndsWith(fileName, "_nl") then
			GWAA.PrintToConsole("Loading config or shared file: " .. dir .. fileName)
			if SERVER then
				include(dir .. fileName)
				AddCSLuaFile(dir .. fileName)
			end
			if CLIENT then
				include(dir .. fileName)
			end
		end
	end

	for k, v in ipairs(dirs) do
		if string.find(v, "_nl", 1, true) then continue end -- Do not load directories with the _nl (no load) suffix
		GWAA.LoadDirectory(dir .. v .. "/")
	end

end

-- Main directory
GWAA.LoadDirectory("gmod_web_api_auth/")

GWAA.PrintToConsole("Loading finished within " .. math.Round(SysTime() - StartTime, 3) .. " seconds!")