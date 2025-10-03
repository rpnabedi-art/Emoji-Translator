'----------------------------------------------------------------
'                  (c) 1995-2011, MCS
'                      xm128-AES.bas
'  This sample demonstrates the Xmega128A1 AES encryption/decryption
'-----------------------------------------------------------------

$RegFile = "xm128a1def.dat"
$crystal = 32000000
$hwstack = 64
$swstack = 40
$framesize = 40


'first enable the osc of your choice
Config Osc = Enabled , 32mhzosc = Enabled

'configure the systemclock
Config Sysclock = 32mhz , Prescalea = 1 , Prescalebc = 1_1

Config Com1 = 38400 , Mode = Asynchroneous , Parity = None , Stopbits = 1 , Databits = 8

'$external _aes_enc

Dim Key(16) As Byte                                         ' room for key
Dim Ar(34) As Byte
Dim Arenc(34) As Byte
Dim J As Byte
Print "AES test"

Restore Keydata
For J = 1 To 16                                             ' load a key to memory
   Read Key(j)
Next

'load some data
For J = 1 To 32                                             ' fill some data to encrypt
  Ar(j) = J
Next


Aesencrypt Keydata , Ar(1) , 32
Print "Encrypted data"
For J = 1 To 32                                             ' fill some data to encrypt
  Print Ar(j)
Next


Aesdecrypt Keydata , Ar(1) , 32
Print "Decrypted data"
For J = 1 To 32                                             ' fill some data to encrypt
  Print Ar(j)
Next

Print "Encrypt function"
Arenc(1) = Aesencrypt(keydata , Ar(1) , 32)
For J = 1 To 32                                             ' fill some data to encrypt
  Print Ar(j) ; "-" ; Arenc(j)
Next

Print "Decrypt function"
Ar(1) = Aesdecrypt(keydata , Arenc(1) , 32)

For J = 1 To 32
 Print J ; ">" ; Ar(j) ; "-" ; Arenc(j)
Next

End



Keydata:
Data 1 , 2 , 3 , 4 , 5 , 6 , 7 , 8 , 9 , 10 , 11 , 12 , 13 , 14 , 15 , 16
