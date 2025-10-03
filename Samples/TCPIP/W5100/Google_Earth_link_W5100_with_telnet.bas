'-----------------------------------------------------------------------------------------
'name                     : Google Earth networklink
'hardware                 : Atmega1280, W5100 ethernetlink
'written by               : Ben Zijlstra
'-----------------------------------------------------------------------------------------

' extra, a telnet session to turn LED ON or OFF

$regfile = "m1280def.dat"                                   ' specify the used micro
$crystal = 16000000                                         ' used crystal frequency
$baud = 19200                                               ' use baud rate

$hwstack = 128                                              ' default use 32 for the hardware stack
$swstack = 128                                              ' default use 10 for the SW stack
$framesize = 128                                            ' default use 40 for the frame space

Config Spi = Hard , Interrupt = Off , Data Order = Msb , Master = Yes , Polarity = Low , Phase = 0 , Clockrate = 4 , Noss = 0
Spiinit
                                                         ' xram access
Print "Init , set IP to 192.168.0.70"                       ' display a message
Enable Interrupts                                           ' before we use config tcpip , we need to enable the interrupts
Config Tcpip = Noint , _
       Mac = 12.128.12.34.56.78 , _
       Ip = 192.168.0.70 , _
       Submask = 255.255.255.0 , _
       Gateway = 192.168.0.1 , _
       Localport = 1000 , _
       Tx = $55 , Rx = $55 , _
       Chip = W5100 , Spi = 1 , Cs = Portb.4

Dim Bclient As Byte                                         ' socket number
Dim Idx As Byte
Dim Result As Word , Result1 As Word , Result2 As Word      ' result
Dim S As String * 180
Dim Buffer_telnet As String * 1
Dim Flags As Byte
Dim Peer As Long
Dim Slen As Byte
Dim Lees As String * 180
Dim Flag As Byte
Dim Tmp As Byte
Dim H As Byte
Dim Crc As Byte
Dim Mybyte As Byte
Dim Sensor_data As String * 40
Dim Tmp_str8 As String * 8
Dim Count As Byte
Dim Telnet As Byte
Dim Telnet_established As Byte
Dim Statusled As Byte

Statusled = 0

Led Alias Portb.7                                           'this is the LED on the Arduino Mega on pin 13
Config Led = Output

'Arduino Mega pin 47
Dht_put Alias Portl.0
Dht_get Alias Pinl.0
Dht_io_set Alias Ddrl.0

Set Dht_io_set
Set Dht_put

Declare Sub Get_th(tmp As Byte , H As Byte)

Do
     Telnet = 1
     Result1 = Socketstat(telnet , 0)                       ' get status
     Select Case Result1
         Case Sock_established
            If Telnet_established = 0 Then
               Result1 = Tcpwrite(telnet , "{013}{010}Bascom-AVR W5100 example - GE networklink{013}{010}{013}{010}")
               Result1 = Tcpwrite(telnet , "Telnet-session:{013}{010}{013}{010}")
               Result1 = Tcpwrite(telnet , "1.{032}LED on{013}{010}")
               Result1 = Tcpwrite(telnet , "2.{032}LED off{013}{010}")
               Result1 = Tcpwrite(telnet , "3.{032}Quit{013}{010}{013}{010}:")
               Telnet_established = 1
            End If
            Bclient = Socketstat(telnet , Sel_recv )        ' get number of bytes waiting
            If Bclient > 0 Then
               Bclient = Tcpread(telnet , Buffer_telnet , 1)
               Select Case Buffer_telnet
                  Case "1"
                     Set Led
                     Statusled = 1
                     Result1 = Tcpwrite(telnet , " LED on{013}{010}:")
                  Case "2"
                     Reset Led
                     Statusled = 0
                     Result1 = Tcpwrite(telnet , " LED off{013}{010}:")
                  Case "3"
                     Result1 = Tcpwrite(telnet , " Goodbye{013}{010}")
                     Socketclose Telnet
               End Select
            End If
         Case Sock_close_wait                               'dit is 28
            Closesocket Telnet
         Case Sock_closed                                   'dit is 0
            Bclient = Getsocket(telnet , Sock_stream , 23 , 64)       ' get socket for server mode, specify port 5000
            Socketlisten Telnet
       Case Sock_listen
       Case Else
     End Select

    Idx = 0
     Result = Socketstat(idx , 0)
     Select Case Result
       Case Sock_established
               Flag = 0
               Do
               Result = Tcpread(idx , Lees)
               If Left(lees , 3) = "GET" Then Flag = 1
               Loop Until Result = 0
               Do
               Result = Tcpread(idx , Lees)
               If Left(lees , 3) = "GET" Then Flag = 1
               Loop Until Result = 0

               If Flag = 1 Then
                  Result = Tcpwrite(idx , "HTTP/1.0 200 OK{013}{010}{013}{010}")
                  Waitms 200
                  Restore Header
                  Do
                     Read S
                     If S = "%END%" Then
                        Socketdisconnect Idx
                        Exit Do
                     End If
                     If S = "%INFO%" Then
                        S = "LED = "
                        If Statusled = 1 Then
                           S = S + "ON{013}{010}"
                           Else
                           S = S + "OFF{013}{010}"
                        End If
                        Call Get_th(tmp , H)
                        S = S + Str(tmp) + " degrees Celcius{013}{010}"
                        S = S + Str(h)
                        S = S + " % humidity"
                     End If
                     Slen = Len(s)
                     Result = Tcpwrite(idx , S , Slen)
                  Loop
               End If
       Case Sock_close_wait
            Closesocket Idx
       Case Sock_closed
            Bclient = Getsocket(idx , Sock_stream , 80 , 64)       ' get socket for server mode, specify port 80
            Socketlisten Idx
       Case Sock_listen
       Case Else
     End Select
Loop
End

'DHT11 routine
Sub Get_th(tmp As Byte , H As Byte)

 Count = 0
 Sensor_data = ""
 Set Dht_io_set
 Reset Dht_put
 Waitms 25

 Set Dht_put
 Waitus 40
 Reset Dht_io_set
 Waitus 40
 If Dht_get = 1 Then
    H = 1
    Exit Sub
 End If

  Waitus 80
  If Dht_get = 0 Then
    H = 2
    Exit Sub
  End If

  While Dht_get = 1 : Wend

   Do
    While Dht_get = 0 : Wend
    Waitus 30
     If Dht_get = 1 Then
       Sensor_data = Sensor_data + "1"
       While Dht_get = 1 : Wend
       Else
       Sensor_data = Sensor_data + "0"
    End If
    Incr Count
   Loop Until Count = 40

   Set Dht_io_set
   Set Dht_put

   Tmp_str8 = Left(sensor_data , 8)
   H = Binval(tmp_str8)

   Tmp_str8 = Mid(sensor_data , 17 , 8)
   Tmp = Binval(tmp_str8)

   Tmp_str8 = Right(sensor_data , 8)
   Crc = Binval(tmp_str8)

   Mybyte = Tmp + H
   If Mybyte <> Crc Then
      H = 3
   End If

   Print "Temperature " ; Tmp
   Print "Humidity    " ; H

End Sub

'remark from MCS : with the $inc directive you can include a binary file


'XML-code for KML-file
Header:
Data "<?xml version={034}1.0{034} encoding={034}UTF-8{034}?>"
Data "<kml xmlns={034}http://www.opengis.net/kml/2.2{034}"
Data " xmlns:gx={034}http://www.google.com/kml/ext/2.2{034}"
Data " xmlns:kml={034}http://www.opengis.net/kml/2.2{034}"
Data " xmlns:atom={034}http://www.w3.org/2005/Atom{034}>"
Data "<Document>"
Data "<name>thuis.kml</name>"
Data "<Style id={034}s_ylw-pushpin{034}>"
Data "<IconStyle>"
Data "<scale>1.1</scale>"
Data "<Icon>"
Data "<href>http://maps.google.com/mapfiles/kml/pushpin/"
Data "ylw-pushpin.png</href>"
Data "</Icon>"
Data "<hotSpot x={034}20{034} y={034}2{034} xunits={034}"
Data "pixels{034} yunits={034}pixels{034}/>"
Data "</IconStyle>"
Data "</Style>"
Data "<StyleMap id={034}m_ylw-pushpin{034}>"
Data "<Pair>"
Data "<key>normal</key>"
Data "<styleUrl>#s_ylw-pushpin</styleUrl>"
Data "</Pair>"
Data "<Pair>"
Data "<key>highlight</key>"
Data "<styleUrl>#s_ylw-pushpin_hl</styleUrl>"
Data "</Pair>"
Data "</StyleMap>"
Data "<Style id={034}s_ylw-pushpin_hl{034}>"
Data "<IconStyle>"
Data "<scale>1.3</scale>"
Data "<Icon>"
Data "<href>http://maps.google.com/mapfiles/kml/pushpin/ylw-pushpin.png</href>"
Data "</Icon>"
Data "<hotSpot x={034}20{034} y={034}2{034} xunits={034}pixels{034}"
Data " yunits={034}pixels{034}/>"
Data "</IconStyle>"
Data "</Style>"
Data "<Placemark>"
Data "<name>Object to check</name>"
Data "<description>"
Data "%INFO%"
Data "</description>"
Data "<LookAt>"
Data "<longitude>5.403932000154976</longitude>"
Data "<latitude>51.45085099993291</latitude>"
Data "<altitude>0</altitude>"
Data "<heading>1.209628556454205e-010</heading>"
Data "<tilt>0</tilt>"
Data "<range>1025.122205284103</range>"
Data "<gx:altitudeMode>relativeToSeaFloor</gx:altitudeMode>"
Data "</LookAt>"
Data "<styleUrl>#m_ylw-pushpin</styleUrl>"
Data "<gx:balloonVisibility>1</gx:balloonVisibility>"
Data "<Point>"
Data "<coordinates>5.403932000154976,51.45085099993291,0</coordinates>"
Data "</Point>"
Data "</Placemark>"
Data "</Document>"
Data "</kml>"
Data "{013}{010}{013}{010}"
Data "%END%"