'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'                          BARCODE.BAS
'                      (c) 2002-2013 MCS Electronics
' SSR 1000/2000 was used for scanning
' This device gives a pulse with the length of the bar
' a bar will pull the pin to 0V a space will leave the pin high
' The algo used is to store the bar nd space times and calculate the digits
' for UPC /EAN13
' THERE IS NO SUPPORT ON THIS SAMPLE since there are many barcode readers and many
' give rs232 output unlike the SSR1000. You can use an optical reader.
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Declare Function Slots(b As Byte) As Word
Declare Function Decodeean13(s As String) As Byte

$regfile = "m163def.dat"
$crystal = 4000000
$baud = 19200
Config Pind.7 = Input
Config Pind.6 = Input
Portd.7 = 1
Portd.6 = 1
Config Timer0 = Timer , Prescale = 64
Start Timer0
Dim Ar(60) As Byte

Dim B As Bit , X As Byte , Avg As Word , Stx As Byte , Ed As Byte , Lx As Byte , L!
Dim Prc As Single , Lz As Integer
Dim N1 As Word , N2 As Word , N3 As Word , N4 As Word
Dim S As String * 4
Print "start"


Do
  Print "wait"                                              ' wait for first bar
  X = 0
  Bitwait Pind.7 , Reset                                    ' wait for the first bar

  Do
    Timer0 = 0                                              ' reset counter
    Bitwait Pind.7 , Set                                    ' wait for space
    X = X + 1 : Ar(x) = Timer0 : Timer0 = 0                 'store
    Bitwait Pind.7 , Reset                                  ' wait for bar
    X = X + 1 : Ar(x) = Timer0                              'store
  Loop Until X = 60

'unremark for printing the array content
'  For Tel = 1 To 60
'   Print "b(" ; Tel ; ")=" ; Ar(tel)
'  Next


  Stx = 5                                                   ' here the bar space starts
  Do
     Avg = 0 : Ed = Stx + 3
     For X = Stx To Ed
        Avg = Avg + Ar(x)                                   ' calculate avergae
     Next
     Avg = Avg / 7
     N1 = Slots(ar(stx)) : Incr Stx                         'determine number that fit into a slot of 7 units
     N2 = Slots(ar(stx )) : Incr Stx
     N3 = Slots(ar(stx )) : Incr Stx
     N4 = Slots(ar(stx )) : Incr Stx

     S = Str(n1) + Str(n2) + Str(n3) + Str(n4)              ' make a string
     X = Decodeean13(s)                                     ' decode the string
     Print X;                                               ' print digit
     If Stx = 29 Then Stx = 34                              ' skip centre marker bars
  Loop Until Stx >= 55
  Wait 1
Loop

End

'determine slots
'there are total 7 slots in a unit
'must be 1,2,3 or 4
Function Slots(b As Byte) As Word
     Lx = B / Avg
     L! = B / Avg : Lz = L!
     Prc = L! - Lz : Prc = Prc * 100 : If Prc > 50 Then Lx = Lx + 1
     Slots = Lx
End Function

'decode EAN13 barode
Function Decodeean13(s As String) As Byte
   Local Z As Byte
   Select Case S
        Case "1123" : Z = 0
        Case "3211" : Z = 0
        Case "2221" : Z = 1
        Case "1222" : Z = 1
        Case "2122" : Z = 2
        Case "2212" : Z = 2
        Case "1411" : Z = 3
        Case "1141" : Z = 3
        Case "1132" : Z = 4
        Case "2311" : Z = 4
        Case "1231" : Z = 5
        Case "1321" : Z = 5
        Case "1114" : Z = 6
        Case "4111" : Z = 6
        Case "1312" : Z = 7
        Case "2131" : Z = 7
        Case "1213" : Z = 8
        Case "3121" : Z = 8
        Case "3112" : Z = 9
        Case "2113" : Z = 9
   End Select
   Decodeean13 = Z
End Function