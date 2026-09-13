local _, db = ...

---------------------------------------------------------------
-- Steam Deck controller preset
--
-- Mirrors ConsolePortLK's Controllers/STEAMDECK/SteamDeck.lua but
-- is tailored for Steam Deck usage:
--   * Color  - hex codes for the ABXY face buttons (text + tint)
--   * Settings - default trigger/stick mapping to CP_* binding ids
--   * Layout - blueprint anchor + index per button for the display
--   * Bindings - default per-button actions across modifier layers
---------------------------------------------------------------

if not db.Controllers then db.Controllers = {} end

db.Controllers.STEAMDECK = {
	-- Help text shown when the user has not yet mapped keys on the Deck.
	Win = 'You must setup your keybindings in your Steam Deck layout.',
	Mac = 'You must setup your keybindings in your Steam Deck layout.',
	-- Link to a Steam controller layout community profile.
	LinkWin = 'https://steamcommunity.com/sharedfiles/filedetails/?id=2804823261',
	LinkMac = 'https://steamcommunity.com/sharedfiles/filedetails/?id=2804823261',
	Hide = false,

	-- Hex colors for the ABXY face buttons (used to tint text + cursor).
	Color = {
		['UP']    = 'FFE74F', -- Y (yellow)
		['LEFT']  = '00A2FF', -- X (blue)
		['RIGHT'] = 'FA4451', -- B (red)
		['DOWN']  = '52C14E', -- A (green)
	},

	-- Default mapping of the Steam Deck physical inputs to CP_* bind ids.
	-- Steam Deck has L4/R4 + L5/R5 grip buttons, hence the extra triggers.
	Settings = {
		['CP_M1']         = 'CP_TL2',      -- L2 full pull
		['CP_M2']         = 'CP_TR2',      -- R2 full pull
		['CP_T1']         = 'CP_TL1',      -- L1 / L bumper
		['CP_T2']         = 'CP_TR1',      -- R1 / R bumper
		['CP_T3']         = 'CP_L_GRIP1',  -- L4 back grip
		['CP_T4']         = 'CP_R_GRIP1',  -- R4 back grip
		['CP_T5']         = 'CP_L_GRIP2',  -- L5 back grip
		['CP_T6']         = 'CP_R_GRIP2',  -- R5 back grip
		['skipGuideBtn']  = false,
	},

	-- Blueprint placement used by the display module. `index` is the
	-- visual slot order within a side; negative means "hidden".
	Layout = {
		['CP_TL1']     = { index = 1, anchor = 'LEFT'  },
		['CP_TL2']     = { index = 2, anchor = 'LEFT'  },
		['CP_T_L3']    = { index = 3, anchor = 'LEFT'  },
		['CP_L_UP']    = { index = 4, anchor = 'LEFT'  },
		['CP_L_LEFT']  = { index = 5, anchor = 'LEFT'  },
		['CP_L_DOWN']  = { index = 6, anchor = 'LEFT'  },
		['CP_L_RIGHT'] = { index = 7, anchor = 'LEFT'  },
		['CP_X_LEFT']  = { index = 8, anchor = 'LEFT'  },
		['CP_L_GRIP1'] = { index = -1, anchor = 'LEFT' },
		['CP_L_GRIP2'] = { index = 10, anchor = 'LEFT' },

		['CP_TR1']     = { index = 1, anchor = 'RIGHT' },
		['CP_TR2']     = { index = 2, anchor = 'RIGHT' },
		['CP_R_UP']    = { index = 3, anchor = 'RIGHT' },
		['CP_R_RIGHT'] = { index = 4, anchor = 'RIGHT' },
		['CP_R_DOWN']  = { index = 5, anchor = 'RIGHT' },
		['CP_R_LEFT']  = { index = 6, anchor = 'RIGHT' },
		['CP_T_R3']    = { index = 7, anchor = 'RIGHT' },
		['CP_X_RIGHT'] = { index = 8, anchor = 'RIGHT' },
		['CP_R_GRIP1'] = { index = -1, anchor = 'RIGHT' },
		['CP_R_GRIP2'] = { index = 10, anchor = 'RIGHT' },
	},

	-- Default per-button actions keyed by modifier layer.
	Bind = {
		-- ABXY face buttons
		['CP_R_UP'] = {
			['']            = 'ACTIONBUTTON2',
			['SHIFT-']      = 'ACTIONBUTTON7',
			['CTRL-']       = 'MULTIACTIONBAR1BUTTON2',
			['CTRL-SHIFT-'] = 'MULTIACTIONBAR1BUTTON7',
		},
		['CP_R_DOWN'] = {
			['']            = 'JUMP',
			['SHIFT-']      = 'ACTIONBUTTON9',
			['CTRL-']       = 'EXTRAACTIONBUTTON1',
			['CTRL-SHIFT-'] = 'OPENALLBAGS',
		},
		['CP_R_LEFT'] = {
			['']            = 'ACTIONBUTTON1',
			['SHIFT-']      = 'ACTIONBUTTON6',
			['CTRL-']       = 'MULTIACTIONBAR1BUTTON1',
			['CTRL-SHIFT-'] = 'MULTIACTIONBAR1BUTTON6',
		},
		['CP_R_RIGHT'] = {
			['']            = 'ACTIONBUTTON3',
			['SHIFT-']      = 'ACTIONBUTTON8',
			['CTRL-']       = 'MULTIACTIONBAR1BUTTON3',
			['CTRL-SHIFT-'] = 'MULTIACTIONBAR1BUTTON8',
		},
		-- Bumpers / triggers
		['CP_T1'] = {
			['']            = 'ACTIONBUTTON4',
			['SHIFT-']      = 'TARGETNEARESTENEMY',
			['CTRL-']       = 'MULTIACTIONBAR1BUTTON4',
			['CTRL-SHIFT-'] = 'MULTIACTIONBAR1BUTTON9',
		},
		['CP_T2'] = {
			['']            = 'ACTIONBUTTON5',
			['SHIFT-']      = 'ACTIONBUTTON10',
			['CTRL-']       = 'MULTIACTIONBAR1BUTTON5',
			['CTRL-SHIFT-'] = 'MULTIACTIONBAR1BUTTON10',
		},
		-- D-Pad
		['CP_L_UP'] = {
			['']            = 'MULTIACTIONBAR1BUTTON12',
			['SHIFT-']      = 'MULTIACTIONBAR2BUTTON2',
			['CTRL-']       = 'MULTIACTIONBAR2BUTTON6',
			['CTRL-SHIFT-'] = 'MULTIACTIONBAR2BUTTON10',
		},
		['CP_L_DOWN'] = {
			['']            = 'ACTIONBUTTON11',
			['SHIFT-']      = 'MULTIACTIONBAR2BUTTON4',
			['CTRL-']       = 'MULTIACTIONBAR2BUTTON8',
			['CTRL-SHIFT-'] = 'MULTIACTIONBAR2BUTTON12',
		},
		['CP_L_LEFT'] = {
			['']            = 'MULTIACTIONBAR1BUTTON11',
			['SHIFT-']      = 'MULTIACTIONBAR2BUTTON1',
			['CTRL-']       = 'MULTIACTIONBAR2BUTTON5',
			['CTRL-SHIFT-'] = 'MULTIACTIONBAR2BUTTON9',
		},
		['CP_L_RIGHT'] = {
			['']            = 'ACTIONBUTTON12',
			['SHIFT-']      = 'MULTIACTIONBAR2BUTTON3',
			['CTRL-']       = 'MULTIACTIONBAR2BUTTON7',
			['CTRL-SHIFT-'] = 'MULTIACTIONBAR2BUTTON11',
		},
		-- Center (Select / Menu)
		['CP_X_LEFT'] = {
			['']            = 'TOGGLEWORLDMAP',
			['SHIFT-']      = 'OPENALLBAGS',
			['CTRL-']       = 'CP_CAMZOOMOUT',
			['CTRL-SHIFT-'] = 'CP_CAMZOOMIN',
		},
		['CP_X_RIGHT'] = {
			['']            = 'TOGGLEGAMEMENU',
			['SHIFT-']      = 'TOGGLEAUTORUN',
			['CTRL-']       = 'CP_TOGGLEMOUSE',
			['CTRL-SHIFT-'] = 'OPENCHAT',
		},
		-- Back grip buttons (L4/R4/L5/R5)
		['CP_T3'] = {
			['']            = 'MULTIACTIONBAR3BUTTON1',
			['SHIFT-']      = 'MULTIACTIONBAR3BUTTON2',
			['CTRL-']       = 'MULTIACTIONBAR3BUTTON3',
			['CTRL-SHIFT-'] = 'MULTIACTIONBAR3BUTTON4',
		},
		['CP_T4'] = {
			['']            = 'MULTIACTIONBAR3BUTTON5',
			['SHIFT-']      = 'MULTIACTIONBAR3BUTTON6',
			['CTRL-']       = 'MULTIACTIONBAR3BUTTON7',
			['CTRL-SHIFT-'] = 'MULTIACTIONBAR3BUTTON8',
		},
		['CP_T5'] = {
			['']            = 'MULTIACTIONBAR3BUTTON9',
			['SHIFT-']      = 'MULTIACTIONBAR3BUTTON10',
			['CTRL-']       = 'MULTIACTIONBAR3BUTTON11',
			['CTRL-SHIFT-'] = 'MULTIACTIONBAR3BUTTON12',
		},
		['CP_T6'] = {
			['']            = 'MULTIACTIONBAR4BUTTON1',
			['SHIFT-']      = 'MULTIACTIONBAR4BUTTON2',
			['CTRL-']       = 'MULTIACTIONBAR4BUTTON3',
			['CTRL-SHIFT-'] = 'MULTIACTIONBAR4BUTTON4',
		},
		-- Stick clicks
		['CP_T_R3'] = {},
		['CP_T_L3'] = {},
	},

	-- Buttons shared across controller types (true = part of default dpad cluster).
	Shared = {
		['CP_L_DOWN']  = true,
		['CP_L_LEFT']  = true,
		['CP_L_RIGHT'] = true,
		['CP_L_UP']    = true,
		['CP_L_GRIP']  = false,
		['CP_R_GRIP']  = false,
	},
}
