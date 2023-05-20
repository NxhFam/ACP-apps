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
local confirmedOpponent = false
local inFront = nil
local behind = nil
local direction = vec3(0,0,0)
local midBetweenPlayers = vec2(0,0)
local midPlusDirection = vec2(0,0)
local distanceBetweenPlayers = 0

local raceEvent = ac.OnlineEvent({
	messageRace = ac.StructItem.int16(),
	yourIndex = ac.StructItem.int16(),
}, function (sender, data)
	if data.yourIndex == ac.getCar(0).sessionID and data.messageRace == 1 then
		acceptedOpponent = true
		raceOpponent = ac.getCar(sender)
	elseif data.yourIndex == ac.getCar(0).sessionID and data.messageRace == 2 then
		confirmedOpponent = true
		raceOpponent = ac.getCar(sender)
	end
end)

local function dot(vector1, vector2)
	return vector1.x * vector2.x + vector1.y * vector2.y
end

local function whosInFront()
	local youDistanceSquared = math.distanceSquared(vec2(car.position.x, car.position.z), midPlusDirection)
	local opponentDistanceSquared = math.distanceSquared(vec2(raceOpponent.position.x, raceOpponent.position.z), midPlusDirection)
	if youDistanceSquared < opponentDistanceSquared then
		inFront = car
		behind = raceOpponent
	else
		inFront = raceOpponent
		behind = car
	end
end

local function resquestRace()
	if car.hazardLights and acceptedOpponent then
		raceEvent{messageRace = 2, yourIndex = raceOpponent.sessionID}
	end
	if confirmedOpponent or acceptedOpponent then
		if dot(vec2(car.look.x, car.look.z), vec2(raceOpponent.look.x, raceOpponent.look.z)) > 0 then
			direction = math.cross(car.look, vec2(raceOpponent.look.x, raceOpponent.look.z))
			midBetweenPlayers = vec2((car.position.x + raceOpponent.position.x)/2, (car.position.z + raceOpponent.position.z)/2)
			midPlusDirection = midBetweenPlayers + direction
			whosInFront()
			isInRace = true
		else
			acceptedOpponent = false
			confirmedOpponent = false
			raceOpponent = nil
		end
	end
end

local function inRace()
	distanceBetweenPlayers = math.distanceSquared(vec2(car.position.x, car.position.z), vec2(raceOpponent.position.x, raceOpponent.position.z))
	if distanceBetweenPlayers > 2500000 then
		isInRace = false
		acceptedOpponent = false
		confirmedOpponent = false
		raceOpponent = nil
	end
	if distanceBetweenPlayers < 10 then
		if dot(vec2(inFront.look.x, inFront.look.z), math.normalize(vec2(behind.position.x, behind.position.z))) > 0 then
			local temp = inFront
			inFront = behind
			behind = temp
		end
	end
end

function script.update(dt)
	if lightTime < 2 then
		lightTime = lightTime + dt
		if headlight.lastState ~= car.headlightsActive then
			headlight.stateChangedCount = headlight.stateChangedCount + 1
			headlight.lastState = car.headlightsActive
		end
		if headlight.stateChangedCount > 3 then
			headlight.flashingLights = true
			local carInfront = ac.getCarIndexInFront(0)
			if carInfront > 0 then
				raceEvent{messageRace = 1, yourIndex = carInfront}
			end
			headlight.stateChangedCount = 0
			lightTime = 0
		end
	else
		headlight.flashingLights = false
		headlight.stateChangedCount = 0
		lightTime = 0
	end
	if not isInRace then
		if headlight.flashingLights then
			resquestRace()
		end
	else
		inRace()
		if not raceOpponent.isConnected then
			isInRace = false
			acceptedOpponent = false
			confirmedOpponent = false
			raceOpponent = nil
		end
	end
end

function script.drawUI()
	ui.pushDWriteFont("Orbitron;Weight=600")
	local textLenght = ui.measureDWriteText(ac.getDriverName(0) .. " is in the lead", 30)
	if isInRace then
			ui.dwriteDrawText(ac.getDriverName(inFront.index) .. " is in the lead", 30, vec2(windowWidth/2 - textLenght.x/2, 0), rgbm.colors.red)
			ui.dummy(vec2(0,windowHeight/10))
			ui.dummy(vec2(windowWidth/4,windowHeight/10))
			ui.sameLine()
			ui.progressBar(distanceBetweenPlayers/2500000, vec2(windowWidth/2,windowHeight/10), 'Distance')
	end
	ui.popDWriteFont()
end
