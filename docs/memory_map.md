nextp8 Memory Map
=================

```
$1000000 +------------------------------------------+
         |                                          |
         | reserved                                 |
         |                                          |
 $c10000 +------------------------------------------+
         | PCM audio memory [8192 * 16]             |
         |   mono mode samples: 16-bit signed       |
         |   stereo mode samples: [15:8] R [7:0] L  |
 $c0c000 +------------------------------------------+
         | reserved                                 |
 $c08020 +------------------------------------------+
         | screen palette front [16 * 8]            |
 $c08010 +------------------------------------------+
         | screen palette back [16 * 8]             |
 $c08000 +------------------------------------------+
         | current overlay front buffer             |
         |   [128 * 128 * 4]                        |
         |   4-bit colour index, packed             |
         |   left to right, top to bottom           |
 $c06000 +------------------------------------------+
         | current overlay back buffer              |
         |   [128 * 128 * 4]                        |
         |   4-bit colour index, packed             |
         |   left to right, top to bottom           |
 $c04000 +------------------------------------------+
         | current front buffer                     |
         |   [128 * 128 * 4]                        |
         |   4-bit colour index, packed             |
         |   left to right, top to bottom           |
 $c02000 +------------------------------------------+
         | current back buffer                      |
         |   [128 * 128 * 4]                        |
         |   4-bit colour index, packed             |
         |   left to right, top to bottom           |
 $c00000 +------------------------------------------+
         |                                          |
         | reserved                                 |
         |                                          |
 $800200 +------------------------------------------+
         | audio subsystem                          |
         |                                          |
 $800134 | STAT56 [r] [16]                          |
 $800132 | STAT55 [r] [16]                          |
 $800130 | STAT54 [r] [16]                          |
 $80012e | STAT53 [r] [16]                          |
 $80012c | STAT52 [r] [16]                          |
 $80012a | STAT51 [r] [16]                          |
 $800128 | STAT50 [r] [16]                          |
 $800126 | STAT49 [r] [16]                          |
 $800124 | STAT48 [r] [16]                          |
 $800122 | STAT47 [r] [16]                          |
 $800120 | STAT46 [r] [16]                          |
 $80011e | MUSIC fade time (frames) [w] [16]        |
 $80011c | MUSIC command register [w] [16]          |
 $80011a | SFX length override [w] [16]             |
 $800118 | SFX command register [w] [16]            |
 $800116 | note release time (samples) [w] [16]     |
 $800114 | note attack time (samples) [w] [16]      |
 $800113 | HWFX 0x5f43 [w] [8]                      |
 $800111 | HWFX 0x5f42 [w] [8]                      |
 $80010f | HWFX 0x5f41 [w] [8]                      |
 $80010d | HWFX 0x5f40 [w] [8]                      |
 $80010a | MUSIC base lo [w] [16]                   |
 $800108 | MUSIC base hi [w] [16]                   |
 $800106 | SFX base lo [w] [16]                     |
 $800104 | SFX base hi [w] [16]                     |
 $800102 | control [w] [16]                         |
         |   [0] run                                |
 $800100 | version [r] [16]                         |
         |                                          |
 $800100 +------------------------------------------+
         | reserved                                 |
 $8000a0 +------------------------------------------+
         | memory mapped ports                      |
         |                                          |
 $800080 | latched keyboard matrix [rw] [256]       |
         |   bit index = PS/2 scan code (set 2)     |
         |   extended scan codes | 0x80             |
 $800060 | keyboard matrix [r] [256]                |
         |   bit index = PS/2 scan code (set 2)     |
         |   extended scan codes | 0x80             |
 $800059 | latched mouse buttons [rw] [8]           |
         |   write to clear latched bits            |
 $800057 | mouse buttons [r] [8]                    |
         |   [0] left [1] right [2] middle          |
         |   [3] button 4 [4] button 5              |
 $800054 | mouse z [r] [signed 16]                  |
         |   scroll wheel position accumulator      |
 $800052 | mouse y [r] [signed 16]                  |
         |   vertical position accumulator          |
 $800050 | mouse x [r] [signed 16]                  |
         |   horizontal position accumulator        |
 $80004f | latched joystick 1 [rw] [8]              |
         |  [0] up [1] down [2] left [3] right      |
         |  [4] button 1 [5] button 2               |
 $80004d | latched joystick 0 [rw] [8]              |
         |  [0] up [1] down [2] left [3] right      |
         |  [4] button 1 [5] button 2               |
 $80004b | joystick 1 [r] [8]                       |
         |  [0] up [1] down [2] left [3] right      |
         |  [4] button 1 [5] button 2               |
 $800049 | joystick 0 [r] [8]                       |
         |  [0] up [1] down [2] left [3] right      |
         |  [4] button 1 [5] button 2               |
 $800042 | PCM audio period [w] [16]                |
         |   1 / 11 000 000 ticks                   |
 $800040 | PCM audio control [w] [16]               |
         |   [0] start [8] mono                     |
         | PCM audio address [r] [16]               |
 $80003f | I2C status / control [8]                 |
         |   [r] [0] busy [1] error                 |
         |   [w] [0] enable [1] rw                  |
 $80003d | I2C read / write data [8]                |
 $80003a | ESP UART baud rate divider [r] [16]      |
 $800039 | ESP UART read / write data [rw] [8]      |
 $800037 | ESP UART status / control [8]            |
         |   [r] [0] data ready [1] ready           |
         |       [2] read ack [3] write ack         |
         |   [w] [0] write strobe [1] read strobe   |
 $800034 | Pi UART baud rate divider [w] [16]       |
 $800033 | Pi UART read / write data [rw] [8]       |
 $800031 | Pi UART status / control [8]             |
         |   [r] [0] data ready [1] ready           |
         |       [2] read ack [3] write ack         |
         |   [w] [0] write strobe [1] read strobe   |
 $80002B | SDSPI chip select [w] [2]                |
 $800029 | SDSPI read ready [r] [1]                 |
 $800027 | SDSPI data out [r] [8]                   |
 $800025 | SDSPI data in [w] [8]                    |
 $800023 | SDSPI divider [w] [8]                    |
 $800021 | SDSPI write enable [w] [1]               |
 $80001f | overlay control [w] [8]                  |
         |   [3:0] transparent index [6] enable     |
 $80001d | vfront [r] / vfrontreq [w] [1]           |
 $80001a | 1MHz tick count [63:48] [16]             |
 $800018 | 1Mhz tick count [47:32] [16]             |
 $800016 | 1MHz tick count [31:16] [16]             |
 $800014 | 1Mhz tick count [15:0] [16]              |
 $800013 | vblank interrupt control [w] [8]         |
         |   [0] 0=disable and clear IRQ            |
         |       1=enable and clear IRQ             |
 $800011 | reset type                               |
         |   [r] [2] 00=power-on, 01=button, 10=sw  |
         |   [w] 01=sw-initiated reset              |
 $80000f | POST code [w] [6]                        |
 $80000c | debug reg lo [w] [16]                    |
 $80000a | debug reg hi [w] [16]                    |
 $800008 | version lo [16]                          |
 $800006 | version hi [16]                          |
 $800004 | build timestamp lo [16]                  |
 $800002 | build timestmap hi [16]                  |
 $800000 | parameters [16]                          |
         |   [0] 0=keyboard at PS/2 port; 1=mouse   |
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
