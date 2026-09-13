# SteamPortLK

A Steam Deck–targeted controller addon for **World of Warcraft - Wrath of the Lich King (3.3.5a)**, built as a learning exercise in Lua and a more focused port of the [ConsolePortLK](https://github.com/leoaviana/ConsolePortLK) baseline.

## Status

Early scaffold. Three modules are stubbed against the ConsolePortLK patterns:

| Module | Path | Responsibility |
| --- | --- | --- |
| **Button config + display** | `ButtonConfig/SteamDeck.lua`, `ButtonConfig/Display.lua` | Steam Deck button layout, ABXY colors, blueprint placement, and a config panel listing each button's bound actions per modifier layer |
| **Camera** | `Camera/Camera.lua` | Camera cvar loading, throttled zoom driver, and right-stick yaw/pitch steering |
| **Binding handler** | `Bindings/Bindings.xml`, `Bindings/Bindings.lua` | Registers the `CP_*` bind names and routes button presses through a modifier-aware action resolver |

## Layout

```
SteamPortLK/
  SteamPortLK.toc        addon manifest (loaded by the 3.3.5a client)
  Init.lua               namespace bootstrap + slash commands (/splk)
  Bindings/
    Bindings.xml         CP_* binding name registration + handler bodies
    Bindings.lua         modifier-aware action resolver + cursor toggle
  Camera/
    Camera.lua           cvars, zoom driver, right-stick steering
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
```

## Notes

- This is a learning project. WoW 3.3.5a uses Lua 5.1; the Lua sources here are validated with `luac5.1 -p`.
- The Steam Deck's extra back-grip buttons (L4/R4/L5/R5) are mapped to `CP_T3`–`CP_T6`, mirroring the ConsolePortLK Steam Deck preset's four-trigger layout.
- A controller mapping tool (e.g. Steam Input or WoWpadX) is still required to translate physical buttons into the `CP_*` keybinds.

## License

See `LICENSE`.
