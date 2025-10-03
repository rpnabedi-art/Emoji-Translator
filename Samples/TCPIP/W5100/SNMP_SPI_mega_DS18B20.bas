'-----------------------------------------------------------------------------------------
'name                     : SNMP_SPI.bas
'copyright                : Ben Zijlstra
'purpose                  : Emulating SNMP-device
'micro                    : Mega1280 (Arduino Mega with W5100 Ethernetboard)
'suited for demo          : yes
'commercial addon needed  : no

'-----------------------------------------------------------------------------------------

' DS18B20 temperatuursensor op portb.5

' SNMP versie 1
' Community-string: public
' OID: 1.3.6.1.4.1.318.1.1.2.1.1.0

' In SNMP-monitoringtools, choose the AP9319 APC Environmental Monitoring Unit

$regfile = "m1280def.dat"                                   ' specify the used micro

$crystal = 16000000                                         ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 200                                              ' default use 32 for the hardware stack
$swstack = 200                                              ' default use 10 for the SW stack
$framesize = 200                                            ' default use 40 for the frame space

Config Spi = Hard , Interrupt = Off , Data Order = Msb , Master = Yes , Polarity = Low , Phase = 0 , Clockrate = 4 , Noss = 0
'Init the spi pins
Spiinit

Print "Init , set IP to 192.168.0.70"                       ' display a message
Enable Interrupts                                           ' before we use config tcpip , we need to enable the interrupts
Config Tcpip = Int4 , _
       Mac = 12.128.12.34.56.78 , _
       Ip = 192.168.0.70 , _
       Submask = 255.255.255.0 , _
       Gateway = 192.168.0.1 , _
       Localport = 161 , _
       Tx = $55 , Rx = $55 , _
       Chip = W5100 , _
       Spi = 1 , _
       Cs = Portb.4

Dim Idx As Byte                                             ' socket number
Dim Result As Word                                          ' result
Dim S(255) As Byte
Dim T(255) As Byte
Dim Temp As Byte
Dim Reqid(4) As Byte

'Variablen ds18b20
Dim I As Word
Dim N As Byte
Dim Rom1 As Integer
Dim Rom2 As Integer
Dim Temp1 As Single
Dim Temp2 As Single
Dim Temp3 As Byte
Dim Dsid1(8) As Byte                                        'Dallas ID 64 bits incl CRC
Dim Dsid2(8) As Byte

Config 1wire = Portb.5

Declare Sub Readtemperature

Print "SNMP demo"

'like with TCP, we need to get a socket first
'note that for UDP we specify sock_dgram
Idx = Getsocket(idx , Sock_dgram , 161 , 0)                 ' get socket for UDP mode, specify port 161
Print "Socket " ; Idx

'UDP is a connection less protocol which means that you can not listen, connect or can get the status
'You can just use send and receive the same way as for TCP/IP.
'But since there is no connection protocol, you need to specify the destination IP address and port
'So compare to TCP/IP you send exactly the same, but with the addition of the IP and PORT
Do
   Result = Socketstat(idx , Sel_recv)                      ' get number of bytes waiting
   If Result > 0 Then
      Print

      Udpreadheader Idx                                     ' read the udp header

      Print "Bytes waiting     " ; Result
      Print "Source IP         " ; Ip2str(peeraddress)
      Print "Source port       " ; Peerport
      Print "Length UDP-packet " ; Peersize


      If Peersize > 0 Then                                  ' the actual number of bytes
         Temp = Udpread(idx , S(1) , Peersize)              ' read the result

         Print "Community-string  ";
         For Temp = 8 To 13
            Print Chr(s(temp));                             ' print result
         Next
         Print
         Print "PDU-type          ";
         Print Hex(s(14));
         Print Hex(s(15))

         Print "Request-ID        ";
         'Print Hex(s(16));
         Reqid(1) = S(16)
         'Print Hex(s(17));
         Reqid(2) = S(17)
         Print Hex(s(18));
         Reqid(3) = S(18)
         Print Hex(s(19))
         Reqid(4) = S(19)

         T(1) = &H30
         T(2) = &H82
         T(3) = &H00

         T(4) = &H33                                        ' how many characters following

         T(5) = &H02
         T(6) = &H01
         T(7) = &H00

         T(8) = &H04
         T(9) = &H06

         T(10) = Asc( "p")
         T(11) = Asc( "u")
         T(12) = Asc( "b")
         T(13) = Asc( "l")
         T(14) = Asc( "i")
         T(15) = Asc( "c")

         T(16) = &HA2
         T(17) = &H82
         T(18) = &H00
         T(19) = &H24
         T(20) = Reqid(1)
         T(21) = Reqid(2)
         T(22) = Reqid(3)
         T(23) = Reqid(4)

         T(24) = &H02                                       'error status
         T(25) = &H01
         T(26) = &H00

         T(27) = &H02                                       'error index
         T(28) = &H01
         T(29) = &H00

         T(30) = &H30
         T(31) = &H82
         T(32) = &H00

         T(33) = &H16                                       'how many char following

         T(34) = &H30                                       'OID object identifier
         T(35) = &H82
         T(36) = &H00

         T(37) = &H12                                       'how much char following

         T(38) = &H06
         T(39) = &H0D
         T(40) = &H2B
         T(41) = &H06
         T(42) = &H01
         T(43) = &H04
         T(44) = &H01
         T(45) = &H82
         T(46) = &H3E
         T(47) = &H01
         T(48) = &H01
         T(49) = &H02
         T(50) = &H01
         T(51) = &H01
         T(52) = &H00

         T(53) = &H42                                       'value gauge
         T(54) = &H01

         Call Readtemperature

         T(55) = Temp3                                      'temperature

         Result = Udpwrite(peeraddress , Peerport , Idx , T(1) , 55)

      End If
   End If
Loop
End

Sub Readtemperature

I = 1wirecount()
Dsid1(1) = 1wsearchfirst()
Dsid2(1) = 1wsearchnext()
'Print "Aantal sensoren: " ; I

Tempwandeln:
1wreset
1wwrite &HCC                                                'Command "Skip ROM"
1wwrite &H44                                                'Command to start temperturesensing
Ddrb.5 = 1                                                  'DQ-line should within 10µs after the command &H44 for at least 750ms be high
Waitms 800                                                  'a DS18S/B20 takes about 1,5mA
Ddrb.5 = 0

1wreset
1wwrite &H55                                                'Command "Match ROM" (address Sensor)
For I = 1 To 8
1wwrite Dsid2(i)
Next I
1wwrite &HBE                                                'Command "Read Scratchpad"
Rom2 = 1wread(2)                                            'for DS18B20
Temp2 = Rom2 / 16

Temp3 = Round(temp2)
Print "Temperatuur       " ; Temp3
End Sub