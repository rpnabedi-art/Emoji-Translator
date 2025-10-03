'-----------------------------------------------------------------------------------------
'name                     : m169_lcd.bas
'copyright                : (c) 1995-2012, MCS Electronics
'purpose                  : demonstrates LCD butterfly driver
'micro                    : Mega169
'suited for demo          :
'commercial addon needed  :
'-----------------------------------------------------------------------------------------

$regfile = "m169def.dat"                                    ' specify the used micro
$crystal = 8000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 10                                               ' default use 10 for the SW stack
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

Dim J As Byte
For J = 0 To 100
  Cls
  Lcd J
  Waitms 1000
Next


'this table supports ASCII 32-127 
Lcd_butterfly_data:
Data 0%                                                     ' space
Data 0%                                                     ' !
Data 0%                                                     '""
Data 0%                                                     ' #
Data &H3BC1%                                                '$
Data 0%                                                     '  %
Data 0%                                                     ' &
Data &H0040%                                                '  '
Data 0%                                                     '  (
Data 0%                                                     '  )
Data &HEAA8%                                                ' *
Data &H2A80%                                                ' +
Data &H4000%                                                ' ,
Data &H0A00%                                                ' -
Data &H2000%                                                ' .
Data &H4008%                                                '/
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
Data &H2080%                                                ':
Data 0%                                                     ';
Data &H8008%                                                '<
Data &H1A00%                                                '=
Data &H4020%                                                '>
Data 0%                                                     '?
Data 0%                                                     '@
Data &H0F51%                                                ' A
Data &H3991% , &H1441% , &H3191% , &H1E41% , &H0E41% , &H1D41% , &H0F50% , &H2080% , &H1510% , &H8648% , &H1440% , &H0578%
Data &H8570% , &H1551% , &H0E51% , &H9551% , &H8E51% , &H9021% , &H2081% , &H1550% , &H4448% , &HC550% , &HC028% , &H2028% , &H5009%
Data &H1441%                                                '[
Data &H8020%                                                '\
Data &H1111%                                                ']
Data 0%                                                     '^
Data &H1000%                                                '_
Data &H0020%                                                ''
Data &H0F51%                                                ' a..z
Data &H3991% , &H1441% , &H3191% , &H1E41% , &H0E41% , &H1D41% , &H0F50% , &H2080% , &H1510% , &H8648% , &H1440% , &H0578%
Data &H8570% , &H1551% , &H0E51% , &H9551% , &H8E51% , &H9021% , &H2081% , &H1550% , &H4448% , &HC550% , &HC028% , &H2028% , &H5009%
Data 0%                                                     '{
Data 2080%                                                  '|
Data 0%                                                     '}
Data &HFFFF%                                                '~
