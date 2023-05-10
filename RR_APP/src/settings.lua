local default_colors = '1,1,1,1|0.9,1,0,1|1,1,0,1|0.5,0.5,0.5,0.5'
local sim = ac.getSim()
local windowWidth = sim.windowWidth
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