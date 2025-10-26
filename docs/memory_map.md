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
 $800080 +------------------------------------------+
         | memory mapped ports                      |
         |                                          |
         | mouse buttons [r] [3]                    |
         |  [0] left [1] right [2] middle           |
 $80006b |  [3] buton 4 [4] button 5                |
 $80006a | mouse z [r] [8]                          |
 $800069 | mouse y [r] [8]                          |
 $800068 | mouse x [r] [8]                          |
         | joystick 1 [r] [8]                       |
         |  [0] up [1] down [2] left [3] right      |
 $800061 |  [4] button 1 [5] button 2               |
         | joystick 0 [r] [8]                       |
         |  [0] up [1] down [2] left [3] right      |
 $800060 |  [4] button 1 [5] button 2               |
         | keyboard matrix [r] [256]                |
         |   bit index = PS/2 scan code (set 2)     |
 $800040 |   extended scan codes | 0x80             |
         | PCM audio period [w] [16]                |
 $800036 |   1 / 11 000 000 ticks                   |
         | PCM audio control [w] [16]               |
         |   [0] start [8] mono                     |
 $800034 | PCM audio address [r] [16]               |
 $800032 | 1MHz tick count lo                       |
 $800030 | 1Mhz tick count hi                       |
 $80001E | core ID [16]                             |
 $800012 | parameters [16]                          |
         |   [0] 0=keyboard at PS/2 port; 1=mouse   |
 $00000E | vfront [r] / vfrontreq [w] [1]           |
 $00000C | POST code [w] [6]                        |
 $00000A | SDSPI chip select [w] [1]                |
 $000008 | SDSPI read ready [r] [1]                 |
 $000006 | SDSPI data out [r] [8]                   |
 $000004 | SDSPI data in [w] [8]                    |
 $000002 | SDSPI divider [w] [8]                    |
 $000000 | SDSPI write enable [w] [1]               |
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
