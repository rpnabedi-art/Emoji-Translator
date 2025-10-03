'-------------------------------------------------------------------------------
'copyright                : (c) 1995-2005, MCS Electronics
'micro                    : Mega48
'suited for demo          : yes
'commercial addon needed  : no
'purpose                  : demonstrates FRAC function
'-------------------------------------------------------------------------------

$regfile = "m48def.dat"                                     ' specify the used micro
$crystal = 8000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 40                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space


Dim X As Single

X = 1.123456
Print X
Print Frac(x)

End