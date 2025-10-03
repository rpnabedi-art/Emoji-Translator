'Routine to read the SHT11 Humidity sensor chip
'By Stuart Leslie
'Contact stu@4sightinc.com with any questions
'CRC includet by Helmut Hoerschgl
'Contact helmut.hoerschgl@gmx.at
'Uses BASCOM-AVR  'a .01 uf capacitor across VCC and Ground on the SHT11 really cleans up the data
'a pullup is required on "data" pin as shown in the data sheet
$regfile = "M16def.dat"

Dim Er As Long
Dim Crc_cor As Byte
Dim Cx As Byte
Dim Crc_sht As Byte
Dim A1 As Byte
Dim I1 As Byte , J As Byte
Dim Z1(3) As Byte
Dim X As Byte
Dim Idx As Byte
Dim Crc As Byte
Dim I As Byte
Dim Ctr As Byte
Dim Dataword As Word
Dim Command As Byte
Dim Dis As String * 20
Dim Calc As Single
Dim Calc2 As Single
Dim Rhlinear As Single
Dim Rhlintemp As Single
Dim Tempc As Single
Dim Tempf As Single

Const C1 = -4
Const C2 = 0.0405
Const C3 = -0.0000028
Const T1c = 0.01
Const T2 = 0.00008
Const T1f = 0.018

Config Lcdpin = Pin , Db4 = Porta.0 , Db5 = Porta.1 , Db6 = Porta.2 , Db7 = Porta.3 , E = Porta.5 , Rs = Porta.4
Config Lcd = 16x2

Sck Alias Portd.6
Dataout Alias Portd.7
Datain Alias Pind.7

Declare Sub Getit()
Declare Sub Calc_crc(byval X As Byte)

Ddrd = &B11111111                                           'all port bare output
Config Pind.6 = Output                                      'sck
Config Pind.7 = Output                                      'datain
'reset the serial communications first, it is easily confused!
Set Dataout
For Ctr = 1 To 12
   Set Sck
   Waitus 2
   Reset Sck
   Waitus 2
Next Ctr
Cls
Waitms 20
Cursor Off
Waitms 20

Do
   'continually read the tempfature and humidity
   Command = &B00000011
   Z1(1) = 3
   Call Getit                                                 'Get the temperature, puts result in "dataword" for us
   '
   Tempf = T1f * Dataword
   Tempf = Tempf - 40
   Tempc = T1c * Dataword                                     'get celcius for later calculations and for "the rest of the world"
   Tempc = Tempc - 40
   Dis = Fusing(tempf , "###.##")
   Locate 1 , 14 : Lcd "CRC"
   Waitms 20
   Locate 1 , 1 : Lcd "Temp=" ; Dis ; "(F)"
   Wait 1
   Command = &B00000101
   Z1(1) = 5
   Call Getit                                                 'get the humidity
   Calc = C2 * Dataword
   Calc2 = Dataword * Dataword                                'that "2" in the datasheet sure looked like a footnote for a couple days, nope  it means "squared"!
   Calc2 = C3 * Calc2
   Calc = Calc + C1
   Rhlinear = Calc + Calc2
   'Dis = Fusing(rhlinear , "##.##")
   'Print "Humidity adjusted for linear = " ; Dis

   Calc = T2 * Dataword
   Calc = Calc + T1c
   Calc2 = Tempc - 25
   Calc = Calc2 * Calc
   Rhlintemp = Calc + Rhlinear
   Dis = Fusing(rhlintemp , "##.##")
   Locate 2 , 0 : Lcd "Hum=" ; Dis
   Wait 1
Loop

Sub Getit()
   Local Datavalue As Word
   Local Databyte As Byte
   'start with "transmission start"
   Set Sck
   Reset Dataout
   Reset Sck
   Set Sck
   Set Dataout
   Reset Sck

   'now send the command
   Shiftout Dataout , Sck , Command , 1
   Ddrd = &B11111101                                          'datain is now input
   Config Pind.7 = Input                                      'datain
   Set Sck                                                    'click one more off
   Reset Sck
   Waitus 10                                                  'no idea why, but it doesn't work without it!
   Bitwait Pind.7 , Reset                                     'wait for the chip to have data ready
   Shiftin Datain , Sck , Databyte , 1                        'get the MSB
   Datavalue = Databyte
   Z1(2) = Databyte
   Ddrd = &B11111111
   Config Pind.7 = Output
   Reset Dataout                                              'this is the tricky part- Lot's of hair pulling- have to tick the ack!
   Set Sck
   Reset Sck
   Ddrd = &B11111101                                          'datain is now input
   Config Pind.7 = Input
   Shiftin Datain , Sck , Databyte , 1                        'get the LSB
   Z1(3) = Databyte
   Shift Datavalue , Left , 8
   Datavalue = Datavalue Or Databyte                          'don't tick the clock or ack since we don't need the CRC value, leave it hanging!
   Dataword = Datavalue
   Ddrd = &B11111111
   Config Pind.7 = Output
   Reset Dataout
   Set Sck
   Reset Sck
   Ddrd = &B11111101                                          'datain is now input
   Config Pind.7 = Input
   Shiftin Datain , Sck , Databyte , 1
   Crc_sht = Databyte                                         'CRC von SHTXX übergeben
   Gosub Crc_ex
   Crc = 0
   For J = 1 To 3                                            'die 3 Bytes an Calc_crc(x) übergeben
      X = Z1(j)
      Call Calc_crc(x)
   Next
   If Crc = Crc_cor Then
      Locate 2 , 15
      Waitms 20
      Lcd "OK"
      Waitms 20
   Else
      Locate 2 , 15
      Waitms 20
      Lcd "ER"
      Waitms 20
      Command = &B00011110
      Set Sck
      Reset Dataout
      Reset Sck
      Set Sck
      Set Dataout
      Reset Sck

      Shiftout Dataout , Sck , Command , 1                  'if CRC is wrong reset the SHTXX
      Waitms 20
   End If
   Ddrd = &B11111111
   Config Pind.7 = Output
   Set Dataout
   Set Sck
   Reset Sck
End Sub

End

Sub Calc_crc(byval X As Byte)                               'CRC Berechnung
   Restore Crc_table
   Idx = Crc Xor X
   If X = 0 Then Idx = 3
   For I = 0 To Idx
      Read Crc
   Next
End Sub

Crc_ex:                                                     'vom SHTXX empfangener CRC wird hier in die korrekte Form gebracht
   Cx = 0
   A1 = 7
   Do
      Crc_cor.cx = Crc_sht.a1
      Incr Cx
      Decr A1
   Loop Until Cx = 8
Return

Crc_table:
   Data 0 , 49 , 98 , 83 , 196 , 245 , 166 , 151 , 185 , 136 , 219 , 234 , 125 , 76 , 31 , 46
   Data 67 , 114 , 33 , 16 , 135 , 182 , 229 , 212 , 250 , 203 , 152 , 169 , 62 , 15 , 92 , 109
   Data 134 , 183 , 228 , 213 , 66 , 115 , 32 , 17 , 63 , 14 , 93 , 108 , 251 , 202 , 153 , 168
   Data 197 , 244 , 167 , 150 , 1 , 48 , 99 , 82 , 124 , 77 , 30 , 47 , 184 , 137 , 218 , 235
   Data 61 , 12 , 95 , 110 , 249 , 200 , 155 , 170 , 132 , 181 , 230 , 215 , 64 , 113 , 34 , 19
   Data 126 , 79 , 28 , 45 , 186 , 139 , 216 , 233 , 199 , 246 , 165 , 148 , 3 , 50 , 97 , 80
   Data 187 , 138 , 217 , 232 , 127 , 78 , 29 , 44 , 2 , 51 , 96 , 81 , 198 , 247 , 164 , 149
   Data 248 , 201 , 154 , 171 , 60 , 13 , 94 , 111 , 65 , 112 , 35 , 18 , 133 , 180 , 231 , 214
   Data 122 , 75 , 24 , 41 , 190 , 143 , 220 , 237 , 195 , 242 , 161 , 144 , 7 , 54 , 101 , 84
   Data 57 , 8 , 91 , 106 , 253 , 204 , 159 , 174 , 128 , 177 , 226 , 211 , 68 , 117 , 38 , 23
   Data 252 , 205 , 158 , 175 , 56 , 9 , 90 , 107 , 69 , 116 , 39 , 22 , 129 , 176 , 227 , 210
   Data 191 , 142 , 221 , 236 , 123 , 74 , 25 , 40 , 6 , 55 , 100 , 85 , 194 , 243 , 160 , 145
   Data 71 , 118 , 37 , 20 , 131 , 178 , 225 , 208 , 254 , 207 , 156 , 173 , 58 , 11 , 88 , 105
   Data 4 , 53 , 102 , 87 , 192 , 241 , 162 , 147 , 189 , 140 , 223 , 238 , 121 , 72 , 27 , 42
   Data 193 , 240 , 163 , 146 , 5 , 52 , 103 , 86 , 120 , 73 , 26 , 43 , 188 , 141 , 222 , 239
Data 130 , 179 , 224 , 209 , 70 , 119 , 36 , 21 , 59 , 10 , 89 , 104 , 255 , 206 , 157 , 172
