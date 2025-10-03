'-----------------------------------------------------------------------
'                        (c) 2002-2003 MCS Electronics
'          lcd4busy.bas shows how to use LCD with busy check
'-----------------------------------------------------------------------
'code tested on a 8515
$regfile = "8515def.dat"
$hwstack = 40
$swstack = 40
$framesize = 40


'stk200 has 4 MHz
$crystal = 4000000

'define the custom library
'uses 184 hex bytes total

$lib "lcd4busy.lib"

'define the used constants
'I used portA for testing
Const _lcdport = Porta
Const _lcdddr = Ddra
Const _lcdin = Pina
Const _lcd_e = 1
Const _lcd_rw = 2
Const _lcd_rs = 3


'this is like always, define the kind of LCD
Config Lcd = 16 * 2

'and here some simple lcd code
Cls
Lcd "test"
Lowerline
Lcd "this"
End
