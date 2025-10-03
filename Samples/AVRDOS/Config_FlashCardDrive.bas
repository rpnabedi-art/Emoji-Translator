$nocompile
' THIS IS AN INCLUDE FILE
' DO NOT COMPILE

' Hardware Definitions:  Port und Pin for FlashCard

' Data Port (D0-D7)
Cf_data_out Alias Porta
Cf_data_in Alias Pina
Cf_data_ddr Alias Ddra

' CF - Register - addressing (A0-A2)
' addresses uses 3 LSB Bit x x x x x A2 A1 A0
Cf_addr_out Alias Portc

'!!!!!!!!!!!!!!!!!!!!!!!!!
 Cf_addr_in Alias Pinc                                      ' Port C nur Output
 Cf_addr_ddr Alias Ddrc
' remove Comment-mark ' if bidirectional Port is used

' Control - Port (CE1, CD1, RESET, OE, WE, RDY)
Cf_control_out Alias Portb
Cf_control_in Alias Pinb
Cf_control_ddr Alias Ddrb

' Pins at Control-Port
Cf_ce1 Alias 0                                              ' Card enable
Cf_cd1 Alias 1                                              ' Card detect
Cf_reset Alias 2                                            ' Reset-Pin
Cf_oe Alias 3                                               ' Output enable
Cf_we Alias 4                                               ' Write enable
Cf_rdy Alias 5                                              ' Card ready

' Input/Output at control-port: Set Output pin to 1 (CF_CE1, CF_Reset, CF_OE, CF_WE)
Const Cf_control_direction = &B00011101                     ' Set

' Output at control-port at init: Set CF_OE and CF_WE to 1
Const Cf_control_init = &B00011000

' Masking used pin at controlport, set unused pins to 1
Const Cf_control_dir_mask = &B11000000

' Declare here used Error-Constants from Driver (use 224 to 255)
Const Cperrdrivenotpresent = 225

'Declare Function Drivereadsector(pwsrampointer As Word , Plsectornumber As Long) As Byte
'Declare Function Drivewritesector(pwsrampointer As Word , Plsectornumber As Long ) As Byte
'Declare Function Drivegetidentity(pwsrampointer As Word ) As Byte
'Declare Function Driveinit() As Byte
'Declare Function Drivereset() As Byte
'Declare Function Drivecheck() As Byte

'


'$external Drivereadsector , Drivewritesector , Drivegetidentity , Driveinit , Drivereset , Drivecheck

$lib "FlashCardDrive.LBX"

' Init the Drive
' use a r24 to scratch
_temp1 = Driveinit()
'Waitms 1                                                    ' force compiler to link _waitms routine
                                          ' can't be linked with $EXTERNAL in LIB