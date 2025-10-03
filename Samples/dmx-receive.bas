'-----------------------------------------------------------------
'                         dmx-receive.bas
'                  (c) 1995-2013 MCS Electronics
' this sample demonstates receiving a DMX datastream in the background
'-----------------------------------------------------------------
'we use a chip with 2 UARTS so we can print some data
$RegFile = "m162def.dat"
'you need to use a crystal that can generate a good 250 KHz baud
'For example 8 Mhz, 16 or 20 Mhz
$crystal = 8000000
'define the stack
$hwstack = 40
$swstack = 32
$framesize = 32


'these are the pins we use. COM1/UART1 is used for the DMX data
'         TX    RX
' COM1   PD.1   PD.0       DMX
' COM2   PB.3   PB.2       RS-232
#autocode
Config Dmxslave = Com1 , Channels = 16 , Dmxstart = 3 , Store = 1
'this will set up the code. an array named _dmx_channels will contain the data
'the channels will define the size. So when you want to receive data for 8 channels, you set it to 8.
'the maximum size is 512 for retrieving all data
'START defines the starting address. By default it is 1. Thus the array will be filled starting at address 3 in the example
'STORE defines how many bytes you want to store
'By default, 1 channel is read. But you can alter the variable _dmx_channelels_toget to specify how many bytes you want to receive
'So essential you need to chose how many bytes you like to receive. Most slaves only need 1 - 3 bytes. It would be a waste of space to define more channels then,
'Then you set the slave address with the variable : _dmx_address , which is also set by the optional [START]
'And finally you chose how many bytes you want to receive that start at the specified address. You do this by setting the _dmx_channels_toget variable.
'Example :
'   Config Dmxslave = Com1 , Channels = 16 , Start = 300 , Store = 4
'   this would store the bytes from address 300 - 303. the maximum would be 315 since channels is set to 16
'   Config Dmxslave = Com1 , Channels = 8 , Start = 1 , Store = 8
'   this would store the bytes from address 1 - 8. the maximum would be 8 since channels is set to 8

Config Com2 = 19200 , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0
#endautocode



Open "COM2:" For Binary As #1
Print #1 , "MCS  DMX-512 test"

'since DMX data is received in an ISR routine, you must enable the global interrupts
Enable Interrupts


Dim J As Byte
Do
    If Inkey(#1) = 32 Then                                  ' when you press the space bar
      For J = 1 To _dmx_channels                            ' show the data we received
         Print #1 , _dmx_received(j) ; " " ;
      Next
      Print #1,
   Elseif Inkey(#1) = 27 Then                               'you ca dynamic change the start address and the channels
     Input #1 , "start " , _dmx_address
     Input #1 , "channels " , _dmx_channels_toget

   End If
Loop

'typical you would read a DIP switch and use the value as the address


End