'-----------------------------------------------------------------------------------------
'name                     : minmax.bas
'copyright                : (c) 1995-2013, MCS Electronics
'purpose                  : show the MIN and MAX functions
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


' These functions only works on BYTE and WORD arrays at the moment !!!!!

'Dim some variables
Dim Wb As Byte , B As Byte
Dim W(10) As Word                                           ' or use a BYTE array

'fill the word array with values from 1 to 10
For B = 1 To 10
  W(b) = B
Next

Print "Max number " ; Max(w(1))
Print "Min number " ; Min(w(1))

Dim Idx As Word , M1 As Word
Min(w(1) , M1 , Idx)
Print "Min number " ; M1 ; " index " ; Idx

Max(w(1) , M1 , Idx)
Print "Max number " ; M1 ; " index " ; Idx
End