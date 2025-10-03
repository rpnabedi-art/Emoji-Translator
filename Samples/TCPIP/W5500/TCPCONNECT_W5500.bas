'-----------------------------------------------------------------------------------------
'name                     : TCPCONNECT_W5500.bas
'copyright                : (c) 1995-2015, MCS Electronics
'purpose                  : test SOCKETCONNECT() function
'micro                    : xMega64A3
'suited for demo          : no, needs library only included in the full version
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------

$regfile = "xm64a3def.dat"
$crystal = 32000000
$hwstack = 64                                               ' default use 32 for the hardware stack
$swstack = 128                                              'default use 10 for the SW stack
$framesize = 64                                             'default use 40 for the frame space

'First Enable The Osc Of Your Choice
Config Osc = Enabled , 32mhzosc = Enabled
'configure the systemclock
Config Sysclock = 32mhz , Prescalea = 1 , Prescalebc = 1_1
'configure UART
Config Com1 = 19200 , Mode = Asynchroneous , Parity = None , Stopbits = 1 , Databits = 8


Config Spie = Hard , Master = Yes , Mode = 0 , Clockdiv = Clk32 , Data_order = Msb , Ss = Auto
 'SPI on Port E is used
 'portx.7 - SCK
 'portx.6 - MISO
 'portx.5 - MOSI
 'portx.4 - SS

Waitms 1000
Print "Init , set IP to 192.168.1.88"                       ' display a message
Config Tcpip = Noint , Mac = 12.128.12.34.56.78 , Ip = 192.168.1.88 , Submask = 255.255.255.0 , Gateway = 192.168.1.1 , Localport = 1000 , Chip = W5500 , Spi = Spie , Cs = Porte.4
Print "Init Done"


Dim Ip As Long                                              ' IP number of time server
Dim Idx As Byte                                             ' socket number
Dim Lsntp As Long                                           ' long SNTP time
dim bResult as Byte
dim wResult1 as Word, wResult2 as Word

Print "TCP demo"

'Ip = Maketcp(173.194.65.101)                                  'assign IP from google.com or any other IP with a web server that allows a connection

'the next line is used for testing. the line above can be used for a test to a server that responds
Ip=MakeTCP(173.194.65.222)                                     ' use this for a server that does not respond

Print "Connecting to : " ; Ip2str(ip)

'we need to get a TCP socket first
Idx = Getsocket(idx , Sock_stream , 0 , 0)                ' get socket for UDP mode, specify port 5000
Print "Socket " ; Idx

bResult = SOCKETCONNECT(idx, IP, 80,1)                     'use port 80
'Notice the 4-th parameter which is 1. This means that socketconnect does not wait but returns immedeately !
print "Result : " ; bresult
wResult1 = 0

Do
  wResult2 = Socketstat(idx , 0)
  if wResult2<>wResult1 then                               'status changed
     print "STATE : " ; wresult2
     wResult1=wResult2
  end if
Loop
End