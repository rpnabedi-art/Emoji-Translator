'------------------------------------------------------------------------------
'name                     : printbin.bas
'copyright                : (c) 1995-2005, MCS Electronics
'purpose                  : demonstrates PRINTBIN
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



Dim B As Byte
B = 65

'this will convert the value 65 to a string "65" and print it
Print B

'this will print the character itself
Print Chr(b)

'this will write the byte value
Printbin B

'when using a word, it will write to 2 bytes
Dim W As Word
W = &H4142
Printbin W

Dim Ar(4) As Byte

'test inputbin too
Inputbin Ar(1)
For B = 1 To 4
  Print Ar(b) ; Spc(4);
Next

End
