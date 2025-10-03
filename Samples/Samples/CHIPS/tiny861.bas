'------------------------------------------------------------
'                 ATTINY861 test file
'------------------------------------------------------------
$regfile = "attiny861.dat"
' default the internal osc runs at 1 MHz
$crystal = 8000000
$hwstack = 40
$swstack = 40
$framesize = 40


Dim B As Byte

Config Adc = Single , Prescaler = Auto
'Now give power to the chip
Start Adc


'The tiny861 does not have a Hardware UART so lets use a
' software UART
Open "COMB.0:9600,8,N,1" For Output As #1
Do

  Print #1 , "Hello world"
  Print #1 , "ADC : " ; Getadc(0)
  Waitms 500
  B = B + 1
Loop Until B = 100
Close #1
End