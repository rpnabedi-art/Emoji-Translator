'-----------------------------------------------------------------------------------------
'name                     : m128103.bas
'copyright                : (c) 1995-2005, MCS Electronics
'purpose                  : test for M128 support in M103 mode
'micro                    : Mega128
'suited for demo          : yes
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------

$regfile = "m128103.dat"                                    ' specify the used micro
$crystal = 4000000                                          ' used crystal frequency
$baud = 9600                                                ' use baud rate
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 10                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space

'By default the M128 has the M103 compatibility fuse set.
'It also runs on a 1 MHz internal oscillator by default
'Set the internal osc to 4 MHz for this example DCBA=1100

'In M103 mode you may NOT use CONFIG COM since only the normal mode is availble
'Config Com1 = Dummy , Synchrone = 0 , Parity = Even , Stopbits = 2 , Databits = 8 , Clockpol = 0
Print "Hello"
Do
   Print "test"
   Wait 1
Loop