'-----------------------------------------------------------------
'                  (c) 1995-2010, MCS
'                  xm128-TIMER-S1.bas
'  This sample demonstrates the TIMER sample 1 from AVR1501
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
Config Porte = Output

'config timer to normal mode
Config Tcd0 = Normal , Prescale = 64
Tcd0_per = &H30                                             ' period register

Do
  If Inkey() <> 0 Then
     Tcd0_per = Tcd0_per + 100                              ' increase period
     Print "period:" ; Tcd0_per                             ' you will see that a larger PERIOD value will cause the TIMER to overflow later and this generating a bigger delay
  End If
  Bitwait Tcd0_intflags.0 , Set                             ' wait for overflow
  Tcd0_intflags.0 = 1                                       ' clear flag by writing 1
  Toggle Porte                                              ' toggle led
Loop


end 'end program