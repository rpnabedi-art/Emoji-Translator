'------------------------------------------------------------
'                 ATTINY841 test file
'------------------------------------------------------------
$regfile = "attiny841.dat"
' default the internal osc runs at 1 MHz but we change it later
$crystal = 8000000
$baud = 19200
$hwstack = 32
$SWstack = 32
$FrameSize = 32
config CLOCKDIV = 1
config PORTA = OUTPUT
Dim B As Byte

print "signature table"
for b = 0 to &H32
  print hex(b) ; "-" ; hex(ReadSig(b))
Next

Config Adc = Free , Prescaler = 8 , Reference = INTERNAL_1.1
start ADC

Do
   print GetADC(&B1100)                                     'temp

   toggle porta
   Print "Hello world " ; b
   Waitms 1000
   incr b
Loop