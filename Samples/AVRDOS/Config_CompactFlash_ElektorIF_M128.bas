$nocompile
'=== User definable area =======================================================
' Hardware Definitions:  Port und Pin for CF-Card/HardDisk
' This hardwaresetting is for the CompactFlashCard Interface Elektor Issue 2003-01
' This layout uses the Interface in PIN-Mode (not in XRAM mode!!)

' 8-Bit Data Low (DD0 - DD7)
Ata_data_low Alias Porta
Ata_data_low_in Alias Pina

Const Ata_databits = 8

#if Ata_databits = 16
' 8-Bit Data High (DD8 - DD15)
Ata_data_high Alias Portb
Ata_data_high_in Alias Pinb
#endif


' Port of Register Address Pins DA0 - DA2


' Address Pins A0
Ata_pin_da0 Alias Pinc.0
Ata_port_da0 Alias Portc.0
Const Ata_da0_portonlyoutput = 0                            ' set to 1 on PortC of ATMega103

' Address Pins A1
Ata_pin_da1 Alias Pinc.1
Ata_port_da1 Alias Portc.1
Const Ata_da1_portonlyoutput = 0                            ' set to 1 on PortC of ATMega103

' Address Pins A2
Ata_pin_da2 Alias Pinc.2
Ata_port_da2 Alias Portc.2
Const Ata_da2_portonlyoutput = 0                            ' set to 1 on PortC of ATMega103


'--- other Drive Control Pins -------------------------------------------------
' CS0 on HD-IDE / CE1 on CF-Card
Ata_pin_cs0 Alias Pinc.5
Ata_port_cs0 Alias Portc.5
Const Ata_cs0_portonlyoutput = 0                            ' set to 1 on PortC of ATMega103
Const Ata_cs0_activelevel = 1

' CS1 on HD-IDE / CE2 on CF-Card
Const Ata_cs1_connected = 0
Ata_pin_cs1 Alias Pinb.7
Ata_port_cs1 Alias Portb.7
Const Ata_cs1_portonlyoutput = 0                            ' set to 1 on PortC of ATMega103


' DIOR / OE
Ata_pin_dior Alias Pinc.3
Ata_port_dior Alias Portc.3
Const Ata_dior_portonlyoutput = 0                           ' set to 1 on PortC of ATMega103

' DIOW / WE
Ata_pin_diow Alias Pinc.4
Ata_port_diow Alias Portc.4
Const Ata_diow_portonlyoutput = 0                           ' set to 1 on PortC of ATMega103

' Reset
Const Ata_reset_connected = 0
Ata_pin_reset Alias Pinb.2
Ata_port_reset Alias Portb.2
Const Ata_reset_portonlyoutput = 0                          ' set to 1 on PortC of ATMega103
Const Ata_reset_activelevel = 1                             ' set to 1 on CF-Card; set to 0 on hard disk

' Card/Drive Detect CD1
Const Ata_cd1_connected = 0
#if Ata_cd1_connected = 1
Ata_pin_cd1 Alias Pinb.1
Ata_port_cd1 Alias Portb.1                                  ' needed for activating Pull up
#endif
Const Ata_cd1_portinputonly = 0                             ' set to 1 on PortF of ATMega103


Const Waitms_afterreset = 100

'=== End of User definable area ================================================

' Declare here used Error-Constants from Driver (use 224 to 255)
Const Cperrdrivenotpresent = 225
Const Cperrdrivetimeout = 226
Const Cperrdrivetimeoutcommand = 227
Const Cperrdrivetimeoutdata = 228
Const Cperrdrivetimeoutbusy = 229
Const Cperrdriveerror = 230


' Init the Drive
Dim Gbdriveerror As Byte
Dim Gbdriveerrorreg As Byte                                 ' Driver load Error-Register of HD in case of error
Dim Gbdrivestatusreg As Byte                                ' Driver load Status-Register of HD on case of error
Dim Gbdrivesense As Byte
Dim Gbdrivedebug As Byte
Gbdriveerror = Driveinit()
Waitms 1


$lib "CF_HD.lbx"