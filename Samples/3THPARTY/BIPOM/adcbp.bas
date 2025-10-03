'*******************************************************************************
'
' Module:   ADC.BAS
'
' Revision:   1.01
'
' Date: 12/22/2006
'
' Description:  ADC TEST
' It is necesasry to connect 5 test voltages to 5 analog terminals.
' Please follow the next wiring diagram:
' VAN - [R=10K] - AN4 - [R=10K] - AN3 - [R=10K]- AN2 -[R=10K] - AN1 - [R=10K] - AN0 - [R=10K] - AGND
' This way we will have the following test voltages on analog terminals:
' AN0 = 0.83V
' AN1 = 1.66V
' AN2 = 2.50V
' AN3 = 3.33V
' AN4 = 4.16V
'
'*******************************************************************************
' ATMEGA 2560
$regfile = "m2560def.dat"
'{TOOLKITDIR}\bascomp {SOURCEFILE} hw=64 ss=64 fr=64 chip=43
$hwstack=64
$swstack=64
$FrameSize=64
'*******************************************************************************
$crystal = 14745600
$baud = 19200
Config Com1 = Dummy , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0
Dim AdcConvStatus as Byte
Dim AdcChannel as Byte
Dim AdcValue as WORD
Dim AdcTemp as WORD
Dim AdcVoltage as Single

'
Declare Sub Get_MMAVR_ADC (AdcChannel  As Byte, AdcValue as WORD)
'
'CONFIGURE ADC
DIDR0 = &H04        'AD0..AD3 - analog inputs
DIDR1 = &H80        'AD15 - analog input
ADMUX = &H40    'Configure analog multiplexer,AVCC with ext.capacitor at AREF pin
ADCSRB =&H00
ADCSRA =&HD7    'Start conversion
Do
   Print
   Print "-- Mini-Max/AVR analog inputs --"
   For AdcChannel = 0 to 4
      Call Get_MMAVR_ADC(AdcChannel,AdcValue)
      AdcVoltage =  5 * AdcValue
      AdcVoltage = AdcVoltage /1023
      Print "Ch";AdcChannel;": Code=";AdcValue;" Voltage=";AdcVoltage;"V"
   Next
   WaitMs 1000
Loop
End

Sub Get_MMAVR_ADC (AdcChannel  As Byte, AdcValue as WORD)
   ' Select ADC channel ( Note. Ch4 of Mini-Max/MAVR board is ADC15 )
   If AdcChannel < 4 Then
      ADCSRB =&H00
      ADMUX = AdcChannel + &H40
   Else
                ' Select ADC15 analog input
      ADCSRB =&H08
      ADMUX = &H47
   End if
'
   ADCSRA =&HD7    'Start ADC conversion
   ' Wait for complete ADC conversion
   Do
      AdcConvStatus = ADCSRA AND &H10
   Loop Until AdcConvStatus <> 0

   AdcTemp = Adcl
   AdcValue = Adch
   Rotate AdcValue , Left , 8
   AdcValue = AdcValue And &H0300
   AdcValue = AdcValue Or AdcTemp
End Sub
