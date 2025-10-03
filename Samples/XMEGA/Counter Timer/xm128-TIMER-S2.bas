'-----------------------------------------------------------------
'                  (c) 1995-2010, MCS
'                  xm128-TIMER-S2.bas
'  This sample demonstrates the TIMER sample 2 from AVR1501
'  This sample uses TIMER TCD0 since TCC0 isused for the UART
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

'connect portE bit 0 and 1 to some LED
Config Porte.0 = Output
Porte.0 = 1                                                 'turn off led

'config timer to normal mode
Config Tcd0 = Normal , Prescale = 64
Tcd0_per = &HFFFF                                           ' period register
Tcd0_cca = &H300                                            'compare A match value

Do
  If Tcd0_intflags.0 = 1 Then                               ' if timer overflowed
     Tcd0_intflags.0 = 1                                    ' clear flag by writing 1
     Porte.0 = 1                                            ' toggle led
  End If
  If Tcd0_intflags.4 = 1 Then                               ' CCA compare match
     Tcd0_intflags.4 = 1                                    ' clear interrupt
     Tcd0_ccabuf = Tcd0_ccabuf + &H1000
     Porte.0 = 0
  End If
Loop


end 'end program