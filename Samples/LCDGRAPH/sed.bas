'--------------------------------------------------------------------
'                         SED.BAS
' demonstrates the SED based graphical display support
'--------------------------------------------------------------------
'some routines to control the display are in the glcdSED.lib file
$regfile = "m88def.dat"
$lib "glcdSED.lib"
$hwstack = 40
$swstack = 40
$framesize = 40


'I used a 2313 with 10 MHz
$crystal = 10000000

'First we define that we use a graphic LCD
Config Graphlcd = 128 * 64sed , Dataport = Portb , Controlport = Portd , Ce = 2 , Cd = 4 , Wr = 5 , Rd = 6 , Reset = 3

'The dataport is the portname that is connected to the data lines of the LCD
'The controlport is the portname which pins are used to control the lcd
'CE =CS  Chip Enable/ Chip select
'CD=A0   Data direction
'WR= Write
'RD=Read
'RESET = reset

'Dim variables (y not used)
Dim X As Byte , Y As Byte


'clear the screen
Cls

'specify the font we want to use
Setfont Font16x16

'You can use locate but the columns have a range from 1-132

'When you want to show somthing on the LCD, use the LDAT command
'LCDAT Y , COL, value
Lcdat 1 , 1 , "123"
'lcdat accepts an additional param for inversing the text
'lcdat 1,1,"123" , 1  ' will inverse the text

'Now use a different font
Setfont Font8x8
'since the 16*16 font uses 2 rows, show on row 3
Lcdat 3 , 1 , "123"

End                                                         'end program


'(
'Optional try this out by unremarking the block remarks
'draw a line
Line(0 , 0) -(128 , 64) , 1
'Line(0 , 64) -(128 , 0) , 1
'check for circles

Wait 2
Display Off
Wait 2
Display On

'use glcdcmd to send a control byte to the display
Glcdcmd &HA7                                                ' reverse display
Wait 1
Glcdcmd &HA6                                                ' normal display

'adjust contrast
For X = 0 To 63
  Glcdcmd &H81                                              ' electronic volume (contrast)
  Glcdcmd X                                                 ' higher means more contrast
  Waitms 100
Next

'you could display a picture too
Showpic 8 , 8 , Plaatje
End

')
'end of block remark on line above

'we need to include the font files
$include "font8x8.font"
$include "font16x16.font"


Plaatje:
'include the picture data
'$bgf "smile.bgf"