'------------------------------------------------------------
'                 ATTINY261 test file
'------------------------------------------------------------
$regfile = "attiny261.dat"
' default the internal osc runs at 1 MHz
$crystal = 8000000
$hwstack = 32
$swstack = 16
$framesize = 24


Config Clockdiv = 1                                         '

Dim B As Byte


'The tiny261 does not have a Hardware UART so lets use a
' software UART

Open "COMB.0:9600,8,N,1" For Output As #1
Print #1 , "Hello world"
Do
  Config Adc = Single , Prescaler = Auto , Reference = Internal_1.1
  Print #1 , "ADC temp: " ; Getadc(63)                      ' internal chip temperature
  Gosub Showregs

  B = 63                                                    'test variable
  Print #1 , "ADC temp: " ; Getadc(b)                       ' internal chip temperature
  Gosub Showregs

  'reconfig the AD converter
  Config Adc = Single , Prescaler = Auto , Reference = Internal_2.56_nocap
  B = 3                                                     'test variable
  Print #1 , "ADC temp: " ; Getadc(b)                       ' internal chip temperature
  Gosub Showregs
Loop
End


Showregs:
  Print #1 , "ADCSRA " ; Bin(adcsra)
  Print #1 , "ADCSRB " ; Bin(adcsrb)
  Print #1 , "ADMUX " ; Bin(admux)
  Waitms 500
Return