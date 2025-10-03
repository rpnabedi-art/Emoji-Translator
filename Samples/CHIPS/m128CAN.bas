'-----------------------------------------------------------------------------------------
'name                     : m128can.bas
'copyright                : (c) 1995-2005, MCS Electronics
'purpose                  : MegaCAN (AT90CAN128) test file
'micro                    : AT90CAN128
'suited for demo          : yes
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------

$regfile = "m128can.dat"                                    ' specify the used micro
$crystal = 1000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$baud1 = 19200
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 10                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space

Config Clock = Soft , Gosub = Sectic
Enable Interrupts

Config Com1 = Dummy , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0
Config Com2 = Dummy , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0
Open "COM2:" For Binary As #1


Osccal = 75

Do
  Print "Hello world : " ; Osccal
  Print #1 , "Hello MegaCAN " ; Time$
  Waitms 250
Loop


Sectic:
  Print #1 , "$- " ; Time$
Return