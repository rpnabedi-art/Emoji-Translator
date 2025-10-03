'-----------------------------------------------------------------------------------------
'name                     : watchd.bas
'copyright                : (c) 1995-2011, MCS Electronics
'purpose                  : demonstrates the watchdog timer
'micro                    : Mega88
'suited for demo          : yes
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------

$RegFile = "m88def.dat"                                     ' specify the used micro
$crystal = 8000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 32                                               ' default use 32 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space
Dim B As Byte
Dim Wdbit As Bit

B = Peek(0)                                                 ' read the wd flag

Print "Watchdog test"
If B.wdrf = 1 Then                                          ' there was a WD overflow
   Wdbit = 1                                                'store the flag
End If

'the watchdog needs a parameter with the number of K cycles
Config Watchdog = 2048                                      'reset after 256K cycles which is 2048 mSec
If Wdbit = 1 Then                                           'just print it now since it is important that CONFIG WATCHDOG runs early as possible
    Print "Micro was reset by Watchdog overflow"
End If

Start Watchdog                                              'start the watchdog timer
Dim I As Word
For I = 1 To 1000
  Waitms 100
  Print I                                                   'print value
  B = Inkey()                                               ' get a key from the serial port
  If B = 65 Then                                            'letter A pressed
     Stop Watchdog                                          ' test if the WD will stop
  Elseif B = 66 Then                                        'letter B pressed
     Config Watchdog = 4096                                 'reconfig to 4096 ms
     Start Watchdog                                         'CONFIG WATCHDOG will disable the WD so start it
  Elseif B = 67 Then                                        'C pressed
     Config Watchdog = 8192                                 ' some have 8 sec timer
     'observe that the WD timer is OFF
  Elseif B = 68 Then                                        'D pressed
     Start Watchdog                                         ' start it
  End If
  'Reset Watchdog
  'you will notice that the for next doesnt finish because of the reset
  'when you unmark the RESET WATCHDOG statement it will finish because the
  'wd-timer is reset before it reaches 2048 msec
  'When you press 'A' you will see that the WD will stop
  'When you press 'B' you will see that the WD will time out after 4 Sec
  'When you press 'C' you will see the WD will stop
  'When you press 'D' you will see the WD will start again timing out after 8 secs
Next
End
