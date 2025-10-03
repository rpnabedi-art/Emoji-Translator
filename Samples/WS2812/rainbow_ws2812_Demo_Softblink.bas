'-------------------------------------------------------------------------------
'                   rainbow_ws2812_Demo_Softblink.bas
'This demo show RB_OrColor and RB_AndColor which can be used
'for a flashing LED with a fade effect.
'-------------------------------------------------------------------------------
$Regfile = "m88pdef.dat"
$Crystal=8000000
$hwstack=32
$swstack=16
$framesize=32
Config RAINBOW=1, RB0_LEN=8, RB0_PORT=PORTB,rb0_pin=0
'                                                   ^ connected to pin 0
'                                       ^------------ connected to portB
'                         ^-------------------------- 8 leds on stripe
'              ^------------------------------------- 1 channel

Const Numled=8
Dim MASK as Dword
Dim Fade as Byte

'----[MAIN]---------------------------------------------------------------------
RB_SelectChannel 0          ' select first channel

Do
   For Fade = 0 to 7
      Waitms 20
      Shift MASK , left
      Incr MASK
      RB_ORColor 0 , MASK
      RB_Send
   Next
   For Fade = 0 to 7
      Waitms 20
      Shift MASK , right
      RB_ANDColor 0 , MASK
      RB_Send
   Next
Loop