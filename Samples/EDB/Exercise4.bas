'--------------------------------------------------------------
'                         Exercise4.bas
'         Exercise 4 for the Educational Development Board
'                  (c) 1995-2006, MCS Electronics
'                        Fileversion 1.0
'--------------------------------------------------------------
'
'Solution for EDB Exercise 4
'
'Note:
'This solution uses pin D.6 as PWM light output and PC.1 as AD input,
'change the code 'to adapt it to you solution.

$regfile = "m88Def.dat"
$crystal = 8000000
$baud = 19200
$hwstack = 40
$swstack = 40
$framesize = 40

'The pin direction is set automatic by the CONFIG command
'We need a timer to generate the PWM signal
Config Timer0 = Pwm , Prescale = 1 , Compare_A_Pwm = Clear Up, Compare_B_Pwm = Clear_Up


'This Configures the AD converter, reference Bascom help if you wish to know more.
Config Adc = Single , Prescaler = Auto , Reference = Internal
Start Adc                                                   'And start

Dim W As Word
Dim Smallw As Word
Dim Smallwb As Byte

Do
   W = Getadc(1)                                            'Get the AD value
   'Print "ADC Word = " ; W
   Smallw = W / 4                                           'Convert to AD Word to a Byte
   'Print "ADC Byte = " ; Smallw                            'PWM0a is one byte

   If Smallw < 265 Then Smallwb = Smallw                    'Check smallw >255
   Pwm0a = Smallwb                                          'Then assign

   Waitms 50
Loop

End