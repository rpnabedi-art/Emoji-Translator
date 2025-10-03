'-----------------------------------------------------------------------------------------
'name                     : declare.bas
'copyright                : (c) 1995-2013, MCS Electronics
'purpose                  : demonstrate using declare
'micro                    : Mega48
'suited for demo          : yes
'commercial addon needed  : no
' Note that SUBS works different in BASCOM-8051
'-----------------------------------------------------------------------------------------

$regfile = "m48def.dat"                                     ' specify the used micro
$crystal = 8000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 10                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space

' First the SUB programs must be declared

'Try a SUB without parameters
Declare Sub Test2

'SUB with variable that can not be changed(A) and
'a variable that can be changed(B1), by the sub program
'When BYVAL is specified, the value is passed to the subprogram
'When BYREF is specified or nothing is specified, the address is passed to
'the subprogram

Declare Sub Test(byval A As Byte , B1 As Byte)
Declare Sub Testarray(byval A As Byte , B1() As Byte)
'All variable types that can be passed
'Notice that BIT variables can not be passed.
'BIT variables are GLOBAL to the application
Declare Sub Testvar(b As Byte , I As Integer , W As Word , L As Long , S As String)

'passing string arrays needs a different syntax because the length of the strings must be passed by the compiler
'the empty () indicated that an array will be passed
Declare Sub Teststr(b As Byte , Dl() As String)

Dim Bb As Byte , I As Integer , W As Word , L As Long , S As String * 10       'dim used variables
Dim Ar(10) As Byte
Dim Sar(10) As String * 8                                   'strng array

For Bb = 1 To 10
  Sar(bb) = Str(bb)                                         'fill the array
Next
Bb = 1
'now call the sub and notice that we always must pass the first address with index 1
Call Teststr(bb , Sar(1))

Call Test2                                                  'call sub
Test2                                                       'or use without CALL
'Note that when calling a sub without the statement CALL, the enclosing parentheses must be left out
Bb = 1
Call Test(1 , Bb)                                           'call sub with parameters
Print Bb                                                    'print value that is changed

'now test all the variable types
Call Testvar(bb , I , W , L , S )
Print Bb ; I ; W ; L ; S

'now pass an array
'note that it must be passed by reference
Testarray 2 , Ar(1)
Print "ar(1) = " ; Ar(1)
Print "ar(3) = " ; Ar(3)

$notypecheck                                                ' turn off type checking
Testvar Bb , I , I , I , S
'you can turn off type checking when you want to pass a block of memory
$typecheck                                                  'turn it back on
End

'End your code with the subprograms
'Note that the same variables and names must be used as the declared ones

Sub Test(byval A As Byte , B1 As Byte)                      'start sub
    Print A ; " " ; B1                                      'print passed variables
    B1 = 3                                                  'change value
    'You can change A, but since a copy is passed to the SUB,
    'the change will not reflect to the calling variable
End Sub


Sub Test2                                                   'sub without parameters
    Print "No parameters"
End Sub


Sub Testvar(b As Byte , I As Integer , W As Word , L As Long , S As String)
    Local X As Byte

    X = 5                                                   'assign local

    B = X
    I = -1
    W = 40000
    L = 20000
    S = "test"
End Sub


Sub Testarray(byval A As Byte , B1() As Byte)               'start sub
    Print A ; " " ; B1(1)                                   'print passed variables
 '   B1 = 3                                                  ' this will raise an error
    B1(1) = 3                                               'specify the index which does the same as the line above
    B1(3) = 3                                               'modify other element of array
    'You can change A, but since a copy is passed to the SUB,
    'the change will not reflect to the calling variable
End Sub

'notice the empty() to indicate that a string array is passed
Sub Teststr(b As Byte , Dl() As String)
  Dl(b) = Dl(b) + "add"
End Sub