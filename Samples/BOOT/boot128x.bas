'-------------------------------------------------------------------------------

'IMPORTANT : Look at BOOTLOADER.BAS which is simpler

'-------------------------------------------------------------------------------
'--------------------------------------------------------------------------------
'name                     : boot128x.bas
'copyright                : (c) 1995-2005, MCS Electronics
'purpose                  : bootloader example for the M128 in M128 mode
'micro                    : Mega128
'suited for demo          : yes
'commercial addon needed  : no
'use in simulator         : not possible
'
'set fusebit KL and M to '1'
'This is a variant of the boot128.bas example
'It will by default jump to location FE00 (bootloader) and waits for 4 magic bytes
'These bytes are &H12 34 56 78
'The terminal emulator can send these bytes!
'Open and load the BootNew.bas program so you can send this program with the loader.

' I M P O R T A N T
' When using the Terminal emulator, the Options, MONITOR, Upload Speed must be the same
' as the baud set in the program. In the example, it must be 19200
' So check this setting


'When it recieves these 4 bytes it will do a reprogramming of the chip
'When these values are not received or nothing is received within the time out value,
'The normal program will execute
'Look for time out register R17. By changing the value you can chance the time out
'--------------------------------------------------------------

'Our communication settings
'$sim                                                        ' simulate
' !!!!!!! REMOVE $SIM when you compile for the real chip

$crystal = 4000000
$baud = 19200
$regfile = "m128def.dat"
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 10                                               'default use 10 for the SW stack
$framesize = 40                                             'default use 40 for the frame space

#if _sim <> 0
   Goto Simlabel                                            ' only when we simulate
#endif
Print "Executing normal program."


'you code would continue here
End

'Include the bootloader code
$include "boot128.inc"