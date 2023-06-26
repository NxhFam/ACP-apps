local PHYSICS_DEBUG_PICK_CARS = false  -- set to `true` to be able to activate lines for certain cars

local sim = ac.getSim()
local defaultCar = ac.getCar(0)
local currentMode = ac.VAODebugMode.Active
local debugLines = { types = {}, cars = { [1] = true } }
local lightSettings = table.chain({filter = '?', count = 10, distance = 100, flags = {outline = true, bbox = true, bsphere = false, text = true}, active = false, dirty = true}, stringify.tryParse(ac.storage.debugLightsSettings, {}))
lightSettings.active = false

local debugWeatherControl = ac.connect({
  ac.StructItem.key('weatherFXDebugOverride'),
  weatherType = ac.StructItem.byte(),
  debugSupported = ac.StructItem.boolean()
})
debugWeatherControl.weatherType = 255
debugWeatherControl.debugSupported = false

local function syncState()
  local t, c = 0, 0
  for k, v in pairs(debugLines.types) do
    if v then
      t = bit.bor(t, k)
    end
  end
  for k, v in pairs(debugLines.cars) do
    if v then
      c = bit.bor(c, bit.lshift(1, k - 1))
    end
  end

  local carIndex = math.max(0, sim.focusedCar)
  ac.setPhysicsDebugLines(c ~= 0 and t or 0, PHYSICS_DEBUG_PICK_CARS and c or bit.lshift(1, carIndex))
  
  if lightSettings.dirty then
    lightSettings.dirty = false
    if lightSettings.active then
      local flags = 0
      if lightSettings.flags.outline then flags = bit.bor(flags, ac.LightsDebugMode.Outline) end
      if lightSettings.flags.bbox then flags = bit.bor(flags, ac.LightsDebugMode.BoundingBox) end
      if lightSettings.flags.bsphere then flags = bit.bor(flags, ac.LightsDebugMode.BoundingSphere) end
      if lightSettings.flags.text then flags = bit.bor(flags, ac.LightsDebugMode.Text) end
      local filter = lightSettings.filter
      if filter == '' then filter = '?' end
      ac.debugLights(filter, lightSettings.count, flags, lightSettings.distance)
    else
      ac.debugLights('', 0, ac.LightsDebugMode.None, 0)
    end
  end
  ac.storage.debugLightsSettings = stringify(lightSettings)
end

local function controlSceneDetail(label, value, postfix)
  ui.text(label..': ')
  ui.sameLine(0, 0)
  ui.copyable(value)
  if postfix then
    ui.sameLine(0, 0)
    ui.text(' '..postfix)
  end
end

local function degressToCompassString(angleDeg)
  local value = math.round(angleDeg / 22.5)
  if value == 0 or value == 16 then
    return 'N'
  elseif value == 1 then
    return 'NNE'
  elseif value == 2 then
    return 'NE'
  elseif value == 3 then
    return 'ENE'
  elseif value == 4 then
    return 'E'
  elseif value == 5 then
    return 'ESE'
  elseif value == 6 then
    return 'SE'
  elseif value == 7 then
    return 'SSE'
  elseif value == 8 then
    return 'S'
  elseif value == 9 then
    return 'SSW'
  elseif value == 10 then
    return 'SW'
  elseif value == 11 then
    return 'WSW'
  elseif value == 12 then
    return 'W'
  elseif value == 13 then
    return 'WNW'
  elseif value == 14 then
    return 'NW'
  elseif value == 15 then
    return 'NNW'
  else
    return '?'
  end
end

local function controlSceneDetails()
  local cameraPos = ac.getCameraPosition()
  controlSceneDetail('Camera', string.format('%.2f, %.2f, %.2f', cameraPos.x, cameraPos.y, cameraPos.z))
  controlSceneDetail('Altitude', string.format('%.2f', ac.getAltitude()), 'm')

  local compassAngle = ac.getCompassAngle(ac.getCameraForward())
  if compassAngle < 0 then compassAngle = compassAngle + 360 end
  controlSceneDetail('Compass', string.format('%.1f°', compassAngle), degressToCompassString(compassAngle))
  controlSceneDetail('FFB (pure)', string.format('%.1f%%', defaultCar.ffbPure * 100))
  controlSceneDetail('FFB (final)', string.format('%.1f%%', defaultCar.ffbFinal * 100))
end

local function controlRender()
  ui.text('Mode:')
  if ui.radioButton('Default', currentMode == ac.VAODebugMode.Active) then currentMode = ac.VAODebugMode.Active end
  if ui.radioButton('Disable VAO', currentMode == ac.VAODebugMode.Inactive) then currentMode = ac.VAODebugMode.Inactive end
  if ui.radioButton('VAO only', currentMode == ac.VAODebugMode.VAOOnly) then currentMode = ac.VAODebugMode.VAOOnly end
  if ui.radioButton('Normals', currentMode == ac.VAODebugMode.ShowNormals) then currentMode = ac.VAODebugMode.ShowNormals end
  ac.setVAOMode(currentMode)
end

local function controlFocus()
  ui.childWindow('##cars', ui.availableSpace(), function ()
    for i = 0, sim.carsCount - 1 do
      if ui.radioButton(string.format('#%d: %s', i + 1, ac.getDriverName(i)), sim.focusedCar == i) then
        ac.focusCar(i)
      end
    end
  end)
end

local function controlLights()
  ui.beginGroup()
  if ui.checkbox('Debug lights', lightSettings.active) then
    lightSettings.active = not lightSettings.active
    lightSettings.dirty = true
  end

  ui.alignTextToFramePadding()
  ui.text('Filter: ')
  ui.sameLine(0, 0)
  ui.setNextItemWidth(ui.availableSpaceX())
  lightSettings.filter = ui.inputText('?', lightSettings.filter, ui.InputTextFlags.Placeholder)
  if ui.itemHovered() then
    ui.setTooltip('Use section name as a filter with “?” for any number of any symbols')
  end

  ui.setNextItemWidth(ui.availableSpaceX())
  lightSettings.count = ui.slider('##count', lightSettings.count, 0, 100, 'Count: %.0f', 2)

  ui.setNextItemWidth(ui.availableSpaceX())
  lightSettings.distance = ui.slider('##distance', lightSettings.distance, 0, 1000, 'Distance: %.1f m', 2)

  local w = ui.availableSpaceX()
  if ui.checkbox('BBox', lightSettings.flags.bbox) then
    lightSettings.flags.bbox = not lightSettings.flags.bbox
    lightSettings.dirty = true
  end

  ui.sameLine(w / 2, 0)
  if ui.checkbox('BSphere', lightSettings.flags.bsphere) then
    lightSettings.flags.bsphere = not lightSettings.flags.bsphere
    lightSettings.dirty = true
  end

  if ui.checkbox('Outline', lightSettings.flags.outline) then
    lightSettings.flags.outline = not lightSettings.flags.outline
    lightSettings.dirty = true
  end

  ui.sameLine(w / 2, 0)
  if ui.checkbox('Text', lightSettings.flags.text) then
    lightSettings.flags.text = not lightSettings.flags.text
    lightSettings.dirty = true
  end

  ui.endGroup()
  if ui.itemEdited() then
    lightSettings.dirty = true
  end
end

local function controlVRAM()
  local vram = ac.getVRAMConsumption()
  if vram then
    ui.text(string.format('Usage:\n%.3f out of %.3f GB (%.3f%%)', vram.usage / 1024, vram.budget / 1024, 100 * vram.usage / vram.budget))
    ui.text(string.format('Reserved:\n%.3f out of %.3f GB (%.3f%%)', vram.reserved / 1024, vram.availableForReservation / 1024, 100 * vram.reserved / vram.availableForReservation))
  else
    ui.textWrapped('VRAM stats are not available on this system')
  end
end

local function controlCarUtils()
  ui.text('Visual:')
  local car = ac.getCar(sim.focusedCar) or defaultCar
  if ui.button('Hide driver', car.isDriverVisible and 0 or ui.ButtonFlags.Active) then
    ac.setDriverVisible(car.index, not car.isDriverVisible)
  end
  ui.sameLine(0, 4)
  if ui.button('Open door', car.isDriverDoorOpen and ui.ButtonFlags.Active or 0) then
    ac.setDriverDoorOpen(car.index, not car.isDriverDoorOpen)
  end

  ui.offsetCursorY(12)
  ui.text('Helpers:')
  if not sim.isOnlineRace and sim.carsCount == 1 and not sim.specialEvent then
    if ui.button('Reset') then
      if ac.getUI().ctrlDown then
        ac.takeAStepBack()
      else
        ac.resetCar()
      end
    end
    if ui.itemHovered() then
      ui.setTooltip('Hold Ctrl to move further back')
    end
  end
end

local function controlTime()
  ui.text(os.dateGlobal('%Y-%m-%d %H:%M:%S', sim.timestamp)..' (x'..sim.timeMultiplier..')')

  if sim.isOnlineRace then
    return
  end

  ui.offsetCursorY(12)
  ui.text('Offset:')
  if ui.smallButton('−12h') then ac.setWeatherTimeOffset(-12 * 60 * 60, true) end ui.sameLine(0, 2)
  if ui.smallButton('−4h') then ac.setWeatherTimeOffset(-4 * 60 * 60, true) end ui.sameLine(0, 2)
  if ui.smallButton('−1h') then ac.setWeatherTimeOffset(-1 * 60 * 60, true) end ui.sameLine(0, 2)
  if ui.smallButton('−20m') then ac.setWeatherTimeOffset(-20 * 60, true) end --ui.sameLine(0, 2)
  if ui.smallButton('+12h') then ac.setWeatherTimeOffset(12 * 60 * 60, true) end ui.sameLine(0, 2)
  if ui.smallButton('+4h') then ac.setWeatherTimeOffset(4 * 60 * 60, true) end ui.sameLine(0, 2)
  if ui.smallButton('+1h') then ac.setWeatherTimeOffset(1 * 60 * 60, true) end ui.sameLine(0, 2)
  if ui.smallButton('+20m') then ac.setWeatherTimeOffset(20 * 60, true) end --ui.sameLine(0, 2)

  ui.pushStyleVar(ui.StyleVar.FramePadding, vec2(3.5, 0))
  if ui.smallButton('−day') then ac.setWeatherTimeOffset(-24 * 60 * 60, true) end ui.sameLine(0, 2)
  if ui.smallButton('−week') then ac.setWeatherTimeOffset(-7 * 24 * 60 * 60, true) end ui.sameLine(0, 2)
  if ui.smallButton('−month') then ac.setWeatherTimeOffset(-30 * 24 * 60 * 60, true) end ui.sameLine(0, 2)
  if ui.smallButton('−year') then ac.setWeatherTimeOffset(-365 * 24 * 60 * 60, true) end --ui.sameLine(0, 2)
  if ui.smallButton('+day') then ac.setWeatherTimeOffset(24 * 60 * 60, true) end ui.sameLine(0, 2)
  if ui.smallButton('+week') then ac.setWeatherTimeOffset(7 * 24 * 60 * 60, true) end ui.sameLine(0, 2)
  if ui.smallButton('+month') then ac.setWeatherTimeOffset(30 * 24 * 60 * 60, true) end ui.sameLine(0, 2)
  if ui.smallButton('+year') then ac.setWeatherTimeOffset(365 * 24 * 60 * 60, true) end --ui.sameLine(0, 2)
  ui.popStyleVar()

  ui.offsetCursorY(12)
  ui.text('Time flow:')
  ui.pushStyleVar(ui.StyleVar.FramePadding, vec2(6, 0))
  if ui.smallButton('0x') then ac.setWeatherTimeMultiplier(0) end ui.sameLine(0, 2)
  if ui.smallButton('1x') then ac.setWeatherTimeMultiplier(1) end ui.sameLine(0, 2)
  if ui.smallButton('60x') then ac.setWeatherTimeMultiplier(60) end ui.sameLine(0, 2)
  if ui.smallButton('600x') then ac.setWeatherTimeMultiplier(600) end ui.sameLine(0, 2)
  if ui.smallButton('6000x') then ac.setWeatherTimeMultiplier(6000) end
  ui.popStyleVar()
end

local currentConditions = ac.ConditionsSet()
local weatherTypes = {
  { 'Clear', 15 },
  { 'Few clouds', 16 },
  { 'Scattered clouds', 17 },
  { 'Broken clouds', 18 },
  { 'Overcast clouds', 19 },
  false,
  { 'Mist', 21 },
  { 'Fog', 20 },
  false,
  { 'Drizzle (light)', 3 },
  { 'Drizzle (medium)', 4 },
  { 'Drizzle (heavy)', 5 },
  { 'Rain (light)', 6 },
  { 'Rain (medium)', 7 },
  { 'Rain (heavy)', 8 },
  { 'Thunderstorm (light)', 0 },
  { 'Thunderstorm (medium)', 1 },
  { 'Thunderstorm (heavy)', 2 },
  { 'Sleet (light)', 12 },
  { 'Sleet (medium)', 13 },
  { 'Sleet (heavy)', 14 },
  { 'Snow (light)', 9 },
  { 'Snow (medium)', 10 },
  { 'Snow (heavy)', 11 },
  false,
  { 'Tornado', 27 },
  { 'Hurricane', 28 },
  false,
  { 'Smoke', 22 },
  { 'Haze', 23 },
  { 'Sand', 24 },
  { 'Dust', 25 },
  { 'Squalls', 26 },
  { 'Cold', 29 },
  { 'Hot', 30 },
  { 'Windy', 31 },
  { 'Hail', 32 }
}

local function controlWeatherSelector(current, callback)
  ui.setNextItemWidth(ui.availableSpaceX())
  ui.combo('##Types', 'Selected: '..(current and current[1] or '?'), ui.ComboFlags.HeightLarge, function ()
    for _, k in ipairs(weatherTypes) do
      if not k then
        ui.separator()
      else
        if ui.selectable(k[1], k[2] == currentConditions.currentType) then
          callback(k[2])
        end
      end
    end
  end)
end

local function controlWeather()
  ac.getConditionsSetTo(currentConditions)

  local current = table.findFirst(weatherTypes, function (item, index, callbackData)
    return item and item[2] == currentConditions.currentType
  end)

  if sim.isOnlineRace then
    ui.text('Weather: '..(current and current[1] or '?'))
    return
  end

  if sim.isReplayActive then
    controlWeatherSelector(current, function (value)
      currentConditions.currentType = value
      currentConditions.upcomingType = value
      currentConditions.transition = 0
      ac.overrideReplayConditions(currentConditions)
    end)
    ui.pushItemWidth(ui.availableSpaceX())

    ui.beginGroup()
    currentConditions.wind.direction = ui.slider('##windd', currentConditions.wind.direction, 0, 360, 'Wind angle: %.1f°')
    currentConditions.wind.speedFrom = ui.slider('##winds', currentConditions.wind.speedFrom, 0, 100, 'Wind speed: %.1f km/h', 2)
    currentConditions.wind.speedTo = currentConditions.wind.speedFrom
    ui.separator()

    -- currentConditions.humidity = ui.slider('##humidity', currentConditions.humidity * 100, 0, 100, 'Humidity: %.1f%%') / 100
    -- currentConditions.pressure = ui.slider('##pressure', currentConditions.pressure / 1e3, 100, 120, 'Pressure: %.0f hpa') * 1e3
    -- ui.separator()

    currentConditions.rainIntensity = ui.slider('##raini', currentConditions.rainIntensity * 100, 0, 100, 'Rain: %.1f%%', 2) / 100
    currentConditions.rainWetness = ui.slider('##rainw', currentConditions.rainWetness * 100, 0, 100, 'Wetness: %.1f%%', 2) / 100
    currentConditions.rainWater = ui.slider('##raint', currentConditions.rainWater * 100, 0, 100, 'Water: %.1f%%', 2) / 100
    ui.endGroup()

    if ui.itemEdited() then
      ac.overrideReplayConditions(currentConditions)
    end

    ui.popItemWidth()
    if ui.button('Reset replay override', vec2(ui.availableSpaceX(), 0)) then
      ac.overrideReplayConditions(nil)
    end
    return
  end

  if not debugWeatherControl.debugSupported then
    ui.textWrapped('Needs default or compatible controller to override weather type during the race')
    return
  end

  controlWeatherSelector(current, function (value)
    debugWeatherControl.weatherType = value
  end)
end

local isRacingLineDebugActive = false
local physicsDebugLines

local function controlPhysicsDebugLines()
  ui.text('Debug lines:')
  if PHYSICS_DEBUG_PICK_CARS then
    ui.text('Types:')
  end
  if not physicsDebugLines then
    physicsDebugLines = table.map(ac.PhysicsDebugLines, function (item, index, callbackData)
      return index
    end)
    table.sort(physicsDebugLines)
  end
  for _, k in ipairs(physicsDebugLines) do
    local v = ac.PhysicsDebugLines[k]
    if v ~= 0 and ui.checkbox(k, debugLines.types[v] or false) then
      debugLines.types[v] = not debugLines.types[v]
    end
  end
  if PHYSICS_DEBUG_PICK_CARS then
    ui.text('Cars:')
    for i = 1, math.min(sim.carsCount, 63) do
      if ui.checkbox(string.format('Car #%d (%s)', i, ac.getCarID(i - 1)), debugLines.cars[i] or false) then
        debugLines.cars[i] = not debugLines.cars[i]
      end
    end
  end

  ui.offsetCursorY(12)
  ui.text('Other visuals:')
  if ui.checkbox('Rain racing line debug', isRacingLineDebugActive) then
    isRacingLineDebugActive = not isRacingLineDebugActive
    ac.debugRainRacingLine(isRacingLineDebugActive)
  end
end

local lastSelectedTab = ac.storage.lastSelectedTab
local curSelectedTab = lastSelectedTab

local function tabItem(label, fn)
  local active = lastSelectedTab == label
  if active then
    lastSelectedTab = nil
  end
  ui.tabItem(label, active and ui.TabItemFlags.SetSelected or 0, function ()
    ui.offsetCursorX(8)
    local s = ui.availableSpace()
    s.x = s.x - 8
    ui.childWindow('content', s, fn)

    if curSelectedTab ~= label then
      curSelectedTab = label
      ac.storage.lastSelectedTab = label
    end
  end)
end

function script.windowMain(dt)
  ui.pushFont(ui.Font.Small)

  ui.tabBar('tabs', ui.TabBarFlags.TabListPopupButton + ui.TabBarFlags.FittingPolicyScroll + ui.TabBarFlags.NoTabListScrollingButtons, function ()
    tabItem('Details', controlSceneDetails)
    tabItem('Car', controlCarUtils)
    if sim.carsCount > 1 then
      tabItem('Cars', controlFocus)
    end
    tabItem('Physics', controlPhysicsDebugLines)
    tabItem('Render', controlRender)
    tabItem('Lights', controlLights)
    tabItem('Time', controlTime)
    tabItem('Weather', controlWeather)
    tabItem('VRAM', controlVRAM)
  end)

  ui.popFont()

  syncState()
end

local cfgVideo = ac.INIConfig.load(ac.getFolder(ac.FolderID.Cfg)..'\\video.ini', ac.INIFormat.Default)
local cfgGraphics = ac.INIConfig.load(ac.getFolder(ac.FolderID.Root)..'\\system\\cfg\\graphics.ini', ac.INIFormat.Default)

local function applyChange(section, key, value)
  cfgVideo:setAndSave(section, key, value)
  ac.refreshVideoSettings()
end

local function applyGraphicsChange(section, key, value)
  cfgGraphics:setAndSave(section, key, value)
  ac.refreshVideoSettings()
end

function script.windowSettings(dt)
  ui.pushFont(ui.Font.Small)
  ui.pushItemWidth(ui.availableSpaceX())
  local newValue

  ui.header('View')
  if ui.checkbox('Hide arms', cfgVideo:get('ASSETTOCORSA', 'HIDE_ARMS', false)) then
    applyChange('ASSETTOCORSA', 'HIDE_ARMS', not cfgVideo:get('ASSETTOCORSA', 'HIDE_ARMS', false))
  end
  if ui.checkbox('Hide steering wheel', cfgVideo:get('ASSETTOCORSA', 'HIDE_STEER', false)) then
    applyChange('ASSETTOCORSA', 'HIDE_STEER', not cfgVideo:get('ASSETTOCORSA', 'HIDE_STEER', false))
  end
  if ui.checkbox('Lock steering wheel', cfgVideo:get('ASSETTOCORSA', 'LOCK_STEER', false)) then
    applyChange('ASSETTOCORSA', 'LOCK_STEER', not cfgVideo:get('ASSETTOCORSA', 'LOCK_STEER', false))
  end

  ui.offsetCursorY(12)
  ui.header('Quality')
  newValue = ui.slider('##qwd', cfgVideo:get('ASSETTOCORSA', 'WORLD_DETAIL', 5), 0, 5, 'World detail: %.0f')
  if ui.itemEdited() then
    applyChange('ASSETTOCORSA', 'WORLD_DETAIL', math.round(newValue))
  end

  local shadows = {0, 32, 64, 128, 256, 512, 1024, 2048, 3072, 4096, 6144, 8192}
  newValue = table.indexOf(shadows, cfgVideo:get('VIDEO', 'SHADOW_MAP_SIZE', 0)) or 1
  newValue = ui.slider('##qsm', newValue, 1, #shadows,
    string.format('Shadows: %s', newValue == 1 and 'off' or (shadows[newValue] or 0)..'x'))
  if ui.itemEdited() then
    applyChange('VIDEO', 'SHADOW_MAP_SIZE', shadows[math.round(newValue)] or 0)
  end

  local levels = {0, 2, 4, 8, 16}
  newValue = table.indexOf(levels, cfgVideo:get('VIDEO', 'ANISOTROPIC', 0)) or 1
  newValue = ui.slider('##qan', newValue, 1, #levels,
    string.format('Anisotropic filtering: %s', newValue == 1 and 'off' or (levels[newValue] or 0)..'x'))
  if ui.itemEdited() then
    applyChange('VIDEO', 'ANISOTROPIC', levels[math.round(newValue)] or 0)
  end

  if cfgVideo:get('POST_PROCESS', 'ENABLED', true) then
    ui.offsetCursorY(12)
    ui.header('Post-processing')

    newValue = ui.slider('##ppq', cfgVideo:get('POST_PROCESS', 'QUALITY', 1), 0, 5, 'Quality: %.0f')
    if ui.itemEdited() then
      applyChange('POST_PROCESS', 'QUALITY', math.round(newValue))
    end

    newValue = ui.slider('##ppg', cfgVideo:get('POST_PROCESS', 'GLARE', 1), 0, 5, 'Glare: %.0f')
    if ui.itemEdited() then
      applyChange('POST_PROCESS', 'GLARE', math.round(newValue))
    end

    newValue = ui.slider('##ppd', cfgVideo:get('POST_PROCESS', 'DOF', 1), 0, 5, 'DOF: %.0f')
    if ui.itemEdited() then
      applyChange('POST_PROCESS', 'DOF', math.round(newValue))
    end

    if cfgVideo:get('EFFECTS', 'MOTION_BLUR', 0) > 0 and not ac.getSim().isVRConnected then
      newValue = ui.slider('##ppm', cfgVideo:get('EFFECTS', 'MOTION_BLUR', 1), 1, 12, 'Motion blur: %.0f')
      if ui.itemEdited() then
        applyChange('EFFECTS', 'MOTION_BLUR', math.round(newValue))
      end
    end

    if ui.checkbox('Sunrays', cfgVideo:get('POST_PROCESS', 'RAYS_OF_GOD', false)) then
      applyChange('POST_PROCESS', 'RAYS_OF_GOD', not cfgVideo:get('POST_PROCESS', 'RAYS_OF_GOD', false))
    end

    if ui.checkbox('Heat shimmer', cfgVideo:get('POST_PROCESS', 'HEAT_SHIMMER', false)) then
      applyChange('POST_PROCESS', 'HEAT_SHIMMER', not cfgVideo:get('POST_PROCESS', 'HEAT_SHIMMER', false))
    end
  end

  ui.offsetCursorY(12)
  ui.header('Reflections')

  if cfgVideo:get('CUBEMAP', 'FACES_PER_FRAME', 1) > 0 then
    newValue = ui.slider('##cfpf', cfgVideo:get('CUBEMAP', 'FACES_PER_FRAME', 1), 1, 6, 'Faces per frame: %.0f')
    if ui.itemEdited() then
      applyChange('CUBEMAP', 'FACES_PER_FRAME', math.round(newValue))
    end
  end

  newValue = ui.slider('##cfp', cfgVideo:get('CUBEMAP', 'FARPLANE', 1), 100, 2500, 'Rendering distance: %.0f m')
  if ui.itemEdited() then
    applyChange('CUBEMAP', 'FARPLANE', math.round(newValue))
  end

  ui.offsetCursorY(12)
  ui.header('Tweaks')
  
  newValue = ui.slider('##fps', 1e3 / cfgVideo:get('VIDEO', 'FPS_CAP_MS', 100), 0, 200, 'FPS cap: %.0f')
  if ui.itemEdited() then
    applyChange('VIDEO', 'FPS_CAP_MS', 1e3 / math.round(newValue))
  end

  newValue = ui.slider('##mip', cfgGraphics:get('DX11', 'MIP_LOD_BIAS', 0), -5, 5, 'MIP LOD bias: %.1f')
  if ui.itemEdited() then
    applyGraphicsChange('DX11', 'MIP_LOD_BIAS', newValue)
  end

  if not ac.isModuleActive(ac.CSPModuleID.WeatherFX) then
    newValue = ui.slider('##srg', cfgGraphics:get('DX11', 'SKYBOX_REFLECTION_GAIN', 1) * 100, 0, 200, 'Skybox gain: %.0f%%')
    if ui.itemEdited() then
      applyGraphicsChange('DX11', 'SKYBOX_REFLECTION_GAIN', newValue / 100)
    end
  end

  newValue = ui.slider('##tsa', cfgVideo:get('SATURATION', 'LEVEL', 100), 0, 200, 'Saturation: %.0f%%')
  if ui.itemEdited() then
    applyChange('SATURATION', 'LEVEL', math.round(newValue))
  end

  ui.popItemWidth()
  ui.popFont()
end

ac.onRelease(function ()
  ac.setVAOMode(ac.VAODebugMode.Active)
  ac.debugLights('', 0, ac.LightsDebugMode.None, 0)
  ac.setPhysicsDebugLines(ac.PhysicsDebugLines.None)
  debugWeatherControl.weatherType = 255
end)
