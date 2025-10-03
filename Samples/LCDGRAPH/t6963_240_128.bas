'-----------------------------------------------------------------------------------------
'name                     : t6963_240_128.bas
'copyright                : (c) 1995-2005, MCS Electronics
'purpose                  : T6963C graphic display support demo 240 * 128
'micro                    : Mega8535
'suited for demo          : yes
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------

$regfile = "m8535.dat"                                      ' specify the used micro
$crystal = 8000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 10                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space

'-----------------------------------------------------------------
'                     (c) 2001-2003 MCS Electronics
'                 T6963C graphic display support demo 240 * 128
'-----------------------------------------------------------------

'The connections of the LCD used in this demo
'LCD pin                  connected to
' 1        GND            GND
 '2        GND            GND
 '3        +5V            +5V
 '4        -9V            -9V potmeter
 '5        /WR            PORTC.0
 '6        /RD            PORTC.1
 '7        /CE            PORTC.2
 '8        C/D            PORTC.3
 '9        NC             not conneted
 '10       RESET          PORTC.4
 '11-18    D0-D7           PA
 '19       FS             PORTC.5
 '20       NC             not connected

'First we define that we use a graphic LCD
' Only 240*64 supported yet
Config Graphlcd = 240 * 128 , Dataport = Porta , Controlport = Portc , Ce = 2 , Cd = 3 , Wr = 0 , Rd = 1 , Reset = 4 , Fs = 5 , Mode = 8
'The dataport is the portname that is connected to the data lines of the LCD
'The controlport is the portname which pins are used to control the lcd
'CE, CD etc. are the pin number of the CONTROLPORT.
' For example CE =2 because it is connected to PORTC.2
'mode 8 gives 240 / 8 = 30 columns , mode=6 gives 240 / 6 = 40 columns

'Dim variables (y not used)
Dim X As Byte , Y As Byte


'Clear the screen will both clear text and graph display
Cls
'Other options are :
' CLS TEXT   to clear only the text display
' CLS GRAPH  to clear only the graphical part

Cursor Off

Wait 1
'locate works like the normal LCD locate statement
' LOCATE LINE,COLUMN LINE can be 1-8 and column 0-30


Locate 1 , 1

'Show some text
Lcd "MCS Electronics"
'And some othe text on line 2
Locate 2 , 1 : Lcd "T6963c support"
Locate 3 , 1 : Lcd "1234567890123456789012345678901234567890"
Locate 16 , 1 : Lcd "write this to the lower line"

Wait 2

Cls Text


'use the new LINE statement to create a box
'LINE(X0,Y0) - (X1,Y1), on/off
Line(0 , 0) -(239 , 127) , 255                              ' diagonal line
Line(0 , 127) -(239 , 0) , 255                              ' diagonal line
Line(0 , 0) -(240 , 0) , 255                                ' horizontal upper line
Line(0 , 127) -(239 , 127) , 255                            'horizontal lower line
Line(0 , 0) -(0 , 127) , 255                                ' vertical left line
Line(239 , 0) -(239 , 127) , 255                            ' vertical right line


Wait 2
' draw a line using PSET X,Y, ON/OFF
' PSET on.off param is 0 to clear a pixel and any other value to turn it on
For X = 0 To 140
   Pset X , 20 , 255                                        ' set the pixel
Next

For X = 0 To 140
   Pset X , 127 , 255                                       ' set the pixel
Next

Wait 2

'circle time
'circle(X,Y), radius, color
'X,y is the middle of the circle,color must be 255 to show a pixel and 0 to clear a pixel
For X = 1 To 10
  Circle(20 , 20) , X , 255                                 ' show circle
  Wait 1
  Circle(20 , 20) , X , 0                                   'remove circle
  Wait 1
Next

Wait 2

For X = 1 To 10
  Circle(20 , 20) , X , 255                                 ' show circle
  Waitms 200
Next
Wait 2
'Now it is time to show a picture
'SHOWPIC X,Y,label
'The label points to a label that holds the image data
Test:
Showpic 0 , 0 , Plaatje
Showpic 0 , 64 , Plaatje                                    ' show 2 since we have a big display
Wait 2
Cls Text                                                    ' clear the text
End



'This label holds the mage data
Plaatje:
'$BGF will put the bitmap into the program at this location
$bgf "mcs.bgf"

'You could insert other picture data here