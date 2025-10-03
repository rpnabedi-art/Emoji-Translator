'-----------------------------------------------------------------------------------------
'name                     :
'copyright                : (c) 1995-2005, MCS Electronics
'purpose                  : test for M165 support
'micro                    : Mega165
'suited for demo          : yes
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------

$regfile = "m165def.dat"                                    ' specify the used micro
$crystal = 8000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 32                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space




'The M154 has an extended UART.
'when CONFIG COMx is not used, the default N,8,1 will be used
Config Com1 = Dummy , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0

Print "Hello"
Dim B As Byte
Do
   Input "test serial port 0" , B
   Print B
Loop



End