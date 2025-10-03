'-----------------------------------------------------------------------------------------
'name                     : udptest_TWI.bas
'copyright                : (c) 1995-2012, MCS Electronics
'purpose                  : start the easytcp.exe program after the chip is programmed and
'                           press UDP button
'micro                    : Mega88
'suited for demo          : no
'commercial addon needed  : yes
'-----------------------------------------------------------------------------------------

$regfile = "m32def.dat"                                     ' specify the used micro

$crystal = 8000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 40                                               ' default use 32 for the hardware stack
$swstack = 40                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space


Print "Init , set IP to 192.168.0.8"                        ' display a message
Enable Interrupts                                           ' before we use config tcpip , we need to enable the interrupts
Config Tcpip = Int0 , Mac = 12.128.12.34.56.78 , Ip = 192.168.0.8 , Submask = 255.255.255.0 , Gateway = 0.0.0.0 , Localport = 1000 , Tx = $55 , Rx = $55 , Twi = &H80 , Clock = 400000


Dim Idx As Byte                                             ' socket number
Dim Result As Word                                          ' result
Dim S(80) As Byte
Dim Sstr As String * 80
Dim Temp As Byte , Temp2 As Byte                            ' temp bytes

Const Showresult = 0

Print "UDP demo"

Dim Ip As Long
Ip = Maketcp(192.168.0.16)                                  'assign IP num

'like with TCP, we need to get a socket first
'note that for UDP we specify sock_dgram
Idx = Getsocket(idx , Sock_dgram , 5000 , 0)                ' get socket for UDP mode, specify port 5000
Print "Socket " ; Idx ; " " ; Idx

'UDP is a connection less protocol which means that you can not listen, connect or can get the status
'You can just use send and receive the same way as for TCP/IP.
'But since there is no connection protocol, you need to specify the destination IP address and port
'So compare to TCP/IP you send exactly the same, but with the addition of the IP and PORT
Do
   Temp = Inkey()                                           ' wait for terminal input
   If Temp = 27 Then                                        ' ESC pressed
      Sstr = "Hello"
      Result = Udpwritestr(ip , 5000 , Idx , Sstr , 255)
   Elseif Temp = 32 Then                                    'space
      Do
         Waitms 200
         Dim Tel As Long : Incr Tel
         Sstr = "0000000000111111111122222222223333333333 " + Str(tel)
         Result = Udpwritestr(ip , 5000 , Idx , Sstr , 255)
      Loop
   End If
   Result = Socketstat(idx , Sel_recv)                      ' get number of bytes waiting
   If Result > 0 Then
      #if Showresult
        Print "Bytes waiting : " ; Result
      #endif
      Temp2 = Result - 8                                    'the first 8 bytes are always the UDP header which consist of the length, IP number and port address
      Temp = Udpread(idx , S(1) , Result)                   ' read the result
      #if Showresult
        For Temp = 1 To Temp2
            Print S(temp) ; " " ;                           ' print result
        Next
        Print
        Print Peersize ; " " ; Peeraddress ; " " ; Peerport ' these are assigned when you use UDPREAD
        Print Ip2str(peeraddress)                           ' print IP in usual format
      #endif
      Result = Udpwrite(ip , Peerport , Idx , S(1) , Temp2) ' write the received data back
   End If
Loop
'the sample above waits for data and send the data back for that reason temp2 is subtracted with 8, the header size


End