'----------------------------------------------------------------
'                 (c) 1995-2011, MCS Electronics
'                     XMEGA_single_slope_PMW.bas
' sample written by MAK3
' Using PWM with XMEGA : Output at PIND.0
' As with all XMEGA Samples you need the Bascom-AVR Full Version to compile and run it
'----------------------------------------------------------------


$RegFile = "xm256A3Bdef.dat"
$Crystal = 32000000                               '32MHz
$HWstack = 64
$SWstack = 40
$FrameSize = 40


'first enable the osc of your choice
Config Osc = Enabled , Pllosc = Disabled , Extosc = Disabled , 32khzosc = Disabled , 32mhzosc = Enabled       '32MHz

'configure the systemclock
Config Sysclock = 32mhz , Prescalea = 1 , Prescalebc = 1_1       '32MHz

'Config Interrupts
Config Priority = Static , Vector = Application , Lo = Enabled       'Enable Lo Level Interrupts

Config Com7 = 57600 , Mode = Asynchroneous , Parity = None , Stopbits = 1 , Databits = 8       'Portf.2 and Portf.3 is COM7
Open "COM7:" For Binary As #2


Config Eeprom = Mapped                            ' when using EEPROM , add this config command

Dim A As Word

'Set Portd.0 as Output
Config Portd.0 = Output                           'Output for PWM


Config Tcd0 = Pwm_topbot , Prescale = 8 , Comparea = Enabled , Resolution = 16
' Tcd0 -->  The word Pwm has no real meaning because no register will be set
' Prescale = 8 --> 32MHz/8 = 4MHz
' Comparea = enabled --> Enable COMPARE or CAPTURE A
' Wgmode = pwm --> pulse width modulation single slope
' Resolution = 16 --> 16-Bit Resolution


' You can set the Period of PWM Signal with Period Register

' The Duty Cycle is set the CCA Register


'      <--TCD0_CCA->
'      +-----------+          +
'      |           |          |
'------+           +----------+
'
'      <--------------------->
'         Period = 16,38mSec

'SET Resolution of PWM (min. = &H0003 ...... max. = &HFFFF)
TCD0_PER = &H7FFF                                 'Set Period = FFFF = 65535 --> 65535/4MHz = 16.38mSec

TCD0_CCA = 10000                                  '10000/4MHz = 2.5mSec


Print #2 , "----Example PWM with XMEGA-----"


Do

  WaitmS 500

  'Change TCD0_CCA (Duty Cycle)
  TCD0_CCA = 20000                                  '20000/4MHz = 5ms

  WaitmS 500

  'Change TCD0_CCA (Duty Cycle)
  TCD0_CCA = 10000                                  '2.5ms

  Wait 2

  'Duty Cycle from 0 to 30000 = from 0 to 7.5ms
  Do
    Incr A
    TCD0_CCA = A
    WaituS 100
  Loop Until A = 30000

  A = 0

  Wait 2


Loop

End                                               'end program
