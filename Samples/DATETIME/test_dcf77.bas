'---------------------------------------------------------
'             (c) 1995-2007 MCS Electronics
'    DCF 77 demo to demonstrate the DCF77 library from Josef Vögel
'---------------------------------------------------------
$regfile = "M88def.dat"
$crystal = 8000000
$baud = 19200

$hwstack = 128
$swstack = 128
$framesize = 128


Config Dcf77 = Pind.2 , Timer = 1 , Debug = 1 , Check = 1 , Gosub = Sectic
'Config Dcf77 = Pind.7 , Timer = 1 , Debug = 1

Enable Interrupts
Config Date = Dmy , Separator =DOT
Declare Function Dcf_timezone() As Byte


Dim I As Integer
Dim Sec_old As Byte , Dcfsec_old As Byte

Sec_old = 99 : Dcfsec_old = 99

' Testroutine für die DCF77 Clock
Print "Test DCF77 Version 1.02"

Print "Configuration"



Do
   For I = 1 To 78
      Waitms 10
      If Sec_old <> _sec Then
         Exit For
      End If
      If Dcfsec_old <> Dcf_sec Then
         Exit For
      End If
   Next
   Waitms 220
   Sec_old = _sec
   Dcfsec_old = Dcf_sec
   Print Time$ ; " " ; Date$ ; " " ; Time(dcf_sec) ; " " ; Date(dcf_day) ; " " ; Bin(dcf_status) ; " " ; Bin(dcf_parity) ; " " ; Bin(dcf_bits) ; " " ; Bdcf_impuls ; " " ; Bdcf_pause       '; " " ; db1 ; " " ; db2
   If Dcf_sec > 45 Then
      Reset Dcf_status.7
   End If
   Print "Timezone : " ; Dcf77timezone()
Loop


'optional, is called every second by the library
Sectic:
  !nop
Return


End