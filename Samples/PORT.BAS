'-----------------------------------------------------------------------------------------
'name                     : port.bas
'copyright                : (c) 1995-2013, MCS Electronics
'purpose                  : demo: PORT access
'micro                    : Mega88
'suited for demo          : yes
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------
$RegFile = "m88def.dat"

Dim A As Byte , Count As Byte

'configure PORT D for input mode
Config Portd = Input

'reading the PORT, will read the latch, that is the value
'you have written to the PORT.
'This is not the same as reading the logical values on the pins!
'When you want to know the logical state of the attached hardware,
'you MUST use the PIN register.
A = PIND

'a port or SFR can be treated as a byte
A = A And Portd

Print A                                                       'print it

Bitwait Pind.7 , Reset                                        'wait until bit is low


'We will use port B for output
Config Portb = Output

'assign value
Portb = 10                                                    'set port B to 10
Portb = Portb And 2

Set Portb.0                                                   'set bit 0 of port B to 1

Incr Portb                                                  'increase value of the port

'Now a light show on the STK200
Count = 0
Do
   Incr Count
   Portb = 1
   For A = 1 To 8
      Rotate Portb , Left                                       'rotate bits left
      Wait 1
   Next
   'the following 2 lines do the same as the previous loop
   'but there is no delay
   '  Portb = 1
   '  Rotate Portb , Left , 8
Loop Until Count = 10
Print "Ready"

'Again, note that the AVR port pins have a data direction register
'when you want to use a pin as an input it must be set low first
'you can do this by writing zeros to the DDRx:
'DDRB =&B11110000  'this will set portb1.0,portb.1,portb.2 and portb.3 to use as inputs.

'So : when you want to use a pin as an input set it low first in the DDRx!
'     and read with PINx
'     and when you want to use the pin as output, write a 1 first
'     and write the value to PORTx

End