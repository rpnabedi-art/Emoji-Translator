'-----------------------------------------------------------------
'                  (c) 1995-2011, MCS
'                   xm128A1-ST7565R.bas
'  This sample demonstrates the ST7565R chip with an Xmega128A1
'  Display used : 64128N SERIES from DisplayTech
'  this is a parallel display with read/write options
'-----------------------------------------------------------------

$regfile = "xm128a1def.dat"
$crystal = 32000000
$hwstack = 64
$swstack = 40
$framesize = 40


'first enable the osc of your choice
Config Osc = Enabled , 32mhzosc = Enabled

'configure the systemclock
Config Sysclock = 32mhz , Prescalea = 1 , Prescalebc = 1_1

Config Com1 = 38400 , Mode = Asynchroneous , Parity = None , Stopbits = 1 , Databits = 8
$lib "glcdST7565r.lbx"                                  ' specify the used lib
$lib "glcd.lbx"                                        ' and this one of you use circle/line etc

'the display was connected with these pins
Config Graphlcd = 128 * 64eadogm ,dataport=portj,  Cs1 = Porth.0 , A0 = Porth.2 , rst= Porth.1 , wr = Porth.3 , Rd = Porth.4,c86=porth.6

cls

Setfont Font8x8tt ' set font

dim y as byte

'You can use locate but the columns have a range from 1-128
'When you want to show somthing on the LCD, use the LDAT command
'LCDAT Y , COL, value
Lcdat 1 , 1 , "11111111"
Lcdat 2 , 1 , "ABCDEFGHIJKL1234"
Lcdat 3 , 1 , "MCS Electronics" , 1    ' inverse
Lcdat 4 , 1 , "MCS Electronics"

Waitms 3000
Setfont My12_16 ' use a bigger font

Cls
Lcdat 1 , 1 , "112345678"                                   'a bigger font
Waitms 3000                                                 ' wait

Line(0 , 0) -(127 , 64) , 1                                 'make line
Waitms 2000  'wait 2 secs
Line(0 , 0) -(127 , 64) , 0                                 'remove line by inverting the color

For Y = 1 To 20
   Circle(30 , 30) , Y , 1                                  ' growing circle
   Waitms 100
Next

End


$include "font8x8TT.font"
$include "my12_16.font"