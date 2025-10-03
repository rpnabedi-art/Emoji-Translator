'--------------------------------------------------------------
'                 (c) 1999-2013 MCS Electronics
'--------------------------------------------------------------
'  file: INPUT.BAS
'  demo: INPUT, INPUTHEX
'--------------------------------------------------------------
'To use another baudrate and crystalfrequency use the
'metastatements $BAUD =  and $CRYSTAL =
$regfile = "m88def.dat"
$crystal = 4000000                                          '12 MHz
$baud = 9600                                                  'try 1200 baud for example

Dim V As Byte , B1 As Byte
Dim C As Integer , D As Byte
Dim S As String * 15

Input "Use this to ask a question " , V
Input B1                                                      'leave out for no question

Input "Enter integer " , C
Print C


Inputhex "Enter hex number (4 bytes) " , C
Print C
Inputhex "Enter hex byte (2 bytes) " , D
Print D

Input "More variables " , C , D
Print C ; " " ; D

Input C Noecho                          'supress echo

Input "Enter your name " , S
Print "Hello " ; S

Input S Noecho                          'without echo
Print S
End