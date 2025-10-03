'------------------------------------------------------------------------------
'name                     : binval.bas
'copyright                : (c) 1995-2013, MCS Electronics
'purpose                  : demonstrates
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

Dim S As String * 8
S = "11001100"

Dim B As Byte
' assign value to B
B = Binval(s)

Print B

End