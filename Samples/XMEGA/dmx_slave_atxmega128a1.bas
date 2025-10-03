'-----------------------------------------------------------------
' dmx_slave_atxemga128a1.bas

' (c) 1995-2011 MCS Electronics

' this sample demonstates config Dmxslave function with ATXMEGA128A1

' You can use dmx-send.bas as a DMX Sender to test it

' Some real good info you find at http://www.dmx512-online.com/packt.html

' Adapted to be used with ATXMEGA by MAK3
'-----------------------------------------------------------------


' Output when used with example: dmx-send_atmega328p.bas:


'Start ATXMEGA as DMX Slave Example !
'
'DMX Address = 1
'DMX Channels to get = 8
'1 2 3 4 5 6 7 8
'1 2 3 4 5 6 7 8
'1 2 3 4 5 6 7 8
'1 2 3 4 5 6 7 8
'1 2 3 4 5 6 7 8
'1 2 3 4 5 6 7 8
'1 2 3 4 5 6 7 8
'....





$RegFile = "xm128a1def.dat"
$Crystal = 32000000                               '32MHz
$HWstack = 64
$SWstack = 40
$FrameSize = 40


'first enable the osc of your choice
Config Osc = Enabled , Pllosc = Disabled , Extosc = Disabled , 32khzosc = Disabled , 32mhzosc = Enabled , 32khzpowermode = Low_power       '32MHz

'configure the systemclock
Config Sysclock = 32mhz , Prescalea = 1 , Prescalebc = 1_1       '32MHz

'Config Interrupts
Config Priority = Static , Vector = Application , Lo = Enabled , Med = Enabled       'Enable Lo Level and Meduim Level Interrupts


'COM5 = Serial interface for communication with PC
Config Com5 = 57600 , Mode = Asynchroneous , Parity = None , Stopbits = 1 , Databits = 8
Open "COM5:" For Binary As #5

'We use Com1 (Portc.2 and Portc.3 of ATXMEGA as DMXslave)
Config Dmxslave = Com1 , Channels = 8 ,DMXSTART = 1 , Store = 8

'this will set up the code. an array named _dmx_channels will contain the data
'the channels will define the size. So when you want to receive data for 8 channels, you set it to 8.
'the maximum size is 512 for retrieving all data
'START defines the starting address. By default it is 1. Thus the array will be filled starting at address 3 in the example
'STORE defines how many bytes you want to store
'By default, 1 channel is read. But you can alter the variable _dmx_channels_toget to specify how many bytes you want to receive
'So essential you need to chose how many bytes you like to receive. Most slaves only need 1 - 3 bytes. It would be a waste of space to define more channels then,
'Then you set the slave address with the variable : _dmx_address , which is also set by the optional [START]
'And finally you chose how many bytes you want to receive that start at the specified address. You do this by setting the _dmx_channels_toget variable.
'Example :
'   Config Dmxslave = Com1 , Channels = 16 , Start = 300 , Store = 4
'   this would store the bytes from address 300 - 303. the maximum would be 315 since channels is set to 16
'   Config Dmxslave = Com1 , Channels = 8 , Start = 1 , Store = 8
'   this would store the bytes from address 1 - 8. the maximum would be 8 since channels is set to 8



'since DMX data is received in an ISR routine, you must enable the global interrupts
Enable Interrupts

Dim J As Byte

Print #5 , "Start ATXMEGA as DMX Slave Example !"
Print #5 ,

Print #5 , "DMX Address = " ; _dmx_address
Print #5 , "DMX Channels to get = " ; _dmx_channels_toget

Do
  WaitmS 500
  For J = 1 To _dmx_channels                            ' show the data we received
    Print #5 , _dmx_received(J) ; " " ;     'print the received data array (_DMX_RECEIVED)
  Next
  Print #5 ,
Loop


End
