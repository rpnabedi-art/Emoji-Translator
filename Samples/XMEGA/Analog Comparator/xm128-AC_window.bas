'-----------------------------------------------------------------
'                  (c) 1995-2010, MCS
'                      XM128a1-AC_WINDOW.bas
'  This sample demonstrates the Analog Comparator in Window Mode
'-----------------------------------------------------------------

'$regfile = "xm128A1def.dat"
$regfile = "xm32A4def.dat"

$crystal = 32000000
$hwstack = 64
$swstack = 64
$framesize = 64

'First Enable The Osc Of Your Choice , make sure to enable 32 KHz clock or use an external 32 KHz clock
Config Osc = Enabled , 32mhzosc = Enabled

'configure the systemclock
Config Sysclock = 32mhz , Prescalea = 1 , Prescalebc = 1_1

Config Com1 = 19200 , Mode = Asynchroneous , Parity = None , Stopbits = 1 , Databits = 8

Config Priority = Static , Vector = Application , Lo = Enabled , Med = Enabled , Hi = Enabled


'setup comparator in window mode on Port A

'MUXPLUS = 2 on both Comparators --> This is the INPUT SIGNAL in Window Mode (PIN 2)
'MUXMIN for ACA0 = 1 (which is PIN 1)  = UPPER LIMIT OF SINGAL (For example connect 3.3 Volt)
'MUXMIN for ACA1 = 6 (which is the internal BANDGAP Voltage of 1.1 Volt)  = LOWER LIMIT OF SIGNAL

'So the Window is fom 1.1 Volt to 3.3 Volt

Config Aca0 = On , Hispeed = Disabled , Window = Enabled , Hysmode = Small , Muxplus = 2 , Muxmin = 1
Config Aca1 = On , Hispeed = Disabled , Window = Enabled , Hysmode = Small , Muxplus = 2 , Muxmin = 6 , Wintmode = Outside       ' specify WINTMODE once

On Aca_acw Ac_window_isr
Enable Aca_acw , Lo
Enable Interrupts

'Now connect for example a AA Battery (1.5 Volt) and alternately GND with PIN 2 (INPUT SIGNAL)

Do

  Print "ACA_ac0ctrl = " ; Bin(aca_ac0ctrl)
  Print "ACA_ac1ctrl = " ; Bin(aca_ac1ctrl)
  Print "ACA_status  = " ; Bin(aca_status)

  If Aca_status.6 = 1 And Aca_status.7 = 0 Then
      Print "INSIDE"
  Else
      Print "OUTSIDE"
  End If


  If Aca_status.2 = 1 Then
     Print "Window INT Flag is set"
  End If

  Waitms 1000

Loop

End                                                         'end program


Ac_window_isr:
 Print "BELOW Window"
 Waitms 5                                                   'Just for testing
Return