'-------------------------------------------------------------------------------
'copyright                : (c) 1995-2013, MCS Electronics
'micro                    : Mega88
'suited for demo          : yes
'commercial addon needed  : no
'purpose                  : demonstrates ALIAS

'-------------------------------------------------------------------------------
$regfile = "m88def.dat"
$crystal = 8000000                                          ' 8 MHz crystal


$hwstack = 32
$swstack = 8
$framesize = 24

Const cOn = 1
Const cOff = 0

Config Portb = Output
Relais1 Alias Portb.1                                       ' from now on you can refer yo PORTB.1 with the alias RELAIS1
Relais2 Alias Portb.2
Relais3 Alias Portd.5
Relais4 Alias Portd.2

Set Relais1                                                 ' this will make PORTB.1 logic 1
Relais2 = 0
Relais3 = cOn
Relais4 = cOff



End