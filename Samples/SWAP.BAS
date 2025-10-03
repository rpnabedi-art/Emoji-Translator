'-----------------------------------------------------------------------------------------
'name                     : swap.bas
'copyright                : (c) 1995-2005, MCS Electronics
'purpose                  : demo: SWAP
'micro                    : Mega48
'suited for demo          : yes
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------

$regfile = "m48def.dat"                                     ' specify the used micro
$crystal = 8000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 32                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space

Dim A As Byte , B1 As Byte
Dim Bbit1 As Bit , Bbit2 As Bit
Dim S1 As String * 10 , S2 As String * 10
Dim L1 As Long , L2 As Long
Dim Sn1 As Single , Sn2 As Single




S1 = "AAA" : S2 = "BBB"
Swap S1 , S2

A = 5 : B1 = 10                                             'assign some vars
Print A ; "   " ; B1                                        'print them

Swap A , B1                                                 'swap them
Print A ; "   " ; B1                                        'print is again

Set Bbit1
Swap Bbit1 , Bbit2
Print Bbit1 ; Bbit2

L1 = 123456 : L2 = 654321
Swap L1 , L2
Print L1 ; Spc(3) ; L2

Sn1 = 1.1 : Sn2 = 1000
Swap Sn1 , Sn2



End
