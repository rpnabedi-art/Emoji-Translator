'-----------------------------------------------------------------
'                                 M161.BAS
'                         (c) 2002-2005 MCS Electronics
' demo file for the M161
'-----------------------------------------------------------------

$regfile = "m161def.dat"
$crystal = 3686440
$baud = 19200
$hwstack = 40
$swstack = 40
$framesize = 40


'baud rate for second serial port
$baud1 = 19200

'         TX    RX
' COM0   PD.1   PD.0
' COM1   PB.3   PB.2

'use OPEN/CLOSE for using the second UART
Open "COM2:" For Binary As #1

'dimension some variables
Dim S As String * 10
Dim B As Byte


Print #1 , "test COM2"
'get a key from COM2
B = Inkey(#1)

'print value
Print #1 , B

'wait for a key from port 2
B = Waitkey(#1)
Print #1 , B

'get data from COM2
Input #1 , "s " , S
Print #1 , S
Printbin #1 , B

Do
  'use normal PRINT for COM1
  Print "com1"
  ' and add #1 for com2
  Print #1 , "com2"
  Waitms 500
Loop

'make the CLOSE the last statement of your program
Close #1

End