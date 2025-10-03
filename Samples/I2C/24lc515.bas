$regfile = "m88def.dat"
$lib "i2c_twi.lbx"
$crystal = 8000000
$baud = 19200
$hwstack = 40
$swstack = 40
$framesize = 40


Config Scl = Portc.5
Config Sda = Portc.4
'connect A0 and A1 to ground, A2 to VCC


Declare Sub Writebyte515(address As Word , Value As Byte)
Declare Function Readbyte515(address As Word) As Byte
Dim B As Byte , Adrs As Word
Dim Hdr As Byte , L As Byte , H As Byte , J As Byte
Dim Choice As Byte , Wstart As Word

Config Twi = 400000
I2cinit

Print "24LC515 EEPROM DEMO"
Do
  Input "0-write 10, 1-read 10, 2-read block ,3 clear" , Choice
  Select Case Choice
    Case 0                                                  'write 10 bytes
            For Adrs = 0 To 15
              B = Adrs
              Writebyte515 Adrs , B                                     'write value
            Next

    Case 1                                                  'read 10 bytes
            For Adrs = 0 To 15                              'read values back
                B = Readbyte515(adrs)
                Print B                                                 'and show them
            Next

    Case 2                                                  'read dump
            Inputhex "Start $" , Wstart
            Hdr = &B10100000
            Hdr.3 = Wstart.15                               ' A15 address bit
            H = High(wstart)
            L = Low(wstart)
            I2cstart
            I2cwbyte Hdr
            I2cwbyte H
            I2cwbyte L
            I2crepstart                                     'repeated start
            Hdr.0 = 1                                       ' we will read now
            I2cwbyte Hdr
            For J = 1 To 63
              I2crbyte B , Ack                              'read byte
              Print Hex(b) ; ",";
            Next
            I2crbyte B , Nack                               'read byte
            Print Hex(b)
            I2cstop

    Case 3
            For Adrs = 0 To 15
              B = &HFF
              Writebyte515 Adrs , B                                     'write value
            Next

  End Select

Loop



End



'write a byte to the 24LC515 memory
Sub Writebyte515(address As Word , Value As Byte)
    Hdr = &B10100000
    Hdr.3 = Address.15                                      ' A15 address bit
    H = High(address)
    L = Low(address)
    I2cstart
    I2cwbyte Hdr                                            'address with A15 segment bit
    I2cwbyte H                                              'MSB
    I2cwbyte L                                              'LSB
    I2cwbyte Value

    I2cstop
    Waitms 10
End Sub

'read a byte from the 24LC515 memory
Function Readbyte515(address As Word) As Byte
    Hdr = &B10100000
    Hdr.3 = Address.15                                      ' A15 address bit
    H = High(address)
    L = Low(address)
    I2cstart
    I2cwbyte Hdr
    I2cwbyte H
    I2cwbyte L
    I2crepstart                                             'repeated start

    Hdr.0 = 1                                               ' we will read now
    I2cwbyte Hdr
    I2crbyte Readbyte515 , Nack                             'read byte
    I2cstop
End Function


