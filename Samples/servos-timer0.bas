'-----------------------------------------------------------------------------------
'                                 (c) 1995-2012, MCS Electronics
'                                     servos-timer0.bas
'                        MODE=SERVO is based on code from MWS
'-----------------------------------------------------------------------------------
$regfile = "m88def.dat"
$crystal = 8000000
$hwstack = 64
$swstack = 64
$framesize = 64



Config Com1 = 19200 , Parity = None , Stopbits = 1 , Databits = 8
Print "Servo test"

Config Servos = 2 , Mode = Servo , Servo1 = Portb.0 , Servo2 = Portb.1
'Config Servos = 2 , Mode = Servo , Servo1 = Portb.0 , Servo2 = Portb.1 , Prescale= 256

' you need to chose SERVO mode for lowest system resources
Enable Interrupts                                           ' you must enable interrupts since timer 0 is used in interrupt mode


Dim Key As Byte
'notice that servo() array is a byte array, which is created automatic

Do
   Key = Inkey()                                            ' get data from serial port
   If Key = "l" Then                                        'left
      Servo(1) = 100
      Servo(2) = 100
   Elseif Key = "m" Then                                    ' middle
      Servo(1) = 170
      Servo(2) = 170
   Elseif Key = "r" Then                                    ' right
      Servo(1) = 255
      Servo(2) = 255
   Elseif Key <> 0 Then                                     ' enter user value
      Input "Servo1 " , Servo(1)
      Servo(2) = Servo(1)
   End If
Loop