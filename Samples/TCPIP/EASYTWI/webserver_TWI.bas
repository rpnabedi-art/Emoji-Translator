'-----------------------------------------------------------------------------------------
'name                     : webserver_TWI.bas
'copyright                : (c) 1995-2012, MCS Electronics
'purpose                  : simple webserver demo
'micro                    : Mega32
'suited for demo          : no
'commercial addon needed  : yes
'-----------------------------------------------------------------------------------------

$regfile = "m32def.dat"                                     ' specify the used micro

$crystal = 8000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 64                                               ' default use 32 for the hardware stack
$swstack = 64                                               ' default use 10 for the SW stack
$framesize = 200                                            ' default use 40 for the frame space
                                                         ' external memory access

'in debug mode to send some info to the terminal
Const Cdebug = 1
Const Authenticate = 0                                      ' use 1 to use authentication

$eepleave                                                   ' do not delete the EEP file since we generated it with the converter tool

#if Cdebug
    Print "init W3100A"
#endif
Enable Interrupts
Config Tcpip = Int0 , Mac = 12.128.12.34.56.78 , Ip = 192.168.0.8 , Submask = 255.255.255.0 , Gateway = 0.0.0.0 , Localport = 1000 , Tx = $55 , Rx = $55 , Twi = &H80 , Clock = 400000

Print "done"

'dim used variables
Dim S As String * 140 At &H120 , Shtml As String * 15 , Sheader As String * 30
Dim Buf(120) As Byte At S Overlay                           ' this is the same data as S but we can treat it as an array now
Dim Tempw As Word
Dim I As Byte , Bcmd As Byte , P1 As Byte , P2 As Byte , Size As Word
Dim Bcontent As Byte
Dim Bauth As Byte , Ipcon As Long                           ' for optional authentication

'note that this webserver demo uses just 1 connection. It can easy be changed to use all 4 connections
'also note that the connection is terminated by the webserver after the data has been sent.
'this is done so more clients can be served, it is not acording to the RFC
'Also included is some simple authentiation. It works by determining the client IP number
'When it differs from the current connection, the user/pwd will be asked. It is decoded with the base64dec() routine

'Usualy we start with creating a connection. This is also tru for this demo.
'Because the socketstat()function will find out that the connection is closed, it will take then
'        Case Sock_closed part of the select case statement, and so will create a new socket.
'After that it will listen to the connection for a client.


I = 0                                                       ' we use just 1 connection with number 0
Do
    Tempw = Socketstat(i , 0)                               ' get status
    Select Case Tempw
       Case Sock_established
            #if Cdebug
                Print "sock_est"                            ' delete it when it sends to much data to the terminal
            #endif
            If Getdstip(i) <> Ipcon Then                    ' the current client is different then the number stored
               Bauth = 0                                    ' reset authentication bit
            End If
            Tempw = Socketstat(i , Sel_recv)                ' get received bytes
            #if Cdebug
                Print "receive buffer size : " ; Tempw
            #endif
            If Tempw > 0 Then                               ' if there is something received
               Bcmd = 0
               Do
                 Tempw = Tcpread(i , S)                     ' read a line
                 If Left(s , 3) = "GET" Then
                    Bcmd = 1                                ' GET /index.htm HTTP/1.1
                    Gosub Page
                 Elseif Left(s , 4) = "HEAD" Then
                    Bcmd = 2
                    Gosub Page
                 Elseif Left(s , 4) = "POST" Then
                    Bcmd = 3
                 Elseif Left(s , 15) = "Content-Length:" Then       ' for post
                    S = Mid(s , 16) : Bcontent = Val(s)
                 Elseif Left(s , 20) = "Authorization: Basic" Then       ' user and pwd specified
                    Print S
                    S = Mid(s , 22)                         'Authorization: Basic bWFyazptYXJr
                    Print "{" ; S ; "}"                     ' this is the user/pwd part the browser is sending
                    #if Cdebug
                        Print "Decoded user:pwd " ; Base64dec(s)
                    #endif
                    If Base64dec(s) = "mark:mark" Then      'pwd ok
                       Bauth = 1                            ' verified
                       Ipcon = Getdstip(i)                  ' store current ip number
                    End If
                 Else
                    #if Cdebug
                        Print S                             ' print data the client browser sent
                    #endif
                 End If
               Loop Until S = ""                            ' wait until we get an empty line

               #if Authenticate
               If Bauth = 0 Then
                  Tempw = Tcpwrite(i , "HTTP/1.0 401 OK{013}{010}")       ' ask for user password
                  Tempw = Tcpwrite(i , "WWW-Authenticate: Basic realm={034}ServerID{034}{013}{010}")
                  Goto Continue
               Else
                 Tempw = Tcpwrite(i , "HTTP/1.0 200 OK{013}{010}")
               End If
               #else                                        ' no authentication used
                     Tempw = Tcpwrite(i , "HTTP/1.0 200 OK{013}{010}")       'send ok
               #endif
               If Bcmd = 3 Then
                  #if Cdebug
                      Print "Posted data"
                  #endif
                  Tempw = Tcpread(i , Buf(1) , Bcontent)    ' read data
                  #if Cdebug
                      Bcontent = Bcontent + 1
                      Buf(bcontent) = 0                     ' put string terminator at end of data so we can handle it as a string
                      Print S
                  #endif
                  Shtml = "/redirect.htm"                   ' redirect to www.mcselec.com
               End If
               Gosub Stuur                                  ' GET or HEAD or POST feedback so send it
Continue:
               Print "closing socket"
               Closesocket I                                ' close the connection
               Print "done"
            End If
       Case Sock_close_wait
            #if Cdebug
                Print "CLOSE_WAIT"
            #endif
            Closesocket I                                   ' we need to close
       Case Sock_closed
            #if Cdebug
                Print "CLOSED"
            #endif
            I = Getsocket(0 , Sock_stream , 5000 , 0)       ' get a new socket
            Socketlisten I                                  ' listen
            #if Cdebug
                Print "Listening on socket : " ; I
            #endif
    End Select

Loop
End

'get html page out of data
Page:
   P1 = Instr(s , " ")                                      ' find first space
   P1 = P1 + 1                                              ' 4
   P2 = Instr(p1 , S , " ")                                 ' find second space
   P2 = P2 - P1
   Shtml = Mid(s , P1 , P2)                                 ' dont use too long page names
   Shtml = Lcase(shtml)                                     ' make lower case
   #if Cdebug
       Print "HTML page:" ; Shtml
   #endif
Return


'send data
 Stuur:
   Dim Woffset As Word , Bcontenttype As Byte , Wsize As Word , Bgenerate As Bit , Ihitcounter As Integer
   Bgenerate = 0                                            ' by default
   Select Case Shtml
     Case "/index.htm"
           Bcontenttype = 0 : Bgenerate = 1
     Case "/redirect.htm"
           Bcontenttype = 0 : Bgenerate = 1
     Case "/post.htm" : Wsize = 277
           Bcontenttype = 0 : Woffset = 0
     Case "/notfound.htm" : Wsize = 123
           Bcontenttype = 0 : Woffset = 277
     Case Else                                              ' not found
           Bcontenttype = 0 : Woffset = 277 : Wsize = 123
   End Select

   Select Case Bcontenttype
     Case 0:                                                ' text
              Tempw = Tcpwrite(i , "Content-Type: text/html{013}{010}")
     Case 1:                                                ' gif
   End Select
   If Bgenerate = 0 Then                                    ' data from eeprom
      S = "Content-Length: " + Str(wsize) + "{013}{010}"
      Tempw = Tcpwritestr(i , S , 255)                      ' add additional CR and LF
      Tempw = Tcpwrite(i , Eeprom , Woffset , Wsize)        ' write data
   Else                                                     ' we generate the data
      If Shtml = "/index.htm" Then
         S = "<html><head><title>Easy TCP/IP</title></head><body><p><b>MCS webserver test<br></b>Hits : " + Str(ihitcounter) + "</p><p>&nbsp;</p><p>&nbsp;</p></body></html>"
         Incr Ihitcounter                                   'increase hitcounter
      Else
         S = "<html><head><title</title></head><body onload='window.location.href=" + Chr(34) + "http://www.mcselec.com" + Chr(34) + "'></body></html>"
      End If
      Wsize = Len(s)                                        ' size of body
      Sheader = "Content-Length: " + Str(wsize) + "{013}{010}"
      Tempw = Tcpwritestr(i , Sheader , 255)                ' add additional CR and LF
      Tempw = Tcpwrite(i , S , Wsize)                       ' send body
   End If
 Return