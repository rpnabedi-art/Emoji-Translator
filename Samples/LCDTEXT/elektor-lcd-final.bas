'------------------------------------------------------------------------------
'               ELEKTOR WORKSHOP BASCOM-AVR
'                      ELEKTOR-LCD-FINAL
' This program demonstrate the special ATM18 CC2 LCD board driver
'------------------------------------------------------------------------------
$regfile = "m88def.dat"
$crystal = 8000000
$hwstack = 40
$swstack = 40
$framesize = 40
'------------------------------------------------------------------------------
Config Clockdiv = 1

Config Lcdpin = Pin                                         ' we used pin mode
Config Lcd = 16 * 2

Pe_ddr Alias Ddrb
Pe_data Alias Portb.2
Pe_clock Alias Portb.3
Pe_port Alias Portb
Pe_data_pin Alias 2
Pe_clock_pin Alias 3

$lib "lcd4-elektor.lib"                                     ' use special elektor driver

Cls
Lcd "CC2 Test"
Lowerline : Lcd "Elektor ATM18"

Config Portb.4 = Output
Do
  Toggle Portb.4
  Waitms 1000
Loop

End

