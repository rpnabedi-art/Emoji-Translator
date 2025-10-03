'-----------------------------------------------------------------------------------------
'name                     : m8535.bas
'copyright                : (c) 1995-2005, MCS Electronics
'purpose                  : test file for M8535 support
'micro                    : Mega8535
'suited for demo          : yes
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------
'!!!!!!!!! The default oscillator speed is 1 Mhz !!!!!!!

$regfile = "m8535.dat"                                      ' specify the used micro
$crystal = 8000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 10                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space

Dim I As Byte

For I = 1 To 255
  Waitms 100
  Print "Hello world" ; I
Next

End