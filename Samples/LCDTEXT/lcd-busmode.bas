'------------------------------------------------------------------------------
'                         lcd-busmode.bas
'  demo for custom 8-bit LCD driver
'  see also lcd-bus.lib
'------------------------------------------------------------------------------
$regfile = "m8515.dat"                                      ' specify the used micro
$crystal = 4000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 32                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space
$lib "lcd-bus.lib"                                          ' specify our alternative lib

Config Lcdmode = Bus                                        ' we use bus mode, not pin mode
Config Lcdbus = 8                                           ' this is not needed since we handle it ourself, but add it anyway

Config Lcd = 16 * 4                                         'configure lcd screen

$lcd = &H8000                                               'Address Will Turn Lcd Into 8 -bit Databus Mode
$lcdrs = &H8001

Dim A As Byte

Cls                                                         'clear the LCD display
Lcd "Hello world."                                          'display this at the top line
Lowerline                                                   'select the lower line
Lcd "Shift this."                                           'display this at the lower line

Cursor On
Locate 1 , 1

End