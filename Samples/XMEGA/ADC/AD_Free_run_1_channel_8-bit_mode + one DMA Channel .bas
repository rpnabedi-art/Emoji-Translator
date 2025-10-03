'----------------------------------------------------------------
'                 (c) 1995-2011, MCS Electronics
'         AD_Free_run_1_channel_8-bit_mode + one DMA Channel .bas
' sample written by MAK3
'----------------------------------------------------------------
' Using ADC A in differential input mode with 8-Bit over DMA to SRAM
' Configure the ADC of Port A to use 1 Channel with differential Input and with Gain
' Pina 0 (+) and Pina 4 (-) is used for Channel 0
' In this Example we use 8-Bit Mode
' Bit 7  of the Result Byte is the Sign-Bit  !

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



Print #1 , "----ADC A use DMA Channel 0----"

'For 8 Bit
Const Mv_per_adc_step_8_bit = 16.11                         'Vref = 3,3Volt/1,6 = 2,0625/128 ADC Steps = 16.11328 mV

Const Sample_count = 1000                                   'Number of samples to aquire

Dim Channel_0(sample_count) As Byte                         'Measurement Array for Channel 0

Dim Milli_volt As Single
Dim Channel_0_ready_bit As Bit
Dim Channel_0_sample_count As Word
Dim X As Word
Dim Dma_ready As Bit
Dim Dma_channel_0_error As Bit


' DMA Interrupt
 On Dma_ch0 Dma_ch0_int                                     'Interrupt will be enabled with  Tci = XX in Config DMAX
 Config Dma = Enabled , Doublebuf = Disabled , Cpm = Ch01rr23       ' enable DMA, Double Buffer disabled

 'you can configure 4 DMA channels
Config Dmach0 = Enabled , Burstlen = 1 , Chanrpt = Enabled , Tci = Lo , Eil = Lo , Singleshot = Enabled , _
 Sar = Burst , Sam = Fixed , Dar = None , Dam = Inc , Trigger = &H10 , Btc = Sample_count , Repeat = 1 , Sadr = Varptr(adca_ch0_resl) , Dadr = Varptr(channel_0(1))


' We use DMA Channel 0
' Burstlen = 1  ---> because we use the ADC in 8-Bit Mode
' Channelrepeat is enabled
' TCI = Lo --> Low Level Transaction Complete Interrupt is enabled
' EIL = Lo --> Low Level Error Interrupt is enabled

' Sar = Source Address  reloaded after each burst
' Sam = Fixed  ---> because we use the ADC in 8-Bit Mode

' Dar = No Destination address reload
' Dam = inc (Destination Address (the Array) will be incremented by one)

' Trigger (Trigger base value for ADC A = &H10   +    Trigger offset = &H00 for Channel 0 -->  &H10 )

' BTC = sample_count (Block Transfer Count = sample_count number of bytes)



'-------------------------------------------------------------------------------

 Set Adca_ctrla.1                                           'Flush the ADC Pipeline

'Configure ADC of Port A in FREE running mode
'Enable DMA  Channel 0 and DMA Channel 1
Config Adca = Free , Convmode = Signed , Resolution = 8bit , Dma = Ch01 , _
 Reference = Intvcc , Event_mode = None , Prescaler = 128 , Sweep = Ch0 , _
 Ch0_gain = 1 , Ch0_inp = Diffwgain , Mux0 = &B00000000

 ' Prescaler = 128 --> 31MHz/128 = 250KHz ADC Clock

 ' Mux0 = &B00000000 means:
 ' MUXPOS Bits = 000 --> Pin 0 is positive Input for Channel 0
 ' MUXNEG Bits = 00  --> Pin 4 is negative Input for Channel 0   (Pin 4 because of Differential with gain)


Enable Interrupts
Config Priority = Static , Vector = Application , Lo = Enabled


'----------------------[Mainloop]-----------------------------------------------
 Do

 Loop Until Dma_ready = 1                                   'Loop until DMA is ready
'-------------------------------------------------------------------------------

 Disable Interrupts

 Print #1 , Sample_count ; " Sample READY"

 'Print Results to COM1
 For X = 1 To Sample_count

 ' Print #1 , Channel_0(x).7 ; " / " ;             'print sign Bit in 8-Bit mode = Bit 7

  If Channel_0(x).7 = 1 Then                                'Sign Bit
    Milli_volt = Channel_0(x) * Mv_per_adc_step_8_bit
     Milli_volt = Milli_volt - 4096                         'Additional calculation in 8-Bit Mode (Bit 7 is Sign Bit)
     Print #1 , Fusing(milli_volt , "###,#")
  Else
    Milli_volt = Channel_0(x) * Mv_per_adc_step_8_bit
    Print #1 , Fusing(milli_volt , "###,#")
  End If

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