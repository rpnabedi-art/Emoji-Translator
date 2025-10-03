'-----------------------------------------------------------------------
'                            at90pwm2_3.bas
'                     (c) 1995-2015 MCS Electronics
' test file for AT90PWM2 and PWM3
' on STK topboard connect rxd to PD.4 and txd to pd.3
'-----------------------------------------------------------------------

$regfile = "at90pwm2_3.dat"
$crystal = 8000000
$baud = 19200
$hwstack = 40
$swstack = 40
$framesize = 40

Dim Key As Byte

Print "at90pwm3 test, we used a PWM3 chip to test the DAC"

Admux = Admux Or &B1100_0000                                'enale 2.56 VREF

Start Dac                                                   ' this will enable the DAC and output the voltage to the pin
'use stop dac to disble the DAC
'Stop Dac

Do
  Waitms 500
  'writing to the DAC variables(word) will set the voltage
  Dac = Dac + 1
  Print Dac

  'notice the output voltage and the 10 bit DAC range
  'in order to get an outut between 0 and 2.56 we multiply by 2
  If Inkey() = 32 Then                                      'space bar pressed
     Print Dac
     Input "Enter voltage 0-512 " , Dac
     Dim S As String * 16
     S = Str(dac)                                           'convert to string
     Print "DAC set to " ; Format(s , "0.00") ; " Volt"
     Dac = Dac * 2                                          'mul by 2 to set the DAC to the right level
     Print "Press any key to continue..." : Key = Waitkey()
  End If
Loop
End