'--------------------------------------------------------------------------------
'name                     : bits-nbits.bas
'copyright                : (c) 1995-2013, MCS Electronics
'purpose                  : demo for Bits() AND Nbits()
'micro                    : Mega48
'suited for demo          : yes
'commercial addon needed  : no
'use in simulator         : possible
'--------------------------------------------------------------------------------

$regfile = "m48def.dat"                                     ' specify the used micro
$crystal = 8000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 10                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space

Dim B As Byte

'while you can use &B notation for setting bits, like B = &B1000_0111
'there is also an alternative by specifying the bits to set
B = Bits(0 , 1 , 2 , 7)                                     'set only bit 0,1,2 and 7
Print B

'and while bits() will set all bits specified to 1, there is also Nbits()
'the N is for NOT. Nbits(1,2) means, set all bits except 1 and 2
B = Nbits(7)                                                'do not set bit 7
Print B
End