ac.log('Script: Essential')
local sim = ac.getSim()
local car = ac.getCar(0) or error()
if not car then return end
local wheels = car.wheels or error()
local uiState = ac.getUI()

ui.setAsynchronousImagesLoading(true)

local localTesting =  ac.dirname() == 'C:\\Program Files (x86)\\Steam\\steamapps\\common\\assettocorsa\\extension\\lua\\online'
local initialisation = true

-- Constants --
local STEAMID = const(ac.getUserSteamID())
local CSP_VERSION = const(ac.getPatchVersionCode())
local CSP_MIN_VERSION = const(3044)
local CAR_ID = const(ac.getCarID(0))
local CAR_NAME = const(ac.getCarName(0))
local DRIVER_NAME = const(ac.getDriverName(0))
if CSP_VERSION < CSP_MIN_VERSION then return end

local SHARED_PLAYER_DATA = const('__ACP_SHARED_PLAYER_DATA')
local SHARED_EVENT_KEY = const('__ACP_PLAYER_SHARED_UPDATE')

local DRIVER_NATION_CODE = const(ac.getDriverNationCode(0))
local UNIT = "km/h"
local UNIT_MULT = 1
if DRIVER_NATION_CODE == "USA" or DRIVER_NATION_CODE == "GBR" then
	UNIT = "mph"
	UNIT_MULT = 0.621371
end

local STATS_FONT_SIZE = const({
	header = 30 / uiState.uiScale,
	stats = 20 / uiState.uiScale,
})

-- "https://www.youtube.com/watch?v=FMUogCkQ1qw", --car thefts
-- "https://www.youtube.com/watch?v=7YKganFmzNA", --drug dealer
-- "https://www.youtube.com/watch?v=U7Kr5E_ImGI", --bank heist

SECTORS_DATA = const({
	[1] = {
		name = "H1",
		timeLimit = 0,
		addTimeLimit = { 0, 0, 0 },
		length = 8,
		gates = {
			{ pos = { -753.56, 138.82, 3541.54 }, dir = { -0.9, 0, -0.43 }, width = 14.75, id = 1 },
			{ pos = { 3001.98, 72.4, 1027.23 }, dir = { -0.85, 0, 0.52 }, width = 15.65, id = 2 },
		},
	},
	[2] = {
		name = "DOUBLE TROUBLE",
		timeLimit = 200,
		addTimeLimit = { 0, 5, 15 },
		length = 5,
		discordLink = "https://discord.com/channels/358562025032646659/1300231481095880725",
		video = "https://www.youtube.com/watch?v=FMUogCkQ1qw",
		gates = {
			{ pos = { 767.34, 95.8, 2262.69 }, dir = { -0.82, 0, 0.56 }, width = 14.7, id = 1 },
			{ pos = { -3541.52, 23.48, -206.67 }, dir = { -0.87, 0, 0.49 }, width = 10.27, id = 2 },
		},
	},
	[3] = {
		name = "BOBs SCRAPYARD",
		timeLimit = 200,
		addTimeLimit = { 0, 5, 15 },
		length = 5,
		discordLink = "https://discord.com/channels/358562025032646659/1300207647873695755",
		video = "https://www.youtube.com/watch?v=FMUogCkQ1qw",
		gates = {
			{ pos = { 767.34, 95.8, 2262.69 }, dir = { -0.82, 0, 0.56 }, width = 14.7, id = 1 },
			{ pos = { -3541.52, 23.48, -206.67 }, dir = { -0.87, 0, 0.49 }, width = 10.27, id = 2 },
		},
	},
	[4] = {
		name = "BANK HEIST",
		timeLimit = 475,
		addTimeLimit = { 0, 40, 70 },
		length = 5,
		discordLink = "https://discord.com/channels/358562025032646659/1300207698280841266",
		video = "https://www.youtube.com/watch?v=U7Kr5E_ImGI",
		gates = {
			{ pos = { -700.04, 137.72, 3540.75 }, dir = { -1.67, 0, 1.02 }, width = 12.1, id = 1 },
			{ pos = { 5188.14, 58.22, -1640.53 }, dir = { -0.07, 0, -1 }, width = 5.56, id = 2 },
		},
	},
	[5] = {
		name = "DRUG DELIVERY",
		timeLimit = 315,
		addTimeLimit = { 0, 25, 45 },
		length = 5,
		discordLink = "https://discord.com/channels/358562025032646659/1300207870515744869",
		video = "https://www.youtube.com/watch?v=7YKganFmzNA",
		gates = {
			{ pos = { -395.08, 127.66, 3392.71 }, dir = { -0.7, 0, -0.72 }, width = 35.95, id = 1 },
			{ pos = { 585.71, -115.77, -3439.67 }, dir = { 0.99, 0, 0.03 }, width = 6.78, id = 2 },
		},
	},
})

local POLICE_CAR = const({ "crown_police", "r34police_acp24" })

local LEADERBOARDS = const({
	time = {"H1", "BOBs SCRAPYARD", "DOUBLE TROUBLE", "DRUG DELIVERY", "BANK HEIST" },
	score = { "arrests", "getaways", "overtake", "thefts", "heists", "deliveries", "elo", "kms", "time" },
})
local LEADERBOARD_NAMES = const({
	{ "Your Stats", "H1", "BOBs SCRAPYARD", "DOUBLE TROUBLE", "DRUG DELIVERY", "BANK HEIST", "arrests", "getaways", "overtake", "thefts", "heists", "deliveries", "elo", "kms", "time" },
	{ "Your Stats", "H1", "Bobs Scrapyard", "Double Trouble", "Drug Delivery", "Bank Heist", "Arrestations", "Getaways", "Overtake", "Car thefts", "Bank Heists", "Drug Deliveries", "Racing", "Distance Driven", "Time Played" },
})
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
	_8 = WINDOW_WIDTH / 8,
	_10 = WINDOW_WIDTH / 10,
	_12 = WINDOW_WIDTH / 12,
	_15 = WINDOW_WIDTH / 15,
	_20 = WINDOW_WIDTH / 20,
	_25 = WINDOW_WIDTH / 25,
	_32 = WINDOW_WIDTH / 32,
	_40 = WINDOW_WIDTH / 40,
	_50 = WINDOW_WIDTH / 50,
	_80 = WINDOW_WIDTH / 80,
	_100 = WINDOW_WIDTH / 100,
	_320 = WINDOW_WIDTH / 320,
})

local WINDOW_HEIGHT = const(sim.windowHeight / uiState.uiScale)
local HEIGHT_DIV = const({
	_2 = WINDOW_HEIGHT / 2,
	_3 = WINDOW_HEIGHT / 3,
	_4 = WINDOW_HEIGHT / 4,
	_12 = WINDOW_HEIGHT / 12,
	_14 = WINDOW_HEIGHT / 14,
	_20 = WINDOW_HEIGHT / 20,
	_24 = WINDOW_HEIGHT / 24,
	_40 = WINDOW_HEIGHT / 40,
	_50 = WINDOW_HEIGHT / 50,
	_60 = WINDOW_HEIGHT / 60,
	_70 = WINDOW_HEIGHT / 70,
	_80 = WINDOW_HEIGHT / 80,
	_100 = WINDOW_HEIGHT / 100,
	_320 = WINDOW_HEIGHT / 320,
})

local FONT_MULT = const(WINDOW_HEIGHT / 1440)

local HUD_IMG = {}
local WELCOME_NAV_IMG = {}
local WELCOME_CARD_IMG = {}

local welcomeCardsToDisplayed = { 1, 2, 3, 4, 5, 6, 7 }
local welcomeNavImgToDraw = {}

local IMAGES = const({
	welcome = {
		url = "https://github.com/ele-sage/ACP-apps/raw/refs/heads/master/images/welcome.zip",
		card = {
			"cartheft.jpg",
			"drugdealer.jpg",
			"bankheist.jpg",
			-- "aboutacp.jpg",
			"earnmoney.jpg",
			-- "leaderboard.jpg",
			"bank.jpg",
			"police.jpg",
			"buycars.jpg",
			-- "tuning.jpg",
		},
		nav = {
			"base.png",
			"logo.png",
			"leftBoxOff.png",
			"leftBoxOn.png",
			"centerBoxOff.png",
			"centerBoxOn.png",
			"rightBoxOff.png",
			"rightBoxOn.png",
			"leftArrowOff.png",
			"leftArrowOn.png",
			"rightArrowOff.png",
			"rightArrowOn.png",
		},
	},
	essential = {
		url = "https://github.com/ele-sage/ACP-apps/raw/refs/heads/master/images/essential.zip",
		hud = {
			"base.png",
			"center.png",
			"left.png",
			"right.png",
			"countdown.png",
			"menu.png",
			"ranks.png",
			"theft.png",
		},
	},
})

---@param key string
local function loadImages(key)
	web.loadRemoteAssets(IMAGES[key].url, function(err, data)
		if err then
			ac.error('Failed to load welcome images:', err)
			return
		end
		local path = data .. '\\' .. key .. '\\'
		local files = io.scanDir(path, "*")
		if key == "welcome" then
			for i, file in ipairs(files) do
				local cardIndex = table.indexOf(IMAGES.welcome.card, file)
				if cardIndex ~= nil then
					WELCOME_CARD_IMG[cardIndex] = path .. file
				elseif table.contains(IMAGES.welcome.nav, file) then
					local k = file:match('(.+)%..+')
					WELCOME_NAV_IMG[k] = path .. file
				end
			end
		elseif key == "essential" then
			for i, file in ipairs(files) do
				if table.contains(IMAGES.essential.hud, file) then
					local k = file:match('(.+)%..+')
					HUD_IMG[k] = path .. file
				end
			end
		end
	end)
end

loadImages("welcome")
loadImages("essential")

local WELCOME_CARD_LINK = const({
	"https://www.youtube.com/watch?v=FMUogCkQ1qw", --car thefts
	"https://www.youtube.com/watch?v=7YKganFmzNA", --drug dealer
	"https://www.youtube.com/watch?v=U7Kr5E_ImGI", --bank heist
	"https://discord.com/channels/358562025032646659/1299309514088120370", --earn
	"https://discord.com/channels/358562025032646659/1299335101187883100", --bank done
	"https://discord.com/channels/358562025032646659/1299310323253252117", --police done
	"https://discord.com/channels/358562025032646659/1299310123482611812", --car done
})

---@param format string
---@param time number
---@return string
local function formatTime(time, format)
	if format == 'time played' then
		local hours = math.floor(time / 3600)
		local minutes = math.floor(time % 3600 / 60)
		local seconds = math.floor(time % 60)
		local formattedTime = ''
		if hours > 0 then formattedTime = hours .. 'h ' end
		if minutes > 0 then formattedTime = formattedTime .. minutes .. 'm ' end
		formattedTime = formattedTime .. seconds .. 's'
		return formattedTime
	else
		local minutes = math.floor(time / 60)
		local seconds = math.floor(time % 60)
		local milliseconds = math.floor((time % 1) * 1000)
		return ('%02d:%02d.%03d'):format(minutes, seconds, milliseconds)
	end
end

local MISSIONS = const({
	[1] = {
		name = "BOBs SCRAPYARD",
		start = { "Steal :", "Gas Station 1 TP" },
		finish = { "Deliver :", "Red Car (Map)" },
		levels = {
			formatTime(SECTORS_DATA[3].timeLimit + SECTORS_DATA[3].addTimeLimit[3], ''),
			formatTime(SECTORS_DATA[3].timeLimit + SECTORS_DATA[3].addTimeLimit[2], ''),
			formatTime(SECTORS_DATA[3].timeLimit + SECTORS_DATA[3].addTimeLimit[1], ''),
		},
		tp= {
			[1] = { pos = vec3(785.519, 95.8002, 2235.53), dir = vec3(0.51, -0.03, -0.86) },
			[2] = { pos = vec3(787.707, 95.5171, 2240.88), dir = vec3(0.58, -0.03, -0.81) },
			[3] = { pos = vec3(790.921, 95.1569, 2247.45), dir = vec3(0.8, -0.01, -0.60) },
		},
	},
	[2] = {
		name = "DRUG DELIVERY",
		start = { "Pick Up :", "Drug Delivery TP" },
		finish = { "Drop Off :", "Pink House (Map)" },
		levels = {
			formatTime(SECTORS_DATA[5].timeLimit + SECTORS_DATA[5].addTimeLimit[3], ''),
			formatTime(SECTORS_DATA[5].timeLimit + SECTORS_DATA[5].addTimeLimit[2], ''),
			formatTime(SECTORS_DATA[5].timeLimit + SECTORS_DATA[5].addTimeLimit[1], ''),
		},
		tp = {
			[1] = { pos = vec3(-369.367, 127.557, 3405.47), dir = vec3(0.8, -0.01, 0.61) },
			[2] = { pos = vec3(-374.729, 127.558, 3413.13), dir = vec3(0.69, -0.01, 0.73) },
			[3] = { pos = vec3(-380.176, 127.557, 3419.49), dir = vec3(0.59, -0.01, 0.81) },
		},
	},
	[3] = {
		name = "BANK HEIST",
		start = { "Rob :", "Bank TP" },
		finish = { "Deliver :", "Yellow BHL (Map)" },
		levels = {
			formatTime(SECTORS_DATA[4].timeLimit + SECTORS_DATA[4].addTimeLimit[3], ''),
			formatTime(SECTORS_DATA[4].timeLimit + SECTORS_DATA[4].addTimeLimit[2], ''),
			formatTime(SECTORS_DATA[4].timeLimit + SECTORS_DATA[4].addTimeLimit[1], ''),
		},
		tp = {
			[1] = { pos = vec3(-626.316, 135.37, 3509.81), dir = vec3(0.91, 0.03, -0.4) },
			[2] = { pos = vec3(-635.369, 135.786, 3514.6), dir = vec3(0.92, 0.04, -0.39) },
			[3] = { pos = vec3(-645.117, 136.215, 3518.99), dir = vec3(0.91, 0.03, -0.42) },
		},
	},
})

local MISSION_NAMES = const({"DRUG DELIVERY", "BANK HEIST", "BOBs SCRAPYARD"})
local MISSION_TEXT = const({
	["DRUG DELIVERY"] = {
		chat = "* Picking up drugs *",
		-- intro = { "You have ", " minutes to deliver up the drugs. Deliver the drugs to the Pink House!" },
		intro = {"The deal's done! The drugs are in the car. You have ", " to drop the package at the Villa! No mistakes!"},
		failed = {
			"You're late! Even the drugs expired waiting for you.",
			"The drugs ran out of patience, unlike your slow driving.",
			"Looks like the drug deal went cold—literally.",
			"Looks like the drug deal's off... thanks to you.",
			"Even the cops stopped chasing—they got bored.",
			"You just set a new record… for being the slowest criminal ever.",
			"Hope you like walking, because you just lost your getaway ride.",
			"Maybe next time, use the GPS… or learn to drive.",
			"They say crime doesn't pay. Guess they were right.",
			"You're late... Even the cops went home.",
			"Hope you enjoyed the scenic route. Too bad it cost you the mission.",
			"Crime waits for no one... except you, apparently.",
			"Time's up, slowpoke! The loot's long gone.",
			"I hope you enjoyed your leisurely failure.",
			"You missed the mark by a mile—literally.",
			"At this speed, you might as well walk.",
		},
	},
	["BOBs SCRAPYARD"] = {
		chat = "* Stealing a " .. string.gsub(CAR_NAME, "%W", " ") .. " *",
		-- intro = { "You have ", " minutes to steal the car. Deliver the car to Bobs Scrapyard!" },
		intro = { "You cracked the car! Now you've got ", " to get it to Bob's Scrapyard! Don't stop, don't get caught!" },
		failed = {
			"Missed the car heist? Might as well try carpool karaoke next time.",
			"Car theft? More like car borrowing… indefinitely.",
			"Looks like the getaway car forgot to show up... oh wait, that's you.",
			"You've got the speed of a parked car. Try again.",
			"You've officially been overtaken... by a granny in a Prius.",
			"Getaway driver? More like get-a-way-slower driver.",
			"Looks like the car heist was a bust. Maybe try stealing a bike next time.",
			"Time's up! Maybe you should consider Uber as a career choice.",
			"Need For Speed? More like Need For a Nap.",
			"You drive like my grandma, and she doesn't drive.",
			"Criminal mastermind? More like criminally slow.",
			"Even the cops are laughing at you.",
			"Oops, looks like you lost track of time. Literally.",
			"You missed the deadline… again.",
			"Slow and steady doesn't win the race in this game.",
			"You just got smoked—by your own bad driving.",
		},
	},
	["DOUBLE TROUBLE"] = {
		chat = "* Stealing a " .. string.gsub(CAR_NAME, "%W", " ") .. " *",
		-- intro = { "You have ", " minutes to steal the car. Deliver the car to Bobs Scrapyard!" },
		intro = { "You cracked the car! Now you've got ", " to get it to Bob's Scrapyard! Don't stop, don't get caught!" },
		failed = {
			"Missed the car heist? Might as well try carpool karaoke next time.",
			"Car theft? More like car borrowing… indefinitely.",
			"Looks like the getaway car forgot to show up... oh wait, that's you.",
			"You've got the speed of a parked car. Try again.",
			"You've officially been overtaken... by a granny in a Prius.",
			"Getaway driver? More like get-a-way-slower driver.",
			"Looks like the car heist was a bust. Maybe try stealing a bike next time.",
			"Time's up! Maybe you should consider Uber as a career choice.",
			"Need For Speed? More like Need For a Nap.",
			"You drive like my grandma, and she doesn't drive.",
			"Criminal mastermind? More like criminally slow.",
			"Even the cops are laughing at you.",
			"Oops, looks like you lost track of time. Literally.",
			"You missed the deadline… again.",
			"Slow and steady doesn't win the race in this game.",
			"You just got smoked—by your own bad driving.",
		},
	},
	["BANK HEIST"] = {
		chat = "* Robbing the bank *",
		-- intro = { "You have ", " minutes to rob the bank. Deliver the loot to the Yellow BHL!" },
		intro = { "The bank's hit, the crew's in ! You've got ", " to get them and the loot to the BHL. Go, go, go!" },
		failed = {
			"At this rate, you'll be robbing piggy banks, not actual banks.",
			"The bank called—they said thanks for not bothering.",
			"Bank job? More like a piggy bank job.",
			"You're so slow, the bank restocked its vault.",
			"You've mastered the art of being fashionably late... for a robbery",
			"The only thing you're robbing is your own time.",
			"You'd make a great escape artist… if the art was staying put.",
			"If slow and steady wins the race, you still wouldn't win.",
			"That's a record! A record for being the slowest.",
			"Time's up! The cops are laughing at you from the station.",
			"You ran out of time... and talent.",
			"Mission: Failed. Maybe consider a desk job?",
			"I hope your backup plan is better than your driving.",
			"You should should stick to your day job, losser.",
			"Maybe you should have think before lighting up that joint.",
			"You should have stayed in bed today, we would have been better off... Seriously.",
		}
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
	{ vec2(2447, 58),  vec2(2500, 90) },
})

local GATE_HEIGHT_OFFSET = const(0.2)
local white = const(rgbm.colors.white)
local gateColor = const(rgbm(0, 100, 0, 10))

local vUp = const(vec3(0, 1, 0))
local vDown = const(vec3(0, -1, 0))

local menuStates = {
	welcome = true,
	main = false,
	leaderboard = false,
}

local duo = {
	teammate = nil,
	request = false,
	onlineSender = nil,
	teammateHasFinished = false,
	waiting = false,
	playerName = "Online Players",
	sentFinish = false,
}

local missionManager = {
	msgTime = 0,
	showIntro = false,
	msgFailedIndex = os.time() % 16 + 1,
	level = 3,
	tp = false
}

local function resetMissionManager()
	if not missionManager.tp then
		missionManager.msgTime = 0
		missionManager.showIntro = false
	else
		missionManager.tp = false
	end
	missionManager.msgFailedIndex = os.time() % 16 + 1
	missionManager.level = 3
end

local menuSize = { vec2(WIDTH_DIV._5, HEIGHT_DIV._4), vec2(WIDTH_DIV._6, WINDOW_HEIGHT * 2 / 3), vec2(WIDTH_DIV._2, HEIGHT_DIV._2) }
local playerStatsSubWindow = vec2(WIDTH_DIV._4 - 10, HEIGHT_DIV._2 - HEIGHT_DIV._20 - 10)

local currentTab = 1

local dataLoaded = {}
dataLoaded['Settings'] = false
dataLoaded['Leaderboard'] = false
dataLoaded['PlayerData'] = false
dataLoaded['Sectors'] = false

local openMenuKeyBind = ac.ControlButton('__ACP_OPEN_MENU_KEY_BIND', ui.KeyIndex.M)

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

local CAR_NAME_NO_UTF8 = removeUtf8Char(CAR_NAME)

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

---@param category string
---@param rows LeaderboardRow[]
---@return LeaderboardRow[]
local function sortLeaderboard(category, rows)
	if category == "time" then
		table.sort(rows, function(a, b)
			return a[2] < b[2]
		end)
		for i, row in ipairs(rows) do
			row[2] = formatTime(row[2], '')
		end
	else
		table.sort(rows, function(a, b)
			return a[2] > b[2]
		end)
	end
	return rows
end

---@type Leaderboard[]
local leaderboards = {}
---@type Leaderboard | Player
local currentLeaderboard = nil

---@class LeaderboardRow
---@field infos string[]
local LeaderboardRow = class('LeaderboardRow')

---@param category string
---@param data table
---@return LeaderboardRow
function LeaderboardRow.allocate(category, data)
	local infos = {}
	if category == "time" then
		table.insert(infos, data.Driver)
		table.insert(infos, data.Time)
		table.insert(infos, data.Car)
	else
		table.insert(infos, data.Driver)
		table.insert(infos, data.Score)
	end
	setmetatable(infos, { __index = LeaderboardRow })
	return infos
end

---@class Leaderboard
---@field name string
---@field category string
---@field header string[]
---@field rows LeaderboardRow[]
---@field rowCount integer
---@field nbCols integer
local Leaderboard = class('Leaderboard')

---@param name string
function Leaderboard.noData(name)
	local category = "score"
	local header = { "Driver", "Score" }
	local row = { "No Data", "No Data" }
	for _, cat in ipairs(LEADERBOARDS.time) do
		if cat == name then
			header = { "Driver", "Time", "Car" }
			category = "time"
			row = { "No Data", "No Data", "No Data" }
			break
		end
	end
	local leaderboard = {
		name = name,
		category = category,
		header = header,
		rows = { row },
		rowCount = 1,
		nbCols = category == "time" and 3 or 2,
	}
	setmetatable(leaderboard, { __index = Leaderboard })
	return leaderboard
end

---@param name string
---@param data table
---@return Leaderboard
function Leaderboard.tryParse(name, data)
	local rowCount = 0
	local category = "score"
	local header = { "Driver", "Score" }
	for _, cat in ipairs(LEADERBOARDS.time) do
		if cat == name then
			header = { "Driver", "Time", "Car" }
			category = "time"
			break
		end
	end
	local rows = {}
	for steamID, record in pairs(data) do
		local row = LeaderboardRow.allocate(category, record)
		table.insert(rows, row)
		rowCount = rowCount + 1
	end
	rows = sortLeaderboard(category, rows)
	local leaderboard = {
		name = name,
		category = category,
		header = header,
		rows = rows,
		rowCount = rowCount,
		nbCols = category == "time" and 3 or 2,
	}
	setmetatable(leaderboard, { __index = Leaderboard })
	return leaderboard
end

---@param name string
function Leaderboard.fetch(name)
	if leaderboards[name] then
		currentLeaderboard = leaderboards[name]
		return
	end
	if localTesting then
		local currentPath = ac.getFolder(ac.FolderID.ScriptOrigin)
		local file = io.open(currentPath .. '/response/leaderboardsResponse.json', 'r')
		if not file then
			ac.error('Failed to open leaderboardResponse.json')
			return
		end
		local data = JSON.parse(file:read('*a'))
		file:close()
		data = data[name]
		if data then
			local leaderboard = Leaderboard.tryParse(name, data)
			if leaderboard then
				leaderboards[name] = leaderboard
				currentLeaderboard = leaderboard
				return
			end
		end
		local leaderboard = Leaderboard.noData(name)
		leaderboards[name] = leaderboard
		currentLeaderboard = leaderboard
		ac.error('Failed to parse leaderboard data.')
	else
		local url = FIREBASE_URL .. 'Leaderboards/' .. name .. '.json'
		web.get(url, function(err, response)
			if canProcessRequest(err, response) then
				local data = JSON.parse(response.body)
				if data then
					local leaderboard = Leaderboard.tryParse(name, data)
					if leaderboard then
						leaderboards[name] = leaderboard
						currentLeaderboard = leaderboard
						return
					end
				end
			end
			local leaderboard = Leaderboard.noData(name)
			leaderboards[name] = leaderboard
			currentLeaderboard = leaderboard
			ac.error('No leaderboard data found:', name)
		end)
	end
end

---@param name string
function Leaderboard.allocate(name)
	Leaderboard.fetch(name)
end

local DEFAULT_SETTINGS = const({
	essentialSize = 20,
	policeSize = 20,
	hudOffset = vec2(0, 0),
	fontSize = 20 / uiState.uiScale,
	current = 1,
	colorHud = rgbm(1, 0, 0, 1),
	colorHudInverted = rgbm(0, 1, 1, 1),
	timeMsg = 10,
	msgOffset = vec2(WIDTH_DIV._2, 10),
	fontSizeMSG = 30 / uiState.uiScale,
	menuPos = vec2(0, 0),
	unit = UNIT,
	unitMult = UNIT_MULT,
	starsSize = 20,
	starsPos = vec2(WIDTH_DIV._2, 0),
	leaderboardWrapWidth = 20 / 1.5,
})

---@class Settings
---@field essentialSize number
---@field policeSize number
---@field hudOffset vec2
---@field fontSize number
---@field current number
---@field colorHud rgbm
---@field colorHudInverted rgbm
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
		fontSize = data.fontSize or (20 / uiState.uiScale),
		current = data.current or 1,
		colorHud = colorHud,
		colorHudInverted = rgbm(1 - colorHud.r, 1 - colorHud.g, 1 - colorHud.b, 1),
		timeMsg = data.timeMsg or 10,
		msgOffset = msgOffset,
		fontSizeMSG = data.fontSizeMSG or (30 / uiState.uiScale),
		menuPos = menuPos,
		unit = data.unit or UNIT,
		unitMult = data.unitMult or UNIT_MULT,
		starsSize = data.starsSize or 20,
		starsPos = starsPos,
		leaderboardWrapWidth = (data.fontSize or DEFAULT_SETTINGS.fontSize) / 1.5,
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
			ac.error('Failed to open settingsResponse.json')
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
---@field addTimeLimit number[]
---@field timeColor rgbm
---@field finalTime number
---@field startDistance number
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
		name = data.name,
		gateCount = #gates,
		gateIndex = 1,
		startTime = 0,
		time = 'Time 00:00.000',
		timeLimit = data.timeLimit,
		addTimeLimit = data.addTimeLimit,
		timeColor = white,
		startDistance = 0,
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
		local file = io.open(currentPath .. '/response/sector' .. filename, 'r')
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
	self.time = 'Time - 00:00.000'
	if self.timeLimit > 0 then
		self.time = 'lvl 3 - ' .. formatTime(self.timeLimit + self.addTimeLimit[3], '')
	end
	self.timeColor = white
	self.startDistance = 0
	self.finalTime = 0
end

function Sector:starting()
	if self.gateIndex == 2 then
		self.time = 'Time - 00:00.000'
		if self.timeLimit > 0 then
			self.time = 'lvl 3 - ' .. formatTime(self.timeLimit + self.addTimeLimit[3], '')
		end
		self.startTime = os.preciseClock()
		self.startDistance = car.distanceDrivenTotalKm
	end
end

---@return boolean
function Sector:isFinished()
	return self.gateIndex > self.gateCount and car.distanceDrivenTotalKm - self.startDistance > self.lenght
end

---@return boolean
function Sector:hasStarted()
	return self.startTime > 0
end

function Sector:updateTime()
	if self.startTime > 0 then
		local time = os.preciseClock() - self.startTime
		local lvl = 'Time'
		if self.timeLimit ~= 0 then
			time = self.timeLimit + self.addTimeLimit[3] - time
			lvl = 'lvl' .. missionManager.level
			if time < 0 then
				time = 0
				lvl = 'FAIL'
			end
		end
		local minutes = math.floor(time / 60)
		local seconds = math.floor(time % 60)
		local milliseconds = math.floor((time % 1) * 1000)
		self.time = lvl .. (' - %02d:%02d.%03d'):format(minutes, seconds, milliseconds)
	end
end

---@return integer
function Sector:isUnderTimeLimit()
	if self.timeLimit > 0 then
		local time = os.preciseClock() - self.startTime
		if time < self.timeLimit + self.addTimeLimit[1] then
			return 3
		elseif time < self.timeLimit + self.addTimeLimit[2] then
			return 2
		elseif time < self.timeLimit + self.addTimeLimit[3] then
			return 1
		end
		missionManager.level = 0
		return 0
	end
	return 1
end

function Sector:updateTimeColor()
	if self:hasStarted() then
		local underTimeLimit = self:isUnderTimeLimit()
		if underTimeLimit ~= missionManager.level then
			missionManager.level = underTimeLimit
			missionManager.msgTime = 20
		end
		if underTimeLimit == 3 or self.timeLimit == 0 then
			if self:isFinished() then
				self.timeColor = rgbm.colors.green
			else
				self.timeColor = rgbm.colors.white
			end
		elseif underTimeLimit == 2 then
			self.timeColor = rgbm.colors.yellow
		elseif underTimeLimit == 1 then
			self.timeColor = rgbm.colors.orange
		else
			self.timeColor = rgbm.colors.red
		end
	end
end

function Sector:update()
	self:updateTime()
	self:updateTimeColor()
	if self.gateIndex > self.gateCount then
		return
	end
	if self.gates[self.gateIndex]:isCrossed() then
		self.gateIndex = self.gateIndex + 1
		self:starting()
		self:updateTimeColor()
		if self:isFinished() then
			self.finalTime = os.preciseClock() - self.startTime
			local time = os.preciseClock() - self.startTime
			local lvl = 'Time'
			if self.timeLimit ~= 0 then
				time = self.timeLimit + self.addTimeLimit[3] - time
				lvl = 'lvl' .. missionManager.level
				if time < 0 then
					time = 0
					lvl = 'FAIL'
				end
			end
			self.time = lvl .. (' - %02d:%02d.%03d'):format(math.floor(self.finalTime / 60), math.floor(self.finalTime % 60),
				math.floor((self.finalTime % 1) * 1000))
		end
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
		local nameWithoutUtf8 = removeUtf8Char(carName)
		records[nameWithoutUtf8] = time
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
		records[CAR_NAME_NO_UTF8] = data
		local sectorStats = {
			name = name,
			records = records,
		}
		setmetatable(sectorStats, { __index = SectorStats })
		return sectorStats
	end
	ac.error('Failed to allocate sector stat')
	return nil
end

---@param time number
---@return boolean
function SectorStats:addRecord(time)
	if not self.records[CAR_NAME_NO_UTF8] or self.records[CAR_NAME_NO_UTF8] > time then
		self.records[CAR_NAME_NO_UTF8] = time
		return true
	end
	return false
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

local lastRegister = {
	kms = 0,
	time = os.clock(),
}

---@class Player
---@field name string
---@field sectors SectorStats[]
---@field sectorsFormated table<string, table<string, string>>
---@field arrests integer
---@field getaways integer
---@field thefts integer
---@field heists integer
---@field deliveries integer
---@field overtake integer
---@field wins integer
---@field losses integer
---@field elo integer
---@field kms number
---@field time number
---@field timePlayed string
local Player = class('Player')

---@type Player | nil
local player = nil

local sharedPlayerLayout = {
	ac.StructItem.key(SHARED_PLAYER_DATA),
	hudColor = ac.StructItem.rgbm(),
	name = ac.StructItem.string(24),
	sectorsFormated = ac.StructItem.array(ac.StructItem.struct({
		name = ac.StructItem.string(16),
		records = ac.StructItem.array(ac.StructItem.string(50), 20)
	}), 5),
	arrests = ac.StructItem.uint16(),
	getaways = ac.StructItem.uint16(),
	thefts = ac.StructItem.uint16(),
	heists = ac.StructItem.uint16(),
	deliveries = ac.StructItem.uint16(),
	overtake = ac.StructItem.uint32(),
	wins = ac.StructItem.uint16(),
	losses = ac.StructItem.uint16(),
	elo = ac.StructItem.uint16(),
	kms = ac.StructItem.float(),
	time = ac.StructItem.float(),
}

---@type Settings | nil
local settings = nil

local sharedPlayerData = ac.connect(sharedPlayerLayout, true, ac.SharedNamespace.ServerScript)

local function updateSharedPlayerData()
	if not player then return end
	local hudC = rgbm.colors.red
	if settings then
		hudC = settings.colorHud
	end
	sharedPlayerData.hudColor = hudC
	sharedPlayerData.name = player.name
	sharedPlayerData.arrests = player.arrests
	sharedPlayerData.getaways = player.getaways
	sharedPlayerData.thefts = player.thefts
	sharedPlayerData.heists = player.heists
	sharedPlayerData.deliveries = player.deliveries
	sharedPlayerData.overtake = player.overtake
	sharedPlayerData.wins = player.wins
	sharedPlayerData.losses = player.losses
	sharedPlayerData.elo = player.elo
	sharedPlayerData.kms = player.kms
	sharedPlayerData.time = player.time
	sharedPlayerData.sectorsFormated = {}
	local i = 1
	table.forEach(player.sectorsFormated, function(v, k)
		sharedPlayerData.sectorsFormated[i].name = k .. '\0'
		for j, entry in ipairs(v) do
			local carName = string.sub(entry[1], 1, 45)
			sharedPlayerData.sectorsFormated[i].records[j] = carName .. ' - ' .. entry[2] .. '\0'
		end
		i = i + 1
	end)
end

---@return Player
function Player.new()
	local _player = {
		name = DRIVER_NAME,
		sectors = {},
		sectorsFormated = {},
		arrests = 0,
		getaways = 0,
		thefts = 0,
		heists = 0,
		deliveries = 0,
		overtake = 0,
		wins = 0,
		losses = 0,
		elo = 1200,
		kms = 0,
		time = 0,
		timePlayed = formatTime(0, 'time played'),
	}
	setmetatable(_player, { __index = Player })
	return _player
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
			local sector = SectorStats.allocate(sectorName, sectorData)
			if sector then
				table.insert(sectors, sector)
			end
		end
	end
	local _player = {
		name = DRIVER_NAME,
		sectors = sectors,
		sectorsFormated = {},
		arrests = data.arrests or 0,
		getaways = data.getaways or 0,
		thefts = data.thefts or 0,
		heists = data.heists or 0,
		deliveries = data.deliveries or 0,
		overtake = data.overtake or 0,
		wins = data.wins or 0,
		losses = data.losses or 0,
		elo = data.elo or 1200,
		kms = data.kms or 0,
		time = data.time or 0,
		timePlayed = formatTime(data.time or 0, 'time played'),
	}
	setmetatable(_player, { __index = Player })
	return _player
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
		local _player = Player.tryParse(data)
		callback(_player)
	else
		web.get(url, function(err, response)
			if canProcessRequest(err, response) then
				if hasExistingData(response) then
					local data = JSON.parse(response.body)
					if data then
						local _player = Player.tryParse(data)
						callback(_player)
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
	Player.fetch(url, function(_player)
		callback(_player)
	end)
end

function Player:sortSectors()
	for _, sector in ipairs(self.sectors) do
		local entries = {}
		for carName, time in pairs(sector.records) do
			table.insert(entries, { carName, time })
		end
		table.sort(entries, function(a, b)
			return a[2] < b[2]
		end)
		for i, entry in ipairs(entries) do
			entries[i][2] = formatTime(entry[2], '')
		end
		self.sectorsFormated[sector.name] = entries
	end
end

---@return table
function Player:export()
	local kms = truncate(car.distanceDrivenSessionKm - lastRegister.kms + self.kms, 3)
	local time = math.round(os.clock() - lastRegister.time + self.time, 0)
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
	if self.heists > 0 then
		data.heists = self.heists
	end
	if self.deliveries > 0 then
		data.deliveries = self.deliveries
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
	if self.elo ~= 1200 then
		data.elo = self.elo
	end
	if kms > 0 then
		data.kms = kms
	end
	if time > 0 then
		data.time = time
	end

	lastRegister.kms = car.distanceDrivenSessionKm
	lastRegister.time = os.clock()

	local sectors = {}
	for _, sector in ipairs(self.sectors) do
		if not sector then
			break
		end
		local sectorData = sector:export()
		for k, v in pairs(sectorData) do
			sectors[k] = v
		end
	end
	if next(sectors) then
		data.sectors = sectors
	end
	self:sortSectors()
	updateSharedPlayerData()
	return data
end

function Player:save()
	local str = '{"' .. STEAMID .. '": ' .. JSON.stringify(self:export()) .. '}'
	if localTesting or patchCount > 40 then return end
	patchCount = patchCount + 1
	web.request('PATCH', FIREBASE_URL .. "Players.json", str, function(err, response)
		if err then
			ac.error(err)
			return
		end
	end)
end

---@param sectorName string
---@param time number
---@return boolean
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
		sector = SectorStats.allocate(sectorName, time)
		if not sector then return false end
		table.insert(self.sectors, sector)
		return true
	end
	return sector:addRecord(time)
end

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
local SectorManager = class('SectorManager')

---@return SectorManager
function SectorManager.new()
	local sm = {
		sector = nil,
		started = false,
		finished = false,
	}
	setmetatable(sm, { __index = SectorManager })
	return sm
end

---@return SectorManager
function SectorManager.allocate()
	return SectorManager.new()
end

function SectorManager:reset()
	duo.teammateHasFinished = false
	duo.sentFinish = false
	duo.waiting = false
	duo.request = false
	duo.onlineSender = nil
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

function SectorManager:resetDuo()
	duo.teammate = nil
	duo.request = false
	duo.onlineSender = nil
	duo.teammateHasFinished = false
	duo.waiting = false
end

function SectorManager:hasTeammateFinished()
	if duo.teammate and duo.teammateHasFinished then
		if not duo.sentFinish then
			acpEvent{message = "Finished", messageType = 5, yourIndex = ac.getCar(duo.teammate.index).sessionID}
			duo.sentFinish = true
		end
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

local function calculateElo(opponentElo, youWon)
	local k = 32
	local expectedScore = 1 / (1 + 10 ^ ((opponentElo - player.elo) / 400))
	local score = youWon and 1 or 0
	local newElo = player.elo + k * (score - expectedScore)
	return math.floor(newElo)
end

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

local function textWithBackground(text, sizeMult, height)
	ui.pushDWriteFont("Orbitron")
	local textSize = ui.measureDWriteText(text, settings.fontSizeMSG * sizeMult)
	local rectPos1 = settings.msgOffset - vec2(textSize.x / 2, 0)
	local rectPos2 = textSize + rectPos1
	local rectOffset = vec2(WIDTH_DIV._320, HEIGHT_DIV._320)
	if ui.time() % 1 < 0.5 then
		ui.drawRectFilled(rectPos1 - rectOffset, rectPos2 + rectOffset, COLOR_MSG_BG, 10)
	else
		ui.drawRectFilled(rectPos1 - rectOffset, rectPos2 + rectOffset, rgbm(0, 0, 0, 0.5), 10)
	end
	ui.dwriteDrawText(text, settings.fontSizeMSG * sizeMult, rectPos1, white)
	ui.popDWriteFont()
end

local function displayInGrid()
	local box1 = vec2(WIDTH_DIV._32, HEIGHT_DIV._70)
	local colWidth = (menuSize[currentTab].x - WIDTH_DIV._32) / currentLeaderboard.nbCols
	ui.pushDWriteFont("Orbitron;Weight=Black")
	ui.newLine()
	ui.dwriteTextWrapped("Pos", settings.leaderboardWrapWidth, settings.colorHud)
	for i = 1, #currentLeaderboard.header do
		local textLenght = ui.measureDWriteText(currentLeaderboard.header[i], settings.leaderboardWrapWidth).x
		ui.sameLine(box1.x + colWidth / 2 + colWidth * (i - 1) - textLenght / 2)
		ui.dwriteTextWrapped(currentLeaderboard.header[i], settings.leaderboardWrapWidth, settings.colorHud)
	end
	local linePos = ui.getMaxCursorY() + HEIGHT_DIV._100
	ui.drawSimpleLine(vec2(0, linePos), vec2(menuSize[currentTab].x, linePos), white, 2)
	ui.newLine()
	ui.popDWriteFont()
	ui.pushDWriteFont("Orbitron;Weight=Regular")
	for i = 1, #currentLeaderboard.rows do
		ui.dwriteTextWrapped(i, settings.leaderboardWrapWidth, white)
		for j = 1, #currentLeaderboard.rows[1] do
			local textLenght = ui.measureDWriteText(currentLeaderboard.rows[i][j], settings.leaderboardWrapWidth).x
			ui.sameLine(box1.x + colWidth / 2 + colWidth * (j - 1) - textLenght / 2)
			ui.dwriteTextWrapped(currentLeaderboard.rows[i][j], settings.leaderboardWrapWidth, white)
		end
	end
	ui.popDWriteFont()
	local lineHeight = math.max(ui.itemRectMax().y + box1.y)
	local lineOffset = box1.x * 1.5
	ui.drawSimpleLine(vec2(lineOffset, HEIGHT_DIV._20), vec2(lineOffset, lineHeight), white, 2)
	for i = 1, currentLeaderboard.nbCols - 1 do
		ui.drawSimpleLine(vec2(box1.x + colWidth * i, HEIGHT_DIV._20), vec2(box1.x + colWidth * i, lineHeight), white, 2)
	end
end

local function playerScores()
	ui.dwriteTextWrapped("Scores: ", STATS_FONT_SIZE.header, settings.colorHud)
	ui.newLine()
	ui.sameLine(WIDTH_DIV._100)
	ui.beginGroup()
	ui.dwriteTextWrapped("Arrests: ", STATS_FONT_SIZE.stats, settings.colorHudInverted)
	ui.sameLine(WIDTH_DIV._10)
	ui.dwriteTextWrapped(player.arrests, STATS_FONT_SIZE.stats, rgbm.colors.white)
	ui.dwriteTextWrapped("Getaways: ", STATS_FONT_SIZE.stats, settings.colorHudInverted)
	ui.sameLine(WIDTH_DIV._10)
	ui.dwriteTextWrapped(player.getaways, STATS_FONT_SIZE.stats, rgbm.colors.white)
	ui.dwriteTextWrapped("Car Thefts: ", STATS_FONT_SIZE.stats, settings.colorHudInverted)
	ui.sameLine(WIDTH_DIV._10)
	ui.dwriteTextWrapped(player.thefts, STATS_FONT_SIZE.stats, rgbm.colors.white)
	ui.dwriteTextWrapped("Bank Heists: ", STATS_FONT_SIZE.stats, settings.colorHudInverted)
	ui.sameLine(WIDTH_DIV._10)
	ui.dwriteTextWrapped(player.heists, STATS_FONT_SIZE.stats, rgbm.colors.white)
	ui.dwriteTextWrapped("Drug Deliveries: ", STATS_FONT_SIZE.stats, settings.colorHudInverted)
	ui.sameLine(WIDTH_DIV._10)
	ui.dwriteTextWrapped(player.deliveries, STATS_FONT_SIZE.stats, rgbm.colors.white)
	ui.dwriteTextWrapped("Overtake: ", STATS_FONT_SIZE.stats, settings.colorHudInverted)
	ui.sameLine(WIDTH_DIV._10)
	ui.dwriteTextWrapped(player.overtake, STATS_FONT_SIZE.stats, rgbm.colors.white)
	ui.dwriteTextWrapped("Race Wins: ", STATS_FONT_SIZE.stats, settings.colorHudInverted)
	ui.sameLine(WIDTH_DIV._10)
	ui.dwriteTextWrapped(player.wins, STATS_FONT_SIZE.stats, rgbm.colors.white)
	ui.dwriteTextWrapped("Race Losses: ", STATS_FONT_SIZE.stats, settings.colorHudInverted)
	ui.sameLine(WIDTH_DIV._10)
	ui.dwriteTextWrapped(player.losses, STATS_FONT_SIZE.stats, rgbm.colors.white)
	ui.dwriteTextWrapped("Racing Elo: ", STATS_FONT_SIZE.stats, settings.colorHudInverted)
	ui.sameLine(WIDTH_DIV._10)
	ui.dwriteTextWrapped(player.elo .. ' pts', STATS_FONT_SIZE.stats, rgbm.colors.white)
	ui.dwriteTextWrapped("Distance Driven: ", STATS_FONT_SIZE.stats, settings.colorHudInverted)
	ui.sameLine(WIDTH_DIV._10)
	ui.dwriteTextWrapped(player.kms .. ' kms', STATS_FONT_SIZE.stats, rgbm.colors.white)
	ui.dwriteTextWrapped("Time Played: ", STATS_FONT_SIZE.stats, settings.colorHudInverted)
	ui.sameLine(WIDTH_DIV._10)
	ui.dwriteTextWrapped(player.timePlayed, STATS_FONT_SIZE.stats, rgbm.colors.white)
	ui.endGroup()
end

local function playerTimes()
	-- ui.newLine()
	ui.dwriteTextWrapped("Sectors: ", STATS_FONT_SIZE.header, settings.colorHud)
	ui.newLine()
	ui.sameLine(WIDTH_DIV._100)
	ui.beginGroup()
	for sectorName, times in pairs(player.sectorsFormated) do
		ui.dwriteTextWrapped(sectorName .. ": ", STATS_FONT_SIZE.stats, settings.colorHud)
		ui.beginSubgroup(WIDTH_DIV._50)
		for i = 1, #times do
			ui.dwriteTextWrapped(times[i][1] .. ": ", STATS_FONT_SIZE.stats, settings.colorHudInverted)
			ui.sameLine(WIDTH_DIV._8)
			ui.dwriteTextWrapped(times[i][2], STATS_FONT_SIZE.stats, white)
		end
		ui.endSubgroup()
		ui.newLine()
	end
	ui.dummy(vec2(WIDTH_DIV._50, HEIGHT_DIV._50))
	ui.endGroup()
end

local function playerStats()
	ui.separator()
	ui.pushDWriteFont("Orbitron;Weight=Black")
	local topPosY = ui.getCursorY() - 5
	ui.childWindow('playerTimes', playerStatsSubWindow, true, ui.WindowFlags.ThinScrollbar, function()
		playerTimes()
	end)
	ui.drawSimpleLine(vec2(playerStatsSubWindow.x + WIDTH_DIV._100, topPosY), vec2(playerStatsSubWindow.x + WIDTH_DIV._100, ui.getCursorY()), rgbm(0.1, 0.1, 0.1, 0.3), 2)
	ui.sameLine(playerStatsSubWindow.x + WIDTH_DIV._50)
	ui.childWindow('playerScores', playerStatsSubWindow, true, ui.WindowFlags.ThinScrollbar, function()
		playerScores()
	end)
	ui.popDWriteFont()
end

local function showLeaderboard()
	ui.setNextItemWidth(WIDTH_DIV._12)
	ui.combo("leaderboard", currentLeaderboard.name, function()
		for i = 1, #LEADERBOARD_NAMES[2] do
			if ui.selectable(LEADERBOARD_NAMES[2][i], currentLeaderboard.name == LEADERBOARD_NAMES[2][i]) then
				if LEADERBOARD_NAMES[1][i] == "Your Stats" then
					currentLeaderboard = player
				else
					Leaderboard.allocate(LEADERBOARD_NAMES[1][i])
				end
			end
		end
	end)
	ui.sameLine(menuSize[currentTab].x - 64)
	if ui.modernButton('', vec2(48, 32), ui.ButtonFlags.PressedOnRelease, 'EXIT', 24, nil) then menuStates.leaderboard = false end
	if not currentLeaderboard then return 3 end
	if currentLeaderboard.name == player.name then
		playerStats()
	else
		displayInGrid()
	end
	return 3
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
	if ui.button('MSG Offset X to center') then settings.msgOffset.x = WIDTH_DIV._2 end
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
	ui.sameLine(menuSize[currentTab].x - 64)
	if ui.modernButton('', vec2(48, 32), ui.ButtonFlags.PressedOnRelease, 'EXIT', 24, nil) then
		menuStates.main = false
		settings:save()
	end
	ui.text('Welcome Menu Keybind : ')
	ui.sameLine()
	openMenuKeyBind:control(vec2(120, 0))
	ui.newLine()
	settings.hudOffset.x = ui.slider('##' .. 'HUD Offset X', settings.hudOffset.x, 0, WINDOW_WIDTH,'HUD Offset X' .. ': %.0f')
	settings.hudOffset.y = ui.slider('##' .. 'HUD Offset Y', settings.hudOffset.y, 0, WINDOW_HEIGHT,'HUD Offset Y' .. ': %.0f')
	settings.essentialSize = ui.slider('##' .. 'HUD Size', settings.essentialSize, 10, 50, 'HUD Size' .. ': %.0f')
	settings.fontSize = settings.essentialSize * FONT_MULT
	ui.setNextItemWidth(300)
	local colorHud = settings.colorHud
	settings.colorHudInverted = rgbm(1 - colorHud.r, 1 - colorHud.g, 1 - colorHud.b, 1)
	ui.colorPicker('Theme Color', colorHud, ui.ColorPickerFlags.AlphaBar)
	ui.newLine()
	uiTab()
	ui.endGroup()
	updateHudPos()
	return 2
end

local function discordLinks()
	ui.newLine(50)
	if sectorManager.sector.name ~= 'H1' then
		ui.dwriteTextWrapped("For more info about the challenge click on the Discord link :", 15, white)
		if ui.textHyperlink(sectorManager.sector.name .. " Discord") then
			for i = 1, #SECTORS_DATA do
				if SECTORS_DATA[i].name == sectorManager.sector.name then
					os.openURL(SECTORS_DATA[i].discordLink)
				end
			end
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
	ui.sameLine(menuSize[currentTab].x - 64)
	if ui.modernButton('', vec2(48, 32), ui.ButtonFlags.PressedOnRelease, 'EXIT', 24, nil) then
		menuStates.main = false
	end
	settings:save()
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
	ui.endGroup()
	return 1
end

--------------------------------------------------------------------------------------- Race Opponent -----------------------------------------------------------------------------------------------

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
	opponentElo = 1200,
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
	raceState.opponentElo = 1200
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

local function hasWonRace(winner)
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
	player.elo = calculateElo(raceState.opponentElo, winner == car)
	player:save()
	raceState.opponent = nil
end

local acpRace = ac.OnlineEvent({
	targetSessionID = ac.StructItem.int16(),
	messageType = ac.StructItem.int16(),
	elo = ac.StructItem.int16(),
}, function(sender, data)
	if data.targetSessionID == car.sessionID and data.messageType == 1 then
		raceState.opponent = sender
		raceState.opponentElo = data.elo
		horn.resquestTime = 7
	elseif data.targetSessionID == car.sessionID and data.messageType == 2 then
		raceState.opponent = sender
		raceState.opponentElo = data.elo
		raceState.inRace = true
		resetHorn()
		horn.resquestTime = 0
		raceState.message = true
		raceState.time = 2
		timeStartRace = 7
	elseif data.targetSessionID == car.sessionID and data.messageType == 3 then
		hasWonRace(car)
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
		hasWonRace(car)
		return false
	end
	if car.isInPit then
		acpRace { targetSessionID = raceState.opponent.sessionID, messageType = 3 }
		hasWonRace(raceState.opponent)
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
		hasWonRace(raceState.inFront)
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
			if isPoliceCar(ac.getCarID(opponent.index)) then return end
			acpRace { targetSessionID = opponent.sessionID, messageType = 1, elo = player.elo }
			horn.resquestTime = 10
		end
	end
end

local function acceptingRace()
	if dot(vec2(car.look.x, car.look.z), vec2(raceState.opponent.look.x, raceState.opponent.look.z)) > 0 then
		acpRace { targetSessionID = raceState.opponent.sessionID, messageType = 2, elo = player.elo }
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

local REQUIRED_SPEED = const(80)

function script.prepare(dt)
	return car.speedKmh > 60
end

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
			player:save()
		end
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
	ui.endRotation(90, vec2(settings.msgOffset.x - WIDTH_DIV._2 - textLenght.x / 2, settings.msgOffset.y))
	ui.dwriteDrawText(text, 30, vec2(settings.msgOffset.x - textLenght.x / 2, settings.msgOffset.y), white)
end

local function raceUI()
	ui.pushDWriteFont("Orbitron;Weight=Black")
	local displayText = false
	local text

	if timeStartRace > 0 then
		timeStartRace = timeStartRace - ui.deltaTime()
		if raceState.opponent and timeStartRace - 5 > 0 then
			text = "Align yourself with " .. ac.getDriverName(raceState.opponent.index) .. " to start the race!"
			textWithBackground(text, 1, 1)
		else
			local number = math.floor(timeStartRace - 1)
			if number <= 0 then
				text = "GO!"
			else
				text = number .. " ..."
			end
			textWithBackground(text, 3, 1)
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
	if displayText then textWithBackground(text, 1, 1) end
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
		physics.teleportCarTo(0, ac.SpawnSet.Pits)
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
		if online.message ~= "BUSTED!" then textWithBackground(text, 1, 1) end
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
		textSize = ui.measureDWriteText('Time - 00:00.000', settings.fontSize)
		ui.dwriteDrawText(sectorManager.sector.time, settings.fontSize, textOffset - vec2(textSize.x / 2, -hud.size.y / 12.5), sectorManager.sector.timeColor)
	end
	ui.popDWriteFont()
end

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
			if missionManager.msgTime == 0 then
				local closestMission = getClosestMission()
				if not closestMission then return end
				ac.sendChatMessage(MISSION_TEXT[closestMission.name].chat)
				missionManager.msgTime = 10
				missionManager.showIntro = true
				if sectorManager.sector.name ~= "DOUBLE TROUBLE" then
					sectorManager:setSector(closestMission.name)
				elseif closestMission.name == "BOBs SCRAPYARD" then
					sectorManager:setSector("DOUBLE TROUBLE")
				end
				settings.current = 4
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
	if toolTipOn then
		ui.tooltip(function()
			ui.text("Click " .. openMenuKeyBind:boundTo() .. "\nto Bring up The Welcome Menu")
		end)
	end
end

local lvlMSG = const("You're late! Don't even think about getting the full payout.\nLook at the new time limit and finish it, or don't bother showing up again!")

local function missionMsgOnScreen()
	if sectorManager.sector == nil or sectorManager.sector.name == "H1" then return end
	if sectorManager.started and missionManager.level == 0 then
		textWithBackground(MISSION_TEXT[sectorManager.sector.name].failed[missionManager.msgFailedIndex], 1, 1)
		missionManager.msgTime = 0
	elseif missionManager.msgTime > 0 then
		if missionManager.showIntro then
			textWithBackground(MISSION_TEXT[sectorManager.sector.name].intro[1] .. formatTime(sectorManager.sector.timeLimit + sectorManager.sector.addTimeLimit[3], '') .. MISSION_TEXT[sectorManager.sector.name].intro[2], 1, 1)
		else
			if not sectorManager.finished then
				textWithBackground(lvlMSG,1,2)
			end
		end
		missionManager.msgTime = missionManager.msgTime - ui.deltaTime()
		if missionManager.msgTime < 0 then
			missionManager.msgTime = 0
			missionManager.showIntro = false
		end
	end
end

local function hudUI()
	missionMsgOnScreen()
	ui.transparentWindow("HUD", settings.hudOffset, hud.size, true, function()
		drawHudImages()
		drawHudText()
	end)
end

-------------------------------------------------------------------------------------------- Menu --------------------------------------------------------------------------------------------

local function menu()
	ui.tabBar('MainTabBar', ui.TabBarFlags.Reorderable, function()
		ui.tabItem('Sectors', function() currentTab = sectorUI() end)
		ui.tabItem('settings', function() currentTab = settingsWindow() end)
	end)
end

local windowAction = 0
local leftClickDown = false
local function moveMenu()
	if ui.windowHovered(ui.HoveredFlags.ChildWindows) then
		local mousePos = ui.mouseLocalPos()
		if not leftClickDown and ui.mouseDown() then
			leftClickDown = true
			windowAction = 3
			if mousePos.y > menuSize[currentTab].y - 50 then
				if mousePos.x < 50 then
					windowAction = 1
				elseif mousePos.x > menuSize[currentTab].x - 50 then
					windowAction = 2
				end
			end
		end
		if mousePos.y > menuSize[currentTab].y - 50 then
			if mousePos.x < 50 then
				ui.setMouseCursor(ui.MouseCursor.ResizeNESW)
			elseif mousePos.x > menuSize[currentTab].x - 50 then
				ui.setMouseCursor(ui.MouseCursor.ResizeNWSE)
			end
		end
	end
	if ui.mouseReleased() then
		leftClickDown = false
		windowAction = 0
	end

	if leftClickDown then
		if windowAction == 1 then
			menuSize[currentTab].x = menuSize[currentTab].x - ui.mouseDelta().x
			menuSize[currentTab].y = menuSize[currentTab].y + ui.mouseDelta().y
			settings.menuPos.x = settings.menuPos.x + ui.mouseDelta().x
		elseif windowAction == 2 then
			menuSize[currentTab] = menuSize[currentTab] + ui.mouseDelta()
			if currentTab == 3 then
				playerStatsSubWindow.x = menuSize[currentTab].x / 2
				playerStatsSubWindow.y = menuSize[currentTab].y - HEIGHT_DIV._20 - 10
			end
		elseif windowAction == 3 then
			settings.menuPos = settings.menuPos + ui.mouseDelta()
		end
	end
end


local function leaderboardWindow()
	ui.toolWindow('LeaderboardWindow', settings.menuPos, menuSize[currentTab], false, true, function()
		currentTab = showLeaderboard()
		moveMenu()
	end)
end

--------------------------------------------------------------------------------- Welcome Menu ---------------------------------------------------------------------------------

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
	missionInfoFontSize = (WINDOW_HEIGHT / 35) * 0.6,
}


local function scaleWelcomeMenu()
	local aspectRatio = WINDOW_WIDTH / WINDOW_HEIGHT < 16 / 9
	local xScale = WINDOW_WIDTH / 2560
	local yScale = WINDOW_HEIGHT / 1440
	local minScale = aspectRatio and math.max(xScale, yScale) or math.min(xScale, yScale)

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

local timeLevelsOffset = vec2(0,0)

local function showMissionInfo(i, id)
	local leftCorner = vec2(WELCOME_CARD_IMG_POS[i + 2][1].x, WELCOME_CARD_IMG_POS[i + 2][1].y) +
		vec2(welcomeWindow.size.x / 100, welcomeWindow.size.y / 10)
	local textPos = leftCorner + welcomeWindow.size / 100
	local margin = welcomeWindow.size.x / 100
	ui.drawRectFilled(leftCorner, vec2(WELCOME_CARD_IMG_POS[i + 2][2].x - margin, WELCOME_CARD_IMG_POS[i + 2][2].y - margin), rgbm(0, 0, 0, 0.8))
	ui.popDWriteFont()
	ui.pushDWriteFont("Orbitron;Weight=BLACK")
	local textOffsetY = ui.measureDWriteText("TEXT", welcomeWindow.missionInfoFontSize).y * 2
	local textOffsetX = ui.measureDWriteText("LEVEL 3:---", welcomeWindow.missionInfoFontSize).x
	ui.dwriteDrawText(MISSIONS[id].start[1], welcomeWindow.missionInfoFontSize, textPos, settings.colorHud)
	textPos.x = textPos.x + textOffsetX
	ui.dwriteDrawText(MISSIONS[id].start[2], welcomeWindow.missionInfoFontSize, textPos, white)
	textPos.y = textPos.y + textOffsetY
	textPos.x = textPos.x - textOffsetX
	ui.dwriteDrawText(MISSIONS[id].finish[1], welcomeWindow.missionInfoFontSize, textPos, settings.colorHud)
	textPos.x = textPos.x + textOffsetX
	ui.dwriteDrawText(MISSIONS[id].finish[2], welcomeWindow.missionInfoFontSize, textPos, white)
	textPos.y = textPos.y + textOffsetY
	textPos.x = textPos.x - textOffsetX
	ui.dwriteDrawText("Time Limits :", welcomeWindow.fontSize * 0.8, textPos, settings.colorHud)
	textPos.y = textPos.y + textOffsetY
	for j = 1, #MISSIONS[id].levels do
		ui.dwriteDrawText("LEVEL " .. j .. " :" , welcomeWindow.missionInfoFontSize, textPos, settings.colorHud)
		timeLevelsOffset.y = textPos.y
		timeLevelsOffset.x = textOffsetX + textPos.x
		ui.dwriteDrawText(MISSIONS[id].levels[j], welcomeWindow.missionInfoFontSize, timeLevelsOffset, white)
		textPos.y = textPos.y + textOffsetY
	end
	ui.popDWriteFont()
end

local function drawWelcomeText()
	ui.popDWriteFont()
	ui.pushDWriteFont(welcomeWindow.font)
	ui.dwriteDrawText("WELCOME BACK,", welcomeWindow.missionInfoFontSize, welcomeWindow.topLeft, white)
	ui.popDWriteFont()
	ui.pushDWriteFont(welcomeWindow.fontBold)
	ui.dwriteDrawText(DRIVER_NAME, welcomeWindow.fontSize,
		vec2(welcomeWindow.topLeft.x,
			welcomeWindow.topLeft.y + ui.measureDWriteText("WELCOME BACK,", welcomeWindow.missionInfoFontSize).y),
		settings.colorHud)
	ui.popDWriteFont()
	ui.pushDWriteFont(welcomeWindow.font)
	ui.dwriteDrawText("CURRENT CAR", welcomeWindow.missionInfoFontSize,
		vec2(welcomeWindow.topRight.x - ui.measureDWriteText("CURRENT CAR", welcomeWindow.missionInfoFontSize).x,
			welcomeWindow.topRight.y), white)
	ui.popDWriteFont()
	ui.pushDWriteFont(welcomeWindow.fontBold)
	ui.dwriteDrawText(string.gsub(string.gsub(CAR_NAME_NO_UTF8, "%W", " "), "  ", ""), welcomeWindow.fontSize,
		vec2(
			welcomeWindow.topRight.x -
			ui.measureDWriteText(string.gsub(string.gsub(CAR_NAME_NO_UTF8, "%W", " "), "  ", ""), welcomeWindow.fontSize).x,
			welcomeWindow.topRight.y + ui.measureDWriteText("CURRENT CAR", welcomeWindow.missionInfoFontSize).y),
		settings.colorHud)
	ui.popDWriteFont()
end

---@param tpPos vec3
local function willCollide(tpPos)
	for i, c in ac.iterateCars.ordered() do
		if c.position:distanceSquared(tpPos) < 4 then
			return true
		end
	end
	return false
end

local function tpToMission(i)
	if i < 4 and car.speedKmh < 30 then
		for j = 1, #MISSIONS[i].tp do
			if not willCollide(MISSIONS[i].tp[j].pos) then
				physics.setCarPosition(0, MISSIONS[i].tp[j].pos, MISSIONS[i].tp[j].dir)
				settings.current = 4
				menuStates.welcome = false
				missionManager.tp = true
				missionManager.msgTime = 10
				missionManager.showIntro = true
				if sectorManager.sector.name ~= "DOUBLE TROUBLE" then
					sectorManager:setSector(MISSIONS[i].name)
				elseif MISSIONS[i].name == "BOBs SCRAPYARD" then
					sectorManager:setSector("DOUBLE TROUBLE")
				end
				break
			end
		end
	end
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
	welcomeNavImgToDraw[6] = WELCOME_NAV_IMG.base
	welcomeNavImgToDraw[7] = WELCOME_NAV_IMG.logo
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
				if uiState.isMouseLeftKeyClicked then tpToMission(welcomeCardsToDisplayed[1]) end
			elseif ui.rectHovered(WELCOME_CARD_IMG_POS[4][1], WELCOME_CARD_IMG_POS[4][2]) then
				toolTipOn = true
				cardOutline[4] = settings.colorHud
				welcomeNavImgToDraw[4] = WELCOME_NAV_IMG.centerBoxOn
				if uiState.isMouseLeftKeyClicked then tpToMission(welcomeCardsToDisplayed[2]) end
			elseif ui.rectHovered(WELCOME_CARD_IMG_POS[5][1], WELCOME_CARD_IMG_POS[5][2]) then
				toolTipOn = true
				cardOutline[5] = settings.colorHud
				welcomeNavImgToDraw[5] = WELCOME_NAV_IMG.rightBoxOn
				if uiState.isMouseLeftKeyClicked then tpToMission(welcomeCardsToDisplayed[3]) end
			elseif ui.rectHovered(WELCOME_CARD_IMG_POS[7][1], WELCOME_CARD_IMG_POS[7][2]) then
				iconCloseColor = settings.colorHud
				if uiState.isMouseLeftKeyClicked then menuStates.welcome = false end
			end
			ui.drawImage(welcomeWindow.closeIMG, WELCOME_CARD_IMG_POS[8][1], WELCOME_CARD_IMG_POS[8][2], iconCloseColor)
			for i = 1, #welcomeNavImgToDraw do
				ui.drawImage(welcomeNavImgToDraw[i], vec2(0, 0), welcomeWindow.size, cardOutline[i])
			end
			for i = 1, 3 do
				if welcomeCardsToDisplayed[i] < 4 then
					ui.drawImage(WELCOME_CARD_IMG[welcomeCardsToDisplayed[i]], WELCOME_CARD_IMG_POS[i + 2][1], WELCOME_CARD_IMG_POS[i + 2][2], white)
					showMissionInfo(i, welcomeCardsToDisplayed[i])
				else
					ui.drawImage(WELCOME_CARD_IMG[welcomeCardsToDisplayed[i]], WELCOME_CARD_IMG_POS[i + 2][1], WELCOME_CARD_IMG_POS[i + 2][2], white)
				end
			end
		end)
	end)
	if toolTipOn then
		for i = 1, 3 do
			if welcomeCardsToDisplayed[i] < 4 then
				ui.tooltip(function()
					ui.text("Left Click to teleport to the mission")
				end)
			end
		end
	end
end

local function drawWelcomeMenu()
	drawWelcomeImg()
	drawWelcomeText()
end

-------------------------------------------------------------------------------- UPDATE --------------------------------------------------------------------------------

local function missionFinishedWindow()
	ui.transparentWindow('MissionFinished', vec2(0, 0), vec2(WINDOW_WIDTH, HEIGHT_DIV._12), false, true, function()
		ui.pushDWriteFont("Orbitron;Weight=Black")
		local timeMsg = "FAILED"
		if missionManager.level ~= 0 then timeMsg = "LEVEL " .. missionManager.level end
		local text = sectorManager.sector.name .. " - " .. timeMsg .. os.date(" - %x")
		local textLenght = ui.measureDWriteText(text, settings.fontSizeMSG * 2)
		ui.drawRectFilled(vec2(0, 0), vec2(WINDOW_WIDTH, HEIGHT_DIV._12), rgbm(0, 0, 0, 0.5))
		ui.dwriteDrawText(text, settings.fontSizeMSG * 2, vec2(WIDTH_DIV._2 - textLenght.x / 2, HEIGHT_DIV._60), settings.colorHud)
		ui.popDWriteFont()
	end)
end

-- https://i.postimg.cc/DyKfkgBG/Boost-Meter.png V1
-- https://i.postimg.cc/pTrNt9n3/Boost-Meter.png V2
local BOOST_FRAME = const("https://i.postimg.cc/zvm1SzVM/Boost-Meter.png")
local horizontalBarParams = {
	text = '',
	pos = vec2(WIDTH_DIV._50, WINDOW_HEIGHT - HEIGHT_DIV._20),
	size = vec2(20 * 25, 20 * 5),
	delta = 0,
	activeColor = rgbm(0, 1, 0, 0.5),
	inactiveColor = rgbm(0, 0, 0, 0.3),
	total = 100,
	active = car.kersCharge * 100
}

local boostFrameParams = {
	image = BOOST_FRAME,
	pos = vec2(WIDTH_DIV._50, WINDOW_HEIGHT - HEIGHT_DIV._20),
	size = vec2(20 * 25, 20 * 5),
	color = white,
	uvStart = vec2(0, 0),
	uvEnd = vec2(1, 1)
}

local boostTextParams = {
	text = 'Boost',
	pos = vec2(WIDTH_DIV._50, WINDOW_HEIGHT - HEIGHT_DIV._20),
	letter = vec2(50, 50),
	font = 'c7_big',
	color = white,
	alignment = 0.5,
	width = 20 * 5,
	spacing = 1
}

local function boostBar()
	horizontalBarParams.active = car.kersCharge * 100
	horizontalBarParams.activeColor = rgbm(1 - car.kersCharge, car.kersCharge^2, 0, 0.7)
	-- display.rect()
	display.horizontalBar(horizontalBarParams)
	display.image(boostFrameParams)
	display.text(boostTextParams)
end

function script.drawUI()
	if not shouldRun() then return end
	-- boostBar()
	if sectorManager.sector and sectorManager.finished and sectorManager.sector.name ~= "H1" then
		missionFinishedWindow()
	end
	if menuStates.welcome then
		drawWelcomeMenu()
	else
		if online.chased then showStarsPursuit() end
		hudUI()
		onlineEventMessageUI()
		raceUI()
		if menuStates.main then
			ui.toolWindow('Menu', settings.menuPos, menuSize[currentTab], true, true, function()
				menu()
				moveMenu()
			end)
		end
		if menuStates.leaderboard then leaderboardWindow() end
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

local function updateThefts()
	if sectorManager.sector:isUnderTimeLimit() == 0 then
		return
	end
	if sectorManager.sector.name == "BOBs SCRAPYARD" or sectorManager.sector.name == "DOUBLE TROUBLE" then
		player.thefts = player.thefts + 1
	elseif sectorManager.sector.name == "BANK HEIST" then
		player.heists = player.heists + 1
	elseif sectorManager.sector.name == "DRUG DELIVERY" then
		player.deliveries = player.deliveries + 1
	end
end

local function sectorUpdate()
	if not sectorManager.started and not sectorManager.sector:hasStarted() then
		sectorManager.started = true
		sectorManager.finished = false
	end
	if not sectorManager.finished and sectorManager.sector:isFinished() then
		if sectorManager.sector.name ~= 'DOUBLE TROUBLE' or sectorManager:hasTeammateFinished() then
			updateThefts()
			sectorManager.finished = true
			sectorManager.started = false
			local shouldSave = player:addSectorRecord(sectorManager.sector.name, sectorManager.sector.finalTime)
			if shouldSave then player:save() end
		else
			if duo.teammate and not duo.sentFinish then
				acpEvent{message = "Finished", messageType = 5, yourIndex = ac.getCar(duo.teammate.index).sessionID}
				duo.sentFinish = true
			end
		end
	end
	if sectorManager.started and not sectorManager.finished then
		sectorManager.sector:update()
	end
end

local function initBoost()
	horizontalBarParams.size = vec2(settings.essentialSize * 10, settings.essentialSize)
	boostFrameParams.size = vec2(settings.essentialSize * 10, settings.essentialSize)
	boostTextParams.pos = vec2(WIDTH_DIV._50 + settings.essentialSize, WINDOW_HEIGHT - HEIGHT_DIV._20 + settings.essentialSize / 10)
	boostTextParams.letter = vec2(settings.essentialSize / 1.2, settings.essentialSize / 1.2)
	boostTextParams.width = boostFrameParams.size
end

local function initUI()
	updateHudPos()
	scaleWelcomeMenu()
	updateStarsPos()
	initBoost()
	dataLoaded['Settings'] = true
end

local function loadSettings()
	Settings.allocate(function(allocatedSetting)
		settings = allocatedSetting
		initUI()
	end)
end

local function loadAllSectors()
	for i = 1, #SECTORS_DATA do
		local sector = Sector.tryParse(SECTORS_DATA[i])
		if sector then
			sector.name = sector.name
			sectors[i] = sector
		end
	end
	sectorManager:setSector('H1')
	dataLoaded['Sectors'] = true
end

local function loadPlayerData()
	Player.allocate(function(allocatedPlayer)
		if allocatedPlayer then
			player = allocatedPlayer
			dataLoaded['PlayerData'] = true
			player:sortSectors()
			currentLeaderboard = player
			updateSharedPlayerData()
		end
	end)
end

local delay = 1

local lastTimeUpdate = os.clock()
local function updateDistanceDriven()
	if os.clock() - lastTimeUpdate > 10 then
		player.kms = truncate(car.distanceDrivenSessionKm - lastRegister.kms + player.kms, 3)
		player.time = math.round(os.clock() - lastRegister.time + player.time, 0)
		lastRegister.kms = car.distanceDrivenSessionKm
		lastRegister.time = os.clock()
		lastTimeUpdate = os.clock()
	end
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
	ac.debug('Kms', player.kms)
	ac.debug('Time', player.time)
	if delay > 0 then delay = delay - dt end
	if delay < 0 then
		delay = 0
		player:sortSectors()
		updateSharedPlayerData()
		ac.broadcastSharedEvent(SHARED_EVENT_KEY, 'update')
	end
	sectorUpdate()
	raceUpdate(dt)
	overtakeUpdate(dt)
	hidePolice()
	updateDistanceDriven()
end

--------------------------------------------------------------- 3D Update ---------------------------------------------------------------

local function drawGate()
	if sectorManager.sector and not sectorManager.sector:isFinished() then
		local gateIndex = sectorManager.sector.gateIndex
		if gateIndex > sectorManager.sector.gateCount then gateIndex = sectorManager.sector.gateCount end
		render.debugLine(sectorManager.sector.gates[gateIndex].point1,
			sectorManager.sector.gates[gateIndex].point2, gateColor)
	end
end

function script.draw3D()
	if not shouldRun() then return end
	render.setDepthMode(render.BlendMode.AlphaBlend)
	drawGate()
end

-- ui.registerOnlineExtra(ui.Icons.Menu, "Menu", nil, menu, nil, ui.OnlineExtraFlags.Tool, 'ui.WindowFlags.AlwaysAutoResize')

--------------------------------------------------------------- AC Callbacks --------------------------------------------------------------

openMenuKeyBind:onPressed(function ()
	menuStates.welcome = not menuStates.welcome
end)

ac.onCarJumped(0, function(carIndex)
	resetMissionManager()
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
			player:save()
		end
	end
	return false
end)


-- ---Adds a callback which might be called when script is unloading. Use it for some state reversion, but
-- ---don’t rely on it too much. For example, if Assetto Corsa would crash or just close rapidly, it would not
-- ---be called. It should be called when scripts reload though.
-- ---@generic T
-- ---@param callback fun(item: T)
-- ---@param item T? @Optional parameter. If provided, will be passed to callback on release, but stored with a weak reference, so it could still be GCed before that (in that case, callback won’t be called at all).
-- ---@return fun() @Call to disable callback.
-- function ac.onRelease(callback, item) end
