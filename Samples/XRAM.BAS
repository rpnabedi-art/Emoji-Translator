'-----------------------------------------------------------------------------------------
'name                     : xram.bas
'copyright                : (c) 1995-2005, MCS Electronics
'purpose                  : demo : XRAM
'micro                    : Mega162
'suited for demo          : yes
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------

$regfile = "m162def.dat"                                    ' specify the used micro
$crystal = 8000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 10                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space


Dim Bx As Xram Byte , B1 As Xram Byte , A As Xram Byte      'specify XRAM so it will be located in external RAM space

Dim Cx As Integer
Dim Wx As Word
Dim S As String * 10
Dim Zz As Byte


Declare Sub Test(byval A As Byte , B1 As Byte)              'declare the subs


S = "123"

Bx = Val(s) + Val(s) : Print Bx

Bx = 50 : Cx = 1000
Wx = Bx * Cx
Print Wx
Call Test(1 , B1)                                           'call sub with parameters
Print B1

Test 1 , B1                                                 'call without CALL statement
Print B1
End



'end your code with the subprograms
'note that the same variables must be used as the declared ones
Sub Test(byval A As Byte , B1 As Byte)                      'start sub
    Local Z As Byte

    Print A ; " " ; B1                                      'print passed variables
    Z = A
    Print Z

    B1 = 3
End Sub
