'-----------------------------------------------------------------------------------------
'name                     : m64.bas
'copyright                : (c) 1995-2005, MCS Electronics
'purpose                  : demo for M64
'micro                    : Mega64
'suited for demo          : yes
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------

$regfile = "m64def.dat"                                     ' specify the used micro
$crystal = 8000000                                          ' used crystal frequency
$baud = 19200
$baud1 = 19200                                              ' use baud rate
$hwstack = 40                                               ' default use 32 for the hardware stack
$swstack = 20                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space

'Waitms 100
'By default the M64 runs on a 1 MHz internal oscillator
'Set the internal osc to 8 MHz for this example

'The M64 will use memory from $60-$9F for the extended registers
'
'Since some ports are located in extended registers it means that some statements
'will not work on these ports. Especially statements that will set or reset a bit
'in a register. You can set any bit yourself with the PORTF.1=1 statement for example
'But the I2C routines use ASM instructions to set the bit of a port. These ASM instructions may
'only be used on port registers. PORTF and PORTG will not work with I2C. To use I2C on these ports use the extended i2c lib

'The M64 has an extended UART.
'when CONFIG COMx is not used, the default N,8,1 will be used
Config Com1 = Dummy , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0
Config Com2 = Dummy , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0

'try the second hardware UART
Open "com2:" For Binary As #1

'try to access an extended register
Config Portf = Output
'Config Portb = Output

Print "Hello"
Dim B As Byte
Do
  Toggle Portb
  Waitms 500
  Input "test serial port 0" , B
  Print B
  Print #1 , "test serial port 2"
  Print "test"
Loop

Close #1

