'--------------------------------------------------------------------------------
'name                     : $inc.bas
'copyright                : (c) 1995-2013, MCS Electronics
'purpose                  : demonstrates  $INC
'micro                    : Mega48
'suited for demo          : yes
'commercial addon needed  : no
'--------------------------------------------------------------------------------

'do not confuse $inc with INC and $INCLUDE
'the $INC directive can include BINARY files

$regfile = "m88def.dat"
$crystal = 8000000

Dim Size As Word , W As Word , B As Byte

Restore L1                                                  ' set pointer to label
Read Size                                                   ' get size of the data

Print Size ; " bytes stored at label L1"
For W = 1 To Size
  Read B : Print Chr(b);
Next

End

'include some data here
$inc L1 , Size , "123.bas"
'when you get an error, insert a file you have on your system