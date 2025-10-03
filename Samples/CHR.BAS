'-----------------------------------------------------------------------------------------
'name                     : chr.bas
'copyright                : (c) 1995-2013, MCS Electronics
'purpose                  : shows how to use the CHR() and BCD() function and
'                           CHR() function in combination with a PRINT statement
'micro                    : Mega48
'suited for demo          : yes
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------

$regfile = "m88def.dat"                                     ' specify the used micro
$crystal = 8000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 10                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space

Dim K As Byte

K = 65
Print K ; Chr(k) ; K ; Chr(66) ; Bcd(k) ; Hex(k)


End