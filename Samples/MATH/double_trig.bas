'--------------------------------------------------------------------
'                        double_trig.bas
'               (c) 1995-2005, MCS Electronics
'  This sample shows the implementation of the TRIG library for the
'  DOUBLE. The library is written by  Josef Franz Vögel
'--------------------------------------------------------------------

'chip settings
$regfile = "m128def.dat"
$crystal = 8000000
$baud = 19200
$hwstack = 40
$swstack = 40
$framesize = 40



'for test purpose we make a constant so we can test for the SINGLE and DOUBLE
Const Dbl = 1

#if Dbl = 1
  Dim D As Double
  Dim Z As Double , F As Double
#else
  Dim D As Single
  Dim Z As Single , F As Double
#endif

D = 0.5 : F = 3.1                                           ' assign some values

Z = Sin(d) : Print "Sin(d)  = " ; : Gosub Printvalue
Z = Cos(d) : Print "Cos(d) = " ; : Gosub Printvalue
Z = Tan(d) : Print "Tan(d) =" ; : Gosub Printvalue

Z = Asin(d) : Print "ASin(d) = " ; : Gosub Printvalue
Z = Acos(d) : Print "Acos(d) = " ; : Gosub Printvalue
Z = Atn(d) : Print "Atn(d) = " ; : Gosub Printvalue
Z = Atn2(d , F) : Print "Atn2(d,f) = " ; : Gosub Printvalue


Z = Sinh(d) : Print "Sinh(d) = " ; : Gosub Printvalue
Z = Cosh(d) : Print "Cosh(d) = " ; : Gosub Printvalue
Z = Tanh(d) : Print "Tanh(d) = " ; : Gosub Printvalue


Z = Power(d , F) : Print "Power(d,f) = " ; : Gosub Printvalue

Z = D ^ 8.0                                                 'uses Power too
End


'routine that prints value of Z
Printvalue:
  Print Z
Return