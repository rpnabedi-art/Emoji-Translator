'----------------------------------------------------------
'                     XTEA.BAS
' This sample demonstrates the XTEA encryption/decryption
' statements
'             (c) 1995-2012 MCS Electronics
'----------------------------------------------------------
$regfile = "m88def.dat"
$hwstack = 40
$swstack = 32
$framesize = 32

'The XTEA encryption/decryption has a small footprint
'XTEA processes data in blocks of 8 bytes. So the minimum length of the data is 8 bytes.
'A 128 bit key is used to encrypt/decrypt the data. You need to supply this in an array of 8 bytes.

'Using the encoding on a string can cause problems when the data contains a 0. This is the end of the string marker.

Dim Key(16) As Byte                                         '128 bit key
Dim Msg(32) As Byte                                         ' this need to be a multiple of 8

Dim B As Byte                                               ' counter byte

For B = 1 To 16                                             ' create a simple key and also fill the data
  Key(b) = B
  Msg(b) = B
Next


Xteaencode Msg(1) , Key(1) , 32                             ' encode the data

For B = 1 To 16
  Print Hex(msg(b)) ; " , " ;
Next
Print


Xteadecode Msg(1) , Key(1) , 32                             ' decode the data

For B = 1 To 16
  Print Hex(msg(b)) ; " , " ;
Next                                                        'it should print 1-16 now
Print

End