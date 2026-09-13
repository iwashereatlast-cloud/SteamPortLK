# SteamPortLK

A Steam Deck–targeted controller addon for **World of Warcraft - Wrath of the Lich King (3.3.5a)**, built as a learning exercise in Lua and a more focused port of the [ConsolePortLK](https://github.com/leoaviana/ConsolePortLK) baseline.

## Status

Early scaffold. Three modules are stubbed against the ConsolePortLK patterns:

| Module | Path | Responsibility |
| --- | --- | --- |
| **Button config + display** | `ButtonConfig/SteamDeck.lua`, `ButtonConfig/Display.lua` | Steam Deck button layout, ABXY colors, blueprint placement, and a config panel listing each button's bound actions per modifier layer |
| **Camera** | `Camera/Camera.lua` | Camera cvar loading, throttled zoom driver, and right-stick yaw/pitch steering |
| **Binding handler** | `Bindings/Bindings.xml`, `Bindings/Bindings.lua` | Registers the `CP_*` bind names, routes each button press through `OnButtonPress`, and resolves the action for the active modifier layer (`''` / `SHIFT-` / `CTRL-` / `CTRL-SHIFT-`) |
| **Virtual cursor** | `Cursor/Cursor.lua` | A gamepad-driven cursor overlay (`CP_TOGGLEMOUSE`) moved by analog sticks (`CP_CURSOR_X/Y`) with left/right-click dispatch to UI or world targets |

## Layout

```
SteamPortLK/
  SteamPortLK.toc        addon manifest (loaded by the 3.3.5a client)
  Init.lua               namespace bootstrap + slash commands (/splk)
  Bindings/
    Bindings.xml         CP_* binding name registration + handler bodies
    Bindings.lua         modifier-aware action resolver + OnButtonPress
  Camera/
    Camera.lua           cvars, zoom driver, right-stick steering
  Cursor/
    Cursor.lua           gamepad-driven virtual cursor + click dispatch
  ButtonConfig/
    SteamDeck.lua        Steam Deck preset (Color / Settings / Layout / Bind)
    Display.lua          two-sided blueprint + binding list window
```

## Commands

```
/splk            Show available commands
/splk config     Open the button config display
/splk reload     Reload the UI
/splk zoom in    Trigger a camera zoom-in (test)
/splk zoom out   Trigger a camera zoom-out (test)
/splk cursor     Toggle the virtual cursor on/off
```

### Controller bindings (set via Steam Input / WoWpadX)

| Bind | Action |
| --- | --- |
| `CP_R_*` / `CP_L_*` / `CP_T1`–`CP_T6` / `CP_X_*` | Face / D-pad / triggers+grips / center buttons → routed through the modifier-aware action resolver |
| `CP_STEER_HORZ/VERT` | Right-stick analog camera steering |
| `CP_ZOOMIN_HOLD` / `CP_ZOOMOUT_HOLD` | Hold-to-zoom (throttled) |
| `CP_TOGGLEMOUSE` | Toggle the virtual cursor |
| `CP_CURSOR_X/Y` | Left-stick analog cursor movement |
| `CP_CURSOR_LEFT/RIGHT` | Virtual cursor click / right-click |

## Notes

- This is a learning project. WoW 3.3.5a uses Lua 5.1; the Lua sources here are validated with `luac5.1 -p`.
- The Steam Deck's extra back-grip buttons (L4/R4/L5/R5) are mapped to `CP_T3`–`CP_T6`, mirroring the ConsolePortLK Steam Deck preset's four-trigger layout.
- A controller mapping tool (e.g. Steam Input or WoWpadX) is still required to translate physical buttons into the `CP_*` keybinds.

## License

See `LICENSE`.
