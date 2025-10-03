'-----------------------------------------------------------------------------------------
'name                     : rs232bufferout1.bas
'copyright                : (c) 1995-2005, MCS Electronics
'purpose                  : how to use a serial output buffer on the second UART
'                           this sample will only work for chips with a seond UART like
'                           the M162 and M128
'micro                    : Mega162
'suited for demo          : yes
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------

$regfile = "m162def.dat"                                    ' specify the used micro
$crystal = 4000000                                          ' used crystal frequency
$baud = 9600                                                ' use baud rate
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 10                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space

Config Com1 = Dummy , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0
Config Com2 = Dummy , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0


'setup to use a serial output buffer
'and reserve 20 bytes for the buffer
Config Serialout1 = Buffered , Size = 20
Open "Com1:" For Binary As #1

'It is important since UDRE interrupt is used that you enable the interrupts
Enable Interrupts
Print #1 , "Hello world"
Do
 Wait 1
 'notice that using the UDRE interrupt will slown down execution of waiting loops like waitms
 Print #1 , "test"
Loop
End


Close #1