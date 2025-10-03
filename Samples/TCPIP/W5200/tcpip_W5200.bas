'-----------------------------------------------------------------------------------------
'name                     : tcpip_W5200.bas
'copyright                : (c) 1995-2012, MCS Electronics
'purpose                  : demo: CONFIG TCPIP
'micro                    : Mega1280
'suited for demo          : no, needs library only included in the full version
'commercial addon needed  : only hardware
'-----------------------------------------------------------------------------------------

$regfile = "M1280def.dat"
$crystal = 16000000
$baud = 19200


Const Epr = 0

Config Spi = Hard , Interrupt = Off , Data Order = Msb , Master = Yes , Polarity = Low , Phase = 0 , Clockrate = 4 , Noss = 0
'Init the spi pins
Spiinit

Print "Init , set IP to 192.168.0.8"                        ' display a message
Config Tcpip = Noint , Mac = 12.128.12.34.56.78 , Ip = 192.168.1.70 , Submask = 255.255.255.0 , Gateway = 192.168.1.1 , Localport = 1000 , Chip = W5200 , Spi = 1 , Cs = Portb.4
Print "Init Done"



'The next code is optional. It shows how to change the IP at run time
#if Epr = 1
    Dim Xx As Eram Long                                     ' this is 4 bytes of EEPROM
    Dim Zz As Long                                          ' this is a long
    Zz = Xx                                                 ' read eeprom
    Dim B4 As Byte
    B4 = 8

    'use maketcp to create an IP number
    'notice that last param is a variable.
    'all bytes could be variables of course
    Zz = Maketcp(192 , 168 , 0 , B4)

    'in reverse order
    Zz = Maketcp(b4 , 9 , 168 , 192 , 1)

    'simplest form
    Zz = Maketcp(192.168.0.8)

    Print Ip2str(zz)
    Settcp 12.128.12.34.56.78 , Zz , 255.255.255.0 , 0.0.0.0
    '                            ^   notice the variable that holds the IP address 192.168.0.8
    '                                from the EEPROM data line below
#endif

Do
  nop
  ' a ping should now work
Loop
End


End


$eeprom
' take care, data is stored byte, by byte so reversed notation is used
Data 8 , 0 , 168 , 192                                      '   this is 192 , 168 , 0 , 8
$data