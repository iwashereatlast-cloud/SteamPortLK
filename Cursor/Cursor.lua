local _, db = ...
local Addon = SteamPortLK

---------------------------------------------------------------
-- Virtual cursor driver
--
-- A self-contained gamepad cursor for the Steam Deck. When toggled
-- on (CP_TOGGLEMOUSE), a movable arrow overlay appears and is driven
-- by analog bindings (CP_CURSOR_X / CP_CURSOR_Y) plus click bindings
-- (CP_CURSOR_LEFT / CP_CURSOR_RIGHT).
--
--  * Left click   -> forward a LeftButton click to the frame under
--                    the cursor (UI), or TargetUnit('mouseover').
--  * Right click  -> forward a RightButton click to the frame under
--                    the cursor, or InteractUnit('mouseover').
--
-- Movement is clamped to the screen; speed scales with axis value.
---------------------------------------------------------------

db.Cursor = db.Cursor or {
	speed    = 800,  -- pixels per second at full deflection
	size     = 24,   -- cursor texture size
	texture  = 'Interface\\Cursor\\Point',
}

local cursorX, cursorY = 0, 0
local axisX, axisY = 0, 0
local active = false

local cursorFrame
local driver

local function GetScreenSize()
	local uiScale = UIParent:GetEffectiveScale() or 1
	local width  = GetScreenWidth()  or 1920
	local height = GetScreenHeight() or 1080
	return width * uiScale, height * uiScale
end

local function CreateCursor()
	cursorFrame = CreateFrame('Frame', 'SteamPortLKCursor', UIParent)
	cursorFrame:SetFrameStrata('TOOLTIP')
	cursorFrame:SetSize(db.Cursor.size, db.Cursor.size)
	local tex = cursorFrame:CreateTexture(nil, 'OVERLAY')
	tex:SetTexture(db.Cursor.texture)
	tex:SetAllPoints()
	cursorFrame.texture = tex
	cursorFrame:Hide()

	driver = CreateFrame('Frame')
	driver:Hide()
	driver:SetScript('OnUpdate', function(self, elapsed)
		if not active then self:Hide() return end
		local cfg = db.Cursor
		local dx = axisX * cfg.speed * elapsed
		local dy = axisY * cfg.speed * elapsed
		if dx == 0 and dy == 0 then return end
		cursorX = cursorX + dx
		cursorY = cursorY - dy -- screen Y is inverted relative to stick up

		local sw, sh = GetScreenSize()
		cursorX = math.max(0, math.min(sw, cursorX))
		cursorY = math.max(0, math.min(sh, cursorY))

		cursorFrame:ClearAllPoints()
		cursorFrame:SetPoint('BOTTOMLEFT', UIParent, 'BOTTOMLEFT', cursorX, cursorY)
	end)
end

---------------------------------------------------------------
-- Toggle / show / hide
---------------------------------------------------------------
function Addon:ToggleCursor()
	if not cursorFrame then CreateCursor() end
	active = not active
	if active then
		local sw, sh = GetScreenSize()
		if cursorX == 0 and cursorY == 0 then
			cursorX, cursorY = sw / 2, sh / 2
		end
		cursorFrame:ClearAllPoints()
		cursorFrame:SetPoint('BOTTOMLEFT', UIParent, 'BOTTOMLEFT', cursorX, cursorY)
		cursorFrame:Show()
		driver:Show()
		-- Release mouselook so the OS cursor / UI is usable.
		CameraOrSelectOrMoveStop()
		TurnOrActionStop()
		DEFAULT_CHAT_FRAME:AddMessage('|cff739BD0SteamPortLK|r cursor: ON')
	else
		cursorFrame:Hide()
		driver:Hide()
		axisX, axisY = 0, 0
		DEFAULT_CHAT_FRAME:AddMessage('|cff739BD0SteamPortLK|r cursor: OFF')
	end
end

function Addon:IsCursorActive()
	return active
end

---------------------------------------------------------------
-- Analog movement
---------------------------------------------------------------
function Addon:SetCursorAxis(axis, value)
	value = tonumber(value) or 0
	if not cursorFrame then CreateCursor() end
	if axis == 'X' then
		axisX = value
	elseif axis == 'Y' then
		axisY = value
	end
	if active and (axisX ~= 0 or axisY ~= 0) then
		driver:Show()
	end
end

function Addon:StopCursor()
	axisX, axisY = 0, 0
end

---------------------------------------------------------------
-- Click dispatch
--
-- Find the frame under the cursor and forward the click. Frames
-- without an OnClick fall through to world interactions.
---------------------------------------------------------------
local function GetFrameUnderCursor()
	if not active then return nil end
	local uiScale = UIParent:GetEffectiveScale() or 1
	local x, y = cursorX / uiScale, cursorY / uiScale
	-- GetMouseFocus returns the frame currently under the OS cursor;
	-- since we drive a virtual cursor, we replicate it by checking
	-- frames against our stored position when no OS hover exists.
	local focus = GetMouseFocus and GetMouseFocus()
	if focus and focus ~= WorldFrame then return focus end
	return WorldFrame
end

function Addon:CursorClick(button)
	if not active then
		DEFAULT_CHAT_FRAME:AddMessage('|cff739BD0SteamPortLK|r cursor is off.')
		return
	end
	local frame = GetFrameUnderCursor()
	if frame and frame:IsObjectType('Button') and frame:GetScript('OnClick') then
		-- Forward the click to the UI button.
		local ok = pcall(frame:GetScript('OnClick'), frame, button, false)
		if not ok and DEFAULT_CHAT_FRAME then
			DEFAULT_CHAT_FRAME:AddMessage('SteamPortLK: failed to click ' .. tostring(frame:GetName() or 'frame'))
		end
		return
	end
	-- No clickable UI under the cursor -> world interaction.
	if frame == WorldFrame then
		if button == 'LeftButton' then
			if UnitExists('mouseover') then
				TargetUnit('mouseover')
			end
		elseif button == 'RightButton' then
			if UnitExists('mouseover') then
				InteractUnit('mouseover')
			end
		end
	end
end
