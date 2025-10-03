'------------------------------------------------------------
'                      MEGACLOCK.BAS
'                  (c) 2000-2014 MCS Electronics
'------------------------------------------------------------
'This example shows the new TIME$ and DATE$ reserved variables
'With the 8535 and timer2 or the Mega103 and TIMER0 you can
'easily implement a clock by attaching a 32768 Hz xtal to the timer
'And of course some BASCOM code

$regfile = "m103def.dat"
$hwstack=64
$swstack=64
$FrameSize=64

'This example is written for the STK300 with M103
Enable Interrupts

'[configure LCD]
$lcd = &HC000                                               'address for E and RS
$lcdrs = &H8000                                             'address for only E
Config Lcd = 20 * 4                                         'nice display from bg micro
Config Lcdbus = 4                                           'we run it in bus mode and I hooked up only db4-db7
Config Lcdmode = Bus                                        'tell about the bus mode

'[now init the clock]
Config Date = Mdy , Separator = /                          ' ANSI-Format

Config Clock = Soft                                         'this is how simple it is
'The above statement will bind in an ISR so you can not use the TIMER anymore!
'For the M103 in this case it means that TIMER0 can not be used by the user anymore

'assign the date to the reserved date$
'The format is MM/DD/YY
Date$ = "11/11/00"

'assign the time, format in hh:mm:ss military format(24 hours)
'You may not use 1:2:3 !! adding support for this would mean overhead
'But of course you can alter the library routines used

Time$ = "02:20:00"

'---------------------------------------------------

'clear the LCD display
Cls

Do
  Home                                                      'cursor home
  Lcd Date$ ; "  " ; Time$                                  'show the date and time
Loop

'The clock routine does use the following internal variables:
'_day , _month, _year , _sec, _hour, _min
'These are all bytes. You can assign or use them directly
_day = 1
'For the _year variable only the year is stored, not the century
End