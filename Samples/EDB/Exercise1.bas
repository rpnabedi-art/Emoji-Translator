'--------------------------------------------------------------
'                         Exercise1.bas
'        Exercise 1 for the Educational Development Board
'                  (c) 1995-2006, MCS Electronics
'                        Fileversion 1.0
'--------------------------------------------------------------
'
'Solution for EDB Exercise 1

$regfile = "m88def.dat"
$crystal = 8000000
$baud = 19200
$hwstack = 40
$swstack = 40
$framesize = 40

'Config Lcd Sets The Portpins Of The Lcd
Config Lcdpin = Pin , Db4 = Portb.2 , Db5 = Portb.3 , Db6 = Portb.4 , Db7 = Portb.5 , E = Portb.1 , Rs = Portb.0
Config Lcdbus = 4                                           'Select 4 bits mode
Config Lcd = 16x2                                         '16*2 type LCD screen
'You can define your own LCD chars with the Deflcdchar statement
'And the Bascom build in LCD Designer, Tools -> LCD Designer menu
Cursor Off, NoBlink                                          'No cursor

Cls                                                         'This clears the LCD

Dim Inputstring As String * 16
Dim Akey As Byte

Do
   Print "Please enter your name"
   Inputstring = ""                                         'Remark this line and observe

   Do
      Akey = Waitkey()
      If Akey = 13 Then Goto Show                           'On CR or LF (enter key) goto show
      If Akey = 10 Then Goto Show
      Inputstring = Inputstring + Chr(akey)                 'Assign the string
   Loop

   Show:
      Locate 1 , 1 : Lcd "Hello:          "
      Locate 2 , 1 : Lcd Inputstring
      Wait 1
Loop

End