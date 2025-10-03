'-----------------------------------------------------------------------------------------
'name                     : servertest_TWI_CFG.bas
'copyright                : (c) 1995-2012, MCS Electronics
'purpose                  : start the easytcp after the chip is programmed
'                           this variant shows how to use variables for the configuration
'                           and create 2 connections
'micro                    : Mega88
'suited for demo          : no
'commercial addon needed  : yes
'-----------------------------------------------------------------------------------------

$regfile = "m32def.dat"                                     ' specify the used micro
$crystal = 8000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 64                                               ' default use 32 for the hardware stack
$swstack = 64                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space
$xa                                                         ' xram access

Const I2cdemo = 1                                           'show that we can also use the I2C bus for other tasks



Dim Mac(6) As Byte                                          'array to store MAC address
Mac(1) = 1                                                  'assign some bytes
Mac(2) = 20                                                 'could come from EEPROM too
Mac(3) = 3
Mac(4) = 4
Mac(5) = 11
Mac(6) = 12

Dim Lip As Long                                             'ip number
Lip = &HC0A80007                                            ' 192.168.0.7

Dim Lsubmask As Long
Lsubmask = &HFFFFFF00                                       ' 255.255.255.0

Dim Lgateway As Long
Lgateway = &HC0A80001                                       '192.168.0.1

Print "Init , set IP to " ; Ip2str(lip)                     ' display a message
Enable Interrupts                                           ' before we use config tcpip , we need to enable the interrupts
Config Tcpip = Int0 , Mac = Mac(1) , Ip = Lip , Submask = Lsubmask , Gateway = Lgateway , Localport = 1000 , Tx = $55 , Rx = $55 , Twi = &H80 , Clock = 400000

'Use the line below if you have a gate way
'Config Tcpip = Int0 , Mac = 12.128.12.34.56.78 , Ip = 192.168.0.8 , Submask = 255.255.255.0 , Gateway = 192.168.0.1 , Localport = 1000 , Tx = $55 , Rx = $55

Dim Bclient As Byte                                         ' socket number
Dim Idx As Byte
Dim Result As Word , Result2 As Word                        ' result
Dim S As String * 80
Dim Flags As Byte
Dim Peer As Long


Do
  For Idx = 0 To 3
     Result = Socketstat(idx , 0)                           ' get status
     Select Case Result
       Case Sock_established
            If Flags.idx = 0 Then                           ' if we did not send a welcome message yet
               Flags.idx = 1
               Result = Tcpwrite(idx , "Hello from W3100A{013}{010}")       ' send welcome
            End If
            Result = Socketstat(idx , Sel_recv)             ' get number of bytes waiting
            If Result > 0 Then
               Do
                 Result = Tcpread(idx , S)
                 Print "Data from client: " ; Idx ; " " ; S
                 Peer = Getdstip(idx)
                 Print "Peer IP " ; Ip2str(peer)
                 'you could analyse the string here and send an appropiate command
                 'only exit is recognized
                 If Lcase(s) = "exit" Then
                    Closesocket Idx
                 Elseif Lcase(s) = "time" Then
                    Result2 = Tcpwrite(idx , "12:00:00{013}{010}")       ' you should send date$ or time$
                 End If
               Loop Until Result = 0
            End If
       Case Sock_close_wait
            Print "close_wait"
            Closesocket Idx
       Case Sock_closed
            Print "closed"
            Bclient = Getsocket(idx , Sock_stream , 5000 , 0)       ' get socket for server mode, specify port 5000
            Print "Socket " ; Idx ; " " ; Bclient
            Socketlisten Idx
            Print "Result " ; Result
            Flags.idx = 0                                   ' reset the hello message flag
     End Select
  Next

  #if I2cdemo
  $lib "i2c_twi.lbx"
  Config Scl = Portc.5
  Config Sda = Portc.4
  Dim Var As Byte
  Var = Not Var
  I2csend &H70 , Var
  Waitms 100
  #endif
Loop



End