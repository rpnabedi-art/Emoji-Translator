'-----------------------------------------------------------------------
'                         DTMFOUT.BAS
'      demonstrates DTMFOUT statement based on AN 314 from Atmel
' min osc.freq is 4 MHz, max freq is 10 MHz
'micro                    : Mega48
'suited for demo          : yes
'commercial addon needed  : no
'-----------------------------------------------------------------------
$regfile = "m48def.dat"                                     ' we use the M48
$crystal = 8000000
$hwstack = 40
$swstack = 8
$framesize = 24
'since the DTMFOUT statement uses the TIMER1 interrupt you must enable
'global interrupts
'This is not done by the compiler in case you have more ISRs
Enable Interrupts


'the first sample does dtmfout in a loop
Dim Btmp As Byte , Sdtmf As String * 10

Sdtmf = "12345678"                                          ' number to dial

Do

   Dtmfout Sdtmf , 50                                       ' lets dial a number
   '                ^ duration is 50 mS for each digit
   Waitms 1000                                                ' wait for one second


   ' As an alternative you can send single digits
   ' there are 16 dtmf tones
   For Btmp = 0 To 15
      DTMFout Btmp , 50                                        ' dtmf out on PORTB.3 for the 2313 for 500 mS
      'output is on the OC1A output pin , pin 15 for M48
      Waitms 500                                              ' wait 500 msec
   Next
Loop
End

'the keypad of most phones looks like this :
'1  2  3    optional are A
'4  5  6                 B
'7  8  9                 C
'*  0  #                 D

'the DTMFOUT translates a numeric value from 0-15 into :
' numeric value    phone key
'   0                0
'   1                1
'   2                2
'   3                3
' etc.
'   9                9
'  10                *
'  11                #
'  12                A
'  13                B
'  14                C
'  15                D