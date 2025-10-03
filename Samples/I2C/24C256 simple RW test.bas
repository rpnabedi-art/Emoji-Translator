'-----------------------------------------------------------------------------------------
'name                     : 24C256 simple RW test.bas
'copyright                : (c) 1995-2013, MCS Electronics
'purpose                  : Testing Read/Write operation with external EEPROM
'micro                    : Mega8535
'suited for demo          : no
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------

$regfile = "m8535.dat"                                      ' specify the used micro
$crystal = 8000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 64                                               ' default use 32 for the hardware stack
$swstack = 20                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space

$lib "i2c_twi.lbx"                                          ' we do not use software emulated I2C but the TWI

Config Scl = Portc.0                                        ' we need to provide the SCL pin name
Config Sda = Portc.1                                        ' we need to provide the SDA pin name

I2cinit                                                     ' we need to set the pins in the proper state

Config Twi = 100000                                         ' wanted clock frequency

' External EEPROM Config
$eepromsize = &H8000
$lib "fm24c64_256.lib"

Dim A(101) As Eram Byte
Dim B As Byte
Dim C As Byte
Dim D As Byte

Do
   Input "Data to write ? (0-255)" , D

   Print "Reading content of EEPROM (via ERAM Byte)"
   For C = 0 To 100
      B = A(c)
      Print "Read " ; C ; ":" ; B ; "/" ; Hex(b)
      Waitms 4
   Next

   Wait 1

   Print "Writing data to EEPROM (via ERAM Byte)"
   For C = 0 To 100
      A(c) = D
      Print "Write " ; C ; ":" ; D ; "/" ; Hex(d)
      Waitms 4
   Next

   Wait 1

   Print "Reading back data from EEPROM (via ERAM Byte)"
   For C = 0 To 100
      B = A(c)
      Print "Read " ; C ; ":" ; B ; "/" ; Hex(b)
      Waitms 4
   Next

   Wait 2

   Input "Data to write ? (0-255)" , D

   Print "Reading content of EEPROM (via READEEPROM)"
   For C = 0 To 100
      Readeeprom B , C
      Print "Read ";C ; ":" ; B ; "/" ; Hex(b)
      Waitms 4
   Next

   Wait 1

   Print "Writing data to EEPROM (via WRITEEEPROM)"
   For C = 0 To 100
      Writeeeprom D , C
      Print "Writing " ; C ; ":" ; D ; "/" ; Hex(d)
      Waitms 4
   Next

   Wait 1

   Print "Reading content of EEPROM (via READEEPROM)"
   For C = 0 To 100
      Readeeprom B , C
      Print "Read ";C ; ":" ; B ; "/" ; Hex(b)
      Waitms 4
   Next

   Wait 2

Loop

End
'-------------------------------------------------------------------------------