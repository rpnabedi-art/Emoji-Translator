'--------------------------------------------------------------------------------
'name                     : BG30dB_LED.bas
'copyright                : (c) 1995-2013, MCS Electronics
'purpose                  : create a logarithmic LED bar graph dB (VU) meter
'micro                    : AT90S2313-10
'suited for demo          : yes
'commercial addon needed  : no
'use in simulator         : possible
'
' Author     : Ger langezaal
'
'---[ Small program description ]-----------------------------------------------
'
' This program is written to create a logarithmic LED bar graph dB (VU) meter
' with peak-hold and drop-down. Scale range is 30dB in 3dB steps.
' Log conversion is done with the analog comparator on a RC discharge curve.
' C1 is charged each 4mS with PB0 as output on a Timer0 Interrupt.
' Then PB0 is set to AIN0 (analog comparator +input) Timer1 is reset
' and start counting, C1 will be discharged by R1.
' Timer1 is counting until AIN0 < AIN1.
' Analog Comparator Output = ACSR bit 5.
' Timer1 value is in T1 stored for calculation.
'
' Display mode is set with PD6 (pin 11).
'   1 = bar mode
'   0 = dot mode  (for low current applications)

'---[ LED to AVR connections ]--------------------------------------------------
'
'     AVR      Resistor   Cathode   dB
'  Port pin      Ohm      LED nr   Scale
'  PD5   9   >--[680]-->   11       +6
'  PD4   8   >--[680]-->   10       +3
'  PD3   7   >--[680]-->    9        0
'  PD2   6   >--[680]-->    8       -3
'  PD1   3   >--[680]-->    7       -6
'  PD0   2   >--[680]-->    6       -9
'  PB7  19   >--[680]-->    5      -12
'  PB6  18   >--[680]-->    4      -15
'  PB5  17   >--[680]-->    3      -18
'  PB4  16   >--[680]-->    2      -21
'  PB3  15   >--[680]-->    1      -24
'  PB2  14   >--[680]-->    0     infinit
'
' All LED Anodes to +5 Volt
'
'---[ Analog comparator inputs ]------------------------------------------------
'
'
'  Meter DC input >-------[ R2 ]-------> PB1 (AIN1 pin 13)
'                                 |
'             GND <---------||-----
'                           C2
'
'                      ---[ R1 ]---
'             GND <----|          |----> PB0 (AIN0 pin 12)
'                      -----||-----
'                           C1
' R1 = 10k 5%
' R2 = 10k
' C1 = 47nF 5%
' C2 = 47nF
'
'---[ DC input versus Timer1 and Led position ]---------------------------------
'
' Measured Timer1 values for calculation:
' DC input = 3500mV  Timer1 =  192   ( +6dB)
' DC input =  312mV  Timer1 = 1544   (-15dB)   21dB = factor 11.22
' 21dB = 1543 - 192 = 1351 Timer1 counts
'  3dB = 1351 / 7 = 193 Timer1 counts
'
'  Input mv    Timer1   LED pos  dB scale
'    3500        192      11       +6
'    2477        385      10       +3
'    1753        578       9        0
'    1241        771       8       -3
'     879        965       7       -6
'     622       1158       6       -9
'     440       1351       5      -12
'     312       1544       4      -15
'     220       1737       3      -18
'     156       1930       2      -21
'     110       2123       1      -24
'    <110      >2123       0     infinit
'
'---[ Compiler and hardware related statements ]--------------------------------

$regfile = "2313def.dat"                                    'register file for AT90S2313
$crystal = 10000000                                         '10MHz crystal
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 10                                               'default use 10 for the SW stack
$framesize = 40                                             'default use 40 for the frame space

Ddrb = &B11111100                                           'PB0 and PB1 are analog inputs
Portb.0 = 0                                                 'disable input pullup
Portb.1 = 0                                                 'disable input pullup

Ddrd = &B10111111                                           'config PD6 as input
Portd = &B11111111                                          'output high and enable input pullup

Acsr.7 = 0                                                  'enable analog comparator ACSR bit 7 = 0

'---[ Variables ]---------------------------------------------------------------

Dim Peak_pos As Byte
Dim Peak_hold As Byte
Dim Drop_hold As Byte
Dim Led_pos As Word
Dim Bar_pattern As Word
Dim T1 As Word

'---[ Constants ]---------------------------------------------------------------

Const Peak_hold_time = 200
Const Drop_down_time = 40
Const Led_max = 11                                          'Led 0 - 11
Const T1_fs = 192                                           'full scale Timer1 value
Const T1_step = 193                                         '3dB step Timer1 value
Const T1_range = T1_step * Led_max + T1_fs                  'Calculate Timer1 range

Displ_mod Alias Pind.6                                      'display mode 1 = Dot 0 = Bar
Ac_out Alias Acsr.5                                         'analog comparator output = ACSR bit 5

'---[ Timer Configuration ]-----------------------------------------------------

Config Timer0 = Timer , Prescale = 256                      'On Interrupt Timer
Config Timer1 = Timer , Prescale = 8                        'R/C Timer
Config Watchdog = 1024                                      'reset after 1 Sec no reset watchdog
Enable Interrupts
Enable Timer0
Enable Timer1
On Timer0 Dc_input_sample                                   'on overflow timer0 jump to label
Timer0 = 0
Timer1 = 0
Start Timer0
Start Timer1

'---[ Main program loop ]-------------------------------------------------------

Do
  Bar_pattern = &HFFFF                                      'set all bits

  If Displ_mod = 1 Then                                     'bar display mode
    Bar_pattern = Lookup(led_pos , Bar_mode)
  Else                                                      'dot display mode
    Bar_pattern.led_pos = 0                                 'reset dot bit
  End If

  Bar_pattern.peak_pos = 0                                  'reset peak bit

  Portd.5 = Bar_pattern.11                                  'led 11 = bit 11
  Portd.4 = Bar_pattern.10
  Portd.3 = Bar_pattern.9
  Portd.2 = Bar_pattern.8
  Portd.1 = Bar_pattern.7
  Portd.0 = Bar_pattern.6
  Portb.7 = Bar_pattern.5
  Portb.6 = Bar_pattern.4
  Portb.5 = Bar_pattern.3
  Portb.4 = Bar_pattern.2
  Portb.3 = Bar_pattern.1
  Portb.2 = Bar_pattern.0                                   'led 0 = bit 0
Loop

'-------------------------------------------------------------------------------
End
'-------------------------------------------------------------------------------

'---[ Interrupt Service Routine on Timer0 overflow  ]---------------------------

Dc_input_sample:
  Timer0 = 100                                              'preset Timer0 for sample rate of 4mS

  Ddrb.0 = 1                                                'set AIN0 as PB0 output
  Portb.0 = 1                                               'set PB0 high to charge C1
  Waitus 200                                                'wait for charge complete
  Ddrb.0 = 0                                                'reset PB0 as AIN0 analog input
  Portb.0 = 0                                               'disable AIN0 pullup

  Timer1 = 0                                                'clear R/C Timer1
  Bitwait Ac_out , Reset                                    'wait for AIN0 < AIN1
  T1 = Timer1                                               'read Timer1 value

  If T1 < T1_fs Then                                        'check T1 low limit
    T1 = T1_fs                                              'T1 clipping
  Elseif T1 > T1_range Then                                 'check T1 high limit
    T1 = T1_range                                           'T1 clipping
  End If

  Led_pos = T1_range - T1                                   'calculate led position
  Led_pos = Led_pos \ T1_step                               'led_pos = 0 - 11

  If Led_pos >= Peak_pos Then                               'new peak value
    Peak_pos = Led_pos                                      'store peak value
    Peak_hold = Peak_hold_time                              'preset peak hold timer
  Else
    If Peak_hold > 0 Then
      Decr Peak_hold
    Else
      If Drop_hold > 0 Then
        Decr Drop_hold
      Else
        Drop_hold = Drop_down_time                          'preset drop down timer
        If Peak_pos > 0 Then Decr Peak_pos                  'drop down one position
      End If
    End If
  End If
  Reset Watchdog
Return

'---[ Led Bar pattern lookup data ]---------------------------------------------

'      Led 11......... 0
Bar_mode:
Data &B1111111111111110%                                    'Word constants must end with the %-sign
Data &B1111111111111100%
Data &B1111111111111000%
Data &B1111111111110000%
Data &B1111111111100000%
Data &B1111111111000000%
Data &B1111111110000000%
Data &B1111111100000000%
Data &B1111111000000000%
Data &B1111110000000000%
Data &B1111100000000000%
Data &B1111000000000000%

'-------------------------------------------------------------------------------