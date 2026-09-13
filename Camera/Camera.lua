local _, db = ...
local Addon = SteamPortLK

---------------------------------------------------------------
-- Camera module
--
-- Handles camera steering (right-stick yaw/pitch) and zoom for the
-- Steam Deck. Mirrors ConsolePortLK's Core/Camera.lua for cvar
-- loading and the throttled zoom driver, and adds a right-stick
-- steering loop driven by the CP_STEER_* bindings.
---------------------------------------------------------------

db.Camera = db.Camera or {}
db.Camera.Settings = db.Camera.Settings or {
	-- WoW 3.3.5a camera cvars applied on init (overridable in SavedVars).
	cameraYawMoveSpeed       = 230,
	cameraPitchMoveSpeed     = 230,
	cameraSmoothPitch        = 1,
	cameraSmoothYaw          = 1,
	cameraSmoothStyle        = 1,
	cameraWaterHead          = 0,
	cameraYawSmoothSpeed     = 180,
	cameraDistanceMax       = 30,
	cameraDistanceMaxFactor  = 1.6,
	cameraFovMax             = 1.25,
	cameraFovMin             = 0.15,
	test_cameraOverShoulder  = 0,
}

-- Steering sensitivity; multiplied into the per-frame yaw/pitch delta.
db.Camera.Steer = db.Camera.Steer or {
	yaw   = 0.18,   -- horizontal (right-stick X) -> yaw degrees/frame
	pitch = 0.12,   -- vertical   (right-stick Y) -> pitch degrees/frame
	invertPitch = false,
}

local steerX, steerY = 0, 0

---------------------------------------------------------------
-- Cvar loading (mirrors ConsolePort:LoadCameraSettings)
---------------------------------------------------------------
function Addon:ApplyCameraSettings()
	if not db.Camera or not db.Camera.Settings then return end
	for cvar, val in pairs(db.Camera.Settings) do
		if GetCVar(cvar) ~= nil then
			local success = pcall(ConsoleExec, (cvar .. ' ' .. tostring(val)))
			if not success then
				DEFAULT_CHAT_FRAME:AddMessage('SteamPortLK: attempted to modify missing cvar: ' .. cvar)
			end
		end
	end
end

---------------------------------------------------------------
-- Throttled zoom driver (mirrors ConsolePort's ZoomHandler)
---------------------------------------------------------------
local ZoomHandler = CreateFrame('Frame')
local zoomDelta, zoomIteration, zoomModReduction = 0, 1, 1
ZoomHandler:Hide()
ZoomHandler:SetScript('OnUpdate', function(self)
	if (zoomModReduction % 7) == 1 then
		if zoomDelta > 0 then
			CameraZoomIn(zoomIteration)
		elseif zoomDelta < 0 then
			CameraZoomOut(zoomIteration)
		end
		zoomIteration = zoomIteration + 1
	end
	zoomModReduction = zoomModReduction + 1
end)

function Addon:CameraZoom(isZooming, delta)
	if isZooming and delta and delta ~= 0 then
		zoomDelta = delta
		zoomIteration = 1
		zoomModReduction = 1
		ZoomHandler:Show()
	else
		ZoomHandler:Hide()
		zoomDelta, zoomIteration, zoomModReduction = 0, 1, 1
	end
end

---------------------------------------------------------------
-- Right-stick steering
--
-- The Steam Deck right stick feeds values via CP_STEER_HORZ /
-- CP_STEER_VERT bindings (registered as analog runOnUp bindings in
-- Bindings.xml). Each call updates the live axis value; an OnUpdate
-- loop applies yaw/pitch while a non-zero axis is held.
---------------------------------------------------------------
local SteerHandler = CreateFrame('Frame')
SteerHandler:Hide()
SteerHandler:SetScript('OnUpdate', function(self)
	if steerX == 0 and steerY == 0 then
		self:Hide()
		return
	end
	local cfg = db.Camera.Steer
	local yaw = steerX * cfg.yaw
	local pitch = steerY * cfg.pitch
	if cfg.invertPitch then pitch = -pitch end
	if yaw ~= 0 then
		CameraOrSelectOrMoveStop()
		TurnOrActionStop()
		MoveCameraYaw(yaw)
	end
	if pitch ~= 0 then
		MoveCameraPitch(pitch)
	end
end)

function Addon:SetSteerAxis(axis, value)
	value = tonumber(value) or 0
	if axis == 'HORZ' then
		steerX = value
	elseif axis == 'VERT' then
		steerY = value
	end
	if steerX ~= 0 or steerY ~= 0 then
		SteerHandler:Show()
	end
end

-- Called by CP_STEER_STOP binding when the stick returns to centre.
function Addon:StopSteer()
	steerX, steerY = 0, 0
	SteerHandler:Hide()
end

---------------------------------------------------------------
-- Look-behind toggle (mirrors CP_CAMLOOKBEHIND)
---------------------------------------------------------------
function Addon:LookBehind(state)
	if state then
		FlipCameraYaw(180)
	else
		FlipCameraYaw(180)
	end
end
