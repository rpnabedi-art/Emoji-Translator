'--------------------------------------------------------------------------------
'name                     : BG30dB_LCD.bas
'copyright                : (c) 1995-2013, MCS Electronics
'purpose                  : create a logarithmic LCD bar graph dB (VU) meter
'micro                    : AT90S2313-10
'suited for demo          : yes
'commercial addon needed  : no
'use in simulator         : possible
'
' Author     : Ger langezaal
'
'---[ Small program description ]-----------------------------------------------------
'
' This program is written to create a logarithmic LCD bar graph dB (VU) meter
' on a 16x2 LCD display with peak-hold and drop-down.
' Custom characters are designed with the LCD Designer in BASCOM-AVR.
' The upper row is a scale from +6dB to -24dB with 2dB markers.
' The lower row is the bar graph with peak-hold and drop-down.
' Log conversion is done with the analog comparator on a RC discharge curve.
' C1 is charged every 4mS with PB0 as output on a Timer0 Interrupt.
' Then PB0 is set to AIN0 (analog comparator +input) Timer1 is reset
' and start counting, C1 will be discharged by R1.
' Timer1 is counting until AIN0 < AIN1.
' Analog Comparator Output = ACSR bit 5.
' Timer1 value is stored in T1 for calculation.
'
'---[ LCD display ]-------------------------------------------------------------
'
' Display     : LCD 16 x 2
' Scale range : 30dB (+6dB to -24dB)
' Resolution  : 2dB
'
' The LCD display is connected in PIN mode.
' See also BASCOM-AVR Index:
'     'Attaching an LCD Display' and 'AT90S2313' for pin numbers
'
'   LCD pin  -  AVR
'
'   Vss  1   -  GND
'   Vdd  2   -  VCC +5 Volt
'   Vo   3   -  0-VCC     Contrast
'   RS   4   -  PB2
'   RW   5   -  GND
'   E    6   -  PB3
'   Db0  7   -  GND
'   Db1  8   -  GND
'   Db2  9   -  GND
'   Db3  10  -  GND
'   Db4  11  -  PB4
'   Db5  12  -  PB5
'   Db6  13  -  PB6
'   Db7  14  -  PB7
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
'---[ DC input versus Timer1 and Bar position ]---------------------------------
'
' Measured Timer1 values for calculation:
' DC input = 3500mV  Timer1 =  192   ( +6dB)
' DC input =  350mV  Timer1 = 1482   (-14dB)   20dB = factor 10
' 20dB = 1482 - 192 = 1290 Timer1 counts
'  2dB = 1290 / 10 = 129 Timer1 counts
'
' Calculated Values:
'  Input mV    Timer1   dB Scale   Bar pos
'   3500         192       +6        16
'   2780         321       +4        15
'   2208         450       +2        14
'   1754         579        0        13
'   1393         708       -2        12
'   1106         837       -4        11
'    879         966       -6        10
'    698        1095       -8         9
'    554        1224       -10        8
'    440        1353       -12        7
'    350        1482       -14        6
'    278        1611       -16        5
'    221        1740       -18        4
'    175        1869       -20        3
'    139        1998       -22        2
'    111        2127       -24        1
'   <111       >2127     infinit     1/2 Bar
'
'---[ Compiler and hardware related statements ]--------------------------------

$regfile = "2313def.dat"                                    'register file for AT90S2313
$crystal = 10000000                                         '10MHz crystal
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 10                                               'default use 10 for the SW stack
$framesize = 40                                             'default use 40 for the frame space

Config Lcdbus = 4
Config Lcd = 16x2
Config Lcdpin = PIN , Db4 = PORTB.4 , Db5 = PORTB.5 , Db6 = PORTB.6 , Db7 = PORTB.7 , E = PORTB.3 , Rs = PORTB.2

Ddrb = &B11111100                                           'set PB0 and PB1 as inputs
Portb.0 = 0                                                 'disable PB0 input pullup
Portb.1 = 0                                                 'disable PB1 input pullup

Ddrd = &B10111111                                           'config PD6 as input
Portd = &B11111111                                          'output high and enable input pullup

Acsr.7 = 0                                                  'enable analog comparator (bit 7 = 0)

'---[ Variables ]---------------------------------------------------------------

Dim Char_pos As Byte
Dim Peak_pos As Byte
Dim Peak_hold As Byte
Dim Drop_hold As Byte
Dim Bar_len As Word
Dim T1 As Word

'---[ Constants ]---------------------------------------------------------------

Const Peak_hold_time = 250
Const Drop_down_time = 50
Const Char_max = 16                                         'number of LCD characters (one row)
Const T1_fs = 192                                           'full scale Timer1 value
Const T1_step = 129                                         '2dB step Timer1  value
Const T1_range = T1_step * Char_max + T1_fs                 'Calculate Timer1 range

Ac_out Alias Acsr.5                                         'analog comparator output = ACSR bit 5

'---[ Custom LCD characters ]---------------------------------------------------

Deflcdchar 0 , 12 , 18 , 18 , 18 , 12 , 32 , 04 , 04        ' 0
Deflcdchar 1 , 02 , 06 , 02 , 02 , 07 , 32 , 32 , 04        ' 1
Deflcdchar 2 , 06 , 09 , 02 , 04 , 15 , 32 , 32 , 04        ' 2
Deflcdchar 3 , 32 , 32 , 07 , 32 , 32 , 32 , 32 , 04        ' -
Deflcdchar 4 , 32 , 32 , 32 , 32 , 32 , 32 , 32 , 04        ' Scale marker
Deflcdchar 5 , 27 , 27 , 27 , 27 , 27 , 27 , 27 , 32        ' bar
Deflcdchar 6 , 24 , 24 , 24 , 24 , 24 , 24 , 24 , 32        ' 1/2 left bar
Deflcdchar 7 , 06 , 05 , 14 , 21 , 14 , 32 , 32 , 04        ' dB
Cls                                                         'select LCD data RAM
Cursor Off

'---[ Timer Configuration ]-----------------------------------------------------

Config Timer0 = Timer , Prescale = 256                      'On Interrupt Timer
Config Timer1 = Timer , Prescale = 8                        'R/C Timer
Config Watchdog = 2048
Enable Interrupts
Enable Timer0
Enable Timer1
On Timer0 Dc_input_sample                                   'goto subroutine
Timer0 = 0
Timer1 = 0
Start Timer0
Start Timer1

'---[ Show software revision ]--------------------------------------------------

Lcd "BAR GRAPH 30dB"
Locate 2 , 1
Lcd "METER  Rev.1.0"
Waitms 1000
Cls

'---[ Draw dB Scale with custom characters ]------------------------------------

Locate 1 , 1 : Lcd Chr(3) ; Chr(2) ; Chr(0) ; Chr(4) ; Chr(4) ; Chr(3)
Locate 1 , 7 : Lcd Chr(1) ; Chr(0) ; Chr(4) ; Chr(4) ; Chr(4) ; Chr(4)
Locate 1 , 13 : Lcd Chr(0) ; Chr(4) ; Chr(4) ; Chr(7)

'---[ Main program loop ]-------------------------------------------------------

Do
  Locate 2 , 1                                              'set LCD first character position

  If Bar_len = 0 Then
    If Peak_pos = 0 Then Lcd Chr(6)                         'print 1/2 left bar for infinit
  End If

  For Char_pos = 1 To Char_max                              'number of characters
    If Char_pos <= Bar_len Then                             'print one bar
      Lcd Chr(5)                                            '
    Elseif Char_pos = Peak_pos Then                         'print peak bar
      Lcd Chr(5)                                            '
    Else
      Lcd Chr(32)                                           'print spaces to fill row
    End If
  Next
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

  Bar_len = T1_range - T1                                   'calculate bar length
  Bar_len = Bar_len \ T1_step                               '

  If Bar_len >= Peak_pos Then                               'new peak value
    Peak_pos = Bar_len                                      'store peak value
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

'-------------------------------------------------------------------------------