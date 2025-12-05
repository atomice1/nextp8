nextp8 Memory Map
=================

```
$1000000 +------------------------------------------+
         | stderr tube                              |
 $ffffff +------------------------------------------+
         | stdout tube                              |
 $fffffe +------------------------------------------+
         |                                          |
         | reserved                                 |
         |                                          |
 $c10000 +------------------------------------------+
         | PCM audio memory [8192 * 16]             |
         |   mono mode samples: 16-bit signed       |
         |   stereo mode samples: [15:8] R [7:0] L  |
         | alias for current frame buffer           |
 $c0c000 +------------------------------------------+
         | reserved                                 |
 $c08010 +------------------------------------------+
         | screen palette [16 * 8]                  |
 $c08000 +------------------------------------------+
         | frame buffer 2 [126 * 128 * 4]           |
         |   4-bit colour index, packed             |
         |   left to right, top to bottom           |
 $c06000 +------------------------------------------+
         | frame buffer 1 [126 * 128 * 4]           |
         |   4-bit colour index, packed             |
         |   left to right, top to bottom           |
 $c04000 +------------------------------------------+
         | alias for current front buffer           |
 $c02000 +------------------------------------------+
         | alias for current back buffer            |
 $c00000 +------------------------------------------+
         |                                          |
         | reserved                                 |
         |                                          |
 $800200 +------------------------------------------+
         | audio subsystem                          |
         |                                          |
 $800130 | STAT56 [r] [16]                          |
 $80012e | STAT55 [r] [16]                          |
 $80012c | STAT54 [r] [16]                          |
 $80012a | STAT53 [r] [16]                          |
 $800128 | STAT52 [r] [16]                          |
 $800126 | STAT51 [r] [16]                          |
 $800124 | STAT50 [r] [16]                          |
 $800122 | STAT49 [r] [16]                          |
 $800120 | STAT48 [r] [16]                          |
 $80011e | STAT47 [r] [16]                          |
 $80011c | STAT46 [r] [16]                          |
 $80011a | MUSIC fade time (frames) [w] [16]        |
 $800118 | MUSIC command register [w] [16]          |
 $800116 | SFX length override [w] [16]             |
 $800114 | SFX command register [w] [16]            |
 $800112 | note release time (samples) [w] [16]     |
 $800110 | note attack time (samples) [w] [16]      |
 $80010f | HWFX 0x5f43 [w] [8]                      |
 $80010e | HWFX 0x5f42 [w] [8]                      |
 $80010d | HWFX 0x5f41 [w] [8]                      |
 $80010c | HWFX 0x5f40 [w] [8]                      |
 $80010a | MUSIC base lo [w] [16]                   |
 $800108 | MUSIC base hi [w] [16]                   |
 $800106 | SFX base lo [w] [16]                     |
 $800104 | SFX base hi [w] [16]                     |
 $800102 | control [w] [16]                         |
         |  [0] run                                 |
 $800100 | version [r] [16]                         |
         |                                          |
 $800100 +------------------------------------------+
         | reserved                                 |
 $800080 +------------------------------------------+
         | memory mapped ports                      |
         |                                          |
 $80006b | mouse buttons [r] [3]                    |
         |  [0] left [1] right [2] middle           |
         |  [3] buton 4 [4] button 5                |
 $80006a | mouse z [r] [8]                          |
 $800069 | mouse y [r] [8]                          |
 $800068 | mouse x [r] [8]                          |
 $800061 | joystick 1 [r] [8]                       |
         |  [0] up [1] down [2] left [3] right      |
         |  [4] button 1 [5] button 2               |
 $800060 | joystick 0 [r] [8]                       |
         |  [0] up [1] down [2] left [3] right      |
         |  [4] button 1 [5] button 2               |
 $800040 | keyboard matrix [r] [256]                |
         |   bit index = PS/2 scan code (set 2)     |
         |   extended scan codes | 0x80             |
 $800038 | PCM audio period [w] [16]                |
         |   1 / 11 000 000 ticks                   |
 $800034 | PCM audio control [w] [16]               |
         |   [0] start [8] mono                     |
         | PCM audio address [r] [16]               |
 $800034 | 1MHz tick count lo [16]                  |
 $800032 | 1Mhz tick count hi [16]                  |
 $800030 | 1MHz tick count lo [16]                  |
 $80002e | 1Mhz tick count hi [16]                  |
 $80002a | ESP UART baud rate divider [r] [16]      |
 $800029 | ESP UART read / write data [r/w] [8      |
 $800028 | ESP UART status / control [8]            |
         |   [r] [0] data ready [1] ready           |
         |       [2] read ack [3] write ack         |
         |   [w] [0] write strobe [1] read strobe   |
 $800026 | Pi UART baud rate divider [w] [16]       |
 $800025 | Pi UART read / write data [r/w] [8]      |
 $800024 | Pi UART status / control [8]             |
         |   [r] [0] data ready [1] ready           |
         |       [2] read ack [3] write ack         |
         |   [w] [0] write strobe [1] read strobe   |
 $800023 | I2C status / control [8]                 |
         |   [r] [0] busy [1] error                 |
         |   [w] [0] enable [1] rw                  |
 $800021 | I2C read / write data [8]                |
 $80001a | version lo [16]                          |
 $800018 | version hi [16]                          |
 $800016 | build timestamp lo [16]                  |
 $800014 | build timestmap hi [16]                  |
 $800012 | parameters [16]                          |
         |   [0] 0=keyboard at PS/2 port; 1=mouse   |
 $80000E | vfront [r] / vfrontreq [w] [1]           |
 $80000C | POST code [w] [6]                        |
 $80000A | SDSPI chip select [w] [1]                |
 $800008 | SDSPI read ready [r] [1]                 |
 $800006 | SDSPI data out [r] [8]                   |
 $800004 | SDSPI data in [w] [8]                    |
 $800002 | SDSPI divider [w] [8]                    |
 $800000 | SDSPI write enable [w] [1]               |
         |                                          |
 $800000 +------------------------------------------+
         |                                          |
         | reserved for RAM expansion               |
         |                                          |
 $200000 +------------------------------------------+
         |                                          |
         | SRAM                                     |
         |                                          |
      $0 +------------------------------------------+
```
