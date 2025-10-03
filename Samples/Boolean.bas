'--------------------------------------------------------------------------------
'name                     : boolean.bas
'copyright                : (c) 1995-2013, MCS Electronics
'purpose                  : demo: AND, OR, XOR, NOT, BIT, SET, RESET and MOD
'suited for demo          : yes
'commercial add on needed : no
'use in simulator         : possible
'--------------------------------------------------------------------------------
'This very same program example can be used in the Help-files for
'      AND, OR, XOR, NOT, BIT, SET, RESET and MOD


$baud = 19200
$crystal = 8000000
$regfile = "m88def.dat"

$hwstack = 40
$swstack = 20
$framesize = 20

Dim A As Byte , B1 As Byte , C As Byte
Dim Aa As Bit , I As Integer

A = 5 : B1 = 3                                              ' assign values
C = A And B1                                                ' and a with b
Print "A And B1 = " ; C                                     ' print it: result = 1


C = A Or B1
Print "A Or B1 = " ; C                                      ' print it: result = 7

C = A Xor B1
Print "A Xor B1 = " ; C                                     ' print it: result = 6

A = 1
C = Not A
Print "c = Not A " ; C                                      ' print it: result = 254
C = C Mod 10
Print "C Mod 10 = " ; C                                     ' print it: result = 4


If Portb.1 = 1 Then                                         'test a bit from a PORT (which is not the same as testing the input state)
  Print "Bit set"
Else
  Print "Bit not set"
End If                                                      'result = Bit not set

Config Pinb.0 = Input : Portb.0 = 1                         'configure as input pin
Do
Loop Until Pinb.0 = 0                                       ' repeat this loop until the logic level becomes 0

Aa = 1                                                      'use this or ..
Set Aa                                                      'use the set statement
If Aa = 1 Then
  Print "Bit set (aa=1)"
Else
  Print "Bit not set(aa=0)"
End If                                                      'result = Bit set (aa=1)

Aa = 0                                                      'now try 0
Reset Aa                                                    'or use reset
If Aa = 1 Then
  Print "Bit set (aa=1)"
Else
  Print "Bit not set(aa=0)"
End If                                                      'result = Bit not set(aa=0)

C = 8                                                       'assign variable to &B0000_1000
Set C                                                       'use the set statement without specifying the bit
Print C                                                     'print it: result = 9 ; bit0 has been set

B1 = 255                                                    'assign variable
Reset B1.0                                                  'reset bit 0 of a byte variable
Print B1                                                    'print it: result = 254 = &B11111110

B1 = 8                                                      'assign variable to &B00001000
Set B1.7                                                    'set it
Print B1                                                    'print it: result = 9 = &B00001001
End