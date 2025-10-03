'-------------------------------------------------------------------------------
'                        (c) 1995-2014 MCS Electronics
'                        attiny1634.bas chip test
'
'-------------------------------------------------------------------------------
$regfile = "attiny828.dat"
$crystal = 8000000
$baud = 19200
$hwstack = 32
$framesize = 24
$swstack = 16

Config Com1 = 19200 , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0

Dim B As Byte , w as word

Print "test"

Config Portb = Output
Do
  Incr B
  Print "toggle " ; B

  Waitms 1000
  Toggle Portb

Loop