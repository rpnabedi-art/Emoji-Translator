'-------------------------------------------------------------------------------------------
'                                  lcd-BIG.bas
'          user contributed example from user simnakovi
' This sample show BIG digits on a normal text LCD
'-------------------------------------------------------------------------------------------
$regfile = "m8def.dat"
$crystal = 8000000
$hwstack = 32
$swstack = 8
$framesize = 24

Config Submode = New
Config Lcdpin = Pin , Db4 = Portb.3 , Db5 = Portb.2 , Db6 = Portb.1 , Db7 = Portb.0 , E = Portb.4 , Rs = Portb.5
Config Lcd = 16 * 2
'------------------------
Dim Pas As Byte                                             'bit location
Dim S As String * 3                                         'formating string
'The elements of a byte array that will be assigned with the binary representation of the digits.
Dim A(4) As Byte , Ar(5) As Byte
Dim C As Byte                                               'temporary variable counting in loop / next
Dim B As Byte                                               'temporary variable counting in loop / next
Dim Idx As Byte                                             'Value Conversion Of Main String
Dim V1 As String * 4                                        'main string for print
'----------------[display 1st sign]---------------------------------------------
Sub Printing
    Str2digits V1 , Ar(1)                                   'get digits out of string

    Idx = Ar(5)
    Pas = 1
    Formating
 '----------------[display 2th sign]---------------------------------------------
    Idx = Ar(4)
    Pas = 5
    Formating
 '---------------[display 3th sign]----------------------------------------------
    Idx = Ar(3)
    Pas = 9
    Formating
  '---------------[display 4th sign]----------------------------------------------
    Idx = Ar(2)

    Pas = 13
    Formating
End Sub

'--------------[Formating subroutine]-------------------------------------------
Sub formating
  S = Lookupstr(idx , Table_up)
  Locate 1 , Pas
  Send2lcd
  S = Lookupstr(idx , Table_down)
  Locate 2 , Pas
  Send2lcd
End Sub

'---------------------[Routine to extract numbers from ARRAY]-------------------
Sub send2lcd
  For C = 1 To 4
    Str2digits S , A(1)
  Next C

  For B = 2 To 4
    Lcd Chr(a(b))
  Next B
End Sub

'-------------------------------------------------------------------------------
Deflcdchar 0 , 15 , 31 , 31 , 31 , 31 , 31 , 31 , 15        'full left
Deflcdchar 1 , 31 , 31 , 32 , 32 , 32 , 32 , 31 , 31        'up,down
Deflcdchar 2 , 31 , 31 , 32 , 32 , 32 , 32 , 32 , 32        'up
Deflcdchar 3 , 32 , 32 , 32 , 32 , 32 , 32 , 31 , 31        'down
Deflcdchar 4 , 32 , 32 , 32 , 32 , 32 , 14 , 14 , 14        'comma
Deflcdchar 5 , 30 , 31 , 31 , 31 , 31 , 31 , 31 , 30        'full right
Deflcdchar 6 , 32 , 32 , 32 , 32 , 32 , 32 , 24 , 28        'rounded
Deflcdchar 7 , 31 , 31 , 32 , 32 , 32 , 32 , 24 , 28        'rounded beak

Waitms 300
Cls
Cursor Off

Do

  V1 = "1357"
  Printing
  Waitms 2000

  V1 = "2468"
  Printing
  Waitms 2000

  V1 = "9301"
  Printing
'if you want to put a comma in the middle
  Locate 2 , 8 : Lcd Chr(4)
  Waitms 2000

Loop

End

table_up:
Data "520" , "A52" , "512" , "511" , "3A0" , "710" , "610" , "522" , "510" , "510"
table_down:
Data "530" , "303" , "330" , "533" , "022" , "533" , "530" , "5AA" , "530" , "53A"