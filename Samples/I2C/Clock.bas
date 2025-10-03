'------------------- AN 4 -----------------------------
'          Copyright 1998-2002 MCS Electronics
'                   CLOCK.BAS
'This AN shows how to use the PCF8583 I2C clock device
'The PCF8583 is a PHILIPS device. Look at the datasheet for more details
'I have used the STK200 to test the program with a 8515
'------------------------------------------------------
$regfile = "m88def.dat"
$lib "mcsbyte.lbx"                                          ' use the byte lib since we do not need longs
$crystal = 16000000
$baud = 19200

$hwstack = 40
$swstack = 40
$framesize = 40

'declare used subs

Declare Sub Settime(byval S1 As Byte , Byval M1 As Byte , Byval H1 As Byte , Byval D1 As Byte , Byval Month1 As Byte)
Declare Sub Gettime()


'Declare variables
Dim Tm(5) As Byte
Dim I As Byte , Temp As Byte

'These are pointers to tm() for simple handling.
Dim S As Byte At Tm Overlay
Dim M As Byte At Tm + 1 Overlay
Dim H As Byte At Tm + 2 Overlay
Dim D As Byte At Tm + 3 Overlay
Dim Month As Byte At Tm + 4 Overlay


'configure the used port pin for I2C
Config I2cdelay = 5                                         ' default slow mode
Config Sda = Portc.4
Config Scl = Portc.5

' not needed since the pins are in the right state
'I2cinit
Call Settime(56 , 1 , 1 , 29 , 11)                          'set time

Print Chr(27) ; "[2J";                                      'clear screen
Print "PCF8583 Clock Sample"
Do
   Call Gettime
   'since the values are stored in BCD format we can use Hex() to display them
   Print Chr(27) ; "[2;2f";                                 ' VT100 emulation set pos to 2,2
   Print Hex(h) ; ":" ; Hex(m) ; ":" ; Hex(s) ; " Err:" ; Err
   Wait 1
Loop
End




Sub Gettime()

   'there are 2 ways to get the time. With low level i2c calls or with a high level call
   'first the high level call
    Tm(1) = 2                                               ' point to second register

    I2creceive &HA0 , Tm(1) , 1 , 5                         ' write the second address and get 5 bytes back
    'i2creceive will first write 1 byte from tm(1) which is 2, and then will read 5 bytes and store it onto tm(1)-tm(5)


    'and optional with low level calls
'    For I = 1 To 5
'       Temp = I + 1
 '      I2cstart
'       I2cwbyte &HA0                                        'write addres of PCF8583
'       I2cwbyte Temp                                        'select register
'       I2cstart                                             'repeated start
'       I2cwbyte &HA1                                        'write address for reading info
'       I2crbyte Tm(i) , Nack                                'read data
'    Next
'  I2cstop
End Sub


Sub Settime(s1 As Byte , M1 As Byte , H1 As Byte , D1 As Byte , Month1 As Byte)
    'values are stored as BCD values so convert the values first

    Tm(1) = Makebcd(s1)                                     'seconds
    Tm(2) = Makebcd(m1)                                     'minutes
    Tm(3) = Makebcd(h1)                                     'hours
    Tm(4) = Makebcd(d1)                                     'days
    Tm(5) = Makebcd(month1)                                 'months


    I2cstart                                                'generate start
    I2cwbyte &HA0                                           'write address
    I2cwbyte 0                                              'select control register
    I2cwbyte 8                                              'set year and day bit for masking
    I2cstart                                                'repeated start
    I2cwbyte &HA0                                           'write mode
    I2cwbyte 2                                              'select seconds Register
    For I = 1 To 5
      I2cwbyte Tm(i)
    Next                                                    'write seconds
    I2cstop
End Sub