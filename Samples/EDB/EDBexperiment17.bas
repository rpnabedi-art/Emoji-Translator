'--------------------------------------------------------------
'                        EDBexperiment17.bas
'       Experiment 17 for the Educational Development Board
'                  (c) 1995-2006, MCS Electronics
'                        Fileversion 1.0
'--------------------------------------------------------------
'
'Purpose:
'This program shows the difference between EEPROM and RAM
'
'Conclusions:
'You should now know the different memory types

$regfile = "m88def.dat"
$crystal = 8000000
$baud = 19200
$hwstack = 40
$swstack = 40
$framesize = 40

Dim My_eeprom_char As Eram Byte
Dim My_ram_char As Byte

Print "This is my RAM char: " ; Chr(my_ram_char)
My_ram_char = My_eeprom_char
Print "This is my EEPROM char: " ; Chr(my_ram_char)

Print
Print "Hit any alphanumerical key to (re) load the variables My_ram/eeprom_char"

My_ram_char = Waitkey()
My_eeprom_char = My_ram_char

Print "This is my RAM char: " ; Chr(my_ram_char)
My_ram_char = My_eeprom_char
Print "This is my EEPROM char: " ; Chr(my_ram_char)

Print "Now disconnect the powersource and observe this terminal"
Print "You should see the value of EEPROM char beeing preserved on"
Print "The next line: "

End