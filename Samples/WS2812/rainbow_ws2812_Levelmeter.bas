'-------------------------------------------------------------------------------
'                   rainbow_ws2812_Levelmeter.bas
'
' This example demonstrate the switching between two Rainbow-Stripes while simulating
' a simple kind of an stereo levelmeter and the use of some RB_statements.
'
'-------------------------------------------------------------------------------
$Regfile = "m88pdef.dat"
$Crystal=8000000
$hwstack=40
$swstack=16
$framesize=32


Config RAINBOW= 2, RB0_LEN=8, RB0_PORT=PORTB,rb0_pin=0  , RB1_LEN=8, RB1_PORT=PORTB,rb1_pin=1
Dim n as Byte
Dim Color as DWord
Dim CH as Byte
Dim LEFT_Level as Byte ,  Left_Level_OLD as Byte
Dim Right_Level as Byte , Right_Level_OLD as Byte
Const Channels = 2
Const Backcolor = &H000005

'----[MAIN]---------------------------------------------------------------------
Color = Backcolor
For ch = 0 to Channels -1
   Rb_SelectChannel Ch
   RB_Fillcolors Color
   Rb_SetTableColor 0,0
   RB_send
Next
Do
   incr n:  n = n and &H30   'n counts from 0 to 63
   If n = 0 then Gosub Get_Level   'Read signal
   'Switch channel
   toggle Ch
   Rb_SelectChannel Ch
   Waitms 40
   If ch = 0 then  'Channel 0
      If left_level_old <  left_level then
         incr Left_level_old
      ElseIf Left_level_old > Left_level then
         Decr Left_level_old
      End if
      RB_Fillcolors Color
      Rb_SetTableColor Left_level_old ,0
   Else  'Channel 1
      If right_level_old <  right_level then
         incr right_level_old
      ElseIf right_level_old > right_level then
         Decr right_level_old
      End if
      RB_Fillcolors Color
      Rb_SetTableColor right_level_old ,0
   end if
   RB_Send
Loop

Get_Level:
   Left_Level  = rnd(7)
   Right_Level = rnd(7)
Return

Rainbow_Colors:
   Data 100,50,0     'orange
