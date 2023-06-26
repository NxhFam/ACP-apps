--[[
  Pauses AC in background.
]]

if not Config:get('MISCELLANEOUS', 'PAUSE_IN_BACKGROUND', false) then
  return
end

local paused = false
local sim = ac.getSim()

Register('core', function ()
  if paused and sim.isWindowForeground then
    paused = false
    ac.tryToPause(false)
  elseif not sim.isWindowForeground and not sim.isPaused then
    ac.tryToPause(true)
    paused = true
  end
end)
