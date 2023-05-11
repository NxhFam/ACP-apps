local sim = ac.getSim()
local windowWidth = sim.windowWidth
local wrongName = false
local default_colors = '1,1,1,1|0.9,1,0,1|1,1,0,1|0.5,0.5,0.5,0.5'
SETTINGS = ac.storage {
	fontSizeHUD = 30,
	fontSizeMSG = 30,
	colors = default_colors,
	colorsInfo = rgbm(1, 1, 1, 1),
	colorsData = rgbm(0.9, 1, 0, 1),
	colorsMsg = rgbm(1,1,0,1),
	colorsMsgBG = rgbm(0.5,0.5,0.5,0.5),
	showMsg = true,
	unit = 'feet',
	unitMult = 3.28084,
	uiOffsetX = 0,
	uiOffsetY = 0,
	sliderX = 0,
	sliderY = 0,
	radarRange = 500,
	radarActive = true,
	timeMsg = 5,
	syncNeons = false,
	enableSyncNeons = true,
	tempoLights = '0.5,0.5,0.5,0.5',
	colorLights = 'r,y',
}

local rrEvent = ac.OnlineEvent({
	messageType = ac.StructItem.int16(),
}, function (sender, data)
	if string.find(ac.getDriverName(sender.index), "_RR_") then
		if data.messageType == 2 then
			if SETTINGS.enableSyncNeons then SETTINGS.syncNeons = true end
		end
	end
end)

local selectedcolor = 'Radar_Info'
local colors = {}
local color_names = {'Radar_Info', 'Radar_Data', 'Msg', 'MsgBG'}

function tocolor(string)
	local temp = string:split('|')
	local temp1 = {}
	for i = 1, #temp do
	  for a, b, c, d in temp[i]:gmatch('(.+),(.+),(.+),(.+)') do temp1[i] = rgbm(tonumber(a), tonumber(b), tonumber(c), tonumber(d)) end
	end
	for i, k in ipairs(color_names) do
	  if temp1[i] == nil then temp1[i] = rgbm.colors.white end
	  colors[k] = temp1[i]
	end
	return temp1
end


tocolor(SETTINGS.colors)

local function general()
	ui.beginGroup()
	ui.text('HUD Position / Size : ')
	SETTINGS.fontSizeHUD = ui.slider('##' .. 'Font Size HUD', SETTINGS.fontSizeHUD, 10, 50, 'Font Size HUD' .. ': %.0f')
	SETTINGS.uiOffsetX = ui.slider('##' .. 'UI Offset X', SETTINGS.uiOffsetX, SETTINGS.sliderX, windowWidth, 'UI Offset X' .. ': %.0f')
	SETTINGS.uiOffsetY = ui.slider('##' .. 'UI Offset Y', SETTINGS.uiOffsetY, SETTINGS.sliderY, 400, 'UI Offset Y' .. ': %.0f')
	ui.newLine()
	ui.text('Radar Settings : ')
	if ui.checkbox('Radar Active', SETTINGS.radarActive) then SETTINGS.radarActive = not SETTINGS.radarActive end
	SETTINGS.radarRange = ui.slider('##' .. 'Radar Range', SETTINGS.radarRange, 100, 1000, 'Radar Range' .. ': %.0f')
	ui.text('Unit : ')
	ui.sameLine(120)
	if ui.selectable('feet', SETTINGS.unit == 'feet',_, ui.measureText('feet')) then 
		SETTINGS.unit = 'feet'
		SETTINGS.unitMult = 3.28084
	end
	ui.sameLine(160)
	if ui.selectable('meters', SETTINGS.unit == 'meters',_, ui.measureText('meters')) then 
		SETTINGS.unit = 'meters'
		SETTINGS.unitMult = 1
	end
	ui.newLine()
	ui.text('Online Event Messages : ')
	if ui.checkbox('Show OnlineEvent', SETTINGS.showMsg) then SETTINGS.showMsg = not SETTINGS.showMsg end
	SETTINGS.timeMsg = ui.slider('##' .. 'Time Msg On Screen', SETTINGS.timeMsg, 1, 20, 'Time Msg' .. ': %.0fs')
	SETTINGS.fontSizeMSG = ui.slider('##' .. 'Font Size Online msg', SETTINGS.fontSizeMSG, 10, 50, 'Font Size Online msg' .. ': %.0f')
	ui.newLine()
	ui.text('UI Colors : ')
	local save_color = ''
	for i, j in pairs(color_names) do
		if ui.selectable(j, selectedcolor == j,_, ui.measureText(j)) then selectedcolor = j end
		save_color = save_color .. colors[j].r .. "," .. colors[j].g .. "," .. colors[j].b .. "," .. colors[j].mult .. '|'
		ui.sameLine()
	end
	ui.newLine()
	ui.colorPicker(selectedcolor, colors[selectedcolor], ui.ColorPickerFlags.AlphaBar)
	ui.newLine(20)
	SETTINGS.colors = save_color
	SETTINGS.colorsInfo = colors.Radar_Info
	SETTINGS.colorsData = colors.Radar_Data
	SETTINGS.colorsShortcuts = colors.ShortCuts
	SETTINGS.colorsMsg = colors.Msg
	SETTINGS.colorsMsgBG = colors.MsgBG
	if ui.button('reset colors') then
		SETTINGS.colors = default_colors
		tocolor(SETTINGS.colors)
	end
	ui.endGroup()
end

local function lightSettings()
	local tempo = nil
	local lightColors = nil
	local temp
	ui.beginGroup()
	if ui.checkbox('Enable Sync Neons', SETTINGS.enableSyncNeons) then SETTINGS.enableSyncNeons = not SETTINGS.enableSyncNeons end
	if ui.button("Sync Neons") then
		rrEvent{messageType = 2}
	end
	ui.newLine()
	ui.text('Neons Settings : ')
	ui.text('Both neons tempo and color sequence will be looped infinitely')
	ui.newLine()
	ui.text('Neons Tempo: ')
	ui.text('To change the tempo, write the time in seconds between each light\nseparated by comma (,) without spaces')
	ui.text('example:0.5,1,1.2,...,0.2')
	tempo = ui.inputText('Tempo', tempo)
	if tempo ~= nil then
		SETTINGS.tempoLights = tempo
	end
	ui.newLine()
	ui.text('Neons Colors: ')
	ui.text('Available colors: (b)blue, (g)green, (r)red, (y)yellow, (p)purple, (c) and (w)white')
	ui.text('To chose color sequence, write the colors\nseparated by comma (,) without spaces')
	ui.text('example:b,g,,...,r')
	lightColors = ui.inputText('Colors', lightColors)
	if lightColors ~= nil then
		SETTINGS.colorLights = lightColors
	end
	ui.endGroup()
end

function script.windowMainSettings()
	ui.tabBar('someTabBarID', function ()
		ui.tabItem('Lights', lightSettings)
		ui.tabItem('General', general)
	end)
end

--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

local msg = {
	"If your warping around, try to Enable custom raycasting in CSP physics tweaks (general patch settings). Use CSP 1.79 or CSP 1.80 Preview 1",
	"That car won't move. Cars with shopping cart or lock next to their icon have other requirments to drive. Pick a C Class",
	"Go to the discord discord.com/acpursuit to learn about points/missions/dealers.",
	"If having FPS issues or poor performance. Go on the discord and grab one of the VideoCSP Presets",
	"We use mumble proximity on the server. Check discord on how to set it up.",
	"To enable neons on street cars:\nContent Manager > ASSETTO CORSA > CONTROLS > PATCH \nSet bindings for Extra options A-F",
}

local buttons = {
	"CPU",
	"CAR",
	"DISCORD",
	"FPS",
	"MUMBLE",
	"NEON"
}

local cooldown = 0
local countDownState = {
	countdownOn = false,
	ready = true,
	set = true,
	go = true
}

local function countdown()
	if cooldown < 5 and countDownState.ready == true then
		ac.sendChatMessage('***GET READY***...')
		countDownState.ready = false
	elseif cooldown < 3 and countDownState.set == true then
		ac.sendChatMessage('**SET**')
		countDownState.set = false
	elseif cooldown == 0 and countDownState.go == true then
		ac.sendChatMessage('*GO*GO*GO*')
		countDownState.go = false
		countDownState.countdownOn = false
	end
end

local function shortcutsTab(dt)
	for b = 1, #buttons do
		if b % 2 == 0 then
			ui.sameLine()
		end
		if ui.smallButton(buttons[b]) then
			ac.sendChatMessage(msg[b])
		end
	end 
	if cooldown == 0 then
		if ui.smallButton("Start Countdown") and not countDownState.countdownOn then
			cooldown = 5
			countDownState.countdownOn = true
			countDownState.ready = true
			countDownState.set = true
			countDownState.go = true
		end
	elseif countDownState.countdownOn then
		cooldown = cooldown - dt
		if cooldown < 0 then
			cooldown = 0
		end
		countdown()
		ui.text("You wont spam me LOL")
	end
	if ui.button("Send ClipBoard") then
		ac.sendChatMessage(ui.getClipboardText())
	end
end

--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

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

local function lightsTab()
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


local function distance(youPos, policePos)
	local l = youPos.x - policePos.x
	local k = youPos.z - policePos.z
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

function script.drawUI()
	local you = ac.getCar(0)
	if ac.isWindowOpen("main") and SETTINGS.radarActive then
		ui.transparentWindow('radar', vec2(0, 0), vec2(windowWidth, 400), function ()
			for i = ac.getSim().carsCount - 1, 0, -1 do
				local car = ac.getCar(i)
				if car.isConnected and (not car.isHidingLabels) then
					if ac.getCarID(i) == "chargerpolice_acpursuit" then
						if car.position.x > you.position.x - SETTINGS.radarRange and car.position.z > you.position.z - SETTINGS.radarRange and car.position.x < you.position.x + SETTINGS.radarRange and car.position.z < you.position.z + SETTINGS.radarRange then
							local textInfo = "COP:    " .. ac.getDriverName(i) .. "\nDistance:" .. string.format("%d %s", distance(you.position, car.position) * SETTINGS.unitMult, SETTINGS.unit)
							local textInfoSize = ui.measureDWriteText(textInfo, SETTINGS.fontSizeHUD)
							local infoSize = ui.measureDWriteText("Distance :", SETTINGS.fontSizeHUD)
							SETTINGS.sliderX = textInfoSize.x
							SETTINGS.sliderY = textInfoSize.y
							local uiOffsetX = math.max(SETTINGS.uiOffsetX - textInfoSize.x, 0)
							local uiOffsetY = math.max(SETTINGS.uiOffsetY - textInfoSize.y, 0)
							textInfo = "COP:     \nDistance:"
							local textData = ac.getDriverName(i) .. "\n" .. string.format("%d %s", distance(you.position, car.position) * SETTINGS.unitMult, SETTINGS.unit)
							ui.dwriteDrawText(textInfo , SETTINGS.fontSizeHUD, vec2(uiOffsetX, uiOffsetY), SETTINGS.colorsInfo)
							ui.dwriteDrawText(textData, SETTINGS.fontSizeHUD, vec2(uiOffsetX + infoSize.x, uiOffsetY), SETTINGS.colorsData)
						end
					end
				end
			end
			if wrongName then
				local textSize = ui.measureDWriteText("GO CHANGE YOUR FUCKIN NAME\nIT MIGHT BE MISSING SOMETHING???" , 50)
				ui.dwriteDrawText("GO CHANGE YOUR FUCKIN NAME" , 50, vec2((windowWidth-textSize.x)/2, 0), rgbm.colors.red)
			end
		end)
	end
end

function script.windowMain(dt)
	if string.find(ac.getDriverName(0), "_RR_") then
		ui.tabBar('someTabBarID', function ()
			ui.tabItem('Shortcuts', function () shortcutsTab(dt) end)
			ui.tabItem('Lights',function () lightsTab() end)
		end)
	else
		wrongName = true
	end
end
