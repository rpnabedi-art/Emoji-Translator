'-----------------------------------------------------------------------------------------
'name                     : sntp_SPI.bas   RFC 2030
'copyright                : (c) 1995-2012, MCS Electronics
'purpose                  : test SNTP() function
'micro                    : Mega88
'suited for demo          : yes
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------


$regfile = "m2560def.dat"                                   ' specify the used micro
$crystal = 16000000                                         ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 80                                               ' default use 32 for the hardware stack
$swstack = 128                                              ' default use 10 for the SW stack
$framesize = 80                                             ' default use 40 for the frame space
$lib "datetime.lbx"                                         'this example uses date time routines

$xramsize = &HFFFF
'$lib "tcpip-w5300.lib"

Config Xram = Enabled


'we do the usual
Print "Init TCP"                                            ' display a message
'Config Tcpip = Noint , Mac = 12.128.12.34.56.78 , Ip = 192.168.1.70 , Submask = 255.255.255.0 , Gateway = 192.168.1.1 , Localport = 1000 , Chip = W5300 , Baseaddress = &HFC00
Config Tcpip = Noint , Noinit = 1 , Localport = 1000 , Chip = W5300 , Baseaddress = &HFC00

Print "Init done"

Dim Mac(6) As Byte , Myip(4) As Byte , Submask(4) As Byte , Gateway(4) As Byte

Mac(1) = 0 : Mac(2) = 2 : Mac(3) = 3 : Mac(4) = 4 : Mac(5) = 5 : Mac(6) = 7
Myip(1) = 192 : Myip(2) = 168 : Myip(3) = 1 : Myip(4) = 70
Submask(1) = 255 : Submask(2) = 255 : Submask(3) = 255 : Submask(4) = 0
Gateway(1) = 192 : Gateway(2) = 168 : Gateway(3) = 1 : Gateway(4) = 1

Settcp Mac(1).mac(2).mac(3).mac(4).mac(5).mac(6) , Myip(1).myip(2).myip(3).myip(4) , Submask(1).submask(2).submask(3).submask(4) , Gateway(1).gateway(2).gateway(3).gateway(4)
'here mac(1) is the MSB of the MAC address

Mac(2) = 10 : Mac(6) = 70
Settcpregs &H08 , Mac(1) , 6                                ' if using settcpregs, the LSB-MSB order will be maintained. This means that mac(6) is written first (MSB).


'Dim _tcp_subnet As Long
Dim Ip As Long                                              ' IP number of time server
Dim Idx As Byte                                             ' socket number
Dim Lsntp As Long                                           ' long SNTP time
Dim W As Word


Print "SNTP demo"


'assign the IP number of a SNTP server
Ip = Maketcp(64.90.182.55 )                                 'assign IP num NIST time.nist.gov  port 37
Print "Connecting to : " ; Ip2str(ip)


'we will use Dutch format
Config Date = Dmy , Separator = -


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

   Lsntp = Sntp(idx , Ip)                                   ' get time from SNTP server

 '  Print Idx ; Lsntp
   'notice that it is not recommended to get the time every sec
   'the time server might ban your IP
   'it is better to sync once or to run your own SNTP server and update that once a day

   'what happens is that IP number of timer server is send a diagram too
   'it will put the time into a variable lsntp and this is converted to BASCOM date/time format
   'in case of a problem the variable is 0
   Print Date(lsntp) ; Spc(3) ; Time(lsntp)

   Lsntp = Lsntp + 7200
   Print "UTC correction " ; Date(lsntp) ; Spc(3) ; Time(lsntp)
   Waitms 10000

Loop


End