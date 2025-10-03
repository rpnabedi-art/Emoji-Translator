'-------------------------------------------------------------------------------
'                               (c) 2004 MCS Electronics
' This sample show the handling with DOUBLE - floating point numbers
' The DOUBLE library and samples are written by Josef Franz Vögel
'-------------------------------------------------------------------------------
'Mega162 was used for compilation. See double1.bas sample

' Double is floating point format which stores a number in 8 Bytes
' Rangle of DOUBLE is from ~ E-308 to ~ E308
' You need version BASACOM-AVR Version 1.11.7.5 (or higher)

$regfile = "m162def.dat"
$hwstack = 40
$swstack = 40
$framesize = 40


Dim D1 As Double , D2 As Double , D3 As Double , D4 As Double
Dim B1 As Byte


Do
   ' read in 2 Double numbers from User input
   Input "Enter D1 " , D1                                   'ask for 2 values
   Input "Enter D2 " , D2
   Print "You entered:"
   Print "D1: " ; D1
   Print "D2: " ; D2

   ' show result of Add, Mul, Sub and Div
   Print "D1+D2=" ; : D3 = D1 + D2 : Print D3               'calculate
   Print "D1-D2=" ; : D3 = D1 - D2 : Print D3
   Print "D1*D2=" ; : D3 = D1 * D2 : Print D3
   Print "D1/D2=" ; : D3 = D1 / D2 : Print D3

   ' Show comparison
   Print
   Print "Comparison D1 and D2: " ;
   If D1 < D2 Then
      Print " < " ;
   End If
   If D1 <= D2 Then
      Print " <= " ;
   End If
   If D1 = D2 Then
      Print " = " ;
   End If
   If D1 >= D2 Then
      Print " >= " ;
   End If
   If D1 > D2 Then
      Print " > " ;
   End If
   Print " "
   Print

   Print "Different roundings of Result of D1 / D2 (" ; D3 ; ")"
   For B1 = 1 To 14
      Print Str(d3 , B1)
   Next
   ' You can use of course also hardcoded values for decimals f.e. Str(D3, 5)


Loop


End