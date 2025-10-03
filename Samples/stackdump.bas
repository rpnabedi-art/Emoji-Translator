'-----------------------------------------------------------------------------------------------------
'                          code and sample by MWS
'                             stackdump.bas
'  uses stackdump.inc and $stackdump to create a dump of the stack in case of a reset
' the $map directive is used to create a source-address map in the report.
'-----------------------------------------------------------------------------------------------------
$regfile = "m88def.dat"
$hwstack = 32
$swstack = 32
$framesize = 32
$crystal = 8000000                                          ' your value
$baud = 19200                                               ' or whatever
$stackdump
$map

$include "stackdump.inc"

Dim ctr As Byte                                             ' variables use for stack autopsy itself have to be declared here,
Dim nl As Byte                                              ' otherwise they may stay uncleared
Dim my_MCUCSR As Byte

my_MCUCSR = GetReg(R0)
  If my_MCUCSR.PORF = 1 Then                                ' powered on ?
    MCUCSR.PORF = 0                                         ' yes, clear PORF
  Else
#IF Ignore_SP
Dim stck_start As Word
  Print "Stack-Address last accessed: &h" ; Hex(SP_last_acsd)
    SP_last_acsd = _HWSTACKSTART - Stck_siz_sav
    Incr SP_last_acsd
      Print "Stack-Dump beginning at: &h" ; Hex(SP_last_acsd)
#ELSE
    Print "Stack-Address last accessed: &h" ; Hex(SP_last_acsd)
#ENDIF
      For ctr = 1 to Stck_byt_cpd                           ' only print out stack variables if not just powered on
        nl = ctr -1 : nl = nl mod 8
          If nl = 0 Then
            if ctr > 1 Then Print
              Print "Addr: &h" ; Hex(SP_last_acsd) ; " = " ;
          End If
            Print "&h" ; Hex(Stck_svd(ctr)) ; " ";
          Incr SP_last_acsd
        If ctr > Stck_siz_sav Then Exit For
      Next ctr
    Print
      Stop
  End If
'###### END BLOCK ##############################################'
'##### Stack display                                       #####'
'###############################################################'

Config Timer1 = Timer , Prescale = 256                      ' interrupts the just executed code after 65536 * 256 cycles = 2.1 sec
  On Timer1 Jump_Reset NOSAVE                               ' just use the ISR to jump to the reset vector
    Enable Timer1                                           ' enable Timer1 ISR
Enable Interrupts                                           ' and so interrupts

Do
  Print "*"
      Waitms 500
  Print "*"
      Waitms 500
  Print "*"
      Waitms 500
Loop


End

Jump_Reset:
  Goto 0
Return