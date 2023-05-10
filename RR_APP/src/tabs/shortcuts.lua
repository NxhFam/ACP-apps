local public = {}

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

function public.shortcuts(dt)
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
	ui.text(physics.allowed())
end

return public