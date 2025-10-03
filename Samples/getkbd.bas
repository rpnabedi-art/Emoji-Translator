'-------------------------------------------------
'               GETKBD.BAS
'          (c) 2000-2013 MCS Electronics
'-------------------------------------------------
'specify which port must be used
'all 8 pins of the port are used
Config Kbd = Portb

'dimension a variable that receives the value of the pressed key
Dim B As Byte

'loop for ever
Do
  B = Getkbd()
  'look in the help file on how to connect the matrix keyboard
  'when you simulate the getkbd() it is important that you press/click the keyboard button
  ' before running the getkbd() line !!!
  Print B
  'when no key is pressed 16 will be returned
  'use the Lookup() function to translate the value to another one
' this because the returned value does not match the number on the keyboad
Loop

End