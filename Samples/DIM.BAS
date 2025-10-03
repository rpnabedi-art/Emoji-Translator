'-----------------------------------------------------------------------------------------
'name                     : dim.bas
'copyright                : (c) 1995-2013, MCS Electronics
'purpose                  : demo: DIM
'micro                    : Mega48
'suited for demo          : yes
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------

$regfile = "m48def.dat"                                     ' specify the used micro
$crystal = 8000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 10                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space

Dim B1 As Bit                                               'bit can be 0 or 1
Dim A As Byte                                               'byte range from 0-255
Dim C As Integer                                            'integer range from -32767 - +32768
Dim L As Long
Dim W As Word
Dim S As String * 11                                        'length can be up to 11 characters

'new feature : you can specify the address of the variable
Dim K As Integer At &H120

'the next dimensioned variable will be placed after variable s
Dim Kk As Integer


'Assign bits
B1 = 1                                                      'or
Set B1                                                      'use set

'Assign bytes
A = 12
A = A + 1

'Assign integer
C = -12
C = C + 100
Print C

W = 50000
Print W

'Assign long
L = 12345678
Print L

'Assign string
S = "Hello world"
Print S

End