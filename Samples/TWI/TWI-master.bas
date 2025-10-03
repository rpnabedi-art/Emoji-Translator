'-------------------------------------------------------------------------------
'                            (c) 2004 MCS Electronics
'                        This demo shows an example of the TWI
'                       Not all AVR chips have TWI (hardware I2C)
'-------------------------------------------------------------------------------

'The chip will work in TWI/I2C master mode
'Connected is a PCF8574A 8-bits port extender


$regfile = "M8def.dat"                                     ' the used chip
$crystal = 8000000                                          ' frequency used
$baud = 19200                                               ' baud rate
$hwstack = 40
$swstack = 32
$framesize = 16


$lib "i2c_twi.lbx"                                          ' we do not use software emulated I2C but the TWI

Config Scl = Portc.5                                        ' we need to provide the SCL pin name
Config Sda = Portc.4                                        ' we need to provide the SDA pin name

'On the Mega88,          On the PCF8574A
'scl=PC5 , pin 28            pin 14
'sda=PC4 , pin 27            pin 15


I2cinit                                                     ' we need to set the pins in the proper state


Config Twi = 100000                                         ' wanted clock frequency
'will set TWBR and TWSR
'Twbr = 12                                                   'bit rate register
'Twsr = 0                                                    'pre scaler bits

Dim B As Byte , X As Byte
Print "TWI master"
Do
  Incr B                                                    ' increase value
  I2csend &H0 , B                                           ' send the value to general call address

  I2csend &H70 , B                                          ' send the value
  Print "Error : " ; Err                                    ' show error status
  I2creceive &H70 , X                                       ' get a byte
  Print X ; " " ; Err                                       ' show error
  Waitms 500                                                'wait a bit
Loop
End