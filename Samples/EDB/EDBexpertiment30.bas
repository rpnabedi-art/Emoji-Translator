'--------------------------------------------------------------
'                        EDBexperiment30.bas
'       Experiment 30 voor het Educatief Ontwikkel Bord
'                  (c) 1995-2006, MCS Electronics
'                        Bestandsversie 1.0
'--------------------------------------------------------------
$regfile = "m88def.dat"
$crystal = 8000000
$hwstack = 40
$swstack = 40
$framesize = 40

Led Alias Portd.7                                           ' de groene LED op het EDB
Config Pind.6 = Input                                       'pind.6 wordt als input gebruikt
Portd.6 = 1                                                 ' pull up wordt geactiveerd

Const Aan = 1
Const Uit = 0

Led = Uit                                                   'LED uit
Dim B As Bit                                                'we bewaren de bit positie
B = 0                                                       'zet hem op 0

Do
    If Pind.6 = 0 Then                                      ' de ingang wordt laag gemaakt
       If B = 0 Then                                        'indien de bit nog niet gezet was
          Toggle Led                                        'inverteer led
          B = 1                                             'onthoud dat we de LED hebben geactiveerd
       End If
    Else                                                    'de ingang is weer hoog
       B = 0                                                'reset de geheugen bit
    End If
Loop