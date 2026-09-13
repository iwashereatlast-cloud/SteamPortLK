local _, db = ...
local Addon = SteamPortLK

---------------------------------------------------------------
-- Button config display
--
-- Builds a simple two-sided blueprint (LEFT / RIGHT) from the
-- active controller preset's Layout + Color tables and lists each
-- button's bound action across modifier layers. Opened via the
-- SteamPortLK:OpenDisplay() method (slash: /splk config).
---------------------------------------------------------------

local DISPLAY_WIDTH  = 420
local DISPLAY_HEIGHT = 360
local ROW_HEIGHT      = 18

-- Resolve the active preset. Defaults to STEAMDECK; users can set
-- SteamPortLKSettings.controller to switch presets later.
local function GetPreset()
	local key = (SteamPortLKSettings and SteamPortLKSettings.controller) or 'STEAMDECK'
	return db.Controllers[key] or db.Controllers.STEAMDECK, key
end

-- Group layout entries by anchor side, sorted by index.
local function GetOrderedLayout(preset)
	local sides = { LEFT = {}, RIGHT = {} }
	for bindId, info in pairs(preset.Layout or {}) do
		if info.index and info.index > 0 then
			local bucket = sides[info.anchor]
			if bucket then
				table.insert(bucket, { id = bindId, index = info.index })
			end
		end
	end
	for _, bucket in pairs(sides) do
		table.sort(bucket, function(a, b) return a.index < b.index end)
	end
	return sides
end

local function ColorText(text, hex)
	if not hex then return text end
	return '|cff' .. hex .. text .. '|r'
end

local display
function Addon:OpenDisplay()
	if display then display:Show() return end
	display = CreateFrame('Frame', 'SteamPortLKDisplay', UIParent)
	display:SetSize(DISPLAY_WIDTH, DISPLAY_HEIGHT)
	display:SetPoint('CENTER')
	display:SetBackdrop({
		bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
		edgeFile = 'Interface\\DialogFrame\\UI-DialogBox-Border',
		tile = true, tileSize = 32, edgeSize = 32,
		insets = { left = 11, right = 11, top = 12, bottom = 11 },
	})
	display:SetBackdropColor(0, 0, 0, 0.9)
	display:SetMovable(true)
	display:EnableMouse(true)
	display:RegisterForDrag('LeftButton')
	display:SetScript('OnDragStart', display.StartMoving)
	display:SetScript('OnDragStop', display.StopMovingOrSizing)

	local title = display:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
	title:SetPoint('TOP', 0, -16)
	title:SetText('|cff739BD0SteamPortLK|r - Button Config')

	local close = CreateFrame('Button', nil, display, 'UIPanelButtonTemplate')
	close:SetSize(80, 22)
	close:SetPoint('BOTTOMRIGHT', -16, 12)
	close:SetText(CLOSE or 'Close')
	close:SetScript('OnClick', function() display:Hide() end)

	local content = CreateFrame('ScrollFrame', nil, display, 'UIPanelScrollFrameTemplate')
	content:SetPoint('TOPLEFT', 16, -40)
	content:SetPoint('BOTTOMRIGHT', -36, 40)
	local scrollChild = CreateFrame('Frame', nil, content)
	scrollChild:SetWidth(DISPLAY_WIDTH - 60)
	content:SetScrollChild(scrollChild)
	display.scrollChild = scrollChild

	Addon:RefreshDisplay()
	display:Show()
end

function Addon:RefreshDisplay()
	if not display then return end
	local scrollChild = display.scrollChild
	for _, child in ipairs({ scrollChild:GetChildren() }) do
		child:Hide()
	end

	local preset, presetKey = GetPreset()
	local sides = GetOrderedLayout(preset)
	local bindings = preset.Bind or {}

	local y = 0
	local function AddLine(text, r, g, b)
		local line = scrollChild:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
		line:SetPoint('TOPLEFT', 0, -y)
		line:SetText(text)
		if r then line:SetTextColor(r, g, b) end
		y = y + ROW_HEIGHT
		return line
	end

	AddLine('Controller: ' .. presetKey, 0.45, 0.61, 0.82)

	for _, sideKey in ipairs({ 'LEFT', 'RIGHT' }) do
		AddLine('--- ' .. sideKey .. ' ---', 0.7, 0.7, 0.7)
		for _, entry in ipairs(sides[sideKey]) do
			local bindId = entry.id
			local faceColor
			if preset.Color then
				if bindId == 'CP_R_UP'    then faceColor = preset.Color['UP'] end
				if bindId == 'CP_R_DOWN'  then faceColor = preset.Color['DOWN'] end
				if bindId == 'CP_R_LEFT' then faceColor = preset.Color['LEFT'] end
				if bindId == 'CP_R_RIGHT' then faceColor = preset.Color['RIGHT'] end
			end
			AddLine(ColorText(bindId, faceColor))
			local layers = bindings[bindId]
			if layers then
				for _, mod in ipairs(db.Modifiers) do
					local action = layers[mod]
					if action then
						local modLabel = (mod == '') and '(none)' or mod:gsub('-$', '')
						AddLine(string.format('    %s -> %s', modLabel, action), 0.85, 0.85, 0.85)
					end
				end
			else
				AddLine('    (no default binding)', 0.5, 0.5, 0.5)
			end
		end
		y = y + 4
	end

	scrollChild:SetHeight(math.max(y, DISPLAY_HEIGHT - 80))
end
