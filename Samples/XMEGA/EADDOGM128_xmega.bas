'-----------------------------------------------------------
'                     EADOGM128.BAS
'               (c) 1995-2011 MCS Electronics
' sample provided by MAK3
'-----------------------------------------------------------
' micro : ATXMEGA32A4

' demo  : SPI graphical display EADOGM128
' IMPORTANT : SPI only allows the WRITE mode. THis mean that setting pixels is not possible.
'             for this reason commands as PSET, LINE and CIRCLE are not supported.
'             best option would be to display pictures
' fonts and images are compatible to KS108


$RegFile = "xm128a1def.dat"
'$regfile = "xm32a4def.dat"
$crystal = 32000000                               '32MHz
$hwstack = 100
$swstack = 100
$framesize = 100


Config Osc = Enabled , 32mhzosc = Enabled
Config Sysclock = 32mhz                           '--> 32MHz


'Serial Interface to PC
Config Com1 = 57600 , Mode = Asynchroneous , Parity = None , Stopbits = 1 , Databits = 8

$lib "glcdeadogm128x6.lib"                                  ' specify the used lib

Config Vport0 = D
'the display was connected with these pins
Config Graphlcd = 128x64eadogm , Cs1 = PORT0.5 , A0 = PORT0.3 , Si = PORT0.1 , Sclk = PORT0.2 , Rst = PORT0.4
'the best option is to control the reset line of the LCD with the micro so you can reset it controlled at startup


Dim B As Byte , J As Byte
Dim K As Byte , X As Word , Y As Word

Print "cls"
Cls

'specify the font we want to use
Setfont Font8x8tt


'You can use locate but the columns have a range from 1-128
'When you want to show somthing on the LCD, use the LDAT command
'LCDAT Y , COL, value
Lcdat 1 , 1 , "11111111"
Lcdat 2 , 1 , "88888888"
Lcdat 3 , 1 , "MCS Electronics" , 1
Wait 1

End                                               'end program




'include used fonts
$include "font8x8TT.font"
