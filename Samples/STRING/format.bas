'--------------------------------------------------------------------
'                   (c) 2000-2008 MCS Electronics
'                        Format.bas
'--------------------------------------------------------------------
$regfile = "2313def.dat"
$hwstack = 24
$swstack = 16
$framesize = 16

Dim S As String * 10
Dim I As Integer

S = "12345"
S = Format(s , "+")
Print S

S = "123"
S = Format(s , "00000")
Print S

S = "12345"
S = Format(s , "000.00")
Print S

S = "12345"
S = Format(s , " +000.00")
Print S


End

