'-----------------------------------------------------------------------------------------
'name                     :
'copyright                : (c) 1995-2014, MCS Electronics
'purpose                  : test for M128 support in M128 mode
'micro                    : Mega128
'suited for demo          : yes
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------

$regfile = "m128def.dat"                                    ' specify the used micro
$crystal = 8000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$baud1 = 19200
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 10                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space



'By default the M128 has the M103 compatibility fuse set. Set the fuse to M128
'It also runs on a 1 MHz internal oscillator by default
'Set the internal osc to 4 MHz for this example DCBA=1100

'use the m128def.dat file when you wanto to use the M128 in M128 mode
'The M128 mode will use memory from $60-$9F for the extended registers

'Since some ports are located in extended registers it means that some statements
'will not work on these ports. Especially statements that will set or reset a bit
'in a register. You can set any bit yourself with the PORTF.1=1 statement for example
'But the I2C routines use ASM instructions to set the bit of a port. These ASM instructions may
'only be used on port registers. PORTF and PORTG will not work with I2C.


'The M128 has an extended UART.
'when CONFIG COMx is not used, the default N,8,1 will be used
Config Com1 = Dummy , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0
Config Com2 = Dummy , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0

'try the second hardware UART
Open "com2:" For Binary As #1

'try to access an extended register
Config Portf = Output
'Config Portf = Input

Print "Hello"
Dim B As Byte
Do
   Print "UART0"
   Print #1 , "UART1"
   B = Inkey()
   If B = 27 Then
     Input "test serial port 0" , B
     Print B
  End If
  Waitms 500
Loop

Close #1


End