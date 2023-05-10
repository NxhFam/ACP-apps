local public = {}
-- local sim = ac.getSim()
-- local width = sim.windowWidth
-- local chatMessage = nil

-- messageType 1 = message to show to private chat in Online tab
-- messageType 2 = sync neons
-- local rrEvent = ac.OnlineEvent({
--     message = ac.StructItem.string(150),
-- 	messageType = ac.StructItem.int16(),
-- }, function (sender, data)
-- 	if string.find(ac.getDriverName(sender.index), "_RR_") then
-- 		if data.messageType == 1 then
-- 			chatMessage = ac.getDriverName(sender.index) .. chatMessage .. "\n" .. data.message
-- 		elseif data.messageType == 2 then
-- 			if SETTINGS.enableSyncNeons then SETTINGS.syncNeons = true end
-- 		end
-- 	end
-- end)
	-- local messageToSend
	-- local windowWidth = ui.windowWidth()
	-- local windowHeight = ui.windowHeight()
	-- windowWidth = math.max(windowWidth - 20, 200)
	-- windowHeight = math.max(windowHeight - 20, 200)


	-- ui.childWindow("RR_APP_Online", vec2(windowWidth, windowHeight), true, function ()
	-- 	ui.dwriteTextWrapped(chatMessage)
	-- end)
	-- ui.dwriteTextWrapped("Maximum of 150 characters")
	-- messageToSend = ui.inputText(string.format("%d",#messageToSend), messageToSend)
	-- if messageToSend ~= nil then
	-- 	if #messageToSend > 150 then
	-- 		messageToSend = string.sub(messageToSend, 1, 150)
	-- 	end
	-- 	if ui.button("Send") then
	-- 		rrEvent{message = messageToSend,messageType = 1,}
	-- 	end
	-- end

-- function public.showMessage()
-- 	--local physics = ac.accessCarPhysics()
-- 	ui.text(physics.allowed())
-- end

return public