'-----------------------------------------------------------------------------------------
'name                     : 90s8515.bas
'copyright                : (c) 1995-2007, MCS Electronics
'purpose                  : test file for 90S8515 support
'micro                    : 90S8515
'suited for demo          : yes
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------

$regfile = "8515def.dat"                                    ' specify the used micro
$crystal = 8000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 32                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space

Config Xram = Enabled , Waitstate = 1
'do not use $XA and $WAITSTATE anymore.

Dim I As Byte

For I = 1 To 255
  Waitms 100
  Print "Hello world" ; I
Next

End