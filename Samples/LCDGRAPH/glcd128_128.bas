'-------------------------------------------------------------------------------
'                 GLCD128_128.BAS
'  This is a USER contributed application
'  It demonstrates support for 4 KS108 chips in  glcd4_0108.lbx
'  This library was made by Nard Awater (aka Plons)
'  The CE pins on this display are active high!
'-------------------------------------------------------------------------------


'Demo program 128x128 LCD display with 4 KS0108-controllers

$crystal = 16000000                                         'tested with 8 MHz as well
$regfile = "m32def.dat"

$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 10                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space


$lib "glcd4_0108.lbx"
'This display is supported by Bascom-version 1.11.9.4 and higher; use the following Config-command
Config Graphlcd = 128x128sed , Dataport = Portc , Controlport = Portb , Ce = 3 , Ce2 = 2 , Ce3 = 1 , Ce4 = 0 , Cd = 7 , Rd = 6 , Reset = 5 , Enable = 4



Dim X As Byte , Y As Byte


Cls

'specify the font we want to use
Setfont My6_8

'Show that text can be written in all four sections of the display
Lcdat 3 , 6 , "cs UL"                                       'UL=UpperLeft
Lcdat 3 , 70 , "cs UR"
Lcdat 12 , 6 , "cs LL"                                      'LL=LowerLeft
Lcdat 12 , 70 , "cs LR"

'line command
Wait 1
Line(0 , 127) -(127 , 0) , 1                                'make line
Wait 2
Line(31 , 96) -(96 , 31) , 0                                'remove middle section of line
Wait 1

'pixel command
For X = 127 To 1 Step -1
   Pset X , X , 255                                         ' set the pixel
   Waitms 10
Next X

'circle command: make a growing dot ... period ;-)
For Y = 1 To 40
   Circle(64 , 64) , Y , 1
   Waitms 25
Next


'All commands that are available for graphical displays work fine with "glcd4_0108.lib"
'except Glcdcmd and Glcddata: these work only for the two upper displays.
'This is not due to the new library, but has to do with the way the compiler selects
'the chips the command is for.

Wait 1
Glcdcmd &H3E , 1                                            'display UpperLeft off
Wait 1
Glcdcmd &H3E , 2                                            'display UpperRight off
Wait 1
Glcdcmd &H3F , 1                                            'display UpperLeft on
Wait 1
Glcdcmd &H3F , 2                                            'display UpperRight on
Wait 3

Cls

Lcdat 13 , 8 , "glcd4_0108.lib by"
'now choose large font
Setfont My12_16
Lcdat 15 , 24 , "Plons"
'show a compressed picture
Showpic 0 , 24 , Picture_bascom

End                                                         'end program


'we need to include the font files that are used ....
$include "My12_16.font"
$include "My6_8.font"


'... and the picture data
Picture_bascom:
$bgf "KS108.bgf"