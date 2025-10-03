'------------------------------------------------------------------------------
'name                     : adc.bas
'copyright                : (c) 1995-2013, MCS Electronics
'purpose                  : demonstrates AD converter
'micro                    : Mega88
'suited for demo          : yes
'commercial addon needed  : no
'------------------------------------------------------------------------------
$regfile = "m88def.dat"                                     ' we use the M88
$crystal = 8000000
$baud = 19200
$hwstack = 32
$swstack = 8
$framesize = 24

Print "ADC demo"
'configure single mode and auto prescaler setting
'The single mode must be used with the GETADC() function

'The prescaler divides the internal clock by 2,4,8,16,32,64 or 128
'Because the ADC needs a clock from 50-200 KHz
'The AUTO feature, will select the highest clockrate possible
Config Adc = Single , Prescaler = Auto , Reference = Avcc
'Now give power to the chip
Start Adc

'With STOP ADC, you can remove the power from the chip
'Stop Adc

Dim W As Word , Channel As Byte

'now read A/D value from channel 0
Do
  W = Getadc(channel)
  Print "Channel " ; Channel ; " value " ; W
  Incr Channel
  If Channel > 7 Then Channel = 0
  Waitms 500
Loop
End

'The new M163 has options for the reference voltage
'For this chip you can use the additional param :
'Config Adc = Single , Prescaler = Auto, Reference = Internal
'The reference param may be :
'OFF      : AREF, internal reference turned off
'AVCC     : AVCC, with external capacitor at AREF pin
'INTERNAL : Internal 2.56 voltage reference with external capacitor ar AREF pin

'Using the additional param on chip that do not have the internal reference will have no effect.