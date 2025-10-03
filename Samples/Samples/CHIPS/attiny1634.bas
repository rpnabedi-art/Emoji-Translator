'-------------------------------------------------------------------------------
'                        (c) 1995-2012 MCS Electronics
'                        attiny1634.bas chip test
'
'-------------------------------------------------------------------------------
$regfile = "attiny1634.dat"
$crystal = 8000000
$baud = 19200
$hwstack = 32
$framesize = 24
$swstack = 16


Config Com1 = 19200 , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0
Config Com2 = 19200 , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0
Open "com1:" For Binary As #1
Open "com2:" For Binary As #2

Dim B As Byte

Print #1 , "test"
Print #2 , "test"

Config Portb = Output
Do
  Incr B
  Print "toggle " ; B
  Print #2 , "toggle " ; B

  Waitms 1000
  Toggle Portb
Loop

