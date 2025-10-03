'-----------------------------------------------------------------------------------------
'name                     : ks108.bas
'copyright                : (c) 1995-2008, MCS Electronics
'purpose                  : demonstrates the KS108 based graphical display support
'micro                    : Mega128
'suited for demo          : no
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------

$regfile = "m128def.dat"                                    ' specify the used micro
$crystal = 8000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 40                                               ' use 40 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space


'some routines to control the display are in the glcdKS108.lib file
$lib "glcdKS108.lbx"


Wait 1

Print "Config"                                              ' printing will still work as only the receiver pin is disabled


'First we define that we use a graphic LCD
Config Graphlcd = 128 * 64sed , Dataport = Porta , Controlport = Portc , Ce = 0 , Ce2 = 1 , Cd = 4 , Rd = 3 , Reset = 2 , Enable = 5

'The dataport is the portname that is connected to the data lines of the LCD
'The controlport is the portname which pins are used to control the lcd
'CE =CS1  Chip select
'CE2=CS2  Chip select second chip
'CD=Data/instruction
'RD=Read
'RESET = reset
'ENABLE= Chip Enable


'Dim variables (y not used)
Dim X As Byte , Y As Byte



Print "Cls"
Cls

Wait 1

'specify the font we want to use
Setfont Font8x8


'You can use locate but the columns have a range from 1-128
'When you want to show somthing on the LCD, use the LDAT command
'LCDAT Y , COL, value
Lcdat 1 , 1 , "123"

'lcdat accepts an additional param for inversing the text
Lcdat 2 , 1 , "123" , 1                                     ' will inverse the text

'Now use a different font
'Setfont Font8x8
'since the 16*16 font uses 2 rows, show on row 3
'Lcdat 1 , 1 , "2345"
'Lcdat 2 , 56 , "2345656"
Wait 1
Line(0 , 0) -(127 , 64) , 1                                 'make line
Wait 2
Line(0 , 0) -(127 , 64) , 0                                 'remove line

For Y = 1 To 20
   Circle(30 , 30) , Y , 1
   Waitms 100
Next

Wait 1
Glcdcmd &H3E , 1 : Glcdcmd &H3E , 2                         ' both displays off
Wait 1
Glcdcmd &H3F , 1 : Glcdcmd &H3F , 2                         'both on
'GLCDCMD accepts an additional param to select the chip
'With multiple, GLCDCMD statements, it is best to specify the chip only the first time


Showpic 0 , 0 , Plaatje                                     'show a comnpressed picture
End                                                         'end program


'we need to include the font files
'Notice that this is a testfont with only numbers defined !
'$include "smallfont8x8.font"
$include "font8x8.font"
'$include "font16x16.font"


Plaatje:
'include the picture data
$bgf "mcs.bgf"