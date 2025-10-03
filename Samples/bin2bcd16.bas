'--------------------------------------------------------------------------------
'name                     : bin2bcd16.bas
'copyright                : (c) 1995-2013, MCS Electronics
'purpose                  : Test program for BIN to BCD Calculations
'suited for demo          : yes
'commercial addon needed  : no
'use in simulator         : possible
'--------------------------------------------------------------------------------
' Library sample from : Per Svensson
'                       Monolitsystem AB
'                       PS@monolitsystem.se

$regfile = "m48def.dat"                                     ' specify the used micro
$crystal = 8000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 10                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space
$noframeprotect

'=====================  BASIC PROGRAM Bin2BCD16.BAS =======================
'Test program for BIN to BCD Calculations

'define external user library
$lib "bcd.lbx"
'define used function/sub
$external Bin2bcd16

'this is needed so the parameters will be placed correct on the stack
Declare Function Bin2bcd16(bval As Word) As Long

Dim S As Word
Dim A As Long
Dim Temp As Word
S = &H8765
A = &HEDCB
Temp = 1234

A = Bin2bcd16(temp)                                         'call function from lib
S = Temp
End