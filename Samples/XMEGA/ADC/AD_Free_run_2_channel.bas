'-----------------------------------------------------------
'                AD_Free_run_2_channel.bas
'               (c) 1995-2011 MCS Electronics
' sample provided by MAK3
'-----------------------------------------------------------

' Configure the ADC of Port A to use 2 Channels with differential Input and with Gain
' Pina 0 (+) and Pina 4 (-) is used for Channel 0
' Pina 1 (+) and Pina 5 (-) is used for Channel 1


$regfile = "xm128a1def.dat"
'$regfile = "xm32a4def.dat"
$crystal = 32000000                                         '32MHz
$hwstack = 64
$swstack = 40
$framesize = 40


Config Osc = Enabled , 32mhzosc = Enabled
Config Sysclock = 32mhz                                     '--> 32MHz

'Serial Interface to PC
Config Com5 = 57600 , Mode = Asynchroneous , Parity = None , Stopbits = 1 , Databits = 8
Open "COM5:" For Binary As #1

Config Dp = Comma                                           'comma is used as a separator (for FUSING function)
'Config Dp = "."                                   'dot is used as a separator (for FUSING function). You also need to change this "###.#" in the fusing funtion


Print #1 , "-----------------START-------------------"


'Config Interrupts
Config Priority = Static , Vector = Application , Lo = Enabled

Config Eeprom = Mapped                                      'when using EEPROM , add this config command

Const Mv_per_adc_step = 1.007                               'Vref = 3,3Volt/1,6 = 2,0625/2048 ADC Steps = 1.007 mV
Const Sample_count = 301

Dim Channel_0(sample_count) As Integer                      'Measurement Array for Channel 0
Dim Channel_1(sample_count) As Integer                      'Measurement Array for Channel 1



Dim Milli_volt As Single

Dim Channel_0_ready_bit As Bit
Dim Channel_1_ready_bit As Bit

Dim Channel_0_sample_count As Word
Dim Channel_1_sample_count As Word
Dim X As Word

'Configure ADC of Port A in FREE running mode
Config Adca = Free , Convmode = Signed , Resolution = 12bit , Dma = Off , _
 Reference = Intvcc , Event_mode = None , Prescaler = 256 , Sweep = Ch01 , _
 Ch0_gain = 1 , Ch0_inp = Diffwgain , Mux0 = &B00000000 , _
 Ch1_gain = 1 , Ch1_inp = Diffwgain , Mux1 = &B00001001

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


 ' RES = ((Measurement_Value - Vin Neg)/Reference Voltage )* GAIN * 2048 = z.B. (400mv-0mV)/2062mV)* 1 * 2048 = 397


'Here you can check if the Mux Register are written correct !
Print #1 , "ADCA_CH0_MUXCTRL = " ; Bin(adca_ch0_muxctrl)
Print #1 , "ADCA_CH1_MUXCTRL = " ; Bin(adca_ch1_muxctrl)


'Channel 0 Interrupt
On Adca_ch0 Channel_0_ready
Enable Adca_ch0 , Lo

'Channel 1 Interrupt
On Adca_ch1 Channel_1_ready
Enable Adca_ch1 , Lo
Enable Interrupts



 Do


  If Channel_0_ready_bit = 1 Then                           'Channel 2 conversion complet interrupt ?
     Channel_0_ready_bit = 0
     Set Adca_ch0_intflags.0                                'Clear Int Flag CH 0
     Channel_0(channel_0_sample_count) = Adca_ch0_res
  End If

  If Channel_1_ready_bit = 1 Then                           'Channel 2 conversion complet interrupt ?
     Channel_1_ready_bit = 0
     Set Adca_ch1_intflags.0                                'Clear Int Flag CH 0
     Channel_1(channel_1_sample_count) = Adca_ch1_res
  End If


Loop Until Sample_count = Channel_1_sample_count            'Loop unitl the second Channel is ready


 Print #1 , " 300 Sample READY"
 'Disable Channel 0 Interrupt on comversion complete
 Adca_ch0_intctrl = &B0000_00_00                            'OFF Int on Conversion complete  (CH 0)
 Adca_ch1_intctrl = &B0000_00_00                            'OFF Int on Conversion complete  (CH 1)
 'Disable Free Running mode
 Reset Adca_ctrlb.3
 'Disable ADC A
 Reset Adca_ctrla.0


 'Print Results to COM1
 For X = 1 To 300
  Milli_volt = Channel_0(x) * Mv_per_adc_step
  Print #1 , Fusing(milli_volt , "###,#") ; " " ;
  Milli_volt = Channel_1(x) * Mv_per_adc_step
  Print #1 , Fusing(milli_volt , "###,#")
  Waitms 1
Next



End                                                         'end program


'Channel 0 conversion complete INTERRUPT SERVICE ROUTINE
Channel_0_ready:
 Incr Channel_0_sample_count
 Set Channel_0_ready_bit
Return

'Channel 1 conversion complete INTERRUPT SERVICE ROUTINE
Channel_1_ready:
 Incr Channel_1_sample_count
 Set Channel_1_ready_bit
Return