'-----------------------------------------------------------------
'                  (c) 1995-2010, MCS
'                  xm128-TIMER-S3.bas
'  This sample demonstrates the TIMER sample 3 from AVR1501
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

'connect portD bit 0-3 to some LED, these are the CCx output pins
'when using TCD1, use pin 4 and 5

Dim Delta As Integer

'config timer to normal mode
Config Tcd0 = Pwm , Prescale = 8 , Comparea = Enabled , Compareb = Enabled , Comparec = Enabled , Compared = Enabled
Tcd0_per = 60000                                            ' period register
Tcd0_ccabuf = 3000                                          'compare A match value
Tcd0_ccbbuf = 60000                                         'compare B match value
Tcd0_cccbuf = 20000                                         'compare C match value
Tcd0_ccdbuf = 32000                                         'compare D match value

Do
  If Tcd0_intflags.0 = 1 Then                               ' if timer overflowed
     Tcd0_intflags.0 = 1                                    ' clear flag by writing 1

     Delta = 300
     Tcd0_ccabuf = Tcd0_ccabuf + Delta
     Tcd0_ccbbuf = Tcd0_ccbbuf + Delta
     Tcd0_cccbuf = Tcd0_cccbuf + Delta
     Tcd0_ccdbuf = Tcd0_ccdbuf + Delta
  End If
Loop

end 'end program