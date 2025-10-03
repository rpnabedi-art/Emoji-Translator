'-----------------------------------------------------------------
'                         dmx-send.bas
'                  (c) 1995-2031 MCS Electronics
' this sample demonstates sending DMX data
' DMX can address 512 slaves and each will receive a byte
' If you only need to address the first 10 addresses you only need to send 10 bytes
'When there is a gap, say you use address 1-10 and 40-50. you MUST send 50 bytes.
'DMX is simple : the firt byte addresses address 1 and contains the value for the device on address 1
' the next byte is address 2, and contains data for device 2, etc.
'So now you understand why you need to send the number of bytes that is equal to the highest slave address.
'In other words : when you have some slaves and the highest address, is 123, you must send 123 bytes.
' Of course you may send 512 bytes but it is not required.
'Some real good info you find at http://www.dmx512-online.com/packt.html
'-----------------------------------------------------------------
'we use a chip with 2 UARTS so we can print some data
$regfile = "m88pdef.dat"
'you need to use a crystal that can generate a good 250 KHz baud
'For example 8 Mhz, 16 or 20 Mhz
$crystal = 8000000
$hwstack = 40
$swstack = 32
$framesize = 32
$map
'these are the pins we use. COM1/UART1 is used for the DMX data
'         TX    RX
' COM1   PD.1   PD.0       DMX

'the CONFIG COM is important. Use 2 stopbits and a baud rate of 250 KHz
Config Com1 = 250000 , Synchrone = 0 , Parity = None , Stopbits = 2 , Databits = 8 , Clockpol = 0


'room for some data
Dim Ar(8) As Byte

'a counter variable
Dim J As Byte

'fill the array
For J = 1 To 8
  Ar(j) = J
Next

'keep sending
Do
   Baud = 500                                               'we force a low baud
   Print Chr(0);                                            ' do not forget ;
   Waitms 1
   Baud = 250000                                            'now switch back to normal DMX baud
   Print Chr(0);

   For J = 1 To 8                                           ' this is the actual data
     Print Chr(ar(j));
   Next
   ' we have now send 1 to address 1, 2 to address 2, 3 to address 3, etc.
   Waitms 500                                               'not needed
Loop


End