'-----------------------------------------------------------------------------------------
'name                     : m8515.bas
'copyright                : (c) 1995-2008, MCS Electronics
'purpose                  : test file for M8515 support
'micro                    : Mega8515
'suited for demo          : yes
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------

$regfile = "m8515.dat"                                      ' specify the used micro
$crystal = 8000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 10                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space

Config Xram = Enabled , Waitstate = 0 , Waitstatehs = 0     'this is the preferred way to configure xram and wait states
'do not use $XA and $WAITSTATE anymore.

Dim I As Byte

For I = 165 To 190
  Osccal = I
  Waitms 100
  Print "Hello world " ; Hex(i)
Next

End