'-----------------------------------------------------------------------------------------
'name                     : i2c.bas
'copyright                : (c) 1995-2005, MCS Electronics
'purpose                  : demo: I2CSEND and I2CRECEIVE
'micro                    : Mega48
'suited for demo          : yes
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------

$regfile = "m48def.dat"                                     ' specify the used micro
$crystal = 8000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 10                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space

'or use the TWI !
Config Scl = Portb.4
Config Sda = Portb.5

Declare Sub Write_eeprom(byval Adres As Byte , Byval Value As Byte)
Declare Sub Read_eeprom(byval Adres As Byte , Value As Byte)

Const Addressw = 174                                        'slave write address
Const Addressr = 175                                        'slave read address

Dim B1 As Byte , Adres As Byte , Value As Byte              'dim byte

Call Write_eeprom(1 , 3)                                    'write value of three to address 1 of EEPROM


Call Read_eeprom(1 , Value) : Print Value                   'read it back
Call Read_eeprom(5 , Value) : Print Value                   'again for address 5


'-------- now write to a PCF8474 I/O expander -------
I2csend &H40 , 255                                          'all outputs high
I2creceive &H40 , B1                                        'retrieve input
Print "Received data " ; B1                                 'print it
End

Rem Note That The Slaveaddress Is Adjusted Automaticly With I2csend & I2creceive
Rem This Means You Can Specify The Baseaddress Of The Chip.




'sample of writing a byte to EEPROM AT2404
Sub Write_eeprom(byval Adres As Byte , Byval Value As Byte)
    I2cstart                                                'start condition
    I2cwbyte Addressw                                       'slave address
    I2cwbyte Adres                                          'asdress of EEPROM
    I2cwbyte Value                                          'value to write
    I2cstop                                                 'stop condition
    Waitms 10                                               'wait for 10 milliseconds
End Sub


'sample of reading a byte from EEPROM AT2404
Sub Read_eeprom(byval Adres As Byte , Value As Byte)
   I2cstart                                                 'generate start
   I2cwbyte Addressw                                        'slave adsress
   I2cwbyte Adres                                           'address of EEPROM
   I2cstart                                                 'repeated start
   I2cwbyte Addressr                                        'slave address (read)
   I2crbyte Value , Nack                                    'read byte
   I2cstop                                                  'generate stop
End Sub


' when you want to control a chip with a larger memory like the 24c64 it requires an additional byte
' to be sent (consult the datasheet):
' Wires from the I2C address that are not connected will default to 0 in most cases!

'   I2cstart                                                'start condition
'   I2cwbyte &B1010_0000                                    'slave address
'   I2cwbyte H                                              'high address
'   I2cwbyte L                                              'low address
'   I2cwbyte Value                                          'value to write
'   I2cstop                                                 'stop condition
'   Waitms 10