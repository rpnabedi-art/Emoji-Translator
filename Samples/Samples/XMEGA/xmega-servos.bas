'-----------------------------------------------------------------------------------
'                                 (c) 1995-2012, MCS Electronics
'                                     xmega-servo.bas
'                        MODE=SERVO is based on code from MWS
'-----------------------------------------------------------------------------------
$regfile = "xm128a1def.dat"
$crystal = 32000000
$hwstack = 64
$swstack = 64
$framesize = 64


Config Osc = Enabled , 32mhzosc = Enabled

'configure the systemclock
Config Sysclock = 32mhz , Prescalea = 1 , Prescalebc = 1_1

Config Com1 = 19200 , Mode = Asynchroneous , Parity = None , Stopbits = 1 , Databits = 8
Print "Servo test"

Config Servos = 2 , Mode = Servo , Timer = Tcc0 , Servo1 = Portb.0 , Servo2 = Portb.1
' you need to chose SERVO mode and you must provide the name of the timer that will be used for the system tick
Enable Interrupts                                           ' you must enable interrupts since timer TCC0 is used in interrupt mode


Dim Key As Byte
'notice that servo() array is a word array, which is created automatic

Do
   Key = Inkey()                                            ' get data from serial port
   If Key = "l" Then                                        'left
      Servo(1) = 12800
      Servo(2) = 12800
   Elseif Key = "m" Then                                    ' middle
      Servo(1) = 19200
      Servo(2) = 19200
   Elseif Key = "r" Then                                    ' right
      Servo(1) = 40000
      Servo(2) = 40000
   Elseif Key <> 0 Then                                     ' enter user value
      Input "Servo1 " , Servo(1)
      Servo(2) = Servo(1)
   End If
Loop