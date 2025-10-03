'--------------------------------------------------------------
'                        mega88P.bas
'                      mega88 sample file
'                  (c) 1995-2008, MCS Electronics
'--------------------------------------------------------------
$RegFile = "m88pdef.dat"
$Crystal = 8000000
$Baud = 19200
$hwstack = 40
$swstack = 40
$framesize = 40
Config Com1 = 19200 , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0

Const I_know_osccal = 1                                     'make 0 or 1

'Config Clockdiv = 1                                         'we want 8 Mhz

'Config Watchdog = 2048

'The following info was inserted by the programmer.
'Press the Write PRG button and it will insert the current Lock,and Fusebit settings
'The options are DIVIDE by 8 : enabled, internal 8 MHz osc. selected
'$prog &HFF , &H62 , &HDF , &HF9                             ' generated. Take care that the chip supports all fuse bytes.
'It is advised to use the $prog only once to set the bits.
'So remark it after the chip has been programmed the first time

Config PORTB = Output

'execute following code only when osccal value is unknown
#if I_know_osccal <> 1
  For Osccal = &HA0 To &HB0
  Print "Wait for this to be readable... " ; Hex(osccal)
  WaitmS 500
  Next
#endif
'when you know the value , you can set it directrly
'Osccal = &HAF
'the calibration value was &HAD


'IMPORTANT :  OSCCAL is loaded automatic. You do not need to set it.
' but it only works correct as long as you leave the settings as shipped.
' So internal 8 Mhz with 8-divider disabled.

Dim B As Byte , W As Word

Dim K As Byte
Do
  K = WaitKey()
  Print K
  Incr B
  PORTB = Not PORTB
  Print "hello mega88 " ; B
  'we print the variable to see if the micro does not reset
  'when it resets it will never reach 255
  WaitmS 500
Loop Until Inkey() = 27


Config Adc = Single , Prescaler = Auto , Reference = Internal
Start ADC
Do
  'in version 1.11.7.6 the GETADC() supports an offset parameter
  'you can use this to add an offset to the channel.
  'For example to use the differential and GAIN settings of some new AVRS's
  Print "ch0 " ; : W = GetADC(0 , 0) : Print W
  Print "ch1 " ; GetADC(1)
  WaitmS 1000
Loop

End
