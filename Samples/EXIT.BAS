'-----------------------------------------------------------------------------------------
'name                     : exit.bas
'copyright                : (c) 1995-2013, MCS Electronics
'purpose                  : demo: EXIT
'micro                    : Mega48
'suited for demo          : yes
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------

$regfile = "m48def.dat"                                     ' specify the used micro
$crystal = 8000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 10                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space

Dim B1 As Byte , A As Byte

B1 = 50                                                     'assign var
For A = 1 To 100                                            'for next loop
   If A = B1 Then                                           'decision
      Exit For                                              'exit loop
   End If
Next
Print "Exit the FOR..NEXT when A was " ; A

A = 1
Do
   Incr A
   If A = 10 Then
      Exit Do
   End If
Loop
Print "Loop terminated"
End