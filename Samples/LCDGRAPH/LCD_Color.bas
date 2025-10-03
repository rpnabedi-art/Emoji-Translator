' ------------------------------------------------------------------------------------------------------------
' The support for this display has been made possible by Peter Küsters from (c) Display3000
' You can buy the displays from Display3000 or MCS Electronics
' ------------------------------------------------------------------------------------------------------------'
'
$lib "lcd-pcf8833.lbx"                                      'special color display support
'$lib "lcd-epson.lbx"                                        'special color display support


$regfile = "m88def.dat"                                     'ATMega 8, change if using different processors
'$regfile = "usb1287.dat"                                    'ATMega 8, change if using different processors

$crystal = 8000000                                          '8 MHz
$hwstack = 40
$swstack = 40
$framesize = 40


'First we define that we use a graphic LCD
Config Graphlcd = Color , Controlport = Portc , Cs = 1 , Rs = 0 , Scl = 3 , Sda = 2

'here we define the colors

Const Blue = &B00000011                                     ''predefined contants are making programming easier
Const Yellow = &B11111100
Const Red = &B11100000
Const Green = &B00011100
Const Black = &B00000000
Const White = &B11111111
Const Brightgreen = &B00111110
Const Darkgreen = &B00010100
Const Darkred = &B10100000
Const Darkblue = &B00000010
Const Brightblue = &B00011111
Const Orange = &B11111000


'clear the display
Cls

'create a cross
Line(0 , 0) -(130 , 130) , Blue
Line(130 , 0) -(0 , 130) , Red

Waitms 1000

'show an RLE encoded picture
'Showpic 0 , 0 , Plaatje
'Showpic 40 , 40 , Plaatje

Waitms 1000

'select a font
Setfont Color16x16
'and show some text
Lcdat 100 , 0 , "12345678" , Blue , Yellow

'Setfont Color8x8
'and show some text
'Lcdat 10 , 0 , "12345678" , Blue , Red



Waitms 1000
'Circle(30 , 30) , 10 , Blue

Waitms 1000
'make a box
Box(10 , 30) -(60 , 100) , Red

'set some pixels
Pset 32 , 110 , Black
Pset 38 , 110 , Black
Pset 35 , 112 , Black


End



Plaatje:
'$bgf "mcse.bgc"


'$include "color8x8.font"
$include "color16x16.font"