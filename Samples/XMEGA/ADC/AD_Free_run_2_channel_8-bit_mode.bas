'-----------------------------------------------------------
'            AD_Free_run_2_channel_8-bit_mode.bas
'               (c) 1995-2011 MCS Electronics
' sample provided by MAK3
'-----------------------------------------------------------

' Configure the ADC of Port A to use 2 Channels with differential Input and with Gain
' Pina 0 (+) and Pina 4 (-) is used for Channel 0
' Pina 1 (+) and Pina 5 (-) is used for Channel 1


' In this Example we use 8-Bit Mode
' Bit 7  of the Result Byte is the Sign-Bit  !


'$regfile = "xm128a1def.dat"
$regfile = "xm32a4def.dat"
$crystal = 32000000                               '32MHz
$hwstack = 64
$swstack = 40
$framesize = 40


Config Osc = Enabled , 32mhzosc = Enabled
Config Sysclock = 32mhz                           '--> 32MHz

'Serial Interface to PC
Config Com1 = 57600 , Mode = Asynchroneous , Parity = None , Stopbits = 1 , Databits = 8
Open "COM1:" For Binary As #1

Config Dp = comma                                   'comma is used as a separator (for FUSING function)
'Config Dp = "."                                   'dot is used as a separator (for FUSING function). You also need to change this "###.#" in the fusing funtion


Print #1 , "-----------------START-------------------"


'Config Interrupts
Config Priority = Static , Vector = Application , Lo = Enabled

Config Eeprom = Mapped                            'when using EEPROM , add this config command

'For 12-Bit
Const Mv_per_adc_step = 1.007               'Vref = 3,3Volt/1,6 = 2,0625/2048 ADC Steps = 1.007 mV

'For 8 Bit
Const Mv_per_adc_step_8_bit = 16.11               'Vref = 3,3Volt/1,6 = 2,0625/128 ADC Steps = 16.11328 mV

Const Sample_count = 311

Dim Channel_0(sample_count) As Byte               'Measurement Array for Channel 0
Dim Channel_1(sample_count) As Byte               'Measurement Array for Channel 1



dim milli_volt as single

Dim Channel_0_ready_bit As Bit
Dim Channel_1_ready_bit As Bit

Dim Channel_0_sample_count As Word
Dim Channel_1_sample_count As Word
Dim X As Word

Set Adca_ctrla.1                                            'Flush the ADC Pipeline

'Configure ADC of Port A in FREE running mode
Config Adca = Free , Convmode = Signed , Resolution = 8bit , Dma = Off , _
 Reference = Intvcc , Event_mode = None , Prescaler = 256 , Sweep = Ch01 , _
 Ch0_gain = 1 , Ch0_inp = Diffwgain , Mux0 = &B00000000 , _
 Ch1_gain = 1 , Ch1_inp = Diffwgain , Mux1 = &B00001001
' Ch2_gain = 1 , Ch2_inp = Diffwgain , Mux2 = &B00001001 _
' Ch3_gain = 1 , Ch3_inp = Diffwgain , Mux3 = &B00001001 _

 ' With MuxX you can set the 4 MUX-Register
 ' ADCA_CH0_MUXCTRL   (for Channel 0)
 ' ADCA_CH1_MUXCTRL   (for Channel 1)
 ' ADCA_CH2_MUXCTRL   (for Channel 2)
 ' ADCA_CH3_MUXCTRL   (for Channel 3)

 ' Mux0 = &B00000000 means:
 ' MUXPOS Bits = 000 --> Pin 0 is positive Input for Channel 0
 ' MUXNEG Bits = 00  --> Pin 4 is negative Input for Channel 0   (Pin 4 because of Differential with gain)

 ' Mux1 = &B00001001 means:
 ' MUXPOS Bits = 001 --> Pin 1 is positive Input for Channel 1
 ' MUXNEG Bits = 01  --> Pin 5 is negative Input for Channel 1   (Pin 5 because of Differential with gain)


 ' Reference Voltage = 3,3 Volt/1.6 = 2.06Volt
 ' Prescaler = 256 --> 32MHz/256 = 125KHz

 ' Prescaler = 128 --> 32MHz/128= 250KHz


 ' 12-Bit Mode:
 ' RES = ((Measurement_Value - Vin Neg)/Reference Voltage )* GAIN * 2048 = z.B. (400mv-0mV)/2062mV)* 1 * 2048 = 397




Print #1 , "ADCA_PRESCALER = " ; Bin(ADCA_PRESCALER)
Print #1 , "ADCA_CTRLB = " ; Bin(ADCA_CTRLB)



'Channel 0 Interrupt
On Adca_ch0 Channel_0_ready


'Channel 1 Interrupt
On Adca_ch1 Channel_1_ready







 Enable Adca_ch0 , Lo
 Enable Adca_ch1 , Lo
 Enable Interrupts

 Do
  !nop
Loop Until Sample_count = Channel_1_sample_count  'Loop unitl the second Channel is ready


 Print #1 , " 300 Sample READY"

 'Print Results to COM1
 For X = 10 To 310                                'We don't use the first 10 samples

  Print #1 , Channel_0(x).7 ; " / " ;             'print sign Bit in 8-Bit mode

  If Channel_0(x).7 = 1 Then                      'Sign Bit
    Milli_volt = Channel_0(x) * Mv_per_adc_step_8_bit
     Milli_volt = Milli_volt - 4096               'Additional calculation in 8-Bit Mode (Bit 7 is Sign Bit)
     Print #1 , Fusing(milli_volt , "###,#") ; " " ;
  Else
    Milli_volt = Channel_0(x) * Mv_per_adc_step_8_bit
    Print #1 , Fusing(milli_volt , "###,#") ; " " ;
  End If



  Milli_volt = Channel_1(x) * Mv_per_adc_step_8_bit
  Print #1 , Fusing(milli_volt , "###,#")

  waitms 1
Next



End                                               'end program


'Channel 0 conversion complete INTERRUPT SERVICE ROUTINE
Channel_0_ready:
 Incr Channel_0_sample_count
 Channel_0(channel_0_sample_count) = ADCA_CH0_RESL    'Low Byte of ADC Result
Return

'Channel 1 conversion complete INTERRUPT SERVICE ROUTINE
Channel_1_ready:
 Incr Channel_1_sample_count
 Channel_1(channel_1_sample_count) = ADCA_CH1_RESL     'Low Byte of ADC Result
Return