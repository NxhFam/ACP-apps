local sim = ac.getSim()
local car = ac.getCar(0)
local windowWidth = sim.windowWidth
local windowHeight = sim.windowHeight
local menuOpen = false
local settingsLoaded = true
local valideCar = {"chargerpolice_acpursuit", "ks_mclaren_650_gt3"}

local sharedDataSettings = ac.connect({
	ac.StructItem.key('ACP_essential_settings'),
	showStats = ac.StructItem.boolean(),
	racesWon = ac.StructItem.int16(),
	racesLost = ac.StructItem.int16(),
	busted = ac.StructItem.int16(),
	statsSize = ac.StructItem.int16(),
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
	unit = ac.StructItem.string(4)
}, true, ac.SharedNamespace.Shared)

ui.setAsynchronousImagesLoading(true)
local imageSize = vec2(0,0)

local assetsFolder = ac.getFolder(ac.FolderID.ACApps) .. "/lua/ACP_essential/HUD/"
local hudBase = assetsFolder .. "hudBase.png"
local hudCenter = assetsFolder .. "hudCenter.png"
local hudMenu = assetsFolder .. "iconMenu.png"

local msgChase = {
    {
        lvl = 1,
        msg = {"This is the police! Please pull over to the side of the road!","You are requested to stop your `CAR` immediately, pull over now!","Attention driver, pull over and cooperate with the authorities.","Stop your `CAR` and comply with the police, this is a warning!","Stop the `CAR`! pull over to the side of the road, and follow our instructions."}
    },
    {
        lvl = 2,
        msg = {"** Pull over now, failure to comply may result in consequences.","** We have reason to believe that you are evading the police in your `CAR`, pull over immediately.","** Stop your `CAR`, this is your last warning before we take action.","** You have been warned, failure to stop will result in the use of force.","** Pull over now or face the consequences, you have been warned."}
    },
    {
        lvl = 3,
        msg = {"** This is your final warning, pull over and comply with the police!","** Stop your `CAR`, any attempt to evade the police will result in immediate action!","** You are endangering the public, pull over now and cooperate!","** Failure to comply with police orders will result in the use of force!","** Stop the `CAR` immediately, you are putting yourself and others in danger!",}
    },
    {
        lvl = 4,
        msg = {"*** The use of force may be necessary if you do not comply, pull over now!!","*** You are putting the lives of others in danger, pull over and face the consequences!!","*** Pull over and surrender now, resistance will not be tolerated!!","*** This is the last warning, pull over and face the consequences of your actions!!","*** Stop the `CAR` immediately, you are putting yourself and others in danger!!",}
    },
    {
        lvl = 5,
        msg = {"*** We are taking control of the situation, pull over and surrender now!","*** You have left us no choice, pull over or we will be forced to act!","*** Stop the `CAR` immediately, you are risking the lives of others!","*** This is your final warning, pull over or face the consequences!","*** Stop the vehicle and surrender now, the use of force is authorized!",}
    },
    {
        lvl = 6,
        msg = {"**** The situation is escalating, pull over and surrender yourself to the authorities!","**** Your actions have consequences, pull over and face them now!","**** This is your last chance to comply, stop the `CAR` immediately!","**** We have authorization to use force, pull over and surrender!","**** You are putting yourself and others in danger, pull over now and cooperate!",}
    },
    {
        lvl = 7,
        msg = {"**** You are risking the lives of innocent people, pull over and surrender now!","**** The use of force is imminent, pull over and surrender yourself to the police!","**** This is your final warning, pull over or face the full force of the law!","**** We will use any means necessary to stop your `CAR`, pull over now!","**** You have been warned, pull over and face the consequences of your actions!",}
    },
    {
        lvl = 8,
        msg = {"***** This is your final warning, stop your `CAR` or we will use total force!","***** The situation has escalated, you must stop your `CAR` immediately or face the consequences!","***** We have authorization to use all necessary means to stop your `CAR`, stop now!","***** This is your last warning, stop your `CAR` or we will use all necessary force!","***** Stop your `CAR` immediately, or you will be met with total force!",}
    }
}

local msgEngage = {
    msg = {"Control! I am engaging on a `CAR` traveling at `SPEED`","Pursuit in progress! I am chasing a `CAR` exceeding `SPEED`","Control, be advised! Pursuit is active on a `CAR` driving over `SPEED`","Attention! Pursuit initiated! Im following a `CAR` going above `SPEED`","Pursuit engaged! `CAR` driving at a high rate of speed over `SPEED`","Attention all units, we have a pursuit in progress! Suspect driving a `CAR` exceeding `SPEED`","Attention units! We have a suspect fleeing in a `CAR` at high speed, pursuing now at `SPEED`","Engaging on a high-speed chase! Suspect driving a `CAR` exceeding `SPEED`!","Attention all units! we have a pursuit in progress! Suspect driving a `CAR` exceeding `SPEED`","High-speed chase underway, suspect driving `CAR` over `SPEED`","Control, `CAR` exceeding `SPEED`, pursuit active.","Engaging on a `CAR` exceeding `SPEED`, pursuit initiated."}
}

local msgArrest = {
    msg = {"`NAME` driving a `CAR` has been arrested for Speeding","`NAME` driving a `CAR` has been arrested for Illegal Racing.","`NAME` driving a `CAR` has been arrested for Hit and Run.","`NAME` driving a `CAR` has been arrested for Car Theft.","`NAME` driving a `CAR` has been arrested for Evading Police.","`NAME` driving a `CAR` has been arrested for Public Disturbance."}
}

local pursuit = {
	suspect = nil,
	enable = false,
	maxDistance = 250000,
	minDistance = 40000,
	timeInPursuit = 0,
	nextMessage = 20,
	level = 1,
	id = -1,
	timerArrest = 0,
	hasArrested = false,
}

local arrestations = {}

---------------------------------------------------------------------------------------------- Settings ----------------------------------------------------------------------------------------------

local acpPolice = ac.OnlineEvent({
    message = ac.StructItem.string(110),
	messageType = ac.StructItem.int16(),
	yourIndex = ac.StructItem.int16(),
}, function (sender, data) end)

local showPreviewMsg = false
COLORSMSGBG = rgbm(0.5,0.5,0.5,0.5)

local function initSettings()
	ac.log(sharedDataSettings.showStats)
	if not sharedDataSettings.showStats then
		settingsLoaded = false
		SETTINGS = {
			showStats = true,
			racesWon = 0,
			racesLost = 0,
			busted = 0,
			statsSize = 20,
			statsOffsetX = 0,
			statsOffsetY = 0,
			statsFont = 20,
			current = 1,
			colorHud = rgbm(1,0,0,1),
			timeMsg = 10,
			msgOffsetY = 10,
			msgOffsetX = windowWidth/2,
			fontSizeMSG = 30,
			menuPos = vec2(0, 0),
			unit = "Kmh",
			unitMult = 1,
		}
	else SETTINGS = sharedDataSettings end
	if SETTINGS.unit ~= "Kmh" then SETTINGS.unitMult = 0.621371 end
	SETTINGS.statsFont = SETTINGS.statsSize * windowHeight/1440
	imageSize = vec2(windowHeight/80 * SETTINGS.statsSize, windowHeight/80 * SETTINGS.statsSize)
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
	ui.text('On Screen Message : ')
	SETTINGS.timeMsg = ui.slider('##' .. 'Time Msg On Screen', SETTINGS.timeMsg, 1, 15, 'Time Msg On Screen' .. ': %.0fs')
	SETTINGS.fontSizeMSG = ui.slider('##' .. 'Font Size MSG', SETTINGS.fontSizeMSG, 10, 50, 'Font Size' .. ': %.0f')
	ui.newLine()
	ui.text('Offset : ')
	SETTINGS.msgOffsetY = ui.slider('##' .. 'Msg On Screen Offset Y', SETTINGS.msgOffsetY, 0, windowHeight, 'Msg On Screen Offset Y' .. ': %.0f')
	SETTINGS.msgOffsetX = ui.slider('##' .. 'Msg On Screen Offset X', SETTINGS.msgOffsetX, 0, windowWidth, 'Msg On Screen Offset X' .. ': %.0f')
    ui.newLine()
	ui.text('Preview : ')
    if ui.button('Message') then showPreviewMsg = not showPreviewMsg end
    if showPreviewMsg then previewMSG() end
	ui.sameLine()
	if ui.button('Offset X to center') then SETTINGS.msgOffsetX = windowWidth/2 end
	ui.newLine()
end


local function settings()
	imageSize = vec2(windowHeight/80 * SETTINGS.statsSize, windowHeight/80 * SETTINGS.statsSize)
	if ui.checkbox('Show HUD', SETTINGS.showStats) then SETTINGS.showStats = not SETTINGS.showStats end
	SETTINGS.statsOffsetX = ui.slider('##' .. 'HUD Offset X', SETTINGS.statsOffsetX, 0, windowWidth, 'HUD Offset X' .. ': %.0f')
	SETTINGS.statsOffsetY = ui.slider('##' .. 'HUD Offset Y', SETTINGS.statsOffsetY, 0, windowHeight, 'HUD Offset Y' .. ': %.0f')
	SETTINGS.statsSize = ui.slider('##' .. 'HUD Size', SETTINGS.statsSize, 10, 50, 'HUD Size' .. ': %.0f')
	local fontMultiplier = windowHeight/1440
	SETTINGS.statsFont = SETTINGS.statsSize * fontMultiplier
    ui.setNextItemWidth(300)
	local colorHud = SETTINGS.colorHud
    ui.colorPicker('Theme Color', colorHud, ui.ColorPickerFlags.AlphaBar)
    ui.newLine()
    uiTab()
    return 2
end

---------------------------------------------------------------------------------------------- Utils ----------------------------------------------------------------------------------------------

local function formatMessage(message)
	local msgToSend = message
	if pursuit.suspect == nil then
		msgToSend = string.gsub(msgToSend,"`CAR`", "No Car")
		msgToSend = string.gsub(msgToSend,"`NAME`", "No Name")
		msgToSend = string.gsub(msgToSend,"`SPEED`", "No Speed")
		return msgToSend
	end
	msgToSend = string.gsub(msgToSend,"`CAR`", string.gsub(string.gsub(ac.getCarName(0), "%W", " "), "  ", ""))
	msgToSend = string.gsub(msgToSend,"`NAME`", "@" .. ac.getDriverName(pursuit.suspect.index))
	msgToSend = string.gsub(msgToSend,"`SPEED`", string.format("%d ", ac.getCarSpeedKmh(pursuit.suspect.index) * SETTINGS.unitMult) .. SETTINGS.unit)
	return msgToSend
end

---------------------------------------------------------------------------------------------- HUD ----------------------------------------------------------------------------------------------

local iconsColorOn = {
	[1] = rgbm(1,1,1,1),
	[2] = rgbm(1,1,1,1),
}

local playersInRange = {}

local function drawImage()
	iconsColorOn[1] = rgbm(0.99,0.99,0.99,1)
	iconsColorOn[2] = rgbm(0.99,0.99,0.99,1)
	local uiStats = ac.getUI()
	local arrestPos1 = vec2(imageSize.x - imageSize.x/1.7, imageSize.y/1.9)
	local arrestPos2 = vec2(imageSize.x/3.6, imageSize.y/2.6)
	local menuPos1 = vec2(imageSize.x/1.75, imageSize.y/1.9)
	local menuPos2 = vec2(imageSize.x - imageSize.x/1.75, imageSize.y/2.6)

	ui.drawImage(hudCenter, vec2(0,0), imageSize)
	if ui.rectHovered(arrestPos2, arrestPos1) then
		iconsColorOn[1] = SETTINGS.colorHud
		if pursuit.suspect and car.speedKmh < 20 and uiStats.isMouseLeftKeyClicked then
			pursuit.hasArrested = true
		end
	elseif ui.rectHovered(menuPos2, menuPos1) then
		iconsColorOn[2] = SETTINGS.colorHud
		if uiStats.isMouseLeftKeyClicked then
			if menuOpen then menuOpen = false else menuOpen = true end
		end
	end
	ui.image(hudBase, imageSize, SETTINGS.colorHud)
	ui.drawImage(hudArrest, vec2(0,0), imageSize, iconsColorOn[1])
	ui.drawImage(hudMenu, vec2(0,0), imageSize, iconsColorOn[2])
end

local function playerSelected(player)
	if pursuit.suspect == player then
		pursuit.suspect = nil
		ac.setExtraSwitch(0, false)
	else
		pursuit.suspect = player
		pursuit.timeInPursuit = os.clock()
		pursuit.nextMessage = 20
		pursuit.level = 1
		ac.setExtraSwitch(0, true)
		ac.sendChatMessage(formatMessage(msg.engage.msg[math.random(msg.engage.nb)]))
	end
end

local function drawText()
	local text
	local textSize = ui.measureDWriteText("MMMMMMMMMMMMMMMMMMMM" .. string.format(" %d ", 000) .. SETTINGS.unit, SETTINGS.statsFont)
	local firstBox = vec2(123,123)
	local uiStats = ac.getUI()

	for i = 1, #playersInRange do
		text = string.sub(ac.getDriverName(playersInRange[i].index), 1, 20) .. string.format(" %d ", playersInRange[i].speedKmh * SETTINGS.unitMult) .. SETTINGS.unit
		if ui.rectHovered(firstBox, firstBox + textSize) then
			if uiStats.isMouseLeftKeyClicked then
				ui.dwriteText(text, SETTINGS.statsFont, SETTINGS.colorHud)
				playerSelected(playersInRange[i])
			end
		elseif pursuit.suspect == playersInRange[i] then
			ui.dwriteDrawText(text, SETTINGS.statsFont, firstBox, SETTINGS.colorHud)
		else
			ui.dwriteDrawText(text, SETTINGS.statsFont, firstBox, rgbm(1,1,1,1))
		end
		if i % 2 == 0 then
			firstBox = firstBox + vec2(textSize.x, 0)
		else
			firstBox = firstBox + vec2(-textSize.x, textSize.y)
		end
	end
end

local function radarUI()
	ui.transparentWindow('RadarHud', vec2(SETTINGS.statsOffsetX, SETTINGS.statsOffsetY), imageSize, true, function ()
		drawImage()
		ui.childWindow('PlayerList', imageSize/2, false, function ()
			drawText()
		end)
		if pursuit.suspect then
			ui.dwriteTextWrapped("Driver : " .. ac.getDriverName(pursuit.suspect.index) .. "\nCar : " .. ac.getCarName(pursuit.suspect.index) .. string.format(" %d ", ac.getCarSpeedKmh(pursuit.suspect.index) * SETTINGS.unitMult) .. SETTINGS.unit .. "\nPursuit : " .. string.format("%.1f", os.clock() - pursuit.timeInPursuit) .. "s LVL :    " .. pursuit.level, SETTINGS.statsFont * 2, SETTINGS.colorHud)
		end
	end)
end

local function radarUpdate()
	local radarRange = 250
	local previousSize = #playersInRange

	local j = 1
	for i = ac.getSim().carsCount - 1, 0, -1 do
		local player = ac.getCar(i)
		if player.isConnected and (not player.isHidingLabels) then
			if player.index ~= car.index then
				if player.position.x > car.position.x - radarRange and player.position.z > car.position.z - radarRange and player.position.x < car.position.x + radarRange and player.position.z < car.position.z + radarRange then
					playersInRange[j] = player
					j = j + 1
					if j == 9 then break end
				end
			end
		end
	end
	for i = j, previousSize do playersInRange[i] = nil end
end

---------------------------------------------------------------------------------------------- Chase ----------------------------------------------------------------------------------------------

local chaseLVL = {
	message = "",
	messageTimer = 0,
}

local function resetChase()
	pursuit.enable = false
	pursuit.nextMessage = 20
	pursuit.level = 1
end

local function lostSuspect()
	resetChase()
	pursuit.suspect = nil
	ac.setExtraSwitch(0, false)
end

local function inRange()
	local distance_x = pursuit.suspect.position.x - car.position.x
	local distance_z = pursuit.suspect.position.z - car.position.z
	if(distance_x * distance_x + distance_z * distance_z < pursuit.minDistance) then
		pursuit.enable = true
	elseif (distance_x * distance_x + distance_z * distance_z > pursuit.minDistance and distance_x * distance_x + distance_z * distance_z < pursuit.maxDistance) then
		pursuit.timeInPursuit = os.clock()
		resetChase()
	else
		if pursuit.suspect.rpm > 400 and pursuit.suspect.speedKmh > 20 then
			local msgToSend = formatMessage("Suspect have been lost, Vehicle Description:`CAR` driven by `NAME`")
			ac.sendChatMessage(msgToSend)
		end
		lostSuspect()
	end
end

local function sendChaseMsg()
	if pursuit.enable then
		if os.clock() - pursuit.timeInPursuit > pursuit.nextMessage then
			local i = math.random(msg.stop[pursuit.level].nb)
			local msgToSend = formatMessage(msg.stop[pursuit.level].msg[i])
			chaseLVL.message = string.format("Level %d⭐", pursuit.level)
			chaseLVL.messageTimer = SETTINGS.timeMsg
			if pursuit.level < 5 and pursuit.connected then
				acpPolice{message = msgToSend, messageType = 1, yourIndex = ac.getCar(pursuit.suspect.index).sessionID}
			else
				ac.sendChatMessage(msgToSend)
			end
			pursuit.nextMessage = pursuit.nextMessage + 20
			if pursuit.level < 8 then
				pursuit.level = pursuit.level + 1
			end
		end
	end
end

local function showPursuitMsg()
	if pursuit.timerArrest > 0 then
		pursuit.timerArrest = pursuit.timerArrest - ui.deltaTime()
		local text = chaseLVL.message
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
end

local function arrestSuspect()
	if pursuit.hasArrested and pursuit.suspect then
		local msgToSend = formatMessage(msg.arrest.msg[b])
		table.insert(arrestations, msgToSend .. os.date("\nDate of the Arrestation: %c"))
		ac.sendChatMessage("You are under arrest!\n" .. msgToSend .. "\nPlease Get Back Pit, GG!")
		pursuit.id = pursuit.suspect.sessionID
		pursuit.suspect = nil
		ac.setExtraSwitch(0, false)
		pursuit.timerArrest = 1
	end
	if pursuit.timerArrest > 0 then
		pursuit.timerArrest = pursuit.timerArrest - ui.deltaTime()
	else
		acpPolice{message = "Arrest", messageType = 2, yourIndex = pursuit.id}
		pursuit.timerArrest = 0
		pursuit.suspect = nil
		pursuit.id = -1
	end
end

local function chaseUpdate()
	if pursuit.suspect then
		sendChaseMsg()
		inRange()
		showPursuitMsg()
		arrestSuspect()
	end
end

---------------------------------------------------------------------------------------------- Menu ----------------------------------------------------------------------------------------------

local function arrestLogsUI()
	local allMsg = ""
	ui.dwriteText("Set ClipBoard by clicking on the button\nnext to the message you want to copy.", 15, rgbm.colors.white)
	for i = 1, #arrestations do
		if ui.smallButton("#" .. i .. ": ", vec2(0,10)) then
			ui.setClipboardText(arrestations[i])
		end
		ui.sameLine()
		ui.dwriteText(arrestations[i], 15, rgbm.colors.white)
	end
	ui.newLine()
	if ui.button("Set all messages to ClipBoard") then
		for i = 1, #arrestations do
			allMsg = allMsg .. arrestations[i] .. "\n\n"
		end
		ui.setClipboardText(allMsg)
	end
	return 1
end

local function download()
	ui.dwriteTextWrapped("Download the latest version of ACP Pursuit.", 30, rgbm.colors.white)
	if ui.textHyperlink("ACP Patreon") then
        os.openURL("https://www.patreon.com/posts/acp-download-51908849")
    end
end

local initialized = false
local menuSize = {vec2(windowWidth/4, windowHeight/3), vec2(windowWidth/6, windowHeight*2/3)}
local currentTab = 1
local buttonPressed = false

local function menu()
	if not settingsLoaded then download()
	else
		ui.tabBar('MainTabBar', ui.TabBarFlags.Reorderable, function ()
			ui.tabItem('Arrest Logs', function () currentTab = arrestLogsUI() end)
			ui.tabItem('Settings', function () currentTab = settings() end)
		end)
		if ui.button('Close', vec2(100, 50)) then menuOpen = false end
	end
end

local function moveMenu()
	if ui.windowHovered() and ui.mouseDown() then buttonPressed = true end
	if ui.mouseReleased() then buttonPressed = false end
	if buttonPressed then SETTINGS.menuPos = SETTINGS.menuPos + ui.mouseDelta() end
end

---------------------------------------------------------------------------------------------- updates ----------------------------------------------------------------------------------------------

function script.drawUI()
	if settingsLoaded and initialized then
		radarUI()
		if menuOpen then
			ui.toolWindow('Menu', SETTINGS.menuPos, menuSize[currentTab], false, function ()
				ui.childWindow('childMenu', menuSize[currentTab], false, function ()
					menu()
					moveMenu()
				end)
			end)
		end
	end
end

function script.update(dt)
	if not initialized then
		if ac.getCarID(0) ~= valideCar[1] and ac.getCarID(0) ~= valideCar[2] then return end
		initialized = true
        initSettings()
		ac.log("notinit")
	else
		if settingsLoaded then
			radarUpdate()
			chaseUpdate()
			ac.log("init")
			sharedDataSettings = SETTINGS
		end
	end
end

-- if ac.getCarID(0) == valideCar[1] or ac.getCarID(0) == valideCar[2] then
-- 	ui.registerOnlineExtra(ui.Icons.Menu, 'Menu', nil, menu, nil, ui.OnlineExtraFlags.Tool)
-- end
