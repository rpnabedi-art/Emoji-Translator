'------------------------------------------------------------------
'                          LCD4.BAS
'  demo shows 4 bit LCD mode with custom lib
'------------------------------------------------------------------
' this example uses the custom LCD4.LIB
' you can change this lib when needed
$lib "Lcd4.lib"
$hwstack = 40
$swstack = 40
$framesize = 40


$crystal = 4000000

Dim S As String * 10
S = "Hello"

Cls

Lcd "test"
Lcd S

End
