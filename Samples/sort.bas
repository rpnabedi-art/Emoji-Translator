'------------------------------------------------------------------------------
'                         SORT.BAS
'                 (c) 1995-2014 , MCS Electronics
' This demo demonstrates the SORT statement. It will sort an array
' sort supports, byte, integer,word, dword and long arrays
'------------------------------------------------------------------------------
$regfile = "m88def.dat"
$crystal = 8000000
$hwstack = 16
$swstack = 8
$framesize = 30

'Dim some arrays
Dim B(10) As Byte , I(10) As Integer , W(10) As Word
Dim J As Byte

'point to data
Restore Arraydata

'read the data
For J = 1 To 10
   Read B(j)
Next
'read the words
For J = 1 To 10
   Read W(j)
Next
'read the integers
For J = 1 To 10
   Read I(j)
Next

'now sort the arrays
Sort B(1) , 10                                              ' 10 elements
Sort W(1)                                                   ' all elements
Sort I(1)


'and show the result
For J = 1 To 10
   Print J ; "  " ; B(j) ; " " ; W(j) ; " " ; I(j)
Next
End




Arraydata:
Data 1 , 4 , 8 , 9 , 2 , 5 , 3 , 7 , 6 , 4
Data 1000% , 101% , 1% , 400% , 30000% , 20000% , 15000% , 0% , 999% , 111%
Data -1000% , 101% , -1% , 400% , 30000% , 2000% , -15000% , 0% , 999% , 111%