'-----------------------------------------------------------------------------------------
'name                     : regs_W5300.bas
'copyright                : (c) 1995-2012, MCS Electronics
'purpose                  : test custom regs reading writing
'micro                    : Mega2560
'suited for demo          : no, needs library only included in the full version
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------
$regfile = "m2560def.dat"                                   ' specify the used micro

$crystal = 16000000                                         ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 80                                               ' default use 32 for the hardware stack
$swstack = 128                                              ' default use 10 for the SW stack
$framesize = 80                                             ' default use 40 for the frame space

Dim L As Long

$xramsize = &HFFFF

Config Xram = Enabled

'we do the usual
Print "Init TCP"                                            ' display a message
Enable Interrupts                                           ' before we use config tcpip , we need to enable the interrupts
Config Tcpip = Noint , Mac = 12.128.12.34.56.78 , Ip = 192.168.1.70 , Submask = 255.255.255.0 , Gateway = 192.168.1.1 , Localport = 1000 , Chip = W5300 , Baseaddress = &HFC00
Print "Init done"



'set the IP address to 192.168.0.135
Settcp 12.128.12.24.56.78 , 192.168.1.135 , 255.255.255.0 , 192.168.1.1



'now read the IP address direct from the registers
L = Gettcpregs(&H18 , 4)
Print Ip2str(l)

Dim B4 As Byte At L Overlay                                 ' this byte is the same as the LSB of L

'now make the IP address 192.168.1.136 by writing to the LSB
B4 = 136
Settcpregs &H18 , L , 4                                     'write


'and check if it worked
L = Gettcpregs(&H18 , 4)
Print Ip2str(l)

'and with PING you can check again that now it works


End