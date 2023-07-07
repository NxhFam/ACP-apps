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

--------------firebase--------------
local firebaseUrl = 'https://acp-server-97674-default-rtdb.firebaseio.com/Players'
local sheetH1B = 'https://docs.google.com/spreadsheets/d/e/2PACX-1vQjvxf3hfas5hkZEsC0AtFZLfycrWSBypkHyIWGt_2eD-FOARKFcdp6Ib3J2C6h3DyRHd_FxKQfekko/pub?gid=1485964543&single=true&output=csv'
local sheetH1C = 'https://docs.google.com/spreadsheets/d/e/2PACX-1vQjvxf3hfas5hkZEsC0AtFZLfycrWSBypkHyIWGt_2eD-FOARKFcdp6Ib3J2C6h3DyRHd_FxKQfekko/pub?gid=1055663571&single=true&output=csv'
local sheetVV = 'https://docs.google.com/spreadsheets/d/e/2PACX-1vQjvxf3hfas5hkZEsC0AtFZLfycrWSBypkHyIWGt_2eD-FOARKFcdp6Ib3J2C6h3DyRHd_FxKQfekko/pub?gid=683938135&single=true&output=csv'
local sheetElo = 'https://docs.google.com/spreadsheets/d/e/2PACX-1vQjvxf3hfas5hkZEsC0AtFZLfycrWSBypkHyIWGt_2eD-FOARKFcdp6Ib3J2C6h3DyRHd_FxKQfekko/pub?gid=1426211490&single=true&output=csv'

local leaderboard = {}
local leaderboardName = 'Class B - H1'
local leaderboardNames = {'Class B - H1', 'Class C - H1', 'Velocity Vendetta', 'Elo Rating'}


local sim = ac.getSim()
local car = ac.getCar(0)
local windowWidth = sim.windowWidth
local windowHeight = sim.windowHeight
local menuOpen = false
local leaderboardOpen = false
local settingsLoaded = true
local amgGtrValid = ac.INIConfig.carData(0, 'brakes.ini'):get("DATA", "MAX_TORQUE", 0) == 3950 and ac.getCarID(0) == "amgtr_acp23"

local valideCar = {"chargerpolice_acpursuit", "crown_police"}

local sharedDataSettings = ac.connect({
	ac.StructItem.key('ACP_essential_settings'),
	showStats = ac.StructItem.boolean(),
	racesWon = ac.StructItem.int16(),
	racesLost = ac.StructItem.int16(),
	busted = ac.StructItem.int16(),
	essentialSize = ac.StructItem.int16(),
	policeSize = ac.StructItem.int16(),
	statsOffsetX = ac.StructItem.int16(),
	statsOffsetY = ac.StructItem.int16(),
	statsFont = ac.StructItem.int16(),
	current = ac.StructItem.int16(),
	colorHud = ac.StructItem.rgbm(),
	send = ac.StructItem.boolean(),
	timeMsg = ac.StructItem.int16(),
	msgOffsetY = ac.StructItem.int16(),
	msgOffsetX = ac.StructItem.int16(),
	fontSizeMSG = ac.StructItem.int16(),
	menuPos = ac.StructItem.vec2(),
	unit = ac.StructItem.string(4),
	unitMult = ac.StructItem.float(),
}, true, ac.SharedNamespace.Shared)

ui.setAsynchronousImagesLoading(true)
local imageSize = vec2(0,0)

local imgPos = {}

local assetsFolder = ac.getFolder(ac.FolderID.ACApps) .. "/lua/ACP_essential/HUD/"
local hudBase = assetsFolder .. "hudBase.png"
local hudLeft = assetsFolder .. "hudLeft.png"
local hudRight = assetsFolder .. "hudRight.png"
local hudCenter = assetsFolder .. "hudCenter.png"
local hudCountdown = assetsFolder .. "iconCountdown.png"
local hudMenu = assetsFolder .. "iconMenu.png"
local hudRanks = assetsFolder .. "iconRanks.png"
local hudTheft = assetsFolder .. "iconTheft.png"

local function loadImages()
	assetsFolder = ac.getFolder(ac.FolderID.ACApps) .. "/lua/ACP_essential/HUD/"
	hudBase = assetsFolder .. "hudBase.png"
	hudLeft = assetsFolder .. "hudLeft.png"
	hudRight = assetsFolder .. "hudRight.png"
	hudCenter = assetsFolder .. "hudCenter.png"
	hudCountdown = assetsFolder .. "iconCountdown.png"
	hudMenu = assetsFolder .. "iconMenu.png"
	hudRanks = assetsFolder .. "iconRanks.png"
	hudTheft = assetsFolder .. "iconTheft.png"
end

local playerData = {}
local sectors = {
    {
        name = 'H1',
		pointsData = {{vec3(-742.9, 138.9, 3558.7), vec3(-729.8, 138.9, 3542.8)},
					{vec3(3008.2, 73, 1040.3), vec3(2998.8, 73, 1017.3)}},
        linesData = {vec4(-742.9, 3558.7, -729.8, 3542.8), vec4(3008.2, 1040.3, 2998.8, 1017.3)},
        length = 26.3,
    },
    {
        name = 'BOBs SCRAPYARD',
		pointsData = {{vec3(-742.9, 139, 3558.7), vec3(-729.8, 139, 3542.8)},
					{vec3(-3537.4, 23.8, -199.8), vec3(-3544.4, 23.8, -212.2)}},
        linesData = {vec4(-742.9, 3558.7, -729.8, 3542.8), vec4(-3537.4, -199.8, -3544.4, -212.2)},
        length = 6.35,
    },
    {
        name = 'DOUBLE TROUBLE',
		pointsData = {{vec3(-742.9, 139, 3558.7), vec3(-729.8, 139, 3542.8)},
					{vec3(-3537.4, 23.8, -199.8), vec3(-3544.4, 23.8, -212.2)}},
        linesData = {vec4(-742.9, 3558.7, -729.8, 3542.8), vec4(-3537.4, -199.8, -3544.4, -212.2)},
        length = 6.35,
    },
    {
        name = 'Velocity Vendetta',
		pointsData = {{vec3(285.1, -193.3, -6755.3),vec3(291.6, -193.4, -6747.1)},
					{vec3(912.6, -215.7, -6951.7),vec3(918.4, -215.8, -6943.2)},
					{vec3(1479.7,-263.9,-8141.4),vec3(1484.4,-264.3,-8131.3)},
					{vec3(2369.9, -275.8, -8198.2),vec3(2372.5, -275.8, -8188.1)},
					{vec3(3192.5,-296.2,-8306.6),vec3(3196.2,-296.6,-8319.6)},
					{vec3(3409.4, -301.1, -8144.1),vec3(3401.4, -300.6, -8134.8)},
					{vec3(3196.2,-296.6,-8319.6),vec3(3192.5,-296.2,-8306.6)},
					{vec3(2372.5, -275.8, -8188.1),vec3(2369.9, -275.8, -8198.2)},
					{vec3(1484.4,-264.3,-8131.3),vec3(1479.7,-263.9,-8141.4)},
					{vec3(918.4, -215.8, -6943.2),vec3(912.6, -215.7, -6951.7)},
					{vec3(291.6, -193.4, -6747.1),vec3(285.1, -193.3, -6755.3)}},
		linesData =	{vec4(285.1, -6755.3, 291.6, -6747.1),
					vec4(912.6, -6951.7, 918.4, -6943.2),
					vec4(1479.7,-8141.4,1484.4,-8131.3),
					vec4(2369.9, -8198.2, 2372.5, -8188.1),
					vec4(3196.2,-8319.6,3192.5,-8306.6),
					vec4(3409.4, -8144.1, 3401.4, -8134.8),
					vec4(3192.5,-8306.6,3196.2,-8319.6),
					vec4(2372.5, -8188.1, 2369.9, -8198.2),
					vec4(1484.4,-8131.3,1479.7,-8141.4),
					vec4(918.4, -6943.2, 912.6, -6951.7),
					vec4(291.6, -6747.1, 285.1, -6755.3)},
		length = 8.51,
    }
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

local function midPoint(p1, p2)
	local point = vec3((p1.x + p2.x)/2, (p1.y + p2.y)/2, (p1.z + p2.z)/2)
	local radius = distance(vec2(p1.x, p1.z), vec2(point.x, point.z))
	return point, radius
end

-- Init

local function updatePos()
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
end

local function initSettings()
	settingsLoaded = false
	SETTINGS = {
		showStats = true,
		racesWon = 0,
		racesLost = 0,
		busted = 0,
		essentialSize = 20,
		policeSize = 20,
		statsOffsetX = 0,
		statsOffsetY = 0,
		statsFont = 20,
		current = 1,
		colorHud = rgbm(1,0,0,1),
		send = false,
		timeMsg = 10,
		msgOffsetY = 10,
		msgOffsetX = windowWidth/2,
		fontSizeMSG = 30,
		menuPos = vec2(0, 0),
		unit = "km/h",
		unitMult = 1,
	}
end


local function initLines()
	ac.log(sharedDataSettings.showStats)
	if not sharedDataSettings.showStats then initSettings()
	else
		SETTINGS = sharedDataSettings
	end
	SETTINGS.statsFont = SETTINGS.essentialSize * windowHeight/1440
	imageSize = vec2(windowHeight/80 * SETTINGS.essentialSize, windowHeight/80 * SETTINGS.essentialSize)
	for i = 1, #sectors do
		local lines = {}
		for j = 1, #sectors[i].linesData do
            local line = {}
            line.p1 = vec2(sectors[i].linesData[j].x, sectors[i].linesData[j].y)
            line.p2 = vec2(sectors[i].linesData[j].z, sectors[i].linesData[j].w)
            line.dir = normalize(line.p2 - line.p1)
            line.region = regionAroundLine(line)
			line.midPoint, line.radius = midPoint(sectors[i].pointsData[j][1], sectors[i].pointsData[j][2])
            table.insert(lines, line)
        end
		sectors[i].lines = lines
	end
    sector = sectors[1]
	updatePos()
end

----------------------------------------------------------------------------------------------- Settings -----------------------------------------------------------------------------------------------


local showPreviewMsg = false
local showPreviewDistanceBar = false
COLORSMSGBG = rgbm(0.5,0.5,0.5,0.5)

local function distanceBarPreview()
	ui.beginTransparentWindow("progressBar", vec2(0, 0), vec2(windowWidth, windowHeight))
	local playerInFront = "You are in front"
	local text = math.floor(50) .. "m"
	local textLenght = ui.measureDWriteText(text, 30)
	ui.newLine()
	ui.dummy(vec2(windowWidth/3, windowHeight/40))
	ui.sameLine()
	ui.beginRotation()
	ui.progressBar(125/250, vec2(windowWidth/3,windowHeight/60), playerInFront)
	ui.endRotation(90,vec2(SETTINGS.msgOffsetX - windowWidth/2 - textLenght.x/2,SETTINGS.msgOffsetY + textLenght.y/3))
	ui.dwriteDrawText(text, 30, vec2(SETTINGS.msgOffsetX - textLenght.x/2 , SETTINGS.msgOffsetY), rgbm.colors.white)
	ui.endTransparentWindow()
end

local function previewMSG()
	ui.beginTransparentWindow("previewMSG", vec2(0, 0), vec2(windowWidth, windowHeight))
	ui.pushDWriteFont("Orbitron;Weight=Black")
	local textSize = ui.measureDWriteText("Messages from Police when being chased", SETTINGS.fontSizeMSG)
	local uiOffsetX = SETTINGS.msgOffsetX - textSize.x/2
	local uiOffsetY = SETTINGS.msgOffsetY
	ui.drawRectFilled(vec2(uiOffsetX - 5, uiOffsetY-5), vec2(uiOffsetX + textSize.x + 5, uiOffsetY + textSize.y + 5), COLORSMSGBG)
	ui.dwriteDrawText("Messages from Police when being chased", SETTINGS.fontSizeMSG, vec2(uiOffsetX, uiOffsetY), SETTINGS.colorHud)
	ui.popDWriteFont()
	ui.endTransparentWindow()
end

local function uiTab()
    if ui.checkbox('Send score in chat', SETTINGS.send) then SETTINGS.send = not SETTINGS.send end
	ui.newLine()
	ui.text('On Screen Message : ')
	SETTINGS.timeMsg = ui.slider('##' .. 'Time Msg On Screen', SETTINGS.timeMsg, 1, 15, 'Time Msg On Screen' .. ': %.0fs')
	SETTINGS.fontSizeMSG = ui.slider('##' .. 'Font Size MSG', SETTINGS.fontSizeMSG, 10, 50, 'Font Size' .. ': %.0f')
	ui.newLine()
	ui.text('Offset : ')
	SETTINGS.msgOffsetY = ui.slider('##' .. 'Msg On Screen Offset Y', SETTINGS.msgOffsetY, 0, windowHeight, 'Msg On Screen Offset Y' .. ': %.0f')
	SETTINGS.msgOffsetX = ui.slider('##' .. 'Msg On Screen Offset X', SETTINGS.msgOffsetX, 0, windowWidth, 'Msg On Screen Offset X' .. ': %.0f')
    ui.newLine()
	ui.text('Preview : ')
    if ui.button('Message') then
        showPreviewMsg = not showPreviewMsg
        if showPreviewMsg then showPreviewDistanceBar = false end
    end
    ui.sameLine()
    if ui.button('Distance Bar') then
        showPreviewDistanceBar = not showPreviewDistanceBar
        if showPreviewDistanceBar then showPreviewMsg = false end
    end
    if showPreviewMsg then previewMSG() end
    if showPreviewDistanceBar then distanceBarPreview() end
	ui.sameLine()
	if ui.button('Offset X to center') then SETTINGS.msgOffsetX = windowWidth/2 end
	ui.newLine()
end


local function settings()
	imageSize = vec2(windowHeight/80 * SETTINGS.essentialSize, windowHeight/80 * SETTINGS.essentialSize)
	ui.sameLine(10)
	ui.beginGroup()
	ui.newLine(15)
	if ui.checkbox('Show HUD', SETTINGS.showStats) then SETTINGS.showStats = not SETTINGS.showStats end
	ui.sameLine(windowWidth/6 - 120)
	if ui.button('Close', vec2(100, windowHeight/50)) then menuOpen = false end
	SETTINGS.statsOffsetX = ui.slider('##' .. 'HUD Offset X', SETTINGS.statsOffsetX, 0, windowWidth, 'HUD Offset X' .. ': %.0f')
	SETTINGS.statsOffsetY = ui.slider('##' .. 'HUD Offset Y', SETTINGS.statsOffsetY, 0, windowHeight, 'HUD Offset Y' .. ': %.0f')
	SETTINGS.essentialSize = ui.slider('##' .. 'HUD Size', SETTINGS.essentialSize, 10, 50, 'HUD Size' .. ': %.0f')
	local fontMultiplier = windowHeight/1440
	SETTINGS.statsFont = SETTINGS.essentialSize * fontMultiplier
    ui.setNextItemWidth(300)
	local colorHud = SETTINGS.colorHud
    ui.colorPicker('Theme Color', colorHud, ui.ColorPickerFlags.AlphaBar)
    ui.newLine()
    uiTab()
	ui.endGroup()
	return 2
end

----------------------------------------------------------------------------------------------- Firebase -----------------------------------------------------------------------------------------------

local function addPlayerToDataBase(steamID)
	local name = ac.getDriverName(0)
	local str = '{"' .. steamID .. '": {"Name":"' .. name .. '","Elo": 1200,"Wins": 0,"Losses": 0,"Busted": 0,"Sectors": {"H1": {},"VV": {}}}}'
	web.request('PATCH', firebaseUrl .. ".json", str, function(err, response)
		if err then
			print(err)
			return
		end
		local data = response.body
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

-- Retrieve data from Google Sheet in CSV format
-- Headers
-- Data...
local urlAppScript = 'https://script.google.com/macros/s/AKfycbwenxjCAbfJA-S90VlV0y7mEH75qt3TuqAmVvlGkx-Y1TX8z5gHtvf5Vb8bOVNOA_9j/exec'
local function loadLeaderboardFromSheet()
	local sheetUrl = sheetH1B
	if leaderboardName == leaderboardNames[2] then sheetUrl = sheetH1C
	elseif leaderboardName == leaderboardNames[3] then sheetUrl = sheetVV
	elseif leaderboardName == leaderboardNames[4] then sheetUrl = sheetElo end

	web.get(sheetUrl, function(err, response)
		if err then
			print(err)
			return
		else
			table.clear(leaderboard)
			local csv = response.body
			local lines = csv:split('\n')
			for i=1, #lines do
				local line = lines[i]:split(',')
				local entry = {}
				for j=1, #line do
					if i > 1 then
						if leaderboardName == leaderboardNames[4] and j == 3 then line[j] = string.format("%d",tonumber(line[j]))
						elseif  leaderboardName ~= leaderboardNames[4] and j == 2 then line[j] = timeFormat(tonumber(line[j])) end
					end
					table.insert(entry, line[j])
				end
				table.insert(leaderboard, entry)
			end
		end
	end)
end

local function getFirebase()
	local url = firebaseUrl .. "/" .. ac.getUserSteamID() .. '.json'
	web.get(url, function(err, response)
		if err then
			print(err)
			return
		else
			if response.body == 'null' then
				addPlayerToDataBase(ac.getUserSteamID())
			else
				local jString = response.body
				playerData = json.parse(jString)
			end
		end
	end)
end

local function updateSheets()
	web.post(urlAppScript, function(err, response)
		if err then
			print(err)
			return
		else
			print(response.body)
			loadLeaderboardFromSheet()
		end
	end)
end

local function updatefirebase()
	local str = '{"' .. ac.getUserSteamID() .. '": ' .. json.stringify(playerData) .. '}'
	web.request('PATCH', firebaseUrl .. ".json", str, function(err, response)
		if err then
			print(err)
			return
		else
			updateSheets()
		end
	end)
end

local function updateSector(sectorName, time)
	local carName = ac.getCarID(0)

	if sectorName == 'H1' then
		if not playerData.Sectors then
			playerData.Sectors = {
				H1 = {
					[carName] = {
						Time = time,
					},
				},
				VV = {},
			}
		end
		if playerData.Sectors.H1 then
			if not playerData.Sectors.H1[carName] then
				playerData.Sectors.H1[carName] = {
					Time = time,
				}
			end
			if time < playerData.Sectors.H1[carName].Time then
				playerData.Sectors.H1[carName].Time = time
			end
		else
			playerData.Sectors.H1 = {
				[carName] = {
					Time = time,
				},
			}
		end
	end
	if sectorName == 'VV' then
		if not playerData.Sectors then
			playerData.Sectors = {
				H1 = {},
				VV = {
					Time = time,
				},
			}
		end
		if playerData.Sectors.VV then
			if time < playerData.Sectors.VV.Time then
				playerData.Sectors.VV.Time = time
			end
		else
			playerData.Sectors.VV = {
				Time = time,
			}
		end
	end
	updatefirebase()
end

local function eloRating(result)
    if raceState.elo == 0 then raceState.elo = 1200 end
    local K = 32 -- Adjust this value based on desired sensitivity

    local expectedScore = 1 / (1 + 10^(raceState.elo - playerData.elo) / 400)

    playerData.elo = playerData.elo + K * (result - expectedScore)
end

local boxHeight = windowHeight/70

local function displayInGrid()
	local box1 = vec2(windowWidth/32, boxHeight)
	local nbCol = #leaderboard[1]
	local colWidth = (windowWidth/3 - windowWidth/32)/(nbCol-1)
	ui.pushDWriteFont("Orbitron;Weight=Black")
	ui.newLine()
	ui.dwriteTextAligned("Pos", SETTINGS.statsFont/1.5, ui.Alignment.Center, ui.Alignment.Center, box1, false, SETTINGS.colorHud)
	for i = 2, nbCol do
		local textLenght = ui.measureDWriteText(leaderboard[1][i], SETTINGS.statsFont/1.5).x
		ui.sameLine(box1.x + colWidth/2 + colWidth*(i-2) - textLenght/2)
		ui.dwriteTextWrapped(leaderboard[1][i], SETTINGS.statsFont/1.5, SETTINGS.colorHud)
	end
	ui.newLine()
	ui.popDWriteFont()
	ui.pushDWriteFont("Orbitron;Weight=Regular")
	for i = 2, #leaderboard do
		local entry = leaderboard[i]
		local sufix = "th"
		if i == 2 then sufix = "st"
		elseif i == 3 then sufix = "nd"
		elseif i == 4 then sufix = "rd" end
		ui.dwriteTextAligned(i-1 .. sufix, SETTINGS.statsFont/2, ui.Alignment.Center, ui.Alignment.Center, box1, false, rgbm.colors.white)
		for j = 2, #entry do
			local textLenght = ui.measureDWriteText(entry[j], SETTINGS.statsFont/1.5).x
			ui.sameLine(box1.x + colWidth/2 + colWidth*(j-2) - textLenght/2)
			ui.dwriteTextWrapped(entry[j], SETTINGS.statsFont/1.5, rgbm.colors.white)
		end
	end
	ui.popDWriteFont()
	local lineHeight = math.max(ui.itemRectMax().y, windowHeight/3)
	ui.drawLine(vec2(box1.x, windowHeight/20), vec2(box1.x, lineHeight), rgbm.colors.white, 1)
	for i = 1, nbCol-2 do
		ui.drawLine(vec2(box1.x + colWidth*i, windowHeight/20), vec2(box1.x + colWidth*i, lineHeight), rgbm.colors.white, 2)
	end
	ui.drawLine(vec2(0, windowHeight/12), vec2(windowWidth/3, windowHeight/12), rgbm.colors.white, 1)
end
-- local function displayInGrid()
-- 	local box1 = vec2(windowWidth/32, windowHeight/70)
-- 	local nbCol = #leaderboard[1]
-- 	local box2 = vec2((windowWidth/3 - windowWidth/32)/(nbCol-1), windowHeight/70)
-- 	ui.pushDWriteFont("Orbitron;Weight=Black")
-- 	ui.newLine()
-- 	ui.dwriteTextAligned("Pos", SETTINGS.statsFont/1.5, ui.Alignment.Center, ui.Alignment.Center, box1, false, SETTINGS.colorHud)
-- 	for i = 2, nbCol do
-- 		ui.sameLine()
-- 		ui.dwriteTextAligned(leaderboard[1][i], SETTINGS.statsFont/1.5, ui.Alignment.Center, ui.Alignment.Center, box2, false, SETTINGS.colorHud)
-- 	end
-- 	ui.newLine()
-- 	ui.popDWriteFont()
-- 	ui.pushDWriteFont("Orbitron;Weight=Regular")
-- 	for i = 2, #leaderboard do
-- 		local entry = leaderboard[i]
-- 		local sufix = "th"
-- 		if i == 2 then sufix = "st"
-- 		elseif i == 3 then sufix = "nd"
-- 		elseif i == 4 then sufix = "rd" end
-- 		ui.dwriteTextAligned(i-1 .. sufix, SETTINGS.statsFont/2, ui.Alignment.Center, ui.Alignment.Center, box1, false, rgbm.colors.white)
-- 		ui.sameLine()
-- 		for j = 2, #entry do
-- 			ui.sameLine()
-- 			ui.dwriteTextAligned(entry[j], SETTINGS.statsFont/2, ui.Alignment.Center, ui.Alignment.Center, box2, false, rgbm.colors.white)
-- 		end
-- 	end
-- 	ui.popDWriteFont()
-- 	local lineHeight = math.max(ui.itemRectMax().y, windowHeight/3)
-- 	ui.drawLine(vec2(box1.x, windowHeight/20), vec2(box1.x, lineHeight), rgbm.colors.white, 1)
-- 	for i = 1, nbCol-2 do
-- 		ui.drawLine(vec2(box1.x + box2.x*i, windowHeight/20), vec2(box1.x + box2.x*i, lineHeight), rgbm.colors.white, 1)
-- 	end
-- 	ui.drawLine(vec2(0, windowHeight/12), vec2(windowWidth/4, windowHeight/12), rgbm.colors.white, 1)
-- end


local function showLeaderboard()
	ui.dummy(vec2(windowWidth/20, 0))
	ui.sameLine()
	ui.setNextItemWidth(windowWidth/12)
	ui.combo("leaderboard", leaderboardName, function ()
		for i = 1, #leaderboardNames do
			if ui.selectable(leaderboardNames[i], leaderboardName == leaderboardNames[i]) then
				leaderboardName = leaderboardNames[i]
				loadLeaderboardFromSheet()
			end
		end
	end)
	ui.sameLine(windowWidth/4 - 120)
	if ui.button('Close', vec2(100, windowHeight/50)) then leaderboardOpen = false end
	ui.newLine()
	displayInGrid()
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
	elseif sectorInfo.sectorIndex  == #sectors then
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
	elseif data.yourIndex == car.sessionID and sender.index == duo.teammate.index and data.messageType == 5 and data.message == "Finished" then
		duo.teammateHasFinished = true
	elseif data.yourIndex == car.sessionID and sender.index == duo.teammate.index and data.messageType == 5 and data.message == "Cancel" then
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
			if carPlayer.index ~= car.index then
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
	if ui.button('Close', vec2(100, windowHeight/50)) then menuOpen = false end
	if sector.name == "Velocity Vendetta" and not amgGtrValid and ac.getCarID(0) == "amgtr_acp23" then ui.dwriteTextWrapped("Mercedes-AMG GTR is not rental, times won't be posted on leaderboard.", 30, rgbm.colors.white) end
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
	if sector == nil then
		sector = sectors[1]
		sectorInfo.sectorIndex = 1
		resetSectors()
	end
	if distanceSquared(vec2(car.position.x, car.position.z), vec2(sector.lines[sectorInfo.checkpoints].midPoint.x, sector.lines[sectorInfo.checkpoints].midPoint.z)) < 30000 then sectorInfo.drawLine = true else sectorInfo.drawLine = false end
	if car.isInPit then resetSectors() end
	if hasCrossedLine(sector.lines[sectorInfo.checkpoints]) then
		if sectorInfo.checkpoints == 1 then
			resetSectors()
			sectorInfo.distance = car.distanceDrivenSessionKm
		end
		if sectorInfo.finished then
			if sectorInfo.finished and not sectorInfo.timePosted then
				if sectors[sectorInfo.sectorIndex].name == "H1" then updateSector('H1', sectorInfo.time)
				elseif sectors[sectorInfo.sectorIndex].name == "Velocity Vendetta" then updateSector('VV', sectorInfo.time) end
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
	elo = 1200,
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

-- Functions --

local function showRaceLights()
	local timing = os.clock() % 1
	if timing > 0.5 then
		ui.drawRectFilledMultiColor(vec2(0,0), vec2(windowWidth/10,windowHeight), SETTINGS.colorHud, rgbm(),  rgbm(), SETTINGS.colorHud)
		ui.drawRectFilledMultiColor(vec2(windowWidth-windowWidth/10,0), vec2(windowWidth,windowHeight),  rgbm(), SETTINGS.colorHud, SETTINGS.colorHud, rgbm())
	else
		ui.drawRectFilledMultiColor(vec2(0,0), vec2(windowWidth/10,windowHeight), rgbm(), rgbm(),  rgbm(), rgbm())
		ui.drawRectFilledMultiColor(vec2(windowWidth-windowWidth/10,0), vec2(windowWidth,windowHeight),  rgbm(), rgbm(), rgbm(), rgbm())
	end
end

local function hasWin(winner)
	raceFinish.winner = winner
	raceFinish.finished = true
	raceFinish.time = 10
	raceState.inRace = false
	if winner == car then
		eloRating(raceState.elo, 1)
		playerData.Wins = playerData.Wins + 1
		raceFinish.opponentName = ac.getDriverName(raceState.opponent.index)
		raceFinish.messageSent = false
	else
		eloRating(raceState.elo, 0)
		playerData.Losses = playerData.Losses + 1
	end
	updatefirebase()
	raceState.opponent = nil
end

local acpRace = ac.OnlineEvent({
	targetSessionID = ac.StructItem.int16(),
	messageType = ac.StructItem.int16(),
	eloRating = ac.StructItem.int16(),
}, function (sender, data)
	if data.targetSessionID == car.sessionID and data.messageType == 1 then
		raceState.opponent = sender
		horn.resquestTime = 7
		raceState.elo = data.eloRating
	elseif data.targetSessionID == car.sessionID and data.messageType == 2 then
		raceState.opponent = sender
		raceState.inRace = true
		resetHorn()
		horn.resquestTime = 0
		raceState.message = true
		raceState.time = 2
		timeStartRace = 7
		raceState.elo = data.eloRating
	elseif data.targetSessionID == car.sessionID and data.messageType == 3 then
		raceState.elo = data.eloRating
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
		acpRace{targetSessionID = raceState.opponent.sessionID, messageType = 3, eloRating = playerData.Elo}
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
			acpRace{targetSessionID = opponent.sessionID, messageType = 1, eloRating = playerData.Elo}
			horn.resquestTime = 10
		end
	end
end

local function acceptingRace()
	if dot(vec2(car.look.x, car.look.z), vec2(raceState.opponent.look.x, raceState.opponent.look.z)) > 0 then
		acpRace{targetSessionID = raceState.opponent.sessionID, messageType = 2, eloRating = playerData.Elo}
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

-- UI Update
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function flashingAlert(intensity)
	local timing = os.clock() % 1
	if timing > 0.5 then
		ui.drawRectFilledMultiColor(vec2(0,0), vec2(windowWidth/intensity,windowHeight), rgbm(1, 0, 0, 0.5), rgbm(),  rgbm(), rgbm(1, 0, 0, 0.5))
		ui.drawRectFilledMultiColor(vec2(windowWidth-windowWidth/intensity,0), vec2(windowWidth,windowHeight), rgbm(), rgbm(1, 0, 0, 0.5), rgbm(1, 0, 0, 0.5), rgbm())
	else
		ui.drawRectFilledMultiColor(vec2(0,0), vec2(windowWidth/intensity,windowHeight), rgbm(), rgbm(),  rgbm(), rgbm())
		ui.drawRectFilledMultiColor(vec2(windowWidth-windowWidth/intensity,0), vec2(windowWidth,windowHeight), rgbm(), rgbm(),  rgbm(), rgbm())
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
	ui.endRotation(90,vec2(SETTINGS.msgOffsetX - windowWidth/2 - textLenght.x/2,SETTINGS.msgOffsetY))
	ui.dwriteDrawText(text, 30, vec2(SETTINGS.msgOffsetX - textLenght.x/2 , SETTINGS.msgOffsetY), rgbm.colors.white)
end

local function raceUI()
	ui.pushDWriteFont("Orbitron;Weight=Black")
	local displayText = false
	local text
	local textLenght

	if timeStartRace > 0 then
		timeStartRace = timeStartRace - ui.deltaTime()
		if raceState.opponent and timeStartRace - 5 > 0 then
			text = "Align yourself with " .. ac.getDriverName(raceState.opponent.index) .. " to start the race!"
		else
			local number = math.floor(timeStartRace - 1)
			if number <= 0 then text = "GO!"
			else text = number .. " ..." end
		end
		displayText = true
		textLenght = ui.measureDWriteText(text, 30)
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
		end
	elseif horn.resquestTime > 0  and raceState.opponent then
		text = ac.getDriverName(raceState.opponent.index) .. " wants to challenge you to a race. To accept activate your horn twice quickly"
		displayText = true
	elseif horn.resquestTime > 0 and raceState.opponent == nil then
		text = "Waiting for " ..  horn.opponentName .. " to accept the challenge"
		displayText = true
	end
	if displayText then
		textLenght = ui.measureDWriteText(text, SETTINGS.fontSizeMSG)
		local rectPos1 = vec2(SETTINGS.msgOffsetX - textLenght.x/2, SETTINGS.msgOffsetY)
		local rectPos2 = vec2(SETTINGS.msgOffsetX + textLenght.x/2, SETTINGS.msgOffsetY + SETTINGS.fontSizeMSG)
		local rectOffset = vec2(10, 10)
		if ui.time() % 1 < 0.5 then
			ui.drawRectFilled(rectPos1 - vec2(10,0), rectPos2 + rectOffset, COLORSMSGBG, 10)
		else
			ui.drawRectFilled(rectPos1 - vec2(10,0), rectPos2 + rectOffset, rgbm(0,0,0,0.5), 10)
		end
		ui.dwriteDrawText(text, SETTINGS.fontSizeMSG, rectPos1, rgbm.colors.white)
	end
	ui.popDWriteFont()
end

--------------------------------------------------------------------------------------- Police Chase --------------------------------------------------------------------------------------------------

local online = {
	message = "",
	messageTimer = 0,
	type = nil,
}

local acpPolice = ac.OnlineEvent({
    message = ac.StructItem.string(110),
	messageType = ac.StructItem.int16(),
	yourIndex = ac.StructItem.int16(),
}, function (sender, data)
	online.type = data.messageType
	if data.yourIndex == car.sessionID and data.messageType == 0 then
		online.message = data.message
		online.messageTimer = SETTINGS.timeMsg
	elseif data.yourIndex == car.sessionID and data.messageType == 1 then
		online.message = data.message
		online.messageTimer = SETTINGS.timeMsg
	elseif data.yourIndex == car.sessionID and data.messageType == 2 then
		online.message = data.message
		online.messageTimer = SETTINGS.timeMsg
		playerData.Busted = playerData.Busted + 1
		updatefirebase()
	end
end)

local function showPoliceLights()
	local timing = os.clock() % 2
	if timing > 1.66 then
		ui.drawRectFilledMultiColor(vec2(0,0), vec2(windowWidth/6,windowHeight), rgbm(1, 0, 0, 0.5), rgbm(),  rgbm(), rgbm(1, 0, 0, 0.5))
		ui.drawRectFilledMultiColor(vec2(windowWidth-windowWidth/6,0), vec2(windowWidth,windowHeight),  rgbm(), rgbm(0, 0, 1, 0.5), rgbm(0, 0, 1, 0.5), rgbm())
	elseif timing > 1.33 then
		ui.drawRectFilledMultiColor(vec2(0,0), vec2(windowWidth/6,windowHeight), rgbm(0, 0, 1, 0.5), rgbm(), rgbm(), rgbm(0, 0, 1, 0.5))
		ui.drawRectFilledMultiColor(vec2(windowWidth-windowWidth/6,0), vec2(windowWidth,windowHeight),  rgbm(), rgbm(1, 0, 0, 0.5), rgbm(1, 0, 0, 0.5), rgbm())
	elseif timing > 1 then
		ui.drawRectFilledMultiColor(vec2(0,0), vec2(windowWidth/6,windowHeight), rgbm(1, 0, 0, 0.5), rgbm(),  rgbm(), rgbm(1, 0, 0, 0.5))
		ui.drawRectFilledMultiColor(vec2(windowWidth-windowWidth/6,0), vec2(windowWidth,windowHeight),  rgbm(), rgbm(0, 0, 1, 0.5), rgbm(0, 0, 1, 0.5), rgbm())
	elseif timing > 0.66 then
		ui.drawRectFilledMultiColor(vec2(0,0), vec2(windowWidth/6,windowHeight), rgbm(0, 0, 1, 0.5), rgbm(), rgbm(), rgbm(0, 0, 1, 0.5))
		ui.drawRectFilledMultiColor(vec2(windowWidth-windowWidth/6,0), vec2(windowWidth,windowHeight),  rgbm(), rgbm(1, 0, 0, 0.5), rgbm(1, 0, 0, 0.5), rgbm())
	elseif timing > 0.33 then
		ui.drawRectFilledMultiColor(vec2(0,0), vec2(windowWidth/6,windowHeight), rgbm(1, 0, 0, 0.5), rgbm(),  rgbm(), rgbm(1, 0, 0, 0.5))
		ui.drawRectFilledMultiColor(vec2(windowWidth-windowWidth/6,0), vec2(windowWidth,windowHeight),  rgbm(), rgbm(0, 0, 1, 0.5), rgbm(0, 0, 1, 0.5), rgbm())
	else
		ui.drawRectFilledMultiColor(vec2(0,0), vec2(windowWidth/6,windowHeight), rgbm(0, 0, 1, 0.5), rgbm(), rgbm(), rgbm(0, 0, 1, 0.5))
		ui.drawRectFilledMultiColor(vec2(windowWidth-windowWidth/6,0), vec2(windowWidth,windowHeight),  rgbm(), rgbm(1, 0, 0, 0.5), rgbm(1, 0, 0, 0.5), rgbm())
	end
end

local function onlineEventMessageUI()
	if online.messageTimer > 0 then
		online.messageTimer = online.messageTimer - ui.deltaTime()
		local text = string.gsub(online.message,"*", "⭐")
		local textLenght = ui.measureDWriteText(text, SETTINGS.fontSizeMSG)
		local rectPos1 = vec2(SETTINGS.msgOffsetX - textLenght.x/2, SETTINGS.msgOffsetY)
		local rectPos2 = vec2(SETTINGS.msgOffsetX + textLenght.x/2, SETTINGS.msgOffsetY + SETTINGS.fontSizeMSG)
		local rectOffset = vec2(10, 10)
		if ui.time() % 1 < 0.5 then
			ui.drawRectFilled(rectPos1 - vec2(10,0), rectPos2 + rectOffset, COLORSMSGBG, 10)
		else
			ui.drawRectFilled(rectPos1 - vec2(10,0), rectPos2 + rectOffset, rgbm(0,0,0,0.5), 10)
		end
		ui.dwriteDrawText(text, SETTINGS.fontSizeMSG, rectPos1, rgbm.colors.white)
		if online.type == 2 then
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
    local textSize = ui.measureDWriteText(statOn[SETTINGS.current], SETTINGS.statsFont)
    if SETTINGS.current < 4 then ui.dwriteDrawText(statOn[SETTINGS.current], SETTINGS.statsFont, textOffset - vec2(textSize.x/2, 0), SETTINGS.colorHud) end
    if SETTINGS.current == 1 then
        local drivenKm = car.distanceDrivenSessionKm
        if drivenKm < 0.01 then drivenKm = 0 end
        textSize = ui.measureDWriteText(string.format("%.2f",drivenKm) .. " km", SETTINGS.statsFont)
        ui.dwriteDrawText(string.format("%.2f",drivenKm) .. " km", SETTINGS.statsFont, textOffset - vec2(textSize.x/2, -imageSize.y/13), rgbm(1,1,1,1))
    elseif SETTINGS.current == 2 then
        textSize = ui.measureDWriteText(playerData.Wins .. "Win  -  Lost" .. playerData.Losses, SETTINGS.statsFont/1.1)
        ui.dwriteDrawText("Win " .. playerData.Wins .. " - Lost " .. playerData.Losses, SETTINGS.statsFont/1.1, textOffset - vec2(textSize.x/2, -imageSize.y/12.5), rgbm(1,1,1,1))
    elseif SETTINGS.current == 3 then
        textSize = ui.measureDWriteText(playerData.Busted, SETTINGS.statsFont)
        ui.dwriteDrawText(playerData.Busted, SETTINGS.statsFont, textOffset - vec2(textSize.x/2, -imageSize.y/13), rgbm(1,1,1,1))
    elseif SETTINGS.current > 3 then
        textSize = ui.measureDWriteText(sector.name, SETTINGS.statsFont)
        ui.dwriteDrawText(sector.name, SETTINGS.statsFont, textOffset - vec2(textSize.x/2, 0), SETTINGS.colorHud)
        textSize = ui.measureDWriteText("Time: 0:00:00", SETTINGS.statsFont)
        if sectorInfo.finished then
            ui.dwriteDrawText("Time: " .. sectorInfo.timerText, SETTINGS.statsFont, textOffset - vec2(textSize.x/2, -imageSize.y/13), rgbm(0, 1, 0, 1))
        else
            ui.dwriteDrawText("Time: " .. sectorInfo.timerText, SETTINGS.statsFont, textOffset - vec2(textSize.x/2, -imageSize.y/13), rgbm(1,1,1,1))
        end
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
	local uiStats = ac.getUI()
	if not ui.isImageReady(hudCenter) then loadImages() end

	ui.drawImage(hudCenter, vec2(0,0), imageSize)
	if ui.rectHovered(imgPos.leftPos2, imgPos.leftPos1) then
		ui.image(hudLeft, imageSize, SETTINGS.colorHud)
		if uiStats.isMouseLeftKeyClicked then
			if SETTINGS.current == 1 then SETTINGS.current = #statOn else SETTINGS.current = SETTINGS.current - 1 end
		end
	elseif ui.rectHovered(imgPos.rightPos2, imgPos.rightPos1) then
		ui.image(hudRight, imageSize, SETTINGS.colorHud)
		if uiStats.isMouseLeftKeyClicked then
			if SETTINGS.current == #statOn then SETTINGS.current = 1 else SETTINGS.current = SETTINGS.current + 1 end
		end
	elseif ui.rectHovered(imgPos.theftPos2, imgPos.theftPos1) then
		iconsColorOn[1] = SETTINGS.colorHud
		if uiStats.isMouseLeftKeyClicked then
			if stealingTime == 0 then
				stealingTime = 30
				ac.sendChatMessage("* Stealing a " .. string.gsub(ac.getCarName(0), "%W", " ") .. os.date(" %x *"))
				stealMsgTime = 7
				if sectorInfo.sectorIndex ~= 3 and sectorInfo.timerText == "00:00.00" then
					sectorInfo.sectorIndex = 2
                    sector = sectors[sectorInfo.sectorIndex]
                    resetSectors()
					SETTINGS.current = 4
				end
			end
		end
	elseif ui.rectHovered(imgPos.ranksPos2, imgPos.ranksPos1) then
		iconsColorOn[2] = SETTINGS.colorHud
		if uiStats.isMouseLeftKeyClicked then
			if leaderboardOpen then leaderboardOpen = false
			else
				if menuOpen then menuOpen = false end
				leaderboardOpen = true
				loadLeaderboardFromSheet()
			end
		end
	elseif ui.rectHovered(imgPos.countdownPos2, imgPos.countdownPos1) then
		iconsColorOn[3] = SETTINGS.colorHud
		if not countDownState.countdownOn and uiStats.isMouseLeftKeyClicked then
			if cooldownTime == 0 then
				countdownTime = 5
				cooldownTime = 30
				countDownState.countdownOn = true
				countDownState.ready = true
				countDownState.set = true
				countDownState.go = true
			end
			SETTINGS.current = 2
		end
	elseif ui.rectHovered(imgPos.menuPos2, imgPos.menuPos1) then
		iconsColorOn[4] = SETTINGS.colorHud
		if uiStats.isMouseLeftKeyClicked then
			if menuOpen then menuOpen = false
			else
				if leaderboardOpen then leaderboardOpen = false end
				menuOpen = true
			end
		end
	end
	ui.image(hudBase, imageSize, SETTINGS.colorHud)
	ui.drawImage(hudTheft, vec2(0,0), imageSize, iconsColorOn[1])
	ui.drawImage(hudRanks, vec2(0,0), imageSize, iconsColorOn[2])
	ui.drawImage(hudCountdown, vec2(0,0), imageSize, iconsColorOn[3])
	ui.drawImage(hudMenu, vec2(0,0), imageSize, iconsColorOn[4])
	if countDownState.countdownOn then countdown() end
	if stealingTime > 0 then stealingTime = stealingTime - ui.deltaTime()
	elseif stealingTime < 0 then stealingTime = 0 end
end

local function showMsgSteal()
	local text = "You have successfully stolen the " ..  string.gsub(string.gsub(ac.getCarName(0), "%W", " "), "  ", "") .. "! Hurry to the scrapyard!"
	local textLenght = ui.measureDWriteText(text, SETTINGS.fontSizeMSG)
	local rectPos1 = vec2(SETTINGS.msgOffsetX - textLenght.x/2, SETTINGS.msgOffsetY)
	local rectPos2 = vec2(SETTINGS.msgOffsetX + textLenght.x/2, SETTINGS.msgOffsetY + SETTINGS.fontSizeMSG)
	local rectOffset = vec2(10, 10)
	if ui.time() % 1 < 0.5 then
		ui.drawRectFilled(rectPos1 - vec2(10,0), rectPos2 + rectOffset, COLORSMSGBG, 10)
	else
		ui.drawRectFilled(rectPos1 - vec2(10,0), rectPos2 + rectOffset, rgbm(0,0,0,0.5), 10)
	end
	ui.dwriteDrawText(text, SETTINGS.fontSizeMSG, rectPos1, rgbm.colors.white)
end

local function hudUI()
	if stealMsgTime > 0 then
		showMsgSteal()
		stealMsgTime = stealMsgTime - ui.deltaTime()
	elseif stealMsgTime < 0 then stealMsgTime = 0 end
	if SETTINGS.showStats then
		ui.beginTransparentWindow("Stats", vec2(SETTINGS.statsOffsetX, SETTINGS.statsOffsetY), imageSize, true)
		drawImage()
		drawText()
		ui.endTransparentWindow()
	end
end

-------------------------------------------------------------------------------------------- Menu --------------------------------------------------------------------------------------------

local function infoRace()
	ui.sameLine(10)
	ui.beginGroup()
	ui.dwriteTextWrapped('\nIllegal street racing', 20, rgbm.colors.white)
    ui.dwriteTextWrapped("Illegal street racing in a one-on-one format is surprisingly simple. Here's how it works:" ..
    "\n\n- The race initiator honks their horn twice to indicate the desire to race." ..
    "\n- The potential opponent responds with two horn honks to accept the invitation." ..
    "\n- The race takes place between the two participants, the app will inform both with a status bar showing the distance from the opponent" ..
    "\n\n- Optionally, If both participants agree, they can decide on a bet amount before the race." ..
    "\n- After the race, the loser is responsible for settling their financial obligations." ..
    "\n- The unsuccessful participant can use the '/pay' command in the dedicated STREET-RACING Discord channel to settle the bet." ..
    "\n\nPlease be aware that illegal street racing is against the law and extremely dangerous.")
    if ui.textHyperlink("Discord STREET-RACING") then
        os.openURL("https://discord.com/channels/358562025032646659/1082294944162660454")
    end
	ui.endGroup()
end

local function infoServer()
	ui.sameLine(10)
	ui.beginGroup()
    ui.dwriteTextWrapped('\nWelcome to ACP', 20, rgbm.colors.white)
	ui.dwriteTextWrapped('ACP is a persistent Assetto Corsa server that allows you to forge your virtual street racer life with every passing day.\nUnlike servers that periodically reset, ACP ensures that your progress remains untouched, empowering you to continuously accumulate and enhance your achievements without any interruptions.\nPrepare for a truly immersive and enduring gaming experience as your street racing journey unfolds, maintaining its integrity throughout.' ..
    '\n\nWhat sets ACP apart is the integration of a unique "POINTS SYSTEM" in conjunction with your driving experience.\nEarned Points serve as a valuable currency, mirroring the real-life racing world.\nUtilize these Points to purchase cars and customize them to your liking, enabling you to tailor your virtual garage to perfection.' ..
    "\n\nBut that's not all! For the daring and fearless racers, ACP presents the opportunity to wager your hard-earned Points during exhilarating illegal races. Take risks, push your limits, and embrace the thrill of high-stakes competitions." ..
    "\n\nJoin us on ACP and embark on a racing adventure where every race, every achievement, and every bet contribute to your ever-evolving street racing legacy!")
    ui.newLine()
    if ui.textHyperlink("ACP Discord") then
        os.openURL("https://discord.gg/acpursuit")
    end
	ui.endGroup()
end

local function download()
	ui.dwriteTextWrapped("Download the latest version of ACP Pursuit.", 30, rgbm.colors.white)
	if ui.textHyperlink("ACP Patreon") then
        os.openURL("https://www.patreon.com/posts/acp-download-51908849")
    end
end

local function info()
	ui.tabBar('InfoTabBar', ui.TabBarFlags.Reorderable, function ()
		ui.tabItem('Illegal street racing', function () infoRace() end)
		ui.tabItem('General Server Info', function () infoServer() end)
	end)
	return 3
end

local initialized = false
local menuSize = {vec2(windowWidth/5, windowHeight/4), vec2(windowWidth/6, windowHeight*1.8/3), vec2(windowWidth/3, windowHeight/3)}
local currentTab = 1
local buttonPressed = false

local function menu()
	if not settingsLoaded then download()
	else
		ui.tabBar('MainTabBar', ui.TabBarFlags.Reorderable, function ()
			ui.tabItem('Sectors', function () currentTab = sectorUI() end)
			ui.tabItem('Settings', function () currentTab = settings() end)
			ui.tabItem('Info', function () currentTab = info() end)
		end)
	end
end

local function moveMenu()
	if ui.windowHovered() and ui.mouseDown() then buttonPressed = true end
	if ui.mouseReleased() then buttonPressed = false end
	if buttonPressed then SETTINGS.menuPos = SETTINGS.menuPos + ui.mouseDelta() end
end

local function leaderboardWindow()
	ui.toolWindow('LeaderboardWindow', SETTINGS.menuPos, vec2(windowWidth/3, windowHeight/3), true, function ()
		ui.childWindow('childLeaderboard', vec2(windowWidth/3, windowHeight/3), true, function ()
			showLeaderboard()
			moveMenu()
		end)
	end)
end

-------------------------------------------------------------------------------------------- Main script --------------------------------------------------------------------------------------------

function script.drawUI()
	if settingsLoaded and initialized then
		hudUI()
		onlineEventMessageUI()
		raceUI()
		if menuOpen then
			ui.toolWindow('Menu', SETTINGS.menuPos, menuSize[currentTab], true, function ()
				ui.childWindow('childMenu', menuSize[currentTab], true, function ()
					menu()
					moveMenu()
				end)
			end)
		end
		if leaderboardOpen then leaderboardWindow() end
	end
end

function script.update(dt)
	if not initialized then
		if ac.getCarID(0) == valideCar[1] or ac.getCarID(0) == valideCar[2] then return end
		initLines()
		initialized = true
		if settingsLoaded then
			getFirebase()
		end
		loadLeaderboardFromSheet()
	else
		if settingsLoaded then
			sectorUpdate()
			raceUpdate(dt)
			sharedDataSettings = SETTINGS
		end
	end
end

function script.draw3D()
	if settingsLoaded and initialized and SETTINGS.current == 4 then
		local lineToRender = sector.pointsData[sectorInfo.checkpoints]
		if sectorInfo.drawLine then render.debugLine(lineToRender[1], lineToRender[2], rgbm(0,100,0,1)) end
	end
end

if ac.getCarID(0) ~= valideCar[1] and ac.getCarID(0) ~= valideCar[2] then
	ui.registerOnlineExtra("Menu", "Menu", nil, function () menu() end, nil, 0, 0, 0)
end

if not settingsLoaded then
	ui.registerOnlineExtra("Download", "Download", nil, function () download() end, nil, 0, 0, 0)
end
