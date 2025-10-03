'AT86RF401_02.bas: Example 2 for the 433.92MHc AVR 1-chip-transmitter AT86RF401E
'Made by:          Roland Walter, 01.07.2003 (DDMMYYY)
'Language:         Bascom-AVR, version 1.11.7.4 upwards
'Program job:      Sends an audible squarewave tone. The PA is keyed by the Bit Timer.
'-------------------------------------------------------------------------------------------
$Regfile="86rf401.dat"
$Crystal = 18080000       '18.08MHc*24=433.92MHc, AVR core 18.08MHc/128 by default
$hwstack = 16
$swstack = 8
$framesize = 16

Dim DataBit As Bit

AVR_CONFIG = &B00100000   'Bits 6+5=01: AVR clock 1/64=282,5KHz (if 18.08MHc crystal)
BTCR       = &B00110000   'Bits5+4=11: Transmitter keyed by Bit Timer, Bit3=0: No interrupt
VCOTUNE    = &B00001111   'Bits 4...0=01111 VCO tuning capacities 0.45pF (a middle value)
PWR_ATTEN  = &B00000000   'Output Power attenuation 0 dB (full transmit power)
TX_CNTL.5  = 1            'Switch on VCO (Bit5=1: TX enable)
BTCNT      = 175          'Set the BitTimer value (Bits 0...7); results a tone

Do                        'Send a simple square wave tone
  If BTCR.0=1 Then        'Bit buffer is empty
    BTCR.1=DataBit        'Load the new data bit to send
    DataBit=Not DataBit   'Invert the data bit
  End If
Loop
'-------------------------------------------------------------------------------------------