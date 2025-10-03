
' Using the new config powermode = Idle function with ATTINY13

' Idle: This sleep mode basically halts clkCPU and clkFLASH, while allowing the other clocks to run.

' Used Bascom-AVR Version 2.0.7.3

' Fuse Bits:
' Disable DWEN (Debug Wire) Fuse Bit
' Disable Brown-Out Detection in Fuse Bits
' Disable Watchdog in Fuse Bits


$regfile = "attiny13.dat"
$crystal = 9600000                                '9.6MHz
$hwstack = 10
$swstack = 0
$framesize = 24


On Int0 Int0_isr                                  'INT0 will be the wake-up source for Idle Mode
Config Int0 = Low Level
Enable Int0


'###############################################################################
Do
   Wait 3                                         ' now we have 3 second to measure the Supply Current in Active Mode

   Enable Interrupts

   ' Now call Idle function
   Config Powermode = Idle

   'Here you have time to measure Idle current consumption until a Low Level on Portb.1 which is the Idle wake-up

Loop
'###############################################################################
End


Int0_isr:
   ' wake_up
Return