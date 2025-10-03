'--------------------------------------------------------------
'                   M324P.BAS
'--------------------------------------------------------------
$regfile = "M164pdef.dat"

'This file is intended to test the Mega164P
'The M164P has the JTAG enabled by default so you can not use
'pins PORTC.2-PORTC.5

'Use the following code to disable JTAG
'Mcusr = &H80
'Mcusr = &H80
'Or program the fuse bit
$crystal = 8000000
$baud = 19200
$hwstack = 40
$swstack = 40
$framesize = 40


Config Serialin = Buffered , Size = 10
Config Input = Cr , Echo = Crlf                            'options are CR, LF, CRLF, LFCR

Config Clock = Soft                                         ' clock crystal connected to portC.6 and portC.7
Enable Interrupts

Config Pinb.2 = Output
Config Com1 = Dummy , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0
'Config Adc = Single , Prescaler = Auto , Reference = Internal_1.1
Config Adc = Single , Prescaler = Auto , Reference = Internal_2.56

Dim B As String * 10

Dim Tel As Word
Do
  Input "test " , B
  While Ischarwaiting() <> 0                                'there is a char
    B = Waitkey()                                           'get it
    Print B;                                                'show it
  Wend                                                      'until the buffer is empty
  If Err = 1 Then                                           'there was an overflow in the serial input buffer
     Print "OVERFLOW" : Err = 0                             'do not forget to reset the buffer
  End If
  Tel = Tel + 1
  Print "hello world " ; Tel ; "  " ; Time$ ; "  " ; Getadc(0)
  Waitms 500
  Toggle Portb.2
Loop



End

'data lines inserted to test flash programming
Data 1 , 2 , 3 , 4 , 5 , 6 , 7 , 8 , 9 , 10 , 11 , 12 , 13 , 14 , 15 , 16
Data 1 , 2 , 3 , 4 , 5 , 6 , 7 , 8 , 9 , 10 , 11 , 12 , 13 , 14 , 15 , 16
Data 1 , 2 , 3 , 4 , 5 , 6 , 7 , 8 , 9 , 10 , 11 , 12 , 13 , 14 , 15 , 16
Data 1 , 2 , 3 , 4 , 5 , 6 , 7 , 8 , 9 , 10 , 11 , 12 , 13 , 14 , 15 , 16