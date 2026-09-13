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

-- Execute an action string.
--  * Tokens beginning with "CLICK " dispatch a frame OnClick via RunMacroText.
--  * Tokens that look like slash commands (start with "/") run as macros.
--  * Anything else is treated as a WoW binding token (ACTIONBUTTON1, JUMP, ...)
--    and dispatched via RunBinding.
function Addon:RunAction(action)
	if not action or action == '' then return end
	if action:sub(1, 6) == 'CLICK ' then
		local ok = pcall(RunMacroText, action)
		if not ok and DEFAULT_CHAT_FRAME then
			DEFAULT_CHAT_FRAME:AddMessage('SteamPortLK: could not click ' .. action)
		end
		return
	end
	if action:sub(1, 1) == '/' then
		local ok = pcall(RunMacroText, action)
		if not ok and DEFAULT_CHAT_FRAME then
			DEFAULT_CHAT_FRAME:AddMessage('SteamPortLK: could not run ' .. action)
		end
		return
	end
	-- WoW binding token (ACTIONBUTTON1, JUMP, TARGETNEARESTENEMY, OPENCHAT, ...)
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

-- Virtual cursor driver lives in Cursor/Cursor.lua; this module
-- only references Addon:ToggleCursor / SetCursorAxis / CursorClick
-- from the binding bodies defined in Bindings.xml.
