$hwstack = 40
$swstack = 40
$framesize = 50
$regfile = "m48def.dat"
$crystal = 12000000
Config Lcdpin = Pin , Rs = Portb.0 , E = Portb.1 , Db4 = Portb.2 , Db5 = Portb.3 , Db6 = Portb.4 , Db7 = Portb.5
Config Lcd = 16 * 2
Cursor Noblink
Cursor Off
Cls

Config Rc5 = Pind.3
Config Pind.3 = Input
Set Portd.3                                                 ' включить внутренний подт€гивающий резистор
Enable Interrupts

Dim Address As Byte
Dim Command As Byte
Lcd "Adress :"
Lowerline
Lcd "Command:"

Do

Getrc5(address , Command)

'If Address < 255 Then
'Command = Command And &B01111111
'Locate 1 , 1
'Lcd "                "
'Locate 1 , 1
'Lcd "Adr: " ; Address ; " Cmd: " ; Command
'End If
  If Address < 255 Then
    'Portd.3 = 1                              ' Kontroll-LED ein
    Command = Command And &B01111111         ' Togglebit lцschen
    Locate 1 , 10
    Lcd Address
    Locate 2 , 10
    Lcd Command

  Else
    'Portd.3 = 0                              ' Kontroll-LED aus
    Locate 1 , 10
    Lcd "   "
    Locate 2 , 10
    Lcd "   "
  End If
     Waitms 200

Loop


