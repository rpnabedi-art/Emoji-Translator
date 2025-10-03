'------------------------------------------------------------------------------
'name                     : function.bas
'copyright                : (c) 1995-2013, MCS Electronics
'purpose                  : demonstrates FUNCTION
'micro                    : Mega48
'suited for demo          : yes
'commercial addon needed  : no
'------------------------------------------------------------------------------
$regfile = "m48def.dat"                                     ' we use the M48
$crystal = 8000000
$baud = 19200

$hwstack = 32
$swstack = 16
$framesize = 24


'A user function must be declare before it can be used.
'A function must return a type
Declare Function Myfunction(byval I As Integer , S As String) As Integer
'The byval paramter will pass the parameter by value so the original value
'will not be changed by the function

Dim K As Integer
Dim Z As String * 10
Dim T As Integer
'assign the values
K = 5
Z = "123"

T = Myfunction(k , Z)
Print T
End


Function Myfunction(byval I As Integer , S As String) As Integer
   'you can use local variables in subs and functions
   Local P As Integer

   P = I

   'because I is passed by value, altering will not change the original
   'variable named k
   I = 10

   P = Val(s) + I

   'finally assign result
   'Note that the same data type must be used !
   'So when declared as an Integer function, the result can only be
   'assigned with an Integer in this case.
   Myfunction = P
End Function

