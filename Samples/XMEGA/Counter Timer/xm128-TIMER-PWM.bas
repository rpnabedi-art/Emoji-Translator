'-----------------------------------------------------------------
'                  (c) 1995-2010, MCS
'                  xm128-TIMER-PWM.bas
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

'connect portD bit 0-3 to some LED

'config timer to pwm mode
Config Tcd0 = Pwm , Prescale = 64 , Comparea = Enabled , Compareb = Enabled , Comparec = Enabled , Compared = Enabled
'In PWM and FREQ mode, and when COMPAREx is enabled, the port pin will be set to output

Tcd0_per = 50000                                            ' period register

Do
  If Tcd0_intflags.0 = 1 Then                               ' if timer overflowed
     Tcd0_intflags.0 = 1                                    ' clear flag by writing 1

     Tcd0_ccabuf = 0                                        'Tcd0_ccabuf + 1000
     Tcd0_ccbbuf = 65000                                    'Tcd0_ccbbuf + 1000
     Tcd0_cccbuf = Tcd0_cccbuf + 1000
     Tcd0_ccdbuf = Tcd0_ccdbuf + 5000
  End If
Loop


end 'end program