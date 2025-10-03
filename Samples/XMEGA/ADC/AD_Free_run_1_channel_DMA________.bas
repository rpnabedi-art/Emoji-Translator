'----------------------------------------------------------------
'                 (c) 1995-2011, MCS Electronics
'                AD_Free_run_1_channel_DMA________.bas
' sample written by MAK3
'----------------------------------------------------------------

' You need BASCOM-AVR Version 2.0.6.0 to run this example

' We use DMA Channel 0 to transfer the ADC Result Values to SRAM (Array)

' ADC Prescaler = 16 --> 2MHz ADC Clock !

' 1500 Measurement Values (means 3000 Byte of SRAM)


' Configure the ADC of Port A to use 1 Channels with differential Input and with Gain (12-Bit Mode)
' Pina 0 (+) and Pina 4 (-) is used for Channel 0


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


Print #1 , "--ADC A over DMA in 12-Bit Mode--"

Config Eeprom = Mapped                                      'when using EEPROM , add this config command

Const Mv_per_adc_step = 1.007                               'Vref = 3,3Volt/1,6 = 2,0625/2048 ADC Steps = 1.007

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Const Sample_count = 1500                                   'Number of 12-Bit Samples (Measurement Values)
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


Dim Channel_0(sample_count) As Integer                      'Measurement Array for Channel 0
Dim Milli_volt As Single
Dim Dma_ready As Bit
Dim Dma_channel_0_error As Bit
Dim Channel_0_sample_count As Word
Dim X As Word


' DMA Interrupt
On Dma_ch0 Dma_ch0_int                                      'Interrupt will be enabled with  Tci = XX in Config DMAX
Config Dma = Enabled , Doublebuf = Disabled , Cpm = Ch01rr23       ' enable DMA, Double Buffer disabled

' DMA Channel 0 is used here
Config Dmach0 = Enabled , Burstlen = 2 , Chanrpt = Enabled , Tci = Lo , Eil = Lo , Singleshot = Enabled , _
 Sar = Burst , Sam = Inc , Dar = None , Dam = Inc , Trigger = &H10 , Btc = 3000 , Repeat = 1 , Sadr = Varptr(adca_ch0_res) , Dadr = Varptr(channel_0(1))


' We use DMA Channel 0
' Burstlen = 2 (We use here 12-Bit Mode so we need 2Bytes from Source Address = ADC A)
' Channelrepeat is enabled

' BTC = 2000 (must be 2X of Sample_count because of 2 Bytes per Measurement Value)

' TCI = Lo --> Low Level Transaction Complete Interrupt is enabled
' EIL = Lo --> Low Level Error Interrupt is enabled

' Sar = Source Address  reloaded after each burst
' Sam = incremented (Low Byte and High Byte of Measurement Value)

' Dar = No Destination address reload
' Dam = inc (Destination Address (the Array) will be incremented by one)

' Trigger (Trigger base value for ADC A = &H10   +    Trigger offset = &H00 for Channel 0 -->  &H10 )


'Configure ADC of Port A in FREE running mode
Config Adca = Free , Convmode = Signed , Resolution = 12bit , Dma = Ch01 , _
 Reference = Intvcc , Event_mode = None , Prescaler = 16 , Sweep = Ch0 , _
 Ch0_gain = 1 , Ch0_inp = Diffwgain , Mux0 = &B00000000


 ' With MuxX you can set the  MUX-Register
 ' ADCA_CH0_MUXCTRL   (for Channel 0)
 ' ADCA_CH1_MUXCTRL   (for Channel 1)

 ' Mux0 = &B00000000 means:
 ' MUXPOS Bits = 000 --> Pin 0 is positive Input for Channel 0
 ' MUXNEG Bits = 00  --> Pin 4 is negative Input for Channel 0   (Pin 4 because of Differential with gain)

 ' Mux1 = &B00001001 means:
 ' MUXPOS Bits = 001 --> Pin 1 is positive Input for Channel 1
 ' MUXNEG Bits = 01  --> Pin 5 is negative Input for Channel 1   (Pin 5 because of Differential with gain)


 ' Reference Voltage = 3,3 Volt/1.6 = 2.06Volt
 ' Prescaler = 16 --> 32MHz/16 = 2MHz


 ' RES = ((Measurement_Value - Vin Neg)/Reference Voltage )* GAIN * 2048 = z.B. (400mv-0mV)/2062mV)* 1 * 2048 = 397

Config Priority = Static , Vector = Application , Lo = Enabled
Enable Interrupts

'----------------------[Mainloop]-----------------------------------------------
 Do

 Loop Until Dma_ready = 1
'-------------------------------------------------------------------------------

 Print #1 , Sample_count ; " Sample READY"
 'Disable Channel 0 Interrupt on comversion complete
 Adca_ch0_intctrl = &B0000_00_00                            'OFF Int on Conversion complete  (CH 0)

 'Disable Free Running mode
 Reset Adca_ctrlb.3
 'Disable ADC A
 Reset Adca_ctrla.0


 'Print Results to COM1
 For X = 1 To Sample_count
  Milli_volt = Channel_0(x) * Mv_per_adc_step
  Print #1 , Fusing(milli_volt , "###,#")
  Waitms 1
Next



End                                                         'end program


'----------------------[Interrupt Service Routines]-----------------------------

 ' Dma_ch0_int is for DMA Channel ERROR Interrupt A N D for TRANSACTION COMPLETE Interrupt
 ' Which Interrupt fired must be checked in Interrupt Service Routine
 Dma_ch0_int:

    If Dma_intflags.0 = 1 Then                              'Channel 0 Transaction Interrupt Flag
       Set Dma_intflags.0                                   'Clear the Channel 0 Transaction Complete flag
       Set Dma_ready
    End If

    If Dma_intflags.4 = 1 Then                              'Channel 0 ERROR Flag
       Set Dma_intflags.4                                   'Clear the flag
       Set Dma_channel_0_error                              'Channel 0 Error
    End If

 Return