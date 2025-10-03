'--------------------------------------------------------------------
'                         EADIP180.BAS
' demonstrates the SED1520 based graphical display support
'--------------------------------------------------------------------
'some routines to control the display are in the glcdEADIP180.lib file
'IMPORTANT : since the SED1520 uses 3 chips, the columns are split into 3 of 60.
'This means that data after column 60 will not print correct. You need to locate the data on the second halve
$regfile = "m32def.dat"
$crystal = 14745600
$lib "glcdEADIP180.lbx"
$hwstack = 40
$swstack = 40
$framesize = 40


$initmicro                                                  'user connected RESET of LCD to pin portd.7

Config Pinc.6 = Output                                      'we use these pins to control the LCD too
Config Pinc.7 = Output

'First we define that we use a graphic LCD
'notice that this library supports extended syntax where you can specify different port pins for CD and RD
Config Graphlcd = 180 * 64sed , Dataport = Porta , Controlport = Portd , Ce = 4 , Ce2 = 5 , Ce3 = 6 , Cd = Portc.7 , Rd = Portc.6


'Dim variables (y not used)
Dim X As Byte , Y As Byte

'clear the screen
Cls

Wait 1
'specify the font we want to use

Setfont Font8x8

'You can use locate but the columns have a range from 1-132

'When you want to show somthing on the LCD, use the LDAT command
'LCDAT Y , COL, value
Lcdat 1 , 1 , "1234567890123456789012"

Lcdat 3 , 80 , "11"
'lcdat accepts an additional param for inversing the text
Lcdat 4 , 100 , "Inverse" , 1                               ' will inverse the text

Wait 2
Line(0 , 0) -(180 , 31) , 1
Wait 2

Showpic 0 , 0 , Plaatje                                     'show a comnpressed picture
Wait 2
Cls
Box(0 , 0) -(60 , 20) , 1
Wait 1
Cls
'create a bargraph effect
Boxfill(0 , 0) -(60 , 10) , 1
Boxfill(2 , 2) -(40 , 8) , 0
Setfont Font16x16
Lcdat 1 , 80 , "16x16"
End                                                         'end program

_init_micro:
Config Pind.7 = Output
Portd.7 = 0
Wait 1
Portd.7 = 1
Return

'we need to include the font files
$include "font8x8.font"
$include "font16x16.font"



Plaatje:
'include the picture data
$bgf "smile.bgf"