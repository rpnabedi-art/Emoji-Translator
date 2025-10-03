'-----------------------------------------------------------------------
'name                     : MEMCOPY.BAS
'copyright                : (c) 1995-2013, MCS Electronics
'purpose                  : show memory copy function
'suited for demo          : yes
'commercial addon needed  : no
'use in simulator         : possible
'----------------------------------------------------------------------
$regfile = "m88def.dat"                                     ' specify the used micro
$crystal = 8000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 16                                               ' default use 10 for the SW stack
$framesize = 40

Dim Ars(10) As Byte                                         'source bytes
Dim Art(10) As Byte                                         'target bytes
Dim J As Byte                                               'index
For J = 1 To 10                                             'fill array
   Ars(j) = J
Next

J = Memcopy(ars(1) , Art(1) , 4)                            'copy 4 bytes

Print J ; " bytes copied"
For J = 1 To 10
   Print Art(j)
Next

J = Memcopy(ars(1) , Art(1) , 10 , 2)                       'assign them all with element 1

Print J ; " bytes copied"
For J = 1 To 10
   Print Art(j)
Next


Dim W As Word , L As Long
W = 65511
J = Memcopy(w , L , 2)                                      'copy 2 bytes from word to long



End
