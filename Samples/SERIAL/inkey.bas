'-----------------------------------------------------------------------------------------
'name                     : inkey.bas
'copyright                : (c) 1995-2005, MCS Electronics
'purpose                  : demo: INKEY , WAITKEY
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

Dim A As Byte , S As String * 2
Do
   A = Inkey()                                              'get ascii value from serial port
   's = Inkey()
   If A > 0 Then                                            'we got something
      Print "ASCII code " ; A ; " from serial"
   End If
Loop Until A = 27                                           'until ESC is pressed

A = Waitkey()                                               'wait for a key
's = waitkey()
Print Chr(a)

'wait until ESC is pressed
Do
Loop Until Inkey() = 27

'When you need to receive binary data and the bibary value 0 ,
'you can use the IScharwaiting() function.
'This will return 1 when there is a char waiting and 0 if there is no char waiting.
'You can get the char with inkey or waitkey then.
End