'-----------------------------------------------------------------------------------------
'name                     : pop3_W5200.bas
'purpose                  : demo: read email with pop3 protocol
'micro                    : atmega1280 (Arduino Mega)
'-----------------------------------------------------------------------------------------

'Arduino Mega - W5200 ethernet shield - own LCD shield

'Works on the Dutch Ziggo network

$regfile = "m1280def.dat"
$crystal = 16000000
$baud = 19200

' Pop3 demo

Dim Bclient As Byte                                         ' socket number
Dim Pop3ip As Long
Dim Idx As Byte
Dim Result As Word                                          ' result
Dim S As String * 180 , I As Byte , J As Byte , Tempw As Word , P As Byte , Ilp As Word , Imsg As Word
Dim Z As Byte

Pop3ip = Maketcp(212.54.42.4)                               ' pop3 server address

'fill in your name and passwrd
Const Pop3username = "USER test@home.nl{013}{010}"
Const Pop3pwd = "PASS secret{013}{010}"

'Configuration Of The SPI bus
Config Spi = Hard , Interrupt = Off , Data Order = Msb , Master = Yes , Polarity = Low , Phase = 0 , Clockrate = 4 , Noss = 0
'Init the spi pins
Spiinit

'R/W LCD
Config Porte.5 = Output
Porte.5 = 0

'three buttons
Config Portf.0 = Input
Config Portf.1 = Input
Config Portf.2 = Input

'pull-ups on buttons
Portf.0 = 1
Portf.1 = 1
Portf.2 = 1

'type of display
Config Lcd = 16 * 2

Beep Alias Portg.2
Config Beep = Output

Reset Beep
Waitms 250
Set Beep

'configure display
Config Lcdpin = Pin , Db4 = Portb.4 , Db5 = Portb.5 , Db6 = Portb.6 , Db7 = Portb.7 , _
E = Porte.3 , Rs = Portg.5

'Init display
Initlcd
Cursor Off
Cls
Home
Lcd "Bascom-AVR W5200"
Lowerline
Lcd "POP3 demo"

Wait 5

Cls
Home
Lcd "Init system"
Wait 2

Cls
Home
Lcd "Init TCP"                                              ' display a message
Wait 2                                                      ' no INT4 in the config TCPIP, conflicting with LCD
Enable Interrupts                                           ' before we use config tcpip , we need to enable the interrupts
Config Tcpip = Noint , _
       Mac = 12.128.12.34.56.78 , _
       Ip = 192.168.0.70 , _
       Submask = 255.255.255.0 , _
       Gateway = 192.168.0.1 , _
       Localport = 1000 , _
       Tx = $55 , Rx = $55 , _
       Chip = W5200 , Spi = 1 , Cs = Portb.4
Lowerline
Lcd "Init done"
Wait 2

Do

Idx = 0                                                     ' for all socket
  Cls
  Home
  Lcd "Checking email"
  Wait 2
  Bclient = Getsocket(idx , Sock_stream , 0 )               ' get socket for client mode, specify port 0 so loal_port is used
  Result = Socketconnect(idx , Pop3ip , 110)                ' connect to ziggo pop3 server

  Tempw = Socketstat(idx , 0)
         Select Case Tempw
           Case 23                                          'Sock_established
               Do
                 Tempw = Tcpread(i , S)                     ' get line
                 Print S
               Loop Until Tempw = 0
               If Left(s , 3) = "+OK" Then                  ' ok
                  Tempw = Tcpwrite(i , Pop3username )       ' send username
                  Tempw = Tcpread(i , S)                    ' get response
                  If Left(s , 3) = "+OK" Then               ' ok
                     Tempw = Tcpwrite(i , Pop3pwd)          ' send password
                     Tempw = Tcpread(i , S)                 ' get response
                     If Left(s , 3) = "+OK" Then            ' ok
                        Do
                            Tempw = Socketstat(i , 2)       ' get number of received bytes
                            If Tempw > 0 Then
                                Tempw = Tcpread(i , S)      ' get response
                            Else
                              Exit Do                       ' no more data
                            End If
                        Loop
                        Tempw = Tcpwrite(i , "STAT{013}{010}")       'get stats
                        Tempw = Tcpread(i , S)
                        If Left(s , 3) = "+OK" Then         ' ok
                           '+OK 10 1204
                           S = Mid(s , 5)                   ' stop +ok
                           P = Instr(s , " ")
                           P = P - 1                        ' find space
                           S = Left(s , P)
                           Cls
                           Home
                           Lcd "Emails: " ; S
                           Wait 2
                           Imsg = Val(s)                    ' number of messages
                           For Ilp = 1 To Imsg
                             S = "TOP " + Str(ilp) + " 0{013}{010}"
                             J = Len(s)
                             Tempw = Tcpwrite(i , S , J)    ' ask for top lines(0) which will respond with only the header
                             Do
                                Tempw = Tcpread(i , S)
                                If Left(s , 8) = "Subject:" Then       ' check for subject
                                   S = Mid(s , 10 , 16)
                                   Cls
                                   Home
                                   Reset Beep
                                   Waitms 100
                                   Set Beep
                                   Lcd "Subject:"
                                   Home Lower : Lcd S       ' show header
                                   Wait 2
                                End If
                             Loop Until S = "."             ' end of data
                             Wait 2                         'some time to read the display
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
         Closesocket 0
         Cls
         Home
         Lcd "Checking mail in"
         Lowerline
         For Z = 90 To 1 Step -1
         Locate 2 , 1
         Lcd Z
         Lcd " seconds     "
         Wait 1
         Next Z
Loop

End                                                         'end program