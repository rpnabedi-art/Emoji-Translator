'--------------------------------------------------------------
'                   (c) 1999-2007 MCS Electronics
'--------------------------------------------------------------
'  file: INCLUDE.BAS
'  demo: $INCLUDE
'--------------------------------------------------------------
$regfile = "m88def.dat"
Config Submode = New

Sub Test()
   Print "test"
End Sub


Print "INCLUDE.BAS"
'Note that the file 123.bas contains an error
' So this file WILL and MUST result in an error !!!
  $include "123.bas"                                        'include file that prints Hello
Print "Back in INCLUDE.BAS"
Test
End
