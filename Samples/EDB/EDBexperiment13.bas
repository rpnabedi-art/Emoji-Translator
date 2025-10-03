'--------------------------------------------------------------
'                        EDBexperiment13.bas
'       Experiment 13 for the Educational Development Board
'                  (c) 1995-2006, MCS Electronics
'                        Fileversion 1.0
'--------------------------------------------------------------
'
'Purpose:
'This program demonstrates how to get the value of a resistor
'
'Conclusions:
'You should be able to read the potentiometers value

$regfile = "m88def.dat"                                     'To tell Bascom which chip we use
$crystal = 8000000
$hwstack = 40
$swstack = 40
$framesize = 40

'The function works by charging a capacitor and uncharge it little by little.
'A word counter counts until the capacitor is uncharged.
'So the result is an indication of the position of a potentiometer not the actual
'resistor value.

'The result of getrc() is a word so DIM one
Dim W As Word
Do
  'The first parameter is the PIN register.
  'The second parameter is the pin number the resistor/capacitor is connected to
  'it could also be a variable!
  W = Getrc(pind , 7)
  Print W
  Wait 1
Loop

End