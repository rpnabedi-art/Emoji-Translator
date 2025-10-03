'-----------------------------------------------------------------------------------------
'name                     : peek.bas
'copyright                : (c) 1995-2013, MCS Electronics
'purpose                  : demonstrates PEEk, POKE, CPEEK, INP and OUT
'micro                    : Mega128
'suited for demo          : yes
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------
' NOTE when you try CPEEKH() on a micro that has no RAMPZ, you get an error and you should remark that code

$regfile = "m128def.dat"                                    ' specify the used micro
$crystal = 8000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 10                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space

Dim I As Integer , B1 As Byte
'dump internal memory
For I = 0 To 31                                             'only 32 registers in AVR
   B1 = Peek(i)                                             'get byte from internal memory
   Print Hex(b1) ; "  ";
   'Poke I , 1                            'write a value into memory
Next
Print                                                       'new line
'be careful when writing into internal memory !!

'now dump a part ofthe code-memory(program)
For I = 0 To 255
   B1 = Cpeek(i)                                             'get byte from internal memory
   Print Hex(b1) ; "  ";
Next
'note that you can not write into codememory!!

'For big flash chip you can use cpeekH() which will access the second page
For I = 0 To 255
   B1 = Cpeekh(i)                                            'get byte from internal memory
   Print Hex(b1) ; "  ";
   B1 = Cpeekh(i , B1)                                       ' or specify the page address (0-3)
   Print Hex(b1) ; "  ";
Next



Out &H8000 , 1                                              'write 1 into XRAM at address 8000
B1 = Inp(&H8000)                                            'return value from XRAM
Print B1

Out Portb , 2

Out Ddrf , 1

End