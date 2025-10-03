'-----------------------------------------------------------------------------------------
'name                     : instr.bas
'copyright                : (c) 1995-2005, MCS Electronics
'purpose                  : INSTR function demo
'micro                    : Mega48
'suited for demo          : yes
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------

$regfile = "m48def.dat"                                     ' specify the used micro
$crystal = 4000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 10                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space

'dimension variables
Dim Pos As Byte
Dim S As String * 8 , Z As String * 8

'assign string to search
S = "abcdeab"                                               ' Z = "ab"

'assign search string
Z = "ab"

'return first position in pos
Pos = Instr(s , Z)
'must return 1

'now start searching in the string at location 2
Pos = Instr(2 , S , Z)
'must return 6


Pos = Instr(s , "xx")
'xx  is not in the string so return 0

End