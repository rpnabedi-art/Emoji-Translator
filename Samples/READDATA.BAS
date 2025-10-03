'------------------------------------------------------------------------------
'name                     : readdata.bas
'copyright                : (c) 1995-2013, MCS Electronics
'purpose                  : demonstrates RESTORE, READ, DATA
'micro                    : Mega48
'suited for demo          : yes
'commercial addon needed  : no
'------------------------------------------------------------------------------
$regfile = "m48def.dat"                                     ' we use the M48
$crystal = 8000000
$baud = 19200

$hwstack = 32
$swstack = 8
$framesize = 24

Dim A As Integer , B1 As Byte , Count As Byte
Dim S As String * 15
Dim L As Long
Restore Dta1                                                'point to stored data
For Count = 1 To 3                                          'for number of data items
   Read B1 : Print Count ; "  " ; B1
Next

Restore Dta2                                                'point to stored data
For Count = 1 To 2                                          'for number of data items
   Read A : Print Count ; "  " ; A
Next

Restore Dta3
Read S : Print S
Read S : Print S


Restore Dta4
Read L : Print L                                            'long type


'demonstration of readlabel
Dim W As Iram Word At 8 Overlay                             ' location is used by restore pointer
'note that W does not use any RAM it is an overlayed pointer to the data pointer
W = Loadlabel(dta1)                                         ' loadlabel expects the labelname
Read B1
Print B1


End


Dta1:
Data &B10 , &HFF , 10
Dta2:
Data 1000% , -1%

Dta3:
Data "Hello" , "World"
'Note that integer values (>255 or <0) must end with the %-sign
'also note that the data type must match the variable type that is
'used for the READ statement

Dta4:
Data 123456789&
'Note that LONG values must end with the &-sign
'Also note that the data type must match the variable type that is used
'for the READ statement