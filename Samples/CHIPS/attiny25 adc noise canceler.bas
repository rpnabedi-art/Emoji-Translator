
' This example shows also how you can use the ADC Noise Canceler of an AVR
' The ADC features a noise canceler that enables conversion during sleep mode to reduce noise

' In this example we measure the internal Temperature sensor so there is no need to connect anything to test it
' Yes the internal temp sensor is not very accurate. Better accuracies are achieved by using two temperature points for calibration
' The internal 1.1V reference must also be selected for the ADC reference source in the temperature sensor measurement



$regfile = "attiny25.dat"
$crystal = 1000000                                '1Mhz (8MHz/8 = 1Mhz)  'FuseBit : Division/8 enabled and we use internal 8Mhz Oscillator
$hwstack = 24
$swstack = 16
$framesize = 40

On adcc adc_interrupt
Enable Interrupts


Const Use_serial_debug_out = 1      'Serial debug output on Pinb.3



#if Use_serial_debug_out = 1
   Open "comb.3:2400,8,n,1" For Output As #1
#endif

Dim W As Word
Dim W_low_byte As Byte At W Overlay   'We use overlay to have easy access to the low and high byte of the Word
Dim W_high_byte As Byte At W + 1 Overlay

Config Adc = Single , Prescaler = Auto , Reference = INTERNAL_1.1       'Reference is internal 1.1V Reference

'Single Conversion mode must be selected and the ADC conversion complete interrupt must be enabled
w = getadc(0,15)     '15 = ADC4 = internal Temp Sensor
Enable Adcc                                     'Enable ADC Interrupt

Do
   wait 1   'just for testing and to keep the example easy. Do something else here or use a counter/Timer.

   Start ADC
   config PowerMode = Adcnoise                     'Start Noise canceler mode
  'AVR will wakeup with ADC conversion complete Interrupt and jump direct to the adc_interrupt Service Routine
  'after the ISR the program continues here
   Stop adc                                        'Disable ADC


  '-40 Degree C = 230
  '+25 Degree C = 300
  '+85 Degree C = 370
   #if Use_serial_debug_out = 1
      Print #1 , "W= " ; w
   #endif

Loop

End                                               'end program


adc_interrupt:
   W_low_byte = Adcl                              'First read Low Byte
   W_high_byte = Adch
return