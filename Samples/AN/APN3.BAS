'-----------------------------------------------------------------
'               Copyright 1999-2015 MCS Electronics
'-----------------------------------------------------------------
'Application Note 3 : controlling the X9CMME
'The X9CMME is a digital potentiometer chip From Xicor http://www.xicor.com
'
'Chip pin    Function
'1           /INC      increment input
'2           U/D       up/down input
'3           VH        potmeter high terminal
'4           VSS       Ground
'5           VW        potmeter wiper terminal
'6           VL        potmeter low terminal
'7           /CS       chip select/enable
'8           VCC       power (+5V)
'The chip used is the X9C103
'The chip can be used to dim a lights or a VCO or ....
'-----------------------------------------------------------------
$regfile = "m48def.dat"
$hwstack = 40
$swstack = 40
$framesize = 40


Dim Pulse As Byte                         'byte to hold number of pulses
Dim Up As Bit                             'counter direction flag

Cls                                       'clear lcd
'  -----   define aliases -----
_incr Alias Portb.1                                           'pin 1 of IC
Ud Alias Portb.0                                              'pin 2 of IC
Cs Alias Portb.2                                              'pin 7 of IC

Config Pinb.0 = Output                                        'output
Config Pinb.1 = Output                                        'output
Config Pinb.2 = Output                                        'output

'or config portb=output

'-------now init the chip to make sure it's value is 0
Set Cs                                    'disable chip
Set _incr                                 'ready for clock pulse
Reset Ud                                  'count down
Reset Up                                  'count down

Pulse = 100 : Gosub Sendpulse           'make sure value is 0

Do
  Set Ud                                'count up
  Set Up                                'set flag too
  Pulse = 100                           '100 pulses maximum
  Gosub Sendpulse                       'send pulses

  Wait 1                                'wait 1 second

  Reset Ud                                                    'count down
  Reset Up                                                    'counting up flag
  Pulse = 100                           '100 pulses
  Gosub Sendpulse                       'send pulses

  Wait 1                                'wait 1 second
Loop
End

'-------- subroutine to send pulse to chip
'Input : pulse holds the number of pulse to generate
'Otput : none
Sendpulse:
  Dim Count As Byte                     'variable for counter
  Reset Cs                                                    'enable chip
  Cls                                                         'clear lcd
  'we must use a bit variable to test the direction since we can only examine
  'the state of the Px.x flags if it is used as input and we are using it as an output.
  If Up = 0 Then
     Lcd "Counting down"                                      'display direction
  Else
     Lcd "Counting Up"
  End If


  For Count = 1 To Pulse                  'for all pulses
    Home Lowerline                        'set cursor home at line 2
    Reset _incr                                               'generate pulse
    Delay                                 'wait a little
    Set _incr                             'high again
    Lcd "Value : " ; Count                                    'display value
  Next
  Set Cs                                  'disable chip and store value
Return