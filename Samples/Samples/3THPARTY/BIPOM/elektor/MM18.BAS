'-------------------------------------------------------------------------------
'                         MM18.BAS
'    New Elektor MiniMod Module with USBASP bootloade built in
' To activate the usbasp bootloader : keep S1 pressed and reset(2 pins on K3)
'-------------------------------------------------------------------------------
$regfile = "m328pdef.dat"                                   ' Specify The Used Micro
$crystal = 16000000                                         ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 32                                               ' default use 32 for thehardware stack
$swstack = 10                                               ' default use 10 for theSW stack
$framesize = 40                                             ' default use 40 for theframe space
'-------------------------------------------------------------------------------

$initmicro                                                  ' run subroutine _init_micro
Config Clockdiv = 1                                         ' divide xtal clock by 1, default fuse bit is set to 8 by elektor
Config Lcdpin = Pin , Db4 = Portd.4 , Db5 = Portd.5 , Db6 = Portd.6 , Db7 = Portd.7 , E = Portc.1 , Rs = Portc.2
Config Lcd = 16 * 2                                         'configure lcd screen 8*2 not available

S1 Alias Pinb.1                                             'switch 1
S2 Alias Pinb.0                                             'switch 2


Cursor Off
Cls
Lcd "MiniMod"
Lowerline
Lcd "Alive"
Waitms 2000
'#######!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#####
' now you can adjust the contrast with P1
'#######!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#####
Do
   If S1 = 0 Then                                           'if switch S1 is pressed it becomes 0
      Cls : Lcd "S1"
   Elseif S2 = 0 Then
      Cls : Lcd "S2"
   End If
Loop

End                                                         'end program



'this routine is executed first, use it to set pins to the needed state quickly
_init_micro:
  Config Portc.3 = Output
  Portc.3 = 0                                               'lcd : R/W Low
  Portb = &B11                                              'activate pull up resistors on switches
Return