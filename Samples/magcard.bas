'--------------------------------------------------------------------------
'                           (c) 2000-2013 MCS Electronics
'                               MAGCARD.BAS
'  This example show you how to read data from a magnetic card
'It was tested on the DT006 SimmStick.
'--------------------------------------------------------------------------
$regfile = "m88def.dat"

'[reserve some space]
Dim Ar(100) As Byte , B As Byte , A As Byte

'the magnetic card reader has 5 wires
'red      - connect to +5V
'black    - connect to GND
'yellow   - Card inserted signal CS
'green    - clock
'blue     - data

'You can find out for your reader which wires you have to use by connecting +5V
'And moving the card through the reader. CS gets low, the clock gives a clock pulse of equal pulses
'and the data varies
'I have little knowledge about these cards and please dont contact me about magnectic readers
'It is important however that you pull the card from the right direction as I was doing it wrong for
'some time :-)
'On the DT006 remove all the jumpers that are connected to the LEDs

'[We use ALIAS to specify the pins and PIN register]
_mport Alias Pinb                                           'all pins are connected to PINB
_mdata Alias 0                                              'data line (blue) PORTB.0
_mcs Alias 1                                                'CS line (yellow) PORTB.1
_mclock Alias 2                                             'clock line (green) PORTB.2

Config Portb = Input                                        'we only need bit 0,1 and 2 for input
Portb = 255                                                 'make them high

Do
  Print "Insert magnetic card"                              'print a message
  Readmagcard Ar(1) , B , 5                                 'read the data
  Print B ; " bytes received"
  For A = 1 To B
    Print Ar(a);                                            'print the bytes
  Next
  Print
Loop

'By sepcifying 7 instead of 5 you can read 7 bit data