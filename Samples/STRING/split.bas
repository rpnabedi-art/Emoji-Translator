'--------------------------------------------------------------
'                        mega48.bas
'                      mega48 sample file
'                  (c) 1995-2005, MCS Electronics
'--------------------------------------------------------------
$regfile = "m48def.dat"
$crystal = 8000000
$baud = 19200
$hwstack = 40
$swstack = 40
$framesize = 40

Config Com1 = Dummy , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0


Dim S As String * 80
Dim Ar(5) As String * 10
Dim Bcount As Byte
Dim Srch As String * 1
Srch = " "
'The split function can split a string or string constant into elements
'It returns the number of elements
'You need to take care that there are enough elements and that each element is big enough
'to hold the result
'When a result does not fit into 1 element it will be put into the next element
'The memory is protected against overwriting.

S = "this is a test"

Bcount = Split( "this is a test" , Ar(1) , Srch)
'bcount will get the number of filled elements
'ar(1) is the starting address to use
'" " means that we check for a space

'When you use "  aa"   , the first element will contain a space
Bcount = Split( "thiscannotfit! into the element" , Ar(1) , " ")

Dim J As Byte
For J = 1 To Bcount
  Print Ar(j)
Next

'this demonstrates that your memory is safe and will not be overwritten when there are too many string parts
Bcount = Split( "do not overflow the array please" , Ar(1) , " ")

For J = 1 To Bcount
  Print Ar(j)
Next


End