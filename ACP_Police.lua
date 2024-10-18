local sim = ac.getSim()
local car = ac.getCar(0) or error()
if not car then return end

local wheels = car.wheels or error()
local uiState = ac.getUI()
ui.setAsynchronousImagesLoading(true)

local localTesting = ac.dirname() == 'C:\\Program Files (x86)\\Steam\\steamapps\\common\\assettocorsa\\extension\\lua\\online'
local initialisation = true

-- Constants --
local STEAMID = const(ac.getUserSteamID())
local CSP_VERSION = const(ac.getPatchVersionCode())
local CSP_MIN_VERSION = const(3116)
local CAR_ID = const(ac.getCarID(0))
local CAR_NAME = const(ac.getCarName(0))
local POLICE_CAR = { "chargerpolice_acpursuit", "crown_police" }
if localTesting then
	POLICE_CAR = { "ks_porsche_911_gt3_r_2016" }
end
local DRIVER_NAME = const(ac.getDriverName(0))
---@param carID string
local function isPoliceCar(carID)
	for _, carName in ipairs(POLICE_CAR) do
		if carID == carName then
			return true
		end
	end
	return false
end
ac.log('Police Car:', isPoliceCar(CAR_ID))
if CSP_VERSION < CSP_MIN_VERSION or not isPoliceCar(CAR_ID) then return end

local DRIVER_NATION_CODE = const(ac.getDriverNationCode(0))
local UNIT = "km/h"
local UNIT_MULT = 1
if DRIVER_NATION_CODE == "USA" or DRIVER_NATION_CODE == "GBR" then
	UNIT = "mph"
	UNIT_MULT = 0.621371
end

-- URL --
local FIREBASE_URL = const('https://acp-server-97674-default-rtdb.firebaseio.com/')

-- UI --
local WINDOW_WIDTH = const(sim.windowWidth / uiState.uiScale)
local WIDTH_DIV = const({
	_2 = WINDOW_WIDTH / 2,
	_3 = WINDOW_WIDTH / 3,
	_4 = WINDOW_WIDTH / 4,
	_5 = WINDOW_WIDTH / 5,
	_6 = WINDOW_WIDTH / 6,
	_10 = WINDOW_WIDTH / 10,
	_12 = WINDOW_WIDTH / 12,
	_15 = WINDOW_WIDTH / 15,
	_20 = WINDOW_WIDTH / 20,
	_25 = WINDOW_WIDTH / 25,
	_32 = WINDOW_WIDTH / 32,
})

local WINDOW_HEIGHT = const(sim.windowHeight / uiState.uiScale)
local HEIGHT_DIV = const({
	_2 = WINDOW_HEIGHT / 2,
	_3 = WINDOW_HEIGHT / 3,
	_4 = WINDOW_HEIGHT / 4,
	_12 = WINDOW_HEIGHT / 12,
	_20 = WINDOW_HEIGHT / 20,
	_40 = WINDOW_HEIGHT / 40,
	_50 = WINDOW_HEIGHT / 50,
	_60 = WINDOW_HEIGHT / 60,
	_70 = WINDOW_HEIGHT / 70,
	_80 = WINDOW_HEIGHT / 80,
})

local FONT_MULT = const(WINDOW_HEIGHT / 1440)

local HUD_IMG = const({
	base = "https://i.postimg.cc/h4sPMmvp/hudBase.png",
	arrest = "https://i.postimg.cc/DwJv2YgM/icon-Arrest.png",
	cams = "https://i.postimg.cc/15zRdzNP/iconCams.png",
	logs = "https://i.postimg.cc/VNXztr29/iconLogs.png",
	lost = "https://i.postimg.cc/DyYf3KqG/iconLost.png",
	menu = "https://i.postimg.cc/SxByj71N/iconMenu.png",
	radar = "https://i.postimg.cc/4dZsQ4TD/icon-Radar.png",
})

local CAMERAS = const({
	{
		name = "BOBs SCRAPYARD",
		pos = vec3(-3564, 31.5, -103),
		dir = -8,
		fov = 60,
	},
	{
		name = "ARENA",
		pos = vec3(-2283, 115.5, 3284),
		dir = 128,
		fov = 70,
	},
	{
		name = "BANK",
		pos = vec3(-716, 151, 3556.4),
		dir = 12,
		fov = 95,
	},
	{
		name = "STREET RUNNERS",
		pos = vec3(-57.3, 103.5, 2935.5),
		dir = 16,
		fov = 67,
	},
	{
		name = "ROAD CRIMINALS",
		pos = vec3(-2332, 101.1, 3119.2),
		dir = 121,
		fov = 60,
	},
	{
		name = "RECKLESS RENEGADES",
		pos = vec3(-2993.7, -24.4, -601.7),
		dir = -64,
		fov = 60,
	},
	{
		name = "MOTION MASTERS",
		pos = vec3(-2120.4, -11.8, -1911.5),
		dir = 102,
		fov = 60,
	},
})

local MSG_ARREST = const({
	"`NAME` has been arrested for Speeding. The individual was driving a `CAR`.",
	"We have apprehended `NAME` for Speeding. The suspect was behind the wheel of a `CAR`.",
	"The driver of a `CAR`, identified as `NAME`, has been arrested for Speeding.",
	"`NAME` has been taken into custody for Illegal Racing. The suspect was driving a `CAR`.",
	"We have successfully apprehended `NAME` for Illegal Racing. The individual was operating a `CAR`.",
	"The driver of a `CAR`, identified as `NAME`, has been arrested for Illegal Racing.",
	"`NAME` has been apprehended for Speeding. The suspect was operating a `CAR` at the time of the arrest.",
	"We have successfully detained `NAME` for Illegal Racing. The individual was driving a `CAR`.",
	"`NAME` driving a `CAR` has been arrested for Speeding",
	"`NAME` driving a `CAR` has been arrested for Illegal Racing."
})

local MSG_LOST = const({
	"We've lost sight of the suspect. The vehicle involved is described as a `CAR` driven by `NAME`.",
	"Attention all units, we have lost visual contact with the suspect. The vehicle involved is a `CAR` driven by `NAME`.",
	"We have temporarily lost track of the suspect. The vehicle description is a `CAR` with `NAME` as the driver.",
	"Visual contact with the suspect has been lost. The suspect is driving a `CAR` and identified as `NAME`.",
	"We have lost the suspect's visual trail. The vehicle in question is described as a `CAR` driven by `NAME`.",
	"Suspect have been lost, Vehicle Description:`CAR` driven by `NAME`",
	"Visual contact with the suspect has been lost. The suspect is driving a `CAR` and identified as `NAME`.",
	"We have lost the suspect's visual trail. The vehicle in question is described as a `CAR` driven by `NAME`.",
})

local MSG_ENGAGE = const({
	"Control! I am engaging on a `CAR` traveling at `SPEED`",
	"Pursuit in progress! I am chasing a `CAR` exceeding `SPEED`",
	"Control, be advised! Pursuit is active on a `CAR` driving over `SPEED`",
	"Attention! Pursuit initiated! Im following a `CAR` going above `SPEED`",
	"Pursuit engaged! `CAR` driving at a high rate of speed over `SPEED`",
	"Attention all units, we have a pursuit in progress! Suspect driving a `CAR` exceeding `SPEED`",
	"Attention units! We have a suspect fleeing in a `CAR` at high speed, pursuing now at `SPEED`",
	"Engaging on a high-speed chase! Suspect driving a `CAR` exceeding `SPEED`!",
	"Attention all units! we have a pursuit in progress! Suspect driving a `CAR` exceeding `SPEED`",
	"High-speed chase underway, suspect driving `CAR` over `SPEED`",
	"Control, `CAR` exceeding `SPEED`, pursuit active.",
	"Engaging on a `CAR` exceeding `SPEED`, pursuit initiated."
})

local dataLoaded = {}
dataLoaded['Settings'] = false
dataLoaded['PlayerData'] = false

--------- Utils ------------
---@param keys string[]
---@param t table
local function hasKeys(keys, t)
	for i = 1, #keys do
		if not t[keys[i]] then
			ac.error('Missing key:', keys[i])
			return false
		end
	end
	return true
end

---@param number number
---@param decimal integer
---@return number
local function truncate(number, decimal)
	local power = 10 ^ decimal
	return math.floor(number * power) / power
end


---@param t table
local function tableToVec3(t)
	return vec3(t[1], t[2], t[3])
end

---@param t table
local function tableToVec2(t)
	return vec2(t[1], t[2])
end

---@param t table
local function tableToRGBM(t)
	return rgbm(t[1], t[2], t[3], t[4])
end

---@param err string
---@param response WebResponse
---@return boolean
local function canProcessRequest(err, response)
	if err then
		ac.error('Failed to process request:', err)
		return false
	end
	return response.status == 200 and response.body ~= ''
end

---@param response WebResponse
---@return boolean
local function hasExistingData(response)
	return response.status == 200 and response.body ~= 'null'
end

---@param v vec3
---@return vec3
local function snapToTrack(v)
	if physics.raycastTrack(v, vDown, 20, v) == -1 then
		physics.raycastTrack(v, vUp, 20, v)
	end
	return v
end
local DEFAULT_SETTINGS = const({
	essentialSize = 20,
	policeSize = 20,
	hudOffset = vec2(0, 0),
	fontSize = 20,
	current = 1,
	colorHud = rgbm(1, 0, 0, 1),
	timeMsg = 10,
	msgOffset = vec2(WIDTH_DIV._2, 10),
	fontSizeMSG = 30,
	menuPos = vec2(0, 0),
	unit = UNIT,
	unitMult = UNIT_MULT,
	starsSize = 20,
	starsPos = vec2(WINDOW_WIDTH, 0),
})

---@class Settings
---@field essentialSize number
---@field policeSize number
---@field hudOffset vec2
---@field fontSize number
---@field current number
---@field colorHud rgbm
---@field timeMsg number
---@field msgOffset vec2
---@field fontSizeMSG number
---@field menuPos vec2
---@field unit string
---@field unitMult number
---@field starsSize number
---@field starsPos vec2
local Settings = class('Settings')

---@return Settings
function Settings.new()
	local settings = table.clone(DEFAULT_SETTINGS, true)
	setmetatable(settings, { __index = Settings })
	return settings
end

---@param data table
---@return Settings
function Settings.tryParse(data)
	local hudOffset = data.hudOffset and tableToVec2(data.hudOffset) or vec2(0, 0)
	local colorHud = data.colorHud and tableToRGBM(data.colorHud) or rgbm(1, 0, 0, 1)
	local msgOffset = data.msgOffset and tableToVec2(data.msgOffset) or vec2(WIDTH_DIV._2, 10)
	local menuPos = data.menuPos and tableToVec2(data.menuPos) or vec2(0, 0)
	local starsPos = data.starsPos and tableToVec2(data.starsPos) or vec2(WINDOW_WIDTH, 0)
	local settings = {
		essentialSize = data.essentialSize or 20,
		policeSize = data.policeSize or 20,
		hudOffset = hudOffset,
		fontSize = data.fontSize or 20,
		current = data.current or 1,
		colorHud = colorHud,
		timeMsg = data.timeMsg or 10,
		msgOffset = msgOffset,
		fontSizeMSG = data.fontSizeMSG or 30,
		menuPos = menuPos,
		unit = data.unit or UNIT,
		unitMult = data.unitMult or UNIT_MULT,
		starsSize = data.starsSize or 20,
		starsPos = starsPos,
	}
	setmetatable(settings, { __index = Settings })
	return settings
end

---@param url string
---@param callback function
function Settings.fetch(url, callback)
	if localTesting then
		local currentPath = ac.getFolder(ac.FolderID.ScriptOrigin)
		local file = io.open(currentPath .. '/response/settingsResponse.json', 'r')
		if not file then
			ac.error('Failed to open response.json')
			callback(Settings.new())
			return
		end
		local data = JSON.parse(file:read('*a'))
		file:close()
		local settings = Settings.tryParse(data)
		callback(settings)
	else
		web.get(url, function(err, response)
			if canProcessRequest(err, response) then
				if hasExistingData(response) then
					local data = JSON.parse(response.body)
					if data then
						local settings = Settings.tryParse(data)
						callback(settings)
					else
						ac.error('Failed to parse settings data.')
						callback(Settings.new())
					end
				else
					callback(Settings.new())
				end
			else
				ac.error('Failed to fetch settings:', err)
				callback(Settings.new())
			end
		end)
	end
end

---@param callback function
function Settings.allocate(callback)
	local url = FIREBASE_URL .. 'Settings/' .. STEAMID .. '.json'
	ac.log('Loading settings')
	Settings.fetch(url, function(settings)
		callback(settings)
	end)
end

---@return table
function Settings:export()
	local data = {}
	if self.essentialSize ~= DEFAULT_SETTINGS.essentialSize then
		data.essentialSize = self.essentialSize
	end
	if self.policeSize ~= DEFAULT_SETTINGS.policeSize then
		data.policeSize = self.policeSize
	end
	if self.hudOffset ~= DEFAULT_SETTINGS.hudOffset then
		data.hudOffset = { self.hudOffset.x, self.hudOffset.y }
	end
	if self.fontSize ~= DEFAULT_SETTINGS.fontSize then
		data.fontSize = self.fontSize
	end
	if self.current ~= DEFAULT_SETTINGS.current then
		data.current = self.current
	end
	if self.colorHud ~= DEFAULT_SETTINGS.colorHud then
		data.colorHud = { self.colorHud.r, self.colorHud.g, self.colorHud.b, self.colorHud.mult }
	end
	if self.timeMsg ~= DEFAULT_SETTINGS.timeMsg then
		data.timeMsg = self.timeMsg
	end
	if self.msgOffset ~= DEFAULT_SETTINGS.msgOffset then
		data.msgOffset = { self.msgOffset.x, self.msgOffset.y }
	end
	if self.fontSizeMSG ~= DEFAULT_SETTINGS.fontSizeMSG then
		data.fontSizeMSG = self.fontSizeMSG
	end
	if self.menuPos ~= DEFAULT_SETTINGS.menuPos then
		data.menuPos = { self.menuPos.x, self.menuPos.y }
	end
	if self.unit ~= DEFAULT_SETTINGS.unit then
		data.unit = self.unit
	end
	if self.unitMult ~= DEFAULT_SETTINGS.unitMult then
		data.unitMult = self.unitMult
	end
	if self.starsSize ~= DEFAULT_SETTINGS.starsSize then
		data.starsSize = self.starsSize
	end
	if self.starsPos ~= DEFAULT_SETTINGS.starsPos then
		data.starsPos = { self.starsPos.x, self.starsPos.y }
	end
	return data
end

function Settings:save()
	if localTesting then return end
	local str = '{"' .. STEAMID .. '": ' .. JSON.stringify(self:export()) .. '}'
	web.request('PATCH', FIREBASE_URL .. "Settings.json", str, function(err, response)
		if err then
			ac.error(err)
			return
		end
	end)
end

---@class Player
---@field name string
---@field arrests integer
---@field getaways integer
---@field thefts integer
---@field overtake integer
---@field wins integer
---@field losses integer
local Player = class('Player')

---@return Player
function Player.new()
	local player = {
		name = DRIVER_NAME,
		arrests = 0,
		getaways = 0,
		thefts = 0,
		overtake = 0,
		wins = 0,
		losses = 0,
	}
	setmetatable(player, { __index = Player })
	return player
end

---@param data table
---@return Player
function Player.tryParse(data)
	if not data then
		return Player.new()
	end
	local player = {
		name = DRIVER_NAME,
		arrests = data.arrests or 0,
		getaways = data.getaways or 0,
		thefts = data.thefts or 0,
		overtake = data.overtake or 0,
		wins = data.wins or 0,
		losses = data.losses or 0,
	}
	setmetatable(player, { __index = Player })
	return player
end

---@param url string
---@param callback function
function Player.fetch(url, callback)
	if localTesting then
		local currentPath = ac.getFolder(ac.FolderID.ScriptOrigin)
		local file = io.open(currentPath .. '/response/playerResponse.json', 'r')
		if not file then
			ac.error('Failed to open playerResponse.json')
			callback(Player.new())
			return
		end
		local data = JSON.parse(file:read('*a'))
		file:close()
		local player = Player.tryParse(data)
		callback(player)
		ac.log('Loaded From File')
	else
		web.get(url, function(err, response)
			if canProcessRequest(err, response) then
				if hasExistingData(response) then
					local data = JSON.parse(response.body)
					if data then
						local player = Player.tryParse(data)
						callback(player)
					else
						ac.error('Failed to parse player data.')
						callback(Player.new())
					end
				else
					callback(Player.new())
				end
			else
				ac.error('Failed to fetch player:', err)
				callback(Player.new())
			end
		end)
	end
end

---@param callback function
function Player.allocate(callback)
	local url = FIREBASE_URL .. 'Players/' .. STEAMID .. '.json'
	Player.fetch(url, function(player)
		callback(player)
	end)
end

---@return table
function Player:export()
	local data = { name = self.name }

	if self.arrests > 0 then
		data.arrests = self.arrests
	end
	if self.getaways > 0 then
		data.getaways = self.getaways
	end
	if self.thefts > 0 then
		data.thefts = self.thefts
	end
	if self.overtake > 0 then
		data.overtake = self.overtake
	end
	if self.wins > 0 then
		data.wins = self.wins
	end
	if self.losses > 0 then
		data.losses = self.losses
	end
	return data
end

function Player:save()
	if localTesting then return end
	local str = '{"' .. STEAMID .. '": ' .. JSON.stringify(self:export()) .. '}'
	web.request('PATCH', FIREBASE_URL .. "Players.json", str, function(err, response)
		if err then
			ac.error(err)
			return
		end
	end)
end

---@type Player | nil
local player = nil

---@type Settings | nil
local settings = nil

local canRun = false
local function shouldRun()
	if canRun then return true end
	local isDataLoaded = dataLoaded['Settings'] and dataLoaded['PlayerData']
	local hasNecessaryData = settings and player
	local hasMinVersion = CSP_VERSION >= CSP_MIN_VERSION
	if isDataLoaded and hasMinVersion and hasNecessaryData and isPoliceCar(CAR_ID) then
		canRun = true
	end
	return canRun
end

-- --return json of playerData with only the data needed for the leaderboard
-- -- data are keys of the playerData table
-- local function dataStringify(data)
-- 	local str = '{"' .. ac.getUserSteamID() .. '": '
-- 	local name = ac.getDriverName(0)
-- 	data['Name'] = name
-- 	str = str .. json.stringify(data) .. '}'
-- 	return str
-- end

local settingsOpen = false
local arrestLogsOpen = false
local camerasOpen = false

local imageSize = vec2(0,0)

local pursuit = {
	suspect = nil,
	enable = false,
	maxDistance = 250000,
	minDistance = 40000,
	nextMessage = 30,
	level = 1,
	id = -1,
	timerArrest = 0,
	hasArrested = false,
	startedTime = 0,
	timeLostSight = 0,
	lostSight = false,
	engage = false,
}

local arrestations = {}

local textSize = {}

local textPos = {}

local iconPos = {}

local function onSettingsChange()
	settings:save()
	ac.log('Settings updated')
end

---------------------------------------------------------------------------------------------- Firebase ----------------------------------------------------------------------------------------------

local acpPolice = ac.OnlineEvent({
    message = ac.StructItem.string(110),
	messageType = ac.StructItem.int16(),
	yourIndex = ac.StructItem.int16(),
}, function (sender, data)
	if data.yourIndex == car.sessionID and data.messageType == 0 and pursuit.suspect ~= nil and sender == pursuit.suspect then
		pursuit.hasArrested = true
		ac.log("ACP Police: Police received")
	end
end)

local starsUI = {
	starsPos = vec2(0, 0),
	starsSize = vec2(0, 0),
	startSpace = 0,
	full = "https://acstuff.ru/images/icons_24/star_full.png",
	empty = "https://acstuff.ru/images/icons_24/star_empty.png",
}

local function updateStarsPos()
	starsUI.starsPos = vec2(settings.starsPos.x - settings.starsSize / 2, settings.starsPos.y + settings.starsSize / 2)
	starsUI.starsSize = vec2(settings.starsPos.x - settings.starsSize * 2, settings.starsPos.y + settings.starsSize * 2)
	starsUI.startSpace = settings.starsSize / 1.5
end
local buttonSize = vec2(0,0)
local buttonOffsetX = 20
local function updateHudPos()
	imageSize = vec2(WINDOW_HEIGHT/80 * settings.policeSize, WINDOW_HEIGHT/80 * settings.policeSize)
	iconPos.arrest1 = vec2(imageSize.x - imageSize.x/12, imageSize.y/3.2)
	iconPos.arrest2 = vec2(imageSize.x/1.215, imageSize.y/5)
	iconPos.lost1 = vec2(imageSize.x - imageSize.x/12, imageSize.y/2.35)
	iconPos.lost2 = vec2(imageSize.x/1.215, imageSize.y/3.2)
	iconPos.logs1 = vec2(imageSize.x/1.215, imageSize.y/1.88)
	iconPos.logs2 = vec2(imageSize.x/1.39, imageSize.y/2.35)
	iconPos.menu1 = vec2(imageSize.x - imageSize.x/12, imageSize.y/1.88)
	iconPos.menu2 = vec2(imageSize.x/1.215, imageSize.y/2.35)
	iconPos.cams1 = vec2(imageSize.x/1.215, imageSize.y/2.35)
	iconPos.cams2 = vec2(imageSize.x/1.39, imageSize.y/3.2)

	textSize.size = vec2(imageSize.x*3/5, settings.fontSize/2)
	textSize.box = vec2(imageSize.x*3/5, settings.fontSize/1.3)
	textSize.window1 = vec2(settings.hudOffset.x + imageSize.x / 9.5, settings.hudOffset.y + imageSize.y / 5.3)
	textSize.window2 = vec2(imageSize.x*3/5, imageSize.y/2.8)
	buttonSize = vec2(textSize.window2.x - textSize.window2.x / 10, ui.measureDWriteText("Button", settings.fontSize).y * 0.9)
	buttonOffsetX = textSize.window2.x / 20
	textPos.box1 = vec2(0, 0)
	textPos.box2 = vec2(textSize.size.x, textSize.size.y*1.8)
	textPos.addBox = vec2(0, textSize.size.y * 1.8)
	settings.fontSize = settings.policeSize * FONT_MULT
end

local function showStarsPursuit()
	local starsColor = rgbm(1, 1, 1, os.clock()%2 + 0.3)
	updateStarsPos()
	for i = 1, 5 do
		if i > pursuit.level/2 then
			ui.drawIcon(ui.Icons.StarEmpty, starsUI.starsPos, starsUI.starsSize, rgbm(1, 1, 1, 0.2))
		else
			ui.drawIcon(ui.Icons.StarFull, starsUI.starsPos, starsUI.starsSize, starsColor)
		end
		starsUI.starsPos.x = starsUI.starsPos.x - settings.starsSize - starsUI.startSpace
		starsUI.starsSize.x = starsUI.starsSize.x - settings.starsSize - starsUI.startSpace
	end
end

local showPreviewMsg = false
local showPreviewStars = false
COLORSMSGBG = rgbm(0.5,0.5,0.5,0.5)

local function initsettings()
	imageSize = vec2(WINDOW_HEIGHT/80 * settings.policeSize, WINDOW_HEIGHT/80 * settings.policeSize)
	updateHudPos()
	updateStarsPos()
end

local function previewMSG()
	ui.beginTransparentWindow("previewMSG", vec2(0, 0), vec2(WINDOW_WIDTH, WINDOW_HEIGHT))
	ui.pushDWriteFont("Orbitron;Weight=800")
	local tSize = ui.measureDWriteText("Messages from Police when being chased", settings.fontSizeMSG)
	local uiOffsetX = settings.msgOffset.x - tSize.x/2
	local uiOffsetY = settings.msgOffset.y
	ui.drawRectFilled(vec2(uiOffsetX - 5, uiOffsetY-5), vec2(uiOffsetX + tSize.x + 5, uiOffsetY + tSize.y + 5), COLORSMSGBG)
	ui.dwriteDrawText("Messages from Police when being chased", settings.fontSizeMSG, vec2(uiOffsetX, uiOffsetY), rgbm.colors.cyan)
	ui.popDWriteFont()
	ui.endTransparentWindow()
end

local function previewStars()
	ui.beginTransparentWindow("previewStars", vec2(0, 0), vec2(WINDOW_WIDTH, WINDOW_HEIGHT))
	showStarsPursuit()
	ui.endTransparentWindow()
end

local function uiTab()
	ui.text('On Screen Message : ')
	settings.timeMsg = ui.slider('##' .. 'Time Msg On Screen', settings.timeMsg, 1, 15, 'Time Msg On Screen' .. ': %.0fs')
	settings.fontSizeMSG = ui.slider('##' .. 'Font Size MSG', settings.fontSizeMSG, 10, 50, 'Font Size' .. ': %.0f')
	ui.text('Stars : ')
	settings.starsPos.x = ui.slider('##' .. 'Stars Offset X', settings.starsPos.x, 0, WINDOW_WIDTH, 'Stars Offset X' .. ': %.0f')
	settings.starsPos.y = ui.slider('##' .. 'Stars Offset Y', settings.starsPos.y, 0, WINDOW_HEIGHT, 'Stars Offset Y' .. ': %.0f')
	settings.starsSize = ui.slider('##' .. 'Stars Size', settings.starsSize, 10, 50, 'Stars Size' .. ': %.0f')
	ui.newLine()
	ui.text('Offset : ')
	settings.msgOffset.y = ui.slider('##' .. 'Msg On Screen Offset Y', settings.msgOffset.y, 0, WINDOW_HEIGHT, 'Msg On Screen Offset Y' .. ': %.0f')
	settings.msgOffset.x = ui.slider('##' .. 'Msg On Screen Offset X', settings.msgOffset.x, 0, WINDOW_WIDTH, 'Msg On Screen Offset X' .. ': %.0f')
    ui.newLine()
	ui.text('Preview : ')
	ui.sameLine()
    if ui.button('Message') then
		showPreviewMsg = not showPreviewMsg
		showPreviewStars = false
	end
	ui.sameLine()
	if ui.button('Stars') then
		showPreviewStars = not showPreviewStars
		showPreviewMsg = false
	end
    if showPreviewMsg then previewMSG()
	elseif showPreviewStars then previewStars() end
	if ui.button('Offset X to center') then settings.msgOffset.x = WINDOW_WIDTH/2 end
	ui.newLine()
end

local function settingsWindow()
	imageSize = vec2(WINDOW_HEIGHT/80 * settings.policeSize, WINDOW_HEIGHT/80 * settings.policeSize)
	ui.dwriteTextAligned("settings", 40, ui.Alignment.Center, ui.Alignment.Center, vec2(WINDOW_WIDTH/6.5,60), false, rgbm.colors.white)
	ui.drawLine(vec2(0,60), vec2(WINDOW_WIDTH/6.5,60), rgbm.colors.white, 1)
	ui.newLine(20)
	ui.sameLine(10)
	ui.beginGroup()
	ui.text('Unit : ')
	ui.sameLine(160)
	if ui.selectable('mph', settings.unit == 'mph',_, ui.measureText('km/h')) then
		settings.unit = 'mph'
		settings.unitMult = 0.621371
	end
	ui.sameLine(200)
	if ui.selectable('km/h', settings.unit == 'km/h',_, ui.measureText('km/h')) then
		settings.unit = 'km/h'
		settings.unitMult = 1
	end
	ui.sameLine(WINDOW_WIDTH/6.5 - 120)
	if ui.button('Close', vec2(100, WINDOW_HEIGHT/50)) then
		settingsOpen = false
		onSettingsChange()
	end
	ui.text('HUD : ')
	settings.hudOffset.x = ui.slider('##' .. 'HUD Offset X', settings.hudOffset.x, 0, WINDOW_WIDTH, 'HUD Offset X' .. ': %.0f')
	settings.hudOffset.y = ui.slider('##' .. 'HUD Offset Y', settings.hudOffset.y, 0, WINDOW_HEIGHT, 'HUD Offset Y' .. ': %.0f')
	settings.policeSize = ui.slider('##' .. 'HUD Size', settings.policeSize, 10, 50, 'HUD Size' .. ': %.0f')
	settings.fontSize = settings.policeSize * FONT_MULT
    ui.setNextItemWidth(300)
    ui.newLine()
    uiTab()
	updateHudPos()
	ui.endGroup()
end

---------------------------------------------------------------------------------------------- Utils ----------------------------------------------------------------------------------------------

local function formatMessage(message)
	local msgToSend = message
	if pursuit.suspect == nil then
		msgToSend = string.gsub(msgToSend,"`CAR`", "No Car")
		msgToSend = string.gsub(msgToSend,"`NAME`", "No Name")
		msgToSend = string.gsub(msgToSend,"`SPEED`", "No Speed")
		return msgToSend
	end
	msgToSend = string.gsub(msgToSend,"`CAR`", string.gsub(string.gsub(ac.getCarName(pursuit.suspect.index), "%W", " "), "  ", ""))
	msgToSend = string.gsub(msgToSend,"`NAME`", "@" .. ac.getDriverName(pursuit.suspect.index))
	msgToSend = string.gsub(msgToSend,"`SPEED`", string.format("%d ", ac.getCarSpeedKmh(pursuit.suspect.index) * settings.unitMult) .. settings.unit)
	return msgToSend
end

---------------------------------------------------------------------------------------------- HUD ----------------------------------------------------------------------------------------------

local policeLightsPos = {
	vec2(0,0),
	vec2(WINDOW_WIDTH/10,WINDOW_HEIGHT),
	vec2(WINDOW_WIDTH-WINDOW_WIDTH/10,0),
	vec2(WINDOW_WIDTH,WINDOW_HEIGHT)
}

local function showPoliceLights()
	local timing = math.floor(os.clock()*2 % 2)
	if timing == 0 then
		ui.drawRectFilledMultiColor(policeLightsPos[1], policeLightsPos[2], rgbm(1,0,0,0.5), rgbm(0,0,0,0), rgbm(0,0,0,0), rgbm(1,0,0,0.5))
		ui.drawRectFilledMultiColor(policeLightsPos[3], policeLightsPos[4], rgbm(0,0,0,0), rgbm(0,0,1,0.5), rgbm(0,0,1,0.5), rgbm(0,0,0,0))
	else
		ui.drawRectFilledMultiColor(policeLightsPos[1], policeLightsPos[2], rgbm(0,0,1,0.5), rgbm(0,0,0,0), rgbm(0,0,0,0), rgbm(0,0,1,0.5))
		ui.drawRectFilledMultiColor(policeLightsPos[3], policeLightsPos[4], rgbm(0,0,0,0), rgbm(1,0,0,0.5), rgbm(1,0,0,0.5), rgbm(0,0,0,0))
	end
end

local chaseLVL = {
	message = "",
	messageTimer = 0,
	color = rgbm.colors.white,
}

local function resetChase()
	pursuit.enable = false
	pursuit.nextMessage = 30
	pursuit.lostSight = false
	pursuit.timeLostSight = 2
end

local function lostSuspect()
	resetChase()
	pursuit.lostSight = false
	pursuit.timeLostSight = 0
	pursuit.level = 1
	ac.sendChatMessage(formatMessage(MSG_LOST[math.random(#MSG_LOST)]))
	pursuit.suspect = nil
	ac.setExtraSwitch(0, false)
end

local iconsColorOn = {
	[1] = rgbm.colors.red,
	[2] = rgbm.colors.white,
	[3] = rgbm.colors.white,
	[4] = rgbm.colors.white,
	[5] = rgbm.colors.white,
	[6] = rgbm.colors.white,
}

local playersInRange = {}

local function drawImage()
	iconsColorOn[2] = rgbm.colors.white
	iconsColorOn[3] = rgbm.colors.white
	iconsColorOn[4] = rgbm.colors.white
	iconsColorOn[5] = rgbm.colors.white
	iconsColorOn[6] = rgbm.colors.white

	if ui.rectHovered(iconPos.arrest2, iconPos.arrest1) then
		iconsColorOn[2] = rgbm.colors.red
		if pursuit.suspect and pursuit.suspect.speedKmh < 50 and car.speedKmh < 20 and uiState.isMouseLeftKeyClicked then
			pursuit.hasArrested = true
		end
	elseif ui.rectHovered(iconPos.cams2, iconPos.cams1) then
		iconsColorOn[3] = rgbm.colors.red
		if uiState.isMouseLeftKeyClicked then
			if camerasOpen then camerasOpen = false
			else
				camerasOpen = true
				arrestLogsOpen = false
				if settingsOpen then
					onSettingsChange()
					settingsOpen = false
				end
			end
		end
	elseif ui.rectHovered(iconPos.lost2, iconPos.lost1) then
		iconsColorOn[4] = rgbm.colors.red
		if pursuit.suspect and uiState.isMouseLeftKeyClicked then
			lostSuspect()
		end
	elseif ui.rectHovered(iconPos.logs2, iconPos.logs1) then
		iconsColorOn[5] = rgbm.colors.red
		if uiState.isMouseLeftKeyClicked then
			if arrestLogsOpen then arrestLogsOpen = false
			else
				arrestLogsOpen = true
				camerasOpen = false
				if settingsOpen then
					onSettingsChange()
					settingsOpen = false
				end
			end
		end
	elseif ui.rectHovered(iconPos.menu2, iconPos.menu1) then
		iconsColorOn[6] = rgbm.colors.red
		if uiState.isMouseLeftKeyClicked then
			if settingsOpen then
				onSettingsChange()
				settingsOpen = false
			else
				settingsOpen = true
				arrestLogsOpen = false
				camerasOpen = false
			end
		end
	end
	ui.image(HUD_IMG.base, imageSize, rgbm.colors.white)
	ui.drawImage(HUD_IMG.radar, vec2(0,0), imageSize, iconsColorOn[1])
	ui.drawImage(HUD_IMG.arrest, vec2(0,0), imageSize, iconsColorOn[2])
	ui.drawImage(HUD_IMG.cams, vec2(0,0), imageSize, iconsColorOn[3])
	ui.drawImage(HUD_IMG.lost, vec2(0,0), imageSize, iconsColorOn[4])
	ui.drawImage(HUD_IMG.logs, vec2(0,0), imageSize, iconsColorOn[5])
	ui.drawImage(HUD_IMG.menu, vec2(0,0), imageSize, iconsColorOn[6])
end

local function playerSelected(suspect)
	if suspect.speedKmh > 50 then
		pursuit.suspect = suspect
		pursuit.nextMessage = 30
		pursuit.level = 1
		local msgToSend = "Officer " .. DRIVER_NAME .. " is chasing you. Run! "
		pursuit.startedTime = settings.timeMsg
		pursuit.engage = true
		acpPolice{message = msgToSend, messageType = 0, yourIndex = ac.getCar(pursuit.suspect.index).sessionID}
		ac.setExtraSwitch(0, true)
	end
end

local function hudInChase()
	ui.pushDWriteFont("Orbitron;Weight=Black")
	ui.sameLine(20)
	ui.beginGroup()
	ui.newLine(1)
	local textPursuit = "LVL : " .. math.floor(pursuit.level/2)
	ui.dwriteTextWrapped(ac.getDriverName(pursuit.suspect.index) .. '\n'
						.. string.gsub(string.gsub(ac.getCarName(pursuit.suspect.index), "%W", " "), "  ", "")
						.. '\n' .. string.format("Speed: %d ", pursuit.suspect.speedKmh * settings.unitMult) .. settings.unit
						.. '\n' .. textPursuit, settings.fontSize/2, rgbm.colors.white)
	ui.dummy(vec2(imageSize.x/5,imageSize.y/20))
	ui.newLine(30)
	ui.sameLine()
	if ui.button('Cancel Chase', vec2(imageSize.x/5, imageSize.y/20)) then
		lostSuspect()
	end
	ui.endGroup()
	ui.popDWriteFont()
end

local function drawText()
	ui.pushDWriteFont("Orbitron;Weight=Bold")
	ui.dwriteDrawText("RADAR ACTIVE", settings.fontSize/2, vec2((textPos.box2.x - ui.measureDWriteText("RADAR ACTIVE", settings.fontSize/2).x)/2, 0), rgbm.colors.red)
	ui.popDWriteFont()
	ui.pushDWriteFont("Orbitron;Weight=Regular")
	ui.dwriteDrawText("NEARBY VEHICULE SPEED SCANNING", settings.fontSize/3, vec2((textPos.box2.x - ui.measureDWriteText("NEARBY VEHICULE SPEED SCANNING", settings.fontSize/3).x)/2, settings.fontSize/1.5), rgbm.colors.red)
	ui.dummy(settings.fontSize)
	ui.beginSubgroup(buttonOffsetX)
	for i = 1, #playersInRange do
		if ui.modernButton(playersInRange[i].text, buttonSize) then
			playerSelected(playersInRange[i].player)
		end
	end
	ui.endSubgroup()
	ui.popDWriteFont()
end

local function radarUI()
	ui.toolWindow('radarText', textSize.window1, textSize.window2, true, true, function ()
		if pursuit.suspect then hudInChase()
		else drawText() end
	end)
	ui.transparentWindow('radar', vec2(settings.hudOffset.x, settings.hudOffset.y), imageSize, true, function ()
		drawImage()
	end)
end

local function hidePlayers()
	local hideRange = 500
	for i = ac.getSim().carsCount - 1, 0, -1 do
		local playerCar = ac.getCar(i)
		if playerCar and playerCar.isConnected and ac.getCarBrand(i) ~= "traffic" then
			if not isPoliceCar(ac.getCarID(i)) then
				if playerCar.position.x > car.position.x - hideRange and playerCar.position.z > car.position.z - hideRange and playerCar.position.x < car.position.x + hideRange and playerCar.position.z < car.position.z + hideRange then
					ac.hideCarLabels(i, false)
				else
					ac.hideCarLabels(i, true)
				end
			end
		end
	end
end

local RADAR_RANGE = 250

local function radarUpdate()
	local previousSize = #playersInRange
	local j = 1
	for i, c in ac.iterateCars.serverSlots() do
	  if not c.isHidingLabels and not isPoliceCar(c:id()) then
			if c.position.x > car.position.x - RADAR_RANGE and c.position.z > car.position.z - RADAR_RANGE and c.position.x < car.position.x + RADAR_RANGE and c.position.z < car.position.z + RADAR_RANGE then
				playersInRange[j] = {}
				playersInRange[j].player = c
				playersInRange[j].text = ac.getDriverName(c.index) .. string.format(" - %d ", c.speedKmh * settings.unitMult) .. settings.unit
				j = j + 1
				if j == 9 then break end
			end
		end
	end
	for i = j, previousSize do playersInRange[i] = nil end
end

---------------------------------------------------------------------------------------------- Chase ----------------------------------------------------------------------------------------------

local function inRange()
	local distance_x = pursuit.suspect.position.x - car.position.x
	local distance_z = pursuit.suspect.position.z - car.position.z
	local distanceSquared = distance_x * distance_x + distance_z * distance_z
	if(distanceSquared < pursuit.minDistance) then
		pursuit.enable = true
		pursuit.lostSight = false
		pursuit.timeLostSight = 2
	elseif (distanceSquared < pursuit.maxDistance) then resetChase()
	else
		if not pursuit.lostSight then
			pursuit.lostSight = true
			pursuit.timeLostSight = 2
		else
			pursuit.timeLostSight = pursuit.timeLostSight - ui.deltaTime()
			if pursuit.timeLostSight < 0 then lostSuspect() end
		end
	end
end

local function sendChatToSuspect()
	if pursuit.enable then
		if 0 < pursuit.nextMessage then
			pursuit.nextMessage = pursuit.nextMessage - ui.deltaTime()
		elseif pursuit.nextMessage < 0 then
			local nb = tostring(pursuit.level)
			acpPolice{message = nb, messageType = 1, yourIndex = ac.getCar(pursuit.suspect.index).sessionID}
			if pursuit.level < 10 then
				pursuit.level = pursuit.level + 1
				chaseLVL.messageTimer = settings.timeMsg
				chaseLVL.message = "CHASE LEVEL " .. math.floor(pursuit.level/2)
				if pursuit.level > 8 then
					chaseLVL.color = rgbm.colors.red
				elseif pursuit.level > 6 then
					chaseLVL.color = rgbm.colors.orange
				elseif pursuit.level > 4 then
					chaseLVL.color = rgbm.colors.yellow
				else
					chaseLVL.color = rgbm.colors.white
				end
			end
			pursuit.nextMessage = 30
		end
	end
end

local function showPursuitMsg()
	local text = ""
	if chaseLVL.messageTimer > 0 then
		chaseLVL.messageTimer = chaseLVL.messageTimer - ui.deltaTime()
		text = chaseLVL.message
	end
	if pursuit.startedTime > 0 then
		if pursuit.suspect then
			text = "You are chasing " .. ac.getDriverName(pursuit.suspect.index) .. " driving a " .. string.gsub(string.gsub(ac.getCarName(pursuit.suspect.index), "%W", " "), "  ", "") .. " ! Get him! "
		end
		if pursuit.startedTime > 6 then showPoliceLights() end
		if pursuit.engage and pursuit.startedTime < 8 then
			ac.sendChatMessage(formatMessage(MSG_ENGAGE[math.random(#MSG_ENGAGE)]))
			pursuit.engage = false
		end
	end
	if text ~= "" then
		local textLenght = ui.measureDWriteText(text, settings.fontSizeMSG)
		local rectPos1 = vec2(settings.msgOffset.x - textLenght.x/2, settings.msgOffset.y)
		local rectPos2 = vec2(settings.msgOffset.x + textLenght.x/2, settings.msgOffset.y + settings.fontSizeMSG)
		local rectOffset = vec2(10, 10)
		if ui.time() % 1 < 0.5 then
			ui.drawRectFilled(rectPos1 - vec2(10,0), rectPos2 + rectOffset, COLORSMSGBG, 10)
		else
			ui.drawRectFilled(rectPos1 - vec2(10,0), rectPos2 + rectOffset, rgbm(0,0,0,0.5), 10)
		end
		ui.dwriteDrawText(text, settings.fontSizeMSG, rectPos1, chaseLVL.color)
	end
end

local function arrestSuspect()
	if pursuit.hasArrested and pursuit.suspect then
		local msgToSend = formatMessage(MSG_ARREST[math.random(#MSG_ARREST)])
		table.insert(arrestations, msgToSend .. os.date("\nDate of the Arrestation: %c"))
		ac.sendChatMessage(msgToSend .. "\nPlease Get Back Pit, GG!")
		pursuit.id = pursuit.suspect.sessionID
		player.arrests = player.arrests + 1
		pursuit.startedTime = 0
		pursuit.suspect = nil
		pursuit.timerArrest = 1
	elseif pursuit.hasArrested then
		if pursuit.timerArrest > 0 then
			pursuit.timerArrest = pursuit.timerArrest - ui.deltaTime()
		else
			acpPolice{message = "BUSTED!", messageType = 2, yourIndex = pursuit.id}
			pursuit.timerArrest = 0
			pursuit.suspect = nil
			pursuit.id = -1
			pursuit.hasArrested = false
			pursuit.startedTime = 0
			pursuit.enable = false
			pursuit.level = 1
			pursuit.nextMessage = 20
			pursuit.lostSight = false
			pursuit.timeLostSight = 0
			local data = {
				["Arrests"] = player.arrests,
			}
			-- Update Player Data Arrests
		end
	end
end

local function chaseUpdate()
	if pursuit.startedTime > 0 then pursuit.startedTime = pursuit.startedTime - ui.deltaTime()
	else pursuit.startedTime = 0 end
	if pursuit.suspect then
		sendChatToSuspect()
		inRange()
	end
	arrestSuspect()
end

---------------------------------------------------------------------------------------------- Menu ----------------------------------------------------------------------------------------------

local function arrestLogsUI()
	ui.dwriteTextAligned("Arrestation Logs", 40, ui.Alignment.Center, ui.Alignment.Center, vec2(WINDOW_WIDTH/4,60), false, rgbm.colors.white)
	ui.drawLine(vec2(0,60), vec2(WINDOW_WIDTH/4,60), rgbm.colors.white, 1)
	ui.newLine(15)
	ui.sameLine(10)
	ui.beginGroup()
	local allMsg = ""
	ui.dwriteText("Click on the button next to the message you want to copy.", 15, rgbm.colors.white)
	ui.sameLine(WINDOW_WIDTH/4 - 120)
	if ui.button('Close', vec2(100, WINDOW_HEIGHT/50)) then arrestLogsOpen = false end
	for i = 1, #arrestations do
		if ui.smallButton("#" .. i .. ": ") then
			ui.setClipboardText(arrestations[i])
		end
		ui.sameLine()
		ui.dwriteTextWrapped(arrestations[i], 15, rgbm.colors.white)
	end
	if #arrestations == 0 then
		ui.dwriteText("No arrestation logs yet.", 15, rgbm.colors.white)
	end
	ui.newLine()
	if ui.button("Set all messages to ClipBoard") then
		for i = 1, #arrestations do
			allMsg = allMsg .. arrestations[i] .. "\n\n"
		end
		ui.setClipboardText(allMsg)
	end
	ui.endGroup()
end

local buttonPos = WINDOW_WIDTH/65

local function camerasUI()
	ui.dwriteTextAligned("Surveillance Cameras", 40, ui.Alignment.Center, ui.Alignment.Center, vec2(WINDOW_WIDTH/6.5,60), false, rgbm.colors.white)
	ui.drawLine(vec2(0,60), vec2(WINDOW_WIDTH/6.5,60), rgbm.colors.white, 1)
	ui.newLine(20)
	ui.beginGroup()
	ui.sameLine(buttonPos)
	if ui.button('Close', vec2(WINDOW_WIDTH/6.5 - buttonPos*2,30)) then camerasOpen = false end
	ui.newLine()
	for i = 1, #CAMERAS do
		local h = math.rad(CAMERAS[i].dir + ac.getCompassAngle(vec3(0, 0, 1)))
		ui.newLine()
		ui.sameLine(buttonPos)
		if ui.button(CAMERAS[i].name, vec2(WINDOW_WIDTH/6.5 - buttonPos*2,30)) then
			ac.setCurrentCamera(ac.CameraMode.Free)
			ac.setCameraPosition(CAMERAS[i].pos)
			ac.setCameraDirection(vec3(math.sin(h), 0, math.cos(h))) 
			ac.setCameraFOV(CAMERAS[i].fov)
		end
	end
	if ac.getSim().cameraMode == ac.CameraMode.Free then
		ui.newLine()
		ui.newLine()
		ui.sameLine(buttonPos)
        if ui.button('Police car camera', vec2(WINDOW_WIDTH/6.5 - buttonPos*2,30)) then ac.setCurrentCamera(ac.CameraMode.Cockpit) end
    end
end


local menuSize = {vec2(WINDOW_WIDTH/4, WINDOW_HEIGHT/3), vec2(WINDOW_WIDTH/6.4, WINDOW_HEIGHT/2.2)}
local buttonPressed = false

local function moveMenu()
	if ui.windowHovered() and ui.mouseDown() then buttonPressed = true end
	if ui.mouseReleased() then buttonPressed = false end
	if buttonPressed then settings.menuPos = settings.menuPos + ui.mouseDelta() end
end

---------------------------------------------------------------------------------------------- updates ----------------------------------------------------------------------------------------------

local initUiSize = false

function script.drawUI()
	if not shouldRun() then return end
	if not initUiSize then
		initsettings()
		initUiSize = true
	end
	radarUI()
	if pursuit.suspect then showStarsPursuit() end
	showPursuitMsg()
	if settingsOpen then
		ui.toolWindow('settings', settings.menuPos, menuSize[2], true, function ()
			ui.childWindow('childsettings', menuSize[2], true, function () settingsWindow() moveMenu() end)
		end)
	elseif arrestLogsOpen then
		ui.toolWindow('ArrestLogs', settings.menuPos, menuSize[1], true, function ()
			ui.childWindow('childArrestLogs', menuSize[1], true, function () arrestLogsUI() moveMenu() end)
		end)
	elseif camerasOpen then
		ui.toolWindow('Cameras', settings.menuPos, menuSize[2], true, function ()
			ui.childWindow('childCameras', menuSize[2], true, function () camerasUI() moveMenu() end)
		end)
	end
end

local function loadSettings()
	Settings.allocate(function(allocatedSetting)
		ac.log("Settings Allocated")
		settings = allocatedSetting
		dataLoaded['Settings'] = true
	end)
end

local function loadPlayerData()
	Player.allocate(function(allocatedPlayer)
		if allocatedPlayer then
			player = allocatedPlayer
			dataLoaded['PlayerData'] = true
		end
	end)
end

function script.update()
	if initialisation then
		initialisation = false
		loadSettings()
		loadPlayerData()
	end
	if not shouldRun() then return end
	radarUpdate()
	chaseUpdate()
end

ac.onCarJumped(0, function (carIndex)
	if isPoliceCar(CAR_ID) then
		if pursuit.suspect then lostSuspect() end
	end
end)

ui.registerOnlineExtra(ui.Icons.Settings, "Settings", nil, settingsWindow, nil, ui.OnlineExtraFlags.Tool, 'ui.WindowFlags.AlwaysAutoResize')
