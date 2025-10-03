'-------------------------------------------------------------------------------
'                                 X10.BAS
'                       (c) 2002-2003 MCS Electronics
' This example needs a TW-523 X10 interface
'-------------------------------------------------------------------------------
$RegFile = "m88def.dat"
$crystal = 8000000
$baud = 19200

'define the house code
Const House = "M"                                           ' use code A-P

Waitms 500                                                  ' optional delay not really needed

'dim the used variables
Dim X As Byte

'configure the zero cross pin and TX pin
Config X10 = Pind.2 , Tx = Portb.0
'             ^--zero cross
'                           ^--- transmission pin

'detect the TW-523
X = X10detect()
Print X                                                     ' 0 means error, 1 means 50 Hz, 2 means 60 Hz

Do
   Input "Send (1-32) " , X
   'enter a key code from 1-31
   '1-16 to address a unit
   '17 all units off
   '18 all lights on
   '19 ON
   '20 OFF
   '21 DIM
   '22 BRIGHT
   '23 All lights off
   '24 extended code
   '25 hail request
   '26 hail acknowledge
   '27 preset dim
   '28 preset dim
   '29 extended data analog
   '30 status on
   '31 status off
   '32 status request

   X10send House , X                                        ' send the code
Loop

Dim Ar(4) As Byte

X10send House , X , Ar(1) , 4                               ' send 4 additional bytes

End