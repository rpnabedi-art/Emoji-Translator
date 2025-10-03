'--------------------------------------------------------------------------
'                    GETRC.BAS
'   demonstrates how to get the value of a resistor
' The library also shows how to pass a variable for use with individual port
' pins. This is only possible in the AVR architecture and not in the 8051
'--------------------------------------------------------------------------
'The function works by charging a capacitor and uncharge it little by little
'A word counter counts until the capacitor is uncharged.
'So the result is an indication of the position of a pot meter not the actual
'resistor value

'This example used the 8535 and a 10K ohm variable resistor connected to PIND.4
'The other side of the resistor is connected to a capacitor of 100nF.
'The other side of the capacitor is connected to ground.
'This is different than BASCOM-8051 GETRC! This because the architecture is different.
$RegFile = "m88def.dat"

'The result of getrc() is a word so DIM one
Dim W As Word
Do
  'the first parameter is the PIN register.
  'the second parameter is the pin number the resistor/capacitor is connected to
  'it could also be a variable!
  W = GetRC(PIND , 4)
  Print W
  Wait 1
Loop