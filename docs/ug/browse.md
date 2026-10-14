# Browse Screen

The Browse screen is nextp8's file manager and launcher. It lets you navigate directories, view cart previews, and launch games.

## Accessing the Browse Screen

- When nextp8 starts, it automatically displays the Browse screen
- Press **Break** / **Esc** from the Editor or REPL to return to Browse

## Main Interface

The Browse screen shows a scrollable list of files and directories in the current folder. Files and directories are displayed in alphabetical order, with directories listed first.

### File List

Each line in the list shows:
- The filename
- A `<DIR>` suffix for directories

Example:
```
CART1.P8
CART2.P8
<DIR> GAMES
<DIR> DEMOS
```

### Button Keys

You can press any of these keys for button 1 (ACTION1):

- **Z**
- **N**
- **C**

Press the **X** key for button 2 (ACTION2).

## Navigation

### Moving Through the List

| Key/Action | Description |
|------------|-------------|
| **Up Arrow** | Move selection up through the list |
| **Down Arrow** | Move selection up through the list |
| **True Video** / **Page Up** | Scroll up a page |
| **Inv Video** / **Page Down** | Scroll down a page |

## Actions

### Launching a Cart

1. Navigate to a `.P8` cart file using the arrow keys
2. Press **Enter** / **Return**
3. The cart will load and run immediately

### Entering a Directory

1. Navigate to a directory (shown with `<DIR>` suffix)
2. Press **Enter** / **Return**
3. The list updates to show the directory's contents
4. The path in the title bar updates to reflect the current directory

### Going to Parent Directory

- Navigate to the parent directory entry (`..`) at the top of the list
- Press **Enter** to move up one level

### Launching the Menu

Press **Button 2 (X)** to open the context menu. The menu options include:

| Menu Item | Description |
|-----------|-------------|
| **EDIT CART** | Opens the selected cart in the Editor for modification |
| **BBS DOWNLOAD** | Downloads a cart from the BBS (if Wi-Fi is configured) |
| **WI-FI CONFIG** | Configures Wi-Fi connection |
| **SHOW VERSION** | Displays the nextp8 firmware version |
| **CONTROLS** | Shows current control bindings |
| **BACK** | Returns to the file list |

## Tips and Tricks

### Edit a Cart

1. Press **X** to open the menu
2. Select "Edit cart" to immediately edit the highlighted cart

### BBS Download

To download a cart from the BBS:

1. Press **X** to open the menu
2. Select "BBS DOWNLOAD"
3. Enter the cart ID (`#ID` format)
4. The cart downloads to the current directory and launches

### Wi-Fi Configuration

On nextp8 hardware:

1. Press **X** to open the menu
2. Select "WI-FI CONFIG"
3. Select your network from the list
4. Enter your password
5. Connection is tested automatically

### Managing Multiple Carts

- Organize carts into directories by game type or creator
- Use the browse screen's directory navigation to switch between collections
- Edit carts directly from the browse screen
