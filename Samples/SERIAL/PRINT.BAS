'------------------------------------------------------------------------------
'name                     : print.bas
'copyright                : (c) 1995-2005, MCS Electronics
'purpose                  : demonstrates  PRINT
'micro                    : Mega48
'suited for demo          : yes
'commercial addon needed  : no
'------------------------------------------------------------------------------
$regfile = "m48def.dat"                                     ' we use the M48
$crystal = 8000000
$baud = 19200

$hwstack = 32
$swstack = 8
$framesize = 24

Dim A As Byte , B1 As Byte , C As Integer , S As String * 4
A = 1
Print "print variable a " ; A
Print                                                         'new line
Print "Text to print."                                        'constant to print


B1 = 10
Print Hex(b1)                                                 'print in hexa notation
C = &HA000                                                    'assign value to c%
Print Hex(c)                                                  'print in hex notation
Print C                                                       'print in decimal notation

C = -32000
Print C
Print Hex(c)
Rem Note That Integers Range From -32767 To 32768

Print "You can also use multiple" _
; "lines using _"
Print "use it for long lines"
'From version 1.11.6.4 :
A = &B1010_0111
Print Bin(a)
S = "1001"
A = Binval(s)
Print A                                                     '9 dec
End