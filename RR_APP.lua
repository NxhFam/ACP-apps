local sim = ac.getSim()
local windowWidth = sim.windowWidth
local icon = "radar"
local time = 0


function script.drawUI()
	ui.transparentWindow('radar', vec2(0, 0), vec2(windowWidth, 400), function ()
		local textSize = ui.measureDWriteText("GO CHANGE YOUR FUCKIN NAME\nIT MIGHT BE MISSING SOMETHING???" , 50)
		ui.dwriteDrawText("GO CHANGE YOUR FUCKIN NAME" , 50, vec2((windowWidth-textSize.x)/2, 0), rgbm.colors.red)
	end)
end

function script.update(dt)
	time = time + dt
	ui.registerOnlineExtra(icon, "settings", function ()
		ui.itemPopup(ui.MouseButton.Right, function ()
			if ui.selectable('Item 1') then 
				ui.dwriteDrawText("Item 1" , 10, vec2(0, 0), rgbm.colors.red)
			end
			if ui.selectable('Item 2') then 
				ui.dwriteDrawText("Item 2" , 10, vec2(0, 0), rgbm.colors.red)
			end
			ui.separator()
			if ui.selectable('Item 3') then
				ui.dwriteDrawText("Item 3" , 10, vec2(0, 0), rgbm.colors.red)
			end
		end)
	end)
	if time > 10 then
		ac.sendChatMessage("FUCKK ME")
		time = 0
	end
end
