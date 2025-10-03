'-----------------------------------------------------------------------------------------
'name                     : PING_TWI.bas           http://www.faqs.org/rfcs/rfc792.html
'copyright                : (c) 1995-2012, MCS Electronics
'purpose                  : Simple PING program
'micro                    : Mega88
'suited for demo          : yes
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------
$regfile = "m32def.dat"                                     ' specify the used micro

$crystal = 8000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 128                                              ' default use 32 for the hardware stack
$swstack = 128                                              ' default use 10 for the SW stack
$framesize = 80                                             ' default use 40 for the frame space


Const Cdebug = 1                                            ' show debug info

Config Com1 = Dummy , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0


'we do the usual
Print "Init TCP"                                            ' display a message
Enable Interrupts                                           ' before we use config tcpip , we need to enable the interrupts
Config Tcpip = Int0 , Mac = 12.128.12.34.56.78 , Ip = 192.168.0.8 , Submask = 255.255.255.0 , Gateway = 192.168.0.1 , Localport = 1000 , Tx = $55 , Rx = $55 , Twi = &H80 , Clock = 400000 , Timeout = 1000000
Print "Init done"

Dim Idx As Byte , Result As Word , J As Byte , Res As Byte
Dim Ip As Long
Dim Dta(12) As Byte , Rec(12) As Byte


Dta(1) = 8                                                  'type is echo
Dta(2) = 0                                                  'code

Dta(3) = 0                                                  ' for checksum initialization
Dta(4) = 0                                                  ' checksum
Dta(5) = 0                                                  ' a signature can be any number
Dta(6) = 1                                                  '   signature
Dta(7) = 0                                                  ' sequence number - any number
Dta(8) = 1
Dta(9) = 65

Dim W As Word At Dta + 2 Overlay                            'same as dta(3) and dta(4)
Dim B As Byte
W = Tcpchecksum(dta(1) , 9)                                 ' calculate checksum and store in dta(3) and dta(4)

#if Cdebug
  For J = 1 To 9
    Print Dta(j)
  Next
#endif



Ip = Maketcp(192.168.0.1)                                   'try to check this server

Print "Socket " ; Idx ; " " ; Idx
Setipprotocol Idx , 1                                       'set protocol to 1
'the protocol value must be set BEFORE the socket is openend

Idx = Getsocket(idx , 3 , 5000 , 0)


Do

   Result = Udpwrite(ip , 7 , Idx , Dta(1) , 9)             'write ping data               '
   Print Result
   Waitms 100
   Result = Socketstat(idx , Sel_recv)                      'check for data
   Print Result
   If Result >= 11 Then
      Print "Ok"
      Res = Tcpread(idx , Rec(1) , Result)                  'get data with TCPREAD !!!
      #if Cdebug
        Print "DATA RETURNED :" ; Res                       '
        For J = 1 To Result
          Print Rec(j) ; " " ;
        Next
        Print
      #endif
   Else                                                     'there might be a problem
      Print "Network not available"
   End If
   Waitms 1000
Loop