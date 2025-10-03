'-----------------------------------------------------------
'            Sample : ON .. GOSUB/GOTO
'            Copyright 1999-2013 MCS Electronics
'-----------------------------------------------------------
$RegFile = "m88def.dat"
$crystal = 8000000
$baud = 19200

Dim A As Byte
Input "Enter value 0-2 " , A                                  'ask for input
Rem Note That The Starting Value Begins With 0
On A Gosub L0 , L1 , L2
Print "Returned"

If Portb < 2 Then                                             'you can also use the portvalue
   On Portb Goto G0 , G1
End If
End_prog:
   End


L0:
   Print "0 entered"
Return

L1:
   Print "1 entered"
Return

L2:
   Print "2 entered"
Return

G0:
   Print "P1 = 0"
   Goto End_prog

G1:
   Print "P1 = 1"
Goto End_prog