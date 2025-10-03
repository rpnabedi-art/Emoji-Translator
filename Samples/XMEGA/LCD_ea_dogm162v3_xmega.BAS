'----------------------------------------------------------------
'                  (c) 1995-2011, MCS
'               LCD_ea_dogm162v3_xmega.BAS
'  This sample demonstrates EA-DOGM 162 3v3
'  contributed by MAK3
'-----------------------------------------------------------------


$RegFile = "xm128a1def.dat"
$crystal = 32000000
$hwstack = 84
$swstack = 80
$framesize = 80


Config Osc = Enabled , 32mhzosc = Enabled
Config Sysclock = 32mhz

Config Com1 = 57600 , Mode = Asynchroneous , Parity = None , Stopbits = 1 , Databits = 8
Open "COM1:" For Binary As #1
Waitms 2


Print #1 ,
Print #1 , "---LCD Example EA-DOGM 162 4-Bit Mode at 3.3 Volt---"

Dim A As Byte


'Hardware Connections according Datasheet 4-Bit Mode 3.3 Volt and R/W --> GND
Config Lcdpin = Pin , Db4 = Porte.5 , Db5 = Porte.4 , Db6 = Porte.3 , Db7 = Porte.2 , E = Porte.6 , Rs = Porte.7
Config Lcd = 16x2 , Chipset = Dogm162v3

Cursor Off, NoBlink
Cls

Locate 1 , 3 : Lcd "ATXMEGA128A1"
Locate 2 , 1 : Lcd "EA-DOGM 162 3.3V"
Wait 2

For A = 1 To 10
  Shiftlcd Right                                  ' shift the text to the right
  Waitms 500                                      ' wait a moment
Next



For A = 1 To 10
  Shiftlcd Left                                   ' shift the text to the left
  Waitms 500                                      ' wait a moment
Next

Cls

Locate 1 , 1                                      ' set cursor position
Lcd "*"                                           ' display this
Wait 1                                            ' wait a moment

Shiftcursor Right                                 ' shift the cursor
Lcd "@"                                           ' display this
Shiftcursor Right
Lcd "*"

Wait 2

Cls

Locate 1 , 3 : Lcd "ATXMEGA128A1"
Locate 2 , 1 : Lcd "EA-DOGM 162 3.3V"

End                                               'end program
