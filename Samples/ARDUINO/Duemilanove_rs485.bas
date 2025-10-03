

'(
Pc < - - -com1(ttl To Usb) - - > Arduino Duemilanove < - - - - -max -485 - - - - - > ...... / / ..... < - - -max -485 - - - >< - - - 5v To 3.3v Level Converter - - - - - - > Atxmega32a4 - - - - > Pc(ttl To Usb Converter)
')



' Arduino Duemilanove with MAX485 and Software UART with 9600Baud
' Tx = Pinc.4
' Rx = Pinc.3
' Enable/disable RS-485 Transmitter = Pinc.2

$regfile = "m328pdef.dat"
$crystal = 16000000                                         '16MHz
$hwstack = 60
$swstack = 60
$framesize = 60


Config Com1 = 19200 , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0


'RS-485

Config Portc.2 = Output                           'Transmitt enable
Reset Portc.2
'Open a TRANSMIT channel for output
Open "comc.4:9600,8,n,1" For Output As #2

'Now open a RECEIVE channel for input
Open "comc.3:9600,8,n,1" For Input As #3


Print "---------------"
Print "Arduino Duemilanove"

Dim input_byte As Byte


Do

     Input_byte = Inkey(#3)                       'Receive Data from ATXMEGA32A4

     If Input_byte > 0 Then
          Print Chr(input_byte) ;                 'Print the Data to COM1 (RS-232 = Interface to PC)
          Waitms 1

          Set Portc.2                             'Enable Transmitter
          Printbin #2 , Input_byte                'Send the Data Back to ATXMEGA32A4
          Reset Portc.2                           'Disable Transmitter

          Input_byte = 0                          ' clear input_byte
     End If


Loop


End                                               'end program