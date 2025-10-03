

'Used BASCOM VERSION 2.0.2.0

'SYSTEM CLOCK CONTROL WITH ATXMEGA32A4

'PLL FACTOR 8
'Clock Source = internal 32MHz (which is divided in hardware by 4) = 8MHz

'8MHz * PLL Factor 8 = 64MHz Clock feed in the Clock distribution system

'CLKper4 = 64MHz   Modules that can run four times the CPU Clock frequency can use the Peripheral 4x clocks.
'                  The High-Resolution (Hi-Res) Extension can be used to increase the resolution of the waveform
'                  generation output from a Timer/Counter by four
'                  Or you can use it with The Advanced Waveform Extension (AWeX)

'CLKper2 = 64MHz   Modules that can run at two times the CPU Clock frequency can use the Peripheral 2x  clocks.
'                  The External Bus Interface can run with CLKper2 (max. 64MHz)

'CLKcpu = CLKper = 32MHz -->  $crystal = 32000000   (with Prescalebc = 1_2 it is 64MHz/2 = 32MHz)

$regfile = "xm32a4def.dat"
$crystal = 32000000                                         'CLKcpu = CLKper = 32MHz
$hwstack = 64
$swstack = 64
$framesize = 64


'----------generate a 64 MHz system clock by use of the PLL  (32MHz/4 * PLL Factor 8 = 64MHz)
'The Internal 32MHz Clock is automatically divided by 4 which result in 8MHz. Therefore 8MHz * 8MHz = 64MHz

Config Osc = Disabled , 32mhzosc = Enabled , 32khzosc = Enabled       'Enable the 32MHz and 32.768KHz Oscillator

Bitwait Osc_status.1 , Set                                  'Check if 32MHz Oscillator is ready
Bitwait Osc_status.2 , Set                                  'Check if internal 32.768 KHz Oscillator is ready

'Init and enable the DFLL (Digital Frequency Locked Loop) for automatic run-time calibration of the internal 32MHz Oscillator
Osc_dfllctrl = &B00000000                                   'The internal 32.768 KHz Oscillator is used for calibration
Set Dfllrc32m_ctrl.0                                        'Enable DFLL and autocalibration


'Set the Multiplication factor and select the clock Reference for the PLL
Osc_pllctrl = &B10_0_01000                                  ' 32MHz clock Source and Multiplication factor = 16
                '^    '^
                '^    'Multiplication factor = 8
                '^
                'PLL Source = 32MHz internal Oscillator (divided by 4 in hardware)




                         '
Set Osc_ctrl.4                                              ' PLL enable

Bitwait Osc_status.4 , Set                                  'Check if PLL is ready

Config Sysclock = Pll , Prescalea = 1 , Prescalebc = 1_2    ' configure the systemclock ---> use PLL
Waitms 2



'CLOCK DISTRIBUTION
'                                                8*8=                     CLKper4 =                CLKper2 =                 CLKcpu = CLKper =  $crystal = 32000000
'+-------------------+     +-----------------+   64MHz   +--------------+ 64MHz  +---------------+   64MHz   +-------------+   32MHz
'|32MHz/4 = 8 MHz    |---->| PLL = factor 8  |---------->|Prescalea = 1 |------->|Prescaleb = 1  |---------->|Prescalec = 2|--------------->>>>>>
'+-------------------+     +-----------------+           +--------------+        +---------------+           +-------------+



'Setup Interrupt
Config Priority = Static , Vector = Application , Lo = Enabled


'Configure UART for communication with PC (USB)
Config Com1 = 19200 , Mode = Asynchroneous , Parity = None , Stopbits = 1 , Databits = 8


Dim Count As Byte


Main:

Do
 Incr Count
 Print "Test " ; Count

 Wait 1
Loop

End                                                         'end program