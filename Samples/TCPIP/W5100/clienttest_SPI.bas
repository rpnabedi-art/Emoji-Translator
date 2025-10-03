'-----------------------------------------------------------------------------------------
'name                     : clienttest_SPI.bas
'copyright                : (c) 1995-2012, MCS Electronics
'purpose                  : start easytcp and listen to port 5000
'micro                    : Mega88
'suited for demo          : yes
'commercial addon needed  : yes
'-----------------------------------------------------------------------------------------

$regfile = "M88def.dat"
$crystal = 8000000
$baud = 19200
$hwstack = 64                                               ' default use 40 for the hardware stack
$swstack = 64                                               ' default use 40 for the SW stack
$framesize = 64                                             ' default use64 for the frame space


Config Spi = Hard , Interrupt = Off , Data Order = Msb , Master = Yes , Polarity = Low , Phase = 0 , Clockrate = 4 , Noss = 0
'Init the spi pins
Spiinit

Print "Init , set IP to 192.168.1.70"                       ' display a message
Enable Interrupts                                           ' before we use config tcpip , we need to enable the interrupts
Config Tcpip = Noint , Mac = 00.128.12.34.56.78 , Ip = 192.168.1.70 , Submask = 255.255.255.0 , Gateway = 192.168.1.1 , Localport = 1000 , Tx = $55 , Rx = $55 , Chip = W5100 , Spi = 1


Dim Bclient As Byte                                         ' socket number
Dim Idx As Byte
Dim Result As Word                                          ' result
Dim Result2 As Byte
Dim S As String * 80

For Idx = 0 To 3                                            ' for all sockets
  Bclient = Getsocket(idx , Sock_stream , 0 , 0)            ' get socket for client mode, specify port 0 so loal_port is used
  Print "Local port : " ; Local_port                        ' print local port that was used
  Print "Socket " ; Idx ; " " ; Bclient
  Result = Socketconnect(idx , 192.168.1.3 , 5000)          ' connect to easytcpip.exe server
  Print "Result " ; Result
Next


Do

  If Ischarwaiting() <> 0 Then                              ' is there a key waiting in the uart?
     Bclient = Waitkey()                                    ' get the key
     If Bclient = 27 Then
       Input "Enter string to send " , S                    ' send WHO , TIME or EXIT

       For Idx = 0 To 3
          Result = Tcpwritestr(idx , S , 255)
       Next

     End If
  End If

  For Idx = 0 To 3
     Result = Socketstat(idx , 0)                           ' get status
     Select Case Result
       Case Sock_established
            Do
              Result = Socketstat(idx , Sel_recv)           ' get number of bytes waiting
              If Result > 0 Then
               Print "size:" ; Result
               Waitms 100
               Result = Socketstat(idx , Sel_recv)          ' get number of bytes waiting
               Print "size:" ; Result

               Do
                 Result2 = Tcpread(idx , S)
                 Print "Data from server: " ; Idx ; " " ; S
               Loop Until Result2 = 0
             End If
            Loop Until Result = 0
       Case Sock_close_wait
            Print "close_wait"
            Closesocket Idx
       Case Sock_closed
            'Print "closed"
     End Select
  Next
Loop
End

