
'-----------------------------------------------------------------------------------------
'name                     : GLCD 24C256.bas
'copyright                : (c) 1995-2013, MCS Electronics
'purpose                  : Graphic display with external eeprom
'micro                    : Mega8535
'suited for demo          : no
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------

$regfile = "m8535.dat"                                      ' specify the used micro
$crystal = 8000000                                          ' used crystal frequency
$baud = 9600                                                ' use baud rate
$hwstack = 64                                               ' default use 32 for the hardware stack
$swstack = 32                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space

'-----------------------------------------------------------------------------------------
'define EEPROM content
$eeprom

'This label holds the mage data
Pic1:
'$BGF will put the bitmap into the eeprom
$bgf "mcs.bgf"

$data
'-----------------------------------------------------------------------------------------

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
 '5        /WR            PORTC.6
 '6        /RD            PORTC.7
 '7        /CE            PORTC.2
 '8        C/D            PORTC.3
 '9        NC             not conneted
 '10       RESET          PORTC.4
 '11-18    D0-D7           PA
 '19       FS             PORTC.5
 '20       NC             not connected

'First we define that we use a graphic LCD
' Only 240*64 supported yet
Config Graphlcd = 240 * 128 , Dataport = Porta , Controlport = Portc , Ce = 2 , Cd = 3 , Wr = 6 , Rd = 7 , Reset = 4 , Fs = 5 , Mode = 8
'The dataport is the portname that is connected to the data lines of the LCD
'The controlport is the portname which pins are used to control the lcd
'CE, CD etc. are the pin number of the CONTROLPORT.
' For example CE =2 because it is connected to PORTC.2
'mode 8 gives 240 / 8 = 30 columns , mode=6 gives 240 / 6 = 40 columns


$lib "i2c_twi.lbx"                                          ' we do not use software emulated I2C but the TWI

Config Scl = Portc.0                                        ' we need to provide the SCL pin name
Config Sda = Portc.1                                        ' we need to provide the SDA pin name

I2cinit                                                     ' we need to set the pins in the proper state

Config Twi = 100000                                         ' wanted clock frequency

' External EEPROM Config
$eepromsize = &H8000                                        ' 32kB for FM24C256
$lib "fm24c64_256.lib"



'Dim variables (y not used)
Dim X As Byte , Y As Byte


'Clear the screen will both clear text and graph display
Cls
'Other options are :
' CLS TEXT   to clear only the text display
' CLS GRAPH  to clear only the graphical part

Cursor Off

Wait 1



Test:
Showpice 0 , 0 , Pic1
Showpice 0 , 64 , Pic1                                      ' show 2 since we have a big display
Wait 2
                                                   ' clear the text
End

'-------------------------------------------------------------------------------

