$regfile = "m32def.dat"
$crystal = 4000000
$sim
$lib "lcd4.lbx"                                             ' use the alternative library
$hwstack = 40
$swstack = 40
$framesize = 40

'in order for simulation to work correct, you need to specify the used pins
'for lcd4.lbx, the pins are fixed
'Rs = PortB.0
'RW = PortB.1        we dont use the R/W option of the LCD in this version so connect to ground
' E = PortB.2
'E2 = PortB.3        optional for lcd with 2 chips
'Db4 = PortB.4       the data bits must be in a nibble to save code
'Db5 = PortB.5
'Db6 = PortB.6
'Db7 = PortB.7

Config Lcdpin = Pin , Rs = Portb.0 , E = Portb.2 , Db4 = Portb.4 , Db5 = Portb.5 , Db6 = Portb.6 , Db7 = Postb.7

Config Lcd = 16x2

Cls
Lcd "test"
Lowerline
Lcd "12345678"
End