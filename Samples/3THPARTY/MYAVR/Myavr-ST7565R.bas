'-----------------------------------------------------------------
'                  (c) 1995-2013, MCS
'                   MyAVR-ST7565R.bas
'  This sample demonstrates the Graphical LCD of the MyAVR MK3
'  The demo also light the LEDS at port L and uses the 7 segment display
'-----------------------------------------------------------------
$regfile = "m2560def.dat"
$crystal = 16000000
$hwstack = 64
$swstack = 40
$framesize = 40

$lib "glcdST7565r.lbx"                                  ' specify the used lib
$lib "glcd.lbx"                                        ' and this one of you use circle/line etc

'the display is connected with these pins
Config Graphlcd = 128x64eadogm ,dataport=portc,  Cs1 = Porta.0 , A0 = Porta.2 , rst= Porta.1 , wr = Porta.3 , Rd = Porta.4,c86=porta.6,pm=porta.7

cls               ' clear the display

Setfont Font8x8tt ' select font

dim y as byte

'You can use locate but the columns have a range from 1-128
'When you want to show somthing on the LCD, use the LDAT command
'LCDAT Y , COL, value
Lcdat 1 , 1 , "     MyAVR"
Lcdat 2 , 1 , "ABCDEFGHIJKL1234"
Lcdat 3 , 1 , "MCS Electronics" , 1    ' inverse
Lcdat 4 , 1 , "MCS Electronics"

Waitms 3000
Setfont My12_16 ' use a bigger font

Cls
Lcdat 1 , 1 , "MyAVR"                                       'a bigger font
Waitms 3000                                                 ' wait

Line(0 , 0) -(127 , 64) , 1                                 'make line
Waitms 2000  'wait 2 secs
Line(0 , 0) -(127 , 64) , 0                                 'remove line by inverting the color

For Y = 1 To 20
   Circle(30 , 30) , Y , 1                                  ' growing circle
   Waitms 100
Next

config portl=output
y=0
do
   toggle portl
   waitms 1000
   incr  Y
loop until y=10

config portb=output
do
    for y=0 to 18
      portb=lookup(y,7segdata)  ' lookup value and write to port
      waitms 500
    next
loop


End
'  a
'--- -
'|f   |b
'--g--
'|e   |c
'-----
'  d
'a-portb.0  - 1
'b-portb.1  - 2
'c-portb.2  - 4
'd-portb.3  - 8
'e-portb.4  -16
'f-portb.5  -32
'g portb.6 -64
'h-portb.7
7segdata:
data &B00111111,&b00000110, &b01011011, &b01001111, &b01100110, &b01101101, &b01111101, &b00000111, &b01111111, &b01101111, &b01110111, &b01111100
data &b00111001,&b01011110, &b01111001, &b01110001, &b01000000, &b00000000, &b01001001


$include "font8x8TT.font"
$include "my12_16.font"