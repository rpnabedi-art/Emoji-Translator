'-----------------------------------------------------------------------------------------
'name                     : test_fptrig2.bas
'copyright                : (c) 1995-2005, MCS Electronics
'purpose                  : demonstates FP trig library from Josef Franz Vögel
'micro                    : Mega8515
'suited for demo          : no
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------

$regfile = "m8515.dat"                                      ' specify the used micro
$crystal = 4000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 64                                               ' default use 32 for the hardware stack
$swstack = 64                                               ' default use 10 for the SW stack
$framesize = 64                                             ' default use 40 for the frame space


Dim S1 As Single , S2 As Single , S3 As Single , S4 As Single , S5 As Single , S6 As Single
Dim Vcos As Single , Vsin As Single , Vtan As Single , Vatan As Single , S7 As Single
Dim Wi As Single , B1 As Byte
Dim Ms1 As Single



Const Pi = 3.14159265358979

'calculate PI
Ms1 = Atn(1) * 4

'Goto Testing_hyperbolicus

Testing_power:
Print "Testing Power X ^ Y"
Print "X             Y          x^Y"
For S1 = 0.25 To 14 Step 0.25
   S2 = S1 \ 2
   S3 = Power(s1 , S2)
   Print S1 ; " ^ " ; S2 ; " = " ; S3
Next
Print : Print : Print

Testing_exp_log:

Print "Testing EXP and LOG"
Print "x    exp(x)       log([exp(x)])    Error-abs    Error-rel"
Print "Error is for calculating exp and back with log together"
For S1 = -88 To 88
   S2 = Exp(s1)
   S3 = Log(s2)
   S4 = S3 - S1
   S5 = S4 \ S1
   Print S1 ; "    " ; S2 ; "    " ; S3 ; "    " ; S4 ; "    " ; S5 ; " " ;
   Print
Next
Print : Print : Print


Testing_trig:
Print "Testing COS, SIN and TAN"
Print "Angle Degree   Angle Radiant         Cos         Sin         Tan"
For Wi = -48 To 48
   S1 = Wi * 15
   S2 = Deg2rad(s1)
   Vcos = Cos(s2)
   Vsin = Sin(s2)
   Vtan = Tan(s2)
   Print S1 ; "    " ; S2 ; "   " ; Vcos ; "   " ; Vsin ; "   " ; Vtan
Next
Print : Print : Print


Testing_atan:
Print "Testing Arctan"
Print "X    atan in Radiant,    Degree"
S1 = 1 / 1024
Do
   S2 = Atn(s1)
   S3 = Rad2deg(s2)
   Print S1 ; "     " ; S2 ; "     " ; S3
   S1 = S1 * 2
   If S1 > 1000000 Then
      Exit Do
   End If
Loop

Print : Print : Print

Testing_int_fract:
Print "Testing Int und Fract of Single"
Print "Value     Int       Frac"
S2 = Pi \ 10
For S1 = 1 To 8
   S3 = Int(s2)
   S4 = Frac(s2)
   Print S2 ; "   " ; S3 ; "   " ; S4
   S2 = S2 * 10
Next

Print : Print : Print

Print "Testing degree - radiant - degree converting"
Print "Degree   Radiant   Degree   Diff-abs   rel"

For S1 = 0 To 90
  S2 = Deg2rad(s1)
  S3 = Rad2deg(s2)
  S4 = S3 - S1
  S5 = S4 \ S1
  Print S1 ; "   " ; S2 ; "   " ; S3 ; "   " ; S4 ; "   " ; S5
Next

Testing_hyperbolicus:
Print : Print : Print
Print "Testing SINH, COSH and TANH"
Print "X        sinh(x)         cosh(x)       tanh(x)"
For S1 = -20 To 20
  S3 = Sinh(s1)
  S2 = Cosh(s1)
  S4 = Tanh(s1)
  Print S1 ; "   " ; S3 ; "   " ; S2 ; "   " ; S4
Next
Print : Print : Print

Testing_log10:
Print "Testing LOG10"
Print "X        log10(x)"
S1 = 0.01
S2 = Log10(s1)
Print S1 ; "   " ; S2
S1 = 0.1
S2 = Log10(s1)
Print S1 ; "   " ; S2
For S1 = 1 To 100
  S2 = Log10(s1)
  Print S1 ; "   " ; S2
Next

Print : Print : Print


'test MOD on FP
S1 = 10000
S2 = 3
S3 = S1 Mod S2
Print S3

Print "Testing_SQR-Single"
For S1 = -1 To 4 Step 0.0625
   S2 = Sqr(s1)
   Print S1 ; " " ; S2
Next
Print
For S1 = 1000000 To 1000100
   S2 = Sqr(s1)
   Print S1 ; " " ; S2
Next

Testing_atn2:
Print "Testing Sin / Cos / ATN2 / Deg2Rad / Rad2Deg / Round"
Print "X[deg]     X[Rad]      Sin(x)      Cos(x)      Atn2     Deg of Atn2    Rounded"
For S1 = -180 To 180 Step 5
   S2 = Deg2rad(s1)
   S3 = Sin(s2)
   S4 = Cos(s2)
   S5 = Atn2(s3 , S4)
   S6 = Rad2deg(s5)
   S7 = Round(s6)
   Print S1 ; " " ; S2 ; " " ; S3 ; " " ; S4 ; " " ; S5 ; " " ; S6 ; " " ; S7
Next
Print "note: -180° is equivalent to +180°"
Print
Testing_asin_acos:
Print "Testing ASIN, ACOS"
Print "X       asin(x)        acos(x)"
   For S1 = -1.125 To 1.125 Step 0.0625
   S2 = Asin(s1)
   S3 = Acos(s1)
   Print S1 ; " " ; S2 ; " " ; S3
Next
Print "Note: > 1.0 and < -1.0 are invalid and shown here for error handling"


Testing_shift:
S1 = 12
For B1 = 1 To 20
   S2 = S1 : S3 = S1
   Shift S2 , Left , B1
   Shift S3 , Right , B1
   Print S1 ; " " ; S2 ; " " ; S3
Next

Print "End of testing"

End