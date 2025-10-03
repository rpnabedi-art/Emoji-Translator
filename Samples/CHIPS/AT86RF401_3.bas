'AT86RF401_3.bas: Example 3 for the 433.92MHc AVR 1-chip-transmitter AT86RF401E
'Made by:         Roland Walter, 30.06.2003 (DDMMYYY)
'Language:        Bascom-AVR, version 1.11.7.4 upwards
'Program job:     Sends an audible square wave tone using interrupts
'-------------------------------------------------------------------------------------------
$Regfile="86rf401.dat"
$Crystal = 18080000       '18.08MHc*24=433.92MHc, AVR core 18.08MHc/128 by default
$hwstack = 16
$swstack = 8
$framesize = 24

'
'The AT86RF401 has two interrupts:
On TXE OnTxEmpty          'Transmit Buffer Empty interrupt
On TXDONE OnTxDone        'Transmit Done interrupt
'
Dim Dummy As Byte
Dim DataBit As Bit
'
AVR_CONFIG = &B01100000   'Bits 6+5=11: AVR clock 1/16=1,13MHc (if 18.08MHc crystal)
VCOTUNE    = &B00001111   'Bits 4...0=01111 VCO tuning capacities 0.45pF (a middle value)
'PWR_ATTEN = &B00101101   'Output Power attenuation 35 dB (minimal transmit power)
PWR_ATTEN  = &B00000000   'Output Power attenuation 0 dB (full transmit power)
BTCNT      = 250          'Set the BitTimer value (Bits 0...7); results an audible tone
BTCR       = &B00111010   'Bits7+6=00: MSB bits of the BitTimer value,
                          'Bits5+4=11: Transmitter keyed by Bit Timer, Bit3=1: Interrupts on,
                          'Bit1=1: (initial) Data bit, results the first interrupt
TX_CNTL.5=1               'Switch on VCO (Bit5=1: TX enable)
'
Enable Interrupts         'Global Interrupt Enable (same as SREG.7=1)
'
Do
Loop
'-------------------------------------------------------------------------------------------
OnTxEmpty:
  Dummy=BTCR            'Reset Flag0 and Flag2 by reading them out
  BTCR.1=DataBit        'Load the new data bit to send
  DataBit=Not DataBit   'Invert the data bit
Return
'-------------------------------------------------------------------------------------------
OnTxDone:
  Dummy=BTCR            'Reset Flag0 and Flag2 by reading them out
Return