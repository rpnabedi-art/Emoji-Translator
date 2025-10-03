'------------------------------------------------------------------------------
'                                  attiny45.bas
'                             (c) 2005, MCS ELectronics
' This file is a test file for the ATTINY45
'------------------------------------------------------------------------------

$regfile = "atTiny45.dat"
$crystal = 1000000
$hwstack = 32
$swstack = 8
$framesize = 16


'by default the tiny45 has a 8 MHz internal osc.
'and by default the internal 8 divider is enabled resulting in 1 Mhz clock freq.
Dim I As Byte


Config Portb = Output
Do
   Toggle Portb
   Waitms 500
   Incr I
Loop Until I = 10

Open "COMB.0:19200,8,N,1" For Output As #1
Do
  Print #1 , "Hello world"
  Waitms 500
  Incr I
Loop Until I = 20

Dim W As Word
Config Adc = Single , Prescaler = Auto , Reference = Internal_1.1

Do
   W = Getadc(0)
   Print #1 , "ADC : " ; W
   Waitms 500
   Incr I
Loop Until I = 30

Test:
'final use pwm mode of timer0
Config Timer0 = Pwm , Prescale = 1 , Compare_A_Pwm = Clear_Up, Compare_B_Pwm = Clear_Up

Do
    Pwm0a = Pwm0a + 1                                       'increase the PWM value
    Pwm0b = Pwm0a
    Waitms 10
Loop

'note that TIMER1 is not a normal 16 bit timer. TIMER config command is not suppported

End