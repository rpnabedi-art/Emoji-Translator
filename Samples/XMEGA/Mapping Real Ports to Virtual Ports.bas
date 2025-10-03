'-----------------------------------------------------------------
'                  (c) 1995-2011, MCS
'           Mapping Real Ports to Virtual Ports.bas
'  This sample demonstrates mapping ports to virtual ports
'  based on MAK3's sample
'-----------------------------------------------------------------

$regfile = "xm128a1def.dat"
$crystal = 32000000
$hwstack = 64
$swstack = 40
$framesize = 40


'first enable the osc of your choice
Config Osc = Enabled , 32mhzosc = Enabled

'configure the systemclock
Config Sysclock = 32mhz , Prescalea = 1 , Prescalebc = 1_1

Config Com1 = 19200 , Mode = Asynchroneous , Parity = None , Stopbits = 1 , Databits = 8

Print "Map VPorts"
'map portD to virtual port0, map portE to virtual port1, map portC to virtual port2
'map portR to virtual port 3
Config Vport0 = D , Vport1 = E , Vport2 = C , Vport3 = R

'Each virtual port is available as PORT0, PORT1, PORT2 and PORT3
'      data direct is available as DDR0 , DDR1,  DDR2  and DDR3
'        PIN input is available as PIN0 , PIN1,  PIN2  and PIN3

'The advantage of virtual port registers is that shorter asm instruction can be used which also use only 1 cycle
Dim Var As Byte


'Real Port Direction
Ddr1 = &B0000_0000                                          ' Port E = INPUT
Ddr0 = &B1111_1111                                          ' Port D = OUTPUT


'Continously copy the value from PORTE to PORTD using the virtual ports.
  Do
    Var = Pin1                                              'Read Virtual Port 0
    Port0 = Var                                             'Write Virtual Port 1
  Loop

End                                                         'end program
