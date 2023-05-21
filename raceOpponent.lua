local sim = ac.getSim()
local car = ac.getCar(0)
local windowWidth = sim.windowWidth
local windowHeight = sim.windowHeight/4

local headlight = {
	lastState = false,
	stateChangedCount = 0,
	flashingLights = false,
}
local lightTime = 0

local isInRace = false
local raceOpponent = nil
local acceptedOpponent = false
local resquestOpponent = false
local inFront = nil
local behind = nil
local direction = vec3(0,0,0)
local midBetweenPlayers = vec2(0,0)
local midPlusDirection = vec2(0,0)
local distanceBetweenPlayers = 0

local resquestTime = 0
local messageTime = 0

local equal = false
local onlineSender = nil

local acpRace = ac.OnlineEvent({
	yourIndex = ac.StructItem.int16(),
}, function (sender, data)
	if data.yourIndex == ac.getCar(0).sessionID then
		onlineSender = ac.getCar(sender)
		resquestOpponent = true
		messageTime = 5
	end
end)

local function newtonSqrt(n)
    local tolerance = 0.001
    local guess = n / 2

    repeat
        local nextGuess = (guess + n / guess) / 2
        local diff = math.abs(guess - nextGuess)
        guess = nextGuess
    until diff <= tolerance
    return guess
end

local function distanceSquared(p1, p2)
	return (p1.x - p2.x)^2 + (p1.y - p2.y)^2
end

local function cross(vector1, vector2)
	return vec2(vector1.x * vector2.y, vector1.y * vector2.x)
end

local function normalize(vector)
	local length = newtonSqrt(vector.x^2 + vector.y^2)
	return vec2(vector.x/length, vector.y/length)
end

local function dot(vector1, vector2)
	return vector1.x * vector2.x + vector1.y * vector2.y
end

local function determineFirstPlayer(player1Position, player1Direction, player2Position, player2Direction)
    -- Calculate the vector connecting the positions of the two players
    local positionVector = player2Position - player1Position

    -- Normalize the position vector
    positionVector = normalize(positionVector)

    -- Calculate the dot products
    local dotProduct1 = dot(positionVector, player1Direction)
    local dotProduct2 = dot(positionVector, player2Direction)

    -- Compare the dot products to determine the first player
    if dotProduct1 > dotProduct2 then
		inFront = car
		behind = raceOpponent
    elseif dotProduct2 < dotProduct1 then
		inFront = raceOpponent
		behind = car
    end
end

local function whosInFront()
	local youDistanceSquared = distanceSquared(vec2(car.position.x, car.position.z), midPlusDirection)
	local opponentDistanceSquared = distanceSquared(vec2(raceOpponent.position.x, raceOpponent.position.z), midPlusDirection)
	if youDistanceSquared < opponentDistanceSquared then
		inFront = car
		behind = raceOpponent
	else
		inFront = raceOpponent
		behind = car
	end
end

local function resquestRace()
	if resquestOpponent and raceOpponent.hazardLights then
		acceptedOpponent = true
		resquestOpponent = false
	end
	if resquestOpponent and car.hazardLights then
		raceOpponent = onlineSender
		acceptedOpponent = true
		resquestOpponent = false
	end
	if acceptedOpponent then
		messageTime = 0
		if dot(vec2(car.look.x, car.look.z), vec2(raceOpponent.look.x, raceOpponent.look.z)) > 0 then
			direction = cross(car.look, vec2(raceOpponent.look.x, raceOpponent.look.z))
			midBetweenPlayers = vec2((car.position.x + raceOpponent.position.x)/2, (car.position.z + raceOpponent.position.z)/2)
			midPlusDirection = midBetweenPlayers + direction
			whosInFront()
			isInRace = true
		else
			isInRace = false
			raceOpponent = nil
		end
		acceptedOpponent = false
	end
end

local function inRace()
	distanceBetweenPlayers = distanceSquared(vec2(car.position.x, car.position.z), vec2(raceOpponent.position.x, raceOpponent.position.z))
	if distanceBetweenPlayers < 200 then
		equal = true
	elseif equal then
		determineFirstPlayer(vec2(car.position.x, car.position.z), vec2(car.look.x, car.look.z), vec2(raceOpponent.position.x, raceOpponent.position.z), vec2(raceOpponent.look.x, raceOpponent.look.z))	
		equal = false
	end
	if distanceBetweenPlayers > 250000 then
		isInRace = false
		raceOpponent = nil
	end
end

function script.update(dt)
	resquestTime = resquestTime + dt
	if resquestTime > 10 then
		resquestTime = 0
		if raceOpponent and not isInRace then
			raceOpponent = nil
		end
	end
	if lightTime < 2 then
		lightTime = lightTime + dt
		if headlight.lastState ~= car.headlightsActive then
			headlight.stateChangedCount = headlight.stateChangedCount + 1
			headlight.lastState = car.headlightsActive
		end
		if headlight.stateChangedCount > 3 then
			local carInfront = ac.getCarIndexInFront(0)
			if carInfront > 0 then
				raceOpponent = ac.getCar(carInfront)
				acpRace{yourIndex = carInfront}
				resquestOpponent = true
			end
			headlight.stateChangedCount = 0
			lightTime = 0
		end
	else
		headlight.stateChangedCount = 0
		lightTime = 0
	end
	if not isInRace then
		if resquestOpponent then
			resquestRace()
		end
	else
		inRace()
	end
end

function script.drawUI()
	ui.pushDWriteFont("Orbitron;Weight=600")
	if isInRace then
		local textLenght = ui.measureDWriteText(ac.getDriverName(0) .. " is in the lead", 30)
		if isInRace then
			ui.dwriteDrawText(ac.getDriverName(inFront.index) .. " is in the lead", 30, vec2(windowWidth/2 - textLenght.x/2, 0), rgbm.colors.red)
			ui.dummy(vec2(0,windowHeight/10))
			ui.dummy(vec2(windowWidth/4,windowHeight/10))
			ui.sameLine()
			ui.progressBar(distanceBetweenPlayers/250000, vec2(windowWidth/2,windowHeight/10), 'Distance')
		end
	end
	if messageTime > 0 then
		messageTime = messageTime - ui.deltaTime()
		local textLenght = ui.measureDWriteText(ac.getDriverName(car.index) .. " wants to challenge you to a race\nTo accept activate you hazard lights", 30)
		ui.dwriteDrawText(ac.getDriverName(car.index) .. " wants to challenge you to a race\nTo accept activate you hazard lights", 30, vec2(windowWidth/2 - textLenght.x/2, windowHeight/20), rgbm.colors.red)
	end
	ui.popDWriteFont()
end
