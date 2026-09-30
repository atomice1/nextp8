PICO-8 Compatibility
====================

Features
--------

* PICO-8 Lua dialect
* 16.16 fixed point numbers
* SFX and MUSIC sequencer
* PCM audio
* Cart load and save
* Persistent cart data
* 32-colour palette
* Screen mirroring and rotation
* Gradient fill / high colour mode
* 30 fps and 60 fps frame rates
* Keyboard and mouse support
* Two joystick support
* 2MB Lua heap

Limitations
-----------

* The SFX instruments are approximations.
* The circle and oval drawing algorithm is not pixel perfect.
* Heap fragmentation may cause some carts to exhaust the Next's physical memory ("out of memory" error).
* SFX in print() strings are silently ignored.
* extcmd() is limited to pause, reset, shutdown, breadcrumb.
* serial() is limited to Pi serial, PCM audio and delay. ESP serial is not supported.
* GPIOs are not supported.
* Some rarely used undocumented functions are not supported.
* Multiple screens are not supported.
