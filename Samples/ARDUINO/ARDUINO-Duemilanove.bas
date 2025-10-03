'-------------------------------------------------------------------------------
'                ARDUINO-Duemilanove.BAS
'           Also tested with ARDUINO NANO V3.0
'              (c) 1995-2014, MCS Electronics
'  This is a sample file for the Mega328P based ARDUINO board
'  Select Programmer 'ARDUINO' , 57600 baud and the proper COM port
'-------------------------------------------------------------------------------
$regfile= "m328pdef.dat"   ' used micro
$crystal=16000000          ' used xtal
$baud=19200                ' baud rate we want
$hwstack = 40
$swstack = 40
$framesize = 40

config clockdiv=1          ' either use this or change the divider fuse byte
'-------------------------------------------------------------------------------

dim w as word,b as byte
dim s as string * 6, ar(6) as byte

config portb=output        ' make portb an output
do
  toggle portb             ' toggle level
  waitms 1000              ' wait 1 sec
  print "Duemilanove"      ' test serial com

  w=w+1 : s=str(w)         ' convert w to a string
  str2digits s,ar(1)       ' convert string into an array with binary numbers
loop

