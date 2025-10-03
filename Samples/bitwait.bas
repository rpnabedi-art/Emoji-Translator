'------------------------------------------------------------------------------
'name                     : bitwait.bas
'copyright                : (c) 1995-2013, MCS Electronics
'purpose                  : demonstrates bitwait
'micro                    : Mega48
'suited for demo          : yes
'commercial addon needed  : no
'------------------------------------------------------------------------------

$regfile = "m48def.dat"                                     ' specify the used micro
$crystal = 8000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 10                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space

Dim A As Bit
Bitwait A , Set                                             'wait until bit a is set
'the above will never contine because it is not set i software
'it could be set in an ISR routine

Bitwait Pinb.7 , Reset                                      'wait until bit 7 of Port B is 0.
End