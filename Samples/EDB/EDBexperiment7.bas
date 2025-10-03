'--------------------------------------------------------------
'                        EDBexperiment7.bas
'       Experiment 7 for the Educational Development Board
'                  (c) 1995-2006, MCS Electronics
'                        Fileversion 1.0
'--------------------------------------------------------------
'
'Purpose:
'This program uses an LCD display
'
'Conclusions:
'You should be able to use an LCD

$regfile = "m88def.dat"
$crystal = 8000000
$hwstack = 40
$swstack = 40
$framesize = 40


'Config Lcd Sets The Portpins Of The Lcd
Config Lcdpin = Pin , Db4 = Portb.2 , Db5 = Portb.3 , Db6 = Portb.4 , Db7 = Portb.5 , E = Portb.1 , Rs = Portb.0
Config Lcdbus = 4                                           'Select 4 bits mode
Config Lcd = 16x2                                         '16*2 type LCD screen
'You can define your own LCD chars with the Deflcdchar statement
'And the Bascom build in LCD Designer, Tools -> LCD Designer menu
Cursor Off, Noblink                                          'No cursor

Cls                                                         'This clears the LCD

Do
   Locate 1 , 1 : Lcd "Hello World     "
   Locate 2 , 1 : Lcd "                "
   Wait 1
Loop

End