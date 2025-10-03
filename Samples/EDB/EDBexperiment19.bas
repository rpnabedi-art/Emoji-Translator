'--------------------------------------------------------------
'                        EDBexperiment19.bas
'       Experiment 19 for the Educational Development Board
'                  (c) 1995-2006, MCS Electronics
'                        Fileversion 1.0
'--------------------------------------------------------------
'
'Purpose:
'This program shows how to initialize and read the
'temperature from an I²C chip. It prints the temperature
'to the UART

'Please also read the DS1624 datasheet, it tells you
'what address- and commandbytes you should use. In
'this example all the necessary bytes are allready entered.
'
'Conclusions:
'You should now know how to use I²C


$regfile = "m88def.dat"                                     'Define the chip we use
$crystal = 8000000                                          'Define speed of internal oscillator
$baud = 19200                                               'Define UART BAUD rate
$hwstack = 40
$swstack = 40
$framesize = 40


'Declare RAM for temperature storage
Dim I2ctemp As Byte                                         'Storage for the temperature


'Configure pins we want to use for the I²C bus
Config Scl = Portd.1                                        'Is serial clock SCL
Config Sda = Portd.3                                        'Is serial data SDA



'Declare constants - I2C chip addresses
Const Ds1624wr = &B10010000                                 'DS1624 Temperature sensor write
Const Ds1624rd = &B10010001                                 'DS1624 Temperature sensor read

'This section initializes the DS1624
   I2cstart                                                 'This creates a start condition
   I2cwbyte Ds1624wr                                        'This sends the address byte with the read/write bit 0
   I2cwbyte &HAC                                            'Access the CONFIG register (&HAC address byte)
   I2cwbyte &H00                                            'Set continuous conversion  (&H00 command byte)
   I2cstop                                                  'This sends the stop condition
   Waitms 25                                                'We have to wait some time after a stop

   I2cstart
   I2cwbyte Ds1624wr
   I2cwbyte &HEE                                            'Start conversion (&HEE command byte)
   I2cstop
   Waitms 25
'End of initialization

Print                                                       'Print empty line



Do

   'Get the current temperature
   I2cstart
   I2cwbyte Ds1624wr
   I2cwbyte &HAA                                            'Read temperature (&HAA command byte)
   I2cstart
   I2cwbyte Ds1624rd                                        'Now the chip will give the register contents
   I2crbyte I2ctemp , ack                                        'Temperature is stored as 12,5 but the ,5 first
   I2crbyte I2ctemp , Nack                                  'So you'll have to read twice... first the ,5
   I2cstop                                                  'And then the 12... we don't store the ,5
                                                                'That's why we read twice.

                                                                'We always specify NACK if, the last byte is read

   'Finally we print the

   Print "Temperature: " ; Str(i2ctemp) ; " degrees centigrade" ; Chr(13);

   Waitms 25

Loop
End

'(
You Can Connect Multiple Ds1624 S To One I²c Bus.

You Can Set The Address Of The Ds1624 Slaves By Connecting
Vcc Or Gnd To Pin 5 , 6 And 7 The Address Of The Ds1624 Is 1001 +
The Logic Value Of Pin 7 , 6 And 5( + A Read / Write Bit).
')