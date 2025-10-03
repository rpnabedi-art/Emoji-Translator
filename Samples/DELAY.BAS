'-----------------------------------------------------------------------------------------
'name                     : delay.bas
'copyright                : (c) 1995-2013, MCS Electronics
'purpose                  : demo: DELAY, WAIT, WAITMS
'micro                    : Mega48
'suited for demo          : yes
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------

$regfile = "m48def.dat"                                     ' specify the used micro
$crystal = 8000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 10                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space

Ddrb = &HFF                                                 'port B as output
Portb = 255
Print "Starting"
Delay                                                       'lets wait for a very short time
Print "Now wait for 3 seconds"
Portb = 0
Wait 3
Print "Ready"
Waitms 10                                                   'wait 10 milliseconds
Portb = 255

'wait for micro seconds
Waitus 10
End