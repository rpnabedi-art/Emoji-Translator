'-----------------------------------------------------------
'                     EADOGM128.BAS
'               (c) 1995-2008 MCS Electronics
' micro : mega168
' demo  : SPI graphical display EADOGM128
' IMPORTANT : SPI only allows the WRITE mode. THis mean that setting pixels is not possible.
'             for this reason commands as PSET, LINE and CIRCLE are not supported.
'             best option would be to display pictures
' fonts and images are compatible to KS108
'-----------------------------------------------------------
$regfile = "m168def.dat"                                    ' ATmega168
$crystal = 8000000
$baud = 19200
$lib "glcdeadogm128x6.lbx"                                  ' specify the used lib
$hwstack = 40
$swstack = 40
$framesize = 40



'the display was connected with these pins
Config Graphlcd = 128 * 64eadogm , Cs1 = Portd.4 , A0 = Portd.7 , Si = Portb.3 , Sclk = Portb.5 , Rst = Portd.5
'the best option is to control the reset line of the LCD with the micro so you can reset it controlled at startup

Config Adc = Single , Prescaler = Auto , Reference = Avcc

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
Waitms 3000

Dim I As Word
For I = 110 To 333
  Lcdat 1 , 1 , I
  Waitms 500
  Cls 1 , 1 , 24 , 255                                      'clear inverse
  Waitms 500
Next

Waitms 3000


Setfont My12_16
Cls
Lcdat 1 , 1 , "112345678"                                   'a bigger font
Waitms 3000

Setfont Font8x8tt

'Showpic 0 , 0 , Plaatje
Waitms 3000
Do
  Gosub Touch                                               'optional touch screen
Loop

End

'portc.0-portc.3 pin 1-4
Touch:
   Start Adc
   Waitms 200
   Config Portc.0 = Output                                  'Bottom
   Config Portc.2 = Output                                  'Top
   Set Portc.0                                              'High
   Reset Portc.2                                            'Low
   Config Pinc.1 = Input                                    'left as input
   Config Pinc.3 = Input                                    'right as input
   Waitms 80
   Y = Getadc(3)
   Y = Y - 365
   If Y > 640 Then Y = 0
   Config Portc.1 = Output                                  'Left
   Config Portc.3 = Output                                  'Right
   Set Portc.3
   Reset Portc.1
   Config Pinc.0 = Input
   Config Pinc.2 = Input
   Waitms 80
   X = Getadc(0)
   X = X - 196
   If X > 800 Then X = 0
   Lcdat 1 , 1 , "X : " ; X
   Lcdat 1 , 74 , "Y : " ; Y
Return



Plaatje:
'include the picture data
'$bgf "ks108.bgf"

'include used fonts
$include "font8x8TT.font"
$include "my12_16.font"