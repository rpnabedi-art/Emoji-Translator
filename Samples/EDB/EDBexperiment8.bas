'--------------------------------------------------------------
'                        EDBexperiment8.bas
'       Experiment 8 for the Educational Development Board
'                  (c) 1995-2006, MCS Electronics
'                        Fileversion 1.0
'--------------------------------------------------------------
'
'Purpose:
'This program shows an HEX counter on a 7 segment display,
'it also shows how to use the Read & Restore statements
'
'Conclusions:
'You should be able to use a 7 segment display

$regfile = "m88def.dat"
$crystal = 8000000
$hwstack = 40
$swstack = 40
$framesize = 40

Dim Output_value As Byte
Dim Count As Byte

Config Portb = Output

Do

Restore Display_table                                       'Point to Display_table

For Count = 1 To 16                                         'Execute statements between for...next 16 times
   Read Output_value                                        'Reads the 'count' position of Display_table
   Portb = Output_value                                     'You could also use the lookup statement
   Wait 1
Next

Loop


End


Display_table:
'Change the values of this table if you connect your 7 segment display
'otherwise then discribed in the EDB manual.
     '0           1             2            3            4            5
Data &B00000101 , &B10011111 , &B10100100 , &B10010100 , &B00011110 , &B01010100
     '6             7           8            9          A             b
Data &B01000100 , &B10011101 , &B00000100 , &B00010100 , &B00001100 , &B01000110
     'C            d             E           F
Data &B01100101 , &B10000110 , &B01100100 , &B01101100