# Editor Screens

The Editor is nextp8's integrated development environment for creating and modifying carts. Access it by pressing **Break** / **Esc** from the Browse screen or REPL.

## Accessing the Editor

- Press **Break** / **Esc** from the Browse screen to enter the Editor
- Press **Extend+6** / **F6** to quit the Editor and return to Browse

## Editor Tabs

The Editor has five tabs across the top of the screen. Each tab handles a different aspect of a PICO-8 cart:

| Tab | Shortcut | Description |
|-----|-------------------------------|-------------|
| **CODE** | **Extend+1 / F1** | Lua source code editor |
| **SPRITE** | **Extend+2 / F2** | Sprite editor for 8x8 pixel graphics |
| **MAP** | **Extend+3 / F3** | Tile map editor |
| **SFX** | **Extend+4 / F4** | Sound effects editor |
| **MUSIC** | **Extend+5 / F5** | Music pattern editor |

### Switching Tabs

- Click on a tab with the mouse, or
- Press the corresponding function key (F1-F5)

The active tab is highlighted with yellow background and dark blue text. Tab labels are 3 characters wide with 2px spacing between them.

## Global Editor Shortcuts

| Key | Action |
|-----|--------|
| **Extend+1** / **F1** | Switch to CODE tab |
| **Extend+2** / **F2** | Switch to SPRITE tab |
| **Extend+3** / **F3** | Switch to MAP tab |
| **Extend+4** / **F4** | Switch to SFX tab |
| **Extend+5** / **F5** | Switch to MUSIC tab |
| **Extend+6** / **F6** | Quit editor (return to Browse) |
| **Extend+7** / **F7** | Open REPL |
| **Extend+R** / **Ctrl+R** | Run the current cart |
| **Extend+S** / **Ctrl+S** | Save the current cart |
| **Extend+A** / **Ctrl+A** | Save As |
| **Extend+Z** / **Ctrl+Z** | Undo (tab-local) |
| **Extend+Y** / **Ctrl+Y** | Redo (tab-local) |

## CODE Tab

The Code Editor displays and edits the Lua source code for your cart.

### Navigation

| Key | Action |
|-----|--------|
| **Arrow keys** | Move cursor one character/line |
| **Extend+Left/Right** / **Ctrl+Left/Right** | Move one word left/right |
| **Extend+SymShift+2** / **Home** | Move to start of line |
| **Extend+M** / **End** | Move to end of line |
| **True Video** / **PgUp** | Scroll up one page |
| **Inv Video** / **PgDn** | Scroll down one page |
| **Ctrl+Home** | Jump to first line |
| **Ctrl+End** | Jump to last line |

### Selection

Hold **Shift** with navigation keys to extend the selection:

- **Shift+Arrow** | Extend selection by character/line
- **Shift+Extend+Left/Right** / **Shift+Ctrl+Left/Right** | Extend by word
- **Shift+Home/End** | Extend to line start/end
- **Shift+True Video/Inv Video** / **Shift+PgUp/PgDn** | Extend by page

### Editing

| Key | Action |
|-----|--------|
| **Type characters** | Insert at cursor position |
| **Delete** / **Backspace** | Delete character before cursor |
| **Delete** (PS/2) | Delete character after cursor |
| **Enter** / **Return** | Insert newline at cursor |
| **Edit** / **Tab** | Insert two spaces |
| **Extend+A** / **Ctrl+A** | Select all text |
| **Extend+C** / **Ctrl+C** | Copy selection |
| **Extend+X** / **Ctrl+X** | Cut selection |
| **Extend+V** / **Ctrl+V** | Paste |
| **Extend/Z** / **Ctrl+Z** | Undo last edit |
| **Extned+Y** / **Ctrl+Y** | Redo last undo |

### Status Bar

The editor shows the filename and modification status in the title bar:

```
cartname.p8*
```

An asterisk (`*`) indicates the cart has unsaved changes.

## SPRITE Tab

The Sprite Editor lets you create and edit 8x8 pixel sprites. It has two modes:

### Sheet Mode (Browse)

- Shows a sheet of sprites.
- Navigate with mouse wheel, **True Video** / **PgUp**, or **Inv Video** / **PgDn**
- Click a sprite to select it (highlighted in white)
- Click the selected sprite again to enter Edit Mode
- Click flags row to toggle sprite flags (8 flags per sprite)

**Status:** `spr:NNN  1/2:col  enter:edit`

### Edit Mode (Paint)

- Left 64x64 area shows sprite zoomed 8x
- Right panel shows 16-color palette, 8 flags, and tools
- Tools are accessed by clicking or keyboard shortcuts

#### Tools

| Tool | Shortcut | Description |
|------|----------|-------------|
| **Pencil** | **P** | Draw single pixels |
| **Bucket** | **F** | Flood fill |
| **Select** | **S** | Select rectangular region |
| **Line** | **L** | Draw diagonal lines |
| **Hollow rect** | click tool | Draw rectangle outline |
| **Oval** | click tool | Draw ellipse |
| **Pan** | click tool | Move pixels/selection |

#### Tool Operations

| Action | Key |
|--------|-----|
| Paint/fill | **Left-click** |
| Sample color (eyedropper) | **Right-click** |
| Replace color (all pixels) | **Ctrl+click** with pencil/bucket |

#### Selection

- **S** to select, drag to define rectangle
- **Delete** / **Backspace** clears selected pixels
- **Break** / **Escape** clears selection
- Paint operations only affect pixels inside selection

#### Pan Operations

- **Pan tool** moves pixels
- Without selection: whole sprite with wrap
- With selection: only selected pixels

#### Keyboard Shortcuts

| Key | Action |
|-----|--------|
| **Arrow keys** | Move 1 pixel in zoomed view |
| **Shift+Arrows** | Shift sprite pixels by 1 |
| **Space/Enter/Return** | Paint current color |
| **Delete** / **Backspace** | Clear current pixel or selection |
| **Extend+G** / **Ctrl+G** | Toggle pixel grid overlay |
| **Extend+A** / **Ctrl+A** | Select all pixels |
| **Extend+C/V** / **Ctrl+C/V** | Copy/paste whole sprite |
| **H/V/R** | Flip horizontal/vertical/rotate CW |
| **P/F/S/L** | Select tool: pencil/fill/select/line |
| **1/2** | Previous/next draw color |
| **0-7** | Toggle sprite flags |
| **Q/W** | Previous/next sprite |
| **Edit** / **Tab** | Toggle between sheet/edit modes |
| **Break** / **Esc** | Clear selection or exit edit mode |

**Status:** `spr:NNN  px:X,Y`

## MAP Tab

The Map Editor shows a 16x12 tile window into the 128x32 tile map. Each tile is 8x8 pixels.

### Navigation

| Key | Action |
|-----|--------|
| **Arrow keys** | Move cursor one tile |
| **True Video** / **PgUp** | Scroll viewport up one page (12 rows) |
| **Inv Video ** / **PgDn** | Scroll viewport down one page |
| **Space+drag** | Pan viewport |

### Placing Tiles

- **Left-click/drag** places selected sprite as tiles
- **Right-click** picks sprite from map cell (eyedropper)

### Sprite Strip

The bottom strip shows two rows of the sprite sheet. Use **Q/W** to scroll through strip rows.

**Status:** `m:X,Y  spr:NNN  rR`

## SFX Tab

The Sound Effects Editor manages 64 SFX, each containing up to 32 notes.

### Views

- **List View**: Shows all 64 SFX
- **Edit View**: Shows 32 notes for selected SFX

### Navigation

| Key | Action |
|-----|--------|
| **Up/Down** | Move between SFX (list) or notes (edit) |
| **Left/Right** | Move between columns in edit view |
| **True Video/Inv Video** / **PgUp/PgDn** | Fast navigation in list view |
| **Home/End** | Jump to first/last note (edit view) |
| **Enter** / **Return** | Open selected SFX in edit view |
| **Break** / **Esc** | Return from edit to list view |
| **Edit** / **Tab** | Cycle through SFX submodes |

### Edit View Controls

- Type **0-9** to enter note pitch (0-95)
- Type **A-F** to enter note pitch (10-15)
- **Delete** / **Backspace** deletes character
- Two digits commit immediately
- Single digit commits when you navigate away

**Status text:**
- List: `enter:edit`
- Edit: `lr:sel enter:set tab:mode`

## MUSIC Tab

The Music Editor manages 64 patterns, each using 4 SFX channels.

### Display

- Shows all 64 patterns
- Flags column (col 0): **L** (loop start), **E** (loop end), **S** (stop)
- SFX columns (cols 1-4): SFX index for each channel
- Flags color-coded: L=green, E=red, S=orange

### Navigation

| Key | Action |
|-----|--------|
| **Up/Down** | Select pattern |
| **Left/Right** | Move between flag and SFX columns |
| **Space** | Play/stop current pattern |

### Editing

- **Flag column (col 0)**: Press **L/E/S** to toggle flags
- **SFX columns (cols 1-4)**: Type digits for SFX index (0-127)
  - Two digits commit immediately
  - Single digit commits on navigation away
  - **Break** / **Esc** cancels pending input without leaving tab

**Status:**
- Flag column: `ud:pattern lr:col l/e/s:flags`
- SFX column: current input state displayed

## Running Cart from Editor

1. Press **Extend+R** / **Ctrl+R** to run the cart
2. If there are syntax errors, a dialog shows the error location
3. The cart runs in full-screen mode
4. Press **Break** / **Esc** to stop and return to Editor

## Saving Carts

| Command | Key | Description |
|---------|-----|-------------|
| **Save** | **Extend+S** / **Ctrl+S** | Save to current filename |
| **Save As** | **Extend+A** / **Ctrl+A** | Save to new filename |

When saving:
- The cart is saved in PICO-8 format with all 5 data sections
- Lua source code and binary data (sprites, map, SFX, music) are combined
- Cart metadata (title, author, labels) are preserved

## Cart Modification

The editor tracks cart modification status:

- If changes are made, an asterisk (`*`) appears in the title bar
- When quitting, a dialog asks if you want to discard changes

## Tips and Tricks

### Undo/Redo

- Each tab has independent undo/redo stacks
- Up to 8 levels of undo per tab
- **Extend+Z** / **Ctrl+Z** to undo, **Extend+Y** / **Ctrl+Y** to redo

### Quick Switching

- Use **Extend+R** / **Ctrl+R** to quickly test cart changes
- Use **Extend+7** / **F7** to open REPL for debugging without leaving Editor
- Use **Extend+A** / **Ctrl+A** to quickly save with new name

### Sprite Editing

- Use **Extend+G** / **Ctrl+G** to see pixel grid for precise editing
- **H/V** flip for symmetry
- **Copy/Paste** whole sprite for duplicates
- **Pan tool** for moving pixel regions

### Map Editing

- Use **Space+drag** to pan large maps
- **Right-click** to sample tiles from existing map
- **Q/W** to scroll sprite strip for variety

## Keyboard Focus

The Editor captures keyboard input when active. Mouse input is handled separately:

- Mouse movement updates cursor position
- Mouse clicks select items
- Mouse wheel scrolls in appropriate contexts

## Error Handling

If the cart has Lua errors:

1. Editor shows error dialog
2. Error location in source code is highlighted
3. Error message is displayed
4. Press **Enter** / **Return** to dismiss and return to editor
