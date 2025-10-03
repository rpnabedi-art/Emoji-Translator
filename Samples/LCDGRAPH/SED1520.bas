'I used a Staver to test
$regfile = "m32def.dat"
$crystal = 14745600
$baud = 115200
$hwstack = 40
$swstack = 40
$framesize = 40


'--------------------------------------------------------------------
'                         SED1520.BAS
' demonstrates the SED1520 based graphical display support
'--------------------------------------------------------------------
'some routines to control the display are in the glcdSED.lib file
'IMPORTANT : since the SED1520 uses 2 chips, the columns are split into 2 of 60.
'This means that data after column 60 will not print correct. You need to locate the data on the second halve
'For example when you want to display a line of text that is more then 8 chars long, (8x8=64) , byte 8 will not draw correctly
'Frankly i find the KS0108 displays a much better choice.


$lib "glcdSED1520.lbx"


'First we define that we use a graphic LCD

Config Graphlcd = 120 * 64sed , Dataport = Porta , Controlport = Portd , Ce = 5 , Ce2 = 7 , Cd = 3 , Rd = 4


'The dataport is the portname that is connected to the data lines of the LCD
'The controlport is the portname which pins are used to control the lcd
'CE =CS  Chip Enable/ Chip select
'CE2= Chip select / chip enable of chip 2
'CD=A0   Data direction
'RD=Read

'Dim variables (y not used)
Dim X As Byte , Y As Byte


'clear the screen
Cls
Wait 2
'specify the font we want to use
Setfont Font8x8

'You can use locate but the columns have a range from 1-132

'When you want to show somthing on the LCD, use the LDAT command
'LCDAT Y , COL, value
Lcdat 1 , 1 , "1231231"
Lcdat 3 , 80 , "11"
'lcdat accepts an additional param for inversing the text
'lcdat 1,1,"123" , 1  ' will inverse the text

Wait 2
Line(0 , 0) -(30 , 30) , 1
Wait 2

Showpic 0 , 0 , Plaatje                                     'show a comnpressed picture
End                                                         'end program


'we need to include the font files
$include "font8x8.font"
'$include "font16x16.font"





Plaatje:
'include the picture data
$bgf "smile.bgf"