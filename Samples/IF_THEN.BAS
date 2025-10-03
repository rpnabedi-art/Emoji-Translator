'------------------------------------------------------------------------------
'name                     : if_then.bas
'copyright                : (c) 1995-2013, MCS Electronics
'purpose                  : demonstrates   IF, THEN, END IF , ELSE
'micro                    : Mega48
'suited for demo          : yes
'commercial addon needed  : no
'------------------------------------------------------------------------------
$regfile = "m48def.dat"                                     ' we use the M48
$crystal = 8000000
$baud = 19200

$hwstack = 32
$swstack = 8
$framesize = 24

Dim A As Byte , B1 As Byte

Input "Number " , A                                         'ask for number
If A = 1 Then                                               'test number
   Print "You got it!"
End If

If A = 0 Then                                               'test again
   Print "Wrong"                                            'thats wrong
Else                                                        'print this if a is not 0
   Print "Almost?"
End If

Rem You Can Nest If Then Statements Like This
B1 = 0
If A = 1 Then
   If B1 = 0 Then
      Print "B1=0"
   End If
Else
   Print "A is not 0"
End If

Input "Number " , A
If A = 1 Then                                               '
   Print "Ok"
Elseif A = 2 Then                                           'use elseif for more tests
   Print "2" : A = 3
Elseif A = 3 Then
   Print "3"
End If

If A.1 = 1 Then Print "Bit 1 set"                           'test for  a bit

End