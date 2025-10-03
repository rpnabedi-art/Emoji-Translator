'-----------------------------------------------------------------------
'                         (c) 2001-2005 MCS Electronics
'                           servo.bas demonstrates the SERVO option
'-----------------------------------------------------------------------

'Servo's need a pulse in order to operate
'with the config statement CONFIG SERVOS we can specify how many servo's we
'will use and which port pins are used
'A maximum of 16 servos might be used
'The SERVO statements use one byte for an interrupt counter and the TIMER0
'This means that you can not use TIMER0 anymore
'The reload value specifies the interval of the timer in uS
'Config Servos = 2 , Servo1 = Portb.0 , Servo2 = Portb.1 , Reload = 10
$regfile = "m88def.dat"

Config Servos = 1 , Servo1 = Portb.0 , Reload = 10
'as an option you can use TIMER1
'Config Servos = 2 , Servo1 = Portb.0 , Servo2 = Portb.1 , Reload = 10 , Timer = Timer1


'we use 2 servos with 10 uS resolution(steps)

'we must configure the port pins used to act as output
Config Portb = Output

'finally we must turn on the global interrupt
Enable Interrupts

'the servo() array is created automatic. You can used it to set the
'time the servo must be on
Servo(1) = 10                                               '10 times 10 = 100 uS on
'Servo(2) = 20                                               '20 times 10 = 200 uS on
Do
Loop

'second example
Dim I As Byte
Do
 For I = 0 To 100
   Servo(1) = I
   Waitms 1000
 Next

 For I = 100 To 0 Step -1
   Servo(1) = I
   Waitms 1000
 Next
Loop
End