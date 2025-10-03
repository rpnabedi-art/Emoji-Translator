'----------------------------------------------------------------
'                  (c) 1995-2014, MCS
'                      xm128-reset.bas
'  This sample demonstrates how to read out the reson for reset
'-----------------------------------------------------------------

$regfile = "xm128a1def.dat"
$crystal = 32000000
$hwstack = 64
$swstack = 40
$framesize = 40

dim bReset as Byte 'reset byte
bReset=Getreg(r0)       ' reset is in R0 so get it early at startup

'first enable the osc of your choice
Config Osc = Enabled , 32mhzosc = Enabled

'configure the systemclock
Config Sysclock = 32mhz , Prescalea = 1 , Prescalebc = 1_1

Config Com1 = 19200 , Mode = Asynchroneous , Parity = None , Stopbits = 1 , Databits = 8


Config Portd.0 = Output
Config Portd.1 = Output
Set Portd.0                                                 ' special xmega handling for set,reset and toggle
Waitms 1000
Reset Portd.0
Waitms 1000
Toggle Portd.0

Print "test reset"
'-------------------RESET STATUS------------------------------------------------
Print Bin(bReset)                                       'print reason for reset
If bReset.0 = 1 Then
   Print "Power On Reset"
End If
If bReset.1 = 1 Then
   Print "External Reset"
End If
If bReset.2 = 1 Then
   Print "Brown out Reset"
End If
If bReset.3 = 1 Then
   Print "Watchdog Reset"
End If
If bReset.4 = 1 Then
   Print "Program and Debug Interface Reset"
End If
If bReset.5 = 1 Then
   Print "Software Reset"
End If
'-------------------------------------------------------------------------------


Do
   Waitms 5000                                              'wait 5 secs

   Cpu_ccp = &HD8                                           ' write protecion register
   Rst_ctrl.0 = 1                                           ' software reset
Loop


End