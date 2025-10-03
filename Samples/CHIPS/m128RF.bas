'-----------------------------------------------------------------------------------------
'name                     :
'copyright                : (c) 1995-2005, MCS Electronics
'purpose                  : test for M128RF
'micro                    : Mega128RFA1
'suited for demo          : yes
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------

$regfile = "m128rfa1.dat"                                   ' specify the used micro
$crystal = 8000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$baud1 = 19200
$hwstack = 40                                               ' default use 32 for the hardware stack
$swstack = 32                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space

'The M128 has an extended UART.
'when CONFIG COMx is not used, the default N,8,1 will be used
Config Com1 = 19200 , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0
Config Com2 = 19200 , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0

Config Clock = Soft
'try the second hardware UART
Open "com2:" For Binary As #1

Print "RF128"
Do
'   Print "UART0"
   Print #1 , "UART1"
  Waitms 500
Loop



End