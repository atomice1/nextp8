# Installing nextp8

nextp8 is a fantasy console "core" for the ZX Spectrum Next Issue5 / KS3, implementing a PICO-8 compatible environment.

## Hardware Requirements

- ZX Spectrum Next Issue 5 / KS3
- SD card (minimum 4MB free space)

Note: Issue2 / KS1 and Issue 5 / KS2 are *not* supported.

## Installation Steps

### 1. Download the release zip file.

nextp8 is still under active development and targeted at the unreleased KS3 Next hardware. As such, there is no official FPGA download available yet. Check the [nextp8 GitHub repository](https://github.com/atomice1/nextp8) for the latest status and available downloads.

### 2. Install to SD Card

1. Extract the `nextp8.zip` file to the root of your SD card
2. Insert the SD card into your ZX Spectrum Next

### 3. Flash (install) the core

1. Power on your ZX Spectrum Next
2. Wait until "Press C for extra cores" is displayed.
3. Press C
4. Select an empty core slot using the up and down cursor keys
5. Press SPACE
6. Select the nextp8 core using the up and down cursor keys
7. Press ENTER to flash (install) the core

### 4. Start the Core

1. Power on your ZX Spectrum Next
2. Wait until "Press C for extra cores" is displayed.
3. Press C
4. Select the nextp8 core using the up and down cursor keys
5. Press ENTER to start the core

## Getting Started

Once nextp8 is running:

1. Use the up and down cursor keys and ENTER to select a cart in the cart browser
2. Press **Break** / **Esc** in the browser to enter the editor
3. Explore the built-in editor to create or modify games
4. Press **Extend+R** / **Ctrl+R** to run your cart from the editor
5. Use **Extend+7 / F7** to open the REPL for interactive Lua programming (F7 has no Next equivalent)

For more information on using nextp8, see the other guides in this documentation:

- [Browse Screen](browse.md) - How to navigate and load carts
- [Editor Screens](editor.md) - Using the built-in editor
- [REPL Screen](repl.md) - Interactive Lua programming

## Compatibility

nextp8 aims for PICO-8 compatibility. See the [PICO-8 Compatibility](../compatibility.md) guide for details on what features are supported and any limitations.
