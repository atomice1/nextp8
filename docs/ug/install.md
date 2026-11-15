# Installing nextp8

nextp8 is a fantasy console "core" for the ZX Spectrum Next Issue5 / KS3, implementing a PICO-8 compatible environment.

## Hardware Requirements

- ZX Spectrum Next Issue 5 / KS3
- SD card (minimum 4MB free space on target)
- A second SD card with the nextp8 release files (source)

Note: Issue2 / KS1 and Issue 5 / KS2 are *not* supported.

## Installation Overview

The nextp8 installation program (`install-nextp8.bas`) copies the core files from an external SD card to the internal SD card. It automatically detects the source drive, validates the target, and copies all necessary files.

## Installation Steps

### 1. Prepare the Source SD Card

1. On a PC/Mac, unzip the nextp8 release .zip file onto an SD card (must be FAT32 formatted)
2. Verify that `install-nextp8.bas` is in the root directory of the SD card

### 2. Run the Installation Program

1. Insert the source SD card into the ZX Spectrum Next
2. Power on the Next and wait for the "Press C for extra cores" screen
3. Press **C** to open the core browser
4. Press **D** to change to the SD card drive
5. Select `install-nextp8.bas` and press **ENTER**
6. The installer will detect the source drive and prompt for confirmation
9. Press Y to confirm and install
10. Wait for the installation to complete
11. Press Y to confirm and reset

The core will now be available in the core browser but it still needs installing to an available slot.

### 3. Install the Core

1. Power on your ZX Spectrum Next
2. Wait until "Press C for extra cores" is displayed.
3. Press C
4. Select the nextp8 core using the left and right cursor keys
5. Press ENTER
6. Select *Flash in an available slot* and press **ENTER**
7. Select a slot and press **ENTER**
8. Press Y to confirm and install

## Reinstalling or Updating

To reinstall or update nextp8:

1. Run the installation program as described above
2. If nextp8 is already installed, you'll be prompted to confirm overwrite
3. Press **Y** to overwrite, or any other key to cancel

## Getting Started

Once nextp8 is installed and running:

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
