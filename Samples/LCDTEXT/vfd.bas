'-------------------------------------------------------------
'                        (C) 1995-2010
'        VFD.BAS demonstates the VFD display from
'             "Electronic Design Bitzer"
'  This progam requires the lcdcfd.lib wich is supplied with
'  display
'-------------------------------------------------------------
$regfile = "m88def.dat"                                     ' used processor
$crystal = 8000000                                          ' crystal clock
$hwstack = 40
$swstack = 40
$framesize = 40

'dim some variables
Dim A As Byte , X As Byte , Y As Byte

'include the library
$lib "lcdvfd.lib"

Config Lcd = 20x4vfd                                        ' this is a special 20x4 display
Config Lcdpin = Pin , Busy = Portb.7 , Db4 = Portb.0 , Db5 = Portb.1 , Db6 = Portb.2 , Db7 = Portb.3 , E = Portb.6 , Reset = Portb.5 , Mode = 0
'this display supports various modes, and also has a normal LCD compatible mode. The library supports mode 0 and mode 1
'mode=0 4 bit parallel upper nibble first  , mode=1 4 bit parallel lower nibble first

Waitms 3000                                                 ' in case there was a welcome sign, delay
Lcd "test"                                                  ' show some text
Waitms 1000
Cls                                                         ' clear display
Lcd "VFD display"                                           ' show text
Home                                                        ' set cursomr home
Waitms 1000
Home Lower                                                  'see the cursor jumping
Waitms 1000
Home Third
Waitms 1000
Home Fourth
Waitms 1000
Locate 2 , 2 : Lcd "test"                                   ' use locate
Waitms 1000
X = 3 : Y = 4 : Locate Y , X : Lcd "display"                ' test with variables
Cursor Off
Waitms 1000
Cursor On
Waitms 3000
Cursor Blink
Waitms 3000
Display Off
Waitms 3000
Display Off
Waitms 3000
Display On
Shiftlcd Left
Shiftlcd Left
Waitms 1000
Shiftlcd Right
Waitms 1000
Shiftlcd Down                                               ' this display can shift down
Waitms 1000
Shiftlcd Up                                                 ' and up
Lcdautodim 5                                                ' auto dim in 5 seconds ,to turn it off send a 0

End