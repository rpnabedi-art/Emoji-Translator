'------------------------------------------------------------------------------
'                   (c) 1995-2014 MCS Electronics
'                     USI-MASTER.bas
' USI used as TWI master demo
'------------------------------------------------------------------------------

$regfile = "attiny2313.dat"
$crystal = 8000000
$hwstack = 40
$swstack = 16
$framesize = 24
$baud = 19200

config usi = twimaster , mode = fast

dim b as byte

i2cinit

do
  i2cstart
  i2cwbyte &H40                                             'send slave WRITE address for PCF8574
  i2cwbyte &B10101010                                       'send a pattern
  i2crepstart                                               'repeated start

  i2cwbyte &H41                                             'send slave READ address
  i2crbyte b , ack                                          'read a byte
  i2crbyte b , nack                                         'and again
  i2cstop                                                   'end transaction and free bus

  waitms 100                                                'some delay not required only when you print
loop