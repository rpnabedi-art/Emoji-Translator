'--------------------------------------------------------------------
'                              M48-88-168-PWM.BAS
'                         Sample for Mega48, Mega88 and Mega168
'                     that demonstrates using the 6 PWM channels
'--------------------------------------------------------------------

 '********** Configuration Settings **********
$regfile = "m88Def.dat"                                     ' use ATmega48 definitions
$crystal = 8000000
$hwstack = 40
$swstack = 40
$framesize = 40


'The pin direction is set automatic by the CONFIG command
Config Timer0 = Pwm , Prescale = 1 , Compare A Pwm = Clear Up , Compare B Pwm = Clear Up
Config Timer1 = Pwm , Prescale = 1 , Compare A Pwm = Clear Up , Pwm = 8 , Compare B Pwm = Clear Up
Config Timer2 = Pwm , Prescale = 1 , Compare A Pwm = Clear Up , Compare B Pwm = Clear Up

Do
    Pwm0a = Pwm0a + 1                                       'increase the PWM value
    Pwm0b = Pwm0a

    Pwm1a = Pwm0a
    Pwm1b = Pwm1a

    Pwm2a = Pwm0a
    Pwm2b = Pwm0a

    Waitms 50                                               'a bit delay
Loop

End