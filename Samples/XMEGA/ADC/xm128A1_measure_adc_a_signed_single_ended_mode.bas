'-----------------------------------------------------------
'     xm128A1_measure_adc_a_signed_single_ended_mode.bas
'               (c) 1995-2011 MCS Electronics
' sample provided by MAK3
'-----------------------------------------------------------

' With this example we measure in SIGNED SINGLE ENDED MODE

' We use PINA.0 as analog input

' In SIGNED SINGLE ENDED MODE the negative Level of the Measurment it tied to GND.

' PINA.0 ----------->+------+
'                    |ADC A |
' GND (internally)-->+------+

' Reference Voltage = 3.3V/1.6 = 2.0625




'------------> 2048  +
'                    | --> 2048
'------------> GND   +

'-------------> -2048


' ADC Step = 2.0625/2048  = 1.00708 mV

'$regfile = "xm128a1def.dat"
$regfile = "xm32a4def.dat"
$crystal = 32000000                               '32MHz
$hwstack = 64
$swstack = 40
$framesize = 40


Config Osc = Enabled , 32mhzosc = Enabled
Config Sysclock = 32mhz                           '--> 32MHz

Dim Measurement As Word
Dim Single_measurment As Single
Dim I As Byte

Const Adc_step = 1.00708                          'mV

'Serial Interface to PC
Config Com1 = 57600 , Mode = Asynchroneous , Parity = None , Stopbits = 1 , Databits = 8
Open "COM1:" For Binary As #1

Print #1 , "-----------------------------------"

'Config Interrupts
Config Priority = Static , Vector = Application , Lo = Enabled

'setup the ADC-A converter
Config Adca = Single , Convmode = Signed , Resolution = 12bit , Dma = Off , Reference = Intvcc , Event_mode = None , Prescaler = 512 , _
Ch0_gain = 1 , Ch0_inp = Single_ended , Mux0 = &B00000000       'Setup Channel 0 in Single Ended Mode


' ADC Clock = 32MHz/512 = 62.5 KHz

' Mux0 = &B00000000 means in SIGNED SINGLE ENDED MODE:
' MUXPOS Bits = 000 --> PINA.0
' The MUXNEG Bits are not in use with SIGNED SINGLE ENDED MODE  (The negative Level it GND (internally))

Waitms 500


Measurement = Getadc(adca , 0 , &B00000000)       'ADC A, Channel 0 , MUX = &B00000000 --> PINA.0
Print #1 , "ADC steps = " ; Measurement
Single_measurment = Measurement * Adc_step
Print #1 , Fusing(single_measurment , "##.#") ; " mV"


Measurement = Getadc(adca , 0 , &B00000000)       'ADC A, Channel 0 , MUX = &B00000000 --> PINA.0
Print #1 , "ADC steps = " ; Measurement
Single_measurment = Measurement * Adc_step
Print #1 , Fusing(single_measurment , "##.#") ; " mV"





End                                               'end program
