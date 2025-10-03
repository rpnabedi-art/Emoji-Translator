'--------------------------------------------------------------
'                        mega48.bas
'                      mega48 sample file
'                  (c) 1995-2005, MCS Electronics
'--------------------------------------------------------------
$regfile = "m48def.dat"
$crystal = 8000000
$baud = 19200
Config Com1 = Dummy , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0
$hwstack = 40
$swstack = 40
$framesize = 40


'The following info was inserted by the programmer.
'Press the Write PRG button and it will insert the current Lock,and Fusebit settings
'The options are DIVIDE by 8 : disabled, External osc. selected
'$prog &HFF , &HEF , &HDF , &HFF                             ' generated. Take care that the chip supports all fuse bytes.
'It is advised to use the $prog only once to set the bits.
'So remark it after the chip has been programmed the first time

'Config Watchdog = 4096 ' or even 8192 is supported on the M48

'NOTE :  when you want to use the internal osc, do not enable the internal 8 divider
'The following line is used for the default, 8 Mhz osc with 8-divider disabled.
'You will benefit from the calibrated OSCCAL value then.
'$PROG &HFF,&HE2,&HDF,&HFF' generated. Take care that the chip supports all fuse bytes.

Config Portb = Output
Dim W As Word


Do
  Portb = Not Portb
  Print "hello mega48 " ; Osccal
  Waitms 500
Loop Until Inkey() = 27


Config Adc = Single , Prescaler = Auto , Reference = Internal
Start Adc
Do
   'in version 1.11.7.6 the GETADC() supports an offset parameter
   'you can use this to add an offset to the channel.
   'For example to use the differential and GAIN settings of some new AVRS's
   Print "ch0 " ; : W = Getadc(0 , 0) : Print W
   Print "ch1 " ; Getadc(1)
   Waitms 1000
Loop
End