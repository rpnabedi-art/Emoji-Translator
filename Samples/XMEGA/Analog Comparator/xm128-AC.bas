'-----------------------------------------------------------------
'                  (c) 1995-2011, MCS
'                      xm128-AC.bas
'  This sample demonstrates the Analog Comparator
'-----------------------------------------------------------------

$regfile = "xm128a1def.dat"
$crystal = 32000000
$hwstack = 64
$swstack = 64
$framesize = 64


'First Enable The Osc Of Your Choice , make sure to enable 32 KHz clock or use an external 32 KHz clock
Config Osc = Enabled , 32mhzosc = Enabled

'configure the systemclock
Config Sysclock = 32mhz , Prescalea = 1 , Prescalebc = 1_1

Config Com1 = 19200 , Mode = Asynchroneous , Parity = None , Stopbits = 1 , Databits = 8

'setup comparator pin 0 and pin 1 are the input of portA. Pin 7 is an output in this sample
Config Aca0 = On , Hysmode = Small , Muxplus = 0 , Muxmin = 1 , Output = Enabled



Do
  Print Bin(aca_status)
  Print Aca_status.4                                        ' output ac0
  Waitms 1000
Loop

end 'end program

