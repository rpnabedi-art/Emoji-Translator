'--------------------------------------------------------------
'                         Exercise3.bas
'         Exercise 3 for the Educational Development Board
'                  (c) 1995-2006, MCS Electronics
'                        Fileversion 1.0
'--------------------------------------------------------------
'
'Solution for EDB Exercise 3
'
'Note: This solution uses port b for the bargraph readout

$regfile = "m88def.dat"
$crystal = 8000000
$baud = 19200
$hwstack = 40
$swstack = 40
$framesize = 40

Config Portb = Output

'This Configures the AD converter, reference Bascom help if you wish to know more.
Config Adc = Single , Prescaler = Auto , Reference = Internal
Start Adc                                                   'And start

Dim W As Word , Channel As Byte
Dim Voltagestring As String * 3

Do
   Print "Hallo"
   'The getadc statements gets the AD value and we store into W
   W = Getadc(1)

   Dim Voltage As Byte
   Dim Check As Word

   Voltage = 0
   Check = 44

      Do
         If W <= Check Then Goto Ready                      'Here we test the voltage
            Voltage = Voltage + 1                           'as described in the manual
            Check = Check + 22
      Loop

   Ready:

   Voltagestring = Str(voltage)                             'Here we convert the value to a string
   Voltagestring = Format(voltagestring , "0.0")            'So we can use format to add the decimal point

   Print "Voltage = " ; Voltagestring ; " V" ; Chr(13);     'Print the voltage user friendly
   Print W                                                  'For the record print the AD value

   Select Case W
      Case Is < 128 : Portb = &B11111110
      Case 128 To 256 : Portb = &B11111100
      Case 256 To 384 : Portb = &B11111000
      Case 384 To 512 : Portb = &B11110000
      Case 512 To 640 : Portb = &B11100000
      Case 640 To 768 : Portb = &B11000000
      Case 768 To 896 : Portb = &B10000000
      Case Is > 896 : Portb = &B00000000
   End Select

   Waitms 550                                               'Wait a moment
Loop                                                        'Run again

End