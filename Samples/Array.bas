'-----------------------------------------------------------------------
'name                     : array.bas
'copyright                : (c) 1995-2013, MCS Electronics
'purpose                  : show using arrays
'suited for demo          : yes
'commercial addon needed  : no
'use in simulator         : possible
'----------------------------------------------------------------------
$regfile = "m162def.dat"                                    ' specify the used micro
$crystal = 8000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 10                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space


'Since we use a large amount of RAM, we need to use XRAM
'some modern chips have 8KB or 16KB or even 32 KB memory !
'but this demo was created in 1997 when you needed XRAM for more memory

$default Xram                                               'this switch will tell the compiler that all DIM statements are DIM <name> AS XRAM

Dim Idx1 As Integer                                         'index
Dim B1(1000) As Byte                                        'byte array
Dim I(500) As Integer                                       'integer array
Dim S(100) As String * 20                                   'string array , each string can be 20 characters long

For Idx1 = 1 To 10                                          'fill part of array
  B1(idx1) = Idx1
  I(idx1) = Idx1
  S(idx1) = Str(b1(idx1))                                   'assign a string
Next

For Idx1 = 1 To 10                                          'print the first 10
  Print B1(idx1) ; "  " ; I(idx1) ; " " ; S(idx1)
Next

End