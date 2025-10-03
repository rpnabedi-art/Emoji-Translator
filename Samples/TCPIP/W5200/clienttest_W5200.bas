'-----------------------------------------------------------------------------------------
'name                     : clienttest_W5200.bas
'copyright                : (c) 1995-2012, MCS Electronics
'purpose                  : start easytcp and listen to port 5000
'micro                    : Mega1280
'suited for demo          : no, needs library only included in the full version
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------

$regfile = "M1280def.dat"
$crystal = 16000000
$baud = 19200
$hwstack = 80                                               ' default use 40 for the hardware stack
$swstack = 80                                               ' default use 40 for the SW stack
$framesize = 80                                             ' default use64 for the frame space


Config Spi = Hard , Interrupt = Off , Data Order = Msb , Master = Yes , Polarity = Low , Phase = 0 , Clockrate = 4 , Noss = 0
'Init the spi pins
Spiinit

Print "Init , set IP to 192.168.1.70"                       ' display a message
Config Tcpip = Noint , Mac = 12.128.12.34.56.78 , Ip = 192.168.1.70 , Submask = 255.255.255.0 , Gateway = 192.168.1.1 , Localport = 1000 , Chip = W5200 , Spi = 1 , Cs = Portb.4


Dim Bclient As Byte                                         ' socket number
Dim Idx As Byte
Dim Result As Word                                          ' result
Dim Result2 As Byte
Dim S As String * 80

Dim L As Long

For Idx = 0 To 7                                            ' for all socket
  Print "Get socket.."
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
       For Idx = 0 To 7
          Result = Tcpwritestr(idx , S , 255)
       Next
     Elseif Bclient = 32 Then
       For L = 1 To 100
         S = "{abcdefghijklmnopqrstuvwxyz123456789" + Str(l) + "}"
         Result = Tcpwritestr(idx , S , 255)
       Next
     End If
  End If

  For Idx = 0 To 7
     Result = Socketstat(idx , 0)                           ' get status
     Select Case Result
       Case Sock_established
            Do
              Result = Socketstat(idx , Sel_recv)           ' get number of bytes waiting
              If Result > 0 Then
               Print "size:" ; Result

               Do
                 Print "read"
                 Result2 = Tcpread(idx , S) : Print "RES:" ; Result2
                 Print "Data from server: " ; Idx ; " " ; S
               Loop Until Result2 = 0
             End If
            Loop Until Result = 0
       Case Sock_close_wait
            Print "close_wait"
            Socketdisconnect Idx
       Case Sock_closed
            Print "closed"
            End
       Case Else
         Print Hex(result)
     End Select
  Next
Loop
End
