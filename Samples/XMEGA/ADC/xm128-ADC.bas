'----------------------------------------------------------------
'                  (c) 1995-2011, MCS
'                      xm128-ADC.bas
'  This sample demonstrates the Xmega128A1 ADC
'-----------------------------------------------------------------

$regfile = "xm128a1def.dat"
$crystal = 32000000
$hwstack = 64
$swstack = 64
$framesize = 64


'First Enable The Osc Of Your Choice
Config Osc = Enabled , 32mhzosc = Enabled

'configure the systemclock
Config Sysclock = 32mhz , Prescalea = 1 , Prescalebc = 1_1

Config Com1 = 19200 , Mode = Asynchroneous , Parity = None , Stopbits = 1 , Databits = 8

Print "ADC test"

'setup the ADC-A converter
Config Adca = Single , Convmode = Unsigned , Resolution = 12bit , Dma = Off , Reference = Int1v , Event_mode = None , Prescaler = 32 , Ch0_gain = 1 , Ch0_inp = Single_ended , Mux0 = &B000_00 , _
Ch1_gain = 1 , Ch1_inp = Single_ended , Mux1 = &B1_000 , Ch2_gain = 1 , Ch2_inp = Single_ended , Mux2 = &B10_000 , Ch3_gain = 1 , Ch3_inp = Single_ended , Mux3 = &B11_000

Dim W As Word , I As Byte , Mux As Byte
Do
  Mux = I * 8                                               ' or you can use shift left,3 to get the proper offset
  W = Getadc(adca , 0 , Mux)
  '   W = Getadc(adca , 0)                                     'when not using the MUX parameter the last value of the MUX will be used!
  ' use ADCA , use channel 0, and use the pinA.0-pinA.3
  Print "RES:" ; I ; "-" ; W
  Incr I
  If I > 3 Then I = 0
  Waitms 500
Loop Until Inkey(#1) = 27


end 'end program
