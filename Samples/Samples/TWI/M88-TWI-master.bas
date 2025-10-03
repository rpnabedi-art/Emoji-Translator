'-------------------------------------------------------------------------------
'                            (c) 2004-2010 MCS Electronics
'                        This demo shows an example of the M88 TWI
'                       Not all AVR chips have TWI (hardware I2C)
'-------------------------------------------------------------------------------

'The chip will work in TWI/I2C master mode
'Connected is another Mega88 in TWI-slave mode


$regfile = "M88def.dat"                                     ' the used chip
$crystal = 8000000                                          ' frequency used
$baud = 19200                                               ' baud rate
$hwstack = 50
$swstack = 24
$framesize = 32

$lib "i2c_twi.lbx"                                          ' we do not use software emulated I2C but the TWI

Config Scl = Portc.5                                        ' we need to provide the SCL pin name
Config Sda = Portc.4                                        ' we need to provide the SDA pin name

'On the Mega88,          On the slave Mega8
'scl=PC5 , pin 28            scl=PC5 , pin 28
'sda=PC4 , pin 27            sda=PC4 , pin 27

'the M8 slave uses a simple protocol
'WRITE -> Start-address-B1-B2-STOP
'READ  -> start-address-B1-B2-STOP
'start -> I2CSTART
'address-the slave address
'B1 and B2 are 2 bytes that when written, write to B1
'                           when read , return A/D converter value


Dim B1 As Byte , B2 As Byte
Dim W As Word At B1 Overlay


I2cinit                                                     ' we need to set the pins in the proper state

Dim V As Byte
Config Twi = 100000                                         ' twi speed

Dim B As Byte , X As Byte
Print "Mega8 TWI master demo"

Do
  I2cstart
  I2cwbyte &H70                                             ' slave address write
  I2cwbyte &B10101010                                       ' write command
  I2cwbyte 2
  I2cstop
  Print "Error : " ; Err                                    ' show error status

  Waitms 100

  I2cstart
  I2cwbyte &H71
  I2crbyte B1 , Ack
  I2crbyte B2 , Nack
  I2cstop
  Print "Error : " ; Err                                    ' show error
  Print "received A/D : " ; W
  Waitms 500                                                'wait a bit
Loop

End