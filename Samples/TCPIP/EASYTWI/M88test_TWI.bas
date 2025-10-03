'-----------------------------------------------------------------------------------------
'name                     : M88test_TWI.bas
'copyright                : (c) 1995-2005, MCS Electronics
'purpose                  : test Mega88 UART
'micro                    : Mega88
'suited for demo          : yes
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------
$regfile = "m88def.dat"                                     ' specify the used micro

$crystal = 8000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 80                                               ' default use 32 for the hardware stack
$swstack = 80                                               ' default use 10 for the SW stack
$framesize = 80                                             ' default use 40 for the frame space

Dim I As Byte
Print "Mega 88 test"                                        ' display a message
Do
  I = I + 1
  Print I
  Waitms 500
Loop
End