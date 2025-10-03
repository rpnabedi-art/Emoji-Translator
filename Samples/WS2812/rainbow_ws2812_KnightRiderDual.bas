'-------------------------------------------------------------------------------
'                   rainbow_ws2812_KnightriderDual.bas
'                      based on sample from Galahat
'-------------------------------------------------------------------------------
$Regfile = "m88pdef.dat"
$Crystal = 8000000
$hwstack = 40
$swstack = 16
$framesize = 32

Config RAINBOW=1, RB0_LEN=8, RB0_PORT=PORTB,rb0_pin=0
'                                                   ^ connected to pin 0
'                                       ^------------ connected to portB
'                         ^-------------------------- 8 leds on stripe
'              ^------------------------------------- 1 channel


'Global Color-variables
Dim Color(3) as Byte
R alias Color(_base) : G alias Color(_base + 1) : B alias Color(_base + 2)

'CONST
const numLeds=8

'----[MAIN]---------------------------------------------------------------------
Dim n as Byte

RB_SelectChannel 0          ' select first channel
R = 50 : G = 0 : B = 100    ' define a color
RB_SetColor 0 , color(1)    ' update led on the left
RB_SetColor 7 , color(1)    ' update led on the right
RB_Send

Do
   For n = 1 to Numleds/2 - 1
      rb_Shiftright 0 , Numleds/2  'shift to the right
      rb_Shiftleft 4 , Numleds/2   'shift to the left all leds except the last one
      Waitms 100
      RB_Send
   Next
   For n = 1 to Numleds/2 - 1
      rb_Shiftleft 0 , Numleds/2   'shift to the left all leds except the last one
      rb_Shiftright 4 , Numleds/2  'shift to the right
      Waitms 100
      RB_Send
   Next
   waitms 500                    'wait a bit
Loop

