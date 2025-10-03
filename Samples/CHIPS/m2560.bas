'-----------------------------------------------------------------------------------------
'name                     :
'copyright                : (c) 1995-2007, MCS Electronics
'purpose                  : test for M2560 support
'micro                    : Mega2560
'suited for demo          : yes
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------

$regfile = "m2560def.dat"                                   ' specify the used micro
$crystal = 8000000                                          ' used crystal frequency
$hwstack = 40                                               ' default use 32 for the hardware stack
$swstack = 40                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space


'$timeout = 1000000

'The M128 has an extended UART.
'when CO'NFIG COMx is not used, the default N,8,1 will be used
Config Com1 = 19200 , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0
Config Com2 = 19200 , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0
Config Com3 = 19200 , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0
Config Com4 = 19200 , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0

Enable Interrupts
Config Serialin = Buffered , Size = 20
Config Serialin1 = Buffered , Size = 20 , Bytematch = 65
Config Serialin2 = Buffered , Size = 20 , Bytematch = 66
Config Serialin3 = Buffered , Size = 20 , Bytematch = All


'Open all UARTS
Open "COM2:" For Binary As #2
Open "COM3:" For Binary As #3
Open "COM4:" For Binary As #4


Print "Hello"                                               'first uart
Dim B1 As Byte , B2 As Byte , B3 As Byte , B4 As Byte
Dim Tel As Word , Nm As String * 16

Config Adc = Single , Prescaler = Auto
Tel = Getadc(0)
Tel = Getadc(8)
Tel = 0
'unremark to test second UART
'Input #2 , "Name ?" , Nm
'Print #2 , "Hello " ; Nm


Do
  Incr Tel
  Print Tel ; " test serial port 1"
  Print #2 , Tel ; " test serial port 2"
  Print #3 , Tel ; " test serial port 3"
  Print #4 , Tel ; " test serial port 4"

  B1 = Inkey()                                              'first uart
  B2 = Inkey(#2)
  B3 = Inkey(#3)
  B4 = Inkey(#4)

  If B1 <> 0 Then
     Print B1 ; " from port 1"
  End If
  If B2 <> 0 Then
     Print #2 , B2 ; " from port 2"
  End If
  If B3 <> 0 Then
     Print #3 , B3 ; " from port 3"
  End If
  If B4 <> 0 Then
     Print #4 , B4 ; " from port 4"
  End If

  Waitms 500
Loop



'Label called when UART2 received an A
Serial1charmatch:
  Print #2 , "we got an A"
Return


'Label called when UART2 received a B
Serial2charmatch:
  Print #3 , "we got a B"
Return


'Label called when UART3 receives a char
Serial3bytereceived:
  Print #4 , "we got a char"
Return


End

Close #2
Close #3
Close #4

$eeprom
Data 1 , 2