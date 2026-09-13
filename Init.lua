local addOn, db = ...

---------------------------------------------------------------
-- SteamPortLK
-- Steam Deck controller addon for WoW 3.3.5a.
-- Bootstraps the shared namespace consumed by the button
-- config, camera and binding modules.
---------------------------------------------------------------

SteamPortLK = SteamPortLK or {}
local Addon = SteamPortLK
Addon.db = db or {}

-- Top-level tables shared by every module.
db.Controllers = db.Controllers or {}
db.Camera      = db.Camera or {}
db.BindingSet   = db.BindingSet or {}

-- Modifier layers recognised by the binding driver, applied
-- in increasing order of precedence (later wins).
db.Modifiers = {
	'',
	'SHIFT-',
	'CTRL-',
	'CTRL-SHIFT-',
}

-- Convenience accessor mirroring ConsolePort's db(key, value) pattern.
function db:db(key, value)
	if value ~= nil then
		self[key] = value
		return value
	end
	return self[key]
end

local frame = CreateFrame('Frame')
Addon.frame = frame

frame:RegisterEvent('ADDON_LOADED')
frame:SetScript('OnEvent', function(self, event, loadedAddOn)
	if loadedAddOn == addOn then
		self:UnregisterEvent('ADDON_LOADED')
		if Addon.OnInitialize then
			Addon:OnInitialize()
		end
	end
end)

function Addon:OnInitialize()
	if Addon.ApplyCameraSettings then
		Addon:ApplyCameraSettings()
	end
	if Addon.RefreshDisplay then
		Addon:RefreshDisplay()
	end
	DEFAULT_CHAT_FRAME:AddMessage(
		'|cff739BD0SteamPortLK|r loaded. Configure your Steam Deck layout, then use /splk for commands.'
	)
end

---------------------------------------------------------------
-- Slash command surface
---------------------------------------------------------------
SLASH_STEAMPORTLK1 = '/splk'
SLASH_STEAMPORTLK2 = '/steamportlk'
SlashCmdList['STEAMPORTLK'] = function(msg)
	msg = (msg or ''):lower():gsub('^%s+', ''):gsub('%s+$', '')
	if msg == '' or msg == 'help' then
		DEFAULT_CHAT_FRAME:AddMessage('|cff739BD0SteamPortLK|r commands:')
		DEFAULT_CHAT_FRAME:AddMessage('  /splk config    - Open the button config display')
		DEFAULT_CHAT_FRAME:AddMessage('  /splk reload    - Reload the UI')
		DEFAULT_CHAT_FRAME:AddMessage('  /splk zoom in|out - Test camera zoom')
	elseif msg == 'config' then
		if Addon.OpenDisplay then
			Addon:OpenDisplay()
		else
			DEFAULT_CHAT_FRAME:AddMessage('Button config display not available.')
		end
	elseif msg == 'reload' then
		ReloadUI()
	elseif msg == 'zoom in' then
		if Addon.CameraZoom then Addon:CameraZoom(true, 1) end
	elseif msg == 'zoom out' then
		if Addon.CameraZoom then Addon:CameraZoom(true, -1) end
	else
		DEFAULT_CHAT_FRAME:AddMessage('Unknown SteamPortLK command: '..msg)
	end
end
