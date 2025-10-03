'----------------------------------------------------------------------------------------------------------
'                                      (c) 1995-2013
'                                   RC5-background.bas
' this sample receives RC5 on the background. it will not block your code like getrc5
' it requires a 16 bit timer with input capture. you can not use the timer yourself.
' some processors have multiple 16 bit timers.
'----------------------------------------------------------------------------------------------------------
$regfile = "m88def.dat"

$crystal = 4000000
$baud = 19200
$hwstack = 64
$swstack = 64
$framesize = 64

Config Rc5 = Pinb.0 , timer=1 , MODE=BACKGROUND
'                                              ^--- background interrupt mode
'                               ^--- this must be a 16 bit timer
'              ^---- this is the timer input capture pin

Enable Interrupts                                           ' you must enable interrupts since input capture and overflow are used


Print "RC5 demo"

Do
  If _rc5_bits.4 = 1 Then                                   ' if there is RC5 code received
     _rc5_bits.4 = 0                                        ' you MUST reset this flag in order to receive a new rc5 command

    Print "Address: " ; Rc5_address                         ' Address
    Print "Command: " ; Rc5_command                         ' Command
  End If
Loop