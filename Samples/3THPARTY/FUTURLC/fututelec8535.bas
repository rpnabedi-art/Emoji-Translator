'--------------------------------------------------------------------------
'                        futurelec 8535 board demo
'
'
'--------------------------------------------------------------------------
$regfile = "8535def.dat"
$hwstack=40
$swstack=24
$FrameSize=40
$crystal = 8000000
$baud = 19200
Config Lcd = 16 * 2
Config Lcdpin = Pin , Db4 = Portc.4 , Db5 = Portc.5 , Db6 = Portc.6 , Db7 = Portc.7 , Rs = Portc.1 , E = Portc.0
Config Adc = Single , Prescaler = Auto
Print "Start"
Start Adc
Cls
Lcd "Hello world"

Dim W As Word , Oldw As Word
Do
  W = Getadc(0)                                             ' get value from ad convert channel 0
  If W <> Oldw Then
     Print W                                                ' if changed
  End If                                                    ' print to serial port
  Oldw = W
Loop

End