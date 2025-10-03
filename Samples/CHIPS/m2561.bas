'-----------------------------------------------------------------------------------------
'name                     :
'copyright                : (c) 1995-2007, MCS Electronics
'purpose                  : test for M2561 support
'micro                    : Mega2561
'suited for demo          : yes
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------

$regfile = "m2561def.dat"                                   ' specify the used micro
$crystal = 8000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$baud1 = 19200
$hwstack = 40                                               ' default use 32 for the hardware stack
$swstack = 40                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space




'The M128 has an extended UART.
'when CONFIG COMx is not used, the default N,8,1 will be used
Config Com1 = Dummy , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0
Config Com2 = Dummy , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0


'try the second hardware UART
Open "com2:" For Binary As #1

Print "Hello"
Dim B As Byte
Dim Tel As Word
Do
  Incr Tel
  Print "test" ; Tel
   Input "test serial port 0" , B
   Print B
  Print #1 , "test serial port 2"
Loop

Close #1


End