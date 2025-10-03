'-----------------------------------------------------------------------------------------
'name                     : sntp.bas   RFC 2030
'copyright                : (c) 1995-2012, MCS Electronics
'purpose                  : test SNTP() function
'micro                    : Mega162
'suited for demo          : yes
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------

$regfile = "m162def.dat"                                    ' specify the used micro
$crystal = 8000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 80                                               ' default use 32 for the hardware stack
$swstack = 80                                               ' default use 10 for the SW stack
$framesize = 80                                             ' default use 40 for the frame space
$xa
$lib "datetime.lbx"                                         'this example uses date time routines



Print "Init TCP"                                            ' display a message
Enable Interrupts                                           ' before we use config tcpip , we need to enable the interrupts
Config Tcpip = Int0 , Mac = 12.128.12.34.56.78 , Ip = 192.168.0.8 , Submask = 255.255.255.0 , Gateway = 0.0.0.0 , Localport = 1000 , Tx = $55 , Rx = $55

Dim Var As Byte                                             'for i2c test


Dim Ip As Long                                              ' IP number of time server
Dim Idx As Byte                                             ' socket number
Dim Lsntp As Long                                           'long SNTP time

Print "SNTP demo"

'assign the IP number of a SNTP server
Ip = Maketcp(193.67.79.202 )                                'assign IP num  ntp0.nl.net port 37

'we will use Dutch format
Config Date = Dmy , Separator = -


'we need to get a socket first
'note that for UDP we specify sock_dgram
Idx = Getsocket(idx , Sock_dgram , 5000 , 0)                ' get socket for UDP mode, specify port 5000
Print "Socket " ; Idx ; " " ; Idx

'UDP is a connection less protocol which means that you can not listen, connect or can get the status
'You can just use send and receive the same way as for TCP/IP.
'But since there is no connection protocol, you need to specify the destination IP address and port
'So compare to TCP/IP you send exactly the same, but with the addition of the IP and PORT
'The SNTP uses port 37 which is fixed in the tcp asm code



Do

   'toggle the variable
   Toggle Var

   Waitms 1000

   Lsntp = Sntp(idx , Ip)                                   ' get time from SNTP server
   'notice that it is not recommended to get the time every sec
   'the time server might ban your IP
   'it is better to sync once or to run your own SNTP server and update that once a day

   'what happens is that IP number of timer server is send a diagram too
   'it will put the time into a variable lsntp and this is converted to BASCOM date/time format
   'in case of a problem the variable is 0
   Print Date(lsntp) ; Spc(3) ; Time(lsntp)
Loop

End