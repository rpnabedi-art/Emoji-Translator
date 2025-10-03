'--------------------------------------------------------------
'                        EDBexperiment16.bas
'       Experiment 16 for the Educational Development Board
'                  (c) 1995-2006, MCS Electronics
'                        Fileversion 1.0
'--------------------------------------------------------------
'
'Purpose:
'This program shows how to use the Analog to Digital converter
'and the Getadc statement
'
'Conclusions:
'You should be able to measure voltages with the AD converter
'
'Note: The values in this program have been adapted a bit to
'mask the tolerance and adapt to the values of the resistors.

$regfile = "m88def.dat"
$crystal = 8000000
$baud = 19200
$hwstack = 40
$swstack = 40
$framesize = 40

'This Configures the AD converter, reference Bascom help if you wish to know more.
Config Adc = Single , Prescaler = Auto , Reference = Internal
Start Adc                                                   'And start

Dim W As Word
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

   Waitms 550                                               'Wait a moment
Loop                                                        'Run again

End