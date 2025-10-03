'-----------------------------------------------------------------------------------------
'name                     : case.bas
'copyright                : (c) 1995-2013, MCS Electronics
'purpose                  : demonstrates SELECT CASE statement
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


Dim I As Byte                                               'dim variable
Dim S As String * 5 , Z As String * 5

Do

  Input "Enter value (0-255) " , I
  Select Case I
    Case 1 : Print "1"
    Case 2 : Print "2"
    Case 3 To 5 : Print "3-5"
    Case Is >= 10 : Print ">= 10"
    Case Else : Print "Not in Case statement"
  End Select
Loop
End

'note that a Boolean expression like > 3 must be preceded
'by the IS keyword