'--------------------------------------------------------------
'                     (c) 1999-2011 MCS Electronics
'--------------------------------------------------------------
'  file: INT0.BAS
'  demo: ON INT0 .. , RETURN
'--------------------------------------------------------------
$RegFile = "m88def.dat"
$HWstack = 40
$SWstack = 32
$FrameSize = 32

Dim V1 As Integer
Dim Count As Integer , Ts As Byte

Config Int0 = Low_level


On Int0 Int0_int                                            'Initialise the INT0 Interrupt
Rem On Int0 Int0_int Nosave     'Initialise the INT0 Interrupt
Rem Use The Nosave Option When You Dont Want The Internal Registers To Be Saved/restored In
Rem The Interrupt Routine

Enable Interrupts
Enable Int0                                                 'enable the interrupt



Count = 0                                                   'reset counter
Do
   V1 = V1 + 1
   Ts = Inkey()                                            'get key from serial device
Loop Until Ts = 27                                          'loop until users presses ESC key
End


Rem The Interrupt Handler For The Int0 Interrupt
Int0_int:
   Incr Count
   If Count = 2 Then
      Print "Int 0 occured"
      Count = 0
   End If
   Rem You Can Perform More Actions Here
Return
'notice the return