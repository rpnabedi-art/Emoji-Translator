$regfile = "m128def.dat"

$crystal = 8000000
$baud = 19200
$hwstack = 40
$swstack = 40
$framesize = 40


Enable Interrupts

'[now init the clock]
Config Date = Mdy , Separator = /                          ' ANSI-Format

Config Clock = Soft                                         'this is how simple it is
'The above statement will bind in an ISR so you can not use the TIMER anymore!

'assign the date to the reserved date$
'The format is MM/DD/YY
Date$ = "11/11/05"

'assign the time, format in hh:mm:ss military format(24 hours)
'You may not use 1:2:3 !! adding support for this would mean overhead
'But of course you can alter the library routines used

Time$ = "23:59:50"
Do
    Waitms 500
    Print Date$ ; Spc(3) ; Time$
Loop