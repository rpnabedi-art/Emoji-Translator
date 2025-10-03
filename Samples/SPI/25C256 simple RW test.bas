'-----------------------------------------------------------------------------------------
'name                     : 25C256 simple RW test.bas
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



' External EEPROM Config
Config Portb.4 = Output
Config Portb.7 = Output
Config Portb.5 = Output
Fram_cs Alias Portb.4 : Const Fram_csp = 4 : Const Fram_csport = Portb
Fram_so Alias Pinb.6 : Const Fram_sop = 6 : Const Fram_soport = Pinb
Fram_si Alias Portb.5 : Const Fram_sip = 5 : Const Fram_siport = Portb
Fram_sck Alias Portb.7 : Const Fram_sckp = 7 : Const Fram_sckport = Portb

$eepromsize = &H8000
$lib "fm25c256.lib"

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
      Print "Read " ; C ; ":" ; B ; "/" ; Hex(b)
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
      Print "Read " ; C ; ":" ; B ; "/" ; Hex(b)
      Waitms 4
   Next

   Wait 2


Loop

End
'-------------------------------------------------------------------------------