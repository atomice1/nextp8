nextp8 Platform
===============

Hardware
--------

[nextp8-core](https://github.com/atomice1/nextp8-core)

### Introduction

The FPGA image implements the Pico-8 hardware... But that's not entirely true because the Pico-8 is a fantasy console so there is no real hardware! In fact Pico-8's fantasy hardware can't always be directly translated to real hardware. For this reason the FPGA image doesn't implement the Pico-8 fantasy hardware exactly because it doesn't always map well to real hardware.

### CPU

The nextp8 uses a m68k CPU with 32-bit registers and a 16-bit data bus. The Pico-8 does not have a native machine code, so it does not dictate a particular CPU architecture.

### Display Processor

The display processor uses a frame buffer layout corresponding exactly to the Pico-8 screen memory layout. It supports a 16 colour display palette drawn from a 32 colour hardware palette. The 128x128 Pico-8 screen is centered and zoomed 6x. The output resolution is 1024x768@60Hz.

The display processor supports native double buffering and the system contains VRAM for both the front and the back buffer, as well as an overlay front and back buffer used for the pause menu, etc.

### Audio Processor

The audio processor implements the Pico-8 SFX and MUSIC. The note timing exactly matches the Pico-8, however the instrument waveforms, effects and filters are approximations. Custom instruments, including PCM instruments are supported.

The audio processor directly reads SFX data and MUSIC patterns from memory using DMA. It has priority over the CPU.

The SFX core also supports custom instruments where the custom instrument SFX core PCM output is input to the main SFX core.

### Peripherals

* 2 x Joysticks
* Keyboard (PS/2 and membrane)
* Mouse (PS/2)
* SD card (SD-SPI)
* Wi-fi (ESP-01)
* Real-time Clock

### Memory Map

View the [memory map](memory_map.md).

nextp8 Software
---------------

### Firmware

[femto8-nextp8](https://github.com/atomice1/femto8-nextp8)

The nextp8 firmware is based on Ben Baker's femto8, ported to the nextp8 hardware. femto8 contains a Lua interpreter and the Pico-8 standard library routines. The display and audio are handled by the nextp8 hardware.

### Bootloader

[nextp8-loader](https://github.com/atomice1/nextp8-loader)

The nextp8 bootloader is loaded by the Next core loader before resetting into the nextp8 core. It functions as the nextp8 'ROM' and is responsible for loading the main firmware.

### Board Support Package (BSP)

[nextp8-bsp](https://github.com/atomice1/nextp8-bsp)

The BSP is based on newlib. It contains drivers for the SD card in SPI mode and the FAT32 filesystem, as well as basic frame buffer support.

### Toolchain

[m68k-elf-gcc](https://github.com/atomice1/m68k-elf-gcc)

The toolchain is based on GCC, binutils and newlib.

### Software Model

[sQLux-nextp8](https://github.com/atomice1/sQLux-nextp8/)

The nextp8 software model is designed to facilitate pre-silicon firmware development. It is based on the sQLux Sinclair QL emulator but has been heavily modified for nextp8.
