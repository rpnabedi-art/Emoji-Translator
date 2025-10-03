'-------------------------------------------------------------------------------
'                       SSD1306-I2C.BAS
'                     (c) MCS Electronics 1995-2015
'          Sample to demo the 128x64 I2C OLED display
'
'-------------------------------------------------------------------------------
$regfile = "m88pdef.dat"
$hwstack = 32
$swstack = 32
$framesize = 32
$crystal = 8000000
Config Clockdiv = 1                                         ' make sure the chip runs at 8 MHz

Config Scl = Portc.5                                        ' used i2c pins
Config Sda = Portc.4
Config Twi = 400000                                         ' i2c speed

I2cinit
$lib "i2c_twi.lbx"                                          ' we do not use software emulated I2C but the TWI
$lib "glcdSSD1306-I2C.lib"                                  ' override the default lib with this special one

#if _build < 20784
  Dim ___lcdrow As Byte , ___lcdcol As Byte                 ' dim these for older compiler versions
#endif

Config Graphlcd = Custom , Cols = 128 , Rows = 64 , Lcdname = "SSD1306"
Cls
Setfont Font8x8tt                                           ' select font

Lcdat 1 , 1 , "BASCOM-AVR"
Lcdat 2 , 10 , "1995-2015"
Lcdat 8 , 5 , "MCS Electronics" , 1
Waitms 3000

Showpic 0 , 0 , Plaatje

End


$include "font8x8TT.font"                                   ' this is a true type font with variable spacing


Plaatje:
   $bgf "ks108.bgf"                                         ' include the picture data