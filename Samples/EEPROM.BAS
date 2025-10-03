'-----------------------------------------------------------------------------------------
'name                     : eeprom.bas
'copyright                : (c) 1995-2013, MCS Electronics
'purpose                  : example on how to use the internal EEPROM
'micro                    : Mega48
'suited for demo          : yes
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------

$regfile = "m48def.dat"                                     ' specify the used micro
$crystal = 8000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 10                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space

'dimension some variables
Dim S As String * 5 , B As Byte , I As Byte , W As Word


'You can also dimension variables that must be stored into EEPROM
Dim Eb As Eram Byte At 13 , Ei As Eram Integer At 14 , El As Eram Long At 16 , Es As Eram String * 10 At 20
'We use the AT to indicate the address because we are using both modes in this example
'Normally you dont need this. In fact it is better to leave the address to the compiler


'Now read 5 bytes from the EEPROM
'I is the address to read from and the lowest address is 0
'Note however that address 0 can be trashed during reset or start up.
'This is a fault in the AVR design.



For I = 0 To 4
  Readeeprom B , I
  Print B
Next


'Now write something from code into EEPROM
'assign variable
S = "abcde"
W = 10000
'write string
Writeeeprom S , 5
'Since length is 5 and we also need the ending null byte the next free address
'is 11

'write word
Writeeeprom W , 11

'Now reset the variables
W = 0
S = ""

'Read back
Readeeprom S , 5
Print S

Readeeprom W , 11
Print W


'Now write a byte to EEPROM
B = 10
Eb = B
'read it back
B = Eb
Print B


'Now write string
Es = S
S = ""
S = Es
Print S

'We dont do anything with the normal DATA in this example
'Restore Lbl
'Read b
'Print b


End


'The $EEPROM directive tells the compiler that the data lines that
'follow, must be written to a <prog>.EEP file
'This file can be programmed into the EEPROM
$eeprom
'Now we want to use 5 bytes
Data 1 , 2 , 3 , 4 , 5
'Normally a DATA statement will place the data in the flash ROM.
'So a $DATA statement is not necesarry.
'BUT since we used an $EEPROM directive above, we need to switch
'back to the normal default
$data
'The label named LBL will be used with the RESTORE statement
Lbl:
'Now define the DATA that will be placed in Flash ROM together with your program code
Data 10 , 12
