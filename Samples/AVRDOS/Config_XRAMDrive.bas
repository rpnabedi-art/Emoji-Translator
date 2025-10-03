' THIS IS AN INCLUDE FILE
' DO NOT COMPILE

' Hardware Definitions:  Port und Pin for FlashCard
Dim Gbdriveerror As Byte 

Dim DriveXRAMStart as XRAM Byte
Const DriveXRAMSize = &H10000 - &H1000
Const cpErrDriveInvalidSectorNumber = 228
Const cpErrDriveWriteError = 226
Const cpErrDriveNotSupported = 229


Const cpDriveNotPresent = &HC0          ' Error code for no drive attached
_temp1 = driveinit()

$Lib "XRAMDrive.Lib"