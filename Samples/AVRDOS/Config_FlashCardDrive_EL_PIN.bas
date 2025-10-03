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

' Control - Port (CE1, OE, WE)
Cf_control_out Alias Portc
'CF_Control_DDR alias DDRC               ' not on Mega103

' Pins at Control-Port
Const Cf_ce1 = 5 : Cf_ce1 Alias 5                           ' Card enable
Const Cf_oe = 3 : Cf_oe Alias 3                             ' Output enable
Const Cf_we = 4 : Cf_we Alias 4                             ' Write enable

' Mask for setting direction for Control-pins
Const Cf_control_direction =(2 ^ Cf_ce1) +(2 ^ Cf_oe) +(2 ^ Cf_we)       ' CE1, OE, WE to output = 1
' Mask for setting init levels for control-pins
Const Cf_control_init =(2 ^ Cf_oe) +(2 ^ Cf_we)
' Mask for clear control pins and left other unchanged
Const Cf_control_mask = 255 - Cf_control_direction          ' CE1, OW, WE to 0, unused to 1


' Address - Port ( A2. A1, A0) at pin 2 - 0 for eaysier handling
Cf_addr_out Alias Portc
'CF_Addr_DDR alias DDRC              ' not on Meag103

' Mask for setting direction for address-pins
Const Cf_addr_direction = &B00000111                        ' A2 , A1, A0 to Output = 1
' Mask for setting init levels for address-pins
Const Cf_addr_init = 0
' Mask for clear address pins and left other unchanged
Const Cf_addr_mask = 255 - Cf_addr_direction



' Declare here used Error-Constants from Driver (use 224 to 255)
Const Cperrdrivenotpresent = 225
Const Cperrdriveerror = 229
Const Cperrdrivetimeout = 226
Const Cperrdrivetimeoutcommand = 227
Const Cperrdrivetimeoutdata = 228
Const Cperrdrivetimeoutbusy = 229



$lib "FlashCardDrive_EL_PIN.LBX"

' Init the Drive
' use a r24 to scratch
_temp1 = Driveinit()
Waitms 1                                                    ' force compiler to link _waitms routine
                                          ' can't be linked with 'EXTERNAL in LIB