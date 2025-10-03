$nocompile
'=== User definable area =======================================================
' Hardware Definitions:  Port und Pin for CF-Card/HardDisk
' This hard ware setting is for schematic in AN123 on a M128
' without the Line RDY, which is obsolet

' Configuration of Output-Pins must be done by Input-Pin-name till 1.11.7.4
' so output  pins have to be additional declared by their Input-Pin-name


' Constant definitions: No / Low = 0 ; Yes / High = 1

' --- Data Port(s) ------------------------------------------------------------

' Data Port (Low) D0 - D7
Ata_data_low Alias Porta
Ata_data_low_in Alias Pina

Const Ata_databits = 8                                      ' 8 for CF-Card or 16 for Hard Disk

#if Ata_databits = 16
' Data Port High D8 - D15 on Hard Disk
Ata_data_high Alias Portb
Ata_data_high_in Alias Pinb
#endif


' --- Register Address Pins DA0 - DA2 -----------------------------------------

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
Ata_pin_cs0 Alias Pinb.0
Ata_port_cs0 Alias Portb.0
Const Ata_cs0_portonlyoutput = 0                            ' set to 1 on PortC of ATMega103
Const Ata_cs0_activelevel = 0                               ' 0 for direct connect
                                        ' or 1 at address-decoding but depends of real hard ware

' CS1 on HD-IDE / CE2 on CF-Card
Const Ata_cs1_connected = 0                                 ' Not used on Cf-Card => 0 and CE2 to High (VCC) level
Ata_pin_cs1 Alias Pinb.7
Ata_port_cs1 Alias Portb.7
Const Ata_cs1_portonlyoutput = 0                            ' set to 1 on PortC of ATMega103


' DIOR / OE
Ata_pin_dior Alias Pinb.3
Ata_port_dior Alias Portb.3
Const Ata_dior_portonlyoutput = 0                           ' set to 1 on PortC of ATMega103


' DIOW / WE
Ata_pin_diow Alias Pinb.4
Ata_port_diow Alias Portb.4
Const Ata_diow_portonlyoutput = 0                           ' set to 1 on PortC of ATMega103


' Reset
Const Ata_reset_connected = 1
Ata_pin_reset Alias Pinb.2
Ata_port_reset Alias Portb.2
Const Ata_reset_portonlyoutput = 0                          ' set to 1 on PortC of ATMega103
Const Ata_reset_activelevel = 1                             ' set to 1 on CF-Card; set to 0 on hard disk


' Card/Drive Detect CD1
Const Ata_cd1_connected = 1
#if Ata_cd1_connected = 1
Ata_pin_cd1 Alias Pinb.1
Ata_port_cd1 Alias Portb.1                                  ' needed for internal Pull up
#endif
Const Ata_cd1_portinputonly = 0                             ' set to 1 on PortF of ATMega103


Const Waitms_afterreset = 100

'=== End of User definable area ================================================

' Error-Constants from Driver (use 224 to 255)
Const Cperrdrivenotpresent = 225
Const Cperrdrivetimeout = 226
Const Cperrdrivetimeoutcommand = 227
Const Cperrdrivetimeoutdata = 228
Const Cperrdrivetimeoutbusy = 229
Const Cperrdriveerror = 230


' Init the Drive
Dim Gbdriveerror As Byte
Dim Gbdriveerrorreg As Byte                                 ' Driver load Error-Register of HD in case of error
Dim Gbdrivestatusreg As Byte                                ' Driver load Status-Register of HD in case of error
Dim Gbdrivedebug As Byte
Gbdriveerror = Driveinit()
Waitms 1


$lib "CF_HD.lbx"