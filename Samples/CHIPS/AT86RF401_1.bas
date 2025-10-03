'AT86RF401_1.bas: Basic example for the 433.92MHc AVR 1-chip-transmitter AT86RF401E
'Made by:         Roland Walter, 01.07.2003 (DDMMYYY)
'Language:        Bascom-AVR, version 1.11.7.4 upwards
'Program job:     Sends a tone which You can receive with both AM and FM receivers
'Notes:           Program the AT86RF401 using normal AVR SPI. The SPI pins have
'                 other names, but work in the same way: SDI=MOSI, SDO=MISO, SCK=SCK.
'                 The Freeware programmer WinAVR (see at www.rowalt.de/mc/ <Tools>)
'                 supports the AT86RF401 and the STK500 too of course ;-)
'                 Single pieces of the AT86RF401 are available at www.tec-shop.de
'                 18.08MHc crystals are very cheap available at www.comtec-crystals.com
'-------------------------------------------------------------------------------------------
$regfile = "86rf401.dat"
$hwstack = 24
$swstack = 16
$framesize = 16
$crystal = 18080000                                         '18.08MHc*24=433.92MHc, AVR core 18.08MHc/128 by default

Avr_config = &B01100000                                     'Bits 6+5=11: AVR clock 1/16=1.13MHc (if 18.08MHc crystal)

'IO_ENAB   = &B00111000   'I/O-Pins data direction: 0=Input, 1=Output (unused here)
'IO_DATOUT = &B00000111   'Pins IO0,IO1 and IO2 are button inputs (unused here)

Vcotune = &B00001111                                        'Bits 4...0=01111 VCO tuning capacities 0.45pF (a middle value)
Pwr_atten = &B00000000                                      'Output Power attenuation 0 dB (full transmit power
'PWR_ATTEN = &B00101101   'Output Power attenuation 35 dB (minimum transmit power)

Tx_cntl.5 = 1                                               'Switch on VCO (Bit5=1: TX enable)
Do                                                          'Send a simple square wave tone
  Waitus 35                                                 'Real duration depends on AVR clock as set in register PWR_CTL
  Tx_cntl.4 = 1                                             'PA on (Bit4=0: TX transmits)
  '
  Waitus 35                                                 'Real duration depends on AVR clock as set in register PWR_CTL
  Tx_cntl.4 = 0                                             'PA off (Bit4=0: TX doesn't transmit)
Loop
'-------------------------------------------------------------------------------------------