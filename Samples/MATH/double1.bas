'-------------------------------------------------------------------------------
'                               (c) 2004 MCS Electronics
' This sample show the handling with DOUBLE - floating point numbers
' The DOUBLE library and samples are written by Josef Franz Vögel
'-------------------------------------------------------------------------------
'NOTICE THAT YOU NEED A MEGA AVR for the DOUBLE.
'This because of the needed SRAM and instructions used.
'The sample was compiled for Mega162.


' Double is floating point format which stores a number in 8 Bytes
' Rangle of DOUBLE is from ~ E-308 to ~ E308
' You need version BASACOM-AVR Version 1.11.7.5 (or higher)

$regfile = "m88def.dat"
$hwstack = 40
$swstack = 40
$framesize = 40


Dim D1 As Double , D2 As Double , D3 As Double , D4 As Double , D5 As Double , D6 As Double
Dim S1 As Single , L1 As Long
Dim Str1 As String * 24                                     ' use at least length of 22

' Double has an accuracy of nearly 16 digits
' you can assign up to 16 digits to a Double
' all routines work with full accuracy of Double
' For print and converting to string 15 digits are shown, last digit is used for rounding

' Assigning a double in code
D1 = 1.234567890123456                                      ' you can use up to 16 digits as Input for a double


' Printing a double
Print "Print of Double"
Print D1                                                    ' Print/Convering to string uses 15 digits (last digit is rounded)

' print a double with rounded decimals
Print Str(d1 , 5)



' Double uses notation with exponent for Input and Output
' You can use every number for exponent from E-308 to E308
Print "Double with Exponent"
D1 = 1.234567e4
D2 = -1.234567e-4

' Print shows Double in scientific notation (Exponent in steps of 3: E3, E6, E9 ...)
Print D1 ; " " ; D2



'Converting a String to a Double
Print "Convert a String to a Double"
Str1 = "2.345678901234567E20"
D1 = Val(str1)
Print Str1 ; " " ; D1


' Converting a Double to a String
Print "Convert as Double to a String"
D1 = 456.789e7
Str1 = Str(d1)
Print D1 ; " " ; Str1


' Converting a Double to a String with rounding
Print "Convert a Double to a String including rounding"
D1 = 4567.1234567e14
Str1 = Str(d1 , 5)
Print D1 ; " " ; Str1


' The 4 ground calculations with Double

D1 = 12.3456e6
D2 = 23.4567e-2
Print "Basic mathematical routines + - * /"
Print D1 ; " + " ; D2 ; " = " ; : D3 = D1 + D2 : Print D3
Print D1 ; " - " ; D2 ; " = " ; : D3 = D1 - D2 : Print D3
Print D1 ; " * " ; D2 ; " = " ; : D3 = D1 * D2 : Print D3
Print D1 ; " / " ; D2 ; " = " ; : D3 = D1 / D2 : Print D3

' you can replace each Double variable with a hard-coded double
D3 = D1 + 23.456e5
: Print D3
D3 = 456.5678 / D2 : Print D3


' Double in Loop

' For - Next
Print "For - Next with Double, values hardcoded "
For D1 = 1 To 5 Step 0.4
    D2 = D1 * D1
    Print D1 ; " " ; D2
Next


' For - Next with Variables
D2 = 1e4
D3 = 6e4
D4 = 1.25e4
Print "For - Next with Double, values from SRAM "
For D1 = D2 To D3 Step D4
    D5 = D1 * D1
    Print D1 ; " " ; D5
Next


Print "While - Wend with Double"
' While - Wend
D1 = 6
While D1 < 10
      Print D1
      D1 = D1 + 0.75
Wend

' Do - Loop Until
D1 = 5

Print "Do - Loop Until with Double"
Do
     Print D1
     D1 = D1 * 1.125
Loop Until D1 > 10



' Int, Fix, Round and Fract with Doubles
' Int: Calculate next lower Integer of Double
' Fix: Calculate next lower Integer of Double For Double >= 0
'            and next higher Integer of Double for Double < 0
' Round: Round to next Double
' Frac: Calculate fractional part of Double

Print "Value  Int Fix Round Frac"
For D1 = -3 To 3 Step 0.25
    D2 = Int(d1)
    D3 = Fix(d1)
    D4 = Round(d1)
    D5 = Frac(d1)
    Print D1 ; " " ; D2 ; " " ; D3 ; " " ; D4 ; " " ; D5
Next


' Incr and Decr with Double

D1 = -2.375
Print "Incr of Double"
Do
    Print D1
    Incr D1
Loop Until D1 > 2

Print "Decr of Double"
Do
    Print D1
    Decr D1
Loop Until D1 < -4


' Converting Double to Single and Long and vice versa
Print "Convert Double to Single and Long"
For D1 = -3.675 To 4 Step 0.5
    S1 = D1                                                 ' Double to Single
    L1 = D1                                                 ' Double to Long
    Print D1 ; " " ; S1 ; " " ; L1
Next


' Single to Double
Print "Convert Single to Double"
For S1 = -3.625 To 4 Step 0.5
    D1 = S1
    Print S1 ; " " ; D1
Next


Print "Convert Long to Double"
' Long to Double
For L1 = -10 To 8
    D1 = L1
    Print L1 ; " " ; D1
Next



End