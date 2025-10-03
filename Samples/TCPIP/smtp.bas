'-----------------------------------------------------------------------------------------
'name                     : smtp.bas
'copyright                : (c) 1995-2012, MCS Electronics
'purpose                  : smtp demo(sending email)
'micro                    : Mega162
'suited for demo          : no
'commercial addon needed  : yes
'-----------------------------------------------------------------------------------------

$regfile = "m162def.dat"                                    ' used processor
$crystal = 8000000                                          ' used crystal
$baud = 19200                                               ' baud rate

$hwstack = 64                                               ' default use 40 for the hardware stack
$swstack = 64                                               ' default use 40 for the SW stack
$framesize = 64                                             ' default use64 for the frame space
$xa                                                         ' xram access enabled


Const Cdebug = -1                                           ' for sending feeback to the terminal

Const Smtpuser = "HELO username{013}{010}"


#if Cdebug
   Print "Start of SMTP demo"
#endif

Enable Interrupts                                           ' enable interrupts
'specify  MAC, IP, submask and gateway
'local port value will be used when you do not specify a port value while creating a connection
'TX and RX are setup to use 4 connections each with a 2KB buffer
Config Tcpip = Int0 , Mac = 00.44.12.34.56.78 , Ip = 192.168.0.8 , Submask = 255.255.255.0 , Gateway = 192.168.0.1 , Localport = 1000 , Tx = $55 , Rx = $55

'dim the used variables
Dim S As String * 50 , I As Byte , J As Byte , Tempw As Word
#if Cdebug
  Print "setup of W3100A complete"
#endif

'First we need a socket
I = Getsocket(0 , Sock_stream , 5000 , 0)
'             ^ socket numer     ^ port
#if Cdebug
   Print "Socket : " ; I
  'the socket must return the asked socket number. It returns 255 if there was an error
#endif

If I = 0 Then                                               ' all ok
   'connect to smtp server
   J = Socketconnect(i , 123.123.123.123 , 25)              ' smtp server and SMTP port 25
   '                 ^socket
   '                      ^ ip address of the smtp server
   '                                          ^ port 25 for smtp
    '  DO NOT FORGET to ENTER a valid IP number of your ISP smtp server
   #if Cdebug
       Print "Connection : " ; J
       Print S_status(1)
   #endif
   If J = 0 Then                                            ' all ok
      #if Cdebug
         Print "Connected"
      #endif
      Do
         Tempw = Socketstat(i , 0)                          ' get status
         Select Case Tempw
           Case Sock_established                            ' connection established
               Tempw = Tcpread(i , S)                       ' read line
               #if Cdebug
                   Print S                                  ' show info from smtp server
               #endif
               If Left(s , 3) = "220" Then                  ' ok
                  Tempw = Tcpwrite(i , Smtpuser )           ' send username
                  #if Cdebug
                    Print Tempw ; "  bytes written"         ' number of bytes actual send
                  #endif
                  Tempw = Tcpread(i , S)                    ' get response
                  #if Cdebug
                     Print S                                ' show response
                  #endif
                  If Left(s , 3) = "250" Then               ' ok
                     Tempw = Tcpwrite(i , "MAIL FROM:<tcpip@test.com>{013}{010}")       ' send from address
                     Tempw = Tcpread(i , S)                 ' get response
                     #if Cdebug
                        Print S
                     #endif
                     If Left(s , 3) = "250" Then            ' ok
                        Tempw = Tcpwrite(i , "RCPT TO:<tcpip@test.com>{013}{010}")       ' send TO address
                        Tempw = Tcpread(i , S)              ' get response
                        #if Cdebug
                           Print S
                        #endif
                        If Left(s , 3) = "250" Then         ' ok
                           Tempw = Tcpwrite(i , "DATA{013}{010}")       ' speicfy that we are going to send data
                           Tempw = Tcpread(i , S)           ' get response
                           #if Cdebug
                              Print S
                           #endif
                           If Left(s , 3) = "354" Then      ' ok
                              Tempw = Tcpwrite(i , "From: tcpip@test.com{013}{010}")
                              Tempw = Tcpwrite(i , "To: tcpip@test.com{013}{010}")
                              Tempw = Tcpwrite(i , "Subject: BASCOM SMTP test{013}{010}")
                              Tempw = Tcpwrite(i , "X-Mailer: BASCOM SMTP{013}{010}")
                              Tempw = Tcpwrite(i , "{013}{010}")
                              Tempw = Tcpwrite(i , "This is a test email from BASCOM SMTP{013}{010}")
                              Tempw = Tcpwrite(i , "Add more lines as needed{013}{010}")
                              Tempw = Tcpwrite(i , ".{013}{010}")       ' end with a single dot

                              Tempw = Tcpread(i , S)        ' get response
                              #if Cdebug
                                  Print S
                              #endif
                              If Left(s , 3) = "250" Then   ' ok
                                 Tempw = Tcpwrite(i , "QUIT{013}{010}")       ' quit connection
                                 Tempw = Tcpread(i , S)
                                 #if Cdebug
                                    Print S
                                 #endif
                              End If
                           End If
                        End If
                     End If
                  End If
               End If
           Case Sock_close_wait
              Print "CLOSE_WAIT"
              Closesocket I                                 ' close the connection
           Case Sock_closed
              Print "Socket CLOSED"                         ' socket is closed
              End
         End Select
      Loop
   End If
End If
End                                                         'end program
