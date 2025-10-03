'--------------------------------------------------------------
'                        EDBexperiment15a.bas
'       Experiment 15a for the Educational Development Board
'                  (c) 1995-2006, MCS Electronics
'                        Fileversion 1.0
'--------------------------------------------------------------
'
'Purpose:
'This program shows how to use the PWM fucntion
'
'Conclusions:
'You should be able to see the light bulb vary

$regfile = "m88Def.dat"
$crystal = 8000000
$baud = 19200
$hwstack = 40
$swstack = 40
$framesize = 40

'The pin direction is set automatic by the CONFIG command
'We need a timer to generate the PWM signal
Config Timer0 = Pwm , Prescale = 1 , Compare A Pwm = Clear Up, Compare B Pwm = Clear Up

Do
   Pwm0a = Pwm0a + 1                                        'The PWM register value
   Print Pwm0a

   Waitms 50                                                'a bit delay
Loop

End