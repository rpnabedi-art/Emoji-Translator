'*******************************************************************************
'
' Module:   TB1LED.BAS
'
' Revision:   1.01
'
' Date: 12/04/2006
'
' Description:  LED test of TB-1 board
'
'*******************************************************************************
' ATMEGA 2560
$regfile = "m2560def.dat"
$hwstack=64
$swstack=64
$FrameSize=64
'{TOOLKITDIR}\bascomp {SOURCEFILE} hw=64 ss=64 fr=64 chip=43
'*******************************************************************************
$crystal = 14745600
'
'CONFIGURE PORTB
Ss Alias Portb.0
Sck Alias Portb.1
Mosi Alias Portb.2
Miso Alias Portb.3
YELLOW_LED Alias Portb.4
GREEN_LED Alias Portb.5
RED_LED  Alias Portb.6
BUZZER Alias Portb.7
Const Ddrb_init = &HF0                        '1-output,0-input
Const Portb_init = &HF0
'
Const LED_DELAY = 250
'
'CONFIGURE PORT B
Ddrb = Ddrb_init
Portb = Portb_init
Do
'        RED LED
   Reset RED_LED
   WaitMs LED_DELAY
   Set RED_LED
   WaitMs LED_DELAY
'        YELLOW LED
   Reset YELLOW_LED
   WaitMs LED_DELAY
   Set YELLOW_LED
   WaitMs LED_DELAY
'        GREEN LED
   Reset GREEN_LED
   WaitMs LED_DELAY
   Set GREEN_LED
   WaitMs LED_DELAY
Loop
End
