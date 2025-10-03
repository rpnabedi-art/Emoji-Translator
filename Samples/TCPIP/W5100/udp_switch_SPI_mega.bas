'-----------------------------------------------------------------------------------------
'name                     : udp-switch_SPI.bas
'copyright                : Ben Zijlstra
'purpose                  :
'micro                    : Mega1280 (Arduino Mega with W5100 Ethernetboard)
'suited for demo          :
'commercial addon needed  : no
' For free UDP mobile software see : http://www.alcorn.com/support/software.html
'-----------------------------------------------------------------------------------------

$regfile = "m1280def.dat"                                   ' specify the used micro

$crystal = 16000000                                         ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 64                                               ' default use 32 for the hardware stack
$swstack = 64                                               ' default use 10 for the SW stack
$framesize = 50                                             ' default use 40 for the frame space

Config Spi = Hard , Interrupt = Off , Data Order = Msb , Master = Yes , Polarity = Low , Phase = 0 , Clockrate = 4 , Noss = 0
'Init the spi pins
Spiinit

Print "Init , set IP to 192.168.0.70"                       ' display a message
Enable Interrupts                                           ' before we use config tcpip , we need to enable the interrupts
Config Tcpip = Int4 , _
       Mac = 12.128.12.34.56.78 , _
       Ip = 192.168.0.70 , _
       Submask = 255.255.255.0 , _
       Gateway = 192.168.0.1 , _
       Localport = 5000 , _
       Tx = $55 , Rx = $55 , _
       Chip = W5100 , _
       Spi = 1 , _
       Cs = Portb.4

Dim Idx As Byte                                             ' socket number
Dim Result As Word                                          ' result
Dim S(255) As Byte
Dim Temp As Byte
Dim Command As String * 12
Const Showresult = 1

Print "UDP demo"

Relay1 Alias Portl.0
Relay2 Alias Portl.1
Relay3 Alias Portl.2
Relay4 Alias Portl.3

Config Relay1 = Output
Config Relay2 = Output
Config Relay3 = Output
Config Relay4 = Output

Relay1 = 0
Relay2 = 0
Relay3 = 0
Relay4 = 0

'like with TCP, we need to get a socket first
'note that for UDP we specify sock_dgram
Idx = Getsocket(idx , Sock_dgram , 5000 , 0)                ' get socket for UDP mode, specify port 5000
Print "Socket " ; Idx

'UDP is a connection less protocol which means that you can not listen, connect or can get the status
'You can just use send and receive the same way as for TCP/IP.
'But since there is no connection protocol, you need to specify the destination IP address and port
'So compare to TCP/IP you send exactly the same, but with the addition of the IP and PORT
Do
   Result = Socketstat(idx , Sel_recv)                      ' get number of bytes waiting
   If Result > 0 Then
      #if Showresult
         Print "Bytes waiting : " ; Result
      #endif

      Udpreadheader Idx                                     ' read the udp header

      #if Showresult
         Print
         Print "Peersize    = " ; Peersize
         Print "Peeraddress = " ; Ip2str(peeraddress)
         Print "Peerport    = " ; Peerport                  ' these are assigned when you use UDPREAD
      #endif

      If Peersize > 0 Then                                  ' the actual number of bytes
         #if Showresult
            Print "read " ; Peersize
         #endif
         Temp = Udpread(idx , S(1) , Peersize)              ' read the result

         Command = ""
         For Temp = 1 To Peersize
            Command = Command + Chr(s(temp))                ' print result
         Next
         Print "Command = " ; Command
         If Command = "relais1= on" Then Set Relay1
         If Command = "relais2= on" Then Set Relay2
         If Command = "relais3= on" Then Set Relay3
         If Command = "relais4= on" Then Set Relay4

         If Command = "relais1=off" Then Reset Relay1
         If Command = "relais2=off" Then Reset Relay2
         If Command = "relais3=off" Then Reset Relay3
         If Command = "relais4=off" Then Reset Relay4
      End If
   End If
Loop
End