$regfile = "attiny24.dat"
$crystal = 8000000
$hwstack = 24
$swstack = 16
$framesize = 32

Config Adc = Single , Prescaler = Auto , Reference = Internal_1.1
Open "COMB.0:9600,8,N,1" For Output As #1
Print #1 , "Hello world"


Do
  Print #1 , "ADC temp: " ; Getadc(&B100010)                ' internal chip temperature
  Waitms 500
Loop
End