'--------------------------------------------------------------
'            mega8.bas
'    mega8 sample file
'--------------------------------------------------------------
$regfile = "m8def.dat"
$crystal = 8000000
'the internal oscillator of 8 Mhz was choosen in the fusebits
$baud = 19200
$hwstack = 40
$swstack = 40
$framesize = 40


Osccal = &HAE

Dim X As Byte , S As String * 10
Config Portb = Output


Do
  X = X + 1
  Portb = Not Portb
  Print "hello mega8 " ; X
  Waitms 1000
Loop Until Inkey() = 27

Config Adc = Single , Prescaler = Auto
Start Adc
Do
   Print "ch0 " ; Getadc(0)
   Print "ch1 " ; Getadc(1)
   Waitms 500
Loop

$eeprom
Data 1 , 2 , 3 , 4 , 5 , 6 , 7 , 8
Data 10 , 20 , 30 , 40 , 50 , 60 , 70 , 80
$data
End