'--------------------------------------------------------------------------------
'name                     : 1wire.bas
'copyright                : (c) 1995-2015, MCS Electronics
'purpose                  : demonstrates 1wreset, 1wwrite and 1wread()
'micro                    : Mega88
'suited for demo          : yes
'commercial addon needed  : no
' pull-up of 4K7 required to VCC from Portb.2
' DS2401 serial button connected to Portb.2
'--------------------------------------------------------------------------------

$regfile = "m88def.dat"
$crystal = 8000000

$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 10                                               'default use 10 for the SW stack
$framesize = 40                                             'default use 40 for the frame space


Config Com1 = 19200 , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0

'when only bytes are used, use the following lib for smaller code
$lib "mcsbyte.lbx"


Config 1wire = Portb.2                                      'use this pin
'On the STK200 jumper B.2 must be inserted
Dim Ar(8) As Byte , A As Byte , I As Byte
Print "1wire test"

Do
   Wait 1
   1wreset                                                   'reset the device
   Print Err                                                 'print error 1 if error
   1wwrite &H33                                              'read ROM command
   For I = 1 To 8
      Ar(i) = 1wread()                                        'place into array
   Next

'You could also read 8 bytes a time by unremarking the next line
'and by deleting the for next above
'Ar(1) = 1wread(8)                                           'read 8 bytes

   For I = 1 To 8
      Print Hex(ar(i));                                      'print output
   Next
   Print                                                     'linefeed
Loop


'NOTE THAT WHEN YOU COMPILE THIS SAMPLE THE CODE WILL RUN TO THIS POINT
'THIS because of the DO LOOP that is never terminated!!!

'New is the possibility to use more than one 1 wire bus
'The following syntax must be used:
For I = 1 To 8
   Ar(i) = 0                                                 'clear array to see that it works
Next

1wreset Pinb , 2                                            'use this port and  pin for the second device
1wwrite &H33 , 1 , Pinb , 2                                 'note that now the number of bytes must be specified!
'1wwrite Ar(1) , 5,pinb,2

'reading is also different
Ar(1) = 1wread(8 , Pinb , 2)                                'read 8 bytes from portB on pin 2

For I = 1 To 8
   Print Hex(ar(i));
Next

'you could create a loop with a variable for the bit number !
For I = 0 To 3                                              'for pin 0-3
   1wreset Pinb , I
   1wwrite &H33 , 1 , Pinb , I
   Ar(1) = 1wread(8 , Pinb , I)
   For A = 1 To 8
      Print Hex(ar(a));
   Next
   Print
Next

End