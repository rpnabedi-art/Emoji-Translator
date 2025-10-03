'--------------------------------------------------------------
'                        EDBexperiment15b.bas
'       Experiment 15b for the Educational Development Board
'                  (c) 1995-2006, MCS Electronics
'                        Fileversion 1.0
'--------------------------------------------------------------
'
'Purpose:
'This program shows how to use the AD converter
'
'Conclusions:
'You should be able to see the AD value in your terminal

$regfile = "m88def.dat"
$crystal = 8000000
$baud = 19200
$hwstack = 40
$swstack = 40
$framesize = 40

'Configure single mode and auto prescaler setting
'The single mode must be used with the GETADC() function

'The prescaler divides the internal clock by 2,4,8,16,32,64 or 128
'Because the ADC needs a clock from 50-200 KHz
'The AUTO feature, will select the highest clockrate possible
Config Adc = Single , Prescaler = Auto , Reference = Internal
'Now give power to the chip
Start Adc

'With STOP ADC, you can remove the power from the chip
'Stop Adc

Dim W As Word

Do
   W = Getadc(1)                                            'Getadc gets the value of the AD converter
   Print W ; Chr(13);
   Waitms 250
Loop

End