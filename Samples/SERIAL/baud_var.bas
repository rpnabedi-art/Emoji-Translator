'------------------------------------------------------------------------------
'name                     : baud_var.bas
'copyright                : (c) 1995-2006, MCS Electronics
'purpose                  : demonstrates setting the BAUD rate with a variable
'micro                    : Mega88
'suited for demo          : yes
'commercial addon needed  : no
'------------------------------------------------------------------------------
$regfile = "m88def.dat"
$crystal = 8000000
$baud = 19200
$hwstack = 40
$swstack = 40
$framesize = 40


'some times it could be useful to set the baudrate depending on a variable instead of a constant
'this sample will show you how you can calculate the baudrate register values

Dim L As Long , Bd As Long
Dim Uh As Byte At L + 1 Overlay
Bd = 38400                                                  ' baud wanted
L = 8000000 / Bd                                            ' divide crystal freq. by the wanted baud rate

L = L / 16                                                  'divide the result by 16
L = L - 1                                                   'and subtract 1
Ubrrl = L                                                   'when you assign a long it will only write the BYTE
Ubrrh = Uh                                                  'we use an overlayed variable that is the high byte
Do
  Print "Set terminal to 38400 to see if it works"
  Waitms 500
Loop