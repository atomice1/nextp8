# nextp8 Programmer's Model Guide

## 1. Introduction

This document describes the hardware programmer's model for the nextp8 platform — a PICO-8 compatible FPGA core for the ZX Spectrum Next.

The nextp8 FPGA image comprises a 68010 (m68k) compatible CPU with a set of memory-mapped peripherals. All peripheral registers are accessed via memory-mapped I/O (MMIO). There are no I/O port instructions.

### 1.1 Conventions

- All addresses are given as byte addresses in hexadecimal.
- Register widths are given in bits. An `[8]` register occupies a single byte; a `[16]` register occupies a 16-bit word.
- `[r]` = read-only, `[w]` = write-only, `[rw]` = read/write. Where a single address has different read and write semantics, both are listed.
- The CPU is big-endian. Multi-byte registers use big-endian byte ordering on the bus.
- Bit numbering: bit 0 is the least significant bit.

---

## 2. System Overview

### 2.1 CPU

- **Architecture:** 68010 (m68k), 32-bit registers, 16-bit data bus, big-endian.
- **Clock:** ~40 MHz (mclk). Bus cycles take 1 clock for SRAM, 3 clocks for MMIO/BRAM reads.
- **Interrupt model:** Autovectored interrupts. IPL lines directly encode the interrupt level. Currently only Level 2 (VBlank) is used.
- **Vector table:** 256 entries × 4 bytes at address `$000000`. Vector 0 = initial SSP, vector 1 = initial PC, vectors 25–31 = autovector levels 1–7.

### 2.2 Address Map

```
$1000000 +------------------------------------------------+
         | (unmapped)                                     |
$c10000  +------------------------------------------------+
         | PCM Audio Sample Memory  [16 KB]               |
         |   8192 × 16-bit samples                        |
$c0c000  +------------------------------------------------+
         | (reserved)                                     |
$c08040  +------------------------------------------------+
         | High colour bitfield         [16 bytes]        |
$c08030  +------------------------------------------------+
         | Secondary Palette            [16 × 8-bit]      |
$c08020  +------------------------------------------------+
         | Display Palette — front buffer [16 × 8-bit]    |
$c08010  +------------------------------------------------+
         | Display Palette — back buffer  [16 × 8-bit]    |
$c08000  +------------------------------------------------+
         | Overlay Front Buffer  [8 KB]                   |
$c06000  +------------------------------------------------+
         | Overlay Back Buffer   [8 KB]                   |
$c04000  +------------------------------------------------+
         | Screen Front Buffer   [8 KB]                   |
$c02000  +------------------------------------------------+
         | Screen Back Buffer    [8 KB]                   |
$c00000  +------------------------------------------------+
         | (reserved)                                     |
$800200  +------------------------------------------------+
         | P8 Audio Subsystem Registers ($800100–$8001FF) |
$800100  +------------------------------------------------+
         | System MMIO Registers  ($800000–$8000FF)       |
$800000  +------------------------------------------------+
         | (reserved for RAM expansion)                   |
$400000  +------------------------------------------------+
         | SRAM  [4 MB]                                   |
$000000  +------------------------------------------------+
```

---

## 3. Reset and Boot

### 3.1 Reset Types

| Value | Type              | Description                                      |
|-------|-------------------|--------------------------------------------------|
| 0     | Power-on          | Initial power-up                                 |
| 1     | Button            | Physical reset button press (debounced ~12 ms)   |
| 2     | Software          | Write to RESET_REQ register                      |

### 3.2 Reset Sequence

1. PLL locks (POST code = 1 while unlocked, 2 during reset hold).
2. All registers return to default values.
3. CPU begins execution from the reset vector at `$000000` (vector 1 = initial PC).

### 3.3 Reset Type Register

| Address    | Name       | Access | Width | Description                                       |
|------------|------------|--------|-------|---------------------------------------------------|
| `$800011`  | RESET_TYPE | r      | 2     | Bits [1:0]: reset type (see table above)          |
| `$800011`  | RESET_REQ  | w      | 8     | Write `$01` = trigger software reset; write `$FF` = halt CPU permanently (until hardware reset) |

### 3.4 Boot Flow (BSP)

```
__start:
    ; POST code = 4
    move.b  #4, ($800003)

    ; Set up stack pointer
    move.l  #__stack, sp
    move.l  #0, fp

    ; Jump to C init
    jmp     __start1

__start1:
    ; POST code 5: hardware_init_hook
    ; POST code 6: copy .data, zero .bss
    ; POST code 7: software_init_hook
    ; POST code 8: call _init(), then main()
```

### 3.5 POST Code Register

| Address    | Name      | Access | Width | Description                      |
|------------|-----------|--------|-------|----------------------------------|
| `$800003`  | POST_CODE | w      | 6     | 6-bit diagnostic code (bits [5:0]), directly output to the Raspberry Pi accelerator GPIOs. This is the low byte of the 16-bit word at `$800002`; access with `move.b`. |

**Initialization:**
```c
MMIO_REG8(0x800003) = code;       // Set POST code (0–63)
```

---

## 4. System Identification

| Address    | Name               | Access | Width | Description                             |
|------------|--------------------|--------|-------|-----------------------------------------|
| `$800004`  | BUILD_TIMESTAMP_HI | r      | 16    | FPGA build timestamp, upper 16 bits     |
| `$800006`  | BUILD_TIMESTAMP_LO | r      | 16    | FPGA build timestamp, lower 16 bits     |
| `$800008`  | HW_VERSION_HI      | r      | 16    | Hardware version, upper 16 bits: `{API[15:8], MAJOR[7:0]}` |
| `$80000A`  | HW_VERSION_LO      | r      | 16    | Hardware version, lower 16 bits: `{MINOR[15:8], PATCH[7:0]}` |

### 4.1 Parameters Register

| Address    | Name   | Access | Width | Description                            |
|------------|--------|--------|-------|----------------------------------------|
| `$800001`  | PARAMS | rw     | 16    | Bit 0: PS/2 port assignment — `0` = keyboard on main PS/2 port, `1` = mouse on main PS/2 port |

---

## 5. Interrupts

### 5.1 Interrupt Architecture

The CPU uses autovectored interrupts with a 3-bit IPL (Interrupt Priority Level) input:

| IPL[2:0] | Level | Source       |
|----------|-------|--------------|
| `111`    | 0     | No interrupt |
| `101`    | 2     | VBlank       |

Only level 2 (VBlank) is implemented. The interrupt vector is at offset 26 × 4 = `$68` in the vector table.

### 5.2 VBlank Interrupt

The VBlank interrupt fires on the rising edge of the vertical sync signal at ~60 Hz.

| Address    | Name             | Access | Width | Description                                     |
|------------|------------------|--------|-------|-------------------------------------------------|
| `$800013`  | VBLANK_INTR_CTRL | w      | 8     | Bit 0: `1` = enable and acknowledge; `0` = disable and acknowledge |

**Programming notes:**

- Writing any value to this register acknowledges (clears) a pending VBlank IRQ.
- To enable: write `$01`. To disable: write `$00`.
- The ISR must write to `VBLANK_INTR_CTRL` to clear the IRQ before returning (rte).

**ISR setup (assembly):**
```asm
    ; Vector 26 (level 2 autovector) at $68
    move.l  #vblank_handler, ($68)

    ; Enable VBlank interrupt
    move.b  #1, ($800013)

    ; Lower CPU IPL to allow level-2 interrupts
    move.w  sr, d0
    andi.w  #$F0FF, d0       ; Clear IPL bits (allow all levels)
    move.w  d0, sr

vblank_handler:
    ; ... handle VBlank ...
    move.b  #1, ($800013)    ; Acknowledge and re-enable
    rte
```

---

## 6. Timers

### 6.1 Microsecond Timer (64-bit, 1 MHz)

A free-running 64-bit counter incremented at 1 MHz (~1 µs resolution). The timer counts continuously from power-on and does not reset.

| Address    | Name              | Access | Width | Description                |
|------------|-------------------|--------|-------|----------------------------|
| `$800014`  | UTIMER_1MHZ[63:48]| r      | 16    | Bits 63–48 (MSW)           |
| `$800016`  | UTIMER_1MHZ[47:32]| r      | 16    | Bits 47–32                 |
| `$800018`  | UTIMER_1MHZ[31:16]| r      | 16    | Bits 31–16                 |
| `$80001A`  | UTIMER_1MHZ[15:0] | r      | 16    | Bits 15–0 (LSW)            |

**Atomic read protocol:** Reading the highest word (`$800014`) latches the entire 64-bit value. Subsequent reads of the lower words return the latched value, provided they are read in descending address order (bits 63:48, then 47:32, then 31:16, then 15:0). Reading out of order re-latches from the current slice downwards.

**Reading the timer (C):**
```c
uint64_t read_timer(void) {
    // Read MSW first — this latches the full 64-bit value
    return MMIO_REG64(0x800014);
}
```

**Busy-wait delay (C):**
```c
void delay_us(uint32_t us) {
    uint64_t start = MMIO_REG64(0x800014);
    while ((MMIO_REG64(0x800014) - start) < us) { }
}
```

---

## 7. Display Processor

### 7.1 Overview

- **Resolution:** 128 × 128 pixels, 4-bit indexed color (16 colors from a 32-color system palette).
- **Output:** 1024 × 768 @ 60 Hz (6× zoom, centered). VGA and HDMI outputs.
- **Double buffering:** Hardware-managed front/back buffer swap.
- **Overlay:** A second 128 × 128 frame buffer composited on top with palette-index transparency.

### 7.2 Frame Buffer Memory

| Address      | Name                   | Size   | Description                         |
|--------------|------------------------|--------|-------------------------------------|
| `$c00000`    | Current Back Buffer    | 8 KB   | CPU draws here                      |
| `$c02000`    | Current Front Buffer   | 8 KB   | Display reads from here             |
| `$c04000`    | Overlay Back Buffer    | 8 KB   | CPU draws overlay here              |
| `$c06000`    | Overlay Front Buffer   | 8 KB   | Display reads overlay from here     |

**Pixel format:** Two 4-bit palette indices packed per byte. Even pixel in the lower nibble, odd pixel in the upper nibble. 64 bytes per row, 128 rows.

```
Byte offset = (y * 64) + (x / 2)
Lower nibble = pixel at even x; upper nibble = pixel at odd x.
```

**Clear screen (C):**
```c
// Fill with color index `c` (0–15)
memset((void*)0xc00000, (c << 4) | c, 8192);
```

### 7.3 Double Buffering

Writing to `$c00000` always writes to the logical back buffer; reading from `$c02000` is the front buffer. The hardware swaps which physical BRAM bank is "front" and which is "back."

| Address    | Name      | Access | Width | Description                              |
|------------|-----------|--------|-------|------------------------------------------|
| `$80001D`  | VFRONT    | r      | 1     | Current front buffer index (0 or 1)      |
| `$80001D`  | VFRONTREQ | w      | 1     | Request buffer swap: write the desired front buffer index |

**Flip buffers (C):**
```c
void flip(void) {
    uint8_t current = MMIO_REG8(0x80001D);  // Read VFRONT
    uint8_t desired = 1 - current;
    MMIO_REG8(0x80001D) = desired;          // Write VFRONTREQ
    while (MMIO_REG8(0x80001D) != desired) { }  // Wait for swap
}
```

### 7.4 Palette

Each frame buffer (front and back) has an independent palette of 16 entries. Each entry maps a 4-bit PICO-8 color index to one of 32 system hardware colors.

| Address      | Name               | Size     | Description                  |
|--------------|--------------------|----------|------------------------------|
| `$c08000`    | Palette Back       | 16 bytes | Palette for the back buffer  |
| `$c08010`    | Palette Front      | 16 bytes | Palette for the front buffer |

Each byte: the low 4 bits and bit 7 together form a 5-bit system color index. Bits [6:4] are unused.

**Set palette entry (C):**
```c
// Map PICO-8 color `slot` to system color `sys_color` (0–31)
uint8_t val = (sys_color & 0x10) ? 0x80 | (sys_color & 0x0F) : (sys_color & 0x0F);
*((volatile uint8_t*)(0xc08000 + slot)) = val;  // Back buffer palette
```

### 7.5 Overlay

The overlay composites a second 128 × 128 frame buffer on top of the main display using palette-index transparency. Pixels matching the transparent index are transparent, showing the main buffer through.

| Address    | Name            | Access | Width | Description                                               |
|------------|-----------------|--------|-------|-----------------------------------------------------------|
| `$80001F`  | OVERLAY_CONTROL | rw     | 8     | Bit 6: enable. Bits [3:0]: transparent color index (key). |

**Enable overlay with transparency on color 0 (C):**
```c
MMIO_REG8(0x80001F) = 0x40 | 0x00;  // Enable, key color = 0
```

**Note:** The overlay frame buffer uses the system palette directly and is not affected by remapping palette changes.

### 7.6 Screen Transform

Controls display scaling and rotation. The screen transform mode is applied after the display is rendered and affect
only the main layer and not the overlay.

| Address    | Name              | Access | Width | Description                           |
|------------|-------------------|--------|-------|---------------------------------------|
| `$8000A1`  | SCREEN_TRANSFORM  | rw     | 8     | Bits [2:0]: transform mode (0-7)      |

**Transform modes:**

| Value | Description                    |
|-------|--------------------------------|
| 0     | Normal (no transform)          |
| 1     | 2× horizontal zoom             |
| 2     | 2× vertical zoom               |
| 3     | 2× horizontal and vertical     |
| 4     | 3× horizontal zoom             |
| 5     | 3× vertical zoom               |
| 6     | 3× horizontal and vertical     |
| 7     | 4× horizontal and vertical     |

**Note:** Transform modes affect only the display output, not the frame buffer contents.

### 7.7 High Colour Mode

The high colour mode provides a 128-bit bitfield that can be used for per-line palette selection or other per-line effects. Each bit in the 128-bit bitfield corresponds to one scanline (row) of the display.

| Address range       | Name                     | Access | Size    | Description           |
|---------------------|--------------------------|--------|---------|-----------------------|
| `$8000A3`           | HIGH_COLOUR_MODE         | rw     | 8       | Bit 0: enable high colour mode |

**High colour bitfield memory (16 bytes = 128 bits):**

| Address range       | Name                     | Access | Size    | Description           |
|---------------------|--------------------------|--------|---------|-----------------------|
| `$c08040`–`$c0804F` | HIGH_COLOUR_BITFIELD     | rw     | 16 bytes| Per-scanline bitfield |

**Enable high colour mode (C):**
```c
// Enable high colour mode
MMIO_REG8(0x8000A3) = 0x01;

// Set bitfield for first 16 scanlines
uint8_t *bf = (uint8_t*)0xc08040;
for (int i = 0; i < 16; i++) {
    bf[i] = 0xFF;  // Set all 8 bits for this scanline group
}
```

### 7.8 Secondary Palette

The secondary palette provides an additional palette layer that can be applied after the primary palette. This enables advanced effects like per-line palette swaps or dynamic color remapping.

| Address range      | Name                      | Access | Size    | Description                  |
|---------------------|--------------------------|--------|---------|------------------------------|
| `$c08030`–`$c0803F` | SECONDARY_PALETTE        | rw     | 16 bytes| 16 secondary palette entries |

**Secondary palette format:** Each byte is a 5-bit system color index (bits [4:0]). Bit 7 is unused.

**Set secondary palette entry (C):**
```c
// Map PICO-8 color `slot` to system color `sys_color` (0–31)
uint8_t val = sys_color & 0x1F;  // 5-bit color index
*((volatile uint8_t*)(0xc08030 + slot)) = val;
```

---

## 8. UART (Pi UART)

### 8.1 Overview

A simple UART connected to GPIO pins 14/15 (directly accessible via a serial terminal or Raspberry Pi). Default baud rate: 115200, 8N1.

### 8.2 Registers

| Address    | Name          | Access | Width  | Description                                    |
|------------|---------------|--------|--------|------------------------------------------------|
| `$800031`  | UART_CTRL     | rw     | 8      | See bit definitions below                      |
| `$800033`  | UART_DATA     | rw     | 8      | TX: write byte to send. RX: read received byte |
| `$800034`  | UART_BAUD_DIV | w      | 16     | Baud rate divider (15-bit)                     |

**UART_CTRL read bits (status):**

| Bit | Name       | Description                      |
|-----|------------|----------------------------------|
| 0   | DATA_READY | `1` = received byte available    |
| 1   | READY      | `1` = transmitter is ready       |
| 2   | READ_ACK   | `1` = read has been acknowledged |
| 3   | WRITE_ACK  | `1` = write has been acknowledged|

**UART_CTRL write bits (control):**

| Bit | Name          | Description                       |
|-----|---------------|-----------------------------------|
| 0   | WRITE_STROBE  | Pulse to initiate byte transmit   |
| 1   | READ_STROBE   | Pulse to acknowledge byte receive |

**Baud rate divider:** `divider = clk_sys / (baud_rate × 16)`. For 115200 baud at ~11 MHz: divider = 95.

### 8.3 Initialization

```c
// Set baud rate to 115200
MMIO_REG16(0x800034) = 95;     // 11000000 / (115200 * 16) ≈ 95
```

### 8.4 Transmit a Byte

```c
void uart_write_byte(uint8_t byte) {
    // 1. Write data
    MMIO_REG8(0x800033) = byte;

    // 2. Wait for transmitter ready
    while (!(MMIO_REG8(0x800031) & 0x02)) { }

    // 3. Pulse write strobe (4 cycles to ensure CDC crossing)
    MMIO_REG8(0x800031) = 0x01;
    MMIO_REG8(0x800031) = 0x01;
    MMIO_REG8(0x800031) = 0x01;
    MMIO_REG8(0x800031) = 0x01;
    MMIO_REG8(0x800031) = 0x00;
}
```

The write strobe must be held for at least 4 consecutive writes to ensure it crosses the clock domain boundary from `mclk` to `clk_sys`.

### 8.5 Receive a Byte

```c
int uart_read_byte(void) {
    // 1. Check for data ready
    if (!(MMIO_REG8(0x800031) & 0x01))
        return -1;  // No data available

    // 2. Read data
    uint8_t byte = MMIO_REG8(0x800033);

    // 3. Pulse read strobe to acknowledge
    MMIO_REG8(0x800031) = 0x02;
    MMIO_REG8(0x800031) = 0x02;
    MMIO_REG8(0x800031) = 0x02;
    MMIO_REG8(0x800031) = 0x02;
    MMIO_REG8(0x800031) = 0x00;

    return byte;
}
```

---

## 9. ESP UART (Wi-Fi)

### 9.1 Overview

A second UART connected to an ESP-01 (ESP8266) module for Wi-Fi. The ESP module is controlled via AT commands. The interface is identical in structure to the Pi UART.

### 9.2 Registers

| Address    | Name          | Access | Width  | Description                                                |
|------------|---------------|--------|--------|------------------------------------------------------------|
| `$800037`  | ESP_CTRL      | rw     | 8      | Same bit layout as UART_CTRL (see §8.2)                    |
| `$800039`  | ESP_DATA      | rw     | 8      | TX/RX data byte                                            |
| `$80003A`  | ESP_BAUD_DIV  | r      | 16     | Baud rate divider (15-bit, read-only; default 95 = 115200) |

### 9.3 Write a Byte

```c
void esp_write_byte(uint8_t byte) {
    MMIO_REG8(0x800039) = byte;

    while (!(MMIO_REG8(0x800037) & 0x02)) { }  // Wait READY

    MMIO_REG8(0x800037) = 0x01;   // Pulse write strobe
    MMIO_REG8(0x800037) = 0x01;
    MMIO_REG8(0x800037) = 0x01;
    MMIO_REG8(0x800037) = 0x01;
    MMIO_REG8(0x800037) = 0x00;
}
```

### 9.4 Read a Byte

```c
int esp_read_byte(uint8_t *out, uint32_t timeout_us) {
    uint64_t start = MMIO_REG64(0x800014);
    while (1) {
        if (MMIO_REG8(0x800037) & 0x01) {       // DATA_READY?
            *out = MMIO_REG8(0x800039);

            MMIO_REG8(0x800037) = 0x02;          // Pulse read strobe
            MMIO_REG8(0x800037) = 0x02;
            MMIO_REG8(0x800037) = 0x02;
            MMIO_REG8(0x800037) = 0x02;
            MMIO_REG8(0x800037) = 0x00;
            return 0;
        }
        if ((MMIO_REG64(0x800014) - start) >= timeout_us)
            return -1;  // Timeout
    }
}
```

### 9.5 Sending an AT Command

```c
int esp_send_at(const char *cmd, const char *expected, uint32_t timeout_us) {
    // Send command followed by "\r\n"
    while (*cmd) esp_write_byte(*cmd++);
    esp_write_byte('\r');
    esp_write_byte('\n');

    // Read lines until expected response or timeout
    // ... (see BSP esp.c for full implementation)
}
```

---

## 10. SD Card (SPI Mode)

### 10.1 Overview

An SD card controller operating in SPI mode. Two chip select lines are available (directly mapping to the internal and external SD cards).

### 10.2 Registers

| Address    | Name              | Access | Width | Description                                                        |
|------------|-------------------|--------|-------|--------------------------------------------------------------------|
| `$800021`  | SDSPI_WRITE_ENABLE| w      | 1     | `1` = latch data_in and start SPI transfer; `0` = idle             |
| `$800023`  | SDSPI_DIVIDER     | w      | 8     | SPI clock divider: `spi_clk = 11 MHz / divider`                    |
| `$800025`  | SDSPI_DATA_IN     | w      | 8     | Byte to transmit (MOSI)                                            |
| `$800027`  | SDSPI_DATA_OUT    | r      | 8     | Received byte (MISO)                                               |
| `$800029`  | SDSPI_READY       | r      | 1     | `1` = SPI transfer in progress / data latched; `0` = idle/complete |
| `$80002B`  | SDSPI_CHIP_SELECT | w      | 2     | Bit 0: CS0# (active low), Bit 1: CS1# (active low). Write `$FF` to deassert all. |

### 10.3 Set SPI Clock Speed

```c
// Set SPI clock to 400 kHz for initialization
MMIO_REG8(0x800023) = 11000000 / 400000;  // = 27

// Set SPI clock to 1 MHz for data transfer
MMIO_REG8(0x800023) = 11000000 / 1000000; // = 11
```

### 10.4 SPI Transfer (One Byte)

```c
uint8_t spi_transfer(uint8_t tx) {
    // 1. Wait for SPI idle (READY = 0)
    while (MMIO_REG8(0x800029)) { }

    // 2. Write TX byte
    MMIO_REG8(0x800025) = tx;

    // 3. Assert WRITE_ENABLE to start transfer
    MMIO_REG8(0x800021) = 1;

    // 4. Wait for data to latch (READY = 1)
    while (!MMIO_REG8(0x800029)) { }

    // 5. Deassert WRITE_ENABLE
    MMIO_REG8(0x800021) = 0;

    // 6. Wait for transfer to complete (READY = 0)
    while (MMIO_REG8(0x800029)) { }

    // 7. Read received byte
    return MMIO_REG8(0x800027);
}
```

### 10.5 Chip Select

```c
// Assert CS0 (active low)
MMIO_REG8(0x80002B) = 0xFE;   // ~(1 << 0)

// Deassert all CS lines
MMIO_REG8(0x80002B) = 0xFF;
```

### 10.6 SD Card Initialization Sequence

1. Set SPI clock to 100–400 kHz.
2. Deassert CS; send ≥74 clock cycles (send 10 × `$FF` bytes).
3. Assert CS0.
4. Send CMD0 (GO_IDLE_STATE) with CRC `$95`. Expect R1 = `$01` (idle).
5. Send CMD8 (SEND_IF_COND) with argument `$000001AA`, CRC `$87`. Check response for voltage acceptance.
6. Repeat ACMD41 (CMD55 + CMD41 with HCS bit) until R1 bit 0 clears (card initialized).
7. Send CMD16 (SET_BLOCKLEN) with argument 512 to set block size.
8. Increase SPI clock to 1 MHz (or higher).

---

## 11. I2C Controller (RTC)

### 11.1 Overview

A single-master I2C controller hardcoded to address `$68` (DS1307 RTC). The bus runs at 100 kHz from the ~11 MHz `clk_sys`.

### 11.2 Registers

| Address    | Name       | Access | Width | Description                                                             |
|------------|------------|--------|-------|-------------------------------------------------------------------------|
| `$80003D`  | I2C_DATA   | rw     | 8     | Write: data to send. Read: received data.                               |
| `$80003F`  | I2C_CTRL   | w      | 8     | Bit 0: ENA (enable/latch command). Bit 1: RW (`0` = write, `1` = read). |
| `$80003F`  | I2C_STATUS | r      | 8     | Bit 0: BUSY. Bit 1: ERR (NACK error).                                   |

### 11.3 I2C Protocol

The I2C controller uses a BUSY-flag protocol. Each command cycle is:
1. Load data and control bits.
2. Wait for BUSY to rise (command accepted).
3. Wait for BUSY to fall (command complete).
4. Read data (if applicable).

### 11.4 Write a Byte (Register Address)

```c
int i2c_write_byte(uint8_t data) {
    // Wait idle
    while (MMIO_REG8(0x80003F) & 0x01) { }

    // Load data
    MMIO_REG8(0x80003D) = data;

    // Start write (ENA=1, RW=0)
    MMIO_REG8(0x80003F) = 0x01;

    // Wait BUSY rise
    while (!(MMIO_REG8(0x80003F) & 0x01)) { }

    // Wait BUSY fall
    while (MMIO_REG8(0x80003F) & 0x01) { }

    // Check for NACK error
    if (MMIO_REG8(0x80003F) & 0x02)
        return -1;

    return 0;
}
```

### 11.5 Read Multiple Bytes (I2C Sequential Read)

```c
int i2c_read_bytes(uint8_t reg_addr, uint8_t *buf, int count) {
    // Phase 1: Write register address
    wait_busy_fall();
    MMIO_REG8(0x80003D) = reg_addr;
    MMIO_REG8(0x80003F) = 0x01;          // ENA=1, RW=0 (write)
    wait_busy_rise();

    // Phase 2: Switch to read mode
    MMIO_REG8(0x80003F) = 0x01 | 0x02;   // ENA=1, RW=1 (read)
    wait_busy_fall();

    // Phase 3: Read bytes
    for (int i = 0; i < count; i++) {
        wait_busy_rise();
        wait_busy_fall();

        if (i == count - 1) {
            // Last byte: send STOP
            MMIO_REG8(0x80003F) = 0x00;  // ENA=0
            wait_busy_fall();
        }

        buf[i] = MMIO_REG8(0x80003D);
    }

    return 0;
}
```

### 11.6 Read RTC (DS1307)

The DS1307 contains 7 time registers starting at address 0: seconds, minutes, hours, weekday, date, month, year (all BCD-encoded).

```c
int read_rtc(struct tm *t) {
    uint8_t regs[7];
    i2c_read_bytes(0x00, regs, 7);

    t->tm_sec  = ((regs[0] >> 4) & 0x07) * 10 + (regs[0] & 0x0F);
    t->tm_min  = ((regs[1] >> 4) & 0x07) * 10 + (regs[1] & 0x0F);
    t->tm_hour = ((regs[2] >> 4) & 0x03) * 10 + (regs[2] & 0x0F);  // 24h mode
    t->tm_wday = regs[3] & 0x07;
    t->tm_mday = ((regs[4] >> 4) & 0x03) * 10 + (regs[4] & 0x0F);
    t->tm_mon  = ((regs[5] >> 4) & 0x01) * 10 + (regs[5] & 0x0F) - 1;
    t->tm_year = ((regs[6] >> 4) & 0x0F) * 10 + (regs[6] & 0x0F) + 100;  // years since 1900
    return 0;
}
```

---

## 12. Input Devices

### 12.1 Joysticks

Two joystick ports, directly memory-mapped with active-high bit encoding.

| Address    | Name               | Access | Width | Description                       |
|------------|--------------------|--------|-------|-----------------------------------|
| `$800049`  | JOYSTICK0          | r      | 8     | Current state of joystick 0       |
| `$80004B`  | JOYSTICK1          | r      | 8     | Current state of joystick 1       |
| `$80004D`  | JOYSTICK0_LATCHED  | rw     | 8     | Latched (edge-detected) state     |
| `$80004F`  | JOYSTICK1_LATCHED  | rw     | 8     | Latched (edge-detected) state     |

**Bit layout (both current and latched):**

| Bit | Function  |
|-----|-----------|
| 0   | Up        |
| 1   | Down      |
| 2   | Left      |
| 3   | Right     |
| 4   | Button 1  |
| 5   | Button 2  |

**Latched registers:** Bits are set on rising edges (button press) and accumulate until cleared. Write a `1` bit to clear the corresponding latched bit.

```c
// Read joystick 0 current state
uint8_t js = MMIO_REG8(0x800049);
if (js & 0x10) { /* Button 1 pressed */ }

// Check for newly pressed buttons (btnp behavior)
uint8_t pressed = MMIO_REG8(0x80004D);
if (pressed & 0x10) { /* Button 1 was just pressed */ }
MMIO_REG8(0x80004D) = pressed;  // Clear latched bits
```

### 12.2 Keyboard

Keyboard input is stored as a 256-bit matrix (32 bytes), indexed by **USB HID scancode** (8-bit). PS/2 keyboard events are translated to USB HID scancodes before being stored in the matrix. The `keyboard.sv` module handles the translation from PS/2 scancodes to USB HID scancodes, including special keys (arrows, F1-F12, numpad, modifier keys).

| Address range      | Name                     | Access | Size    | Description           |
|---------------------|--------------------------|--------|---------|----------------------|
| `$800060`–`$80007F` | KEYBOARD_MATRIX         | r      | 256 bits| Current key state     |
| `$800080`–`$80009F` | KEYBOARD_MATRIX_LATCHED | rw     | 256 bits| Edge-detected state   |

The matrix is organized as 32 bytes, each containing 8 scan-code flags.

```c
// Check if scan code 0x04 (key 'A', USB HID) is pressed
// The matrix is indexed by the low 8 bits of the USB HID scancode
uint8_t byte_index = 0x04 / 8;  // = 0
uint8_t bit_mask   = 1 << (0x04 % 8);  // = 1 << 4
if (*(volatile uint8_t*)(0x800060 + byte_index) & bit_mask) {
    // Key 'A' is pressed
}
```

**Latched keyboard:** Same as joystick latching — bits set on key press, cleared by writing `1` to the corresponding bit. This implements "button just pressed" (btnp) semantics.

**Clearing latched keys:**
```c
// Read and clear all latched keys for a given byte
uint8_t latched = *(volatile uint8_t*)(0x800080 + byte_index);
*(volatile uint8_t*)(0x800080 + byte_index) = latched;  // Write 1s to clear
```

**USB HID scancodes:** The matrix uses USB HID scancodes (matching PICO-8/SDL 2), not PS/2 scancodes. For example:

- `0x04` = 'A' key
- `0x05` = 'B' key
- `0x06` = 'C' key
- `0x1C` = 'Enter' key
- `0x29` = Space bar
- `0x2A` = Backspace
- `0x2B` = Tab
- `0x2C` = Space bar
- `0x2F` = '['
- `0x30` = ']'
- `0x31` = '\'
- `0x33` = ';'
- `0x34` = '''
- `0x36` = ','
- `0x37` = '.'
- `0x38` = '/'
- `0xE0` = Left Control
- `0xE1` = Left Shift
- `0xE2` = Left Alt
- `0xE3` = Left GUI (Windows key)
- `0xE4` = Right Control
- `0xE5` = Right Shift
- `0xE6` = Right Alt
- `0xE7` = Right GUI

Keyboard input is the OR of the PS/2 keyboard and the membrane keyboard (on the Spectrum Next board). Both sources are translated to USB HID scancodes before being combined in the matrix.

**Note:** The PS/2 to USB HID scancode mapping is performed by the `keyboard.sv` module. See `nextp8.srcs/sources_1/keyboard.sv` for the full mapping table. PS/2 keys that use the extended prefix (0xE0) have their own unique scancodes (e.g., PS/2 0x14 maps to USB HID 0xE0 for Left Control). The 0xE0 prefix in PS/2 is not the scancode itself but a prefix indicating extended keys.

### 12.3 Keyboard Event Queue

The keyboard event queue stores up to 7 key press/release events in a FIFO buffer. Events are generated when keys change state and are pushed to the queue by hardware. Software reads events by polling the event registers. This prevents key events from being lost when the CPU is busy.

**Event format (32 bits):**

| Bit(s)      | Description                                                     |
|-------------|-----------------------------------------------------------------|
| 31          | `0` = key press, `1` = key release                              |
| 30          | Membrane mode: `0` = PS/2 key, `1` = membrane key               |
| 29:28       | Reserved (0)                                                    |
| 27:24       | Lock keys: mode, scroll, caps, num                              |
| 23:16       | Modifiers: rgui, lgui, ralt, lalt, rctrl, lctrl, rshift, lshift |
| 15:0        | USB HID scancode (16-bit)                                       |

**Memory map:**

| Address    | Name                     | Access | Width | Description                                  |
|------------|--------------------------|--------|-------|----------------------------------------------|
| `$8000A8`  | KEYBOARD_EVENT_QUEUE_HI  | r      | 16    | Upper 16 bits of 32-bit event (bits 31:16)   |
| `$8000AA`  | KEYBOARD_EVENT_QUEUE_LO  | r/w    | 16    | Lower 16 bits of 32-bit event (bits 15:0); write any value to clear queue |

**Reading an event:**

1. Read `KEYBOARD_EVENT_QUEUE_HI` to get bits 31:16.
2. Read `KEYBOARD_EVENT_QUEUE_LO` to get bits 15:0 **and** pop the event from the queue.
3. If the queue is empty, the read returns `0`.

**Clearing the queue:**

Write any value to `KEYBOARD_EVENT_QUEUE_LO`. This resets both read and write positions to 0.

**Example (C):**
```c
// Read event without popping (polling)
uint16_t hi = MMIO_REG16(0x8000A8);
uint16_t lo = MMIO_REG16(0x8000AA);
uint32_t event = (hi << 16) | lo;

if (event != 0) {
    uint8_t is_release = (event >> 31) & 1;
    uint8_t is_membrane = (event >> 30) & 1;
    uint8_t hid_scancode = event & 0xFFFF;
    
    if (is_release) {
        printf("Key release: HID scancode 0x%02X\n", hid_scancode);
    } else {
        printf("Key press: HID scancode 0x%02X\n", hid_scancode);
    }
}

// Pop event from queue
uint32_t event = MMIO_REG32(0x8000A8);  // Reads HI then LO, popping the event

// Clear the entire queue
MMIO_REG16(0x8000AA) = 0;  // Write any value to clear
```

**Example (assembly, big-endian):**
```asm
    ; Read and pop event
    move.l  ($8000A8), d0    ; 32-bit read: HI word first, then LO word
    tst.l   d0
    beq     no_event         ; d0 = 0 if queue empty
    
    ; Event format: d0 = [31:0] = [release][membrane][reserved][lock_keys][modifiers][hid_scancode]
    ; Check if release event
    btst    #31, d0
    bne     press_event
    ; Release event
    ...
press_event:
    ; Press event
    ...

no_event:
```

**Queue depth:** 7 events (uses 8-element circular buffer, with one slot reserved to distinguish full from empty).

**USB HID scancodes:** The queue uses USB HID scancodes (matching PICO-8/SDL 2), not PS/2 scancodes. For example:

- `0x04` = 'A' key
- `0x1C` = 'Enter' key
- `0xE0` = Left Control
- `0xE1` = Left Shift
- `0xE2` = Left Alt
- `0xE4` = Right Control

See `nextp8.srcs/sources_1/keyboard.sv` for the full PS/2 to USB HID scancode mapping.

### 12.4 Mouse

PS/2 mouse position accumulators and button state.

| Address    | Name                   | Access | Width     | Description                      |
|------------|------------------------|--------|-----------|----------------------------------|
| `$800050`  | MOUSE_X                | r      | signed 16 | Horizontal position accumulator  |
| `$800052`  | MOUSE_Y                | r      | signed 16 | Vertical position accumulator    |
| `$800054`  | MOUSE_Z                | r      | signed 16 | Scroll wheel accumulator         |
| `$800057`  | MOUSE_BUTTONS          | r      | 8         | Current button state             |
| `$800059`  | MOUSE_BUTTONS_LATCHED  | rw     | 8         | Edge-detected button state       |

**Mouse button bits:**

| Bit | Button   |
|-----|----------|
| 0   | Left     |
| 1   | Right    |
| 2   | Middle   |
| 3   | Button 4 |
| 4   | Button 5 |

The PS/2 port assignment (keyboard vs. mouse on the main port) is controlled by `PARAMS` bit 0.

---

## 13. PCM Digital Audio

### 13.1 Overview

A sample-based audio playback engine reading from an 8192-sample circular buffer in dedicated BRAM. Supports mono (16-bit signed) and stereo (8-bit unsigned per channel, packed) modes. Audio output is mixed with the P8 audio subsystem and sent to DAC and HDMI.

### 13.2 Registers

| Address    | Name        | Access | Width | Description                                           |
|------------|-------------|--------|-------|-------------------------------------------------------|
| `$800040`  | DA_CONTROL  | w      | 16    | Bit 0: start playback. Bit 8: mono mode.              |
| `$800040`  | DA_ADDRESS  | r      | 16    | Bits [12:0]: current playback sample address (0–8191) |
| `$800042`  | DA_PERIOD   | w      | 16    | Sample period in 65 MHz clock ticks                   |

### 13.3 Sample Memory

| Address range        | Size    | Description                                  |
|----------------------|---------|----------------------------------------------|
| `$c0c000`–`$c0ffff`  | 16 KB   | 8192 × 16-bit sample buffer (read/write)     |

**Mono format (DA_CONTROL bit 8 = 1):** Each 16-bit word is a signed PCM sample sent to both L and R channels.

**Stereo format (DA_CONTROL bit 8 = 0):** Each 16-bit word packs two 8-bit unsigned samples: `[15:8]` = right channel, `[7:0]` = left channel. Silence = 128.

### 13.4 Sample Rate Calculation

```
period = 65000000 / sample_rate
```

| Sample Rate | Period Value |
|-------------|--------------|
| 5512.5 Hz   | 11791        |
| 11025 Hz    | 5895         |
| 22050 Hz    | 2948         |
| 44100 Hz    | 1474         |

### 13.5 Playback Sequence

```c
// 1. Fill sample buffer
int16_t *buf = (int16_t*)0xc0c000;
for (int i = 0; i < 8192; i++)
    buf[i] = generate_sample(i);

// 2. Set sample rate (22050 Hz)
MMIO_REG16(0x800042) = 65000000 / 22050;  // = 2948

// 3. Start mono playback
MMIO_REG16(0x800040) = 0x0101;  // start=1, mono=1

// 4. Monitor playback position for double-buffering
uint16_t pos = MMIO_REG16(0x800040) & 0x1FFF;  // Read DA_ADDRESS

// 5. Stop playback
MMIO_REG16(0x800040) = 0x0000;  // start=0
```

The buffer wraps around from sample 8191 back to 0 automatically.

---

## 14. PICO-8 Audio Subsystem

### 14.1 Overview

The P8 audio subsystem implements the PICO-8 SFX and MUSIC engines in hardware. It reads SFX data and music patterns from main memory via DMA. The subsystem has its own clock domains and runs independently of the CPU.

### 14.2 Registers

| Address    | Name              | Access | Width | Description                                    |
|------------|-------------------|--------|-------|------------------------------------------------|
| `$800100`  | P8AUDIO_VERSION   | r      | 16    | Audio subsystem version                        |
| `$800102`  | P8AUDIO_CTRL      | w      | 16    | Bit 0: `1` = run (enable audio engine)         |
| `$800104`  | P8AUDIO_SFX_BASE_HI  | w   | 16    | SFX data base address, bits [31:16]            |
| `$800106`  | P8AUDIO_SFX_BASE_LO  | w   | 16    | SFX data base address, bits [15:0]             |
| `$800108`  | P8AUDIO_MUSIC_BASE_HI| w   | 16    | Music pattern base address, bits [31:16]       |
| `$80010A`  | P8AUDIO_MUSIC_BASE_LO| w   | 16    | Music pattern base address, bits [15:0]        |
| `$80010D`  | P8AUDIO_HWFX40    | w      | 8     | Hardware effect register 0x5F40                |
| `$80010F`  | P8AUDIO_HWFX41    | w      | 8     | Hardware effect register 0x5F41                |
| `$800111`  | P8AUDIO_HWFX42    | w      | 8     | Hardware effect register 0x5F42                |
| `$800113`  | P8AUDIO_HWFX43    | w      | 8     | Hardware effect register 0x5F43                |
| `$800118`  | P8AUDIO_SFX_CMD   | w      | 16    | SFX command register                           |
| `$80011A`  | P8AUDIO_SFX_LEN   | w      | 16    | SFX length override (note count)               |
| `$80011C`  | P8AUDIO_MUSIC_CMD | w      | 16    | Music command register                         |
| `$80011E`  | P8AUDIO_MUSIC_FADE| w      | 16    | Music fade time (in frames)                    |

**Status registers (read-only):**

| Address    | Name             | Width | Description                                       |
|------------|------------------|-------|---------------------------------------------------|
| `$800120`  | P8AUDIO_STAT46   | 16    | SFX index playing on channel 0 (`-1` = none)      |
| `$800122`  | P8AUDIO_STAT47   | 16    | SFX index playing on channel 1                    |
| `$800124`  | P8AUDIO_STAT48   | 16    | SFX index playing on channel 2                    |
| `$800126`  | P8AUDIO_STAT49   | 16    | SFX index playing on channel 3                    |
| `$800128`  | P8AUDIO_STAT50   | 16    | Current note index on channel 0                   |
| `$80012A`  | P8AUDIO_STAT51   | 16    | Current note index on channel 1                   |
| `$80012C`  | P8AUDIO_STAT52   | 16    | Current note index on channel 2                   |
| `$80012E`  | P8AUDIO_STAT53   | 16    | Current note index on channel 3                   |
| `$800130`  | P8AUDIO_STAT54   | 16    | Current music pattern index                       |
| `$800132`  | P8AUDIO_STAT55   | 16    | (reserved)                                        |
| `$800134`  | P8AUDIO_STAT56   | 16    | (reserved)                                        |
| `$800136`  | P8AUDIO_STAT57   | 16    | Music playing status (non-zero = playing)         |

### 14.3 SFX Data Format (in Memory)

SFX data must be placed in SRAM at the address configured via `P8AUDIO_SFX_BASE`. The audio engine accesses it via DMA.

- 64 SFX slots × 68 bytes each = 4352 bytes total.
- Per slot: 32 notes × 2 bytes each (little-endian) + 4 header bytes.

**Note encoding (16-bit, little-endian):**

| Bits    | Field   | Values                                                                            |
|---------|---------|-----------------------------------------------------------------------------------|
| 15      | Custom  | `1` = custom waveform instrument                                                  |
| 14–12   | Effect  | 0=none, 1=slide, 2=vibrato, 3=drop, 4=fade-in, 5=fade-out, 6=arp-fast, 7=arp-slow |
| 11–9    | Volume  | 0–7                                                                               |
| 8–6     | Waveform| 0=sine, 1=tri, 2=saw, 3=square, 4=pulse, 5=organ, 6=noise, 7=phaser               |
| 5–0     | Pitch   | 0–63 (note index)                                                                 |

**Header bytes (offset 64–67 within each SFX slot):**

| Offset | Description                                                |
|--------|------------------------------------------------------------|
| 64     | Filter flags: noiz, buzz, detune, reverb, dampen           |
| 65     | Speed (or BASS flag for custom waveforms)                  |
| 66     | Loop start                                                 |
| 67     | Loop end                                                   |

### 14.4 SFX Command Register

Write to `P8AUDIO_SFX_CMD` (`$800118`) to trigger SFX playback:

```
Bit 15:     Play flag (must be 1)
Bits 14–12: Channel (0–3 = explicit, 7 = auto-assign, 6 = stop-by-index)
Bits 11–6:  Note offset (starting note within the SFX, 0–31)
Bits 5–0:   SFX index (0–63; 63 = stop channel, 62 = release loop)
```

**Play SFX 5 on auto-assigned channel:**
```c
MMIO_REG16(0x800118) = 0x8000 | (7 << 12) | (0 << 6) | 5;
// = 0xF005
```

**Stop channel 2:**
```c
MMIO_REG16(0x800118) = 0x8000 | (2 << 12) | 63;
// = 0xA03F
```

### 14.5 Music Command Register

Write to `P8AUDIO_MUSIC_CMD` (`$80011C`) to control music playback:

```
Bits 14:    Stop flag
Bit  13:    Start flag
Bits 12–7:  Pattern index (0–63)
Bits 6–3:   Channel mask (bit 3 = ch0, bit 4 = ch1, bit 5 = ch2, bit 6 = ch3)
```

**Start music at pattern 0 on all channels:**
```c
MMIO_REG16(0x80011C) = (1 << 13) | (0 << 7) | (0xF << 3);
// = 0x2078
```

**Stop music:**
```c
MMIO_REG16(0x80011C) = (1 << 14);
// = 0x4000
```

**Fade out over 60 frames (1 second):**
```c
MMIO_REG16(0x80011E) = 60;
MMIO_REG16(0x80011C) = (1 << 14);
```

### 14.6 Initialization Sequence

```c
// 1. Write SFX and music data to SRAM
uint8_t *sfx_data = (uint8_t*)0x3200;   // Example address
uint8_t *music_data = (uint8_t*)0x3100;
// ... populate SFX and music data ...

// 2. Configure base addresses
MMIO_REG16(0x800104) = 0x0000;           // SFX base high
MMIO_REG16(0x800106) = 0x3200;           // SFX base low
MMIO_REG16(0x800108) = 0x0000;           // Music base high
MMIO_REG16(0x80010A) = 0x3100;           // Music base low

// 3. Enable audio engine
MMIO_REG16(0x800102) = 0x0001;           // Run

// 4. Play an SFX
MMIO_REG16(0x800118) = 0xF005;           // Auto-channel, SFX 5
```

---

## 15. Debug Registers

| Address    | Name          | Access | Width | Description                    |
|------------|---------------|--------|-------|--------------------------------|
| `$80000C`  | DEBUG_REG_HI  | rw     | 16    | Debug register, bits [31:16]   |
| `$80000E`  | DEBUG_REG_LO  | rw     | 16    | Debug register, bits [15:0]    |

Writes to these registers are printed to the simulation console (via `$display`). They have no effect on real hardware. Useful for printf-style debugging from assembly code.

---

## 16. Tube Interface (Simulation Only)

| Address      | Description                                    |
|--------------|------------------------------------------------|
| `$FFFFFE`    | Stdout byte output (simulation/software model) |
| `$FFFFFF`    | Stderr byte output (simulation/software model) |

These addresses are handled by the software model for console output. They are not mapped to any hardware on the FPGA.

---

## 17. Bootloader

The nextp8 bootloader is a small program that runs from SRAM and loads the main application from an SD card into memory before jumping to it.

### 17.1 Boot File

The bootloader loads a file named `nextp8.bin` from the SD card. The default path is:

- **Default path:** `/machines/NEXTP8/nextp8.bin`

The path can be customized via the configuration block (see §17.4) or overridden using the `--loader-image` command line option (see §17.5).

### 17.2 Memory Layout at Application Entry

When the bootloader transfers control to the main application:

| Register                 | Value                                                    |
|--------------------------|----------------------------------------------------------|
| **SP** (Stack Pointer)   | `memtop - 512` (end of RAM minus 512 bytes)              |
| **PC** (Program Counter) | `0x20000` (128KB into SRAM)                              |
| **FP** (Frame Pointer)   | `0`                                                      |
| **RAM**                  | Application loaded at `0x20000`, zero-padded BSS section |

**Memory map at entry:**

- `0x000000` - `0x1FFFFF` - SRAM (free for application use)
- `0x20000` - Application code/data (loaded from file)
- `memtop - 512` - Initial stack pointer
- `memtop - 256` - Loader data block (256 bytes, read-only for application)
- `memtop - 512` - Config data block (256 bytes, read/write for application)
- `memtop` - Top of detected RAM

**RAM detection:** The bootloader performs a memory test to determine available RAM size (memtop), supporting 1MB to 8MB.

### 17.3 Configuration Block

The configuration block is copied to the new stack location and contains board-level settings:

| Offset | Size | Name | Description |
|--------|------|------|-------------|
| 0 | 1 | video_timing | Video timing mode (0-7) |
| 1 | 1 | scandoubler | Scandoubler (0=off, 1=on) |
| 2 | 1 | frequency | 50Hz/60Hz (0=50, 1=60) |
| 3 | 1 | ps2_mode | PS/2 mode (0=keyboard, 1=mouse) |
| 4 | 1 | scanline_weight | Scanline effect (0=off, 1-3=strength) |
| 5 | 1 | internal_speaker | Internal speaker (0=disabled, 1=enabled) |
| 6 | 1 | hdmi_sound | HDMI sound (0=disabled, 1=enabled) |
| 7-15 | 9 | reserved1 | Reserved |
| 16-31 | 16 | userfile_selected | Userfile selection status |
| 32-63 | 32 | core_path | Null-terminated core path |
| 64-95 | 32 | reserved2 | Reserved |
| 96-254 | 159 | cmdline | Pre-parsed command line arguments |
| 255 | 1 | exit_action | Exit action (0=restart, 1=shutdown) |

**Access (C):**
```c
#include <nextp8.h>

// Access configuration data
extern struct _config_data *_config_data;

// Example: check PS/2 mode
if (_config_data->ps2_mode == 0) {
    // Keyboard mode
}
```

### 17.4 Loader Data Block

Passed 256 bytes above the config block, this block contains bootloader information:

| Offset | Size | Name | Description |
|--------|------|------|-------------|
| 0 | 4 | magic | `LOADER_MAGIC` (0x12345432) |
| 4 | 4 | loader_version | Version: API[31:24], MAJOR[23:16], MINOR[15:8], PATCH[7:0] |
| 8 | 4 | loader_timestamp | Build timestamp |
| 12 | 4 | entry_point | Application entry address (`0x20000`) |
| 16 | 4 | memtop | Total RAM size detected |
| 20 | 1 | reset_type | Reset type (0=power, 1=btn, 2=sw, 3=app_restart) |
| 24-151 | 128 | loaded_path | Null-terminated file path loaded |

**Access (C):**
```c
#include <nextp8.h>

extern struct _loader_data *_loader_data;

// Verify loader data
if (_loader_data->magic == LOADER_MAGIC) {
    printf("Loaded from: %s\n", _loader_data->loaded_path);
    printf("RAM size: %d MB\n", _loader_data->memtop >> 20);
}
```

### 17.5 Command Line Options

**Software model only** (hardware uses SD card):

```
nextp8 [--loader-image <path>] <app_args...>
```

- `--loader-image <path>` - Override SD card path (format: `0:/path/to/file` or absolute path)
- `<app_args...>` - Remaining arguments passed to the application via config cmdline

**Example:**
```bash
# Load from custom path
nextp8 --loader-image 0:/custom/path/app.bin arg1 arg2 arg3

# Application receives:
#   argc = 4
#   argv[0] = "/custom/path/app.bin"
#   argv[1] = "arg1"
#   argv[2] = "arg2"
#   argv[3] = "arg3"
```

**Command line format in config block:**

- Each argument is null-terminated
- Arguments are contiguous in memory
- End marked by empty string (double null terminator)

### 17.6 Boot Sequence Summary

1. **Reset** - CPU starts at vector 1 (PC from vector table)
2. **POST 4-6** - Hardware init (PLL, memory detection)
3. **POST 11-18** - Bootloader runs, displays logo, shows version info
4. **POST 19-22** - Loads application from SD card to `0x20000`
5. **POST 23** - Sets up config/ loader data blocks, jumps to app
6. **Application entry** - SP at `memtop-512`, PC at `0x20000`

---

## 18. SRAM Interface

### 18.1 Characteristics

- **Type:** IS61WV204816BLL-10BLI (4 MB, 16-bit, 10 ns).
- **Address range:** `$000000`–`$3FFFFF` (4 MB, byte-addressed).
- **Access time:** 1 CPU clock cycle.
- **Bus width:** 16-bit. The CPU supports individual byte lane selection via UDS#/LDS# signals.

### 18.2 SRAM and DMA Arbitration

The P8 audio subsystem accesses SRAM via DMA for reading SFX and music data. DMA has priority over CPU accesses:
- When a DMA request is pending, the CPU is stalled until the DMA transfer completes.
- DMA transfers are single-word (16-bit) reads.

---

## 19. MMIO Register Access Model

### 19.1 MMIO Access Types

| Address Range                 | Width        | Cycle Count          | Notes                           |
|-------------------------------|--------------|----------------------|---------------------------------|
| `$000000`–`$3FFFFF` (SRAM)    | 8 or 16 bit  | 1                    | Direct SRAM access              |
| `$800000`–`$8000FF` (MMIO)    | 8 or 16 bit  | 3                    | System peripheral registers     |
| `$800100`–`$8001FF` (P8Audio) | 8 or 16 bit  | 3                    | Audio subsystem registers       |
| `$c00000`–`$c07FFF` (VRAM)    | 8 or 16 bit  | 1 (write) / 3 (read) | Frame buffer BRAM               |
| `$c08000`–`$c0801F` (Palette) | 8 or 16 bit  | 1 (write) / 3 (read) | Palette BRAM                    |
| `$c0c000`–`$c0FFFF` (DA Mem)  | 8 or 16 bit  | 1 (write) / 3 (read) | Audio sample BRAM               |

### 19.2 Register Access Helpers (C)

All driver code should use volatile memory-mapped I/O macros:

```c
#define MMIO_REG8(addr)   (*(volatile uint8_t  *)(addr))
#define MMIO_REG16(addr)  (*(volatile uint16_t *)(addr))
#define MMIO_REG32(addr)  (*(volatile uint32_t *)(addr))
#define MMIO_REG64(addr)  (*(volatile uint64_t *)(addr))
```

### 19.3 Byte Access Alignment

MMIO registers at odd byte addresses (`$800003`, `$800011`, etc.) are accessed as 8-bit reads/writes using the lower data strobe (LDS#). The CPU handles this automatically via the m68k byte-access instructions (`move.b`).

For 16-bit registers, the address must be word-aligned (even). The hardware mirrors 8-bit registers to both byte lanes on reads; writes use only the addressed byte lane.

---

## 20. System Startup Checklist

For RTOS bring-up, the minimum initialization sequence is:

1. **Vector table:** Place initial SSP and PC at `$000000` and `$000004`. Set up exception vectors for bus error, address error, and illegal instruction handlers.
2. **Stack:** Initialize supervisor and (if needed) user stack pointers.
3. **POST code:** Write boot progress to `$800003` for diagnostic visibility.
4. **BSS/Data:** Zero `.bss` section and copy `.data` from ROM (if applicable).
5. **UART:** Write baud rate divider to `$800034` (= 95 for 115200 baud). The UART is then available for console output.
6. **Timer:** The 1 MHz timer at `$800014` is free-running and requires no initialization. Read it for `gettimeofday()` and delay loops.
7. **Interrupts:** Install VBlank ISR at vector 26 (`$68`). Write `$01` to `$800013` to enable. Set CPU IPL appropriately.
8. **Display:** Clear back buffer at `$c00000`. Set default palette at `$c08000`. Call `flip()`.
9. **SD card:** Initialize SPI, then follow SD card initialization sequence (see §10.6).
10. **I2C/RTC:** Read time from DS1307 (see §11.6) if wall-clock time is needed.
11. **Audio:** Set SFX/music base addresses and enable the P8 audio engine (see §14.6).

---

## A. Register Quick Reference

| Address    | Name               | R/W | Width | Section |
|------------|--------------------|-----|-------|---------|
| `$800001`  | PARAMS             | rw  | 16    | §4.1    |
| `$800003`  | POST_CODE          | w   | 6     | §3.5    |
| `$800004`  | BUILD_TIMESTAMP_HI | r   | 16    | §4      |
| `$800006`  | BUILD_TIMESTAMP_LO | r   | 16    | §4      |
| `$800008`  | HW_VERSION_HI      | r   | 16    | §4      |
| `$80000A`  | HW_VERSION_LO      | r   | 16    | §4      |
| `$80000C`  | DEBUG_REG_HI       | rw  | 16    | §16     |
| `$80000E`  | DEBUG_REG_LO       | rw  | 16    | §16     |
| `$800011`  | RESET_TYPE / REQ   | rw  | 8     | §3.3    |
| `$800013`  | VBLANK_INTR_CTRL   | w   | 8     | §5.2    |
| `$800014`  | UTIMER[63:48]      | r   | 16    | §6.1    |
| `$800016`  | UTIMER[47:32]      | r   | 16    | §6.1    |
| `$800018`  | UTIMER[31:16]      | r   | 16    | §6.1    |
| `$80001A`  | UTIMER[15:0]       | r   | 16    | §6.1    |
| `$80001D`  | VFRONT / VFRONTREQ | rw  | 1     | §7.3    |
| `$80001F`  | OVERLAY_CONTROL    | rw  | 8     | §7.5    |
| `$800021`  | SDSPI_WRITE_ENABLE | w   | 1     | §10.2   |
| `$800023`  | SDSPI_DIVIDER      | w   | 8     | §10.2   |
| `$800025`  | SDSPI_DATA_IN      | w   | 8     | §10.2   |
| `$800027`  | SDSPI_DATA_OUT     | r   | 8     | §10.2   |
| `$800029`  | SDSPI_READY        | r   | 1     | §10.2   |
| `$80002B`  | SDSPI_CHIP_SELECT  | w   | 2     | §10.2   |
| `$800031`  | UART_CTRL          | rw  | 8     | §8.2    |
| `$800033`  | UART_DATA          | rw  | 8     | §8.2    |
| `$800034`  | UART_BAUD_DIV      | w   | 16    | §8.2    |
| `$800037`  | ESP_CTRL           | rw  | 8     | §9.2    |
| `$800039`  | ESP_DATA           | rw  | 8     | §9.2    |
| `$80003A`  | ESP_BAUD_DIV       | r   | 16    | §9.2    |
| `$80003D`  | I2C_DATA           | rw  | 8     | §11.2   |
| `$80003F`  | I2C_CTRL / STATUS  | rw  | 8     | §11.2   |
| `$800040`  | DA_CONTROL / ADDR  | rw  | 16    | §13.2   |
| `$800042`  | DA_PERIOD          | w   | 16    | §13.2   |
| `$800049`  | JOYSTICK0          | r   | 8     | §12.1   |
| `$80004B`  | JOYSTICK1          | r   | 8     | §12.1   |
| `$80004D`  | JOYSTICK0_LATCHED  | rw  | 8     | §12.1   |
| `$80004F`  | JOYSTICK1_LATCHED  | rw  | 8     | §12.1   |
| `$800050`  | MOUSE_X            | r   | s16   | §12.3   |
| `$800052`  | MOUSE_Y            | r   | s16   | §12.3   |
| `$800054`  | MOUSE_Z            | r   | s16   | §12.3   |
| `$800057`  | MOUSE_BUTTONS      | r   | 8     | §12.3   |
| `$800059`  | MOUSE_BTNS_LATCHED | rw  | 8     | §12.3   |
| `$800060`  | KEYBOARD_MATRIX    | r   | 256b  | §12.2   |
| `$800080`  | KBD_MATRIX_LATCHED | rw  | 256b  | §12.2   |
| `$800100`  | P8AUDIO_VERSION    | r   | 16    | §14.2   |
| `$800102`  | P8AUDIO_CTRL       | w   | 16    | §14.2   |
| `$800104`  | P8AUDIO_SFX_BASE_HI| w   | 16    | §14.2   |
| `$800106`  | P8AUDIO_SFX_BASE_LO| w   | 16    | §14.2   |
| `$800108`  | P8AUDIO_MUS_BASE_HI| w   | 16    | §14.2   |
| `$80010A`  | P8AUDIO_MUS_BASE_LO| w   | 16    | §14.2   |
| `$80010D`  | P8AUDIO_HWFX40     | w   | 8     | §14.2   |
| `$80010F`  | P8AUDIO_HWFX41     | w   | 8     | §14.2   |
| `$800111`  | P8AUDIO_HWFX42     | w   | 8     | §14.2   |
| `$800113`  | P8AUDIO_HWFX43     | w   | 8     | §14.2   |
| `$800118`  | P8AUDIO_SFX_CMD    | w   | 16    | §14.4   |
| `$80011A`  | P8AUDIO_SFX_LEN    | w   | 16    | §14.2   |
| `$80011C`  | P8AUDIO_MUSIC_CMD  | w   | 16    | §14.5   |
| `$80011E`  | P8AUDIO_MUSIC_FADE | w   | 16    | §14.5   |
| `$800120`–`$800136` | P8AUDIO_STAT46–57 | r | 16 | §14.2  |

---

## B. C Header Definitions

All register addresses and bit definitions are provided in `nextp8-bsp/include/nextp8.h` and `nextp8-bsp/include/mmio.h`. See those files for the canonical definitions used by the BSP.

---

## C. Key Differences from Standard m68k Systems

1. **No bus error / DTACK timeout.** Accesses to unmapped regions return `$FFFF` without generating a bus error.
2. **CDC strobe pattern.** UART and ESP write/read strobes must be held for 4 cycles to ensure cross-clock-domain capture (mclk → clk_sys). This is a hardware requirement.
3. **DMA stalls.** The P8 audio DMA has priority over the CPU. Audio DMA reads cause single-cycle CPU stalls that are transparent to software.
4. **Double-buffered video.** The addresses `$c00000` and `$c02000` always refer to the logical back and front buffers respectively. A buffer flip changes which physical BRAM bank each address maps to.
