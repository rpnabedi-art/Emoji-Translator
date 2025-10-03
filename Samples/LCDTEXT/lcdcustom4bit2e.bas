'------------------------------------------------------------------
'                          LCDCUSTOM4BITE2.BAS
'                 demo shows 4 bit LCD mode with 2 E lines
'------------------------------------------------------------------
$regfile = "2313def.dat"
$hwstack = 32
$swstack = 16
$framesize = 24


' this is the custom LCD lib
$lib "Lcd4e2.lib"

$crystal = 4000000

'to use 2 E lines we need a way to make a distinct between them
Dim ___lcde As Byte
'___LCDE set to 0 will use E1, set to any other value will use E2

Dim S As String * 10
S = "Hello"

' write to the 2 first lines
___lcde = 0

Cls

Lcd "test"
Lcd S

___lcde = 1
'write to the 2 last lines
Lcd "test"
Lcd S

End