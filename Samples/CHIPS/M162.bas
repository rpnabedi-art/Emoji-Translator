'-----------------------------------------------------------------------------------------
'name                     : m162.bas
'copyright                : (c) 1995-2005, MCS Electronics
'purpose                  : demo file for the M162
'micro                    : Mega162
'suited for demo          : yes
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------

$regfile = "m162def.dat"                                    ' specify the used micro
'$crystal = 7372800                                          ' used crystal frequency
'$crystal = 3684000
$crystal = 8000000
$baud = 19200                                               ' use baud rate
$hwstack = 42                                               ' default use 32 for the hardware stack
$swstack = 40                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space

' The $prog directive will program the lock and fusebits with the following values
' 16-divider disabled, external oscillator enabled, JTAG disabled
'$prog &HFF , &HEF , &HD9 , &HFF
'Everytime you program the chip, the lcok & fusebits will be programmed when they differ.
'For example when you insert a new chip
'Use with CARE as wrong values can lock the chip.


'baud rate for second serial port
$baud1 = 19200

'         TX    RX
' COM0   PD.1   PD.0
' COM1   PB.3   PB.2


'the config lines are optional. By default the settings are 8 databits,None parity,1 stopbit
Config Com1 = Dummy , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0
Config Com2 = Dummy , Synchrone = 0 , Parity = Even , Stopbits = 2 , Databits = 8 , Clockpol = 0


'use OPEN/CLOSE for using the second UART
Open "COM2:" For Binary As #1

'dimension some variables
Dim S As String * 10
Dim B As Byte

Print "Hello to COM1"

Print #1 , "test COM2"
'get a key from COM2
B = Inkey(#1)

'print value
Print #1 , B

'wait for a key from port 2
B = Waitkey(#1)
Print #1 , B

'get data from COM2
Input #1 , "s " , S
Print #1 , S
Printbin #1 , B

Do
  'use normal PRINT for COM1
  Print "com1"
  ' and add #1 for com2
  Print #1 , "com2"
  Waitms 500
Loop

'make the CLOSE the last statement of your program
Close #1

Config Int2 = Rising

End