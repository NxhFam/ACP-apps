local tabCA = require("src/tabs/cameras")
local tabLI = require("src/tabs/lights")
local tabSC = require("src/tabs/shortcuts")
--local online = require("src/online")
require("src/settings")
local sim = ac.getSim()
local windowWidth = sim.windowWidth
local wrongName = false

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

function script.fullscreenUI(dt)
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
	ui.pushDWriteFont("Orbitron;Weight=Bold")
	if string.find(ac.getDriverName(0), "_RR_") then
		ui.tabBar('someTabBarID', function ()
			ui.tabItem('Shortcuts', function () tabSC.shortcuts(dt) end)
			ui.tabItem('Cameras', function () tabCA.cameras() end)
			ui.tabItem('Lights',function () tabLI.lights() end)
			--ui.tabItem('Online', function () online.showMessage() end)
		end)
	else
		wrongName = true
	end
end
