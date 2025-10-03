'------------------------------------------------------------------------------
'name                     : crc8-16-32.bas
'copyright                : (c) 1995-2013, MCS Electronics
'purpose                  : demonstrates CRC
'micro                    : Mega48
'suited for demo          : yes
'commercial addon needed  : no
'------------------------------------------------------------------------------

$regfile = "m48def.dat"                                     ' specify the used micro
$crystal = 8000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 10                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space


Dim Ar(10) As Byte
Dim J As Byte
Dim W As Word
Dim L As Long
Dim S As String * 16


S = "123456789"

Ar(1) = 1
Ar(2) = 2
Ar(3) = 3


J = Crc8(ar(1) , 3)                                         'calculate value which is 216
W = Crc16(ar(1) , 3)                                        '24881
L = Crc32(ar(1) , 3)                                        '1438416925

'                  data , length, intial value , Poly, reflect input, reflect output

Print Hex(Crc16Uni(S , 9 , 0 , &H1021 , 0 , 0))             'CRC-CCITT (0x0000)   31C3
Print Hex(Crc16Uni(S , 9 , &HFFFF , &H1021 , 0 , 0))        'CRC-CCITT (0xFFFF)   29B1
Print Hex(Crc16Uni(S , 9 , &H1D0F , &H1021 , 0 , 0))        'CRC-CCITT (0x1D0F)   E5CC
Print Hex(Crc16Uni(S , 9 , 0 , &H8005 , 1 , 1))             'crc16                BB3D
Print Hex(Crc16Uni(S , 9 , &HFFFF , &H8005 , 1 , 1))        'crc16-modbus         4B37


End