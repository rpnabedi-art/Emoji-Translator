'-----------------------------------------------------------------------------------------
'name                     : m329_lcd.bas
'copyright                : (c) 1995-2006, MCS Electronics
'purpose                  : demonstrates LCD butterfly driver for STK502
'micro                    : Mega329
'suited for demo          :
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------

$regfile = "m329def.dat"                                    ' specify the used micro
$crystal = 8000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 42                                               ' default use 32 for the hardware stack
$swstack = 40                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space

$lib "lcd_butterfly.lbx"

'you need to dim this byte
Dim _butterfly_digit As Byte

Dim S As String * 6

Cls
S = "AVR"
Lcd "BASCOM"
Wait 2
Cls : Lcd S
Wait 2

Dim J As Byte
For J = 0 To 100
  Cls
  Lcd J
  Waitms 1000
Next


Lcd_butterfly_data:
Data 0%                                                     ' space
Data 0%                                                     ' !
Data 0%                                                     '""
Data 0%                                                     ' #
Data 0%                                                     '$
Data 0%                                                     '  %
Data 0%                                                     ' &
Data 0%                                                     '  '
Data 0%                                                     '  (
Data 0%                                                     '  )
Data 0%                                                     ' *
Data 0%                                                     ' +
Data 0%                                                     ' ,
Data 0%                                                     ' -
Data 0%                                                     ' .
Data 0%                                                     '/
Data &H5559%                                                ' 0
Data &H0118%                                                '1
Data &H1E11%                                                ' 2
Data &H1B11%                                                ' 3
Data &H0B50%                                                ' 4
Data &H1B41%                                                ' 5
Data &H1F41%                                                '6
Data &H0111%                                                ' 7
Data &H1F51%                                                ' 8
Data &H1B51%                                                '9
Data 0%                                                     ':
Data 0%                                                     ';
Data 0%                                                     '<
Data 0%                                                     '=
Data 0%                                                     '>
Data 0%                                                     '?
Data 0%                                                     '@
Data &H0F51%                                                ' A
Data &H3991% , &H1441% , &H3191% , &H1E41% , &H0E41% , &H1D41% , &H0F50% , &H2080% , &H1510% , &H8648% , &H1440% , &H0578%
Data &H8570% , &H1551% , &H0E51% , &H9551% , &H8E51% , &H9021% , &H2081% , &H1550% , &H4448% , &HC550% , &HC028% , &H2028% , &H5009%