'------------------------------------------------------------------------
' *** User contributed sample ***
'This shows an insertion sort
'we are sorting from lowest to highest
'then sorting from highest to lowest
'this will sort any array variable by its numeric value (not strings)
'------------------------------------------------------------------------

$regfile = "m2560def.dat"                                 ' specify the used micro


$crystal = 16000000                                         ' used crystal frequency
$baud = 57600                                               ' use baud rate
$hwstack = 50
$swstack = 50
$framesize = 50

Dim Onlongs(17) As Long                                     'numbers to sort Long, Word, Byte as needed
Dim X As Byte


Declare Sub Arraysortasc()                                    'ascending
Declare Sub Arraysortdec()                                    'decending

'---Dummy numbers to test as example
Onlongs(1) = 270
Onlongs(2) = 120
Onlongs(3) = 99
Onlongs(4) = 1452
Onlongs(5) = 978
Onlongs(6) = 22
Onlongs(7) = 180
Onlongs(8) = 721
Onlongs(9) = 622

Cls
print "Sort start>"
Waitms 10

Call Arraysortasc                                          'ascending
print "sorted ascending"
For X = 1 To 9
   print Onlongs(x) ; "-";

Next X
print
Call Arraysortdec                                          'ascending
print "sorted descending"

For X = 1 To 9
   print Onlongs(x) ; "-";
Next X

End                                                        'end program
'-----------Array sorting using insertion with long variables.  other variables can be used

Sub Arraysortasc()
   Local Al As Long                                            'matching the array to be sorted
   Local I As Byte                                             'you may need to use Word variables if the array is large
   Local J As Byte
   Local Z As Byte
   Cls
   For I = 2 To 9                                              'from 2 to highest element number of array
      Al = Onlongs(i)
      J = I
      While J > 1 And Onlongs(j -1) > Al
         Onlongs(j) = Onlongs(j - 1)
         J = J - 1

         For Z = 1 To 9
            print Onlongs(z) ; "-" ;

         Next
         Wait 2
         print
      Wend
      Onlongs(j) = Al
   Next
End Sub


Sub Arraysortdec()

   Local Al As Long                                            'matching the array to be sorted
   Local I As Byte                                             'you may need to use Word variables if the array is large
   Local J As Byte
   Local Z As Byte
   Cls
   For I = 1 To 9                                              'from 1 to highest element number of array
      Al = Onlongs(i)
      J = I
      While J > 1 And Onlongs(j -1) < Al
         Onlongs(j) = Onlongs(j - 1)
         J = J - 1

         For Z = 1 To 9
            print Onlongs(z) ; "-" ;
         Next
         Wait 2
         print
      Wend
      Onlongs(j) = Al
   Next

End Sub