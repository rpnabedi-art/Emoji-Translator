'Routine to read the  SHT11 Humidity sensor chip
'By Stuart Leslie
'Contact stu@4sightinc.com with any questions
'Uses BascomAVR
'a .01 uf capacitor across VCC and Ground on the SHT11 really cleans up the data
'a pullup is required on "data" pin as shown in the data sheet

$regfile = "m88def.dat"


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

Sck Alias Portb.0
Dataout Alias Portb.1
Datain Alias Pinb.1
Redled Alias Portb.2

Declare Sub Getit()

Ddrb = &B11111111                                           'all port b are output
Config Pinb.0 = Output                                      'sck
Config Pinb.1 = Output                                      'datain

'reset the serial communications first, it is easily confused!
Set Dataout
For Ctr = 1 To 12
   Set Sck
   Waitus 2
   Reset Sck
   Waitus 2
Next Ctr


Do                                                          'continually read the tempfature and humidity

   Command = &B00000011
   Call Getit                                               'Get the temperature, puts result in "dataword" for us
      '
   Tempf = T1f * Dataword
   Tempf = Tempf - 40

   Tempc = T1c * Dataword                                   'get celcius for later calculations and for "the rest of the world"
   Tempc = Tempc - 40

   Dis = Fusing(tempf , "###.##")
   Print "Temperature = " ; Dis ; " (F)"

   Command = &B00000101
   Call Getit                                               'get the humidity
   Calc = C2 * Dataword
   Calc2 = Dataword * Dataword                              'that "2" in the datasheet sure looked like a footnote for a couple days, nope it means "squared"!
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
   Print "Humidity adjusted for temperature  = " ; Dis
   Print

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


   'now send the  command
   Shiftout Dataout , Sck , Command , 1

   Ddrb = &B11111101                                        'datain is now input
   Config Pinb.1 = Input                                    'datain
   Set Sck                                                  'click one more off
   Reset Sck
   Waitus 10                                                'no idea why, but it doesn't work without it!
   Bitwait Pinb.1 , Reset                                   'wait for the chip to have data ready

   Shiftin Datain , Sck , Databyte , 1                      'get the MSB
   Datavalue = Databyte

   Ddrb = &B11111111
   Config Pinb.1 = Output

   Reset Dataout                                            'this is the tricky part- Lot's of hair pulling- have to tick the ack!
   Set Sck
   Reset Sck

   Ddrb = &B11111101                                        'datain is now input
   Config Pinb.1 = Input

   Shiftin Datain , Sck , Databyte , 1                      'get the LSB
   Shift Datavalue , Left , 8
   Datavalue = Datavalue Or Databyte
   'don't tick the clock or ack since we don't need the CRC value, leave it hanging!
   Dataword = Datavalue

   Ddrb = &B11111111
   Config Pinb.1 = Output

   Reset Dataout
   Set Sck
   Reset Sck

   Ddrb = &B11111101                                        'datain is now input
   Config Pinb.1 = Input

   Shiftin Datain , Sck , Databyte , 1                      'not using the CRC value for now- can't figure it out! Anybody know how to impliment?
   'Print "CRC value was - " ; Databyte

   Ddrb = &B11111111
   Config Pinb.1 = Output

   Set Dataout
   Set Sck
   Reset Sck
End Sub

End