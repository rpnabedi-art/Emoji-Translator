'-----------------------------------------------------------------------------------------
'name                     : sntp_W5200.bas   RFC 2030
'copyright                : (c) 1995-2012, MCS Electronics
'purpose                  : test SNTP() function
'micro                    : Mega1280
'suited for demo          : no, needs library only included in the full version
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------


$regfile = "m1280def.dat"                                     ' specify the used micro
$crystal = 16000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 80                                               ' default use 32 for the hardware stack
$swstack = 128                                              ' default use 10 for the SW stack
$framesize = 80                                             ' default use 40 for the frame space
$lib "datetime.lbx"                                         'this example uses date time routines


'Configuration Of The SPI bus
Config Spi = Hard , Interrupt = Off , Data Order = Msb , Master = Yes , Polarity = Low , Phase = 0 , Clockrate = 4 , Noss = 0
'Init the spi pins
Spiinit

Print "Init TCP"                                            ' display a message
Config Tcpip = Noint , Mac = 12.128.12.34.56.78 , Ip = 192.168.1.70 , Submask = 255.255.255.0 , Gateway = 192.168.1.1 , Localport = 1000 , Chip = W5200 , Spi = 1 , Cs = Portb.4       'optional
Print "Init done"


Dim Ip As Long                                              ' IP number of time server
Dim Idx As Byte                                             ' socket number
Dim Lsntp As Long                                           ' long SNTP time

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