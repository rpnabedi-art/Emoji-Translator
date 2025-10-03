'-----------------------------------------------------------------------------------------
'name                     : regs_TWI.bas
'copyright                : (c) 1995-2005, MCS Electronics
'purpose                  : test custom regs reading writing
'micro                    : Mega88
'suited for demo          : yes
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------
$regfile = "m88def.dat"                                     ' specify the used micro

$crystal = 8000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 80                                               ' default use 32 for the hardware stack
$swstack = 128                                              ' default use 10 for the SW stack
$framesize = 80                                             ' default use 40 for the frame space



'we do the usual
Print "Init TCP"                                            ' display a message
Enable Interrupts                                           ' before we use config tcpip , we need to enable the interrupts
Config Tcpip = Int0 , Mac = 12.128.12.34.56.78 , Ip = 192.168.0.8 , Submask = 255.255.255.0 , Gateway = 192.168.0.1 , Localport = 1000 , Tx = $55 , Rx = $55 , Twi = &H80 , Clock = 400000
Print "Init done"


'set the IP address to 192.168.0.135
Settcp 12.128.12.24.56.78 , 192.168.0.135 , 255.255.255.0 , 192.168.0.88


Dim L As Long

'now read the IP address direct from the registers
L = Gettcpregs(&H91 , 4)
Print Ip2str(l)

Dim B4 As Byte At L Overlay                                 ' this byte is the same as the LSB of L

'now make the IP address 192.168.0.136 by writing to the LSB
B4 = 136
Settcpregs &H91 , L , 4                                     'write


'and check if it worked
L = Gettcpregs(&H91 , 4)
Print Ip2str(l)
'while the address has the right value now the chip needs a reset in order to use the new settings
L = &B10000001                                              ' set sysinit and swrest bits
Settcpregs &H00 , L , 1                                     ' write 1 register

'and with PING you can check again that now it works


End
