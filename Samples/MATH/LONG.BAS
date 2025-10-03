'------------------------------------------------------------
'                 (C) 1999-2003 MCS Electronics
'                      LONG.BAS
'long ranges from -2147483648 to 2147483647
'------------------------------------------------------------
$regfile = "m48def.dat"
$hwstack = 40
$swstack = 16
$framesize = 24


Dim I As Integer , L1 As Long , L2 As Long , L3 As Long
Dim Xi As Integer
Dim Xl1 As Long , Xl2 As Long , Xl3 As Long

I = 1000 : Xi = -1000                                         'assign integers
L1 = I : Print L1                                             'convert to long
L1 = Xi : Print L1                                            'convert to long


L1 = 1000                                                     'long assign
Xl1 = L1 : Xl2 = 2000                                         'long assign
L2 = Xl2
Print L2 ; "  " ; Xl2

Xl1 = 1000 : L2 = 5000
Xl3 = Xl1 * L2 : Print Xl3

Input "number1 " , L1
Input "number2 " , L2


L3 = L1 + L2 : Print L3
L3 = L1 - L2 : Print L3
L3 = L1 * L2 : Print L3
L3 = L1 / L2 : Print L3
L3 = L1 Mod L2 : Print L3
L3 = L1 And L2 : Print L3
L3 = L1 Or L2 : Print L3
L3 = L1 Xor L2 : Print L3


Inputhex "Long HEX " , L1                                     'note that 8 bytes must be entered
Print Hex(l1)
End