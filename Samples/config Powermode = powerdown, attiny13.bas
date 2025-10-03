
' Using the new config powermode = PowerDown function with ATTINY13

' Used Bascom-AVR Version 2.0.7.3

' Fuse Bits:
' Disable DWEN (Debug Wire) Fuse Bit
' Disable Brown-Out Detection in Fuse Bits
' Disable Watchdog in Fuse Bits

' You can also just use  Config Powermode = Powerdown

' But this example here also considers what the data sheet write under "MINIMIZING POWER CONSUMPTION"
' You need to follow this when you want to achieve the current consumption which you find in the data sheet under Powerdown Mode

' 1. Disable/Switch off ADC
' 2. Disable/Switch off Analog Comparator
' 3. Disable Brown-out Detection when not needed
' 4. Disable internal voltage reference
' 5. Disable Watchdog Timer when not needed
' 6. Disable the digital input buffer
' 7. Enable Pull-up or pull-down an all unused pins


$regfile = "attiny13.dat"
$crystal = 9600000                                '9.6MHz
$hwstack = 10
$swstack = 0
$framesize = 24


On Int0 Int0_isr                                  'INT0 will be the wake-up source for Powerdown Mode
Config Int0 = Low_level
Enable Int0


' Prepare Powerdown:
' To minimize power consumption, enable pull-up or -down on all unused pins, and
' disable the digital input buffer on pins that are connected to analog sources
Config Portb.0 = Input
Set Portb.0
Config Portb.1 = Input                            'INT0 --> external 47K pull-up
'Set Portb.1
Config Portb.2 = Input
Set Portb.2
Config Portb.3 = Input
Set Portb.3
Config Portb.4 = Input
Set Portb.4
Config Portb.5 = Input                            'External Pull-Up (Reset)

Didr0 = Bits(ain1d , Ain0d)                       'Disable digital input buffer on the AIN1/0 pin

Set Acsr.acd                                      'Switch off  the power to the Analog Comparator
'alternative:
' Stop Ac

Reset Acsr.acbg                                   'Disable Analog Comparator Bandgap Select

Reset Adcsra.aden                                 'Switch off ADC
'alternative:
' Stop Adc

'###############################################################################
Do
   Wait 3                                         ' now we have 3 second to measure the Supply Current in Active Mode

   Enable Interrupts

   ' Now call Powerdown function
   Config Powermode = Powerdown

   'Here you have time to measure PowerDown current consumption until a Low Level on Portb.1 which is the PowerDown wake-up
Loop
'###############################################################################
End


Int0_isr:
' wake_up
Return