'-------------------------------------------------------------------------------
'                          eadogxl240-7.bas
'                     (c) MCS Electronics 1995-2015
'  Sample to demo the EADOGXL240-7 LCD in I2C mode
'
'-------------------------------------------------------------------------------
$regfile = "M328pdef.dat"                                   ' the used chip
$crystal = 8000000                                          ' frequency used
$baud = 19200                                               ' baud rate
$hwstack = 40
$swstack = 40
$framesize = 40

Config Scl = Portc.5                                        ' we need to provide the SCL pin name
Config Sda = Portc.4                                        ' we need to provide the SDA pin name

$lib "i2c_twi.lbx"                                          ' we do not use software emulated I2C but the TWI
Config Twi = 400000                                         'speed 400 KHz
I2cinit

$lib "glcdEADOGMXL240-7-I2C.lib"                            'override the default lib with this special one
#if _build < 2078
  Dim ___lcdrow As Byte , ___lcdcol As Byte
#endif

Config Graphlcd = Custom , Cols = 240 , Rows = 128 , Lcdname = "EADOGXL240-7"

Cls

Setfont Font8x8tt

'You can use locate but the columns have a range from 1-240
'When you want to show somthing on the LCD, use the LDAT command

Lcdat 1 , 1 , "11111111"
Lcdat 2 , 1 , "88888888"
Lcdat 12 , 64 , "MCS Electronics" , 1

Showpic 60 , 0 , Plaatje

Circle(30 , 30) , 20 , 255
Line(0 , 0) -(239 , 127) , 255                              ' diagonal line
Line(0 , 127) -(239 , 0) , 255                              ' diagonal line

End

$include "font8x8TT.font"


Plaatje:
   $bgf "ks108.bgf"                                         'include the picture data