'--------------------------------------------------------------
'                 (c) 1999-2005 MCS Electronics
'--------------------------------------------------------------
'  file: LCD.BAS
'  demo: LCD, CLS, LOWERLINE, SHIFTLCD, SHIFTCURSOR, HOME
'        CURSOR, DISPLAY
'--------------------------------------------------------------

'note : tested in bus mode with 4-bit on the STK200
'LCD   -   STK200
'D4         D4
'D5         D5
'D6         D6
'D7         D7
'WR         WR
'E          E
'RS         RS
'+5V        +5V
'GND        GND
'V0         V0
'   D0-D3 are not connected since 4 bit bus mode is used!


'Config Lcdpin = Pin , Db4 = Portb.1 , Db5 = Portb.2 , Db6 = Portb.3 , Db7 = Portb.4 , E = Portb.5 , Rs = Portb.6
Rem with the config lcdpin statement you can override the compiler settings
$regfile = "8515def.dat"
$hwstack=64
$swstack=64
$FrameSize=64

Dim A As Byte
Config Lcd = 20 * 4                                           'configure lcd screen
'other options are 16 * 2 , 16 * 4 and 20 * 4, 20 * 2 , 16 * 1a
'When you dont include this option 16 * 2 is assumed
'16 * 1a is intended for 16 character displays with split addresses over 2 lines

'$LCD = address will turn LCD into 8-bit databus mode
'       use this with uP with external RAM and/or ROM
'       because it aint need the port pins !

Cls                                                           'clear the LCD display
Lcd "Hello world."                                            'display this at the top line
Wait 1
Lowerline                                                     'select the lower line
Wait 1
Lcd "Shift this."                                             'display this at the lower line
Wait 1
For A = 1 To 10
   Shiftlcd Right                                             'shift the text to the right
   Wait 1                                                     'wait a moment
Next

For A = 1 To 10
   Shiftlcd Left                                              'shift the text to the left
   Wait 1                                                     'wait a moment
Next

Locate 2 , 1                                                  'set cursor position
Lcd "*"                                                       'display this
Wait 1                                                        'wait a moment

Shiftcursor Right                                             'shift the cursor
Lcd "@"                                                       'display this
Wait 1                                                        'wait a moment

Home Upper                                                    'select line 1 and return home
Lcd "Replaced."                                               'replace the text
Wait 1                                                        'wait a moment

Cursor Off Noblink                                            'hide cursor
Wait 1                                                        'wait a moment
Cursor On Blink                                               'show cursor
Wait 1                                                        'wait a moment
Display Off                                                   'turn display off
Wait 1                                                        'wait a moment
Display On                                                    'turn display on
'-----------------NEW support for 4-line LCD------
Thirdline
Lcd "Line 3"
Fourthline
Lcd "Line 4"
Home Third                                                    'goto home on line three
Home Fourth
Home F                                                        'first letteer also works
Locate 4 , 1 : Lcd "Line 4"
Wait 1

'Now lets build a special character
'the first number is the characternumber (0-7)
'The other numbers are the rowvalues
'Use the LCD tool to insert this line

Deflcdchar 1 , 225 , 227 , 226 , 226 , 226 , 242 , 234 , 228       ' replace ? with number (0-7)
Deflcdchar 0 , 240 , 224 , 224 , 255 , 254 , 252 , 248 , 240       ' replace ? with number (0-7)
Cls                                                           'select data RAM
Rem it is important that a CLS is following the deflcdchar statements because it will set the controller back in datamode
Lcd Chr(0) ; Chr(1)                                           'print the special character

'----------------- Now use an internal routine ------------
_temp1 = 1                                                    'value into ACC
!rCall _write_lcd                                             'put it on LCD
End