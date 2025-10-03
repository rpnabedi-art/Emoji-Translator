'-----------------------------------------------------------------------------------------
'name                     : webserver_W5200.bas
'copyright                : (c) 1995-2012, MCS Electronics
'purpose                  : simple webserver demo
'micro                    : Mega1280
'suited for demo          : no, needs library only included in the full version
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------

$regfile = "m1280def.dat"                                   ' specify the used micro

$crystal = 16000000                                         ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 128                                              ' default use 32 for the hardware stack
$swstack = 128                                              ' default use 10 for the SW stack
$framesize = 200                                            ' default use 40 for the frame space


'in debug mode to send some info to the terminal
Const Cdebug = 1
Const Authenticate = 0                                      ' use 1 to use authentication

Dim Btemp1 As Byte                                          ' Needed for Fat Drivers



$eepleave                                                   ' do not delete the EEP file since we generated it with the converter tool

#if Cdebug
    Print "init W5200...";
#endif

Config Spi = Hard , Interrupt = Off , Data Order = Msb , Master = Yes , Polarity = Low , Phase = 0 , Clockrate = 4 , Noss = 0
'Init the spi pins
Spiinit


Config Tcpip = Noint , Mac = 00.128.12.34.56.78 , Ip = 192.168.1.70 , Submask = 255.255.255.0 , Gateway = 192.168.1.1 , Localport = 1000 , Chip = W5200 , Spi = 1 , Cs = Portb.4


$include "config_MMCSD_HC-W5200.bas"
$include "Config_AVR-DOS-W5200.BAS"                               ' Include AVR-DOS Configuration and library

If Gbdriveerror = 0 Then                                    'from.... Gbdriveerror = Driveinit()
   Print "Init File System ... " ;
   Btemp1 = Initfilesystem(1)                               ' Reads the Master boot record and the partition boot record (Sector) from the flash card and initializes the file system
   If Btemp1 <> 0 Then
      Print "Error: " ; Btemp1 ; " at Init file system"
      End
   Else
      Print " OK  --> Btemp1= " ; Btemp1 ; " / Gbdriveerror = " ; Gbdriveerror
      Print "Filesystem = " ; Gbfilesystem
  End If
Else
  Print "drive error"
  End
End If

Print "done"

'dim used variables
Dim S As String * 150 , Shtml As String * 15 , Sheader As String * 30
Dim Buf(150) As Byte At S Overlay                           ' this is the same data as S but we can treat it as an array now
Dim Tempw As Word
Dim I As Byte , Bcmd As Byte , P1 As Byte , P2 As Byte , Size As Word
Dim Bcontent As Byte
Dim Bauth As Byte , Ipcon As Long                           ' for optional authentication
Dim Fl As Long , Sfile As String * 80 , Ar(128) As Byte , P As Byte , Ext As String * 3
Dim Wsize As Word

'Also included is some simple authentiation. It works by determining the client IP number
'When it differs from the current connection, the user/pwd will be asked. It is decoded with the base64dec() routine

'Usualy we start with creating a connection. This is also tru for this demo.
'Because the socketstat()function will find out that the connection is closed, it will take then
'        Case Sock_closed part of the select case statement, and so will create a new socket.
'After that it will listen to the connection for a client.


Do
  For I = 0 To 7                                            ' for all sockets
    Tempw = Socketstat(i , 0)                               ' get status
    Select Case Tempw
       Case Sock_established
            '#if Cdebug
            '    Print "sock_est"                            ' delete it when it sends to much data to the terminal
            '#endif
            If Getdstip(i) <> Ipcon Then                    ' the current client is different then the number stored
               Bauth = 0                                    ' reset authentication bit
            End If
            'Print "BAUTH:" ; Bauth
            Tempw = Socketstat(i , Sel_recv)                ' get received bytes
            If Tempw > 0 Then                               ' if there is something received
               #if Cdebug
                  Print "receive buffer size : " ; Tempw
               #endif

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
                  Print "auth"
                  Tempw = Tcpwrite(i , "HTTP/1.0 401 OK{013}{010}")       ' ask for user password
                  Tempw = Tcpwrite(i , "WWW-Authenticate: Basic realm={034}ServerID{034}{013}{010}")
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
               #if Authenticate
                  If Bauth = 1 Then                         ' only if authenticated
                     Gosub Stuur
                  End If
               #else
               Gosub Stuur                                  ' GET or HEAD or POST feedback so send it
               #endif
Continue:
               Print "sent done"
               Socketdisconnect I
            End If
       Case Sock_close_wait
            #if Cdebug
                Print I ; " CLOSE_WAIT"
            #endif
            Socketdisconnect I
       Case Sock_closed
            #if Cdebug
                Print "CLOSED"
            #endif
            I = Getsocket(i , Sock_stream , 5000 , 0)       ' get a new socket
            Socketlisten I                                  ' listen
            #if Cdebug
                Print "Listening on socket : " ; I
            #endif
    End Select
  Next
Loop
End

'get html page out of data
Page:
   P1 = Charpos(s , " ")                                    ' find first space
   Incr P1                                                  ' 4
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
   Shtml = Mid(shtml , 2)                                   ' strip the /
   Print "file:" ; Shtml ; "}"
   Sfile = Dir(shtml)
   Print "exist:" ; Sfile                                   ' check if it exists
   If Sfile <> "" Then
      P = Charpos(sfile , ".")
      Incr P
      Ext = Mid(sfile , P , 3)
      Ext = Lcase(ext)
      Select Case Ext
           Case "gif" : Tempw = Tcpwrite(i , "Content-Type: image/gif{013}{010}")
           Case "jpg" : Tempw = Tcpwrite(i , "Content-Type: image/jpeg{013}{010}")
           Case Else : Tempw = Tcpwrite(i , "Content-Type: text/html{013}{010}")
      End Select

      Fl = Filelen(shtml)
      Print "size :" ; Fl
      S = "Content-Length: " + Str(fl) + "{013}{010}"
      Tempw = Tcpwritestr(i , S , 255)                      ' add additional CR and LF
      Open Shtml For Binary As #4
      Do
          If Fl > 128 Then
             Get #4 , Ar(1) , , 128
             Fl = Fl - 128 : Wsize = 128
          Else
            Get #4 , Ar(1) , , Fl
            Wsize = Fl : Fl = 0
          End If
          Tempw = Tcpwrite(i , Ar(1) , Wsize)               ' write data
          If Tempw <> Wsize Then
            Print Tempw ; " - " ; Wsize ; " written : error"
            Exit Do
          End If
      Loop Until Fl = 0
      Close #4
   Else
      Print "file not found"
   End If
   Print "send done"
Return