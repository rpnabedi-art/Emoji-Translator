'-----------------------------------------------------------------------------------------
'name                     : clienttest_TWI.bas
'copyright                : (c) 1995-2012, MCS Electronics
'purpose                  : start easytcp and listen to port 5000
'micro                    : Mega88
'suited for demo          : no
'commercial addon needed  : yes
'-----------------------------------------------------------------------------------------

$regfile = "M88def.dat"

$crystal = 8000000
$baud = 19200
$hwstack = 64                                               ' default use 40 for the hardware stack
$swstack = 64                                               ' default use 40 for the SW stack
$framesize = 64                                             ' default use64 for the frame space
$xa                                                         ' xram access enabled


'Notice that the only difference between a "normal" and TWI TCP/IP program is the CONFIG TCPIP line.
Print "Init , set IP to 192.168.0.8"                        ' display a message
Enable Interrupts                                           ' before we use config tcpip , we need to enable the interrupts

Config Tcpip = Int0 , Mac = 12.128.12.34.56.78 , Ip = 192.168.0.8 , Submask = 255.255.255.0 , Gateway = 0.0.0.0 , Localport = 1000 , Tx = $55 , Rx = $55 , Twi = &H80 , Clock = 400000


Dim Bclient As Byte                                         ' socket number
Dim Idx As Byte
Dim Result As Word                                          ' result
Dim Result2 As Byte
Dim S As String * 80

For Idx = 0 To 3                                            ' for all sockets
  Bclient = Getsocket(idx , Sock_stream , 0 , 0)            ' get socket for client mode, specify port 0 so loal_port is used
  Print "Local port : " ; Local_port                        ' print local port that was used
  Print "Socket " ; Idx ; " " ; Bclient
  Result = Socketconnect(idx , 192.168.0.16 , 5000)         ' connect to easytcpip.exe server
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