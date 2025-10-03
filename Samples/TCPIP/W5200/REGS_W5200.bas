'-----------------------------------------------------------------------------------------
'name                     : regs_W5200.bas
'copyright                : (c) 1995-2012, MCS Electronics
'purpose                  : test custom regs reading writing
'micro                    : Mega1280
'suited for demo          : no, needs library only included in the full version
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------
$regfile = "m1280def.dat"                                     ' specify the used micro

$crystal = 16000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 80                                               ' default use 32 for the hardware stack
$swstack = 128                                              ' default use 10 for the SW stack
$framesize = 80                                             ' default use 40 for the frame space

Dim L As Long

Config Spi = Hard , Interrupt = Off , Data Order = Msb , Master = Yes , Polarity = Low , Phase = 0 , Clockrate = 4 , Noss = 0
'Init the spi pins
Spiinit

'we do the usual
Print "Init TCP"                                            ' display a message
Config Tcpip = Noint , Mac = 12.128.12.34.56.78 , Ip = 192.168.1.70 , Submask = 255.255.255.0 , Gateway = 192.168.1.1 , Localport = 1000 , Chip = W5200 , Spi = 1 , Cs = Portb.4
Print "Init done"



'set the IP address to 192.168.0.135
Settcp 12.128.12.24.56.78 , 192.168.1.135 , 255.255.255.0 , 192.168.1.1



'now read the IP address direct from the registers
L = Gettcpregs(&H0f , 4)
Print Ip2str(l)

Dim B4 As Byte At L Overlay                                 ' this byte is the same as the LSB of L

'now make the IP address 192.168.1.136 by writing to the LSB
B4 = 136
Settcpregs &H0F , L , 4                                     'write


'and check if it worked
L = Gettcpregs(&H0f , 4)
Print Ip2str(l)

'and with PING you can check again that now it works


End