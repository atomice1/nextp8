# nextp8 User Guide

nextp8 is a PICO-8 compatible "core" for the ZX Spectrum Next. This user guide covers installation and using nextp8's features.

## Getting Started

- [Installation](install.md) - How to install nextp8 on your ZX Spectrum Next
- [Quick Start](#quick-start) - What to do after that

## Using nextp8

### Screens

nextp8 has three main screens that you'll use:

1. **Browse Screen** - File manager and cart launcher
   - [Browse Screen Guide](browse.md)
   
2. **Editor Screen** - Integrated development environment
   - [Editor Guide](editor.md)
   - Includes: Code, Sprite, Map, SFX, and Music editors
   
3. **REPL Screen** - Interactive Lua interpreter
   - [REPL Guide](repl.md)

### PICO-8 Compatibility

nextp8 aims for PICO-8 compatibility while running on real hardware:

- [PICO-8 Compatibility](../compatibility.md) - What's supported and what's not

## Quick Start

### First Boot

With the nextp8 core [installed](install.md):

1. Power on your ZX Spectrum Next
2. Wait until "Press C for extra cores" is displayed.
3. Press C
4. Select the nextp8 core using the up and down cursor keys
5. Press ENTER to start the core
6. nextp8 starts in the **Browse Screen**
7. Select a cart file and press **Enter** / **Return** to run it

### Creating a New Game

1. Press **Break** / **Esc** to enter the **Editor Screen**
2. Type your Lua code:
   ```lua
   FUNCTION _INIT()
   END
   
   FUNCTION UPDATE()
   END
   
   FUNCTION _DRAW()
       CLS()
       PRINT("HELLO, WORLD!")
   END
   ```
3. Press **Extend+R** / **Ctrl+R** to run your cart
4. Press **Extend+S** / **Ctrl+S** to save it

### Using the REPL

1. Press **Break** / **Esc** from the Editor to open the **REPL Screen**
2. Try some commands:
   ```lua
   > CLD()
   > PRINT("TESTING REPL")
   > FOR I=1,5 DO PRINT(I) END
   ```
3. Press **Break** / **Esc** to return to the Editor

### Loading a Cart from BBS

1. In the **Browse Screen**, press **X** to open the menu
2. Select **BBS DOWNLOAD**
3. Enter the cart ID in `#ID` format
4. The cart downloads and launches automatically

## Keyboard Support

nextp8 supports both the built-in Next keyboard and PS/2 external keyboards with US layout.

To type characters that would normally need Extended mode (printed directly above the key bezel), press Caps Shift + Symbol Shift + the key simultaneously.

For example: to type `[` press Caps Shift + Symbol Shift + Y.

The Extended Mode key is used for keyboard shortcuts.

## Mouse Support

nextp8 supports a PS/2 mouse. A mouse is recommended when using the editors.

## Keyboard Shortcuts Reference

### Global

| Key | Action |
|-----|--------|
| **Break** / **Esc** | Switch between Browse/Editor/REPL screens |
| **Extend+1** / **F1-F5** (PS/2 keyboard only) | Switch editor tabs (Code, Sprite, Map, SFX, Music) |
| **Extend+6** / **F6** (PS/2 keyboard only) | Quit Editor, return to Browse |
| **Extend+7** / **F7** (PS/2 keyboard only) | Open REPL |

### Editor

| Key | Action |
|-----|--------|
| **Extend+R** / **Ctrl+R** | Run cart |
| **Extend+S** / **Ctrl+S** | Save cart |
| **Extend+Z/Y** / **Ctrl+Z/Y** | Undo/Redo |

### Browse

| Key | Action |
|-----|--------|
| **Up/Down Arrow** | Navigate list |
| **Enter** / **Return** | Launch cart / enter directory |
| **X** | Open menu |

## Troubleshooting

### Cart won't run

- Check for [compatibility](../compatibility.md)
- [Report it on github](https://github.com/atomice1/nextp8/issues). Make sure to include the BBS cart ID or full download URL of the cart.

### Wi-Fi not connecting

- Press **X** in Browse to open menu
- Select **WI-FI CONFIG**
- Select your network and enter password
- Check connection status

## More Information

- [PICO-8 Compatibility](../compatibility.md)

## Feedback

nextp8 is an active project. For issues, feature requests, or questions:

- Check the [nextp8 GitHub repository](https://github.com/atomice1/nextp8)
- Review the [compatibility guide](../compatibility.md) for known limitations
