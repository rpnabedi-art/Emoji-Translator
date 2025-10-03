'----------------------------------------------------------
'                (c) 1997-2015 MCS Electronics
'                  APPLICATION NOTE 1
'               RS-232 / LCD interface
'----------------------------------------------------------
'This sample shows how to manipulate a LCD-display via
'the RS-232 interface.
'Commands are sent as numbers above 127
'Characters are sent as usually
'Use the evaluation board to test it.

'----------------------------------------------------------------
'You can use a simple routine in QuickBasic to send commands/characters to the display
'OPEN "COM1:4800,8,N,1" FOR OUTPUT as #1
'PRINT #1,128
'PRINT#1,"Hello"
'CLOSE #1
'----------------------------------------------------------------
$regfile = "m48def.dat"
$hwstack = 40
$swstack = 40
$framesize = 40

Dim K As Byte                           'dim byte

Do                                      'start
  K = Inkey()                                                 'get character
  If K = 128 Then
     Cls                                'clear LCD
  Elseif K = 129 Then
     Home                               'HOME LCD
  Elseif K = 130 Then
     Display On                         'display on
  Elseif K = 131 Then
     Display Off                        'display off
  Elseif K <> 0 Then                    'not a command
     Lcd Chr(k);                        'convert it to a character and print it
  End If
Loop                                    'loop for ever
End