local sim = ac.getSim()
local car = ac.getCar(0)
local carInFrontVisible = false
local windowWidth = sim.windowWidth
local windowHeight = sim.windowHeight

local horn = {
	lastState = false,
	stateChangedCount = 0,
	time = 0,
}

local isInRace = false
local raceOpponent = nil
local acceptedOpponent = false
local resquestOpponent = false
local inFront = nil
local distanceBetweenPlayers = 0

local resquestTime = 0
local messageTime = 0

local raceFinish = {
	winner = nil,
	finished = false,
	timeFinish = 0,
}

local function newtonSqrt(n, tolerance)
    local guess = n / 2

    repeat
        local nextGuess = (guess + n / guess) / 2
        local diff = math.abs(guess - nextGuess)
        guess = nextGuess
    until diff <= tolerance
    return guess
end

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
	local length = newtonSqrt(vector.x^2 + vector.y^2, 0.01)
	return vec2(vector.x/length, vector.y/length)
end

local function dot(vector1, vector2)
	return vector1.x * vector2.x + vector1.y * vector2.y
end

local function hasWin(winner)
	raceFinish.winner = winner
	raceFinish.finished = true
	raceFinish.timeFinish = 10
	raceOpponent = nil
	isInRace = false
end

local function whosInFront()
	local direction = cross(vec2(car.velocity.x, car.velocity.z), vec2(raceOpponent.velocity.x, raceOpponent.velocity.z))
	local midBetweenPlayers = vec2((car.position.x + raceOpponent.position.x)/2, (car.position.z + raceOpponent.position.z)/2)
	local midPlusDirection = vec2(midBetweenPlayers.x + direction.x, midBetweenPlayers.y + direction.y)
	local youDistanceSquared = distanceSquared(vec2(car.position.x, car.position.z), midPlusDirection)
	local opponentDistanceSquared = distanceSquared(vec2(raceOpponent.position.x, raceOpponent.position.z), midPlusDirection)
	if youDistanceSquared < opponentDistanceSquared then
		inFront = car
	else
		inFront = raceOpponent
	end
end

local function acceptedRace()
	messageTime = 0
	if dot(vec2(car.look.x, car.look.z), vec2(raceOpponent.look.x, raceOpponent.look.z)) > 0 then
		whosInFront()
		isInRace = true
	else
		isInRace = false
		raceOpponent = nil
	end
	acceptedOpponent = false
end

local function resquestRace()
	if car.hazardActive then
		acceptedOpponent = true
		resquestOpponent = false
		AcpRace{targetSessionID = raceOpponent.sessionID, messageType = 2}
	end
end

local function hasPit()
	if not raceOpponent or raceOpponent and not raceOpponent.isConnected then
		hasWin(car)
		return true
	end
	if car.isInPit then
		AcpRace{targetSessionID = raceOpponent.sessionID, messageType = 3}
		hasWin(raceOpponent)
		return true
	end
	return false
end

local function challengeOpponent(dt)
	if horn.time < 4 and raceOpponent == nil then
		horn.time = horn.time + dt
		if horn.lastState ~= car.hornActive then
			horn.stateChangedCount = horn.stateChangedCount + 1
			horn.lastState = car.hornActive
		end
		if horn.stateChangedCount > 3 then
			local opponentIndex = ac.getCarIndexInFront(0)
			if opponentIndex > 0 then
				AcpRace{targetSessionID = ac.getCar(opponentIndex).sessionID, messageType = 1}
			end
			horn.stateChangedCount = 0
			horn.time = 0
		end
	else
		horn.stateChangedCount = 0
		horn.time = 0
	end
end

local function inRace()
	distanceBetweenPlayers = distance(vec2(car.position.x, car.position.z), vec2(raceOpponent.position.x, raceOpponent.position.z))
	if distanceBetweenPlayers < 50 then whosInFront()
	elseif distanceBetweenPlayers > 500 then
		hasWin(inFront)
	end
end

AcpRace = ac.OnlineEvent({
	targetSessionID = ac.StructItem.int16(),
	messageType = ac.StructItem.int16(),
}, function (sender, data)
	if data.targetSessionID == ac.getCar(0).sessionID and data.messageType == 1 then
		raceOpponent = sender
		resquestOpponent = true
		messageTime = 5
	elseif data.targetSessionID == ac.getCar(0).sessionID and data.messageType == 2 then
		raceOpponent = sender
		acceptedOpponent = true
		messageTime = 0
	elseif data.targetSessionID == ac.getCar(0).sessionID and data.messageType == 3 then
		hasWin(car)
	end
end)

function script.update(dt)
	if isInRace and hasPit() then
		inRace()
	else
		if raceOpponent then
			if resquestOpponent then
				resquestRace()
			elseif acceptedOpponent then
				acceptedRace()
			end
			resquestTime = resquestTime + dt
		elseif resquestTime > 10 then
			resquestTime = 0
			raceOpponent = nil
			resquestOpponent = false
		end
		challengeOpponent(dt)
		if raceFinish.finished then
			raceFinish.timeFinish = raceFinish.timeFinish - dt
			if raceFinish.timeFinish < 0 then
				raceFinish.finished = false
				raceFinish.winner = nil
			end
		end
	end
end

function script.fullscreenUI()
	ui.pushDWriteFont("Orbitron;Weight=600")
	if isInRace then
		if isInRace then
			ui.dummy(vec2(windowWidth/4,windowHeight/40))
			ui.sameLine()
			ui.progressBar(distanceBetweenPlayers/500, vec2(windowWidth/2,windowHeight/40), ac.getDriverName(inFront.index) .. ' is ' .. distanceBetweenPlayers .. ' meters ahead')
		end
	elseif raceFinish.finished then
		local text = ac.getDriverName(raceFinish.winner.index) .. " has won the race"
		local textLenght = ui.measureDWriteText(text, 30)
		ui.dwriteDrawText(text, 30, vec2(windowWidth/2 - textLenght.x/2, windowHeight/80), rgbm.colors.red)
	elseif messageTime > 0 then
		messageTime = messageTime - ui.deltaTime()
		local text = ac.getDriverName(raceOpponent.index) .. " wants to challenge you to a race"
		local textLenght = ui.measureDWriteText(text, 30)
		ui.dwriteDrawText(text, 30, vec2(windowWidth/2 - textLenght.x/2, windowHeight/80), rgbm.colors.red)
	end
	if carInFrontVisible then
		local carInFrontIndex = ac.getCarIndexInFront(0)
		if carInFrontIndex > 0 then
			ui.dwriteTextWrapped("Car in front: " .. ac.getDriverName(carInFrontIndex), 15, rgbm.colors.white)
		end
	end
	ui.popDWriteFont()
end

local function main()
	if ui.checkbox('Car in front on screen', carInFrontVisible) then carInFrontVisible = not carInFrontVisible end
	local you = ac.getCar(0)
	local players = {}
	local playerName = 'online player'
	for i = ac.getSim().carsCount - 1, 0, -1 do
		local player = ac.getCar(i)
		if player.isConnected and (not player.isHidingLabels) then
			if player.index ~= you.index then
				table.insert(players, player)
			end
		end
	end
	local teamate = nil
	if #players == 0 then
		ui.newLine()
		ui.dwriteTextWrapped("There is no other players connected", 15, rgbm.colors.white)
		ui.dwriteTextWrapped("You can't steal a car", 15, rgbm.colors.white)
	else
		ui.combo("Teamate", playerName, function ()
			for i = 1, #players do
				if ui.selectable(ac.getDriverName(players[i].index), teamate == players[i].index) then
					playerName = ac.getDriverName(players[i].index)
				end
			end
		end)
	end
end

ui.registerOnlineExtra(ui.Icons.FastForward, 'Teleport somebody', nil, main, nil, ui.OnlineExtraFlags.Tool)
--ui.registerOnlineExtra(iconID: string, title: string, availableCallback: integer, uiCallback: integer, closeCallback: integer, flags: ui.OnlineExtraFlags, toolFlags: ui.WindowFlags = ImGuiWindowFlags_None, toolSize: vec2 = vec2(320, 400)): lua_linked_id
