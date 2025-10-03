'-----------------------------------------------------------------------------------------
'name                     : servertest_TWI.bas
'copyright                : (c) 1995-2012, MCS Electronics
'purpose                  : start the easytcp after the chip is programmed
'                           and create 2 connections
'micro                    : Mega32
'suited for demo          : no
'commercial addon needed  : yes
'-----------------------------------------------------------------------------------------

$regfile = "m32def.dat"                                     ' specify the used micro
$crystal = 8000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate

$hwstack = 128                                              ' default use 32 for the hardware stack
$swstack = 128                                              ' default use 10 for the SW stack
$framesize = 128                                            ' default use 40 for the frame space
                                                         ' xram access

Const I2cdemo = 0                                           'show that we can also use the I2C bus for other tasks


Print "Init , set IP to 192.168.0.8"                        ' display a message
Enable Interrupts                                           ' before we use config tcpip , we need to enable the interrupts
Config Tcpip = Int0 , Mac = 12.128.12.34.56.78 , Ip = 192.168.0.8 , Submask = 255.255.255.0 , Gateway = 192.168.0.1 , Localport = 1000 , Tx = $55 , Rx = $55 , Twi = &H80 , Clock = 400000

'Use the line below if you have a gate way
'Config Tcpip = Int0 , Mac = 12.128.12.34.56.78 , Ip = 192.168.0.8 , Submask = 255.255.255.0 , Gateway = 192.168.0.1 , Localport = 1000 , Tx = $55 , Rx = $55

Dim Bclient As Byte                                         ' socket number
Dim Idx As Byte
Dim Result As Word , Result2 As Word                        ' result
Dim S As String * 80
Dim Flags As Byte
Dim Peer As Long
Dim L As Long


Do
  Waitms 1000
  For Idx = 0 To 3
     Result = Socketstat(idx , 0)                           ' get status
     Print "Socket status : " ; Result
     Select Case Result
       Case Sock_established
            If Flags.idx = 0 Then                           ' if we did not send a welcome message yet
               Flags.idx = 1
               Result = Tcpwrite(idx , "Hello from W3100A{013}{010}")       ' send welcome
            End If
            Result = Socketstat(idx , Sel_recv)             ' get number of bytes waiting
            Print "Received : " ; Result
            If Result > 0 Then
               Do
                 Print "Result : " ; Result
                 Result = Tcpread(idx , S)
                 Print "Data from client: " ; Idx ; " " ; Result ; "  " ; S
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
            Bclient = Getsocket(idx , Sock_stream , 5000 , 64)       ' get socket for server mode, specify port 5000
            Print "Socket " ; Idx ; " " ; Bclient

            Socketlisten Idx
            Print "Result " ; Result
            Flags.idx = 0                                   ' reset the hello message flag
     End Select
  Next

  #if I2cdemo
  $lib "i2c_twi.lbx"
    Config Scl = Portc.0
    Config Sda = Portc.1
    Dim Var As Byte
    Var = Not Var
    I2csend &H70 , Var
    Waitms 100
  #endif
Loop



End