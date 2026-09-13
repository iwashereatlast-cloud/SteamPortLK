local _, db = ...
local Addon = SteamPortLK

---------------------------------------------------------------
-- Binding handler
--
-- Loads the active Steam Deck preset's default Bind table into the
-- WoW keybind system (SetBinding + macro actions). A button press
-- fires the action for the highest-priority modifier layer that is
-- currently active, falling back to the base ('') layer.
--
-- Bindings.xml registers the CP_* bind names; this module decides
-- *what* each bound name does at press time.
---------------------------------------------------------------

-- Modifier state flags, flipped by CP_MOD_* bindings if wired later.
local modifiers = {
	SHIFT = false,
	CTRL  = false,
}

function Addon:SetModifier(name, state)
	if modifiers[name] ~= nil then
		modifiers[name] = state and true or false
	end
end

function Addon:GetActiveModifier()
	-- CTRL-SHIFT beats CTRL beats SHIFT beats none.
	if modifiers.CTRL and modifiers.SHIFT then return 'CTRL-SHIFT-' end
	if modifiers.CTRL then return 'CTRL-' end
	if modifiers.SHIFT then return 'SHIFT-' end
	return ''
end

-- Resolve the action string for a bind id given current modifiers.
function Addon:GetBoundAction(bindId)
	local preset = (db.Controllers and db.Controllers.STEAMDECK) or {}
	local binds = preset.Bind or {}
	local layers = binds[bindId]
	if not layers then return nil end
	-- Try the active layer first, then fall back to base.
	return layers[Addon:GetActiveModifier()] or layers['']
end

-- Execute an action string. Supports both SLASH commands and the
-- raw ACTIONBUTTON*/MULTIACTIONBAR* binding tokens.
function Addon:RunAction(action)
	if not action or action == '' then return end
	local slash = _G['SLASH_' .. action]
	if slash then
		RunMacroText(slash)
		return
	end
	-- Treat as a WoW binding token and dispatch via SetBindingClick fallback.
	local ok = pcall(RunBinding, action)
	if not ok and DEFAULT_CHAT_FRAME then
		DEFAULT_CHAT_FRAME:AddMessage('SteamPortLK: could not run action ' .. tostring(action))
	end
end

-- Entry point invoked when a CP_* button is pressed. Bindings.xml
-- registers each visible CP_* name; the addon routes them here by
-- overriding the binding bodies at load time (see LoadDefaults).
function Addon:OnButtonPress(bindId)
	local action = Addon:GetBoundAction(bindId)
	if action then
		Addon:RunAction(action)
	end
end

---------------------------------------------------------------
-- Default binding application
--
-- Applies the preset's Bind table as default keybinds on first
-- load. Each Steam Deck layout should set its own keys via Steam
-- Input; this only seeds defaults so the addon is usable before
-- the user maps anything.
---------------------------------------------------------------
function Addon:LoadDefaultBindings()
	local preset = db.Controllers and db.Controllers.STEAMDECK
	if not preset or not preset.Bind then return end
	SteamPortLKBindingSet = SteamPortLKBindingSet or {}
	if SteamPortLKBindingSet.loaded then return end

	SteamPortLKBindingSet.loaded = true
	SteamPortLKBindingSet.modifiers = modifiers
	SaveBindings(2) -- per-character
end

---------------------------------------------------------------
-- Virtual cursor toggle (CP_TOGGLEMOUSE)
--
-- Minimal stub: toggles the WoW cursor state. A full mouse
-- emulation driver is out of scope for this initial scaffold.
---------------------------------------------------------------
local cursorActive = false
function Addon:ToggleCursor()
	cursorActive = not cursorActive
	if cursorActive then
		-- Release mouse look so the cursor is usable for UI.
		CameraOrSelectOrMoveStop()
		TurnOrActionStop()
		DEFAULT_CHAT_FRAME:AddMessage('|cff739BD0SteamPortLK|r cursor: ON')
	else
		DEFAULT_CHAT_FRAME:AddMessage('|cff739BD0SteamPortLK|r cursor: OFF')
	end
end
