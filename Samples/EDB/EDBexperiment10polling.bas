'--------------------------------------------------------------
'                    EDBexperiment10polling.bas
'       Experiment 10 for the Educational Development Board
'                  (c) 1995-2006, MCS Electronics
'                        Fileversion 1.0
'--------------------------------------------------------------
'
'Purpose:
'This program shows how to use a matrix keyboard with polling
'
'Conclusions:
'You should be able to read the keys pressed on the matrix

$regfile = "m88def.dat"                                     'Define the chip we use
$crystal = 8000000                                          'Define speed of internal oscillator
$baud = 19200                                               'Define UART BAUD rate
$hwstack = 40
$swstack = 40
$framesize = 40

'Specify which port must be used all 8 pins of the port are used
Config Kbd = Portb

'Dimension a variable that receives the value of the pressed key
Dim B As Byte

Do
  B = Getkbd()
  'Look in the help file on how to connect the matrix keyboard
  Print B
  'When no key is pressed 16 will be returned
  'You can use the Lookup() function to translate the value to another one
  'this because the returned value does not match the number on the keyboad
Loop

End