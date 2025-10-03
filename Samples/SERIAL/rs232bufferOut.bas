'-----------------------------------------------------------------------------------------
'name                     : rs232bufferout.bas
'copyright                : (c) 1995-2005, MCS Electronics
'purpose                  : demonstrates how to use a serial output buffer
'micro                    : Mega48
'suited for demo          : yes
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------

$regfile = "m48def.dat"                                     ' specify the used micro
$crystal = 8000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 40                                               ' default use 32 for the hardware stack
$swstack = 40                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space

Config Com1 = Dummy , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0


'setup to use a serial output buffer
'and reserve 20 bytes for the buffer
Config Serialout = Buffered , Size = 20

'It is important since UDRE interrupt is used that you enable the interrupts
Enable Interrupts
Print "Hello world"
Print "test1"
Do
 Wait 1
 'notice that using the UDRE interrupt will slown down execution of waiting loops like waitms
 Print "test"
Loop
End