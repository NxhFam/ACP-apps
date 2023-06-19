local serverIp = "95.211.222.135"
local sim = ac.getSim()
local car = ac.getCar(0)
local windowWidth = sim.windowWidth
local windowHeight = sim.windowHeight
SETTINGS.statsFont = SETTINGS.statsSize * windowHeight/1440
ui.setAsynchronousImagesLoading(true)

---------------------TO DO---------------------
local hudBase = "assets/Hud/hudBase.png"
local hudLeft = "assets/Hud/hudLeft.png"
local hudRight = "assets/Hud/hudRight.png"
local hudCenter = "assets/Hud/hudCenter.png"
local hudCountdown = "assets/Hud/iconCountdown.png"
local hudMenu = "assets/Hud/iconMenu.png"
local hudTheft = "assets/Hud/iconTheft.png"
---------------------TO DO---------------------

local sectors = {
    {
        name = 'H1',
        linesData = {vec4(-742.9, 3558.7, -729.8, 3542.8), vec4(3008.2, 1040.3, 2998.8, 1017.3)},
        length = 26.3,
    },
    {
        name = 'BOBs SCRAPYARD',
        linesData = {vec4(-742.9, 3558.7, -729.8, 3542.8), vec4(-3537.4, -199.8, -3544.4, -212.2)},
        length = 6.35,
    },
    {
        name = 'DOUBLE TROUBLE',
        linesData = {vec4(-742.9, 3558.7, -729.8, 3542.8), vec4(-3537.4, -199.8, -3544.4, -212.2)},
        length = 6.35,
    },
    {
        name = 'Velocity Vendetta',
        linesData = {vec4(579.4, -748.6, 590.7, -763.8), vec4(-179, 1424.0, -178, 1338.2), vec4(1185, 2509.5, 1178, 2518.8), vec4(460.9, 2426.8, 451.1, 2433.5)},
        length = 9.1,
    }
}

local sector = nil

-- Init
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

local function initLines()
	for i = 1, #sectors do
		local lines = {}
		for j = 1, #sectors[i].linesData do
            local line = {}
            line.p1 = vec2(sectors[i].linesData[j].x, sectors[i].linesData[j].y)
            line.p2 = vec2(sectors[i].linesData[j].z, sectors[i].linesData[j].w)
            line.dir = normalize(line.p2 - line.p1)
            line.region = regionAroundLine(line)
            table.insert(lines, line)
        end
	end
    sector = sectors[1]
end

-- Settings
local showPreviewMsg = false
local showPreviewDistanceBar = false
COLORSMSGBG = rgbm(0.5,0.5,0.5,0.5)

SETTINGS = ac.storage {
	showStats = true,
    racesWon = 0,
    racesLost = 0,
    busted = 0,
    statsSize = 20,
    statsOffsetX = 0,
	statsOffsetY = 0,
    statsFont = 20,
    current = 1,
    colorHud = rgbm(0,1,1,1),
	colorString = '0,1,1,1',
	send = false,
	timeMsg = 10,
	msgOffsetY = 10,
	msgOffsetX = windowWidth/2,
	fontSizeMSG = 30,
}

local function stringToColor(sColor)
	local r, g, b, a = sColor:match('(.+),(.+),(.+),(.+)')
	return rgbm(tonumber(r), tonumber(g), tonumber(b), tonumber(a))
end

SETTINGS.colorHud = stringToColor(SETTINGS.colorString)

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
	ui.pushDWriteFont("Orbitron;Weight=800")
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
    if ui.button('Preview Message') then
        showPreviewMsg = not showPreviewMsg
        if showPreviewMsg then showPreviewDistanceBar = false end
    end
    ui.sameLine()
    if ui.button('Preview Distance Bar') then
        showPreviewDistanceBar = not showPreviewDistanceBar
        if showPreviewDistanceBar then showPreviewMsg = false end
    end
    if showPreviewMsg then previewMSG() end
    if showPreviewDistanceBar then distanceBarPreview() end
	if ui.button('Offset X to center') then SETTINGS.msgOffsetX = windowWidth/2 end
	ui.newLine()
end


local function uiHUD()
	if ui.checkbox('Show HUD', SETTINGS.showStats) then SETTINGS.showStats = not SETTINGS.showStats end
	SETTINGS.statsOffsetX = ui.slider('##' .. 'HUD Offset X', SETTINGS.statsOffsetX, 0, windowWidth, 'HUD Offset X' .. ': %.0f')
	SETTINGS.statsOffsetY = ui.slider('##' .. 'HUD Offset Y', SETTINGS.statsOffsetY, 0, windowHeight, 'HUD Offset Y' .. ': %.0f')
	SETTINGS.statsSize = ui.slider('##' .. 'HUD Size', SETTINGS.statsSize, 10, 50, 'HUD Size' .. ': %.0f')
	local fontMultiplier = windowHeight/1440
	SETTINGS.statsFont = SETTINGS.statsSize * fontMultiplier
    ui.setNextItemWidth(300)
	local colorHud = SETTINGS.colorHud
    ui.colorPicker('Theme Color', colorHud, ui.ColorPickerFlags.AlphaBar)

	SETTINGS.colorString = colorHud.r .. ',' .. colorHud.g .. ',' .. colorHud.b .. ',' .. colorHud.mult
	ui.newLine()
	if ui.button('reset colors') then SETTINGS.colorString = '0,1,1,1' end
	SETTINGS.colorHud = stringToColor(SETTINGS.colorString)
    ui.newLine()
    uiTab()
end

-- Sectors
local sectorInfo = {
	time = 0,
	timerText = 'H1|TIME: 00:00.00|0',
	finalTime = 'H1|TIME: 00:00.00|0',
	checkpoints = 1,
	sectorIndex = 1,
	distance = 0,
	finished = false,
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
	sectorInfo.timerText = sector.name .. '|TIME: 00:00.00|0'
	sectorInfo.finalTime = sector.name .. '|TIME: 00:00.00|0'
	sectorInfo.checkpoints = 1
	sectorInfo.distance = 0
end

local function dot(vector1, vector2)
	return vector1.x * vector2.x + vector1.y * vector2.y
end

---------------------------------------------------------------------------------------------------------------------------

local acpEvent = ac.OnlineEvent({
    message = ac.StructItem.string(110),
	messageType = ac.StructItem.int16(),
	yourIndex = ac.StructItem.int16(),
}, function (sender, data)
	if data.yourIndex == car.sessionID and data.messageType == 5 and data.message == "duo.Request" then
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
			ui.combo("duo.Teammate", duo.playerName, function ()
				for i = 1, #players do
					if ui.selectable(ac.getDriverName(players[i].index), duo.teammate == players[i].index) then
						acpEvent{message = "duo.Request", messageType = 5, yourIndex = ac.getCar(players[i].index).sessionID}
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
			ui.dwriteTextWrapped("duo.teammate : ", 15, rgbm.colors.white)
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
	ui.combo("Sector", sector.name, function ()
		for i = 1, #sectors do
			if ui.selectable(sectors[i].name, sector == sectors[i]) then
				sector = sectors[i]
				sectorInfo.sectorIndex = i
				resetSectors()
			end
		end
	end)
end

local function sectorUI()
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
	if #sector.lines + 1 == sectorInfo.checkpoints then
		sectorInfo.timerText = sector.name .. '|TIME: ' .. timeFormated .. '|1'
	else
		sectorInfo.timerText = sectors[sectorInfo.sectorIndex].name .. '|TIME: ' .. timeFormated .. '|0'
	end
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
	if car.isInPit then resetSectors() end
	if hasCrossedLine(sector.lines[sectorInfo.checkpoints]) then
		if sectorInfo.checkpoints == 1 then
			resetSectors()
			sectorInfo.distance = car.sectorInfo.distanceDrivenSessionKm
		end
		sectorInfo.checkpoints = sectorInfo.checkpoints + 1
	end
	if sectorInfo.checkpoints > 1 then textTimeFormat() end
	if sectorInfo.checkpoints - 1 == #sector.lines then
		if sector.length < car.sectorInfo.distanceDrivenSessionKm - sectorInfo.distance then
			if sectorInfo.sectorIndex == 3 then
				if duo.teammate ~= nil and not sectorInfo.finished then
					acpEvent{message = "Finished", messageType = 5, yourIndex = ac.getCar(duo.teammate.index).sessionID}
				end
				if duo.teammateHasFinished then sectorInfo.finished = true end
			else
				sectorInfo.finished = true
			end
			if sectorInfo.finished then sectorInfo.finalTime = sectorInfo.timerText end
		end
	end
end

-- Online Interactions
-- Races Opponents
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

local function hasWin(winner)
	raceFinish.winner = winner
	raceFinish.finished = true
	raceFinish.time = 10
	raceState.inRace = false
	if winner == car then
		SETTINGS.racesWon = SETTINGS.racesWon + 1
		raceFinish.opponentName = ac.getDriverName(raceState.opponent.index)
		raceFinish.messageSent = false
	else SETTINGS.racesLost = SETTINGS.racesLost + 1 end
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
			ac.sendChatMessage(ac.getDriverName(0) .. " has started an illegal race against " .. ac.getDriverName(raceState.opponent.index) .. "!")
			raceState.message = false
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
	ui.pushDWriteFont("Orbitron;Weight=800")
	local displayText = false
	local text
	local textLenght

	if timeStartRace > 0 then
		timeStartRace = timeStartRace - ui.deltaTime()
		text = "Align yourself with " .. ac.getDriverName(raceState.opponent.index) .. " to start the race!"
		displayText = true
		textLenght = ui.measureDWriteText(text, 30)
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
			ac.sendChatMessage(ac.getDriverName(0) .. " has just beaten " .. raceFinish.opponentName .. string.format(" in an illegal race. [Win rate: %d",SETTINGS.racesWon * 100 / (SETTINGS.racesWon + SETTINGS.racesLost)) .. "%]")
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

-- Police Chase
local online = {
	message = "",
	messageTimer = 0,
	sender = nil,
	type = nil,
	confirmed = false,
	chased = false,
	police = nil,
}

local acpPolice = ac.OnlineEvent({
    message = ac.StructItem.string(110),
	messageType = ac.StructItem.int16(),
	yourIndex = ac.StructItem.int16(),
}, function (sender, data)
	online.sender = sender
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
		SETTINGS.busted = SETTINGS.busted + 1
	elseif data.yourIndex == car.sessionID and data.messageType == 5 and data.message == "Confirm" then
		online.confirmed = true
		online.chased = true
		online.police = sender
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

local function onlineEventMessage()
	if online.confirmed then
		acpPolice{message = "Confirmed", messageType = 5, yourIndex = car.sessionID}
		online.confirmed = false
	end
	if online.messageTimer > 0 then
		online.messageTimer = online.messageTimer - ui.deltaTime()
		if online.type == 2 then
			showPoliceLights()
			online.chased = false
			online.police = nil
		else
			online.message = string.gsub(online.message,"*", "⭐")
			local textSize = ui.measureDWriteText(online.message, SETTINGS.fontSizeMSG)
			local uiOffsetX = math.floor((windowWidth - textSize.x)/2)
			local uiOffsetY = SETTINGS.msgOffsetY
			ui.drawRectFilled(vec2(uiOffsetX - 5, uiOffsetY-5), vec2(uiOffsetX + textSize.x + 5, uiOffsetY + textSize.y + 5), COLORSMSGBG)
			ui.dwriteDrawText(online.message, SETTINGS.fontSizeMSG, vec2(uiOffsetX, uiOffsetY), SETTINGS.colorHud)
		end
	elseif online.messageTimer < 0 then
		online.message = ""
		online.messageTimer = 0
	end
end

-- HUD
local imageSize = vec2(windowHeight/80 * SETTINGS.statsSize, windowHeight/80 * SETTINGS.statsSize)
local timeFormated = sectorInfo.timeFormated
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
        textSize = ui.measureDWriteText(SETTINGS.racesWon .. "Win  -  Lost" .. SETTINGS.racesLost, SETTINGS.statsFont/1.1)
        ui.dwriteDrawText("Win " .. SETTINGS.racesWon .. " - Lost " .. SETTINGS.racesLost, SETTINGS.statsFont/1.1, textOffset - vec2(textSize.x/2, -imageSize.y/12.5), rgbm(1,1,1,1))
    elseif SETTINGS.current == 3 then
        textSize = ui.measureDWriteText(SETTINGS.busted, SETTINGS.statsFont)
        ui.dwriteDrawText(SETTINGS.busted, SETTINGS.statsFont, textOffset - vec2(textSize.x/2, -imageSize.y/13), rgbm(1,1,1,1))
    elseif SETTINGS.current > 3 then
        local timeSplit = string.split(timeFormated, "|")
        textSize = ui.measureDWriteText(timeSplit[1], SETTINGS.statsFont)
        ui.dwriteDrawText(timeSplit[1], SETTINGS.statsFont, textOffset - vec2(textSize.x/2, 0), SETTINGS.colorHud)
        textSize = ui.measureDWriteText("Time: 0:00:00", SETTINGS.statsFont)
        if timeSplit[3] == "0" then
            ui.dwriteDrawText(timeSplit[2], SETTINGS.statsFont, textOffset - vec2(textSize.x/2, -imageSize.y/13), rgbm(1,1,1,1))
        else
            ui.dwriteDrawText(timeSplit[2], SETTINGS.statsFont, textOffset - vec2(textSize.x/2, -imageSize.y/13), rgbm(0, 1, 0, 1))
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
	local uiStats = ac.getUI()
	local theftPos1 = vec2(imageSize.x - imageSize.x/1.7, imageSize.y/1.9)
	local theftPos2 = vec2(imageSize.x/3.6, imageSize.y/2.6)
	local menuPos1 = vec2(imageSize.x/1.75, imageSize.y/1.9)
	local menuPos2 = vec2(imageSize.x - imageSize.x/1.75, imageSize.y/2.6)
	local countdownPos1 = vec2(imageSize.x - imageSize.x/3.6, imageSize.y/1.9)
	local countdownPos2 = vec2(imageSize.x/1.7, imageSize.y/2.6)
	local leftPos1 = vec2(imageSize.x/8, imageSize.y/2.8)
	local leftPos2 = vec2(0, imageSize.y/4.3)
	local rightPos1 = vec2(imageSize.x, imageSize.y/2.8)
	local rightPos2 = vec2(imageSize.x - imageSize.x/8, imageSize.y/4.3)

	ui.drawImage(hudCenter, vec2(0,0), imageSize)
	if ui.rectHovered(leftPos2, leftPos1) then
		ui.image(hudLeft, imageSize, SETTINGS.colorHud)
		if uiStats.isMouseLeftKeyClicked then
			if SETTINGS.current == 1 then SETTINGS.current = #statOn else SETTINGS.current = SETTINGS.current - 1 end
		end
	elseif ui.rectHovered(rightPos2, rightPos1) then
		ui.image(hudRight, imageSize, SETTINGS.colorHud)
		if uiStats.isMouseLeftKeyClicked then
			if SETTINGS.current == #statOn then SETTINGS.current = 1 else SETTINGS.current = SETTINGS.current + 1 end
		end
	elseif ui.rectHovered(theftPos2, theftPos1) then
		iconsColorOn[1] = SETTINGS.colorHud
		if uiStats.isMouseLeftKeyClicked then
			if stealingTime == 0 then
				stealingTime = 30
				ac.sendChatMessage("* Stealing a " .. string.gsub(ac.getCarName(0), "%W", " ") .. os.date(" %x *"))
				stealMsgTime = 7
				if sectorInfo.sectorIndex ~= 3 and string.split(timeFormated, "|")[2] == "TIME: 00:00.00" then
					sectorInfo.sectorIndex = 2
                    sector = sectors[sectorInfo.sectorIndex]
                    resetSectors()
					SETTINGS.current = 4
				end
			end
		end
	elseif ui.rectHovered(menuPos2, menuPos1) then
		iconsColorOn[2] = SETTINGS.colorHud
		if uiStats.isMouseLeftKeyClicked then
			if ac.isWindowOpen('Settings') then ac.setWindowOpen('Settings', false)
			else ac.setWindowOpen('Settings', true) end
		end
	elseif ui.rectHovered(countdownPos2, countdownPos1) then
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
	end
	ui.image(hudBase, imageSize, SETTINGS.colorHud)
	ui.drawImage(hudTheft, vec2(0,0), imageSize, iconsColorOn[1])
	ui.drawImage(hudMenu, vec2(0,0), imageSize, iconsColorOn[2])
	ui.drawImage(hudCountdown, vec2(0,0), imageSize, iconsColorOn[3])
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

local initialized = false
-- Main script
function script.drawUI()
	if serverIp == ac.getServerIP() then
		hudUI()
		onlineEventMessage()
		raceUI()
	end
end

function script.update(dt)
    if not initialized then
        initialized = true
        initLines()
    else
        sectorUpdate()
        raceUpdate(dt)
    end
end

ui.registerOnlineExtra(ui.Icons.Settings, 'Sectors', nil, sectorUI, nil, ui.OnlineExtraFlags.Tool)
ui.registerOnlineExtra(ui.Icons.Settings, 'Settings', nil, uiHUD, nil, ui.OnlineExtraFlags.Tool)
