'-----------------------------------------------------------
'   xm128A1_measure_adc_VALUE_unsigned_mode_pina0_FREE.bas
'               (c) 1995-2011 MCS Electronics
' sample provided by MAK3
'-----------------------------------------------------------
 ' USING ADC IN UNSIGNED SINGLE ENDED MODE WITH FREE RUNNING ADC AND 2 CHANNELS

' Vref = 3.3V/1.6 = 2.0625 Volt
' TOP = 4095 ADC Steps  = Vref - OFFSET
' GND = 172 ADC Steps = measured OFFSET


' (RESULT - OFFSET) * 2.0625V
'----------------------------- = Vin
'   4095



'$regfile = "xm128a1def.dat"
$regfile = "xm32a4def.dat"
$crystal = 32000000                                         '32MHz
$hwstack = 64
$swstack = 40
$framesize = 40


Config Osc = Enabled , 32mhzosc = Enabled
Config Sysclock = 32mhz                                     '--> 32MHz

Dim Measurement As Word
Dim Measurement_minus_offset As Word
Dim Measurement_single As Single
Dim I As Byte

'Serial Interface to PC
Config Com1 = 57600 , Mode = Asynchroneous , Parity = None , Stopbits = 1 , Databits = 8
Open "COM1:" For Binary As #1

Dim Calibration_word As Word
Dim Adca_byte_0 As Byte At Calibration_word Overlay
Dim Adca_byte_1 As Byte At Calibration_word + 1 Overlay

'First we read the Calibration bytes form Signature Row (to get the real 12-Bit)
Adca_byte_0 = Readsig(&H20)
Adca_byte_1 = Readsig(&H21)

'Write factory calibration values to calibration register
Adca_call = Adca_byte_0
Adca_calh = Adca_byte_1

Print #1 ,
Print #1 , "----------START----------"
Print #1 , "Calibration Word = " ; Hex(calibration_word)
Print #1 , "The calibration value &H0444 looks like a standard mean value for calibration !?"



Print #1 , "----We use PINA.0 and PINA.1 for Measurement----"

Config Eeprom = Mapped                                      'When we want to use ERAM Variables with XMEGA

Const Adc_a_offset = 172                                    '<<<<<<<<<<<<Measured OFFSET of ADC from Port A  in UNSIGNED SINGLE ENDED MODE WITH INTVCC AS REFERENCE

'Config Interrupts
Config Priority = Static , Vector = Application , Lo = Enabled

Const Unsigned_single_ended = 0.503663                      '_(2.0625/4095) = 0.50366 mV

Const Sample_count = 311

Dim Channel_0(sample_count) As Word                         'in unsigned single ended mode we can use WORD Variable
Dim Channel_1(sample_count) As Word                         'in unsigned single ended mode we can use WORD Variable

Dim Channel_0_sample_count As Word
Dim Channel_1_sample_count As Word
Dim X As Word

'Channel 0 Interrupt
On Adca_ch0 Channel_0_ready
Enable Adca_ch0 , Lo

'Channel 1 Interrupt
On Adca_ch1 Channel_1_ready
Enable Adca_ch1 , Lo
Enable Interrupts

'setup the ADC-A converter
Config Adca = Free , Convmode = Unsigned , Resolution = 12bit , Dma = Off , Reference = Intvcc , Event_mode = None , _
 Prescaler = 512 , Sweep = Ch01 , _
 Ch0_gain = 1 , Ch0_inp = Single_ended , Mux0 = &B00000000 , _
 Ch1_gain = 1 , Ch1_inp = Single_ended , Mux1 = &B00001001

' ADC Clock = 32MHz/512 = 62.5 KHz

' Mux0 = &B00000000 means in UNSIGNED Mode
' MUXPOS Bits = 000 --> PINA.0
' The MUXNEG Bits are not in use with UNSIGNED MODE  (The negative Level in unsigend single ended mode is Vref/2 - Offset)

' So we use PINA.0 and PINA.1 as positive input. The "negative" Input is GND for both Signals.


 Do
  !nop
Loop Until Sample_count = Channel_1_sample_count            'Loop unitl the second Channel is ready


 Print #1 , " 300 Sample READY"

 'Print Results to COM1
 For X = 10 To 310                                          'We don't use the first 10 samples


   If Channel_0(x) >= Adc_a_offset Then                     'We don't want to subtract more than the OFFSET
       Channel_0(x) = Channel_0(x) - Adc_a_offset
       'Shorter calculation with const (2.0625/4095) = 0.50366 mV
       Measurement_single = Channel_0(x) * Unsigned_single_ended
       Print #1 , "Ch0 = " ; Fusing(measurement_single , "####.#") ; " " ;
   Else
       Channel_0(x) = 0
       'Shorter calculation with const (2.0625/4095) = 0.50366 mV
       Measurement_single = Channel_0(x) * Unsigned_single_ended
       Print #1 , "Ch0 = " ; Fusing(measurement_single , "####.#") ; " " ;
   End If


   If Channel_1(x) >= Adc_a_offset Then                     'We don't want to subtract more than the OFFSET
       Channel_1(x) = Channel_1(x) - Adc_a_offset
       'Shorter calculation with const (2.0625/4095) = 0.50366 mV
       Measurement_single = Channel_1(x) * Unsigned_single_ended
       Print #1 , "Ch1 = " ; Fusing(measurement_single , "####.#") ; " mV"
   Else
       Channel_1(x) = 0
       'Shorter calculation with const (2.0625/4095) = 0.50366 mV
       Measurement_single = Channel_1(x) * Unsigned_single_ended
       Print #1 , "Ch1 = " ; Fusing(measurement_single , "####.#") ; " mV"
  End If



  Waitms 1
Next







End                                                         'end program

'Channel 0 conversion complete INTERRUPT SERVICE ROUTINE
Channel_0_ready:
 Incr Channel_0_sample_count
 Channel_0(channel_0_sample_count) = Adca_ch0_res
Return

'Channel 1 conversion complete INTERRUPT SERVICE ROUTINE
Channel_1_ready:
 Incr Channel_1_sample_count
 Channel_1(channel_1_sample_count) = Adca_ch1_res
Return