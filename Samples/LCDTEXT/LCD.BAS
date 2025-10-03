'-----------------------------------------------------------------------------------------
'name                     : lcd.bas
'copyright                : (c) 1995-2008, MCS Electronics
'purpose                  : demo: LCD, CLS, LOWERLINE, SHIFTLCD, SHIFTCURSOR, HOME
'                           CURSOR, DISPLAY
'micro                    : Mega8515
'suited for demo          : yes
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------

$regfile = "m8515.dat"                                      ' specify the used micro
$crystal = 4000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 10                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space


$sim
'REMOVE the above command for the real program !!
'$sim is used for faster simulation


'note : tested in PIN mode with 4-bit

'Config Lcdpin = Pin , Db4 = Portb.1 , Db5 = Portb.2 , Db6 = Portb.3 , Db7 = Portb.4 , E = Portb.5 , Rs = Portb.6
Config Lcdpin = Pin , Db4 = Porta.4 , Db5 = Porta.5 , Db6 = Porta.6 , Db7 = Porta.7 , E = Portc.7 , Rs = Portc.6
'These settings are for the STK200 in PIN mode
'Connect only DB4 to DB7 of the LCD to the LCD connector of the STK D4-D7
'Connect the E-line of the LCD to A15 (PORTC.7) and NOT to the E line of the LCD connector
'Connect the RS, V0, GND and =5V of the LCD to the STK LCD connector

Rem with the config lcdpin statement you can override the compiler settings


Dim A As Byte
Config Lcd = 16 * 2                                         'configure lcd screen


'other options are 16 * 4 and 20 * 4, 20 * 2 , 16 * 1a
'When you dont include this option 16 * 2 is assumed
'16 * 1a is intended for 16 character displays with split addresses over 2 lines

'$LCD = address will turn LCD into 8-bit databus mode
'       use this with uP with external RAM and/or ROM
'       because it aint need the port pins !

Cls                                                         'clear the LCD display
Lcd "Hello world."                                          'display this at the top line
Wait 1
Lowerline                                                   'select the lower line
Wait 1
Lcd "Shift this."                                           'display this at the lower line
Wait 1
For A = 1 To 10
   Shiftlcd Right                                           'shift the text to the right
   Wait 1                                                   'wait a moment
Next

For A = 1 To 10
   Shiftlcd Left                                            'shift the text to the left
   Wait 1                                                   'wait a moment
Next

Locate 2 , 1                                                'set cursor position
Lcd "*"                                                     'display this
Wait 1                                                      'wait a moment

Shiftcursor Right                                           'shift the cursor
Lcd "@"                                                     'display this
Wait 1                                                      'wait a moment

Home Upper                                                  'select line 1 and return home
Lcd "Replaced."                                             'replace the text
Wait 1                                                      'wait a moment

Cursor Off Noblink                                          'hide cursor
Wait 1                                                      'wait a moment
Cursor On Blink                                             'show cursor
Wait 1                                                      'wait a moment
Display Off                                                 'turn display off
Wait 1                                                      'wait a moment
Display On                                                  'turn display on
'-----------------NEW support for 4-line LCD------
Thirdline
Lcd "Line 3"
Fourthline
Lcd "Line 4"
Home Third                                                  'goto home on line three
Home Fourth
Home F                                                      'first letteer also works
Locate 4 , 1 : Lcd "Line 4"
Wait 1

'Now lets build a special character
'the first number is the characternumber (0-7)
'The other numbers are the rowvalues
'Use the LCD tool to insert this line

Deflcdchar 1 , 225 , 227 , 226 , 226 , 226 , 242 , 234 , 228       ' replace ? with number (0-7)
Deflcdchar 0 , 240 , 224 , 224 , 255 , 254 , 252 , 248 , 240       ' replace ? with number (0-7)
Cls                                                         'select data RAM
Rem it is important that a CLS is following the deflcdchar statements because it will set the controller back in datamode
Lcd Chr(0) ; Chr(1)                                         'print the special character

'----------------- Now use an internal routine ------------
_temp1 = 1                                                  'value into ACC
!rCall _write_lcd                                           'put it on LCD

'or use this instead
Lcddata 65                                                  'data
Lcdcmd 1                                                    ' control

End