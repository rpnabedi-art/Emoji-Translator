'-----------------------------------------------------------------------------------------
'name                     : for_next.bas
'copyright                : (c) 1995-2013, MCS Electronics
'purpose                  : demo: FOR, NEXT
'micro                    : Mega48
'suited for demo          : yes
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------

$RegFile = "m48def.dat"                                     ' specify the used micro
$Crystal = 8000000                                          ' used crystal frequency
$Baud = 19200                                               ' use baud rate
$HWstack = 32                                               ' default use 32 for the hardware stack
$SWstack = 10                                               ' default use 10 for the SW stack
$FrameSize = 40                                             ' default use 40 for the frame space

Dim A As Byte , B1 As Byte , C As Integer


For A = 1 To 10 Step 2
   Print "This is A " ; A
Next A

Print "Now lets count down"
For C = 10 To -5 Step -1
   Print "This is C " ; C
Next



Print "You can also nest FOR..NEXT statements."
For A = 1 To 10
   Print "This is A " ; A
   For B1 = 1 To 10
      Print "This is B1 " ; B1
   Next                                                      ' note that you do not have to specify the parameter
Next A



End