'--------------------------------------------------------------------------------
'name                     : bcd.bas
'copyright                : (c) 1995-2013, MCS Electronics
'purpose                  : demonstration of split and combine BCD Bytes
'suited for demo          : yes
'commercial addon needed  : no
'use in simulator         : possible
'--------------------------------------------------------------------------------
$RegFile = "m88def.dat"                                     ' specify the used micro
$crystal = 8000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
Config Com1 = Dummy , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0


$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 10                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space

'==============================================================================='
' Set up Variables
'==============================================================================='
Dim A As Byte                                               'Setup A Variable
Dim B As Byte                                               'Setup B Variable
Dim C As Byte                                               'Setup C Variable

A = &H89                                                    '

'==============================================================================='
' Main
'==============================================================================='
Print "Combined :   " ; Hex(a)                              'Print A

'-------------------------------------------------------------------------------'
B = A And &B1111_0000                                       'Mask To Get Only High Nibble Of Byte
Shift B , Right , 4                                         'Shift High Nibble To Low Nibble Position , Store As B

C = A And &B0000_1111                                       'Mask To Get Only Low Nibble Of Byte , Store As C

Print "Split :      " ; B ; " " ; C                         'Print B (High Nibble) , C(low Nibble)

'-------------------------------------------------------------------------------'
Shift B , Left , 4                                     'Shift Data From Low Nibble Into High Nibble Position

A = B + C                                                   'Add B (High Nibble) And C(low Nibble) Together

Print "Re-Combined: " ; Hex(a)                              'Print A (re -combined Byte)

'-------------------------------------------------------------------------------'
End                                                         'End Program
'-------------------------------------------------------------------------------'

