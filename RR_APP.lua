local sim = ac.getSim()
local windowWidth = sim.windowWidth
local color = rgbm.colors.blue


function script.drawUI()
	ui.transparentWindow('radar', vec2(0, 0), vec2(windowWidth, 400), function ()
		local textSize = ui.measureDWriteText("GO CHANGE YOUR FUCKIN NAME\nIT MIGHT BE MISSING SOMETHING???" , 50)
		ui.dwriteDrawText("GO CHANGE YOUR FUCKIN NAME" , 50, vec2((windowWidth-textSize.x)/2, 0), color)
	end)
	ui.beginPopupContextItem('mon cul')
		if ui.button('Please Work') then
			color = rgbm.colors.red
		end
	ui.endPopup()
end
