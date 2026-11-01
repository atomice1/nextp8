# Running Carts

Once you've selected a cart in the Browse screen or typed RUN in the REPL screen, nextp8 will load and run it.

## Controls

### Player 1 Controls

| Key | Action |
|-----|--------|
| **Arrow Keys** | Directional controls |
| **Z, C, N** | Button 1 (ACTION1) |
| **X, M, V** | Button 2 (ACTION2) |

### Player 2 Controls

| Key | Action |
|-----|--------|
| **S, D, E, F** | Directional controls |
| **Tab, Shift** | Button 1 (ACTION1) |
| **Q, A** | Button 2 (ACTION2) |

### General Controls

| Key | Action |
|-----|--------|
| **P** or **Enter** | Pause the cart |

## Pause Menu

When a cart is running, press **P** or **Enter** to pause. The pause menu shows:

| Menu Item | Description |
|-----------|-------------|
| **CONTINUE** | Resume the cart |
| *[Custom menu items]* | Cart-specific |
| **RESTART** | Restart the cart from the beginning |
| **SHOW VERSION** | Display nextp8 firmware version |
| **CONTROLS** | Show keyboard controls reference card |
| **OPTIONS** | Configure volume and autosave settings |
| **QUIT** | Return to the Browse screen |

## Compatibility

nextp8 aims for PICO-8 compatibility, but there are some differences:

- See the [PICO-8 Compatibility Guide](../compatibility.md) for details on what's supported and what's not

## Launching from BBS

To download and run a cart directly from the BBS:

1. In the Browse screen, press **X** to open the menu
2. Select **BBS DOWNLOAD**
3. Enter the cart ID in `#ID` format
4. The cart downloads and launches automatically

Note: Wi-Fi must be configured for BBS download to work.
