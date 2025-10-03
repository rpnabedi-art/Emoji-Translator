'--------------------------------------------------------------------
'                              M1280-2560-PWM.BAS
'                         Sample for Mega1280, Mega2560
'--------------------------------------------------------------------

 '********** Configuration Settings **********
$regfile = "m1280Def.dat"                                   ' use ATmega1280 definitions
$crystal = 8000000
$hwstack = 40
$swstack = 40
$framesize = 40


'The pin direction is set automatic by the CONFIG command
Config Timer0 = Pwm , Prescale = 1 , Compare A Pwm = Clear Up, Compare B Pwm = Clear Up
Config Timer2 = Pwm , Prescale = 1 , Compare A Pwm = Clear Up, Compare B Pwm = Clear Up

Config Timer1 = Pwm , Prescale = 1 , Compare A Pwm = Clear Up , Compare B Pwm = Clear Up , Compare C Pwm = Clear Up
Config Timer3 = Pwm , Prescale = 1 , Compare A Pwm = Clear Up , Compare B Pwm = Clear Up , Compare C Pwm = Clear Up
Config Timer4 = Pwm , Prescale = 1 , Compare A Pwm = Clear Up , Compare B Pwm = Clear Up , Compare C Pwm = Clear Up
'Config Timer5 = Pwm , Prescale = 1 , Compare A Pwm = Clear Up , Compare B Pwm = Clear Up
'while you can use timer 5 in compare mode, there are no output compare pins !

Dim B As Byte

Do
    B = B - 1                                               'count down
    Pwm0b = B

    Pwm1a = B
    Pwm1b = B
    Pwm1c = B

    Pwm3a = B
    Pwm3b = B
    Pwm3c = B

    Pwm4a = B
    Pwm4b = B
    Pwm4c = B

    Pwm2a = B
    Pwm2b = B

    Waitms 5                                                'a bit delay
Loop

End