'-------------------------------------------------------------------------------
'                ARDUINO-Duemilanove-168.BAS
'              (c) 1995-2011, MCS Electronics
'  This is a sample file for the Mega168 based ARDUINO board
'  Select Programmer 'ARDUINO' , 19200 baud and the proper COM port
'-------------------------------------------------------------------------------
$regfile= "m168def.dat"    ' used micro
$crystal=16000000          ' used xtal
$baud=19200                ' baud rate we want
$hwstack = 40
$swstack = 40
$framesize = 40

config clockdiv=1          ' either use this or change the divider fuse byte
'-------------------------------------------------------------------------------

config portb=output        ' make portb an output
do
  toggle portb             ' toggle level
  waitms 1000              ' wait 1 sec
  print "Duemilanove"      ' test serial com
loop

