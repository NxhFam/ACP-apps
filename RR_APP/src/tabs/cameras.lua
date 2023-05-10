local public = {}

local cameras = {}
local firstLoad = true

local function getCameras()
	local cameraIni = ac.INIConfig.load(ac.getFolder(ac.FolderID.ACApps) .. "/lua/RR_APP/data/cameras.ini", ac.INIFormat.Default)
	
	for index, section in cameraIni:iterate("CAMERA") do
		local camera = {}
		camera.name = cameraIni:get(section, "NAME", "Unknown camera")
		camera.pos = vec3(
			cameraIni:get(section, "POS_X", 0),
			cameraIni:get(section, "POS_Y", 0),
			cameraIni:get(section, "POS_Z", 0)
		)
		camera.dir = cameraIni:get(section, "DIR", 0)
		camera.fov = cameraIni:get(section, "FOV", 0)
		table.insert(cameras, camera)
	end
end

function public.cameras()
	if firstLoad then
		getCameras()
		firstLoad = false
	end
	for i = 1, #cameras do		
		local h = math.rad(cameras[i].dir + ac.getCompassAngle(vec3(0, 0, 1)))
		if ui.button(cameras[i].name) then
			ac.setCurrentCamera(ac.CameraMode.Free) 
			ac.setCameraPosition(cameras[i].pos)
			ac.setCameraDirection(vec3(math.sin(h), 0, math.cos(h))) 
			ac.setCameraFOV(cameras[i].fov)
		end
	end
	if ac.getSim().cameraMode == ac.CameraMode.Free then
        if ui.button('Return to Car') then ac.setCurrentCamera(ac.CameraMode.Cockpit) end
    end
end

return public