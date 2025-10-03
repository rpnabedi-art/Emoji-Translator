'--------------------------------------------------------------------
'                  ADC_INT.BAS
'  demonstration of GETADC() function in combintion with the idle mode
'  for a better noise immunity
'  Getadc() will also work for other AVR chips that have an ADC converter
'--------------------------------------------------------------------
$RegFile = "m88def.dat"
$Crystal = 8000000
$Baud = 19200

$HWstack = 40
$SWstack = 8
$FrameSize = 40

Declare Sub Adc_isr()
'configure single mode and auto prescaler setting
'The single mode must be used with the GETADC() function

'The prescaler divides the internal clock by 2,4,8,16,32,64 or 128
'Because the ADC needs a clock from 50-200 KHz
'The AUTO feature, will select the highest clockrate possible
Config Adc = Free , Prescaler = Auto , Reference = Internal
'Now give power to the chip
On ADC Adc_isr Nosave
Enable ADC
Enable Interrupts



Dim W As Word , Channel As Byte

Channel = 0
'now read A/D value from channel 0
Do
  Channel = 0
  'idle will put the micro into sleep.
  'an interrupt will wake the micro.
  Start ADC
  Idle
  Stop ADC

  Print "Channel " ; Channel ; " value " ; W
Loop
End

Sub Adc_isr()
  $asm
    push r26
    push r27
    push r24
    in r24,SREG
    push r24
    push r25
  $End Asm

  W = GetADC(Channel)

  $Asm
    pop r25
    pop r24
    Out SREG,r24
    pop r24

    pop r27
    pop r26
  $end Asm

End Sub