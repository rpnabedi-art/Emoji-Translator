'-----------------------------------------------------------------
'                     (c) 2001-2007 MCS Electronics
'                 T6963C graphic display support demo
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

$crystal = 8000000
$regfile = "m32def.dat"
$hwstack = 40
$swstack = 40
$framesize = 40


'First we define that we use a graphic LCD

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

Wait 2

Cls Text
' draw a line using PSET X,Y, ON/OFF
' PSET on.off param is 0 to clear a pixel and any other value to turn it on
For X = 0 To 140
   Pset X , 20 , 255                                        ' set the pixel
Next

Wait 2


'Now it is time to show a picture
'SHOWPIC X,Y,label
'The label points to a label that holds the image data
Showpic 0 , 0 , Plaatje

Wait 2
Cls Text                                                    ' clear the text
End



'This label holds the mage data
Plaatje:
'$BGF will put the bitmap into the program at this location
$bgf "mcs.bgf"

'You could insert other picture data here