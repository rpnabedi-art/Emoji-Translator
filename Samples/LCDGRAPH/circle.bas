'----------------------------------------------------------------
'                          circle.bas
'            draws a circle on a graphic display
'----------------------------------------------------------------
$crystal = 8000000
$regfile = "8535def.dat"
$hwstack = 40
$swstack = 40
$framesize = 40


'First we define that we use a graphic LCD
' Only 240*64 supported yet
Config Graphlcd = 240 * 128 , Dataport = Porta , Controlport = Portc , Ce = 2 , Cd = 3 , Wr = 0 , Rd = 1 , Reset = 4 , Fs = 5 , Mode = 8
'The dataport is th e portname that is connected to the data lines of the LCD
'The controlport is the portname which pins are used to control the lcd
'CE, CD etc. are the pin number of the CONTROLPORT.
' For example CE =2 because it is connected to PORTC.2
'mode 8 gives 240 / 8 = 30 columns , mode=6 gives 240 / 6 = 40 columns

Dim I As Byte
Cls
'create a solid circle
For I = 1 To 20
   Circle(40 , 40) , I , 255
Next


Do
  Circle(20 , 20) , 10 , 255                                'make circle
  Wait 1
  Circle(20 , 20) , 10 , 0                                  ' remove circle
  Wait 1
Loop


End