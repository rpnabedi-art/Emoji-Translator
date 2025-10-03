'----------------------------------------------------------------
'                 (c) 1995-2011, MCS Electronics
'                     XMEGA_easy_Frequency_Generation.bas
' sample written by MAK3
' Frequency Generation with XMEGA : Output at PIND.0
' As with all XMEGA Samples you need the Bascom-AVR Full Version to compile and run it
'----------------------------------------------------------------


$regfile = "xm256A3Bdef.dat"
$crystal = 32000000                               '32MHz
$hwstack = 64
$swstack = 40
$framesize = 40


'first enable the osc of your choice
Config Osc = Enabled , Pllosc = Disabled , Extosc = Disabled , 32khzosc = Disabled , 32mhzosc = Enabled       '32MHz

'configure the systemclock
Config Sysclock = 32mhz , Prescalea = 1 , Prescalebc = 1_1       '32MHz

'Config Interrupts
Config Priority = Static , Vector = Application , Lo = Enabled       'Enable Lo Level Interrupts

Config Com7 = 57600 , Mode = Asynchroneous , Parity = None , Stopbits = 1 , Databits = 8       'Portf.2 and Portf.3 is COM7
Open "COM7:" For Binary As #2


Config Eeprom = Mapped                            ' when using EEPROM , add this config command

Dim A As Word

Config Portd.0 = Output                           'Output for Frequency


Print #2 , "----Example Digital Frequency Generation with XMEGA-----"


Config Tcd0 = Freq , Prescale = 2 , Comparea = Enabled , Resolution = 16
' Config Tcd0 = Pwm --> the word Pwm have here no meaning because it set no Register

'TCD_PER is not used in Frequency (Waveformgeneration) mode, only the TCX_CCX Registers to set the Period of the Digital Waveform

'Digital Waveform Generation

'      +-----------+          +
'      |           |          |
'------+           +----------+
'
'      <--------------------->
'      Period = TCD_CCA Register

' Prescale = 1 --> 32MHz


' Frequency max with TCD_CCA = 0 -->  System Clock/2*Prescaler(CCA + 1) = 32MHz/2*2(0 + 1) = 32MHz/4 = 8MHz

' Frequency min with TCD_CCA = &HFFFF -->  System Clock/2*Prescaler(CCA + 1) = 32MHz/2*2(65535 + 1) = 32MHz/4*65536 = 122 Hz


Tcd0_cca = 0                                      'F = 8 MHz
Wait 6
Tcd0_cca = &HFFFF                                 'F = 122 Hz

End                                               'end program
