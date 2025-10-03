'-----------------------------------------------------------------------------------------
'name                     : sntp_W5500.bas   RFC 2030
'copyright                : (c) 1995-2015, MCS Electronics
'purpose                  : test SNTP() function
'micro                    : xMega128A1
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


$lib "datetime.lbx"                                         'this example uses date time routines


Dim Ip As Long                                              ' IP number of time server
Dim Idx As Byte                                             ' socket number
Dim Lsntp As Long                                           ' long SNTP time

Print "SNTP demo"

'assign the IP number of a SNTP server
Ip = Maketcp(129.6.15.30 )                                  'assign IP num NIST time.nist.gov  port 37
Print "Connecting to : " ; Ip2str(ip)


'we will use Dutch format
Config Date = Dmy , Separator = Minus


'we need to get a socket first
'note that for UDP we specify sock_dgram
Idx = Getsocket(idx , Sock_dgram , 5000 , 0)                ' get socket for UDP mode, specify port 5000
Print "Socket " ; Idx

'UDP is a connection less protocol which means that you can not listen, connect or can get the status
'You can just use send and receive the same way as for TCP/IP.
'But since there is no connection protocol, you need to specify the destination IP address and port
'So compare to TCP/IP you send exactly the same, but with the addition of the IP and PORT
'The SNTP uses port 37 which is fixed in the tcp asm code


Do


   Waitms 5000

   Lsntp = Sntp(idx , Ip)                                   ' get time from SNTP server
 '  Print Idx ; Lsntp
   'notice that it is not recommended to get the time every sec
   'the time server might ban your IP
   'it is better to sync once or to run your own SNTP server and update that once a day

   'what happens is that IP number of timer server is send a diagram too
   'it will put the time into a variable lsntp and this is converted to BASCOM date/time format
   'in case of a problem the variable is 0
   Print Date(lsntp) ; Spc(3) ; Time(lsntp)
Loop



End