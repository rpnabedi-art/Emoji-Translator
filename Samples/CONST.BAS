'-----------------------------------------------------------------------------------------
'name                     : const.bas
'copyright                : (c) 1995-2013, MCS Electronics
'purpose                  : demo for constants
'micro                    : Mega48
'suited for demo          : yes
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------

$regfile = "m48def.dat"                                     ' specify the used micro
$crystal = 8000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 10                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space

'dimension some variables
Dim Z As String * 10
Dim B As Byte

'assign some constants
'constants dont use program memory
Const S = "test"
Const A = 5                                                 'declare a as a constant
Const B1 = &B1001

'or use an expression to assign a constant
Const X =(b1 * 3) + 2
Const Ssingle = Sin(1)


Print X
Print Ssingle


B = A
'the same as b = 5

Z = S
'the same as Z = "test"

Print A
Print B1
Print S


'you can use constants with conditional compilation
#if A = 5                                                   ' note there is no then
  Print "constant a is 5"
  #if S = "test"
    Print "nested example"
  #else                                                     ' else is optional
    Print "not executed"
  #endif
#else
  Print "not executed"
#endif

End