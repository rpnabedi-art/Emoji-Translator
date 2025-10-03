'---------------------------------------------------------
'                    SINGLE.BAS
'         (c) 1995-2007 MCS Electronics
'         Uses FP unit from Jack Tidwell, TRIG from Josef Vögel.
'---------------------------------------------------------
$regfile= "m88def.dat"
$hwstack = 40
$swstack = 40
$framesize = 40


Dim X As Single , Y As Single , Result As Single
Dim Z As String * 10

'INPUT with a SINGLE is now supported!
'STR() also works with singles now
'So this leaves the TRIG functions to be implemented
Input "Enter x " , X                                        'ask for 2 values
Input "Enter y " , Y

Z = "1234.567"
Result = Val(z) : Print Result
Z = Str(result) : Print Result

'X = 1000.1234
'Y = 5.75
Print "X+Y=" ; : Result = X + Y : Print Result              'calculate
Print "X-Y=" ; : Result = X - Y : Print Result
Print "X/Y=" ; : Result = X / Y : Print Result
Print "X*Y=" ; : Result = X * Y : Print Result

If X > Y Then
  Print ">"
End If


'new type conversion for singles
Dim I As Integer , L As Long , W As Word
X = 1000.1                                                  'assign single
I = X                                                       'single ->integer
L = X                                                       'single->long
W = X                                                       'single->word
X = L                                                       'long -> single
X = I                                                       'integer ->single
X = W                                                       'word -> single

Print X ; " " ; I ; " " ; L ; " " ; W ; " " ; X

X = 9
X = Sqr(x)
Print "SRQ " ; X
End