'------------------------------------------------------------------------------
'                                  attiny45.bas
'                             (c) 2005, MCS ELectronics
' This file is a test file for the ATTINY25
'------------------------------------------------------------------------------

$regfile = "atTiny25.dat"
$crystal = 1000000
$hwstack = 24
$swstack = 16
$framesize = 32
'by default the tiny25 has a 8 MHz internal osc.
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
   Print #1 , "ADC2 : " ; Getadc(2)
   Print #1 , "ADC3 : " ; Getadc(3)
   Waitms 500
   Incr I
Loop


End