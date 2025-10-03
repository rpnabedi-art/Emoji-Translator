 '------------------------------------------------------------------------------
'name                     : simtest.bas
'copyright                : (c) 1995-2005, MCS Electronics
'purpose                  : demonstrates simulator input test file
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

Dim Nm As String * 10

Do
  Input Nm
  Print "Got Nm"
Loop