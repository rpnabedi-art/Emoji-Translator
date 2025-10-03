'-----------------------------------------------------------------------------------------
'name                     : encoder.bas
'copyright                : (c) 1995-2013, MCS Electronics
'purpose                  : demonstration of encoder function
'micro                    : Mega48
'suited for demo          : yes
'commercial addon needed  : no
'An encoder has 2 outputs and a ground
'We connect the outputs to pinb.0 and pinb.1
'You may choose different pins as long as they are at the same PORT
'The pins must be configured to work as input pins
'This function works for all PIN registers
'-----------------------------------------------------------------------------------------

$regfile = "m48def.dat"                                     ' specify the used micro
$crystal = 8000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 10                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space

Declare Sub Encleft()
Declare Sub Encright()

Print "Encoder test"
Dim B As Byte
'we have dimmed a byte because we need to maintain the state of the encoder

Portb = &B11                                                ' activate pull up registers

Do
   B = Encoder(pinb.0 , Pinb.1 , Encleft , Encright , 1)
   '                                               ^--- 1 means wait for change which blocks programflow
   '                               ^--------^---------- labels which are called
   '              ^-------^---------------------------- port PINs
   Print B
  Waitms 10
Loop
End

'so while you can choose PINB0 and PINB7,they must be both member of PINB
'this works on all PIN registers

Sub Encleft()
  Print "left rotation"
End Sub

Sub Encright()
  Print "right rotation"
End Sub


End