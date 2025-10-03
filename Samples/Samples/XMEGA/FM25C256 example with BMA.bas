'____________________________________________________________________________________
'                                                            Using the FM25C256 library

'  The FM25C256 library uses the CYPRESS FM25W256  chip (before named FM25C256 by Ramtron)
'  This chip is based in FRAM technology, which makes it much faster than an EEPROM  and has a much
'  longer life (100.000.000.000.000 read/writes)
'  To give an idea of speed, writting a byte to an XMEGA192A3 internal EEPROM takes more than 10580us
'  while writing a byte  to the FM25W256 chip using the FM25C256 library  takes 32,5us in this example;
'  this is more than 325 times  faster.

' NOTES:
'     -  This library allows you to use an external EEPROM INSTEAD of the internal EEPROM (you cannot use both)
'     -  Do not use the "Config Eeprom = " command when using this library
'     -  The FM25C256 library uses software SPI; therefore,  if you need to share the SPI bus with another chip
'         that uses  HW SPI, you must:
'              - Configure the HW SPI normally  (with the "Config SpiX =" command in XMEGA chips)  as needed for
'                 the other chip
'              - Disable HW SPI before reading or writing to EEPROM, and enable it after.

' In this example, there are two chips connected to the SPIC bus of an XMEGA192A3, an accelerometer BMA180
' and the FM25W256 FRAM chip.

' The HW SPIC of the XMEGA192A3  is configured at the begining to allow for the BMA180 to be read while the
'  FM25W256 is not used.
'____________________________________________________________________________________

$regfile = "xm192a3def.dat"
$hwstack = 256
$swstack = 256
$framesize = 256
'____________________________________________________________________________________

'   For  16MHz crystal
Config Osc = Disabled , Extosc = Enabled , Range = 12mhz_16mhz , Startup = Xtal_1kclk , 32khzosc = Enabled
' Set PLL OSC conditions:
Osc_pllctrl = &B1100_0010                                   ' Reference external oscillator, set the PLL' multiplication factor to 2 (bits 0 - 4)
Set Osc_ctrl.4                                              ' Enable PLL Oscillator
Bitwait Osc_status.4 , Set                                  ' wait until the pll clock reference source is stable
Clk_ctrl = &B0000_0100                                      ' switch system clock to pll
' Prescale
Config Sysclock = Pll , Prescalea = 1 , Prescalebc = 1_1
$crystal = 32000000
'____________________________
Const Fclock = 32000000
'____________________________________________________________________________________

'Config Eeprom = Mapped                            ' Do not put this command when using an external EEPROM
 '____________________________________________________________________________________

Config Priority = Static , Vector = Application , Lo = Enabled , Med = Enabled , Hi = Enabled
Enable Interrupts

'================================ COM1 (C2 C3)  C0  ==================================

' COM1        RS232_1
Config Com1 = 230400 , Mode = Asynchroneous , Parity = None , Stopbits = 1 , Databits = 8
Config Serialin0 = Buffered , Size = 254
Config Serialout0 = Buffered , Size = 254
Open "COM1:" For Binary As #1

'==================================    SPIC for FRAM    ================================

' External EEPROM Config
Fram_cs Alias Porta.7 : Const Fram_csp = 7 : Const Fram_csport = Porta : Config Porta.7 = Output
Fram_si Alias Portc.5 : Const Fram_sip = 5 : Const Fram_siport = Portc : Config Portc.5 = Output
Fram_sck Alias Portc.7 : Const Fram_sckp = 7 : Const Fram_sckport = Portc : Config Portc.7 = Output
Fram_so Alias Portc.6 : Const Fram_sop = 6 : Const Fram_soport = Pinc

$eepromsize = &H32000                                       ' Size, in bytes, of the FM25W256 memory
'____________________________________________________________________________________

$lib "fm25c256.lib"                                         '
'NOTE:
'While using the lib, the hardware SPI should be disabled. you can do this by writing to the SPIx_CTRL register
' SPIC_CTRL.6=0   'disable SPI
'Then use the eeprom commands, and re-enable the SPI after that : SPIC_CTRL.6=1
'Also notice that clock level must be low at entrance for FM25W256
'    Fram_sck = 0                                            ' Need to put this before accesing the chip
     'eprom commands here
 ' Before re-enable hw spi, set clock pin to high, and enabe with spic_ctrl.6=1
'____________________________________________________________________________________

 ' Configure HW SPIC to use a  BMA180
Config Spic = Hard , Master = Yes , Mode = 3 , Clockdiv = Clk8 , Data_order = Msb , Ss = None
'  Open device
Open "SPIC" For Binary As #10

Bma_ss Alias Portc.4 : Config Portc.4 = Output : Bma_ss = 1       ' /SS del bma180

'____________________________________________________________________________________

Dim Dwtemp_ee As Eram Dword
Dim Dwtemp As Dword
Dim N As Byte
N = 0
Dim I As Byte

Dim Acel_x As Integer
'____________________________________________________________________________________

Do
'  ------------------------
   Incr N
'  ------------------------
' Disable HW SPi before writing to EEPROM  FM25W256
   Spic_ctrl.6 = 0
   Fram_sck = 0                                             ' Clock level must be low at entrance for fm25256
' Write to EEPROM FM25W256
   Dwtemp = N                                               ' Convert Byte to Dword. When writing to EEPROM variables must be of the same type
   Dwtemp_ee = Dwtemp                                       ' This takes 51,1us
' Read from EEPROM FM25W256
   Dwtemp = Dwtemp_ee                                       ' This takes 42,2us
' Enable  HW SPI. It must be done with SCK high
   Fram_sck = 1
   Spic_ctrl.6 = 1                                          ' Enable HW SPI
'  ------------------------
'  Show  value stored and then retrieved from EEPROM
   Print #1 , N ; ":" ; Dwtemp ; "  ";
'  ------------------------
   Gosub Read_bma_x
   Print #1 , Acel_x ; "mG"
'  ------------------------
   Waitms 500
'  ------------------------
Loop

'____________________________________________________________________________________

'                                         READ THE BMA180 X AXIS ACCELERATION
'____________________________________________________________________________________

Dim Bma_adr_byte As Byte
Dim Spi_byte As Byte
Dim Msb_itemp As Integer
Dim Lsb_itemp As Integer
' Dim Aceleracion_tmp As Integer
Const Acc_x_msb = &H3
Const Acc_x_lsb = &H2
 '____________________________________________________________________________________

Read_bma_x:
   '_________________________ Read  Acel_X_LSB
   Bma_ss = 0
   Bma_adr_byte = Acc_x_lsb                              ' X_LSB
   Bma_adr_byte.7 = 1                                    ' Read command
   Print #10 , Bma_adr_byte                             ' Send address
   Input #10 , Spi_byte                                 ' Read  spibyte= | d5 d4 d3 d2  d1  d0 | 0 | 1  |
   Bma_ss = 1                                            ' De-select BMA 180
   Shift Spi_byte , Right , 2
   Lsb_itemp = Spi_byte
   '_________________________ Read Acel_X_MSB
   Bma_ss = 0
   Bma_adr_byte = Acc_x_msb                              ' X_MSB
   Bma_adr_byte.7 = 1                                    ' Read command
   Print #10 , Bma_adr_byte                              ' Send address
   Input #10 , Spi_byte                                  ' Read spibyte= |d13 d12  d11 d10 d9  d8 d7 d6 |
   Bma_ss = 1                                            ' De-select BMA180
   Msb_itemp = Spi_byte
   Shift Msb_itemp , Left , 6
   Lsb_itemp = Lsb_itemp Or Msb_itemp
   Lsb_itemp.14 = Spi_byte.7
   Lsb_itemp.15 = Spi_byte.7

   Acel_x = Lsb_itemp

Return
'____________________________________________________________________________________

End