'-----------------------------------------------------------------------------------------
'name                     : lcd_i2c_demo.bas
'copyright                : (c) 1995-2013, MCS Electronics
'purpose                  : demo: lcd_i2c.lib and key_i2c.lib
'micro                    : Mega88
'suited for demo          : yes
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------
$RegFile = "m88def.dat"
$Crystal = 8000000

$Lib "Lcd_i2c.lib"                                          'My i2c driver for the LCD
$Lib "Key_i2c.lib"                                          'My i2c Keyboard driver
$external _key_scan                                         'Enable the routine

Config I2cdelay = 1

Const Pcf8574_lcd = &H40                                    'Defines the address of the I/O expander for LCD
Const Pcf8574_kbd = &H42                                    'Defines the address of the I/O expander for KBD
!rcall _Key_Init                                            'Call initialization routine (needed if int. driven)

Config Scl = PORTD.6                                        'Configure i2c SCL
Config Sda = PORTD.7                                        'Configure i2c SDA
Dim _lcd_e As Byte                                          'Needed to control 4 line LCD
Dim _bkey_scan As Byte                                      'Returned Key from _Key_scan

Enable Interrupts
Config Int0 = Falling                                       'Int signal from PCF8574_KBD is connected to INT0
'Enable Int0                                                 'Don't enable until it should be used (after LCD-test)
On INT0 _int0_label                                         'Procedure to call upon interrupt

'_lcd_e = 128 select E1, 64 select E2, 192 select both (for CLS or DefLCDChar etc.)
_lcd_e = 128                                                'Upper half of 4-line display is selected

'Here the LCD test program that is included in BASCOM follows
'and at the end there is a demo of the keyboard scan routine

Dim A As Byte
'Config Lcd = 40 * 4                                         'configure lcd screen
'other options are 16 * 4 and 20 * 4, 20 * 2 , 16 * 1a
'When you dont include this option 16 * 2 is assumed
'16 * 1a is intended for 16 character displays with split addresses over 2 lines

'$LCD = address will turn LCD into 8-bit databus mode
'       use this with uP with external RAM and/or ROM
'       because it aint need the port pins !
' Put your own strings here
Cls                                                         'clear the LCD display
Lcd "Hello world."                                          'display this at the top line
Wait 1
LowerLine                                                   'select the lower line
Wait 1
Lcd "Shift this."                                           'display this at the lower line
Wait 1
For A = 1 To 10
   Shiftlcd Right                                           'shift the text to the right
   WaitmS 250                                               'wait a moment
Next

For A = 1 To 10
   ShiftLcd Left                                            'shift the text to the left
   WaitmS 250                                               'wait a moment
Next


Locate 2 , 1                                                'set cursor position
Lcd "*"                                                     'display this
Wait 1                                                      'wait a moment

ShiftCursor Right                                           'shift the cursor
Lcd "@"                                                     'display this
Wait 1                                                      'wait a moment

Home Upper                                                  'select line 1 and return home
Lcd "Replaced."                                             'replace the text
Wait 1                                                      'wait a moment

Cursor Off ,NoBlink                                          'hide cursor
Wait 1                                                      'wait a moment
Cursor On ,Blink                                             'show cursor
Wait 1                                                      'wait a moment
Display Off                                                 'turn display off
Wait 1                                                      'wait a moment
Display On                                                  'turn display on
'-----------------Support for line 3 and 4 is controlled via _lcd_e
_lcd_e = 64
Lcd "Line 3"
LowerLine
Lcd "Line 4"
Wait 1
_lcd_e = 192                                                'select both halfs for defining characters
'Now lets build a special character
'the first number is the characternumber (0-7)
'The other numbers are the rowvalues
'Use the LCD tool to insert this line
DefLCDchar 2 , 32 , 10 , 32 , 14 , 17 , 17 , 17 , 14        ' replace ? with number (0-7)
DefLCDchar 0 , 32 , 4 , 32 , 14 , 18 , 18 , 18 , 13         ' replace ? with number (0-7)
DefLCDchar 1 , 32 , 10 , 32 , 14 , 18 , 18 , 18 , 13        ' replace ? with number (0-7)
_lcd_e = 128
Cls                                                         'select data RAM
Rem it is important that a CLS is following the deflcdchar statements because it will set the controller back in datamode
Lcd Chr(0) ; Chr(1)                                         'print the special character

'----------------- Now use an internal routine ------------
_temp1 = 2                                                  'value into ACC
!rCall _write_lcd                                           'put it on LCD



'Display pressed key value on LCD

Do

   Enable INT0                                                 'Now I could accept input from Keyboard
   If _bkey_scan > 0 Then                                      'As the keyboard is interupt driven I could do like this!
      Disable INT0                                             'Disable Int0 during LCD output due to the fact
      Locate 2 , 10                                            'that _Key_Scan also uses i2c (garbled output is likely)
      Lcd _bkey_scan ; " "
      Enable INT0
   End If

Loop
End

_int0_label:
   !rcall _Key_Scan
Return