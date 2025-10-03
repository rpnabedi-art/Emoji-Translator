'------------------------------------------------------------------------------
'                        eeprom_master.bas
'                    demo for USI eeprom slave
'
'
'------------------------------------------------------------------------------
$Regfile= "m88pdef.dat"
$crystal=8000000
$HWstack=40
$SWstack=50
$FrameSize=40
$baud=19200
$lib "i2c_twi.lbx"             ' we do not use software emulated I2C but the TWI

config CLOCKDIV=1              ' no need to change fuse byte, we set the divider to 1
Config Sda = Portc.4                                        ' I2C Bus konfigurieren
Config Scl = Portc.5

Dim Address As Word
Dim Value As Byte
'!!!!!!!!!!!!!!!!!!!!
osccal=46              'REMARK THIS LINE, THIS WAS REQUIRED for the test chip
'!!!!!!!!!!!!!!!!!!!!

Print "Start"
I2cinit                         ' init i2c
For Address = 0 To 10                                   ' just test a bit
   value=address+10
   print "write "; address ; ":";value

   I2cstart : I2cwbyte &H40                             'slave address
   I2cwbyte Low(address)                                'LSB first
   I2cwbyte High(address)                               'MSB
   I2cwbyte Value                                       'write value
   I2cstop
   Waitms 500
next

print "Read"
For Address = 0 To 10
   ' The mathing master code to read
   I2cstart : I2cwbyte &H40                             'send slave WRITE address
   I2cwbyte Low(address) :  I2cwbyte High(address) :    'send eeprom address
   I2crepstart                                          'repeated start
   I2cwbyte &H41                                        'write slave READ address
   I2crbyte Value , Nack                                'read eeprom value
   I2cstop
   print address;":";value
Next Address                                              ' increment address byte

end

'EXPECTED OUTPUT
'(
Start
write 0:10
write 1:11
write 2:12
write 3:13
write 4:14
write 5:15
write 6:16
write 7:17
write 8:18
write 9:19
write 10:20
Read
0:10
1:11
2:12
3:13
4:14
5:15
6:16
7:17
8:18
9:19
10:20
')