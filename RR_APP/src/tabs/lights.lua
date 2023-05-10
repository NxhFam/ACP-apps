local public = {}

local function blue()
	ac.setExtraSwitch(1, true)
end

local function green()
	ac.setExtraSwitch(2, true)
end

local function red()
	ac.setExtraSwitch(3, true)
end

local function yellow()
	ac.setExtraSwitch(2, true)
	ac.setExtraSwitch(3, true)
end

local function purple()
	ac.setExtraSwitch(1, true)
	ac.setExtraSwitch(3, true)
end

local function cyan()
	ac.setExtraSwitch(1, true)
	ac.setExtraSwitch(2, true)
end

local function white()
	ac.setExtraSwitch(1, true)
	ac.setExtraSwitch(2, true)
	ac.setExtraSwitch(3, true)
end

local function none()
	ac.setExtraSwitch(1, false)
	ac.setExtraSwitch(2, false)
	ac.setExtraSwitch(3, false)
end

local time = 0

local lights = {
	neonOn = false,
	rrTempo = {0.2, 0.5, 1.2, 2.3, 3, 2.5, 1.1, 0.8, 0.6, 0.5, 0.4, 0.3, 0.2, 0.2, 0.3, 0.4, 0.5, 0.6, 0.8, 1.1, 2.5, 3, 2.3, 1.2, 0.5, 0.2},
	rrColor = {'r', 'y'},
	customTempo = {},
	customColor = {},
	currentNeon = "RR",
	tempoIndex = 1,
	colorIndex = 1,
	lastTime = 0,
}

local function changeColor(color)
	if color == 'b' then blue()
	elseif color == 'g' then green()
	elseif color == 'r' then red()
	elseif color == 'y' then yellow()
	elseif color == 'p' then purple()
	elseif color == 'c' then cyan()
	elseif color == 'w' then white()
	else none()
	end
end

local function toTempo(string)
	local temp = string:split(',')
	for i = 1, #temp do
		local numTemp = tonumber(temp[i])
		if numTemp == nil then numTemp = 0.5 end
		lights.customTempo[i] = numTemp
	end
end

local function toNeonColor(string)
	local temp = string:split(',')
	for i = 1, #temp do
		local colorTemp = temp[i]
		if colorTemp == 'b' then lights.customColor[i] = 'b'
		elseif colorTemp == 'g' then lights.customColor[i] = 'g'
		elseif colorTemp == 'r' then lights.customColor[i] = 'r'
		elseif colorTemp == 'y' then lights.customColor[i] = 'y'
		elseif colorTemp == 'p' then lights.customColor[i] = 'p'
		elseif colorTemp == 'c' then lights.customColor[i] = 'c'
		elseif colorTemp == 'w' then lights.customColor[i] = 'w'
		else lights.customColor[i] = 'r'
		end
	end
end

local function changeNeon(timeCPU)
	if lights.currentNeon == "RR" then

		if timeCPU - lights.lastTime > lights.rrTempo[lights.tempoIndex] then
			none()
			changeColor(lights.rrColor[lights.colorIndex])
			lights.tempoIndex = lights.tempoIndex + 1
			if lights.tempoIndex > #lights.rrTempo then
				lights.tempoIndex = 1
			end
			lights.colorIndex = lights.colorIndex + 1
			if lights.colorIndex > #lights.rrColor then
				lights.colorIndex = 1
			end
			lights.lastTime = timeCPU
		end
	elseif lights.currentNeon == "Custom" then
		if timeCPU - lights.lastTime > lights.customTempo[lights.tempoIndex] then
			none()
			changeColor(lights.customColor[lights.colorIndex])
			lights.tempoIndex = lights.tempoIndex + 1
			if lights.tempoIndex > #lights.customTempo then
				lights.tempoIndex = 1
			end
			lights.colorIndex = lights.colorIndex + 1
			if lights.colorIndex > #lights.customColor then
				lights.colorIndex = 1
			end
			lights.lastTime = timeCPU
		end
	else
		none()
	end
end

function public.lights()
	ui.text('Neons : ')
	if ui.button("NONE") then
		lights.currentNeon = "NONE"
		lights.neonOn = false
		none()
	end
	ui.sameLine()
	if ui.button("RR") then
		lights.currentNeon = "RR"
		lights.neonOn = true
		lights.tempoIndex = 1
		lights.colorIndex = 1
	end
	ui.sameLine()
	if ui.button("Custom") then
		lights.currentNeon = "Custom"
		toNeonColor(SETTINGS.colorLights)
		toTempo(SETTINGS.tempoLights)
		lights.neonOn = true
		lights.tempoIndex = 1
		lights.colorIndex = 1
	end
end

local sync = true

function script.update()
	time = os.clock()
	if lights.neonOn then
		changeNeon(time)
	end
	if SETTINGS.syncNeons then
		lights.neonOn = true
		lights.currentNeon = "RR"
		lights.tempoIndex = 1
		lights.colorIndex = 1
		SETTINGS.syncNeons = false
		sync = true
	end
	if not SETTINGS.enableSyncNeons and sync then
		lights.neonOn = false
		sync = false
		none()
	end
end

return public