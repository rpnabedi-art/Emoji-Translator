'-----------------------------------------------------------
'                     EADOGM132x32.BAS
'               (c) 1995-2009 MCS Electronics
' micro : m324p
' demo  : SPI graphical display EADOGM132x32
' IMPORTANT : SPI only allows the WRITE mode. THis mean that setting pixels is not possible.
'             for this reason commands as PSET, LINE and CIRCLE are not supported.
'             best option would be to display pictures
' fonts and images are compatible with KS108
'-----------------------------------------------------------
$regfile = "m324pdef.dat"                                   ' ATmega168
$crystal = 8000000
'$lib "glcdeadogm128x6.lbx"                                  ' specify the used lib
$lib "glcdEADOGM132x32.lib"
$hwstack = 40
$swstack = 40
$framesize = 40


'the display was connected with these pins
Config Graphlcd = 128 * 64eadogm , Cs1 = Portb.2 , A0 = Porta.6 , Si = Portb.4 , Sclk = Porta.5 , Rst = Porta.7
'the best option is to control the reset line of the LCD with the micro so you can reset it controlled at startup


Dim B As Byte , J As Byte
Dim K As Byte , X As Word , Y As Word


Cls

'specify the font we want to use
Setfont Font8x8


'You can use locate but the columns have a range from 1-128
'When you want to show somthing on the LCD, use the LDAT command
'LCDAT Y , COL, value
Lcdat 1 , 1 , "11111111"
Lcdat 2 , 1 , "ABCDEFGHIJKL1234"
Lcdat 3 , 1 , "MCS Electronics" , 1
Lcdat 4 , 1 , "MCS Electronics"

Wait 3
Locate 1 , 1 : Lcd "TEST"

'Cls
'Setfont Font16x16sajat
'Lcdat 3 , 1 , "HELLO"

End


Plaatje:
'include the picture data
'$bgf "ks108.bgf"

'include used fonts
$include "font8x8.font"
'$include "font16x16sajat.font"
