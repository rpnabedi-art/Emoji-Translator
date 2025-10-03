'------------------------------------------------------------------------------
'name                     : bin.bas
'copyright                : (c) 1995-2013, MCS Electronics
'purpose                  : demonstrates BIN() function
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

Dim B As Byte
B = 45

Dim S As String * 10
S = Bin(b)

Portb = 33
Print Bin(portb)

'or print an input
Config Portb = Input
Print Bin(pinb)
End