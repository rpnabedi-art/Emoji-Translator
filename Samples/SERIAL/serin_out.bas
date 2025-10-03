'----------------------------------------------------------------------
'                         serin_out.bas
'                    (c) 2002-2015 MCS Electronics
' demonstration of DYNAMIC software UART
'----------------------------------------------------------------------

'tip : Also look at OPEN and CLOSE

'tell the compiler which XTAL was used
$crystal = 8000000

'tell the compiler which chip we use
$regfile = "m48def.dat"
$hwstack = 32
$swstack = 16
$framesize = 24


'some variables we will use
Dim S As String * 10
Dim Mybaud As Long
'when you pass the baud rate with a variable, make sure you dimesion it as a LONG

Const Serout_extpull = 0                                    ' do use pin in port output mode

Ucsr0b = 0                                                  ' DISABLE HW UART

Mybaud = 19200
Do
  'first get some data
  Serin S , 0 , D , 0 , Mybaud , 0 , 8 , 1
  'now send it
  Serout S , 0 , D , 1 , Mybaud , 0 , 8 , 1
  '                                      ^ 1 stop bit
  '                                  ^---- 8 data bits
  '                                ^------ even parity (0=N, 1 = E, 2=O)
  '                        ^-------------- baud rate
  '                  ^-------------------- pin number
  '               ^----------------------- port so PORTA.0 and PORTA.1 are used
  '           ^--------------------------- for strings pass 0
  '      ^-------------------------------- variable
  Wait 1
Loop
End

'because the baud rate is passed with a variable in theis example, you could change it under user control
'for example check some DIP switches and change the variable mybaud