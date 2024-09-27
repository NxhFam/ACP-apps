local sim = ac.getSim()
local car = ac.getCar(0) or error()
if not car then return end
local wheels = car.wheels or error()
local uiState = ac.getUI()
ui.setAsynchronousImagesLoading(true)

local localTesting = false
ac.log('Local testing:', localTesting)
local initialisation = true

-- Constants --
local STEAMID = const(ac.getUserSteamID())
local CSP_VERSION = const(ac.getPatchVersionCode())
local CSP_MIN_VERSION = const(2253)
local CAR_ID = const(ac.getCarID(0))
local CAR_NAME = const(ac.getCarName(0))
local DRIVER_NAME = const(ac.getDriverName(0))
if CSP_VERSION < CSP_MIN_VERSION then return end

local DRIVER_NATION_CODE = const(ac.getDriverNationCode(0))
local UNIT = "km/h"
local UNIT_MULT = 1
if DRIVER_NATION_CODE == "USA" or DRIVER_NATION_CODE == "GBR" then
	UNIT = "mph"
	UNIT_MULT = 0.621371
end

local POLICE_CAR = { "chargerpolice_acpursuit", "crown_police" }

local patchCount = 0

-- URL --
local GOOGLE_APP_SCRIPT_URL = const(
	'https://script.google.com/macros/s/AKfycbwenxjCAbfJA-S90VlV0y7mEH75qt3TuqAmVvlGkx-Y1TX8z5gHtvf5Vb8bOVNOA_9j/exec')
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
	base = "https://i.postimg.cc/ZKbvKVkP/hudBase.png",
	center = "https://i.postimg.cc/fyZtdvVN/hud-Center.png",
	left = "https://i.postimg.cc/y8WJ0x8k/hudLeft.png",
	right = "https://i.postimg.cc/d0yLSfdF/hudRight.png",
	countdown = "https://i.postimg.cc/FHqYpvYG/icon-Countdown.png",
	menu = "https://i.postimg.cc/2ywq7BWB/iconMenu.png",
	ranks = "https://i.postimg.cc/66LGXFP5/icon-Ranks.png",
	theft = "https://i.postimg.cc/9FLR4ZV6/icon-Theft.png",
})

local WELCOME_NAV_IMG = const({
	base = "https://i.postimg.cc/pX9rTTVC/baseacp.png",
	logo = "https://i.postimg.cc/brZysCPr/logoacp.png",
	leftBoxOff = "https://i.postimg.cc/MTKK8Zry/left-Box-Off.png",
	leftBoxOn = "https://i.postimg.cc/xdPT7Ngf/left-Box-On.png",
	centerBoxOff = "https://i.postimg.cc/G2qtBTs7/center-Box-Off.png",
	centerBoxOn = "https://i.postimg.cc/2j93rvY3/center-Box-On.png",
	rightBoxOff = "https://i.postimg.cc/kXtMCpwh/right-Box-Off.png",
	rightBoxOn = "https://i.postimg.cc/13hm3rjR/right-Box-On.png",
	leftArrowOff = "https://i.postimg.cc/cLwJRbn8/left-Arrow-Off.png",
	leftArrowOn = "https://i.postimg.cc/B6YZZWdR/left-Arrow-On.png",
	rightArrowOff = "https://i.postimg.cc/cLRsgtpR/right-Arrow-Off.png",
	rightArrowOn = "https://i.postimg.cc/BbRqDTZg/right-Arrow-On.png",
})

local WELCOME_CARD_IMG = const({
	"https://i.postimg.cc/5tW6DVV3/aboutacp.jpg",
	"https://i.postimg.cc/MHLG5k51/earnmoney.jpg",
	"https://i.postimg.cc/4yydp46J/leaderboard.jpg",
	"https://i.postimg.cc/T3DKkPZ1/bank.jpg",
	"https://i.postimg.cc/15LtNQfQ/police.jpg",
	"https://i.postimg.cc/WbKD6ZYx/buycars.jpg",
	"https://i.postimg.cc/sfLftrPh/tuning.jpg",
	"https://i.postimg.cc/bv0shBYj/cartheft.jpg",
	"https://i.postimg.cc/Jn1t45tH/drugdealer.jpg",
	"https://i.postimg.cc/mrm2J2xf/BANK-HEIST.png",
})

local WELCOME_CARD_LINK = const({
	"https://discord.com/channels/358562025032646659/1062186611091185784", --FAQ
	"https://discord.com/channels/358562025032646659/1147217487524528138", --earn
	"https://discord.com/channels/358562025032646659/1127619394328076318", --leaderboard
	"https://discord.com/channels/358562025032646659/1075578309443858522", --bank
	"https://discord.com/channels/358562025032646659/1095681142197325975", --police
	"https://discord.com/channels/358562025032646659/1076123906362056784", --car
	"https://discord.com/channels/358562025032646659/1079799948306034708", --tuning
	"https://discord.com/channels/358562025032646659/1096470595392241704", --car theft
	"",
	"",
})

local MISSION_INFOS = const({
	[10] = {
		start = "Rob : Bank in front of Start/1 TP",
		finish = "Deliver : Yellow BHL (Map)",
		time = "Time Limit: 03:20.000",
	},
	[9] = {
		start = "Pick Up : Drug Delivery TP",
		finish = "Drop Off : Pink House (Map)",
		time = "Time Limit: 05:40.000",
	},
	[8] = {
		start = "Steal : Gas Station 1 TP",
		finish = "Deliver : Red Car (Map)",
		time = "Time Limit: 07:20.000",
	},
})

local MISSION_NAMES = const({"DRUG DELIVERY", "BANK HEIST", "BOBs SCRAPYARD"})
local MISSION_TEXT = const({
	["DRUG DELIVERY"] = {
		chat = "* Picking up drugs " .. os.date("%x *"),
		screen = "You have successfully picked up the drugs! Hurry to the drop off location!",
	},
	["BOBs SCRAPYARD"] = {
		chat = "* Stealing a " .. string.gsub(CAR_NAME, "%W", " ") .. os.date("%x *"),
		screen = "You have successfully stolen the " .. string.gsub(string.gsub(CAR_NAME, "%W", " "), "  ", "") .. "! Hurry to the scrapyard!",
	},
	["BANK HEIST"] = {
		chat = "* Robbing the bank " .. os.date("%x *"),
		screen = "You have successfully robbed the bank! Hurry to the drop off location!",
	},
});

local FINISH_MSG = const({
	["H1"] = {
		success = " has finished H1 in ",
		fail = " has failed to finish H1 under the time limit!",
	},
	["BOBs SCRAPYARD"] = {
		success = " has successfully stolen a " .. string.gsub(CAR_NAME, "%W", " ") .. " and got away with it!",
		fail = " has failed to steal a " .. string.gsub(CAR_NAME, "%W", " ") .. " under the time limit!",
	},
	["DOUBLE TROUBLE"] = {
		success = " has successfully stolen a " .. string.gsub(CAR_NAME, "%W", " ") .. " and got away with it!",
		fail = " has failed to steal a " .. string.gsub(CAR_NAME, "%W", " ") .. " under the time limit!",
	},
	["DRUG DELIVERY"] = {
		success = " has successfully delivered the drugs!",
		fail = " has failed to deliver the drugs under the time limit!",
	},
	["BANK HEIST"] = {
		success = " has successfully robbed the bank!",
		fail = " has failed to rob the bank under the time limit!",
	},
});

local WELCOME_CARD_IMG_POS = const({
	{ vec2(70, 650),   vec2(320, 910) },
	{ vec2(2230, 650), vec2(2490, 910) },
	{ vec2(357, 325),  vec2(920, 1234) },
	{ vec2(993, 325),  vec2(1557, 1234) },
	{ vec2(1633, 325), vec2(2195, 1234) },
	{ vec2(31, 106),   vec2(2535, 1370) },
	{ vec2(2437, 48),  vec2(2510, 100) },
})

-- Gate related --
local GATE_HEIGHT_OFFSET = const(0.2)
local white = const(rgbm.colors.white)
local gateColor = const(rgbm(0, 100, 0, 10))

-- basic directionnal vectors --
local vUp = const(vec3(0, 1, 0))
local vDown = const(vec3(0, -1, 0))

local menuStates = {
	welcome = true,
	main = false,
	leaderboard = false,
}

local dataLoaded = {}
dataLoaded['Settings'] = false
dataLoaded['Leaderboard'] = false
dataLoaded['PlayerData'] = false
dataLoaded['Sectors'] = false

---@param carID string
local function isPoliceCar(carID)
	for _, carName in ipairs(POLICE_CAR) do
		if carID == carName then
			return true
		end
	end
	return false
end

if isPoliceCar(CAR_ID) then return end

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
		local file = io.open(currentPath .. '/settingsResponse.json', 'r')
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
	if localTesting or patchCount > 20 then return end
	patchCount = patchCount + 1
	local str = '{"' .. STEAMID .. '": ' .. JSON.stringify(self:export()) .. '}'
	web.request('PATCH', FIREBASE_URL .. "Settings.json", str, function(err, response)
		if err then
			ac.error(err)
			return
		end
	end)
end

---@class Gate
---@field pos vec3
---@field dir vec3
---@field point1 vec3
---@field point2 vec3
---@field width number
---@field cross vec3
---@field id integer
local Gate = class('Gate')

---@param data table
---@return Gate|nil
function Gate.tryParse(data)
	local keys = { 'pos', 'dir', 'width', 'id' }
	if not hasKeys(keys, data) then
		ac.log('Missing required keys in gate data.')
		return nil
	end

	local pos = tableToVec3(data.pos)
	local dir = tableToVec3(data.dir)
	local cross = vec3(dir.z, 0, -dir.x)
	local point1 = pos + cross * data.width / 2
	local point2 = pos - cross * data.width / 2
	return {
		pos = pos,
		dir = dir,
		cross = cross,
		point1 = snapToTrack(point1) + vec3(0, GATE_HEIGHT_OFFSET, 0),
		point2 = snapToTrack(point2) + vec3(0, GATE_HEIGHT_OFFSET, 0),
		width = data.width,
		id = data.id,
	}
end

---@param data table
---@return Gate|nil
function Gate.allocate(data)
	local gate = Gate.tryParse(data)
	if not gate then
		ac.error('Failed to allocate gate')
		return nil
	end
	return gate
end

function Gate:print()
	ac.error('Gate:\npos:', self.pos, 'dir:', self.dir)
end

---@return boolean
function Gate:isTooFar()
	return self.pos:distanceSquared(car.position) > self.width * 3
end

---@return boolean
function Gate:isCrossed()
	if self:isTooFar() then
		return false
	end
	local carHalfWidth = car.aabbSize.z / 2

	local isCrossing = vec2.intersect(vec2(self.point1.x, self.point1.z), vec2(self.point2.x, self.point2.z),
		vec2(car.position.x - carHalfWidth, car.position.z - carHalfWidth),
		vec2(car.position.x + carHalfWidth, car.position.z + carHalfWidth))
	local goingThrough = self.dir:dot(car.look) > 0
	if isCrossing and goingThrough then
		return true
	end
	return false
end

---@class Sector
---@field name string
---@field startTime number
---@field time string
---@field timeLimit number
---@field timeColor rgbm
---@field startDistance number
---@field distanceDriven number
---@field lenght number
---@field gateCount integer
---@field gateIndex integer
---@field gates Gate[]
local Sector = class('Sector')

---@param data table
---@return Sector|nil
function Sector.tryParse(data)
	local keys = { 'timeLimit', 'length', 'gates' }
	if not hasKeys(keys, data) then
		ac.error('Missing required keys in sector data.')
		return nil
	end
	local gates = {}
	for i, gateData in ipairs(data.gates) do
		local gate = Gate(gateData)
		if not gate then
			ac.error('Failed to parse gate:', i)
			return nil
		end
		table.insert(gates, gate)
	end

	local sector = {
		gateCount = #gates,
		gateIndex = 1,
		startTime = 0,
		time = '00:00.000',
		timeLimit = data.timeLimit,
		timeColor = white,
		startDistance = 0,
		distanceDriven = 0,
		lenght = data.length,
		gates = gates,
	}
	setmetatable(sector, { __index = Sector })
	return sector
end

---@param url string
---@param callback function
function Sector.fetch(url, callback)
	if localTesting then
		local currentPath = ac.getFolder(ac.FolderID.ScriptOrigin)
		local filename = url:match('.+/(.+)$')
		local file = io.open(currentPath .. '/sector' .. filename, 'r')
		if not file then
			ac.error('Failed to open response.json')
			callback(nil)
			return
		end
		local data = JSON.parse(file:read('*a'))
		file:close()
		local sector = Sector.tryParse(data)
		callback(sector)
	else
		web.get(url, function(err, response)
			if canProcessRequest(err, response) then
				local data = JSON.parse(response.body)
				if data then
					local sector = Sector.tryParse(data)
					callback(sector)
				else
					ac.error('Failed to parse sector data.')
					callback(nil)
				end
			else
				callback(nil)
			end
		end)
	end
end

---@param name string
---@param callback function
function Sector.allocate(name, callback)
	local url = FIREBASE_URL .. 'Sectors/' .. name .. '.json'
	Sector.fetch(url, function(sector)
		if not sector then
			ac.error('Failed to allocate sector:', name)
		else
			sector.name = name
		end
		callback(sector)
	end)
end

function Sector:reset()
	self.gateIndex = 1
	self.startTime = 0
	self.time = '00:00.000'
	self.timeColor = white
	self.startDistance = 0
	self.distanceDriven = 0
end

function Sector:starting()
	if self.gateIndex == 2 then
		self.time = '00:00.000'
		self.startTime = os.preciseClock()
		self.startDistance = car.distanceDrivenTotalKm
	end
end

---@return boolean
function Sector:isFinished()
	return self.gateIndex > self.gateCount -- and self.distanceDriven > self.lenght
end

---@return boolean
function Sector:hasStarted()
	return self.startTime > 0
end

function Sector:updateDistanceDriven()
	if self.startDistance > 0 then
		self.distanceDriven = truncate(car.distanceDrivenTotalKm - self.startDistance, 3)
	end
end

function Sector:updateTime()
	if self.startTime > 0 then
		local time = os.preciseClock() - self.startTime
		local minutes = math.floor(time / 60)
		local seconds = math.floor(time % 60)
		local milliseconds = math.floor((time % 1) * 1000)
		self.time = ('%02d:%02d.%03d'):format(minutes, seconds, milliseconds)
	end
end

function Sector:isUnderTimeLimit()
	if self.timeLimit > 0 then
		return os.preciseClock() - self.startTime < self.timeLimit
	end
	return true
end

function Sector:updateTimeColor()
	if self:hasStarted() and not self:isUnderTimeLimit() then
		self.timeColor = rgbm(1, 0, 0, 1)
	end
	if self:isFinished() then
		self.timeColor = rgbm(0, 1, 0, 1)
	end
end

function Sector:update()
	self:updateDistanceDriven()
	self:updateTime()
	self:updateTimeColor()
	if self.gateIndex > self.gateCount then
		return
	end
	if self.gates[self.gateIndex]:isCrossed() then
		self.gateIndex = self.gateIndex + 1
		self:starting()
		self:updateTimeColor()
	end
end

---@class SectorStats
---@field name string
---@field records table<string, number>
local SectorStats = class('SectorStats')

---@param name string
---@param data table
---@return SectorStats
function SectorStats.tryParse(name, data)
	local records = {}
	for carName, time in pairs(data) do
		records[carName] = time
	end
	local sectorStats = {
		name = name,
		records = records,
	}
	setmetatable(sectorStats, { __index = SectorStats })
	return sectorStats
end

---@param name string
---@param data table
---@return SectorStats|nil
function SectorStats.allocate(name, data)
	if type(data) == 'table' then
		local sectorStats = SectorStats.tryParse(name, data)
		if not sectorStats then
			ac.error('Failed to allocate sector stat')
			return nil
		end
		return sectorStats
	end
	if type(data) == 'number' then
		local records = {}
		records[CAR_NAME] = data
		local sectorStats = {
			name = name,
			records = records,
		}
		return sectorStats
	end
	ac.error('Failed to allocate sector stat')
	return nil
end

---@param time number
function SectorStats:addRecord(time)
	if not self.records[CAR_NAME] or self.records[CAR_NAME] > time then
		self.records[CAR_NAME] = time
	end
end

---@return table
function SectorStats:export()
	local records = {}
	for carName, time in pairs(self.records) do
		records[carName] = truncate(time, 3)
	end
	return {
		[self.name] = records
	}
end

---@class Player
---@field name string
---@field sectors SectorStats[]
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
		sectors = {},
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
	local sectors = {}
	if data.sectors then
		for sectorName, sectorData in pairs(data.sectors) do
			local sector = SectorStats(sectorName, sectorData)
			if sector then
				table.insert(sectors, sector)
			end
		end
	end
	local player = {
		name = DRIVER_NAME,
		sectors = sectors,
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
		local file = io.open(currentPath .. '/playerResponse.json', 'r')
		if not file then
			ac.error('Failed to open playerResponse.json')
			callback(Player.new())
			return
		end
		local data = JSON.parse(file:read('*a'))
		file:close()
		local player = Player.tryParse(data)
		callback(player)
		ac.log('Player Date Loaded From File')
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

	local sectors = {}
	for _, sector in ipairs(self.sectors) do
		local sectorData = sector:export()
		for key, value in pairs(sectorData) do
			sectors[key] = value
		end
	end
	if next(sectors) then
		data.sectors = sectors
	end
	return data
end

function Player:save()
	if localTesting or patchCount > 40 then return end
	patchCount = patchCount + 1
	local str = '{"' .. STEAMID .. '": ' .. JSON.stringify(self:export()) .. '}'
	web.request('PATCH', FIREBASE_URL .. "Players.json", str, function(err, response)
		if err then
			ac.error(err)
			return
		end
	end)
end

function Player:addSectorRecord(sectorName, time)
	---@type SectorStats | nil
	local sector = nil
	for _, s in ipairs(self.sectors) do
		if s.name == sectorName then
			sector = s
			break
		end
	end
	if not sector then
		sector = SectorStats(sectorName, time)
		if not sector then return end
		table.insert(self.sectors, sector)
	end
	sector:addRecord(time)
end

---@type Player | nil
local player = nil

---@type Settings | nil
local settings = nil

---@type Sector[]
local sectors = {}

local function getSectorByName(name)
	for _, sector in ipairs(sectors) do
		if sector.name == name then
			return sector
		end
	end
	return nil
end

---@class SectorManager
---@field sector Sector
---@field started boolean
---@field finished boolean
---@field isDuo boolean
local SectorManager = class('SectorManager')

---@return SectorManager
function SectorManager.new()
	local sm = {
		sector = nil,
		started = false,
		finished = false,
		isDuo = false,
	}
	setmetatable(sm, { __index = SectorManager })
	return sm
end

---@return SectorManager
function SectorManager.allocate()
	return SectorManager.new()
end

function SectorManager:reset()
	if self.sector.name == "DOUBLE TROUBLE" then
		self.isDuo = true
	else
		self.isDuo = false
	end
	self.started = false
	self.finished = false
	self.sector:reset()
end

---@param name string
function SectorManager:setSector(name)
	local sector = getSectorByName(name)
	if sector then
		self.sector = sector
		self:reset()
	end
end

---@type SectorManager
local sectorManager = SectorManager()

local duo = {
	teammate = nil,
	request = false,
	onlineSender = nil,
	teammateHasFinished = false,
	waiting = false,
	playerName = "Online Players",
}

local acpEvent = ac.OnlineEvent({
	message = ac.StructItem.string(110),
	messageType = ac.StructItem.int16(),
	yourIndex = ac.StructItem.int16(),
}, function(sender, data)
	if not sender then return end
	if data.yourIndex == car.sessionID and data.messageType == 5 and data.message == "Request" then
		duo.request = true
		duo.onlineSender = sender
	elseif data.yourIndex == car.sessionID and data.messageType == 5 and data.message == "Accept" then
		duo.teammate = sender
		duo.request = false
	elseif duo.teammate and data.yourIndex == car.sessionID and sender.index == duo.teammate.index and data.messageType == 5 and data.message == "Finished" then
		duo.teammateHasFinished = true
	elseif duo.teammate and data.yourIndex == car.sessionID and sender.index == duo.teammate.index and data.messageType == 5 and data.message == "Cancel" then
		duo.teammate = nil
		duo.request = false
		sectorManager:setSector('BOBs SCRAPYARD')
	end
end)

function SectorManager:duoFinished()
	if duo.teammate then
		if duo.teammateHasFinished then
			ac.sendChatMessage(" has finished " .. self.sector.name .. " in " .. self.sector.time .. "!")
		else
			acpEvent{message = "Finished", messageType = 5, yourIndex = ac.getCar(duo.teammate.index).sessionID}
		end
	end
end

function SectorManager:printToChat()
	if sectorManager.sector.name == "H1" then
		ac.sendChatMessage(" has finished H1 in " .. sectorManager.sector.time .. " driving a " .. CAR_NAME .. "!")
	elseif self.sector:isUnderTimeLimit() then
		ac.sendChatMessage(FINISH_MSG[self.sector.name].success)
	else
		ac.sendChatMessage(FINISH_MSG[self.sector.name].fail)
	end
end

function SectorManager:hasTeammateFinished()
	if duo.teammate and duo.teammateHasFinished then
		return true
	end
	return false
end

local canRun = false
local function shouldRun()
	if canRun then return true end
	local isDataLoaded = dataLoaded['Settings'] and dataLoaded['PlayerData'] and dataLoaded['Sectors']
	local hasNecessaryData = settings and player and sectors and sectorManager.sector
	local hasMinVersion = CSP_VERSION >= CSP_MIN_VERSION
	if isDataLoaded and hasMinVersion and hasNecessaryData and not isPoliceCar(CAR_ID) then
		canRun = true
	end
	return canRun
end

local hud = {
	size = vec2(0, 0),
	pos = {
		countdown1 = vec2(0, 0),
		countdown2 = vec2(0, 0),
		menu1 = vec2(0, 0),
		menu2 = vec2(0, 0),
		ranks1 = vec2(0, 0),
		ranks2 = vec2(0, 0),
		theft1 = vec2(0, 0),
		theft2 = vec2(0, 0),
		left1 = vec2(0, 0),
		left2 = vec2(0, 0),
		right1 = vec2(0, 0),
		right2 = vec2(0, 0),
	},
}

----------------------------------------------------------------------------------------------- Math -----------------------------------------------------------------------------------------------

local function cross(vector1, vector2)
	return vec2(vector1.x + vector2.x, vector1.y + vector2.y)
end

local function isPointInCircle(point, circle, radius)
	if math.distanceSquared(point, circle) <= radius then
		return true
	end
	return false
end

-------------------------------------------------------------------------------------------- Init --------------------------------------------------------------------------------------------

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

local function updateHudPos()
	hud.size = vec2(HEIGHT_DIV._80 * settings.essentialSize, HEIGHT_DIV._80 * settings.essentialSize)
	hud.pos.theftPos1 = vec2(hud.size.x - hud.size.x / 1.56, hud.size.y / 1.9)
	hud.pos.theftPos2 = vec2(hud.size.x / 4.6, hud.size.y / 2.65)
	hud.pos.ranksPos1 = vec2(hud.size.x / 1.97, hud.size.y / 1.9)
	hud.pos.ranksPos2 = vec2(hud.size.x - hud.size.x / 1.56, hud.size.y / 2.65)
	hud.pos.countdownPos1 = vec2(hud.size.x / 1.53, hud.size.y / 1.9)
	hud.pos.countdownPos2 = vec2(hud.size.x - hud.size.x / 2.04, hud.size.y / 2.65)
	hud.pos.menuPos1 = vec2(hud.size.x - hud.size.x / 4.9, hud.size.y / 1.9)
	hud.pos.menuPos2 = vec2(hud.size.x / 1.53, hud.size.y / 2.65)
	hud.pos.leftPos1 = vec2(hud.size.x / 8, hud.size.y / 2.8)
	hud.pos.leftPos2 = vec2(0, hud.size.y / 4.3)
	hud.pos.rightPos1 = vec2(hud.size.x, hud.size.y / 2.8)
	hud.pos.rightPos2 = vec2(hud.size.x - hud.size.x / 8, hud.size.y / 4.3)
	settings.fontSize = settings.essentialSize * FONT_MULT
end

local function textWithBackground(text, sizeMult)
	local textLenght = ui.measureDWriteText(text, settings.fontSizeMSG * sizeMult)
	local rectPos1 = vec2(settings.msgOffset.x - textLenght.x / 2, settings.msgOffset.y)
	local rectPos2 = vec2(settings.msgOffset.x + textLenght.x / 2, settings.msgOffset.y + settings.fontSizeMSG * sizeMult)
	local rectOffset = vec2(10, 10)
	if ui.time() % 1 < 0.5 then
		ui.drawRectFilled(rectPos1 - vec2(10, 0), rectPos2 + rectOffset, COLOR_MSG_BG, 10)
	else
		ui.drawRectFilled(rectPos1 - vec2(10, 0), rectPos2 + rectOffset, rgbm(0, 0, 0, 0.5), 10)
	end
	ui.dwriteDrawText(text, settings.fontSizeMSG * sizeMult, rectPos1, white)
end

----------------------------------------------------------------------------------------------- Firebase -----------------------------------------------------------------------------------------------
local boxHeight = HEIGHT_DIV._70

local function displayInGrid()
	local box1 = vec2(WIDTH_DIV._32, boxHeight)
	local nbCol = #leaderboard[1]
	local colWidth = (WIDTH_DIV._2 - WIDTH_DIV._32) / (nbCol)
	ui.pushDWriteFont("Orbitron;Weight=Black")
	ui.newLine()
	ui.dwriteTextAligned("Pos", settings.fontSize / 1.5, ui.Alignment.Center, ui.Alignment.Center, box1, false,
		settings.colorHud)
	for i = 1, nbCol do
		local textLenght = ui.measureDWriteText(leaderboard[1][i], settings.fontSize / 1.5).x
		ui.sameLine(box1.x + colWidth / 2 + colWidth * (i - 1) - textLenght / 2)
		ui.dwriteTextWrapped(leaderboard[1][i], settings.fontSize / 1.5, settings.colorHud)
	end
	ui.newLine()
	ui.popDWriteFont()
	ui.pushDWriteFont("Orbitron;Weight=Regular")
	for i = 2, #leaderboard do
		local sufix = "th"
		if i == 2 then
			sufix = "st"
		elseif i == 3 then
			sufix = "nd"
		elseif i == 4 then
			sufix = "rd"
		end
		ui.dwriteTextAligned(i - 1 .. sufix, settings.fontSize / 2, ui.Alignment.Center, ui.Alignment.Center, box1, false,
			white)
		for j = 1, #leaderboard[1] do
			local textLenght = ui.measureDWriteText(leaderboard[i][leaderboard[1][j]], settings.fontSize / 1.5).x
			ui.sameLine(box1.x + colWidth / 2 + colWidth * (j - 1) - textLenght / 2)
			ui.dwriteTextWrapped(leaderboard[i][leaderboard[1][j]], settings.fontSize / 1.5, white)
		end
	end
	ui.popDWriteFont()
	local lineHeight = math.max(ui.itemRectMax().y, HEIGHT_DIV._3)
	ui.drawLine(vec2(box1.x, HEIGHT_DIV._20), vec2(box1.x, lineHeight), white, 1)
	for i = 1, nbCol - 1 do
		ui.drawLine(vec2(box1.x + colWidth * i, HEIGHT_DIV._20), vec2(box1.x + colWidth * i, lineHeight),
			white, 2)
	end
	ui.drawLine(vec2(0, HEIGHT_DIV._12), vec2(WIDTH_DIV._2, HEIGHT_DIV._12), white, 1)
end

local function showLeaderboard()
	ui.dummy(vec2(WIDTH_DIV._20, 0))
	ui.sameLine()
	ui.setNextItemWidth(WIDTH_DIV._12)
	ui.combo("leaderboard", leaderboardName, function()
		for i = 1, #leaderboardNames do
			if ui.selectable(leaderboardNames[i], leaderboardName == leaderboardNames[i]) then
				leaderboardName = leaderboardNames[i]
				loadLeaderboard()
			end
		end
	end)
	ui.sameLine(WIDTH_DIV._4 - 120)
	if ui.button('Close', vec2(100, HEIGHT_DIV._50)) then menuStates.leaderboard = false end
	ui.newLine()
	displayInGrid()
end

----------------------------------------------------------------------------------------------- settings -----------------------------------------------------------------------------------------------
local PREVIEWS = const({ 'Message', 'Distance Bar', 'Stars' })

local preview = {
	msg = false,
	distanceBar = false,
	stars = false,
}
---@param buttonClicked string
local function updatePreviewState(buttonClicked)
	if buttonClicked == 'Message' then
		preview.msg = not preview.msg
		preview.distanceBar = false
		preview.stars = false
	elseif buttonClicked == 'Distance Bar' then
		preview.distanceBar = not preview.distanceBar
		preview.msg = false
		preview.stars = false
	elseif buttonClicked == 'Stars' then
		preview.stars = not preview.stars
		preview.msg = false
		preview.distanceBar = false
	end
end

COLOR_MSG_BG = rgbm(0.5, 0.5, 0.5, 0.5)

local online = {
	message = "",
	messageTimer = 0,
	type = 1,
	chased = false,
	officer = nil,
	level = 0,
}

local function showStarsPursuit()
	local starsColor = rgbm(1, 1, 1, os.clock() % 2 + 0.3)
	updateStarsPos()
	for i = 1, 5 do
		if i > online.level / 2 then
			ui.drawImage(starsUI.empty, starsUI.starsPos, starsUI.starsSize, rgbm(1, 1, 1, 0.2))
		else
			ui.drawImage(starsUI.full, starsUI.starsPos, starsUI.starsSize, starsColor)
		end
		starsUI.starsPos.x = starsUI.starsPos.x - settings.starsSize - starsUI.startSpace
		starsUI.starsSize.x = starsUI.starsSize.x - settings.starsSize - starsUI.startSpace
	end
end

local function distanceBarPreview()
	ui.transparentWindow("progressBar", vec2(0, 0), vec2(WINDOW_WIDTH, WINDOW_HEIGHT), function()
		local playerInFront = "You are in front"
		local text = math.floor(50) .. "m"
		local textLenght = ui.measureDWriteText(text, 30)
		ui.newLine()
		ui.dummy(vec2(WIDTH_DIV._3, HEIGHT_DIV._40))
		ui.sameLine()
		ui.beginRotation()
		ui.progressBar(125 / 250, vec2(WIDTH_DIV._3, HEIGHT_DIV._60), playerInFront)
		ui.endRotation(90, vec2(settings.msgOffset.x - WIDTH_DIV._2 - textLenght.x / 2, settings.msgOffset.y + textLenght.y / 3))
		ui.dwriteDrawText(text, 30, vec2(settings.msgOffset.x - textLenght.x / 2, settings.msgOffset.y), white)
	end)
end

local function previewMSG()
	ui.transparentWindow("previewMSG", vec2(0, 0), vec2(WINDOW_WIDTH, WINDOW_HEIGHT), function()
		ui.pushDWriteFont("Orbitron;Weight=Black")
		local textSize = ui.measureDWriteText("Messages from Police when being chased", settings.fontSizeMSG)
		local uiOffsetX = settings.msgOffset.x - textSize.x / 2
		local uiOffsetY = settings.msgOffset.y
		ui.drawRectFilled(vec2(uiOffsetX - 5, uiOffsetY - 5), vec2(uiOffsetX + textSize.x + 5, uiOffsetY + textSize.y + 5), COLOR_MSG_BG)
		ui.dwriteDrawText("Messages from Police when being chased", settings.fontSizeMSG, vec2(uiOffsetX, uiOffsetY), settings.colorHud)
		ui.popDWriteFont()
	end)
end

local function previewStars()
	ui.transparentWindow("PreviewStars", vec2(0, 0), vec2(WINDOW_WIDTH, WINDOW_HEIGHT), function()
		showStarsPursuit()
	end)
end

local function uiTab()
	ui.text('On Screen Message : ')
	settings.timeMsg = ui.slider('##' .. 'Time Msg On Screen', settings.timeMsg, 1, 15, 'Time Msg On Screen' .. ': %.0fs')
	settings.fontSizeMSG = ui.slider('##' .. 'Font Size MSG', settings.fontSizeMSG, 10, 50, 'Font Size' .. ': %.0f')
	settings.msgOffset.y = ui.slider('##' .. 'Msg On Screen Offset Y', settings.msgOffset.y, 0, WINDOW_HEIGHT, 'Msg On Screen Offset Y' .. ': %.0f')
	settings.msgOffset.x = ui.slider('##' .. 'Msg On Screen Offset X', settings.msgOffset.x, 0, WINDOW_WIDTH, 'Msg On Screen Offset X' .. ': %.0f')
	if ui.button('MSG Offset X to center') then settings.msgOffsetX = WIDTH_DIV._2 end
	ui.newLine()
	ui.text('Stars : ')
	settings.starsPos.x = ui.slider('##' .. 'Stars Offset X', settings.starsPos.x, 0, WINDOW_WIDTH, 'Stars Offset X' .. ': %.0f')
	settings.starsPos.y = ui.slider('##' .. 'Stars Offset Y', settings.starsPos.y, 0, WINDOW_HEIGHT, 'Stars Offset Y' .. ': %.0f')
	settings.starsSize = ui.slider('##' .. 'Stars Size', settings.starsSize, 10, 50, 'Stars Size' .. ': %.0f')
	ui.newLine()
	ui.text('Preview : ')
	for i = 1, #PREVIEWS do
		if ui.button(PREVIEWS[i]) then
			updatePreviewState(PREVIEWS[i])
		end
		ui.sameLine()
	end
	if preview.msg then previewMSG() end
	if preview.distanceBar then distanceBarPreview() end
	if preview.stars then previewStars() end
	ui.newLine()
end

local function settingsWindow()
	hud.size = vec2(HEIGHT_DIV._80 * settings.essentialSize, HEIGHT_DIV._80 * settings.essentialSize)
	ui.sameLine(10)
	ui.beginGroup()
	ui.newLine(15)

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
	ui.sameLine(WIDTH_DIV._6 - WIDTH_DIV._20)
	if ui.button('Close', vec2(WIDTH_DIV._25, HEIGHT_DIV._50)) then
		menuStates.main = false
		settings:save()
	end
	settings.hudOffset.x = ui.slider('##' .. 'HUD Offset X', settings.hudOffset.x, 0, WINDOW_WIDTH,'HUD Offset X' .. ': %.0f')
	settings.hudOffset.y = ui.slider('##' .. 'HUD Offset Y', settings.hudOffset.y, 0, WINDOW_HEIGHT,'HUD Offset Y' .. ': %.0f')
	settings.essentialSize = ui.slider('##' .. 'HUD Size', settings.essentialSize, 10, 50, 'HUD Size' .. ': %.0f')
	settings.fontSize = settings.essentialSize * FONT_MULT
	ui.setNextItemWidth(300)
	local colorHud = settings.colorHud
	ui.colorPicker('Theme Color', colorHud, ui.ColorPickerFlags.AlphaBar)
	ui.newLine()
	uiTab()
	ui.endGroup()
	updateHudPos()
	return 2
end

local function discordLinks()
	ui.newLine(50)
	ui.dwriteTextWrapped("For more info about the challenge click on the Discord link :", 15, white)
	if sectorManager.sector.name == 'H1' then
		if ui.textHyperlink("H1 Races Discord") then
			os.openURL("https://discord.com/channels/358562025032646659/1073622643145703434")
		end
		ui.sameLine(150)
		if ui.textHyperlink("H1 Vertex Discord") then
			os.openURL("https://discord.com/channels/358562025032646659/1088832930698231959")
		end
	elseif sectorManager.sector.name == 'BOBs SCRAPYARD' then
		if ui.textHyperlink("BOB's Scrapyard Discord") then
			os.openURL("https://discord.com/channels/358562025032646659/1096776154217709629")
		end
	elseif sectorManager.sector.name == 'DOUBLE TROUBLE' then
		if ui.textHyperlink("Double Trouble Discord") then
			os.openURL("https://discord.com/channels/358562025032646659/1097229381308530728")
		end
	end
	ui.newLine(10)
end


local function doubleTrouble()
	local players = {}
	for i = ac.getSim().carsCount - 1, 0, -1 do
		local carPlayer = ac.getCar(i)
		if carPlayer and carPlayer.isConnected and (not carPlayer.isHidingLabels) then
			if carPlayer.index ~= car.index and not isPoliceCar(carPlayer:id()) then
				table.insert(players, carPlayer)
			end
		end
	end
	if #players == 0 then
		ui.newLine()
		ui.dwriteTextWrapped("There is no other players connected", 15, white)
		ui.dwriteTextWrapped("You can't steal a car", 15, white)
	else
		if duo.teammate == nil then
			ui.setNextItemWidth(150)
			ui.combo("Teammate", duo.playerName, function()
				for i = 1, #players do
					if ui.selectable(ac.getDriverName(players[i].index), duo.teammate == players[i].index) then
						acpEvent { message = "Request", messageType = 5, yourIndex = ac.getCar(players[i].index).sessionID }
						duo.playerName = ac.getDriverName(players[i].index)
						duo.waiting = true
					end
				end
			end)
			if duo.waiting then
				ui.dwriteTextWrapped("duo.waiting for " .. duo.playerName .. " response ...", 15, rgbm.colors.yellow)
			end
		else
			ui.newLine()
			ui.dwriteTextWrapped("teammate : ", 15, white)
			ui.sameLine()
			ui.dwriteTextWrapped(ac.getDriverName(duo.teammate.index), 15, rgbm.colors.purple)
			ui.sameLine()
			if ui.button("Cancel") then
				acpEvent { message = "Cancel", messageType = 5, yourIndex = ac.getCar(duo.teammate.index).sessionID }
				duo.teammate = nil
			end
			duo.waiting = false
		end
	end
end

local function sectorSelect()
	ui.setNextItemWidth(150)
	ui.combo("Sector", sectorManager.sector.name, function()
		for i = 1, #sectors do
			if ui.selectable(sectors[i].name, sectorManager.sector == sectors[i]) then
				sectorManager.sector = sectors[i]
				sectorManager.sector:reset()
			end
		end
	end)
	ui.sameLine(WIDTH_DIV._5 - 120)
	if ui.button('Close', vec2(100, HEIGHT_DIV._50)) then
		menuStates.main = false
	end

end

local function sectorUI()
	ui.sameLine(10)
	ui.beginGroup()
	ui.newLine(15)
	sectorSelect()
	if sectorManager.sector.name == 'DOUBLE TROUBLE' then doubleTrouble() end
	if duo.request then
		ui.newLine()
		ui.dwriteTextWrapped((ac.getDriverName(duo.onlineSender.index) .. " want to steal a car with you!"), 15, rgbm.colors.purple)
		if ui.button("Accept") then
			duo.teammate = duo.onlineSender
			acpEvent{message = "Accept", messageType = 5, yourIndex = ac.getCar(duo.teammate.index).sessionID}
			duo.request = false
			sectorManager:setSector('DOUBLE TROUBLE')
		end
		ui.sameLine()
		if ui.button("Decline") then
			duo.request = false
		end
	end
	discordLinks()
	ui.newLine()
	return 1
end


-- local function drugDeliveryUI()
-- 	if drugDelivery.active and not drugDelivery.started then
-- 		textWithBackground(
-- 			"You just picked up some drugs to start the mission click on the THEFT icon! Deliver them to this location : " ..
-- 			drugDelivery.dropOffName .. "!", 1)
-- 	elseif drugDelivery.started then
-- 		textWithBackground("You are on the way to deliver the drugs to " .. drugDelivery.dropOffName .. "!", 1)
-- 	end
-- end

-- local function drugDeliveryUpdate(dt)
-- 	drawDrugLocations()
-- 	if not drugDelivery.active and car.speedKmh < 5 and isPointInCircle(car.position, drugDelivery.pickUp, 100) then
-- 		drugDelivery.active = true
-- 		drugDelivery.finalAvgSpeed = 0
-- 	elseif drugDelivery.call and drugDelivery.active and car.speedKmh > 5 and isPointInCircle(car.position, drugDelivery.pickUp, 100) then
-- 		resetDrugDelivery()
-- 		drugDelivery.distance = car.distanceDrivenSessionKm
-- 		for i = 0, 4 do drugDelivery.damage[i] = car.damage[i] end
-- 		drugDelivery.started = true
-- 	elseif drugDelivery.started and car.speedKmh < 10 and isPointInCircle(car.position, drugDelivery.dropOff, 100) then
-- 		if drugAvgSpeedValid() then
-- 			ac.sendChatMessage(" has delivered the drugs and got away with it!\nDate : " .. os.date("%d/%m/%Y"))
-- 		else
-- 			ac.sendChatMessage(" was too slow and got caught by the cops with the drugs!")
-- 		end
-- 	end
-- 	if drugDelivery.started then
-- 		if car.speedKmh > 10 then
-- 			for i = 0, 4 do
-- 				if car.damage[i] > drugDelivery.damage[i] then
-- 					ac.sendChatMessage(" has crashed and lost the drugs!")
-- 					resetDrugDelivery()
-- 					break
-- 				end
-- 			end
-- 		end
-- 	end
-- 	if drugDelivery.started then
-- 		drugDelivery.timer = drugDelivery.timer + dt
-- 		drugDelivery.avgSpeed = (car.distanceDrivenSessionKm - drugDelivery.distance) * 3600 / drugDelivery.timer
-- 	end
-- end

--------------------------------------------------------------------------------------- Race Opponent -----------------------------------------------------------------------------------------------
-- Variables --
local horn = {
	lastState = false,
	stateChangedCount = 0,
	time = 0,
	active = false,
	resquestTime = 0,
	opponentName = "",
}

local raceState = {
	inRace = false,
	opponent = nil,
	inFront = nil,
	distance = 0,
	message = false,
	time = 0,
}

local raceFinish = {
	winner = nil,
	finished = false,
	time = 0,
	opponentName = 'None',
	messageSent = false,
}

local function resetHorn()
	horn.active = false
	horn.stateChangedCount = 0
	horn.time = 0
end

local function resetRequest()
	horn.resquestTime = 0
	raceState.opponent = nil
	horn.opponentName = ""
	resetHorn()
end

local timeStartRace = 0

local function showRaceLights()
	local timing = os.clock() % 1
	if timing > 0.5 then
		ui.drawRectFilledMultiColor(vec2(0, 0), vec2(WIDTH_DIV._10, WINDOW_HEIGHT), settings.colorHud, rgbm.colors.transparent,
			rgbm.colors.transparent, settings.colorHud)
		ui.drawRectFilledMultiColor(vec2(WINDOW_WIDTH - WIDTH_DIV._10, 0), vec2(WINDOW_WIDTH, WINDOW_HEIGHT),
			rgbm.colors.transparent, settings.colorHud, settings.colorHud, rgbm.colors.transparent)
	else
		ui.drawRectFilledMultiColor(vec2(0, 0), vec2(WIDTH_DIV._10, WINDOW_HEIGHT), rgbm.colors.transparent, rgbm.colors.transparent,
			rgbm.colors.transparent, rgbm.colors.transparent)
		ui.drawRectFilledMultiColor(vec2(WINDOW_WIDTH - WIDTH_DIV._10, 0), vec2(WINDOW_WIDTH, WINDOW_HEIGHT),
			rgbm.colors.transparent, rgbm.colors.transparent, rgbm.colors.transparent, rgbm.colors.transparent)
	end
end

local function hasWin(winner)
	raceFinish.winner = winner
	raceFinish.finished = true
	raceFinish.time = 10
	raceState.inRace = false
	if winner == car then
		player.wins = player.wins + 1
		raceFinish.opponentName = ac.getDriverName(raceState.opponent.index)
		raceFinish.messageSent = false
	else
		player.losses = player.losses + 1
	end
	player:save()
	raceState.opponent = nil
end

local acpRace = ac.OnlineEvent({
	targetSessionID = ac.StructItem.int16(),
	messageType = ac.StructItem.int16(),
}, function(sender, data)
	if data.targetSessionID == car.sessionID and data.messageType == 1 then
		raceState.opponent = sender
		horn.resquestTime = 7
	elseif data.targetSessionID == car.sessionID and data.messageType == 2 then
		raceState.opponent = sender
		raceState.inRace = true
		resetHorn()
		horn.resquestTime = 0
		raceState.message = true
		raceState.time = 2
		timeStartRace = 7
	elseif data.targetSessionID == car.sessionID and data.messageType == 3 then
		hasWin(car)
	end
end)

local function whosInFront()
	if raceState.opponent == nil then return end
	local direction = cross(vec2(car.velocity.x, car.velocity.z),
		vec2(raceState.opponent.velocity.x, raceState.opponent.velocity.z))
	local midBetweenPlayers = vec2((car.position.x + raceState.opponent.position.x) / 2,
		(car.position.z + raceState.opponent.position.z) / 2)
	local midPlusDirection = vec2(midBetweenPlayers.x + direction.x, midBetweenPlayers.y + direction.y)
	local youDistanceSquared = vec2(car.position.x, car.position.z):distanceSquared(midPlusDirection)
	local opponentDistanceSquared = vec2(raceState.opponent.position.x, raceState.opponent.position.z):distanceSquared(midPlusDirection)
	if youDistanceSquared < opponentDistanceSquared then
		raceState.inFront = car
	else
		raceState.inFront = raceState.opponent
	end
end

local function hasPit()
	if not raceState.opponent or raceState.opponent and not raceState.opponent.isConnected then
		hasWin(car)
		return false
	end
	if car.isInPit then
		acpRace { targetSessionID = raceState.opponent.sessionID, messageType = 3 }
		hasWin(raceState.opponent)
		return false
	end
	return true
end

local function inRace()
	if raceState.opponent == nil then return end
	raceState.distance = vec2(car.position.x, car.position.z):distance(vec2(raceState.opponent.position.x, raceState.opponent.position.z))
	if raceState.distance < 50 then
		whosInFront()
	elseif raceState.distance > 250 then
		hasWin(raceState.inFront)
	end
end

local function hornUsage()
	if horn.time < 2 then
		horn.time = horn.time + ui.deltaTime()
		if horn.lastState ~= car.hornActive then
			horn.stateChangedCount = horn.stateChangedCount + 1
			horn.lastState = car.hornActive
		end
		if horn.stateChangedCount > 3 then
			horn.active = true
			horn.stateChangedCount = 0
			horn.time = 0
		end
	else
		resetHorn()
	end
end

local function dot(vector1, vector2)
	return vector1.x * vector2.x + vector1.y * vector2.y
end

local function resquestRace()
	local opponent = ac.getCar(ac.getCarIndexInFront(0))
	if not opponent then return end
	horn.opponentName = ac.getDriverName(opponent.index)
	if opponent and (not opponent.isHidingLabels) then
		if dot(vec2(car.look.x, car.look.z), vec2(opponent.look.x, opponent.look.z)) > 0 then
			acpRace { targetSessionID = opponent.sessionID, messageType = 1 }
			horn.resquestTime = 10
		end
	end
end

local function acceptingRace()
	if dot(vec2(car.look.x, car.look.z), vec2(raceState.opponent.look.x, raceState.opponent.look.z)) > 0 then
		acpRace { targetSessionID = raceState.opponent.sessionID, messageType = 2 }
		raceState.inRace = true
		horn.resquestTime = 0
		timeStartRace = 7
		resetHorn()
	end
end

local function raceUpdate(dt)
	if raceState.inRace and hasPit() then
		inRace()
		if raceState.time > 0 then
			raceState.time = raceState.time - dt
		elseif raceState.time < 0 then
			raceState.time = 0
		end
		if raceState.message and raceState.time == 0 then
			if raceState.opponent then
				ac.sendChatMessage(DRIVER_NAME ..
					" has started an illegal race against " .. ac.getDriverName(raceState.opponent.index) .. "!")
				raceState.message = false
			end
		end
	else
		if raceFinish.finished then
			raceFinish.time = raceFinish.time - dt
			if raceFinish.time < 0 then
				raceFinish.finished = false
				raceFinish.winner = nil
			end
		else
			hornUsage()
			if horn.resquestTime > 0 then
				horn.resquestTime = horn.resquestTime - dt
				if horn.resquestTime < 0 then resetRequest() end
				if horn.active and raceState.opponent then acceptingRace() end
			else
				if horn.active then resquestRace() end
			end
		end
	end
end

-------------------------------------------------------------------------------- overtake --------------------------------------------------------------------------------

-- Event configuration:
local REQUIRED_SPEED = const(80)

-- This function is called before event activates. Once it returns true, it’ll run:
function script.prepare(dt)
	return car.speedKmh > 60
end

-- Event state:
local overtake = {
	damage = {},
	timePassed = 0,
	totalScore = 0,
	comboMeter = 1,
	dangerouslySlowTimer = 0,
}

local carsState = {}

local function resetOvertake()
	for i = 0, 4 do overtake.damage[i] = car.damage[i] end
	if overtake.totalScore > player.overtake then
		player.overtake = math.floor(overtake.totalScore)
		if player.overtake > 10000 then
			ac.sendChatMessage("New highest Overtake score: " .. player.overtake .. " pts !")
			player.save()
		end
		-- local data = {
		-- 	["Overtake"] = highestScore,
		-- }
	end
	overtake.totalScore = 0
	overtake.comboMeter = 1
end

local function initOverTake()
	for i = 0, 4 do overtake.damage[i] = car.damage[i] end
end

local function overtakeUpdate(dt)
	if car.engineLifeLeft < 1 then
		resetOvertake()
		return
	end
	for i = 0, 4 do
		if car.damage[i] > overtake.damage[i] then
			resetOvertake()
			break
		end
	end
	overtake.timePassed = overtake.timePassed + dt

	local comboFadingRate = 0.5 * math.lerp(1, 0.1, math.lerpInvSat(car.speedKmh, 80, 200)) + car.wheelsOutside
	overtake.comboMeter = math.max(1, overtake.comboMeter - dt * comboFadingRate)

	while sim.carsCount > #carsState do
		carsState[#carsState + 1] = {}
	end

	if car.speedKmh < REQUIRED_SPEED then
		if overtake.dangerouslySlowTimer > 3 then
			resetOvertake()
			return
		end
		overtake.dangerouslySlowTimer = overtake.dangerouslySlowTimer + dt
		overtake.comboMeter = 1
		return
	else
		overtake.dangerouslySlowTimer = 0
	end

	for i = 1, ac.getSim().carsCount - 1 do
		local state = carsState[i]
		local otherCar = ac.getCar(i)
		if otherCar.isConnected and otherCar.position:closerToThan(car.position, 10) then
			local drivingAlong = math.dot(otherCar.look, car.look) > 0.2
			if not drivingAlong then
				state.drivingAlong = false

				if not state.nearMiss and otherCar.position:closerToThan(car.position, 3) then
					state.nearMiss = true

					if otherCar.position:closerToThan(car.position, 2.5) then
						overtake.comboMeter = overtake.comboMeter + 3
					else
						overtake.comboMeter = overtake.comboMeter + 1
					end
				end
			end

			if otherCar.collidedWith == 0 then
				state.collided = true
				resetOvertake()
				return
			end

			if not state.overtaken and not state.collided and state.drivingAlong then
				local posDir = (otherCar.position - car.position):normalize()
				local posDot = math.dot(posDir, otherCar.look)
				state.maxPosDot = math.max(state.maxPosDot, posDot)
				if posDot < -0.5 and state.maxPosDot > 0.5 then
					overtake.totalScore = overtake.totalScore + math.ceil(10 * overtake.comboMeter)
					overtake.comboMeter = overtake.comboMeter + 1
					state.overtaken = true
				end
			end
		else
			state.maxPosDot = -1
			state.overtaken = false
			state.collided = false
			state.drivingAlong = true
			state.nearMiss = false
		end
	end
end

local function overtakeUI(textOffset)
	local text
	local colorCombo

	if overtake.totalScore > 0 then
		text = overtake.totalScore .. " pts - " .. string.format("%d", overtake.comboMeter) .. "x"
		colorCombo = rgbm(0, 1, 0, 0.9)
	else
		text = "PB: " .. player.overtake .. "pts"
		colorCombo = rgbm(1, 1, 1, 0.9)
	end
	local textSize = ui.measureDWriteText(text, settings.fontSize)
	ui.dwriteDrawText(text, settings.fontSize, textOffset - vec2(textSize.x / 2, -hud.size.y / 13), colorCombo)
end

-- UI Update
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function flashingAlert(intensity)
	local timing = os.clock() % 1
	if timing > 0.5 then
		ui.drawRectFilledMultiColor(vec2(0, 0), vec2(WINDOW_WIDTH / intensity, WINDOW_HEIGHT), rgbm(1, 0, 0, 0.5),
			rgbm.colors.transparent, rgbm.colors.transparent, rgbm(1, 0, 0, 0.5))
		ui.drawRectFilledMultiColor(vec2(WINDOW_WIDTH - WINDOW_WIDTH / intensity, 0), vec2(WINDOW_WIDTH, WINDOW_HEIGHT),
			rgbm.colors.transparent, rgbm(1, 0, 0, 0.5), rgbm(1, 0, 0, 0.5), rgbm.colors.transparent)
	else
		ui.drawRectFilledMultiColor(vec2(0, 0), vec2(WINDOW_WIDTH / intensity, WINDOW_HEIGHT), rgbm.colors.transparent,
			rgbm.colors.transparent, rgbm.colors.transparent, rgbm.colors.transparent)
		ui.drawRectFilledMultiColor(vec2(WINDOW_WIDTH - WINDOW_WIDTH / intensity, 0), vec2(WINDOW_WIDTH, WINDOW_HEIGHT),
			rgbm.colors.transparent, rgbm.colors.transparent, rgbm.colors.transparent, rgbm.colors.transparent)
	end
end

local function distanceBar()
	local playerInFront
	if raceState.inFront == car then
		playerInFront = "You are in front"
	else
		playerInFront = ac.getDriverName(raceState.inFront.index) .. " is in front"
	end
	local text = math.floor(raceState.distance) .. "m"
	local textLenght = ui.measureDWriteText(text, 30)
	ui.newLine()
	ui.dummy(vec2(WIDTH_DIV._3, HEIGHT_DIV._40))
	ui.sameLine()
	ui.beginRotation()
	ui.progressBar(raceState.distance / 250, vec2(WIDTH_DIV._3, HEIGHT_DIV._60), playerInFront)
	ui.endRotation(90, vec2(settings.msgOffsetX - WIDTH_DIV._2 - textLenght.x / 2, settings.msgOffset.y))
	ui.dwriteDrawText(text, 30, vec2(settings.msgOffsetX - textLenght.x / 2, settings.msgOffset.y), white)
end

local function raceUI()
	ui.pushDWriteFont("Orbitron;Weight=Black")
	local displayText = false
	local text

	if timeStartRace > 0 then
		timeStartRace = timeStartRace - ui.deltaTime()
		if raceState.opponent and timeStartRace - 5 > 0 then
			text = "Align yourself with " .. ac.getDriverName(raceState.opponent.index) .. " to start the race!"
			textWithBackground(text, 1)
		else
			local number = math.floor(timeStartRace - 1)
			if number <= 0 then
				text = "GO!"
			else
				text = number .. " ..."
			end
			textWithBackground(text, 3)
		end
		if timeStartRace - 6 > 0 then showRaceLights() end
		if timeStartRace < 0 then timeStartRace = 0 end
	elseif raceState.inRace and raceState.inFront then
		distanceBar()
		if raceState.inFront == raceState.opponent then
			if raceState.distance > 190 then
				flashingAlert(math.floor((190 - raceState.distance) / 10) + 10)
			end
		end
	elseif raceFinish.finished then
		text = ac.getDriverName(raceFinish.winner.index) .. " has won the race"
		displayText = true
		if not raceFinish.messageSent and raceFinish.winner == car then
			ac.sendChatMessage(DRIVER_NAME ..
				" has just beaten " ..
				raceFinish.opponentName ..
				string.format(" in an illegal race. [Win rate: %d",
					player.wins * 100 / (player.wins + player.losses)) .. "%]")
			raceFinish.messageSent = true
			local data = {
				["Wins"] = player.wins,
				["Losses"] = player.losses,
			}
		end
	elseif horn.resquestTime > 0 and raceState.opponent then
		text = ac.getDriverName(raceState.opponent.index) ..
			" wants to challenge you to a race. To accept activate your horn twice quickly"
		displayText = true
	elseif horn.resquestTime > 0 and raceState.opponent == nil then
		text = "Waiting for " .. horn.opponentName .. " to accept the challenge"
		displayText = true
	end
	if displayText then textWithBackground(text, 1) end
	ui.popDWriteFont()
end

--------------------------------------------------------------------------------------- Police Chase --------------------------------------------------------------------------------------------------

local policeLightsPos = {
	vec2(0, 0),
	vec2(WIDTH_DIV._15, WINDOW_HEIGHT),
	vec2(WINDOW_WIDTH - WIDTH_DIV._15, 0),
	vec2(WINDOW_WIDTH, WINDOW_HEIGHT)
}

local acpPolice = ac.OnlineEvent({
	message = ac.StructItem.string(110),
	messageType = ac.StructItem.int16(),
	yourIndex = ac.StructItem.int16(),
}, function(sender, data)
	online.type = data.messageType
	if data.yourIndex == car.sessionID and data.messageType == 0 then
		online.message = data.message
		online.chased = true
		online.officer = sender
		online.messageTimer = settings.timeMsg
		policeLightsPos[2] = vec2(WIDTH_DIV._10, WINDOW_HEIGHT)
		policeLightsPos[3] = vec2(WINDOW_WIDTH - WIDTH_DIV._10, 0)
	elseif data.yourIndex == car.sessionID and data.messageType == 1 then
		online.level = tonumber(data.message)
		online.messageTimer = settings.timeMsg
		online.message = "CHASE LEVEL " .. data.message
		if online.level > 8 then
			online.color = rgbm.colors.red
		elseif online.level > 6 then
			online.color = rgbm.colors.orange
		elseif online.level > 4 then
			online.color = rgbm.colors.yellow
		else
			online.color = white
		end
	elseif data.yourIndex == car.sessionID and data.messageType == 2 then
		online.message = data.message
		online.messageTimer = settings.timeMsg
		online.chased = false
		online.officer = nil
		online.level = 0
		policeLightsPos[2] = vec2(WIDTH_DIV._6, WINDOW_HEIGHT)
		policeLightsPos[3] = vec2(WINDOW_WIDTH - WIDTH_DIV._6, 0)
	end
end)

local function showPoliceLights()
	local timing = math.floor(os.clock() * 2 % 2)
	if timing == 0 then
		ui.drawRectFilledMultiColor(policeLightsPos[1], policeLightsPos[2], rgbm(1, 0, 0, 0.5), rgbm.colors.transparent,
			rgbm.colors.transparent, rgbm(1, 0, 0, 0.5))
		ui.drawRectFilledMultiColor(policeLightsPos[3], policeLightsPos[4], rgbm.colors.transparent, rgbm(0, 0, 1, 0.5),
			rgbm(0, 0, 1, 0.5), rgbm.colors.transparent)
	else
		ui.drawRectFilledMultiColor(policeLightsPos[1], policeLightsPos[2], rgbm(0, 0, 1, 0.5), rgbm.colors.transparent,
			rgbm.colors.transparent, rgbm(0, 0, 1, 0.5))
		ui.drawRectFilledMultiColor(policeLightsPos[3], policeLightsPos[4], rgbm.colors.transparent, rgbm(1, 0, 0, 0.5),
			rgbm(1, 0, 0, 0.5), rgbm.colors.transparent)
	end
end

local function showArrestMSG()
	ui.pushDWriteFont("Orbitron;Weight=Black")
	local textArrest1 = "BUSTED!"
	local textArrest2 = "GGs! Please Go Back To Pits."
	local textArrestLenght1 = ui.measureDWriteText(textArrest1, settings.fontSizeMSG * 3)
	local textArrestLenght2 = ui.measureDWriteText(textArrest2, settings.fontSizeMSG * 3)
	ui.drawRectFilled(vec2(0, 0), vec2(WINDOW_WIDTH, WINDOW_HEIGHT), rgbm(0, 0, 0, 0.5))
	ui.dwriteDrawText(textArrest1, settings.fontSizeMSG * 3,
		vec2(WIDTH_DIV._2 - textArrestLenght1.x / 2, HEIGHT_DIV._4 - textArrestLenght1.y / 2), rgbm(1, 0, 0, 1))
	ui.dwriteDrawText(textArrest2, settings.fontSizeMSG * 3,
		vec2(WIDTH_DIV._2 - textArrestLenght2.x / 2, HEIGHT_DIV._4 + textArrestLenght2.y / 2), white)
	ui.popDWriteFont()
end


local function onlineEventMessageUI()
	if online.messageTimer > 0 then
		online.messageTimer = online.messageTimer - ui.deltaTime()
		local text = online.message
		if online.message ~= "BUSTED!" then textWithBackground(text, 1) end
		if online.type == 2 then
			if online.message == "BUSTED!" then showArrestMSG() end
			showPoliceLights()
		end
		if online.type == 1 and online.messageTimer < 3 then
			showPoliceLights()
		end
	elseif online.messageTimer < 0 then
		online.message = ""
		online.messageTimer = 0
	end
end

-------------------------------------------------------------------------------------------- HUD -------------------------------------------------------------------------------------------------------

local statOn = {
	[1] = "Distance Driven",
	[2] = "Races",
	[3] = "Overtake",
	[4] = "Sector",
}

local iconsColorOn = {
	[1] = white,
	[2] = white,
	[3] = white,
	[4] = white,
}

local countdownTime = 0
local cooldownTime = 0
local countDownState = {
	countdownOn = false,
	ready = true,
	set = true,
	go = true
}

local function countdown()
	if countDownState.countdownOn then
		if countdownTime > 0 then countdownTime = countdownTime - ui.deltaTime() end
		cooldownTime = cooldownTime - ui.deltaTime()
		if cooldownTime < 0 then
			cooldownTime = 0
			countDownState.countdownOn = false
		end
		if countdownTime < 5 and countDownState.ready == true then
			ac.sendChatMessage('***GET READY***')
			countDownState.ready = false
		elseif countdownTime < 3 and countDownState.set == true then
			ac.sendChatMessage('**SET**')
			countDownState.set = false
		elseif countdownTime < 0 and countDownState.go == true then
			ac.sendChatMessage('*GO*GO*GO*')
			countDownState.go = false
		end
	end
end

local function drawHudText()
	ui.pushDWriteFont("Orbitron;Weight=BOLD")
	local textOffset = vec2(hud.size.x / 2, hud.size.y / 4.5)
	local textSize = ui.measureDWriteText(statOn[settings.current], settings.fontSize)
	if settings.current ~= 4 then
		ui.dwriteDrawText(statOn[settings.current], settings.fontSize,
			textOffset - vec2(textSize.x / 2, 0), settings.colorHud)
	end
	if settings.current == 1 then
		local drivenKm = car.distanceDrivenSessionKm
		if drivenKm < 0.01 then drivenKm = 0 end
		textSize = ui.measureDWriteText(string.format("%.2f", drivenKm) .. " km", settings.fontSize)
		ui.dwriteDrawText(string.format("%.2f", drivenKm) .. " km", settings.fontSize,
			textOffset - vec2(textSize.x / 2, -hud.size.y / 13), rgbm(1, 1, 1, 0.9))
	elseif settings.current == 2 then
		textSize = ui.measureDWriteText(player.wins .. "Win  -  Lost" .. player.losses, settings.fontSize / 1.1)
		ui.dwriteDrawText("Win " .. player.wins .. " - Lost " .. player.losses, settings.fontSize / 1.1,
			textOffset - vec2(textSize.x / 2, -hud.size.y / 12.5), rgbm(1, 1, 1, 0.9))
	elseif settings.current == 3 then
		overtakeUI(textOffset)
	elseif settings.current == 4 then
		textSize = ui.measureDWriteText(sectorManager.sector.name, settings.fontSize)
		ui.dwriteDrawText(sectorManager.sector.name, settings.fontSize, textOffset - vec2(textSize.x / 2, 0), settings.colorHud)
		textSize = ui.measureDWriteText("Time: 00:00:000", settings.fontSize)
		ui.dwriteDrawText("Time: " .. sectorManager.sector.time, settings.fontSize, textOffset - vec2(textSize.x / 2, -hud.size.y / 13), sectorManager.sector.timeColor)
	end
	ui.popDWriteFont()
end

local stealingTime = 0
local stealMsgTime = 0

local function getClosestMission()
	local closestMission = nil
	local closestDistance = 500
	for i = 1, #sectors do
		for j = 1, #MISSION_NAMES do
			if sectors[i].name == MISSION_NAMES[j] then
				if car.position:distance(sectors[i].gates[1].pos) < closestDistance then
					closestMission = sectors[i]
					closestDistance = car.position:distance(sectors[i].gates[1].pos)
				end
				break
			end
		end
	end
	return closestMission
end

local function drawHudImages()
	iconsColorOn[1] = white
	iconsColorOn[2] = white
	iconsColorOn[3] = white
	iconsColorOn[4] = white
	local toolTipOn = false
	ui.drawImage(HUD_IMG.center, vec2(0, 0), hud.size)
	if ui.rectHovered(vec2(0, 0), vec2(hud.size.x, hud.size.y / 2)) then toolTipOn = true end
	if ui.rectHovered(hud.pos.leftPos2, hud.pos.leftPos1) then
		ui.image(HUD_IMG.left, hud.size, settings.colorHud)
		if uiState.isMouseLeftKeyClicked then
			if settings.current == 1 then settings.current = #statOn else settings.current = settings.current - 1 end
		end
	elseif ui.rectHovered(hud.pos.rightPos2, hud.pos.rightPos1) then
		ui.image(HUD_IMG.right, hud.size, settings.colorHud)
		if uiState.isMouseLeftKeyClicked then
			if settings.current == #statOn then settings.current = 1 else settings.current = settings.current + 1 end
		end
	elseif ui.rectHovered(hud.pos.theftPos2, hud.pos.theftPos1) then
		iconsColorOn[1] = settings.colorHud
		if uiState.isMouseLeftKeyClicked then
			
			if stealingTime == 0 then
				local closestMission = getClosestMission()
				if not closestMission then return end
				stealingTime = 5
				ac.sendChatMessage(MISSION_TEXT[closestMission.name].chat)
				stealMsgTime = 7
				if sectorManager.sector.name ~= "DOUBLE TROUBLE" then
					sectorManager:setSector(closestMission.name)
				elseif closestMission.name == "BOBs SCRAPYARD" then
					sectorManager:setSector("DOUBLE TROUBLE")
				end
				settings.current = 4
				-- if not drugDelivery.drawPickUp then
				-- end
				-- if drugDelivery.active and not drugDelivery.started then
				-- 	ac.sendChatMessage(" has picked up the drugs at (" .. drugDelivery.pickUpName .. ") and is on the way to the drop off! (" .. drugDelivery.dropOffName .. ")")
				-- 	drugDelivery.call = true
				-- end
			end
		end
	elseif ui.rectHovered(hud.pos.ranksPos2, hud.pos.ranksPos1) then
		iconsColorOn[2] = settings.colorHud
		if uiState.isMouseLeftKeyClicked then
			if menuStates.leaderboard then
				menuStates.leaderboard = false
			else
				if menuStates.main then
					menuStates.main = false
				end
				menuStates.leaderboard = true
				-- loadLeaderboard()
			end
		end
	elseif ui.rectHovered(hud.pos.countdownPos2, hud.pos.countdownPos1) then
		iconsColorOn[3] = settings.colorHud
		if not countDownState.countdownOn and uiState.isMouseLeftKeyClicked then
			if cooldownTime == 0 then
				countdownTime = 5
				cooldownTime = 30
				countDownState.countdownOn = true
				countDownState.ready = true
				countDownState.set = true
				countDownState.go = true
			end
			settings.current = 2
		end
	elseif ui.rectHovered(hud.pos.menuPos2, hud.pos.menuPos1) then
		iconsColorOn[4] = settings.colorHud
		if uiState.isMouseLeftKeyClicked then
			if menuStates.main then
				menuStates.main = false
			else
				if menuStates.leaderboard then menuStates.leaderboard = false end
				menuStates.main = true
			end
		end
	end
	ui.image(HUD_IMG.base, hud.size, settings.colorHud)
	ui.drawImage(HUD_IMG.theft, vec2(0, 0), hud.size, iconsColorOn[1])
	ui.drawImage(HUD_IMG.ranks, vec2(0, 0), hud.size, iconsColorOn[2])
	ui.drawImage(HUD_IMG.countdown, vec2(0, 0), hud.size, iconsColorOn[3])
	ui.drawImage(HUD_IMG.menu, vec2(0, 0), hud.size, iconsColorOn[4])
	if countDownState.countdownOn then countdown() end
	if stealingTime > 0 then
		stealingTime = stealingTime - ui.deltaTime()
	elseif stealingTime < 0 then
		stealingTime = 0
	end
	if toolTipOn then
		ui.tooltip(function()
			ui.text("Click ALT to Bring up\nThe Welcome Menu")
		end)
	end
end

local function showMsgMission()
	textWithBackground(MISSION_TEXT[sectorManager.sector.name].screen, 1)
end

local function hudUI()
	if stealMsgTime > 0 then
		showMsgMission()
		stealMsgTime = stealMsgTime - ui.deltaTime()
	elseif stealMsgTime < 0 then
		stealMsgTime = 0
	end
	ui.beginTransparentWindow("HUD", vec2(settings.hudOffset.x, settings.hudOffset.y), hud.size, true)
	drawHudImages()
	drawHudText()
	ui.endTransparentWindow()
end

-------------------------------------------------------------------------------------------- Menu --------------------------------------------------------------------------------------------

local menuSize = { vec2(WIDTH_DIV._5, HEIGHT_DIV._4), vec2(WIDTH_DIV._6, WINDOW_HEIGHT * 2 / 3), vec2(
	WIDTH_DIV._3, HEIGHT_DIV._3) }
local currentTab = 1
local buttonPressed = false

local function menu()
	ui.tabBar('MainTabBar', ui.TabBarFlags.Reorderable, function()
		ui.tabItem('Sectors', function() currentTab = sectorUI() end)
		ui.tabItem('settings', function() currentTab = settingsWindow() end)
	end)
end

local function moveMenu()
	if ui.windowHovered() and ui.mouseDown() then buttonPressed = true end
	if ui.mouseReleased() then buttonPressed = false end
	if buttonPressed then settings.menuPos = settings.menuPos + ui.mouseDelta() end
end

local function leaderboardWindow()
	ui.toolWindow('LeaderboardWindow', settings.menuPos, vec2(WIDTH_DIV._2, HEIGHT_DIV._2), true, function()
		ui.childWindow('childLeaderboard', vec2(WIDTH_DIV._2, HEIGHT_DIV._2), true, function()
			showLeaderboard()
			moveMenu()
		end)
	end)
end

--------------------------------------------------------------------------------- Welcome Menu ---------------------------------------------------------------------------------

local welcomeCardsToDisplayed = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }

local welcomeNavImgToDraw = { WELCOME_NAV_IMG.leftArrowOff, WELCOME_NAV_IMG.rightArrowOff, WELCOME_NAV_IMG.leftBoxOff, WELCOME_NAV_IMG
	.centerBoxOff, WELCOME_NAV_IMG.rightBoxOff, WELCOME_NAV_IMG.base, WELCOME_NAV_IMG.logo }

local cardOutline = {
	white,
	white,
	white,
	white,
	white,
	white,
	white,
}

local welcomeWindow = {
	size = vec2(16 * WINDOW_HEIGHT / 9, WINDOW_HEIGHT),
	topLeft = vec2(0, 0),
	topRight = vec2(WINDOW_WIDTH, 0),
	offset = vec2(0, 0),
	scale = 0.9,
	fontBold = ui.DWriteFont("Orbitron;Weight=BLACK"),
	font = ui.DWriteFont("Orbitron;Weight=REGULAR"),
	closeIMG = "https://acstuff.ru/images/icons_24/cancel.png",
	fontSize = WINDOW_HEIGHT / 35,
}


local function scaleWelcomeMenu()
	local xScale = WINDOW_WIDTH / 2560
	local yScale = WINDOW_HEIGHT / 1440
	local minScale = math.min(xScale, yScale)

	welcomeWindow.size = welcomeWindow.size * welcomeWindow.scale
	welcomeWindow.offset = vec2((WINDOW_WIDTH - welcomeWindow.size.x) / 2, (WINDOW_HEIGHT - welcomeWindow.size.y) / 2)
	minScale = minScale * welcomeWindow.scale
	for i = 1, #WELCOME_CARD_IMG_POS do
		WELCOME_CARD_IMG_POS[i][1] = WELCOME_CARD_IMG_POS[i][1] * minScale
		WELCOME_CARD_IMG_POS[i][2] = WELCOME_CARD_IMG_POS[i][2] * minScale
	end
	welcomeWindow.topLeft = WELCOME_CARD_IMG_POS[6][1] + welcomeWindow.offset + welcomeWindow.size / 100
	welcomeWindow.topRight = vec2(WELCOME_CARD_IMG_POS[6][2].x - welcomeWindow.size.x / 100,
		WELCOME_CARD_IMG_POS[6][1].y + welcomeWindow.size.y / 100) + welcomeWindow.offset
end

local function showMissionInfo(i, id)
	local leftCorner = vec2(WELCOME_CARD_IMG_POS[i + 2][1].x, WELCOME_CARD_IMG_POS[i + 2][1].y) +
		vec2(welcomeWindow.size.x / 100, welcomeWindow.size.y / 10)
	local textPos = leftCorner + welcomeWindow.size / 100
	ui.drawRectFilled(leftCorner,
		vec2(WELCOME_CARD_IMG_POS[i + 2][2].x - welcomeWindow.size.x / 100,
		leftCorner.y + ui.measureDWriteText("\n\n\n\n", settings.fontSize).y), rgbm(0, 0, 0, 0.8))
	ui.popDWriteFont()
	ui.pushDWriteFont("Orbitron;Weight=BLACK")
	ui.dwriteDrawText(MISSION_INFOS[id].start, welcomeWindow.fontSize * 0.6, textPos, white)
	textPos.y = textPos.y +
		ui.measureDWriteText(MISSION_INFOS[id].start, welcomeWindow.fontSize * 0.6).y * 2
	ui.dwriteDrawText(MISSION_INFOS[id].finish, welcomeWindow.fontSize * 0.6, textPos,
		white)
	textPos.y = textPos.y + ui.measureDWriteText(MISSION_INFOS[id].finish, welcomeWindow.fontSize * 0.6).y * 2
	ui.dwriteDrawText(MISSION_INFOS[id].time, welcomeWindow.fontSize * 0.6, textPos, white)
	ui.popDWriteFont()
end

local function drawWelcomeText()
	ui.popDWriteFont()
	ui.pushDWriteFont(welcomeWindow.font)
	ui.dwriteDrawText("WELCOME BACK,", welcomeWindow.fontSize * 0.6, welcomeWindow.topLeft, white)
	ui.popDWriteFont()
	ui.pushDWriteFont(welcomeWindow.fontBold)
	ui.dwriteDrawText(DRIVER_NAME, welcomeWindow.fontSize,
		vec2(welcomeWindow.topLeft.x,
			welcomeWindow.topLeft.y + ui.measureDWriteText("WELCOME BACK,", welcomeWindow.fontSize * 0.6).y),
		settings.colorHud)
	ui.popDWriteFont()
	ui.pushDWriteFont(welcomeWindow.font)
	ui.dwriteDrawText("CURRENT CAR", welcomeWindow.fontSize * 0.6,
		vec2(welcomeWindow.topRight.x - ui.measureDWriteText("CURRENT CAR", welcomeWindow.fontSize * 0.6).x,
			welcomeWindow.topRight.y), white)
	ui.popDWriteFont()
	ui.pushDWriteFont(welcomeWindow.fontBold)
	ui.dwriteDrawText(string.gsub(string.gsub(CAR_NAME, "%W", " "), "  ", ""), welcomeWindow.fontSize,
		vec2(
			welcomeWindow.topRight.x -
			ui.measureDWriteText(string.gsub(string.gsub(CAR_NAME, "%W", " "), "  ", ""), welcomeWindow.fontSize).x,
			welcomeWindow.topRight.y + ui.measureDWriteText("CURRENT CAR", welcomeWindow.fontSize * 0.6).y),
		settings.colorHud)
	ui.popDWriteFont()
end

local function drawWelcomeImg()
	local iconCloseColor = white
	local toolTipOn = false
	for i = 1, #cardOutline - 1 do
		if i == #cardOutline - 1 then
			cardOutline[i] = settings.colorHud
		else
			cardOutline[i] = white
		end
	end
	welcomeNavImgToDraw[1] = WELCOME_NAV_IMG.leftArrowOff
	welcomeNavImgToDraw[2] = WELCOME_NAV_IMG.rightArrowOff
	welcomeNavImgToDraw[3] = WELCOME_NAV_IMG.leftBoxOff
	welcomeNavImgToDraw[4] = WELCOME_NAV_IMG.centerBoxOff
	welcomeNavImgToDraw[5] = WELCOME_NAV_IMG.rightBoxOff
	ui.transparentWindow('WELCOME_NAV_IMG', welcomeWindow.offset, welcomeWindow.size, true, function()
		ui.childWindow('welcomeNavIMGChild', welcomeWindow.size, true, function()
			ui.drawRectFilled(WELCOME_CARD_IMG_POS[6][1], WELCOME_CARD_IMG_POS[6][2], rgbm(0, 0, 0, 0.6))
			ui.drawRectFilled(WELCOME_CARD_IMG_POS[7][1], WELCOME_CARD_IMG_POS[7][2], rgbm(0, 0, 0, 0.6))
			if ui.rectHovered(WELCOME_CARD_IMG_POS[1][1], WELCOME_CARD_IMG_POS[1][2]) then
				cardOutline[1] = settings.colorHud
				welcomeNavImgToDraw[1] = WELCOME_NAV_IMG.leftArrowOn
				if uiState.isMouseLeftKeyClicked then
					for i = 1, #welcomeCardsToDisplayed do
						if welcomeCardsToDisplayed[i] == 1 then
							welcomeCardsToDisplayed[i] = #WELCOME_CARD_IMG
						else
							welcomeCardsToDisplayed[i] = welcomeCardsToDisplayed[i] - 1
						end
					end
				end
			elseif ui.rectHovered(WELCOME_CARD_IMG_POS[2][1], WELCOME_CARD_IMG_POS[2][2]) then
				cardOutline[2] = settings.colorHud
				welcomeNavImgToDraw[2] = WELCOME_NAV_IMG.rightArrowOn
				if uiState.isMouseLeftKeyClicked then
					for i = 1, #welcomeCardsToDisplayed do
						if welcomeCardsToDisplayed[i] == #WELCOME_CARD_IMG then
							welcomeCardsToDisplayed[i] = 1
						else
							welcomeCardsToDisplayed[i] = welcomeCardsToDisplayed[i] + 1
						end
					end
				end
			elseif ui.rectHovered(WELCOME_CARD_IMG_POS[3][1], WELCOME_CARD_IMG_POS[3][2]) then
				toolTipOn = true
				cardOutline[3] = settings.colorHud
				welcomeNavImgToDraw[3] = WELCOME_NAV_IMG.leftBoxOn
				if uiState.isMouseLeftKeyClicked and uiState.ctrlDown then os.openURL(WELCOME_CARD_LINK[welcomeCardsToDisplayed[1]]) end
			elseif ui.rectHovered(WELCOME_CARD_IMG_POS[4][1], WELCOME_CARD_IMG_POS[4][2]) then
				toolTipOn = true
				cardOutline[4] = settings.colorHud
				welcomeNavImgToDraw[4] = WELCOME_NAV_IMG.centerBoxOn
				if uiState.isMouseLeftKeyClicked and uiState.ctrlDown then os.openURL(WELCOME_CARD_LINK[welcomeCardsToDisplayed[2]]) end
			elseif ui.rectHovered(WELCOME_CARD_IMG_POS[5][1], WELCOME_CARD_IMG_POS[5][2]) then
				toolTipOn = true
				cardOutline[5] = settings.colorHud
				welcomeNavImgToDraw[5] = WELCOME_NAV_IMG.rightBoxOn
				if uiState.isMouseLeftKeyClicked and uiState.ctrlDown then os.openURL(WELCOME_CARD_LINK[welcomeCardsToDisplayed[3]]) end
			elseif ui.rectHovered(WELCOME_CARD_IMG_POS[7][1], WELCOME_CARD_IMG_POS[7][2]) then
				iconCloseColor = settings.colorHud
				if uiState.isMouseLeftKeyClicked then menuStates.welcome = false end
			end
			ui.drawImage(welcomeWindow.closeIMG, WELCOME_CARD_IMG_POS[7][1] + vec2(10, 10), WELCOME_CARD_IMG_POS[7][2] - vec2(10, 10),
				iconCloseColor)
			for i = 1, #welcomeNavImgToDraw do ui.drawImage(welcomeNavImgToDraw[i], vec2(0, 0), welcomeWindow.size, cardOutline[i]) end
			for i = 1, 3 do
				if welcomeCardsToDisplayed[i] > 7 then
					ui.drawImage(WELCOME_CARD_IMG[welcomeCardsToDisplayed[i]], WELCOME_CARD_IMG_POS[i + 2][1], WELCOME_CARD_IMG_POS[i + 2][2], white)
					showMissionInfo(i, welcomeCardsToDisplayed[i])
				else
					ui.drawImage(WELCOME_CARD_IMG[welcomeCardsToDisplayed[i]], WELCOME_CARD_IMG_POS[i + 2][1], WELCOME_CARD_IMG_POS[i + 2][2], white)
				end
			end
		end)
	end)
	if toolTipOn then
		ui.tooltip(function()
			ui.text("CTRL + Left Click to open Discord link\nWhere you can find more information")
		end)
	end
end

local function drawWelcomeMenu()
	drawWelcomeImg()
	drawWelcomeText()
end

-------------------------------------------------------------------------------- UPDATE --------------------------------------------------------------------------------



function script.drawUI()
	if not shouldRun() then return end
	if ui.keyboardButtonPressed(ui.KeyIndex.Menu) then menuStates.welcome = not menuStates.welcome end
	if menuStates.welcome then
		drawWelcomeMenu()
	else
		if online.chased then showStarsPursuit() end
		hudUI()
		onlineEventMessageUI()
		raceUI()
		if menuStates.main then
			ui.toolWindow('Menu', settings.menuPos, menuSize[currentTab], true, function()
				ui.childWindow('childMenu', menuSize[currentTab], true, ui.WindowFlags.MenuBar, function()
					menu()
					moveMenu()
				end)
			end)
		end
		-- if menuStates.leaderboard then leaderboardWindow() end
	end
end

local policeCarIndex = { 0, 0, 0, 0, 0, 0 }

local function initPoliceCarIndex()
	local j = 1
	for i = ac.getSim().carsCount - 1, 0, -1 do
		local playerCarID = ac.getCarID(i)
		if playerCarID and isPoliceCar(playerCarID) then
			policeCarIndex[j] = i
			j = j + 1
		end
	end
end

local function hidePolice()
	local hideRange = 100
	for i = 1, 6 do
		local p = ac.getCar(policeCarIndex[i])
		if p and p.isConnected then
			if p.position.x > car.position.x - hideRange and p.position.z > car.position.z - hideRange and p.position.x < car.position.x + hideRange and p.position.z < car.position.z + hideRange then
				ac.hideCarLabels(i, false)
			else
				ac.hideCarLabels(i, true)
			end
		end
	end
end

local function sectorUpdate()
	if not sectorManager.started and not sectorManager.sector:hasStarted() then
		sectorManager.started = true
		sectorManager.finished = false
	end
	if not sectorManager.finished and sectorManager.sector:isFinished() then
		
		sectorManager:printToChat()
		sectorManager.finished = true
		sectorManager.started = false
	end
	if sectorManager.isDuo then
		if sectorManager.started and not sectorManager.finished and not sectorManager:hasTeammateFinished() then
			sectorManager.sector:update()
		end
	else
		if sectorManager.started and not sectorManager.finished then
			sectorManager.sector:update()
		end
	end
end

local function initUi()
	updateHudPos()
	scaleWelcomeMenu()
	updateStarsPos()
	dataLoaded['Settings'] = true
end

local function loadSettings()
	Settings.allocate(function(allocatedSetting)
		ac.log("Settings Allocated")
		settings = allocatedSetting
		initUi()
	end)
end


local function loadAllSectors()
	local url = FIREBASE_URL .. 'Sectors.json'
	if localTesting then
		local currentPath = ac.getFolder(ac.FolderID.ScriptOrigin)
		local file = io.open(currentPath .. '/sectorsResponse.json', 'r')
		if not file then
			ac.error('Failed to open sectorsResponse.json')
			return
		end
		local data = JSON.parse(file:read('*a'))
		file:close()
		local i = 1
		for key, value in pairs(data) do
			local sector = Sector.tryParse(value)
			if sector then
				sector.name = key
				sectors[i] = sector
				i = i + 1
			end
		end
		sectorManager:setSector('H1')
		dataLoaded['Sectors'] = true
	else
		web.get(url, function(err, response)
			if canProcessRequest(err, response) then
				local data = JSON.parse(response.body)
				local i = 1
				for key, value in pairs(data) do
					local sector = Sector.tryParse(value)
					if sector then
						sector.name = key
						sectors[i] = sector
						i = i + 1
					end
				end
				sectorManager:setSector('H1')
				dataLoaded['Sectors'] = true
			end
		end)
	end
end

local function loadPlayerData()
	Player.allocate(function(allocatedPlayer)
		if allocatedPlayer then
			player = allocatedPlayer
			dataLoaded['PlayerData'] = true
		end
	end)
end

function script.update(dt)
	if initialisation then
		initialisation = false
		loadSettings()
		loadAllSectors()
		loadPlayerData()
		initPoliceCarIndex()
		initOverTake()
	end
	if not shouldRun() then return end
	ac.debug('PATCH COUNT', patchCount)
	sectorUpdate()
	raceUpdate(dt)
	overtakeUpdate(dt)
	hidePolice()
end

--------------------------------------------------------------- 3D Update ---------------------------------------------------------------

local function drawGate()
	if sectorManager.sector and not sectorManager.sector:isFinished() then
		-- for i = 1, sectorManager.sector.gateCount do
		-- 	render.debugLine(sectorManager.sector.gates[i].point1, sectorManager.sector.gates[i].point2, gateColor)
		-- end
		local gateIndex = sectorManager.sector.gateIndex
		if gateIndex > sectorManager.sector.gateCount then gateIndex = sectorManager.sector.gateCount end
		render.debugLine(sectorManager.sector.gates[gateIndex].point1,
			sectorManager.sector.gates[gateIndex].point2, gateColor)
	end
end

function script.draw3D()
	if not shouldRun() then return end
	render.setBlendMode(render.BlendMode.AlphaBlend)
	render.setCullMode(render.CullMode.None)
	render.setDepthMode(render.DepthMode.Normal)
	drawGate()
end

ui.registerOnlineExtra(ui.Icons.Menu, "Menu", nil, menu, nil, ui.OnlineExtraFlags.Tool, 'ui.WindowFlags.AlwaysAutoResize')

--------------------------------------------------------------- AC Callbacks --------------------------------------------------------------
ac.onCarJumped(0, function(carIndex)
	sectorManager:reset()
	if not isPoliceCar(CAR_ID) then
		if online.chased and online.officer then
			acpPolice { message = "TP", messageType = 0, yourIndex = online.officer.sessionID }
		end
	end
end)

ac.onClientConnected(function(carIndex)
	local newCar = ac.getCarID(carIndex)
	if newCar and isPoliceCar(newCar) then
		ac.hideCarLabels(carIndex)
	end
	initPoliceCarIndex()
end)

ac.onClientDisconnected(function(carIndex)
	ac.hideCarLabels(carIndex, false)
end)

ac.onChatMessage(function(message, senderCarIndex, senderSessionID)
	if not shouldRun() then return false end
	if online.chased and online.officer then
		if (senderSessionID == online.officer.sessionID and string.find(message, 'lost')) then
			if not player.getaways then player.getaways = 0 end
			player.getaways = player.getaways + 1
			online.chased = false
			online.officer = nil
			local data = {
				["Getaway"] = player.getaways,
			}
			player.save()
		end
	end
	return false
end)
