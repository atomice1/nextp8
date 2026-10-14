# REPL Screen

The REPL (Read-Eval-Print Loop) is an interactive Lua interpreter that lets you test code and execute commands without creating a cart file. Access it by pressing **F7** (PS/2 keyboard only) from the Editor or **Break** (or **Esc**) from the Browse screen.

## Accessing the REPL

- Press **Extend+7** / **F7** from the Editor to open the REPL
- Press **Break** / **Esc** from the Browse screen cycles to REPL (then back to Editor on next Break)

## Quitting the REPL

- Press **Break** / **Esc** to return to the Editor

## REPL Interface

The REPL screen is divided into two sections:

- The **Output area** occupies most of the screen.
- The **Input line** at the bottom: `> _` (underscore is the cursor)

## Lua Interpreter

The REPL provides a Lua interpreter supporting PICO-8's Lua dialect. You can:

- Execute Lua expressions
- Define functions and variables
- Call PICO-8 API functions
- Test cart code before adding it to a cart file

### Example Usage

```lua
> PRINT("HELLO, WORLD!")
HELLO, WORLD!

> FOR I=1,5 DO PRINT(I) END
1
2
3
4
5

> X = 10
> Y = 20
> PRINT(X + Y)
30
```

## PICO-8 API Functions

All PICO-8 API functions are available in the REPL:

```lua
> CLS()
> PRINT("Testing")
> RECT(10, 10, 20, 20, 8)
> CIRC(64, 64, 20, 3)
```

## Built-in Commands

The REPL supports several shell-like commands that are automatically converted to Lua function calls:

| Command | Converted To | Description |
|---------|-------------|-------------|
| `LS` | `LS()` | List directory contents |
| `LS path` | `LS("path")` | List contents of path |
| `CD` | `CD()` | Show current directory |
| `CD path` | `CD("path")` | Change directory |
| `MKDIR` | `MKDIR()` | No args creates current directory string |
| `MKDIR path` | `MKDIR("path")` | Create directory |
| `SAVE` | `SAVE()` | Save current cart |
| `SAVE filename` | `SAVE("filename")` | Save cart to file |
| `LOAD` | `LOAD()` | No args uses current cart |
| `LOAD filename` | `LOAD("filename")` | Load cart from file |
| `REBOOT` | `REBOOT()` | Reboot the system |

### Example Command Usage

```lua
> LS
CART1.P8
CART2.P8
<DIR> DEMOS

> CD DEMOS
> LS
GAME1.P8
GAME2.P8

> MKDIR NEWDIR
```

## History Navigation

The REPL keeps a history of the last 32 commands:

| Key | Action |
|-----|--------|
| **Up Arrow** | Recall previous command |
| **Down Arrow** | Recall next command (after reaching top) |
| **Home** (PS/2 keyboard only) | Jump to start of input line |
| **End** (PS/2 keyboard only) | Jump to end of input line |

## Error Handling

### Syntax Errors

If your input has a syntax error, the REPL displays:

```
> PRINT(
SYNTAX ERROR
LINE: 1
```

### Runtime Errors

Runtime errors show:

```
> UNDEFINED_VARIABLE
ATTEMPT TO CALL A NIL VALUE
LINE: 1 
```

### Lua Script Errors

If a Lua script error occurs, the REPL:

1. Shows the error type (e.g., "SYNTAX ERROR", "RUNTIME ERROR")
2. Shows line number if available
3. Shows the error message
4. Sets cursor to error line in Editor (if Editor was open)

## Output Display

- Successful expressions produce no output
- Errors are shown immediately
- Use `PRINT()` to display values

```lua
> 1 + 1
> PRINT(1 + 1)
2
```

## Example REPL Session

```
WELCOME TO NEXTP8

TYPE BROWSE TO RETURN TO THE
BROWSER

PRESS BREAK/ESC TO RETURN TO
THE EDITOR

> PRINT("HELLO NEXTP8!")
HELLO NEXTP8!

> FOR I=1,3 DO PRINT(I) END
1
2
3

> X = 42
> Y = x * 2
> PRINT(Y)
84

> CLS()
> RECT(10, 10, 50, 50, 8)
> CIRC(32, 32, 15, 3)

> LS
CART1.P8
CART2.P8
<DIR> DEMOS
```

## Escape Sequence Support

The REPL supports P8SCII escape sequences for colored output:

```lua
> PRINT("\F8RED \FAGREEN \FBBLUE \FCCYAN")
```

Colors are defined by PICO-8's 16-color palette (0-15).
