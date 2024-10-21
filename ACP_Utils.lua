ac.log('Script: Utils')
local sim = ac.getSim()
local car = ac.getCar(0) or error()
if not car then return end
local wheels = car.wheels or error()
local uiState = ac.getUI()

local chat = require('shared/sim/chat')
local virtualizing = require('shared/ui/virtualizing')

ui.setAsynchronousImagesLoading(true)

local localTesting = ac.dirname() == 'C:\\Program Files (x86)\\Steam\\steamapps\\common\\assettocorsa\\extension\\lua\\online'
local initialisation = true

-- Constants --
local STEAMID = const(ac.getUserSteamID())
local CSP_VERSION = const(ac.getPatchVersionCode())
local CSP_MIN_VERSION = const(3044)
local CAR_ID = const(ac.getCarID(0))
local CAR_NAME = const(ac.getCarName(0))
local DRIVER_NAME = const(ac.getDriverName(0))
local vUp = const(vec3(0, 1, 0))
local vDown = const(vec3(0, -1, 0))

local SHARED_PLAYER_DATA = const('__ACP_SHARED_PLAYER_DATA')
local SHARED_EVENT_KEY = const('__ACP_PLAYER_SHARED_UPDATE')

if CSP_VERSION < CSP_MIN_VERSION then return end

local WINDOW_WIDTH = const(sim.windowWidth / uiState.uiScale)
local WINDOW_HEIGHT = const(sim.windowHeight / uiState.uiScale)
local FONT_MULT = const(WINDOW_HEIGHT / 1440)

local WIDTH_DIV = const({
	_2 = WINDOW_WIDTH / 2,
	_3 = WINDOW_WIDTH / 3,
	_4 = WINDOW_WIDTH / 4,
	_5 = WINDOW_WIDTH / 5,
	_6 = WINDOW_WIDTH / 6,
	_9 = WINDOW_WIDTH / 9,
	_10 = WINDOW_WIDTH / 10,
	_12 = WINDOW_WIDTH / 12,
	_15 = WINDOW_WIDTH / 15,
	_20 = WINDOW_WIDTH / 20,
	_25 = WINDOW_WIDTH / 25,
	_32 = WINDOW_WIDTH / 32,
	_40 = WINDOW_WIDTH / 40,
	_50 = WINDOW_WIDTH / 50,
	_100 = WINDOW_WIDTH / 100,
})

local HEIGHT_DIV = const({
	_2 = WINDOW_HEIGHT / 2,
	_3 = WINDOW_HEIGHT / 3,
	_4 = WINDOW_HEIGHT / 4,
	_12 = WINDOW_HEIGHT / 12,
	_14 = WINDOW_HEIGHT / 14,
	_20 = WINDOW_HEIGHT / 20,
	_24 = WINDOW_HEIGHT / 24,
	_25 = WINDOW_HEIGHT / 25,
	_40 = WINDOW_HEIGHT / 40,
	_50 = WINDOW_HEIGHT / 50,
	_60 = WINDOW_HEIGHT / 60,
	_70 = WINDOW_HEIGHT / 70,
	_80 = WINDOW_HEIGHT / 80,
})


---@param time number
---@return string
local function formatTime(time)
	local minutes = math.floor(time / 60)
	local seconds = math.floor(time % 60)
	local milliseconds = math.floor((time % 1) * 1000)
	return ('%02d:%02d.%03d'):format(minutes, seconds, milliseconds)
end

---@param carID string
local function isPoliceCar(carID)
	for _, carName in ipairs(POLICE_CAR) do
		if carID == carName then
			return true
		end
	end
	return false
end

---@param key string
local function removeUtf8Char(key)
	local newKey = ''
	for i = 1, #key do
		local c = key:sub(i, i)
		if c:byte() < 128 then
			newKey = newKey .. c
		end
	end
	newKey = newKey:match('^%s*(.-)%s*$')
	return newKey
end

---@param number number
---@param decimal integer
---@return number
local function truncate(number, decimal)
	local power = 10 ^ decimal
	return math.floor(number * power) / power
end

local playerData = {
	hudColor = rgbm.colors.red,
	name = '',
	sectors = {},
	arrests = '0',
	getaways = '0',
	thefts = '0',
	overtake = '0',
	wins = '0',
	losses = '0',
	elo = '0',
}

local sharedPlayerLayout = {
	ac.StructItem.key(SHARED_PLAYER_DATA),
	hudColor = ac.StructItem.rgbm(),
	name = ac.StructItem.string(24),
	sectorsFormated = ac.StructItem.array(ac.StructItem.struct({
		name = ac.StructItem.string(16),
		records = ac.StructItem.array(ac.StructItem.string(32), 10)
	}), 5),
	arrests = ac.StructItem.int16(),
	getaways = ac.StructItem.int16(),
	thefts = ac.StructItem.int16(),
	overtake = ac.StructItem.int16(),
	wins = ac.StructItem.int16(),
	losses = ac.StructItem.int16(),
	elo = ac.StructItem.int16(),
}

local sharedPlayerData = ac.connect(sharedPlayerLayout, true, ac.SharedNamespace.ServerScript)

local function playerScores()
	ui.newLine()
	ui.dwriteTextWrapped("Scores: ", 30, rgbm.colors.yellow)
	ui.separator()
	ui.newLine()
	ui.sameLine(WIDTH_DIV._100)
	ui.beginGroup()
	ui.dwriteTextWrapped("Arrests: ", 20, playerData.hudColor)
	ui.sameLine(WIDTH_DIV._10)
	ui.dwriteTextWrapped(playerData.arrests, 20, rgbm.colors.white)
	ui.dwriteTextWrapped("Getaways: ", 20, playerData.hudColor)
	ui.sameLine(WIDTH_DIV._10)
	ui.dwriteTextWrapped(playerData.getaways, 20, rgbm.colors.white)
	ui.dwriteTextWrapped("Thefts: ", 20, playerData.hudColor)
	ui.sameLine(WIDTH_DIV._10)
	ui.dwriteTextWrapped(playerData.thefts, 20, rgbm.colors.white)
	ui.dwriteTextWrapped("Overtake: ", 20, playerData.hudColor)
	ui.sameLine(WIDTH_DIV._10)
	ui.dwriteTextWrapped(playerData.overtake, 20, rgbm.colors.white)
	ui.dwriteTextWrapped("Wins: ", 20, playerData.hudColor)
	ui.sameLine(WIDTH_DIV._10)
	ui.dwriteTextWrapped(playerData.wins, 20, rgbm.colors.white)
	ui.dwriteTextWrapped("Losses: ", 20, playerData.hudColor)
	ui.sameLine(WIDTH_DIV._10)
	ui.dwriteTextWrapped(playerData.losses, 20, rgbm.colors.white)
	ui.dwriteTextWrapped("Racing Elo: ", 20, playerData.hudColor)
	ui.sameLine(WIDTH_DIV._10)
	ui.dwriteTextWrapped(playerData.elo, 20, rgbm.colors.white)
	ui.endGroup()
end

local function playerTimes()
	ui.newLine()
	ui.dwriteTextWrapped("Sectors: ", 30, rgbm.colors.yellow)
	ui.separator()
	ui.newLine()
	ui.sameLine(WIDTH_DIV._100)
	ui.beginGroup()

	for sectorName, record in pairs(playerData.sectors) do
		ui.dwriteTextWrapped(sectorName .. ": ", 20, rgbm.colors.yellow)
		ui.beginSubgroup(WIDTH_DIV._50)
		for k, v in pairs(record) do
			ui.dwriteTextWrapped(k .. ": ", 20, playerData.hudColor)
			ui.sameLine(WIDTH_DIV._10)
			ui.dwriteTextWrapped(v, 20, rgbm.colors.white)
		end
		ui.endSubgroup()
		ui.newLine()
	end
	ui.endGroup()
end

local playerStatsWindow = {
	visible = false,
	pos = vec2(WIDTH_DIV._2 - WIDTH_DIV._100, HEIGHT_DIV._25),
	size = vec2(WIDTH_DIV._2, HEIGHT_DIV._2),
}

local playerStatsSubWindow = {
	visible = false,
	size = vec2(WIDTH_DIV._4, HEIGHT_DIV._2),
}

local function playerStats()
	ui.pushDWriteFont("Orbitron;Weight=Black")
	ui.childWindow('playerTimes', playerStatsSubWindow.size, true, function()
		playerTimes()
	end)
	ui.sameLine()
	ui.childWindow('playerScores', playerStatsSubWindow.size, true, function()
		playerScores()
	end)
	ui.popDWriteFont()
end

ui.onExclusiveHUD(function(mode)
	if mode == 'game' then
		ui.text('Hello, world!')
	elseif mode == 'menu' then
		ui.toolWindow('PlayerStats', playerStatsWindow.pos, playerStatsWindow.size, false, true, function()
			playerStats()
		end)
	end
end)

local function resetPlayerData()
	playerData = {
		hudColor = rgbm.colors.red,
		name = '',
		sectors = {},
		arrests = '0',
		getaways = '0',
		thefts = '0',
		overtake = '0',
		wins = '0',
		losses = '0',
		elo = '0',
	}
end

local function updatedSharedData()
	resetPlayerData()
	if sharedPlayerData.name ~= '' then
		playerData.hudColor = sharedPlayerData.hudColor
		playerData.name = sharedPlayerData.name
		playerData.arrests = tostring(sharedPlayerData.arrests)
		playerData.getaways = tostring(sharedPlayerData.getaways)
		playerData.thefts = tostring(sharedPlayerData.thefts)
		playerData.overtake = tostring(sharedPlayerData.overtake)
		playerData.wins = tostring(sharedPlayerData.wins)
		playerData.losses = tostring(sharedPlayerData.losses)
		playerData.elo = tostring(sharedPlayerData.elo)
		for i = 1, 5 do
			local sectorName = ffi.string(sharedPlayerData.sectorsFormated[i].name)
			ac.log(sectorName)
			if sectorName ~= '' then
				for j = 1, 11 do
					local record = ffi.string(sharedPlayerData.sectorsFormated[i].records[j])
					ac.log(record)
					if record ~= '' then
						local recordInfo = string.split(record, ' - ')
						if #recordInfo == 2 then
							if not playerData.sectors[sectorName] then
								playerData.sectors[sectorName] = {}
							end
							playerData.sectors[sectorName][recordInfo[1]] = recordInfo[2]
						end
					end
				end
			end
		end
	end
end

ac.onSharedEvent(SHARED_EVENT_KEY, function(data)
	if data == 'update' then
		ac.log('Shared Data Updated')
		updatedSharedData()
	end
end, true)

-- ui.registerOnlineExtra(ui.Icons.Menu, "Menu", nil, menu, nil, ui.OnlineExtraFlags.Tool, 'ui.WindowFlags.AlwaysAutoResize')

--------------------------------------------------------------- AC Callbacks --------------------------------------------------------------
-- ac.onCarJumped(0, function(carIndex)

-- end)

-- ac.onClientConnected(function(carIndex)

-- end)

-- ac.onClientDisconnected(function(carIndex)

-- end)

-- ac.onChatMessage(function(message, senderCarIndex, senderSessionID)

-- end)
