'-------------------------------------------------------------------------------
'                            (c) 2005 MCS Electronics
'                 This demo shows an example of I2C on the M128 portF
' PORTF is an extened port and requires a special I2C driver
'-------------------------------------------------------------------------------


$regfile = "m128def.dat"                                    ' the used chip
$crystal = 8000000
$baud = 19200                                               ' baud rate
$hwstack = 40
$swstack = 40
$framesize = 40


$lib "i2c_extended.lib"

Config Scl = Portf.0                                        ' we need to provide the SCL pin name
Config Sda = Portf.1                                        ' we need to provide the SDA pin name


Dim B1 As Byte , B2 As Byte
Dim W As Word At B1 Overlay



I2cinit                                                     ' we need to set the pins in the proper state


Dim B As Byte , X As Byte
Print "Mega128 master demo"


Print "Scan start"
For B = 1 To 254 Step 2
  I2cstart
  I2cwbyte B
  If Err = 0 Then
     Print "Slave at : " ; B
  End If
  I2cstop
Next
Print "End Scan"


Do
  I2cstart
  I2cwbyte &H70                                             ' slave address write
  I2cwbyte &B10101010                                       ' write command
  I2cwbyte 2
  I2cstop
  Print Err


  I2cstart
  I2cwbyte &H71
  I2crbyte B1 , Ack
  I2crbyte B2 , Nack
  I2cstop
  Print "Error : " ; Err                                    ' show error
  Waitms 500                                                'wait a bit
Loop
End