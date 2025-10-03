'-----------------------------------------------------------------------------------------
'name                     : pop3_TWI.bas
'copyright                : (c) 1995-2012, MCS Electronics
'purpose                  : demo: read email with pop3 protocol
'micro                    : Mega88
'suited for demo          : yes
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------

$regfile = "m88def.dat"
$crystal = 8000000
$baud = 19200


Print "Pop3 demo"

Dim Pop3ip As Long
Pop3ip = Maketcp(192.168.0.16)                              ' pop3 server address


'fill in your name and passwrd
Const Pop3username = "USER name{013}{010}"
Const Pop3pwd = "PASS pwd{013}{010}"


Print "Init system"
Config Lcd = 16 * 2                                         ' lcd we use
Config Lcdpin = Pin , Db4 = Portb.0 , Db5 = Portb.1 , Db6 = Portb.2 , Db7 = Portb.3 , E = Portb.4 , Rs = Portb.5
Cls                                                         ' clear LCD

Enable Interrupts
Config Tcpip = Int0 , Mac = 01.43.12.34.56.78 , Ip = 192.168.0.8 , Submask = 255.255.255.0 , Gateway = 192.168.0.1 , Localport = 1000 , Tx = $55 , Rx = $55 , Twi = &H80 , Clock = 400000

'dim variables
Dim S As String * 80 , I As Byte , J As Byte , Tempw As Word , P As Byte , Ilp As Word , Imsg As Word
Print "Init Ready"

'get a socket
I = Getsocket(0 , Sock_stream , 6001 , 0)
Print "socket : " ; I

If I <> 255 Then                                            ' all ok
   'connect to pop3 server
   J = Socketconnect(i , Pop3ip , 110)                      ' smtp server and POP3 port 110
   '   FILL IN IP number  ^^^^^
   Print "Connection : " ; J
   Print S_status(1)
   If J = 0 Then                                            ' all ok
      Print "Connected"
      Do
         Tempw = Socketstat(i , 0)                          ' get status
         Select Case Tempw
           Case Sock_established
               Do
                 Tempw = Tcpread(i , S)                     ' get line
                 Print S
               Loop Until Tempw = 0
               If Left(s , 3) = "+OK" Then                  ' ok
                  Print "Send username"
                  Tempw = Tcpwrite(i , Pop3username )       ' send username
                  '                          ^^^ fill in user name
                  Print "Get response"
                  Tempw = Tcpread(i , S)                    ' get response
                  Print "response from username : " ; S
                  If Left(s , 3) = "+OK" Then               ' ok
                     Print "Send password ; " ; Pop3pwd
                     Tempw = Tcpwrite(i , Pop3pwd)          ' send password
                     '                           ^^^^^ fill in password

                     Print "Get response from password : ";
                     Tempw = Tcpread(i , S)                 ' get response
                     Print "{" ; S ; "}"
                     If Left(s , 3) = "+OK" Then            ' ok
                        Print "Ok"
                        Do
                            Tempw = Socketstat(i , 2)       ' get number of received bytes
                            If Tempw > 0 Then
                                Tempw = Tcpread(i , S)      ' get response
                                    Print S
                            Else
                              Exit Do                       ' no more data
                            End If
                        Loop
                        Tempw = Tcpwrite(i , "STAT{013}{010}")       'get stats
                        Tempw = Tcpread(i , S)
                        Print S
                        If Left(s , 3) = "+OK" Then         ' ok
                           '+OK 10 1204
                           S = Mid(s , 5)                   ' stop +ok
                           P = Instr(s , " ")
                           P = P - 1                        ' find space
                           S = Left(s , P)
                           Cls                              ' clear LCD
                           Lcd "Emails : " ; S
                           Print "Emails : " ; S
                           Imsg = Val(s)                    ' number of messages
                           For Ilp = 1 To Imsg
                             S = "TOP " + Str(ilp) + " 0{013}{010}"
                             J = Len(s)
                             Tempw = Tcpwrite(i , S , J)    ' ask for top lines(0) which will respond with only the header
                             Do
                                Tempw = Tcpread(i , S)
                                If Left(s , 8) = "Subject:" Then       ' check for subject
                                   S = Mid(s , 10)
                                   Print "subject : " ; S
                                   Home Lower : Lcd S       ' show header
                                   Print S
                                End If
                             Loop Until S = "."             ' end of data
                             Waitms 1000                    'some time to read the display
                           Next
                        End If
                     End If
                  End If
               End If
               Tempw = Tcpwrite(i , "QUIT{013}{010}")       ' quit
               Tempw = Tcpread(i , S)

           Case Sock_close_wait
                 Print "CLOSE_WAIT"
              Closesocket I                                 ' close connection
           Case Sock_closed
                 Print "CLOSED"                             ' we are done
              End
         End Select
      Loop
   End If
End If
End                                                         'end program