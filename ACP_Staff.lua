local initialized = false

function script.update(dt)
	if not initialized then
	  ac.log(sim.directUDPMessagingAvailable)
    ac.log("Staff script")
    initialized = true
  else
    return
	end
end
