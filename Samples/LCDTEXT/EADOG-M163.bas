'--------------------------------------------------------------
'                        EADOG-M163.bas
'       Demonstration for EADOG 163 display
'                  (c) 1995-2006, MCS Electronics
'--------------------------------------------------------------
'

$regfile = "M8515.dat"
$crystal = 4000000
$hwstack = 40
$swstack = 40
$framesize = 40


'I used the following settings
'Config Lcdpin = Pin , Db4 = Portb.2 , Db5 = Portb.3 , Db6 = Portb.4 , Db7 = Portb.5 , E = Portb.1 , Rs = Portb.0

'CONNECT vin TO 5 VOLT
Config Lcd = 16 * 3 , Chipset = Dogm163v5                   '16*3 type LCD display
'other options for chipset are DOG163V3 for 3Volt operation


'Config Lcd = 16 * 3 , Chipset = Dogm163v3 , Contrast = &H702       '16*3 type LCD display
'The CONTRAST can be specified when the default value is not what you need


'The EADOG-M162 is also supported :
'Chipset params for the DOGM162 : DOG162V5, DOG162V3

Cls                                                         'Dit maakt het scherm leeg
Locate 1 , 1 : Lcd "Hello World"
Locate 2 , 1 : Lcd "line 2"
Locate 3 , 1 : Lcd "line 3"

End