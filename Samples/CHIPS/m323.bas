'-----------------------------------------------------------------------------------------
'name                     : m323.bas
'copyright                : (c) 1995-2005, MCS Electronics
'purpose                  : demo for M323
'micro                    : Mega323
'suited for demo          : yes
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------

$regfile = "m323def.dat"                                    ' specify the used micro
$crystal = 4000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 10                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space


'This file is intended to test the M323
'The M323 has the JTAG enabled by default so you can not use
'pins PORTC.2-PORTC.5

'Use the following code to disable JTAG
Mcusr = &H80
Mcusr = &H80

'Or program the fuse bit
