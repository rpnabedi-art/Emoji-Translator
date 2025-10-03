'--------------------------------------------------------------------------
'                   (c) 1995-2013, MCS Electronics
'          LOOKUP and LOOKUPSTR example
'--------------------------------------------------------------------------

'With LookUp() you can lookup data from DATA lines with an index.

$regfile = "m88def.dat"
$swstack = 40
$hwstack = 32
$framesize = 32
$crystal = 4000000
$baud = 19200

Dim Idx As Word , Vl As Byte

For Idx = 0 To 4
   Vl = Lookup(idx , Lbl)
   Print "Index searched : " ; Idx ; "  and found : " ; Vl

   Print Lookupstr(idx , Lbl2)
Next

End



Lbl:
Data 1 , 2 , 30 , 50 , 5 , 6 , 7

Lbl2:
Data "BASCOM" , "BASIC" , "AVR" , "8051" , "???"