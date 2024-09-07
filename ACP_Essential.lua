ac.log("Disabled during development")
return
local steamID = ac.getUserSteamID()

local class = 'C'
local timeRequirement = 150
local sim = ac.getSim()
local car = ac.getCar(0)
local windowWidth = sim.windowWidth/ac.getUI().uiScale
local windowHeight = sim.windowHeight/ac.getUI().uiScale
local menuOpen = false
local leaderboardOpen = false
local cspVersion = ac.getPatchVersionCode()
local cspMinVersion = 2144
local valideCar = {"chargerpolice_acpursuit", "crown_police", "bk_for_f450_21"}
local fontMultiplier = windowHeight/1440
local carID = ac.getCarID(0)
local wheels = car.wheels
local playerData = {}
local welcomeClosed = false

if carID == valideCar[1] or carID == valideCar[2] or carID == valideCar[3] or cspVersion < cspMinVersion then return end

local carVersion = "Rental"

local stockHash256 = {
    "49f0d0e1683d338c719cc5c5cb29bd2562e766eeb12f9f333075482625621dfb",
    "008461cbca3bbbe5469edafd97d3beba31d73293f793bd595319ca34196e1443",
    "0d5a20c2e936f9aab941e5c2ee450daf6322cdd8f18d1a44ac4687d048b59d77",
    "6f56567669dfa90bb67fbc7be102f4508457af3990015a70160ba3cb26887993",
    "3b41c5f96b59f862a176dcfb365a453f46e695a37829a16d0d05d899548463dd",
    "c651de6887419c2c103cc1cd2b0bac8df9a20e3f81254a7737008095372642b4",
    "236578882256b20a3b9698c9bec510da21c9a9da52324c06b22f3712e8b8ab49",
    "58be1d2dd3de57fa33a6233eeac61cdb2267c3d3130866eb8ae86196e1791e9b",
    "68d4063b0e71df24850c8bf6d9928eeafe5a917bee49775a49b6fbc86daef322",
    "06d7e9d3cb2a9bbaf21c9bbeda7654d68fdd3ef9b58852b769f03aff775ae35b",
    "f069f3cbd41fe0a4caa5799e75d2503682aa82b45085680390f370b7ead4e8fc",
    "57b813694499530b1550c208762c24c119654696c03f0ce1fffd229816468f7e",
    "8c54420f3c1818387c535417ed1f2b74a1d2781a3072c78cb8fac945cb8732d9",
}

local tunedHash256 = {
    "3ab92c7b2643885126106f0954946b9826b055a7eb12463c679e4062fee9e3a2",
    "b3555528f97ebff84b48a8bcfedb21372b6a3e98bae75a421c0c084819497a56",
    "c8f88adeacd0421984cf04d4ee25f79696d16590b4adbe113455a2a9b0bd0f95",
    "404b4999855761d4875e35ee25b8a03d4d72d65e9dd696e9f154942af40ec83f",
    "2a4c6a0c8c4b13b191dd1309b9423265f302c6add266b714701e16c77d3a7ae4",
    "e43fa68ad0768ae4d88380e6bc6aca218162d0ba9c8e8a1afac1aac9c2035546",
    "a73c494f6a6d262bb0aacba68947ad2c1fcfa9a49ea586b8865a098e2e9a7760",
    "286ff2d6ed38c8ed1212079d91865be65a6587200b364d363258380eb6221346",
    "e589eb21e899c7e661de9072aa5e80c6266f7ca144184a00cb5442743672a9c3",
    "5dcdc1fafcf76c3684da7d3dee09ec10a077c57073f8bc6cb035d3f0fe1ac23f",
    "992ae5200fe88a458733a3ab0a973a0a76c62c4b3057f351f50c4b636c2a5333",
    "00e5386e6a5ba94b950f35391128e2ba7409f47023af411a0aeb0232a5437431",
    "2a6a1f1ce7ecf5cb8fbe81a9b10f468f28b5dbbad373000a3ea2c774d26e4093",
}

local driftHash256 = {
    "fe04aab967c373de4580271d88e9f26d2ba463a29ccc03a30d1fd3e708265c07",
    "2907ae504e794d36a9fed6eed317527ba10eb2b9c040d70634d37c5968c460f7",
    "b5d95b03324aa04a4f8330f79869295a31bcf984bbabfa7d1b3387a477b9b99f",
    "fb2cd39d5d8311e1abc8e9d8ca156faa046d9f4e6b017fafb4ed2dc2629d8267",
    "9d452cec475af6a7aa99daa047948e874250f1e724962a4fa45934f65b2345f0",
    "91d494330244fb95867039588303eb21a863dc62b68342e840a9df5cfb7c5845",
    "76dde11d01c607befca128b269bdd659268fef564309ca43991fa2dd265b5bdd",
    "e47b0704f3a64ccde3d48e4396a01663dd1b809aa620b071fa1ec734f2a35830",
    "25ba03f4babc88184b86f37d6022423a547f08971e990341a3bf54addf2f64b5",
    "9010ddea5fbf187a52afa7a6e7d31d2dd4adf8a2c3a49d7bd1736cb758cfa665",
    "6467223e5a187bc7d5bd400557446e76a6bc47e08603fd86ea6eaff946e1f6a7",
}

local function checkHash256()
	local carDataPath = ac.getFolder(ac.FolderID.ContentCars) .. '/' .. ac.getCarID(0) .. '/data.acd'
    local carHash256 = ac.checksumSHA256(io.load(carDataPath))
    
    for i, hash in ipairs(stockHash256) do
        if hash == carHash256 then
            carVersion = "Stock"
            break
        end
    end
    for i, hash in ipairs(tunedHash256) do
        if hash == carHash256 then
            carVersion = "Tuned"
            break
        end
    end
    for i, hash in ipairs(driftHash256) do
        if hash == carHash256 then
            carVersion = "Drift"
            break
        end
    end
    table.clear(stockHash256)
    table.clear(tunedHash256)
    table.clear(driftHash256)
end

local highestScore = 0
local driftState = {
	bestScore = 0,
	lastScore = 0,
	valid = true,
}

------------------------------------------------------------------------- JSON Utils -------------------------------------------------------------------------

local json = {}

-- Internal functions.

local function kind_of(obj)
  if type(obj) ~= 'table' then return type(obj) end
  local i = 1
  for _ in pairs(obj) do
    if obj[i] ~= nil then i = i + 1 else return 'table' end
  end
  if i == 1 then return 'table' else return 'array' end
end

local function escape_str(s)
  local in_char  = {'\\', '"', '/', '\b', '\f', '\n', '\r', '\t'}
  local out_char = {'\\', '"', '/',  'b',  'f',  'n',  'r',  't'}
  for i, c in ipairs(in_char) do
    s = s:gsub(c, '\\' .. out_char[i])
  end
  return s
end

-- Returns pos, did_find; there are two cases:
-- 1. Delimiter found: pos = pos after leading space + delim; did_find = true.
-- 2. Delimiter not found: pos = pos after leading space;     did_find = false.
-- This throws an error if err_if_missing is true and the delim is not found.
local function skip_delim(str, pos, delim, err_if_missing)
  pos = pos + #str:match('^%s*', pos)
  if str:sub(pos, pos) ~= delim then
    if err_if_missing then
      error('Expected ' .. delim .. ' near position ' .. pos)
    end
    return pos, false
  end
  return pos + 1, true
end

-- Expects the given pos to be the first character after the opening quote.
-- Returns val, pos; the returned pos is after the closing quote character.
local function parse_str_val(str, pos, val)
  val = val or ''
  local early_end_error = 'End of input found while parsing string.'
  if pos > #str then error(early_end_error) end
  local c = str:sub(pos, pos)
  if c == '"'  then return val, pos + 1 end
  if c ~= '\\' then return parse_str_val(str, pos + 1, val .. c) end
  -- We must have a \ character.
  local esc_map = {b = '\b', f = '\f', n = '\n', r = '\r', t = '\t'}
  local nextc = str:sub(pos + 1, pos + 1)
  if not nextc then error(early_end_error) end
  return parse_str_val(str, pos + 2, val .. (esc_map[nextc] or nextc))
end

-- Returns val, pos; the returned pos is after the number's final character.
local function parse_num_val(str, pos)
  local num_str = str:match('^-?%d+%.?%d*[eE]?[+-]?%d*', pos)
  local val = tonumber(num_str)
  if not val then error('Error parsing number at position ' .. pos .. '.') end
  return val, pos + #num_str
end


-- Public values and functions.

function json.stringify(obj, as_key)
  local s = {}  -- We'll build the string as an array of strings to be concatenated.
  local kind = kind_of(obj)  -- This is 'array' if it's an array or type(obj) otherwise.
  if kind == 'array' then
    if as_key then error('Can\'t encode array as key.') end
    s[#s + 1] = '['
    for i, val in ipairs(obj) do
      if i > 1 then s[#s + 1] = ', ' end
      s[#s + 1] = json.stringify(val)
    end
    s[#s + 1] = ']'
  elseif kind == 'table' then
    if as_key then error('Can\'t encode table as key.') end
    s[#s + 1] = '{'
    for k, v in pairs(obj) do
      if #s > 1 then s[#s + 1] = ', ' end
      s[#s + 1] = json.stringify(k, true)
      s[#s + 1] = ':'
      s[#s + 1] = json.stringify(v)
    end
    s[#s + 1] = '}'
  elseif kind == 'string' then
    return '"' .. escape_str(obj) .. '"'
  elseif kind == 'number' then
    if as_key then return '"' .. tostring(obj) .. '"' end
    return tostring(obj)
  elseif kind == 'boolean' then
    return tostring(obj)
  elseif kind == 'nil' then
    return 'null'
  else
    error('Unjsonifiable type: ' .. kind .. '.')
  end
  return table.concat(s)
end

json.null = {}  -- This is a one-off table to represent the null value.

function json.parse(str, pos, end_delim)
  pos = pos or 1
  if pos > #str then error('Reached unexpected end of input.') end
  local pos = pos + #str:match('^%s*', pos)  -- Skip whitespace.
  local first = str:sub(pos, pos)
  if first == '{' then  -- Parse an object.
    local obj, key, delim_found = {}, true, true
    pos = pos + 1
    while true do
      key, pos = json.parse(str, pos, '}')
      if key == nil then return obj, pos end
      if not delim_found then error('Comma missing between object items.') end
      pos = skip_delim(str, pos, ':', true)  -- true -> error if missing.
      obj[key], pos = json.parse(str, pos)
      pos, delim_found = skip_delim(str, pos, ',')
    end
  elseif first == '[' then  -- Parse an array.
    local arr, val, delim_found = {}, true, true
    pos = pos + 1
    while true do
      val, pos = json.parse(str, pos, ']')
      if val == nil then return arr, pos end
      if not delim_found then error('Comma missing between array items.') end
      arr[#arr + 1] = val
      pos, delim_found = skip_delim(str, pos, ',')
    end
  elseif first == '"' then  -- Parse a string.
    return parse_str_val(str, pos + 1)
  elseif first == '-' or first:match('%d') then  -- Parse a number.
    return parse_num_val(str, pos)
  elseif first == end_delim then  -- End of an object or array.
    return nil, pos + 1
  else  -- Parse true, false, or null.
    local literals = {['true'] = true, ['false'] = false, ['null'] = json.null}
    for lit_str, lit_val in pairs(literals) do
      local lit_end = pos + #lit_str - 1
      if str:sub(pos, lit_end) == lit_str then return lit_val, lit_end + 1 end
    end
    local pos_info_str = 'position ' .. pos .. ': ' .. str:sub(pos, pos + 10)
    error('Invalid json syntax starting at ' .. pos_info_str)
  end
end

--return json of playerData with only the data needed for the leaderboard
-- data are keys of the playerData table
local function dataStringify(data)
	local str = '{"' .. ac.getUserSteamID() .. '": '
	local name = ac.getDriverName(0)
	data['Name'] = name
	str = str .. json.stringify(data) .. '}'
	return str
end


--------------firebase--------------
local urlAppScript = 'https://script.google.com/macros/s/AKfycbwenxjCAbfJA-S90VlV0y7mEH75qt3TuqAmVvlGkx-Y1TX8z5gHtvf5Vb8bOVNOA_9j/exec'
local firebaseUrl = 'https://acp-server-97674-default-rtdb.firebaseio.com/'
local firebaseUrlData = 'https://acp-server-97674-default-rtdb.firebaseio.com/PlayersData/'
local firebaseUrlLeaderboards = 'https://acp-server-97674-default-rtdb.firebaseio.com/Leaderboards/'
local nodes = { ['Arrests'] = 'Arrestations',
				['H1'] = 'Class C - H1',
				['STRace'] = 'Street Racing',
				['Theft'] = 'Car Thefts',
				['VV'] = 'Velocity Vendetta',
				['Drift'] = 'Drift',
				['Overtake'] = 'Overtake',
				['Getaway'] = 'Most Wanted'}

local leaderboard = {}
local leaderboardName = 'Class C - H1'
local leaderboardNames = {'Class C - H1', 'Velocity Vendetta', 'Street Racing', 'Car Thefts', 'Arrestations','HORIZON', 'Drift', 'Overtake', 'Most Wanted'}

local settings = {
	essentialSize = 20,
	policeSize = 20,
	hudOffsetX = 0,
	hudOffsetY = 0,
	fontSize = 20,
	current = 1,
	colorHud = rgbm(1,0,0,1),
	timeMsg = 10,
	msgOffsetY = 10,
	msgOffsetX = windowWidth/2,
	fontSizeMSG = 30,
	menuPos = vec2(0, 0),
	unit = "km/h",
	unitMult = 1,
	starsSize = 20,
	starsPos = vec2(windowWidth, 0),
}

local settingsJSON = {
	essentialSize = 20,
	policeSize = 20,
	hudOffsetX = 0,
	hudOffsetY = 0,
	fontSize = 20,
	current = 1,
	colorHud = "1,0,0,1",
	timeMsg = 10,
	msgOffsetY = 10,
	msgOffsetX = "1280",
	fontSizeMSG = 30,
	menuPos = vec2(0, 0),
	unit = "km/h",
	unitMult = 1,
	starsSize = 20,
	starsPos = vec2(windowWidth, 0),
}


ui.setAsynchronousImagesLoading(true)
local imageSize = vec2(0,0)

local imgPos = {}

local hudImg = {
	base = "https://i.postimg.cc/ZKbvKVkP/hudBase.png",
	center = "https://i.postimg.cc/fyZtdvVN/hud-Center.png",
	left = "https://i.postimg.cc/y8WJ0x8k/hudLeft.png",
	right = "https://i.postimg.cc/d0yLSfdF/hudRight.png",
	countdown = "https://i.postimg.cc/FHqYpvYG/icon-Countdown.png",
	menu = "https://i.postimg.cc/2ywq7BWB/iconMenu.png",
	ranks = "https://i.postimg.cc/66LGXFP5/icon-Ranks.png",
	theft = "https://i.postimg.cc/9FLR4ZV6/icon-Theft.png",
}

local sectors  = {
    {
        name = 'H1',
		pointsData = {{vec3(-742.9, 138.9, 3558.7), vec3(-729.8, 138.9, 3542.8)},
					{vec3(3008.2, 73, 1040.3), vec3(2998.8, 73, 1017.3)}},
        length = 26.3,
    },
    {
        name = 'BOBs SCRAPYARD',
		pointsData = {{vec3(-742.9, 139, 3558.7), vec3(-729.8, 139, 3542.8)},
					{vec3(-3537.4, 23.8, -199.8), vec3(-3544.4, 23.8, -212.2)}},
        length = 6.35,
    },
    {
        name = 'DOUBLE TROUBLE',
		pointsData = {{vec3(-742.9, 139, 3558.7), vec3(-729.8, 139, 3542.8)},
					{vec3(-3537.4, 23.8, -199.8), vec3(-3544.4, 23.8, -212.2)}},
        length = 6.35,
    },
	{
		name = 'Velocity Vendetta',
		pointsData = {{vec3(-3944.9,-184.7,10004.4), vec3(-3951.9,-184.7,10007.2)},
					{vec3(-5774.6,-349.1,10183.9), vec3(-5776.7,-349.2,10173.8)},
					{vec3(-3977.2,-147.5,9537.4), vec3(-3969.2,-147.6,9540.2)}},
		length = 4,
	},
}

local drugAccessPointsName = {
	"Gas Station 1",
	"Street Runners",
	"Gas Station 2",
	"McDanalds 3",
	"Road Criminals",
	"McDanalds 4",
	"Gas Station 3",
	"Reckless Renegades",
	"Motion Masters",
	"restaurant 4",
	"restaurant 7",
	"McDanalds 7",
	"restaurant 9",
	"restaurant 11",
	"restaurant 13",
	"restaurant 14",
	"McDanalds 8",
	"restaurant 15",
	"McDanalds 9",
	"restaurant 16",
}

local drugAccessPoints = {
	[1] = vec3(779.2,96.9,2225.4),
	[2] = vec3(-78.9,100.3,2906.2),
	[3] = vec3(-902.2,144.1,3494.8),
	[4] = vec3(-2029.1,99.9,3522.9),
	[5] = vec3(-2357,97.2,3147.6),
	[6] = vec3(-2605.8,94.9,2863.1),
	[7] = vec3(-4021.3,60,65.4),
	[8] = vec3(-2952.5,-28.5,-593.4),
	[9] = vec3(-2154.1,-14.3,-1928.1),
	[10] = vec3(-2317.3,-23.2,-2443),
	[11] = vec3(-1084.8,-121.5,-3029.7),
	[12] = vec3(-152.9,-120.3,-3427.6),
	[13] = vec3(913.1,-77.8,-2670.6),
	[14] = vec3(2751.9,23.2,-2169.7),
	[15] = vec3(4231.5,135.1,-2789.3),
	[16] = vec3(4942.5,101.7,-2367),
	[17] = vec3(4890.5,69.9,-1525.5),
	[18] = vec3(4556.7,62.3,-1031.8),
	[19] = vec3(3147.5,55.9,214.7),
	[20] = vec3(1831.1,71.9,1621.5)
}

local drugDelivery = {
	pickUp = vec3(0,0,0),
	dropOff = vec3(0,0,0),
	pickUpName = "",
	dropOffName = "",
	active = false,
	call = false,
	started = false,
	drawPickUp = false,
	drawDropOff = false,
	timer = 0,
	distance = 0,
	avgSpeed = 0,
	finalAvgSpeed = 0,
	damage = {0,0,0,0,0},
}

local sector = nil

----------------------------------------------------------------------------------------------- Math -----------------------------------------------------------------------------------------------

local function distance(youPos, midPos)
	local l = youPos.x - midPos.x
	local k = youPos.y - midPos.y
	local n = l * l + k * k
	local lo, hi = 0, n
    while lo <= hi do
        local mid = math.floor((lo + hi)/2)
        if mid*mid <= n then
            lo = mid + 1
        else
            hi = mid - 1
        end
    end
    return hi
end

local function distanceSquared(p1, p2)
	return (p1.x - p2.x)^2 + (p1.y - p2.y)^2
end

local function cross(vector1, vector2)
	return vec2(vector1.x + vector2.x, vector1.y + vector2.y)
end

local function normalize(vector)
    local magnitude = math.sqrt(vector.x^2 + vector.y^2)
    if magnitude == 0 then
        return vector
    end
	local temp = vector.x * -1
	vector.x = vector.y
	vector.y = temp
    return vector / magnitude
end

local function regionAroundLine(line)
	local region = {}
	local offsetX = math.max(3 - math.abs(line.p1.x - line.p2.x), 1)
	local offsetZ = math.max(3 - math.abs(line.p1.y - line.p2.y), 1)
	region.x1 = math.min(line.p1.x, line.p2.x) - offsetX
	region.x2 = math.max(line.p1.x, line.p2.x) + offsetX
	region.z1 = math.min(line.p1.y, line.p2.y) - offsetZ
	region.z2 = math.max(line.p1.y, line.p2.y) + offsetZ
	return region
end

local function isPointInCircle(point, circle, radius)
	if math.distanceSquared(point, circle) <= radius then
		return true
	end
	return false
end

local function midPoint(p1, p2)
	local point = vec3((p1.x + p2.x)/2, (p1.y + p2.y)/2, (p1.z + p2.z)/2)
	local radius = distance(vec2(p1.x, p1.z), vec2(point.x, point.z))
	return point, radius
end

-------------------------------------------------------------------------------------------- Init --------------------------------------------------------------------------------------------

local starsUI = {
	starsPos = vec2(windowWidth - (settings.starsSize or 20)/2, settings.starsSize or 20)/2,
	starsSize = vec2(windowWidth - (settings.starsSize or 20)*2, (settings.starsSize or 20)*2),
	startSpace = (settings.starsSize or 20)/4,
	full = "https://acstuff.ru/images/icons_24/star_full.png",
	empty = "https://acstuff.ru/images/icons_24/star_empty.png",
}

local function resetStarsUI()
	if settings.starsPos == nil then
		settings.starsPos = vec2(windowWidth, 0)
	end
	if settings.starsSize == nil then
		settings.starsSize = 20
	end
	starsUI.starsPos = vec2(settings.starsPos.x - settings.starsSize/2, settings.starsPos.y + settings.starsSize/2)
	starsUI.starsSize = vec2(settings.starsPos.x - settings.starsSize*2, settings.starsPos.y + settings.starsSize*2)
	starsUI.startSpace = settings.starsSize/1.5
end

local function updatePos()
	imageSize = vec2(windowHeight/80 * settings.essentialSize, windowHeight/80 * settings.essentialSize)
	imgPos.theftPos1 = vec2(imageSize.x - imageSize.x/1.56, imageSize.y/1.9)
	imgPos.theftPos2 = vec2(imageSize.x/4.6, imageSize.y/2.65)
	imgPos.ranksPos1 = vec2(imageSize.x/1.97, imageSize.y/1.9)
	imgPos.ranksPos2 = vec2(imageSize.x - imageSize.x/1.56, imageSize.y/2.65)
	imgPos.countdownPos1 = vec2(imageSize.x/1.53, imageSize.y/1.9)
	imgPos.countdownPos2 = vec2(imageSize.x - imageSize.x/2.04, imageSize.y/2.65)
	imgPos.menuPos1 = vec2(imageSize.x - imageSize.x/4.9, imageSize.y/1.9)
	imgPos.menuPos2 = vec2(imageSize.x/1.53, imageSize.y/2.65)
	imgPos.leftPos1 = vec2(imageSize.x/8, imageSize.y/2.8)
	imgPos.leftPos2 = vec2(0, imageSize.y/4.3)
	imgPos.rightPos1 = vec2(imageSize.x, imageSize.y/2.8)
	imgPos.rightPos2 = vec2(imageSize.x - imageSize.x/8, imageSize.y/4.3)
	settings.fontSize = settings.essentialSize * fontMultiplier

	resetStarsUI()
end

local function initLines()
	settings.essentialSize = settings.essentialSize * windowHeight/1440
	settings.fontSize = settings.essentialSize * windowHeight/1440
	imageSize = vec2(windowHeight/80 * settings.essentialSize, windowHeight/80 * settings.essentialSize)
	for i = 1, #sectors do
		local lines = {}
		for j = 1, #sectors[i].pointsData do
            local line = {}
            line.p1 = vec2(sectors[i].pointsData[j][1].x, sectors[i].pointsData[j][1].z)
            line.p2 = vec2(sectors[i].pointsData[j][2].x, sectors[i].pointsData[j][2].z)
            line.dir = normalize(line.p2 - line.p1)
            line.region = regionAroundLine(line)
			line.midPoint, line.radius = midPoint(sectors[i].pointsData[j][1], sectors[i].pointsData[j][2])
            table.insert(lines, line)
        end
		sectors[i].lines = lines
	end
    sector = sectors[1]
	updatePos()
	checkHash256()
end

local function randNum(seed)
	local date = os.date("%m%d%Y")
	local num = 0
	for i = 1, #date do
		num = num + tonumber(date:sub(i,i))
	end
	num = num + seed
	num = num % 20
	num = num + 1
	return num
end


local function initDrugRoute()
	local accessPoint = randNum(0)
	local ray = render.createRay(drugAccessPoints[accessPoint], vec3(0, -1, 0))
	local hit = ray:track() - 0.1
	if hit ~= -1 then
		drugDelivery.pickUp = ray.pos + ray.dir * hit
	else
		drugDelivery.pickUp = drugAccessPoints[accessPoint]
	end
	drugDelivery.pickUpName = drugAccessPointsName[accessPoint]
	local deliveryPoint = randNum(accessPoint) % 4 + 3
	if (accessPoint + deliveryPoint) > #drugAccessPoints then
		deliveryPoint = accessPoint + deliveryPoint - #drugAccessPoints
	else
		deliveryPoint = accessPoint + deliveryPoint
	end
	drugDelivery.dropOff = drugAccessPoints[deliveryPoint]
	drugDelivery.dropOffName = drugAccessPointsName[deliveryPoint]
end



local function textWithBackground(text, sizeMult)
	local textLenght = ui.measureDWriteText(text, settings.fontSizeMSG*sizeMult)
	local rectPos1 = vec2(settings.msgOffsetX - textLenght.x/2, settings.msgOffsetY)
	local rectPos2 = vec2(settings.msgOffsetX + textLenght.x/2, settings.msgOffsetY + settings.fontSizeMSG*sizeMult)
	local rectOffset = vec2(10, 10)
	if ui.time() % 1 < 0.5 then
		ui.drawRectFilled(rectPos1 - vec2(10,0), rectPos2 + rectOffset, COLORSMSGBG, 10)
	else
		ui.drawRectFilled(rectPos1 - vec2(10,0), rectPos2 + rectOffset, rgbm(0,0,0,0.5), 10)
	end
	ui.dwriteDrawText(text, settings.fontSizeMSG*sizeMult, rectPos1, rgbm.colors.white)
end

----------------------------------------------------------------------------------------------- Firebase -----------------------------------------------------------------------------------------------


local function stringToVec2(str)
	if str == nil then return vec2(0, 0) end
	local x = string.match(str, "([^,]+)")
	local y = string.match(str, "[^,]+,(.+)")
	return vec2(tonumber(x), tonumber(y))
end

local function vec2ToString(vec)
	return tostring(vec.x) .. ',' .. tostring(vec.y)
end

local function stringToRGBM(str)
	local r = string.match(str, "([^,]+)")
	local g = string.match(str, "[^,]+,([^,]+)")
	local b = string.match(str, "[^,]+,[^,]+,([^,]+)")
	local m = string.match(str, "[^,]+,[^,]+,[^,]+,(.+)")
	return rgbm(tonumber(r), tonumber(g), tonumber(b), tonumber(m))
end

local function rgbmToString(rgbm)
	return tostring(rgbm.r) .. ',' .. tostring(rgbm.g) .. ',' .. tostring(rgbm.b) .. ',' .. tostring(rgbm.mult)
end

local function parsesettings(table)
	settings.essentialSize = table.essentialSize
	settings.policeSize = table.policeSize
	settings.hudOffsetX = table.hudOffsetX
	settings.hudOffsetY = table.hudOffsetY
	settings.fontSize = table.fontSize
	settings.current = table.current
	settings.colorHud = stringToRGBM(table.colorHud)
	settings.timeMsg = table.timeMsg
	settings.msgOffsetY = table.msgOffsetY
	settings.msgOffsetX = table.msgOffsetX
	settings.fontSizeMSG = table.fontSizeMSG
	settings.menuPos = stringToVec2(table.menuPos)
	settings.unit = table.unit
	settings.unitMult = table.unitMult
	settings.starsSize = table.starsSize or 20
	if table.starsPos == nil then
		settings.starsPos = vec2(windowWidth, 0)
	else
		settings.starsPos = stringToVec2(table.starsPos)
	end
end

local function addPlayerToDataBase()
	local name = ac.getDriverName(0)
	local str = '{"' .. steamID .. '": {"Name":"' .. name .. '","Getaway": 0,"Drift": 0,"Overtake": 0,"Wins": 0,"Losses": 0,"Busted": 0,"Arrests": 0,"Theft": 0,"Sectors": {"H1": {},"VV": {}}}}'
	web.request('PATCH', firebaseUrl .. "Players.json", str, function(err, response)
		if err then
			print(err)
			return
		end
	end)
end

local function addPlayersettingsToDataBase()
	local str = '{"' .. steamID .. '": {"essentialSize":20,"policeSize":20,"hudOffsetX":0,"hudOffsetY":0,"fontSize":20,"current":1,"colorHud":"1,0,0,1","timeMsg":10,"msgOffsetY":10,"msgOffsetX":' .. windowWidth/2 .. ',"fontSizeMSG":30,"menuPos":"0,0","unit":"km/h","unitMult":1,"starsSize":20}}'
	web.request('PATCH', firebaseUrl .. "Settings.json", str, function(err, response)
		if err then
			print(err)
			return
		end
	end)
end

local function timeFormat(sec)
	local timeFormated = ''
	if sec < 600 then
		timeFormated = '0' .. math.floor(sec/ 60) .. ':'
	else
		timeFormated = math.floor(sec / 60) .. ':'
	end
	if sec % 60 < 10 then
		timeFormated = timeFormated .. '0' .. string.format("%.3f", sec % 60)
	else
		timeFormated = timeFormated .. string.format("%.3f", sec % 60)
	end
	return timeFormated
end

local function getFirebase()
	local url = firebaseUrl .. "Players/" .. steamID .. '.json'
	web.get(url, function(err, response)
		if err then
			print(err)
			return
		else
			if response.body == 'null' then
				addPlayerToDataBase(steamID)
			else
				local jString = response.body
				playerData = json.parse(jString)
				if playerData.Name ~= ac.getDriverName(0) then
					playerData.Name = ac.getDriverName(0)
				end
				if not playerData.Drift then
					playerData.Drift = 0
				else
					driftState.bestScore = playerData.Drift
				end
				if not playerData.Overtake then
					playerData.Overtake = 0
				else
					highestScore = playerData.Overtake
				end
			end
			ac.log('Player data loaded')
		end
	end)
end

local function loadSettings()
	local url = firebaseUrl .. "Settings/" .. steamID .. '.json'
	web.get(url, function(err, response)
		if err then
			print(err)
			return
		else
			if response.body == 'null' then
				addPlayersettingsToDataBase(steamID)
			else
				ac.log("settings loaded")
				local jString = response.body
				local table = json.parse(jString)
				parsesettings(table)
			end
		end
	end)
end

local function updateSettings()
	local str = '{"' .. steamID .. '": ' .. json.stringify(settingsJSON) .. '}'
	web.request('PATCH', firebaseUrl .. "Settings.json", str, function(err, response)
		if err then
			print(err)
			return
		end
	end)
	ac.log("Updated settings")
end

local function onSettingsChange()
	settingsJSON.colorHud = rgbmToString(settings.colorHud)
	settingsJSON.menuPos = vec2ToString(settings.menuPos)
	settingsJSON.essentialSize = settings.essentialSize
	settingsJSON.policeSize = settings.policeSize
	settingsJSON.hudOffsetX = settings.hudOffsetX
	settingsJSON.hudOffsetY = settings.hudOffsetY
	settingsJSON.fontSize = settings.fontSize
	settingsJSON.current = settings.current
	settingsJSON.timeMsg = settings.timeMsg
	settingsJSON.msgOffsetY  = settings.msgOffsetY
	settingsJSON.msgOffsetX  = settings.msgOffsetX
	settingsJSON.fontSizeMSG = settings.fontSizeMSG
	settingsJSON.unit = settings.unit
	settingsJSON.unitMult = settings.unitMult
	settingsJSON.starsSize = settings.starsSize
	settingsJSON.starsPos = vec2ToString(settings.starsPos)
	updateSettings()
end

local function changeHeaderNames(name)
	if name == 'Arrests' then
		return 'Arrestations'
	elseif name == 'Theft' then
		return 'Cars Stolen'
	else 
		return name
	end
end

local function parse_leaderboard(lb)
	local header = {}
	local leaderboard = {}
	for k,v in pairs(lb) do
		local entry = {}
		for k2,v2 in pairs(v) do
			k2 = changeHeaderNames(k2)
			if k == 1 then table.insert(header, k2) end
			if k2 == 'Time' then v2 = timeFormat(tonumber(v2)) end
			entry[k2] = v2
		end
		table.insert(leaderboard, entry)
	end
	table.insert(leaderboard, 1, header)
	return leaderboard
end


local function loadLeaderboard()
	local url = firebaseUrlLeaderboards .. leaderboardName .. '.json'

	web.get(url, function(err, response)
		if err then
			print(err)
			return
		else
			if response.body == 'null' then
				ac.log("No leaderboard found")
			else
				local jString = response.body
				leaderboard = json.parse(jString)
				leaderboard = parse_leaderboard(leaderboard)
			end
		end
	end)
end

local function updateSheets(category)
	local str = '{"category" : "' .. nodes[category] .. '"}'
	web.post(urlAppScript, str, function(err, response)
		if err then
			print(err)
			return
		else
			print(response.body)
		end
	end)
end

local function updatefirebase()
	local str = '{"' .. ac.getUserSteamID() .. '": ' .. json.stringify(playerData) .. '}'
	web.request('PATCH', firebaseUrl  .. "Players" .. ".json", str, function(err, response)
		if err then
			print(err)
			return
		else
			print(response.body)
		end
	end)
end

local function updatefirebaseData(node, data)
	local str = dataStringify(data)
	web.request('PATCH', firebaseUrlData .. node .. ".json", str, function(err, response)
		if err then
			print(err)
			return
		else
			print(response.body)
			updateSheets(node)
		end
	end)
end

function updateSectorData(sectorName, time)
	if sectorName == 'H1' then
		if not playerData.Sectors then
			playerData.Sectors = {
				H1 = {
					[carID] = {
						Time = time,
					},
				},
				VV = {},
			}
		end
		if playerData.Sectors.H1 then
			if not playerData.Sectors.H1[carID] then
				playerData.Sectors.H1[carID] = {
					Time = time,
				}
			end
			if time < playerData.Sectors.H1[carID].Time then
				playerData.Sectors.H1[carID].Time = time
			end
		else
			playerData.Sectors.H1 = {
				[carID] = {
					Time = time,
				},
			}
		end
	elseif sectorName == 'VV' then
		if not playerData.Sectors then
			playerData.Sectors = {
				H1 = {},
				VV = {
					Car = carID,
					Time = time,
				},
			}
		end
		if playerData.Sectors.VV then
			if time < playerData.Sectors.VV.Time then
				playerData.Sectors.VV = {
					Car = carID,
					Time = time,
				}
			end
		else
			playerData.Sectors.VV = {
				Car = carID,
				Time = time,
			}
		end
	end
	local data
	if sectorName == 'H1' then
		data = playerData.Sectors[sectorName]
	else
		data = {
			Car = carID,
			Time = time,
		}
	end
	updatefirebase()
	updatefirebaseData(sectorName, data)
end

local boxHeight = windowHeight/70

local function displayInGrid()
	local box1 = vec2(windowWidth/32, boxHeight)
	local nbCol = #leaderboard[1]
	local colWidth = (windowWidth/2 - windowWidth/32)/(nbCol)
	ui.pushDWriteFont("Orbitron;Weight=Black")
	ui.newLine()
	ui.dwriteTextAligned("Pos", settings.fontSize/1.5, ui.Alignment.Center, ui.Alignment.Center, box1, false, settings.colorHud)
	for i = 1, nbCol do
		local textLenght = ui.measureDWriteText(leaderboard[1][i], settings.fontSize/1.5).x
		ui.sameLine(box1.x + colWidth/2 + colWidth*(i-1) - textLenght/2)
		ui.dwriteTextWrapped(leaderboard[1][i], settings.fontSize/1.5, settings.colorHud)
	end
	ui.newLine()
	ui.popDWriteFont()
	ui.pushDWriteFont("Orbitron;Weight=Regular")
	for i = 2, #leaderboard do
		local sufix = "th"
		if i == 2 then sufix = "st"
		elseif i == 3 then sufix = "nd"
		elseif i == 4 then sufix = "rd" end
		ui.dwriteTextAligned(i-1 .. sufix, settings.fontSize/2, ui.Alignment.Center, ui.Alignment.Center, box1, false, rgbm.colors.white)
		for j = 1, #leaderboard[1] do
			local textLenght = ui.measureDWriteText(leaderboard[i][leaderboard[1][j]], settings.fontSize/1.5).x
			ui.sameLine(box1.x + colWidth/2 + colWidth*(j-1) - textLenght/2)
			ui.dwriteTextWrapped(leaderboard[i][leaderboard[1][j]], settings.fontSize/1.5, rgbm.colors.white)
		end
	end
	ui.popDWriteFont()
	local lineHeight = math.max(ui.itemRectMax().y, windowHeight/3)
	ui.drawLine(vec2(box1.x, windowHeight/20), vec2(box1.x, lineHeight), rgbm.colors.white, 1)
	for i = 1, nbCol-1 do
		ui.drawLine(vec2(box1.x + colWidth*i, windowHeight/20), vec2(box1.x + colWidth*i, lineHeight), rgbm.colors.white, 2)
	end
	ui.drawLine(vec2(0, windowHeight/12), vec2(windowWidth/2, windowHeight/12), rgbm.colors.white, 1)
end

local function showLeaderboard()
	ui.dummy(vec2(windowWidth/20, 0))
	ui.sameLine()
	ui.setNextItemWidth(windowWidth/12)
	ui.combo("leaderboard", leaderboardName, function ()
		for i = 1, #leaderboardNames do
			if ui.selectable(leaderboardNames[i], leaderboardName == leaderboardNames[i]) then
				leaderboardName = leaderboardNames[i]
				loadLeaderboard()
			end
		end
	end)
	ui.sameLine(windowWidth/4 - 120)
	if ui.button('Close', vec2(100, windowHeight/50)) then leaderboardOpen = false end
	ui.newLine()
	displayInGrid()
end

----------------------------------------------------------------------------------------------- settings -----------------------------------------------------------------------------------------------


local showPreviewMsg = false
local showPreviewDistanceBar = false
local showPreviewStars = false
COLORSMSGBG = rgbm(0.5,0.5,0.5,0.5)

local online = {
	message = "",
	messageTimer = 0,
	type = 1,
	chased = false,
	officer = nil,
	level = 0,
}

local function showStarsPursuit()
	local starsColor = rgbm(1, 1, 1, os.clock()%2 + 0.3)
	resetStarsUI()
	for i = 1, 5 do
		if i > online.level/2 then
			ui.drawImage(starsUI.empty, starsUI.starsPos, starsUI.starsSize, rgbm(1, 1, 1, 0.2))
		else
			ui.drawImage(starsUI.full, starsUI.starsPos, starsUI.starsSize, starsColor)
		end
		starsUI.starsPos.x = starsUI.starsPos.x - settings.starsSize - starsUI.startSpace
		starsUI.starsSize.x = starsUI.starsSize.x - settings.starsSize - starsUI.startSpace
	end
end

local function distanceBarPreview()
	ui.transparentWindow("progressBar", vec2(0, 0), vec2(windowWidth, windowHeight), function ()
	local playerInFront = "You are in front"
	local text = math.floor(50) .. "m"
	local textLenght = ui.measureDWriteText(text, 30)
	ui.newLine()
	ui.dummy(vec2(windowWidth/3, windowHeight/40))
	ui.sameLine()
	ui.beginRotation()
	ui.progressBar(125/250, vec2(windowWidth/3,windowHeight/60), playerInFront)
	ui.endRotation(90,vec2(settings.msgOffsetX - windowWidth/2 - textLenght.x/2,settings.msgOffsetY + textLenght.y/3))
	ui.dwriteDrawText(text, 30, vec2(settings.msgOffsetX - textLenght.x/2 , settings.msgOffsetY), rgbm.colors.white)
	end)
end

local function previewMSG()
	ui.transparentWindow("previewMSG", vec2(0, 0), vec2(windowWidth, windowHeight), function ()
	ui.pushDWriteFont("Orbitron;Weight=Black")
	local textSize = ui.measureDWriteText("Messages from Police when being chased", settings.fontSizeMSG)
	local uiOffsetX = settings.msgOffsetX - textSize.x/2
	local uiOffsetY = settings.msgOffsetY
	ui.drawRectFilled(vec2(uiOffsetX - 5, uiOffsetY-5), vec2(uiOffsetX + textSize.x + 5, uiOffsetY + textSize.y + 5), COLORSMSGBG)
	ui.dwriteDrawText("Messages from Police when being chased", settings.fontSizeMSG, vec2(uiOffsetX, uiOffsetY), settings.colorHud)
	ui.popDWriteFont()
	end)
end

local function previewStars()
	ui.transparentWindow("PreviewStars", vec2(0, 0), vec2(windowWidth, windowHeight), function ()
		showStarsPursuit()
	end)
end


local function uiTab()
	ui.text('On Screen Message : ')
	settings.timeMsg = ui.slider('##' .. 'Time Msg On Screen', settings.timeMsg, 1, 15, 'Time Msg On Screen' .. ': %.0fs')
	settings.fontSizeMSG = ui.slider('##' .. 'Font Size MSG', settings.fontSizeMSG, 10, 50, 'Font Size' .. ': %.0f')
	settings.msgOffsetY = ui.slider('##' .. 'Msg On Screen Offset Y', settings.msgOffsetY, 0, windowHeight, 'Msg On Screen Offset Y' .. ': %.0f')
	settings.msgOffsetX = ui.slider('##' .. 'Msg On Screen Offset X', settings.msgOffsetX, 0, windowWidth, 'Msg On Screen Offset X' .. ': %.0f')
    ui.newLine()
	ui.text('Stars : ')
	settings.starsPos.x = ui.slider('##' .. 'Stars Offset X', settings.starsPos.x, 0, windowWidth, 'Stars Offset X' .. ': %.0f')
	settings.starsPos.y = ui.slider('##' .. 'Stars Offset Y', settings.starsPos.y, 0, windowHeight, 'Stars Offset Y' .. ': %.0f')
	settings.starsSize = ui.slider('##' .. 'Stars Size', settings.starsSize, 10, 50, 'Stars Size' .. ': %.0f')
	ui.newLine()
	ui.text('Preview : ')
    if ui.button('Message') then
        showPreviewMsg = not showPreviewMsg
        showPreviewDistanceBar = false
		showPreviewStars = false
    end
    ui.sameLine()
    if ui.button('Distance Bar') then
        showPreviewDistanceBar = not showPreviewDistanceBar
        showPreviewMsg = false
		showPreviewStars = false
    end
	ui.sameLine()
	if ui.button('Stars') then
		showPreviewStars = not showPreviewStars
		showPreviewMsg = false
		showPreviewDistanceBar = false
	end
    if showPreviewMsg then previewMSG() end
    if showPreviewDistanceBar then distanceBarPreview() end
	if showPreviewStars then previewStars() end
	ui.newLine()
	if ui.button('MSG Offset X to center') then settings.msgOffsetX = windowWidth/2 end
end


local function settingsWindow()
	imageSize = vec2(windowHeight/80 * settings.essentialSize, windowHeight/80 * settings.essentialSize)
	ui.sameLine(10)
	ui.beginGroup()
	ui.newLine(15)
	ui.text('HUD :')
	ui.sameLine(windowWidth/6 - windowWidth/20)
	if ui.button('Close', vec2(windowWidth/25, windowHeight/50)) then
		menuOpen = false
		onSettingsChange()
	end
	settings.hudOffsetX = ui.slider('##' .. 'HUD Offset X', settings.hudOffsetX, 0, windowWidth, 'HUD Offset X' .. ': %.0f')
	settings.hudOffsetY = ui.slider('##' .. 'HUD Offset Y', settings.hudOffsetY, 0, windowHeight, 'HUD Offset Y' .. ': %.0f')
	settings.essentialSize = ui.slider('##' .. 'HUD Size', settings.essentialSize, 10, 50, 'HUD Size' .. ': %.0f')
	settings.fontSize = settings.essentialSize * fontMultiplier
    ui.setNextItemWidth(300)
	local colorHud = settings.colorHud
	local colorHud2 = settings.colorHud2
    ui.colorPicker('Theme Color', colorHud, ui.ColorPickerFlags.AlphaBar)
	if colorHud ~= colorHud2 then
		settingsJSON.colorHud = rgbmToString(colorHud)
	end
    ui.newLine()
    uiTab()
	ui.endGroup()
	updatePos()
	return 2
end


----------------------------------------------------------------------------------------------- Sectors -----------------------------------------------------------------------------------------------
-- Variables --
local sectorInfo = {
	time = 0,
	timerText = '00:00.00',
	finalTime = '00:00.00',
	checkpoints = 1,
	sectorIndex = 1,
	distance = 0,
	finished = false,
	drawLine = false,
	timePosted = false,
}

local duo = {
	teammate = nil,
	request = false,
	onlineSender = nil,
	teammateHasFinished = false,
	waiting = false,
	playerName = "Online Players",
}

local function resetSectors()
	sector = sectors[sectorInfo.sectorIndex]
	sectorInfo.time = 0
	sectorInfo.timerText = '00:00.00'
	sectorInfo.finalTime = '00:00.00'
	sectorInfo.checkpoints = 1
	sectorInfo.distance = 0
	sectorInfo.finished = false
	sectorInfo.timePosted = false
end

local function dot(vector1, vector2)
	return vector1.x * vector2.x + vector1.y * vector2.y
end

----------------------------------------------------------------------------------------------- UI ----------------------------------------------------------------------------------------------------
-- Functions --
local showDescription = false

local function discordLinks()
	ui.newLine(100)
	ui.dwriteTextWrapped("For more info about the challenge click on the Discord link :", 15, rgbm.colors.white)
	if sectorInfo.sectorIndex == 1 then
		if ui.textHyperlink("H1 Races Discord") then
			os.openURL("https://discord.com/channels/358562025032646659/1073622643145703434")
		end
		ui.sameLine(150)
		if ui.textHyperlink("H1 Vertex Discord") then
			os.openURL("https://discord.com/channels/358562025032646659/1088832930698231959")
		end
	elseif sectorInfo.sectorIndex == 2 then
		if ui.textHyperlink("BOB's Scrapyard Discord") then
			os.openURL("https://discord.com/channels/358562025032646659/1096776154217709629")
		end
	elseif sectorInfo.sectorIndex == 3 then
		if ui.textHyperlink("Double Trouble Discord") then
			os.openURL("https://discord.com/channels/358562025032646659/1097229381308530728")
		end
	elseif sectorInfo.sectorIndex  == 4 then
		if ui.textHyperlink("Velocity Vendetta Discord") then
			os.openURL("https://discord.com/channels/358562025032646659/1118046532168589392")
		end
	end
	ui.newLine(10)
end

local acpEvent = ac.OnlineEvent({
    message = ac.StructItem.string(110),
	messageType = ac.StructItem.int16(),
	yourIndex = ac.StructItem.int16(),
}, function (sender, data)
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
		sector = sectors[sectorInfo.sectorIndex]
		resetSectors()
	end
end)

local function doubleTrouble()
	local players = {}
	for i = ac.getSim().carsCount - 1, 0, -1 do
		local carPlayer = ac.getCar(i)
		if carPlayer.isConnected and (not carPlayer.isHidingLabels) then
			if carPlayer.index ~= car.index and ac.getCarID(i) ~= valideCar[1] and ac.getCarID(i) ~= valideCar[2] and ac.getCarID(i) ~= valideCar[3] then
				table.insert(players, carPlayer)
			end
		end
	end
	if #players == 0 then
		ui.newLine()
		ui.dwriteTextWrapped("There is no other players connected", 15, rgbm.colors.white)
		ui.dwriteTextWrapped("You can't steal a car", 15, rgbm.colors.white)
	else
		if duo.teammate == nil then
			ui.setNextItemWidth(150)
			ui.combo("Teammate", duo.playerName, function ()
				for i = 1, #players do
					if ui.selectable(ac.getDriverName(players[i].index), duo.teammate == players[i].index) then
						acpEvent{message = "Request", messageType = 5, yourIndex = ac.getCar(players[i].index).sessionID}
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
			ui.dwriteTextWrapped("teammate : ", 15, rgbm.colors.white)
			ui.sameLine()
			ui.dwriteTextWrapped(ac.getDriverName(duo.teammate.index), 15, rgbm.colors.purple)
			ui.sameLine()
			if ui.button("Cancel") then
				acpEvent{message = "Cancel", messageType = 5, yourIndex = ac.getCar(duo.teammate.index).sessionID}
				duo.teammate = nil
			end
			duo.waiting = false
		end
	end
end

local function sectorSelect()
	ui.setNextItemWidth(150)
	ui.combo("Sector", sector.name, function ()
		for i = 1, #sectors do
			if ui.selectable(sectors[i].name, sector == sectors[i]) then
				sector = sectors[i]
				sectorInfo.sectorIndex = i
				resetSectors()
			end
		end
	end)
	ui.sameLine(windowWidth/5 - 120)
	if ui.button('Close', vec2(100, windowHeight/50)) then 
		menuOpen = false
		onSettingsChange()
	end
end

local function sectorUI()
	ui.sameLine(10)
	ui.beginGroup()
	ui.newLine(15)
	sectorSelect()
	if sector == nil then
		sector = sectors[1]
		sectorInfo.sectorIndex = 1
		resetSectors()
	end
	if sectorInfo.sectorIndex == 3 then doubleTrouble() end
	if duo.request then
		ui.newLine()
		ui.dwriteTextWrapped((ac.getDriverName(duo.onlineSender.index) .. " want to steal a car with you!"), 15, rgbm.colors.purple)
		if ui.button("Accept") then
			duo.teammate = duo.onlineSender
			acpEvent{message = "Accept", messageType = 5, yourIndex = ac.getCar(duo.teammate.index).sessionID}
			duo.request = false
			sectorInfo.sectorIndex = 3
			resetSectors()
		end
		ui.sameLine()
		if ui.button("Decline") then
			duo.request = false
		end
	end
	if ui.button("Close Comfy") then
		ac.setAppWindowVisible("ACP_Tools", '?', true)
	end
	discordLinks()
	ui.endGroup()
	return 1
end

local function textTimeFormat()
	local timeFormated = ''
	local dt = ui.deltaTime()
	sectorInfo.time = sectorInfo.time + dt
	if sectorInfo.time < 600 then
		timeFormated = '0' .. math.floor(sectorInfo.time / 60) .. ':'
	else
		timeFormated = math.floor(sectorInfo.time / 60) .. ':'
	end
	if sectorInfo.time % 60 < 10 then
		timeFormated = timeFormated .. '0' .. string.format("%.2f", sectorInfo.time % 60)
	else
		timeFormated = timeFormated .. string.format("%.2f", sectorInfo.time % 60)
	end
	sectorInfo.timerText = timeFormated
end

local function hasCrossedLine(line)
	local pos3 = car.position
	if pos3.x > line.region.x1 and pos3.z > line.region.z1 and pos3.x < line.region.x2 and pos3.z < line.region.z2 then
        if dot(vec2(car.look.x, car.look.z), line.dir) > 0 then return true end
	end
    return false
end

local function sectorUpdate()
	if wheels[0].surfaceSectorID == 47 and wheels[1].surfaceSectorID == 47 and wheels[2].surfaceSectorID == 47 and wheels[3].surfaceSectorID == 47 then
		resetSectors()
	end
	if sector == nil then
		sector = sectors[1]
		sectorInfo.sectorIndex = 1
		resetSectors()
	end
	if distanceSquared(vec2(car.position.x, car.position.z), vec2(sector.lines[sectorInfo.checkpoints].midPoint.x, sector.lines[sectorInfo.checkpoints].midPoint.z)) < 30000 then sectorInfo.drawLine = true else sectorInfo.drawLine = false end
	if hasCrossedLine(sector.lines[sectorInfo.checkpoints]) then
		if sectorInfo.checkpoints == 1 then
			resetSectors()
			sectorInfo.distance = car.distanceDrivenSessionKm
		end
		if sectorInfo.finished then
			if sectorInfo.finished and not sectorInfo.timePosted then
				if sectors[sectorInfo.sectorIndex].name == "BOBs SCRAPYARD" then
					if class == "C" and timeRequirement > sectorInfo.time then
						if not playerData.Theft then playerData.Theft = 0 end
						playerData.Theft = playerData.Theft + 1
						ac.sendChatMessage(" has successfully stolen a " .. string.gsub(ac.getCarName(0), "%W", " ") .. " and got away with it!")
					else
						ac.sendChatMessage(" has failed to steal a " .. string.gsub(ac.getCarName(0), "%W", " ") .. " under the time limit!")
					end
					local data = {
						["Theft"] = playerData.Theft,
					}
					updatefirebase()
					updatefirebaseData("Theft", data)
				else
					if sectors[sectorInfo.sectorIndex].name == "H1" then updateSectorData('H1', sectorInfo.time)
					elseif sectors[sectorInfo.sectorIndex].name == "Velocity Vendetta" then updateSectorData('VV', sectorInfo.time) end
					ac.sendChatMessage(" has finished " .. sectors[sectorInfo.sectorIndex].name .. " in " .. sectorInfo.timerText .. "!")
				end
				sectorInfo.timePosted = true
			end
			if sectorInfo.sectorIndex == 3 and duo.teammate ~= nil and sectorInfo.finishedTeammate or sectorInfo.sectorIndex ~= 3 then
				sectorInfo.finalTime = sectorInfo.timerText
				duo.teammate = nil
			end
		elseif sectorInfo.checkpoints == #sector.lines then
			if sector.length < car.distanceDrivenSessionKm - sectorInfo.distance then
				if sectorInfo.sectorIndex == 3 then
					if duo.teammate ~= nil and not sectorInfo.finished then
						acpEvent{message = "Finished", messageType = 5, yourIndex = ac.getCar(duo.teammate.index).sessionID}
					end
				end
				sectorInfo.finished = true
			end
		else sectorInfo.checkpoints = sectorInfo.checkpoints + 1 end
	end
	if sectorInfo.checkpoints > 1 and not sectorInfo.finished then textTimeFormat() end
end

local function resetDrugDelivery()
	drugDelivery.active = false
	drugDelivery.started = false
	drugDelivery.call = false
	drugDelivery.timer = 0
	drugDelivery.distance = 0
	drugDelivery.avgSpeed = 0
end

local function drugDeliveryUI()
	if drugDelivery.active and not drugDelivery.started then
		textWithBackground("You just picked up some drugs to start the mission click on the THEFT icon! Deliver them to this location : " .. drugDelivery.dropOffName .. "!", 1)
	elseif drugDelivery.started then
		textWithBackground("You are on the way to deliver the drugs to " .. drugDelivery.dropOffName .. "!", 1)
	end
end

local function drawDrugLocations()
	if not drugDelivery.started and math.distanceSquared(car.position, drugDelivery.pickUp) < 30000 then drugDelivery.drawPickUp = true else drugDelivery.drawPickUp = false end
	if math.distanceSquared(car.position, drugDelivery.dropOff) < 30000 then drugDelivery.drawDropOff = true else drugDelivery.drawDropOff = false end
end

local function drugAvgSpeedValid()
	if drugDelivery.timer > 0 then
		local routeLength = car.distanceDrivenSessionKm - drugDelivery.distance
		drugDelivery.finalAvgSpeed = drugDelivery.avgSpeed
		resetDrugDelivery()
		if drugDelivery.finalAvgSpeed > 100 then return true end
	end
	return false
end

local function drugDeliveryUpdate(dt)
	drawDrugLocations()
	if not drugDelivery.active and car.speedKmh < 5 and isPointInCircle(car.position, drugDelivery.pickUp, 100) then
		drugDelivery.active = true
		drugDelivery.finalAvgSpeed = 0
	elseif drugDelivery.call and drugDelivery.active and car.speedKmh > 5 and isPointInCircle(car.position, drugDelivery.pickUp, 100) then
		resetDrugDelivery()
		drugDelivery.distance = car.distanceDrivenSessionKm
		for i = 0, 4 do drugDelivery.damage[i] = car.damage[i] end
		drugDelivery.started = true
	elseif drugDelivery.started and car.speedKmh < 10 and isPointInCircle(car.position, drugDelivery.dropOff, 100) then
		if drugAvgSpeedValid() then
			ac.sendChatMessage(" has delivered the drugs and got away with it!\nDate : " .. os.date("%d/%m/%Y"))
		else
			ac.sendChatMessage(" was too slow and got caught by the cops with the drugs!")
		end
	end
	if drugDelivery.started then
		if car.speedKmh > 10 then
			for i = 0, 4 do
				if car.damage[i] > drugDelivery.damage[i] then
					ac.sendChatMessage(" has crashed and lost the drugs!")
					resetDrugDelivery()
					break
				end
			end
		end
	end
	if drugDelivery.started then
		drugDelivery.timer = drugDelivery.timer + dt
		drugDelivery.avgSpeed = (car.distanceDrivenSessionKm - drugDelivery.distance) * 3600 / drugDelivery.timer
	end
end

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
		ui.drawRectFilledMultiColor(vec2(0,0), vec2(windowWidth/10,windowHeight), settings.colorHud, rgbm(0,0,0,0),  rgbm(0,0,0,0), settings.colorHud)
		ui.drawRectFilledMultiColor(vec2(windowWidth-windowWidth/10,0), vec2(windowWidth,windowHeight),  rgbm(0,0,0,0), settings.colorHud, settings.colorHud, rgbm(0,0,0,0))
	else
		ui.drawRectFilledMultiColor(vec2(0,0), vec2(windowWidth/10,windowHeight), rgbm(0,0,0,0), rgbm(0,0,0,0),  rgbm(0,0,0,0), rgbm(0,0,0,0))
		ui.drawRectFilledMultiColor(vec2(windowWidth-windowWidth/10,0), vec2(windowWidth,windowHeight),  rgbm(0,0,0,0), rgbm(0,0,0,0), rgbm(0,0,0,0), rgbm(0,0,0,0))
	end
end

local function hasWin(winner)
	raceFinish.winner = winner
	raceFinish.finished = true
	raceFinish.time = 10
	raceState.inRace = false
	if winner == car then
		playerData.Wins = playerData.Wins + 1
		raceFinish.opponentName = ac.getDriverName(raceState.opponent.index)
		raceFinish.messageSent = false
	else
		playerData.Losses = playerData.Losses + 1
	end
	if playerData.Wins + playerData.Losses > 0 then
		playerData.WR = math.floor((playerData.Wins * 100 / (playerData.Wins + playerData.Losses))*100)/100
	end
	raceState.opponent = nil
end

local acpRace = ac.OnlineEvent({
	targetSessionID = ac.StructItem.int16(),
	messageType = ac.StructItem.int16(),
}, function (sender, data)
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
	local direction = cross(vec2(car.velocity.x, car.velocity.z), vec2(raceState.opponent.velocity.x, raceState.opponent.velocity.z))
	local midBetweenPlayers = vec2((car.position.x + raceState.opponent.position.x)/2, (car.position.z + raceState.opponent.position.z)/2)
	local midPlusDirection = vec2(midBetweenPlayers.x + direction.x, midBetweenPlayers.y + direction.y)
	local youDistanceSquared = distanceSquared(vec2(car.position.x, car.position.z), midPlusDirection)
	local opponentDistanceSquared = distanceSquared(vec2(raceState.opponent.position.x, raceState.opponent.position.z), midPlusDirection)
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
		acpRace{targetSessionID = raceState.opponent.sessionID, messageType = 3}
		hasWin(raceState.opponent)
		return false
	end
	return true
end

local function inRace()
	if raceState.opponent == nil then return end
	raceState.distance = distance(vec2(car.position.x, car.position.z), vec2(raceState.opponent.position.x, raceState.opponent.position.z))
	if raceState.distance < 50 then whosInFront()
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

local function resquestRace()
	local opponent = ac.getCar(ac.getCarIndexInFront(0))
	if not opponent then return end
	horn.opponentName = ac.getDriverName(opponent.index)
	if opponent and (not opponent.isHidingLabels) then
		if dot(vec2(car.look.x, car.look.z), vec2(opponent.look.x, opponent.look.z)) > 0 then
			acpRace{targetSessionID = opponent.sessionID, messageType = 1}
			horn.resquestTime = 10
		end
	end
end

local function acceptingRace()
	if dot(vec2(car.look.x, car.look.z), vec2(raceState.opponent.look.x, raceState.opponent.look.z)) > 0 then
		acpRace{targetSessionID = raceState.opponent.sessionID, messageType = 2}
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
		elseif raceState.time < 0 then raceState.time = 0 end
		if raceState.message and raceState.time == 0 then
			if raceState.opponent then
				ac.sendChatMessage(ac.getDriverName(0) .. " has started an illegal race against " .. ac.getDriverName(raceState.opponent.index) .. "!")
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
local requiredSpeed = 80

-- This function is called before event activates. Once it returns true, it’ll run:
function script.prepare(dt)
    return
    ac.debug("speed", car.speedKmh)
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
	if overtake.totalScore > highestScore then
		highestScore = math.floor(overtake.totalScore)
		ac.sendChatMessage("New highest Overtake score: " .. highestScore .. " pts !")
		playerData.Overtake = highestScore
		local data = {
			["Overtake"] = highestScore,
		}
		updatefirebase()
		updatefirebaseData("Overtake", data)
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

    if car.speedKmh < requiredSpeed then
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
		text = overtake.totalScore .. " pts - " .. string.format("%d",overtake.comboMeter) .. "x"
		colorCombo = rgbm(0, 1, 0, 0.9)
	else
		text = "PB: " .. highestScore .. "pts"
		colorCombo = rgbm(1, 1, 1, 0.9)
	end
	local textSize = ui.measureDWriteText(text, settings.fontSize)
	ui.dwriteDrawText(text, settings.fontSize, textOffset - vec2(textSize.x/2, -imageSize.y/13), colorCombo)
end

--------------------------------------------------------------------------------- Drift -----------------------------------------------------------------------------------

local function isDriftValid()
	if car.driftInstantPoints == 0 then driftState.valid = true end
	if wheels[0].surfaceSectorID == 47 and wheels[1].surfaceSectorID == 47 and wheels[2].surfaceSectorID == 47 and wheels[3].surfaceSectorID == 47 then
		driftState.valid = false
	end
end

local function isDriftValidSpot()
	if wheels[0].surfaceGrip == 1 and wheels[1].surfaceGrip == 1 and wheels[2].surfaceGrip == 1 and wheels[3].surfaceGrip == 1 then
		return false
	end
	if (not (car.position.x > 800 and car.position.x < 1050 and car.position.z > 2000 and car.position.z < 2250)
	and not (car.position.x > -1006 and car.position.x < -79 and car.position.z > 1264 and car.position.z < 1431)) then
		return true
	else
		return false
	end
end

-- Disable drift event if car is in arena area
local function driftUpdate(dt)
	isDriftValid()
	if driftState.lastScore ~= car.driftPoints then
		if car.driftPoints - driftState.lastScore > driftState.bestScore and isDriftValidSpot() and driftState.valid then
			driftState.bestScore = car.driftPoints - driftState.lastScore
			playerData.Drift = math.floor(driftState.bestScore)
			if driftState.bestScore > 100 then
				ac.sendChatMessage("New Drift PB: " .. string.format("%d",driftState.bestScore) .. " pts !")
				local data = {
					["Drift"] = playerData.Drift,
				}
				updatefirebase()
				updatefirebaseData("Drift", data)
			end
		end
		driftState.lastScore = car.driftPoints
	end
end

local function driftUI(textOffset)
	local text
	local colorCombo
	if car.driftInstantPoints > 0 and isDriftValidSpot() and driftState.valid then
		text = string.format("%d", car.driftInstantPoints) .. " pts"
		colorCombo = rgbm(0, 1, 0, 0.9)
	else
		text = "PB: " .. string.format("%d", driftState.bestScore) .. " pts"
		colorCombo = rgbm(1, 1, 1, 0.9)
	end
	local textSize = ui.measureDWriteText(text, settings.fontSize)
	ui.dwriteDrawText(text, settings.fontSize, textOffset - vec2(textSize.x/2, -imageSize.y/13),  colorCombo)
end

-- UI Update
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function flashingAlert(intensity)
	local timing = os.clock() % 1
	if timing > 0.5 then
		ui.drawRectFilledMultiColor(vec2(0,0), vec2(windowWidth/intensity,windowHeight), rgbm(1, 0, 0, 0.5), rgbm(0,0,0,0),  rgbm(0,0,0,0), rgbm(1, 0, 0, 0.5))
		ui.drawRectFilledMultiColor(vec2(windowWidth-windowWidth/intensity,0), vec2(windowWidth,windowHeight), rgbm(0,0,0,0), rgbm(1, 0, 0, 0.5), rgbm(1, 0, 0, 0.5), rgbm(0,0,0,0))
	else
		ui.drawRectFilledMultiColor(vec2(0,0), vec2(windowWidth/intensity,windowHeight), rgbm(0,0,0,0), rgbm(0,0,0,0),  rgbm(0,0,0,0), rgbm(0,0,0,0))
		ui.drawRectFilledMultiColor(vec2(windowWidth-windowWidth/intensity,0), vec2(windowWidth,windowHeight), rgbm(0,0,0,0), rgbm(0,0,0,0),  rgbm(0,0,0,0), rgbm(0,0,0,0))
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
	ui.dummy(vec2(windowWidth/3, windowHeight/40))
	ui.sameLine()
	ui.beginRotation()
	ui.progressBar(raceState.distance/250, vec2(windowWidth/3,windowHeight/60), playerInFront)
	ui.endRotation(90,vec2(settings.msgOffsetX - windowWidth/2 - textLenght.x/2,settings.msgOffsetY))
	ui.dwriteDrawText(text, 30, vec2(settings.msgOffsetX - textLenght.x/2 , settings.msgOffsetY), rgbm.colors.white)
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
			if number <= 0 then text = "GO!"
			else text = number .. " ..." end
			textWithBackground(text, 3)
		end
		if timeStartRace - 6 > 0 then showRaceLights() end
		if timeStartRace < 0 then timeStartRace = 0 end
	elseif raceState.inRace and raceState.inFront then
		distanceBar()
		if raceState.inFront == raceState.opponent then
			if raceState.distance > 190 then
				flashingAlert(math.floor((190 - raceState.distance)/10)+10)
			end
		end
	elseif raceFinish.finished then
		text = ac.getDriverName(raceFinish.winner.index) .. " has won the race"
		displayText = true
		if not raceFinish.messageSent and raceFinish.winner == car then
			ac.sendChatMessage(ac.getDriverName(0) .. " has just beaten " .. raceFinish.opponentName .. string.format(" in an illegal race. [Win rate: %d",playerData.Wins * 100 / (playerData.Wins + playerData.Losses)) .. "%]")
			raceFinish.messageSent = true
			local data = {
				["Wins"] = playerData.Wins,
				["Losses"] = playerData.Losses,
			}
			updatefirebase()
			updatefirebaseData("STRace", data)
		end
	elseif horn.resquestTime > 0  and raceState.opponent then
		text = ac.getDriverName(raceState.opponent.index) .. " wants to challenge you to a race. To accept activate your horn twice quickly"
		displayText = true
	elseif horn.resquestTime > 0 and raceState.opponent == nil then
		text = "Waiting for " ..  horn.opponentName .. " to accept the challenge"
		displayText = true
	end
	if displayText then textWithBackground(text, 1) end
	ui.popDWriteFont()
end

--------------------------------------------------------------------------------------- Police Chase --------------------------------------------------------------------------------------------------

local policeLightsPos = {
	vec2(0,0), 
	vec2(windowWidth/15,windowHeight),
	vec2(windowWidth-windowWidth/15,0),
	vec2(windowWidth,windowHeight)
}

local acpPolice = ac.OnlineEvent({
    message = ac.StructItem.string(110),
	messageType = ac.StructItem.int16(),
	yourIndex = ac.StructItem.int16(),
}, function (sender, data)
	online.type = data.messageType
	if data.yourIndex == car.sessionID and data.messageType == 0 then
		online.message = data.message
		online.chased = true
		online.officer = sender
		online.messageTimer = settings.timeMsg
		policeLightsPos[2] = vec2(windowWidth/10,windowHeight)
		policeLightsPos[3] = vec2(windowWidth-windowWidth/10,0)
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
            online.color = rgbm.colors.white
        end
	elseif data.yourIndex == car.sessionID and data.messageType == 2 then
		online.message = data.message
		online.messageTimer = settings.timeMsg
		if data.message == "BUSTED!" then
			playerData.Busted = playerData.Busted + 1
		end
		online.chased = false
		online.officer = nil
		online.level = 0
		policeLightsPos[2] = vec2(windowWidth/6,windowHeight)
		policeLightsPos[3] = vec2(windowWidth-windowWidth/6,0)
	end
end)

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

local function showArrestMSG()
	ui.pushDWriteFont("Orbitron;Weight=Black")
	local textArrest1 = "BUSTED!"
	local textArrest2 = "GGs! Please Go Back To Pits."
	local textArrestLenght1 = ui.measureDWriteText(textArrest1, settings.fontSizeMSG*3)
	local textArrestLenght2 = ui.measureDWriteText(textArrest2, settings.fontSizeMSG*3)
	ui.drawRectFilled(vec2(0,0), vec2(windowWidth,windowHeight), rgbm(0, 0, 0, 0.5))
	ui.dwriteDrawText(textArrest1, settings.fontSizeMSG*3, vec2(windowWidth/2 - textArrestLenght1.x/2, windowHeight/4 - textArrestLenght1.y/2), rgbm(1, 0, 0, 1))
	ui.dwriteDrawText(textArrest2, settings.fontSizeMSG*3, vec2(windowWidth/2 - textArrestLenght2.x/2, windowHeight/4 + textArrestLenght2.y/2), rgbm(1, 1, 1, 1))
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
	[3] = "Busted",
	[4] = "Sector",
	[5] = "Overtake",
	[6] = "Drift",
	[7] = "Drug Delivery",
}

local iconsColorOn = {
	[1] = rgbm(1,1,1,1),
	[2] = rgbm(1,1,1,1),
	[3] = rgbm(1,1,1,1),
	[4] = rgbm(1,1,1,1),
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

local function drawText()
	ui.pushDWriteFont("Orbitron;Weight=BOLD")
    local textOffset = vec2(imageSize.x / 2, imageSize.y / 4.5)
    local textSize = ui.measureDWriteText(statOn[settings.current], settings.fontSize)
    if settings.current ~= 4 then ui.dwriteDrawText(statOn[settings.current], settings.fontSize, textOffset - vec2(textSize.x/2, 0), settings.colorHud) end
    if settings.current == 1 then
        local drivenKm = car.distanceDrivenSessionKm
        if drivenKm < 0.01 then drivenKm = 0 end
        textSize = ui.measureDWriteText(string.format("%.2f",drivenKm) .. " km", settings.fontSize)
        ui.dwriteDrawText(string.format("%.2f",drivenKm) .. " km", settings.fontSize, textOffset - vec2(textSize.x/2, -imageSize.y/13), rgbm(1, 1, 1, 0.9))
    elseif settings.current == 2 then
        textSize = ui.measureDWriteText(playerData.Wins .. "Win  -  Lost" .. playerData.Losses, settings.fontSize/1.1)
        ui.dwriteDrawText("Win " .. playerData.Wins .. " - Lost " .. playerData.Losses, settings.fontSize/1.1, textOffset - vec2(textSize.x/2, -imageSize.y/12.5), rgbm(1, 1, 1, 0.9))
    elseif settings.current == 3 then
        textSize = ui.measureDWriteText(playerData.Busted, settings.fontSize)
        ui.dwriteDrawText(playerData.Busted, settings.fontSize, textOffset - vec2(textSize.x/2, -imageSize.y/13), rgbm(1, 1, 1, 0.9))
    elseif settings.current == 4 then
        textSize = ui.measureDWriteText(sector.name, settings.fontSize)
        ui.dwriteDrawText(sector.name, settings.fontSize, textOffset - vec2(textSize.x/2, 0), settings.colorHud)
        textSize = ui.measureDWriteText("Time: 0:00:00", settings.fontSize)
        if sectorInfo.finished then
            ui.dwriteDrawText("Time: " .. sectorInfo.timerText, settings.fontSize, textOffset - vec2(textSize.x/2, -imageSize.y/13), rgbm(0, 1, 0, 1))
        else
            ui.dwriteDrawText("Time: " .. sectorInfo.timerText, settings.fontSize, textOffset - vec2(textSize.x/2, -imageSize.y/13), rgbm(1, 1, 1, 0.9))
        end
	elseif settings.current == 5 then
		overtakeUI(textOffset)
	elseif settings.current == 6 then
		driftUI(textOffset)
	elseif settings.current == 7 then
		textSize = ui.measureDWriteText("123 km/h", settings.fontSize)
		local avgSpeed = drugDelivery.avgSpeed
		local color = rgbm(1, 1, 1, 0.9)
		if drugDelivery.finalAvgSpeed > 1 then
			avgSpeed = drugDelivery.finalAvgSpeed
			if avgSpeed > 120 then color = rgbm(0, 1, 0, 1)
			else color = rgbm(1, 0, 0, 1) end
		end
		avgSpeed = avgSpeed * settings.unitMult
		ui.dwriteDrawText(string.format("%.1f ", avgSpeed) .. settings.unit, settings.fontSize, textOffset - vec2(textSize.x/2, -imageSize.y/13), color)
    end
	ui.popDWriteFont()
end

local stealingTime = 0
local stealMsgTime = 0

local function drawImage()
	iconsColorOn[1] = rgbm(0.99,0.99,0.99,1)
	iconsColorOn[2] = rgbm(0.99,0.99,0.99,1)
	iconsColorOn[3] = rgbm(0.99,0.99,0.99,1)
	iconsColorOn[4] = rgbm(0.99,0.99,0.99,1)
	local uiState = ac.getUI()
	local toolTipOn = false
	ui.drawImage(hudImg.center, vec2(0,0), imageSize)
	if ui.rectHovered(vec2(0,0), vec2(imageSize.x, imageSize.y/2)) then toolTipOn = true end
	if ui.rectHovered(imgPos.leftPos2, imgPos.leftPos1) then
		ui.image(hudImg.left, imageSize, settings.colorHud)
		if uiState.isMouseLeftKeyClicked then
			if settings.current == 1 then settings.current = #statOn else settings.current = settings.current - 1 end
		end
	elseif ui.rectHovered(imgPos.rightPos2, imgPos.rightPos1) then
		ui.image(hudImg.right, imageSize, settings.colorHud)
		if uiState.isMouseLeftKeyClicked then
			if settings.current == #statOn then settings.current = 1 else settings.current = settings.current + 1 end
		end
	elseif ui.rectHovered(imgPos.theftPos2, imgPos.theftPos1) then
		iconsColorOn[1] = settings.colorHud
		if uiState.isMouseLeftKeyClicked then
			if stealingTime == 0 then
				stealingTime = 30
				if not drugDelivery.drawPickUp then
					ac.sendChatMessage("* Stealing a " .. string.gsub(ac.getCarName(0), "%W", " ") .. os.date(" %x *"))
					stealMsgTime = 7
					if sectorInfo.sectorIndex ~= 3 and sectorInfo.timerText == "00:00.00" then
						sectorInfo.sectorIndex = 2
						sector = sectors[sectorInfo.sectorIndex]
						resetSectors()
						settings.current = 4
					end
				end
				if drugDelivery.active and not drugDelivery.started then
					ac.sendChatMessage(" has picked up the drugs at (" .. drugDelivery.pickUpName .. ") and is on the way to the drop off! (".. drugDelivery.dropOffName ..")")
					drugDelivery.call = true
				end
			end
		end
	elseif ui.rectHovered(imgPos.ranksPos2, imgPos.ranksPos1) then
		iconsColorOn[2] = settings.colorHud
		if uiState.isMouseLeftKeyClicked then
			if leaderboardOpen then leaderboardOpen = false
			else
				if menuOpen then
					menuOpen = false
					onSettingsChange()
				end
				leaderboardOpen = true
				loadLeaderboard()
			end
		end
	elseif ui.rectHovered(imgPos.countdownPos2, imgPos.countdownPos1) then
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
	elseif ui.rectHovered(imgPos.menuPos2, imgPos.menuPos1) then
		iconsColorOn[4] = settings.colorHud
		if uiState.isMouseLeftKeyClicked then
			if menuOpen then
				menuOpen = false
				onSettingsChange()
			else
				if leaderboardOpen then leaderboardOpen = false end
				menuOpen = true
			end
		end
	end
	ui.image(hudImg.base, imageSize, settings.colorHud)
	ui.drawImage(hudImg.theft, vec2(0,0), imageSize, iconsColorOn[1])
	ui.drawImage(hudImg.ranks, vec2(0,0), imageSize, iconsColorOn[2])
	ui.drawImage(hudImg.countdown, vec2(0,0), imageSize, iconsColorOn[3])
	ui.drawImage(hudImg.menu, vec2(0,0), imageSize, iconsColorOn[4])
	if countDownState.countdownOn then countdown() end
	if stealingTime > 0 then stealingTime = stealingTime - ui.deltaTime()
	elseif stealingTime < 0 then stealingTime = 0 end
	if toolTipOn then ui.tooltip(function ()
			ui.text("Click ALT to Bring up\nThe Welcome Menu")
		end)
	end
end

local function showMsgSteal()
	local text = "You have successfully stolen the " ..  string.gsub(string.gsub(ac.getCarName(0), "%W", " "), "  ", "") .. "! Hurry to the scrapyard!"
	textWithBackground(text, 1)
end

local function hudUI()
	if stealMsgTime > 0 then
		showMsgSteal()
		stealMsgTime = stealMsgTime - ui.deltaTime()
	elseif stealMsgTime < 0 then stealMsgTime = 0 end
	ui.beginTransparentWindow("HUD", vec2(settings.hudOffsetX, settings.hudOffsetY), imageSize, true)
	drawImage()
	drawText()
	ui.endTransparentWindow()
end

-------------------------------------------------------------------------------------------- Menu --------------------------------------------------------------------------------------------

local firstLoad = true
local initialized = false
local menuSize = {vec2(windowWidth/5, windowHeight/4), vec2(windowWidth/6, windowHeight*2/3), vec2(windowWidth/3, windowHeight/3)}
local currentTab = 1
local buttonPressed = false

local function menu()
	ui.tabBar('MainTabBar', ui.TabBarFlags.Reorderable, function ()
		ui.tabItem('Sectors', function () currentTab = sectorUI() end)
		ui.tabItem('settings', function () currentTab = settingsWindow() end)
	end)
end

local function moveMenu()
	if ui.windowHovered() and ui.mouseDown() then buttonPressed = true end
	if ui.mouseReleased() then buttonPressed = false end
	if buttonPressed then settings.menuPos = settings.menuPos + ui.mouseDelta() end
end

local function leaderboardWindow()
	ui.toolWindow('LeaderboardWindow', settings.menuPos, vec2(windowWidth/2, windowHeight/2), true, function ()
		ui.childWindow('childLeaderboard', vec2(windowWidth/2, windowHeight/2), true, function ()
			showLeaderboard()
			moveMenu()
		end)
	end)
end

--------------------------------------------------------------------------------- Welcome Menu ---------------------------------------------------------------------------------

local welcomeImg = {
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
}

local imgToDraw = { welcomeImg.leftArrowOff, welcomeImg.rightArrowOff, welcomeImg.leftBoxOff, welcomeImg.centerBoxOff, welcomeImg.rightBoxOff, welcomeImg.base, welcomeImg.logo}

local imgColor = {
	rgbm.colors.white,
	rgbm.colors.white,
	rgbm.colors.white,
	rgbm.colors.white,
	rgbm.colors.white,
	settings.colorHud,
	rgbm.colors.white,
}

-- Position for interaction with the image
-- Position is based on the image size of 2560x1440
local imgPos_ = {
	{vec2(70, 650), vec2(320, 910)},
	{vec2(2230, 650), vec2(2490, 910)},
	{vec2(357, 325), vec2(920, 1234)},
	{vec2(993, 325), vec2(1557, 1234)},
	{vec2(1633, 325), vec2(2195, 1234)},
	{vec2(31, 106), vec2(2535, 1370)},
	{vec2(2437, 48), vec2(2510, 100)},
}

local welcomeWindow = {
	size = vec2(16 * windowHeight / 9, windowHeight),
	topLeft = vec2(0, 0),
	topRight = vec2(windowWidth, 0),
	offset = vec2(0, 0),
	scale = 0.9,
	fontBold = ui.DWriteFont("Orbitron;Weight=BLACK"),
	font = ui.DWriteFont("Orbitron;Weight=REGULAR"),
	closeIMG = "https://acstuff.ru/images/icons_24/cancel.png",
	fontSize = windowHeight/35,
}


local function loadFont()
	local urlFont = "https://cdn.discordapp.com/attachment/1130004696984203325/1218567361892847708/EUROSTARBLACKEXTENDED.zip?ex=6608224a&is=65f5ad4a&hm=9e63bb730630e53c5f273e1e66f67684231380f71327793af6cb4603b141b989&"

    web.loadRemoteAssets(urlFont, function (err, folder)
		if err then
			print("Error loading font: " .. err)
			welcomeWindow.fontBold = ui.DWriteFont("Orbitron;Weight=BLACK")
			welcomeWindow.font = ui.DWriteFont("Orbitron;Weight=REGULAR")
		else
			welcomeWindow.fontBold = ui.DWriteFont("Eurostar Black Extended", folder):weight(ui.DWriteFont.Weight.Bold)
			welcomeWindow.font = ui.DWriteFont("Eurostar Black Extended", folder):weight(ui.DWriteFont.Weight.SemiBold)
		end
	end)
end

local function scalePositions()
	welcomeWindow.fontBold = ui.DWriteFont("Orbitron;Weight=BLACK")
	welcomeWindow.font = ui.DWriteFont("Orbitron;Weight=REGULAR")
	local xScale = windowWidth / 2560
	local yScale = windowHeight / 1440
	local minScale = math.min(xScale, yScale)

	welcomeWindow.size = welcomeWindow.size * welcomeWindow.scale
	welcomeWindow.offset = vec2((windowWidth - welcomeWindow.size.x) / 2, (windowHeight - welcomeWindow.size.y) / 2)
	minScale = minScale * welcomeWindow.scale
	for i = 1, #imgPos_ do
		imgPos_[i][1] = imgPos_[i][1] * minScale
		imgPos_[i][2] = imgPos_[i][2] * minScale
	end
	welcomeWindow.topLeft = imgPos_[6][1] + welcomeWindow.offset + welcomeWindow.size/100
	welcomeWindow.topRight = vec2(imgPos_[6][2].x - welcomeWindow.size.x/100, imgPos_[6][1].y + welcomeWindow.size.y/100) + welcomeWindow.offset
end

local imgSet = {
	"https://i.postimg.cc/5tW6DVV3/aboutacp.jpg",
	"https://i.postimg.cc/MHLG5k51/earnmoney.jpg",
	"https://i.postimg.cc/4yydp46J/leaderboard.jpg",
	"https://i.postimg.cc/T3DKkPZ1/bank.jpg",
	"https://i.postimg.cc/15LtNQfQ/police.jpg",
	"https://i.postimg.cc/WbKD6ZYx/buycars.jpg",
	"https://i.postimg.cc/sfLftrPh/tuning.jpg",
	"https://i.postimg.cc/bv0shBYj/cartheft.jpg",
	"https://i.postimg.cc/Jn1t45tH/drugdealer.jpg",
}

local imgLink = {
	"https://discord.com/channels/358562025032646659/1062186611091185784",--FAQ
	"https://discord.com/channels/358562025032646659/1147217487524528138",--earn
	"https://discord.com/channels/358562025032646659/1127619394328076318",--leaderboard
	"https://discord.com/channels/358562025032646659/1075578309443858522",--bank
	"https://discord.com/channels/358562025032646659/1095681142197325975",--police
	"https://discord.com/channels/358562025032646659/1076123906362056784",--car
	"https://discord.com/channels/358562025032646659/1079799948306034708",--tuning
	"https://discord.com/channels/358562025032646659/1096470595392241704",--car theft
	"",
}

local imgDisplayed = {1,2,3,4,5,6,7,8,9,}

local function drugShowInfo(i)
	local leftCorner = vec2(imgPos_[i+2][1].x, imgPos_[i+2][1].y) + vec2(welcomeWindow.size.x/100, welcomeWindow.size.y/10)
	local textPos = leftCorner + welcomeWindow.size/100
	ui.drawRectFilled(leftCorner,  vec2(imgPos_[i+2][2].x - welcomeWindow.size.x/100 , leftCorner.y + ui.measureDWriteText("Locations names are the same\nas the teleports in the mini map.\nDelivery : \n \nPick Up :  \nDrop Off :  " .. drugDelivery.dropOffName, settings.fontSize).y*2), rgbm(0, 0, 0, 0.8))
	ui.popDWriteFont()
	ui.pushDWriteFont("Orbitron;Weight=BLACK")
	ui.dwriteDrawText("Location names are the same\nas teleports in the mini map.", welcomeWindow.fontSize*0.6, textPos, rgbm.colors.white)
	textPos.y = textPos.y + ui.measureDWriteText("Locations names are the same\nas the teleports in the mini map.", welcomeWindow.fontSize*0.6).y*2
	ui.dwriteDrawText("Delivery : " .. os.date("%a the %d"), welcomeWindow.fontSize*0.6, textPos, rgbm.colors.white)
	textPos.x = textPos.x  + ui.measureDWriteText("Delivery : " .. os.date("%a the %d"), welcomeWindow.fontSize*0.6).x
	if os.date("%d") == "01" then
		ui.dwriteDrawText(" st", welcomeWindow.fontSize*0.6, textPos, rgbm.colors.white)
	elseif os.date("%d") == "02" then
		ui.dwriteDrawText(" nd", welcomeWindow.fontSize*0.6, textPos, rgbm.colors.white)
	elseif os.date("%d") == "03" then
		ui.dwriteDrawText(" rd", welcomeWindow.fontSize*0.6, textPos, rgbm.colors.white)
	else
		ui.dwriteDrawText("th", welcomeWindow.fontSize*0.6, textPos, rgbm.colors.white)
	end
	textPos.x = textPos.x - ui.measureDWriteText(os.date("%a the %d"), welcomeWindow.fontSize*0.6).x
	textPos.y = textPos.y + ui.measureDWriteText("Delivery : " .. os.date("%a the %d"), welcomeWindow.fontSize*0.6).y
	ui.dwriteDrawText("of " .. os.date("%B"), welcomeWindow.fontSize*0.6, textPos, rgbm.colors.white)
	textPos.x = textPos.x - ui.measureDWriteText("Delivery : ", welcomeWindow.fontSize*0.6).x
	textPos.y = textPos.y + ui.measureDWriteText("Delivery :  " .. os.date("%x"), welcomeWindow.fontSize*0.6).y*2
	ui.dwriteDrawText("Pick Up :  " .. drugDelivery.pickUpName, welcomeWindow.fontSize*0.6, textPos, rgbm.colors.white)
	textPos.y = textPos.y + ui.measureDWriteText("Pick Up :  " .. drugDelivery.pickUpName, welcomeWindow.fontSize*0.6).y*2
	ui.dwriteDrawText("Drop Off :  " .. drugDelivery.dropOffName, welcomeWindow.fontSize*0.6, textPos, rgbm.colors.white)
	ui.popDWriteFont()
end

local function drawMenuText()
	ui.popDWriteFont()
	ui.pushDWriteFont(welcomeWindow.font)
	ui.dwriteDrawText("WELCOME BACK,", welcomeWindow.fontSize*0.6, welcomeWindow.topLeft, rgbm.colors.white)
	ui.popDWriteFont()
	ui.pushDWriteFont(welcomeWindow.fontBold)
	ui.dwriteDrawText(ac.getDriverName(0), welcomeWindow.fontSize, vec2(welcomeWindow.topLeft.x, welcomeWindow.topLeft.y + ui.measureDWriteText("WELCOME BACK,", welcomeWindow.fontSize*0.6).y), settings.colorHud)
	ui.popDWriteFont()
	ui.pushDWriteFont(welcomeWindow.font)
	ui.dwriteDrawText("CURRENT CAR", welcomeWindow.fontSize*0.6, vec2(welcomeWindow.topRight.x - ui.measureDWriteText("CURRENT CAR", welcomeWindow.fontSize*0.6).x, welcomeWindow.topRight.y), rgbm.colors.white)
	ui.popDWriteFont()
	ui.pushDWriteFont(welcomeWindow.fontBold)
	ui.dwriteDrawText(string.gsub(string.gsub(ac.getCarName(0), "%W", " "), "  ", ""), welcomeWindow.fontSize, vec2(welcomeWindow.topRight.x - ui.measureDWriteText(string.gsub(string.gsub(ac.getCarName(0), "%W", " "), "  ", ""), welcomeWindow.fontSize).x - ui.measureDWriteText(carVersion, welcomeWindow.fontSize*0.8).x, welcomeWindow.topRight.y + ui.measureDWriteText("CURRENT CAR", welcomeWindow.fontSize*0.6).y), settings.colorHud)
	ui.popDWriteFont()
	ui.pushDWriteFont(welcomeWindow.font)
	ui.dwriteDrawText(carVersion, welcomeWindow.fontSize*0.7, vec2(welcomeWindow.topRight.x - ui.measureDWriteText(carVersion, welcomeWindow.fontSize*0.7).x, welcomeWindow.topRight.y + ui.measureDWriteText("CURRENT CAR", welcomeWindow.fontSize).y*0.85), rgbm.colors.white)
	ui.popDWriteFont()
end

local function drawMenuImage()
	local iconCloseColor = rgbm.colors.white
	local toolTipOn = false
	for i = 1, #imgColor - 1 do
		if i == #imgColor - 1 then imgColor[i] = settings.colorHud
		else imgColor[i] = rgbm.colors.white end
	end
	imgToDraw[1] = welcomeImg.leftArrowOff
	imgToDraw[2] = welcomeImg.rightArrowOff
	imgToDraw[3] = welcomeImg.leftBoxOff
	imgToDraw[4] = welcomeImg.centerBoxOff
	imgToDraw[5] = welcomeImg.rightBoxOff
	ui.transparentWindow('welcomeIMG', welcomeWindow.offset, welcomeWindow.size, true, function ()
		ui.childWindow('welcomeIMGChild', welcomeWindow.size, true, function ()
			local uiState = ac.getUI()
			ui.drawRectFilled(imgPos_[6][1], imgPos_[6][2], rgbm(0, 0, 0, 0.6))
			ui.drawRectFilled(imgPos_[7][1], imgPos_[7][2], rgbm(0, 0, 0, 0.6))
			if ui.rectHovered(imgPos_[1][1], imgPos_[1][2]) then
				imgColor[1] = settings.colorHud
				imgToDraw[1] = welcomeImg.leftArrowOn
				if uiState.isMouseLeftKeyClicked then
					for i = 1, #imgDisplayed do
						if imgDisplayed[i] == 1 then
							imgDisplayed[i] = #imgSet
						else
							imgDisplayed[i] = imgDisplayed[i] - 1
						end
					end
				end
			elseif ui.rectHovered(imgPos_[2][1], imgPos_[2][2]) then
				imgColor[2] = settings.colorHud
				imgToDraw[2] = welcomeImg.rightArrowOn
				if uiState.isMouseLeftKeyClicked then
					for i = 1, #imgDisplayed do
						if imgDisplayed[i] == #imgSet then
							imgDisplayed[i] = 1
						else
							imgDisplayed[i] = imgDisplayed[i] + 1
						end
					end
				end
			elseif ui.rectHovered(imgPos_[3][1], imgPos_[3][2]) then
				toolTipOn = true
				imgColor[3] = settings.colorHud
				imgToDraw[3] = welcomeImg.leftBoxOn
				if uiState.isMouseLeftKeyClicked and uiState.ctrlDown then os.openURL(imgLink[imgDisplayed[1]]) end
			elseif ui.rectHovered(imgPos_[4][1], imgPos_[4][2]) then
				toolTipOn = true
				imgColor[4] = settings.colorHud
				imgToDraw[4] = welcomeImg.centerBoxOn
				if uiState.isMouseLeftKeyClicked and uiState.ctrlDown then os.openURL(imgLink[imgDisplayed[2]]) end
			elseif ui.rectHovered(imgPos_[5][1], imgPos_[5][2]) then
				toolTipOn = true
				imgColor[5] = settings.colorHud
				imgToDraw[5] = welcomeImg.rightBoxOn
				if uiState.isMouseLeftKeyClicked and uiState.ctrlDown then os.openURL(imgLink[imgDisplayed[3]]) end
			elseif ui.rectHovered(imgPos_[7][1], imgPos_[7][2]) then
				iconCloseColor = settings.colorHud
				if uiState.isMouseLeftKeyClicked then welcomeClosed = true end
			end
				ui.drawImage(welcomeWindow.closeIMG, imgPos_[7][1]+vec2(10,10), imgPos_[7][2]-vec2(10,10), iconCloseColor)
			for i = 1, #imgToDraw do ui.drawImage(imgToDraw[i], vec2(0,0), welcomeWindow.size, imgColor[i]) end
			for i = 1, 3 do
				if imgDisplayed[i] == 9 then
					ui.drawImage(imgSet[imgDisplayed[i]], imgPos_[i+2][1], imgPos_[i+2][2], rgbm(1,1,1,1))
					drugShowInfo(i)
				else ui.drawImage(imgSet[imgDisplayed[i]], imgPos_[i+2][1], imgPos_[i+2][2], rgbm(1,1,1,1)) end
			end
		end)
	end)
	if toolTipOn then ui.tooltip(function ()
			ui.text("CTRL + Left Click to open Discord link\nWhere you can find more information")
		end)
	end
end

local function drawMenuWelcome()
	drawMenuImage()
	drawMenuText()
end

-------------------------------------------------------------------------------- UPDATE --------------------------------------------------------------------------------



function script.drawUI()
	return
	if ui.keyboardButtonPressed(ui.KeyIndex.Menu) then welcomeClosed = not welcomeClosed end
	if not welcomeClosed then
		drawMenuWelcome()
	elseif initialized then
		if cspVersion < cspMinVersion then return end
		if firstLoad then
			updatePos()
			firstLoad = false
		end
		if online.chased then showStarsPursuit() end
		hudUI()
		onlineEventMessageUI()
		raceUI()
		drugDeliveryUI()
		if menuOpen then
			ui.toolWindow('Menu', settings.menuPos, menuSize[currentTab], true, function ()
				ui.childWindow('childMenu', menuSize[currentTab], true, ui.WindowFlags.MenuBar, function ()
					menu()
					moveMenu()
				end)
			end)
		end
		if leaderboardOpen then leaderboardWindow() end
	end
end

local policeCarIndex = {0, 0, 0, 0, 0, 0}

local function initPoliceCarIndex()
	local j = 1
	for i = ac.getSim().carsCount - 1, 0, -1 do
		local playerCarID = ac.getCarID(i)
		if playerCarID == valideCar[1] or playerCarID == valideCar[2] or carID == valideCar[3] then
			policeCarIndex[j] = i
			j = j + 1
		end
	end
end

local function hidePolice()
	local hideRange = 100
	for i = 1, 6 do
		local player = ac.getCar(policeCarIndex[i])
		if player.isConnected then
			if player.position.x > car.position.x - hideRange and player.position.z > car.position.z - hideRange and player.position.x < car.position.x + hideRange and player.position.z < car.position.z + hideRange then
				ac.hideCarLabels(i, false)
			else
				ac.hideCarLabels(i, true)
			end
		end
	end
end

function script.update(dt)
	return
	if not initialized then
		ac.log("ACP Essential APP")
		if carID == valideCar[1] or carID == valideCar[2] or carID == valideCar[3] or cspVersion < cspMinVersion then return end
		loadSettings()
		initLines()
		initialized = true
		getFirebase()
		loadLeaderboard()
		initDrugRoute()
		scalePositions()
		initOverTake()
		initPoliceCarIndex()
	else
		sectorUpdate()
		raceUpdate(dt)
		overtakeUpdate(dt)
		driftUpdate(dt)
		drugDeliveryUpdate(dt)
		hidePolice()
	end
end

ac.onCarJumped(0, function (carIndex)
	if carID ~= valideCar[1] and carID ~= valideCar[2] and carID ~= valideCar[3] then
		ac.log("Car Jumped")
		resetSectors()
		if drugDelivery.started then
			ac.sendChatMessage(" has crashed and lost the drugs!")
		end
		resetDrugDelivery()
		if online.chased and online.officer then
			acpPolice{message = "TP", messageType = 0, yourIndex = online.officer.sessionID}
		end
	end
end)

ac.onClientConnected(function (carIndex)
	local newCar = ac.getCarID(carIndex)
	ac.log("New Car : " .. newCar)
	if newCar == valideCar[1] or newCar == valideCar[2] or newCar == valideCar[3] then
		ac.hideCarLabels(carIndex)
	end
	initPoliceCarIndex()
end)

ac.onClientDisconnected(function (carIndex)
	local newCar = ac.getCarID(carIndex)
	ac.log("Car Disconnected : " .. newCar)
	ac.hideCarLabels(carIndex, false)
end)

ac.onChatMessage(function (message, senderCarIndex, senderSessionID)
	if carID ~= valideCar[1] and carID ~= valideCar[2] and carID ~= valideCar[3] and online.chased and online.officer then
		if (senderSessionID == online.officer.sessionID and string.find(message, 'lost')) then
			if not playerData.Getaway then playerData.Getaway = 0 end
			playerData.Getaway = playerData.Getaway + 1
			online.chased = false
			online.officer = nil
			local data = {
				["Getaway"] = playerData.Getaway,
			}
			updatefirebase()
			updatefirebaseData("Getaway", data)
		end
	end
end)

function script.draw3D()
	return
	render.setBlendMode(render.BlendMode.AlphaBlend)
    render.setCullMode(render.CullMode.None)
	render.setDepthMode(render.DepthMode.Normal)
	if initialized and settings.current == 4 then
		if sectorInfo.drawLine then render.debugLine(sector.pointsData[sectorInfo.checkpoints][1], sector.pointsData[sectorInfo.checkpoints][2], rgbm(0,100,0,1)) end
	end
	if initialized then
		if drugDelivery.drawPickUp then render.circle(drugDelivery.pickUp, vec3(0,1,0), 4, rgbm(0,1,0,1))
		elseif drugDelivery.drawDropOff then render.circle(drugDelivery.dropOff, vec3(0,1,0), 4, rgbm(0,1,0,1)) end
	end
end

if carID ~= valideCar[1] and carID ~= valideCar[2] and carID ~= valideCar[3] and cspVersion >= cspMinVersion then
	ui.registerOnlineExtra(ui.Icons.Menu, "Menu", nil, menu, nil, ui.OnlineExtraFlags.Tool, 'ui.WindowFlags.AlwaysAutoResize')
end
