local sim = ac.getSim()
local car = ac.getCar(0)
local windowWidth = sim.windowWidth
local windowHeight = sim.windowHeight/4

local headlight = {
	lastState = false,
	stateChangedCount = 0,
}
local lightTime = 0

local isInRace = false
local raceOpponent = nil
local acceptedOpponent = false
local resquestOpponent = false
local inFront = nil
local distanceBetweenPlayers = 0

local resquestTime = 0
local messageTime = 0

local onlineSender = nil
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

local function resquestRace()
	if resquestOpponent and raceOpponent.hazardLights then
		AcpRace{yourIndex = raceOpponent.sessionID}
		resquestOpponent = false
		acceptedOpponent = true
	end
	if acceptedOpponent and car.hazardLights then
		raceOpponent = onlineSender
		resquestOpponent = false
	end
	if acceptedOpponent then
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
end

local function hasPit()
	if car.isInPit then
		isInRace = false
		raceFinish.winner = raceOpponent
		raceFinish.finished = true
		raceFinish.timeFinish = 10
		raceOpponent = nil
		return 1
	elseif raceOpponent.isInpit then
		isInRace = false
		raceFinish.winner = car
		raceFinish.finished = true
		raceFinish.timeFinish = 10
		raceOpponent = nil
		return 1
	end
	return 0
end

local function inRace()
	distanceBetweenPlayers = distance(vec2(car.position.x, car.position.z), vec2(raceOpponent.position.x, raceOpponent.position.z))
	if hasPit() then return end
	if distanceBetweenPlayers < 50 then whosInFront()
	elseif distanceBetweenPlayers > 500 then
		isInRace = false
		raceFinish.winner = inFront
		raceFinish.finished = true
		raceFinish.timeFinish = 10
		raceOpponent = nil
	end
end

AcpRace = ac.OnlineEvent({
	yourIndex = ac.StructItem.int16(),
}, function (sender, data)
	if data.yourIndex == ac.getCar(0).sessionID then
		onlineSender = sender
		acceptedOpponent = true
		messageTime = 5
		resquestRace()
	end
end)

function script.update(dt)
	if resquestTime > 10 then
		resquestTime = 0
		if raceOpponent and not isInRace then
			raceOpponent = nil
			resquestOpponent = false
		end
	elseif raceOpponent and isInRace then
		resquestTime = resquestTime + dt
	end
	if lightTime < 4 then
		lightTime = lightTime + dt
		if headlight.lastState ~= car.headlightsActive then
			headlight.stateChangedCount = headlight.stateChangedCount + 1
			headlight.lastState = car.headlightsActive
		end
		if headlight.stateChangedCount > 2 then
			raceOpponent = ac.getCar(ac.getCarIndexInFront(0))
			if raceOpponent then
				resquestOpponent = true
				resquestRace()
			end
			headlight.stateChangedCount = 0
			lightTime = 0
		end
	else
		headlight.stateChangedCount = 0
		lightTime = 0
	end
	if isInRace then inRace() end
	if raceFinish.finished then
		raceFinish.timeFinish = raceFinish.timeFinish - dt
		if raceFinish.timeFinish < 0 then
			raceFinish.finished = false
			raceFinish.winner = nil
		end
	end
end

function script.draWUI()
	ui.pushDWriteFont("Orbitron;Weight=600")
	if isInRace then
		if isInRace then
			ui.dummy(vec2(windowWidth/4,windowHeight/10))
			ui.sameLine()
			ui.progressBar(distanceBetweenPlayers/500, vec2(windowWidth/2,windowHeight/10), ac.getDriverName(inFront.index) .. ' is ' .. distanceBetweenPlayers .. ' meters ahead')
		end
	elseif raceFinish.finished then
		local textLenght = ui.measureDWriteText(ac.getDriverName(raceFinish.winner.index) .. " has won the race", 30)
		ui.dwriteDrawText(ac.getDriverName(raceFinish.winner.index) .. " has won the race", 30, vec2(windowWidth/2 - textLenght.x/2, windowHeight/20), rgbm.colors.red)
	elseif messageTime > 0 then
		messageTime = messageTime - ui.deltaTime()
		local textLenght = ui.measureDWriteText(ac.getDriverName(onlineSender.index) .. " wants to challenge you to a race", 30)
		ui.dwriteDrawText(ac.getDriverName(onlineSender.index) .. " wants to challenge you to a race", 30, vec2(windowWidth/2 - textLenght.x/2, windowHeight/20), rgbm.colors.red)
	end
	ui.popDWriteFont()
end
