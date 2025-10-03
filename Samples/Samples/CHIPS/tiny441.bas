'------------------------------------------------------------
'                 ATTINY441 test file
'------------------------------------------------------------
$regfile = "attiny441.dat"
' default the internal osc runs at 1 MHz
$crystal = 8000000                                          'we change the clock div
$baud = 19200
$hwstack = 32
$SWstack = 32
$FrameSize = 32
config CLOCKDIV = 1
config PORTA = OUTPUT
Dim B As Byte

'config com1 = 19200
'(
do
toggle PORTA
waitms 1000
'   porta = 0
'   waitms 1000
loop

')
'The tiny441 has 2 UARTS
'Config WATCHDOG = 2048


Do
   toggle porta
   Print "Hello world"
   Waitms 1000
   print b
   incr b
Loop
'End