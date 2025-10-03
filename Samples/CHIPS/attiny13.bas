$regfile = "attiny13.dat"
$crystal = 9600000
Config Portb = Output
$hwstack = 16
$swstack = 8
$framesize = 24


'final use pwm mode of timer0
Config Timer0 = Pwm , Prescale = 1 , Compare A Pwm = Clear Up

Do
  Pwm0a = Pwm0a + 10
  Toggle Portb
  Waitms 1000
Loop

End