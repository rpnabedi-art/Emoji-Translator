'-----------------------------------------------------------------------------------------
'name                     : rs485-modbus-master.bas
'copyright                : (c) 1995-2008, MCS Electronics
'purpose                  : demo file for MAKEMODBUS
'micro                    : Mega162
'suited for demo          : yes
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------

$regfile = "m162def.dat"                                    ' specify the used micro
$crystal = 8000000
$baud = 19200                                               ' use baud rate
$hwstack = 42                                               ' default use 42 for the hardware stack
$swstack = 40                                               ' default use 40 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space

$lib "modbus.lbx"                                           ' specify the additional library
'the libray will call a routine for UAR0,UART1,UAR2 and/or UAR3.
'when you get an error message that a label is not found with _SENDCHAR3 or _SENDCHAR4 then add these labels
'when you later use these routines you might get a duplicate label error and then you need to remove them
Config Print1 = Portb.1 , Mode = Set                        ' specify RS-485 and direction pin


Rs485dir Alias Portb.1                                      'make an alias
Config Rs485dir = Output                                    'set direction register to output
Rs485dir = 0                                                ' set the pin to 0 for listening

Portc.0 = 1                                                 '  a pin is used with a switch

'The circuit from the help is used. See Using MAX485
'         TX    RX
' COM0   PD.1   PD.0   rs232 used for debugging
' COM1   PB.3   PB.2   rs485 used for MODBUS halve duplex
'           PB.1       data direction rs485


'configure the first UART for RS232
Config Com1 = Dummy , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0

'configure the second UAR for RS485/MODBUS. Make sure all slaves/servers use the same settings
Config Com2 = 9600 , Synchrone = 0 , Parity = Even , Stopbits = 1 , Databits = 8 , Clockpol = 0


'use OPEN/CLOSE for using the second UART
Open "COM2:" For Binary As #1

'dimension some variables
Dim B As Byte
Dim W As Word
Dim L As Long

W = &H4567                                                  'assign a value
L = &H12345678                                              'assign a value


Print "RS-485 MODBUS master"
Do
   If Pinc.0 = 0 Then                                       ' test switch
      Waitms 500                                            ' delay
      Print "send request to slave/server"
     ' Send one of the following three messages
     ' Print #1 , Makemodbus(2 , 3 , &H2B , 8);              ' slave 2, function 3, start address 2B, 4 words is 8 bytes
     W = &HDD : Print #1 , Makemodbus(1 , 6 , &H64 , W);    ' slave 2, function 6, address 8  , value of w
     ' Print #1 , Makemodbus(2 , 16 , 8 , L);               ' slave 2, function 16, address 8 , send a long
   End If
   If Ischarwaiting(#1) <> 0 Then                           'was something returned?
       B = Waitkey(#1)                                      'then get it
       Print Hex(b) ; ",";                                  'print the info
   End If
Loop

End