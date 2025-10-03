'------------------------------------------------------------------------------
'name                     : rotate.bas
'copyright                : (c) 1995-2013, MCS Electronics
'purpose                  : demonstrates ROTATE and SHIFT
'micro                    : Mega48
'suited for demo          : yes
'commercial addon needed  : no
'------------------------------------------------------------------------------
$regfile = "m48def.dat"                                     ' we use the M48
$crystal = 8000000
$baud = 19200

$hwstack = 32
$swstack = 8
$framesize = 24

'dimension some variables
Dim B As Byte , I As Integer , L As Long

'the shift statement shift all the bits in a variable one
'place to the left or right
'An optional paramater can be provided for the number of shifts.
'When shifting out then number 128 in a byte, the result will be 0
'because the MS bit is shifted out

B = 1
Shift B , Left
Print B
'B should be 2 now

B = 128
Shift B , Left
Print B
'B should be 0 now

'The ROTATE statement preserves all the bits
'so for a byte when set to 128, after a ROTATE, LEFT , the value will
'be 1

'Now lets make a nice walking light
'First we use PORTB as an output
Config Portb = Output
'Assign value to portb
Portb = 1
Do
   For I = 1 To 8
      Rotate Portb , Left
      'wait for 1 second
      Wait 1
   Next
   'and rotate the bit back to the right
   For I = 1 To 8
      Rotate Portb , Right
      Wait 1
   Next
Loop

End