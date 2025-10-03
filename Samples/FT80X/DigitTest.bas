' DigitTest
' Example of how to load a Font
' For use with the FT800
' Requires Bascom 2.0.7.8 or greater

$Regfile = "M328pdef.dat"
$Crystal = 16000000
$Baud = 57600
$HwStack = 100
$SwStack = 100
$FrameSize = 300
$NOTYPECHECK

'Config ft800=spi , ftsave=0, ftdebug=0 , ftcs=portb.0 ', platform=gameduino2, lcd_rotate=1 ' Gameduino2
Config Ft800 = Spi , Ftsave = 0 , Ftdebug = 0 , Ftcs = Portd.4 , Ftpd = Portd.3  ' 4D AdamShield
'Config Ft800 = Spi , Ftcs = Portb.1 , Ftpd = Portd.4 ' VM801P

Config Submode = New
Config Spi = Hard , Interrupt = Off , Data_Order = Msb , Master = Yes , Polarity = Low , Phase = 0 , Clockrate = 4, Noss = 1
SPSR = 0  ' Makes SPI run at 8Mhz instead of 4Mhz

$Include "FT80x.inc"
$Include "FT80x_Functions.inc"

Declare Sub Digit

Spiinit


if  FT800_Init()=1 Then END    ' Initialise the FT800

Digit

Do
Loop

End


'------------------------------------------------------------------------------------------------------------
Sub Digit
'------------------------------------------------------------------------------------------------------------

   Local dloffset As Word

   CmdMemSet 0, 0, 10 * 1024
   WaitCmdFifoEmpty

   ' Load the deflated icons to GRAM via J1
   TempDW = LoadLabel(digits)
   CMDINFLATEx 0, TempDW, 6358

   CmdSetFont 13, 0
   BITMAPHANDLE 13
'   Const A1 = 144 - (32 * (54/2) * 87 )
   BITMAPSOURCE 144 - (32 * (54/2) * 87 )
   BITMAPLAYOUT FT_L4, 54/2, 87

   UpdateScreen

   'Copy the displaylist from DLRAM to GRAM
   dloffset =  Rd16(REG_CMD_DL)
   CMDMEMCPY 100000, RAM_DL, 12 'dloffset
   CmdAppend 100000, dloffset


   ClearScreen
   COLORRGB 255,0,0
   CmdText   5, 60, 13, 0, ",./!#$%&*()"
   CmdNumber 5, 160, 13, 0, 1234567890

   UpdateScreen

End Sub


'------------------------------------------------------------------------------------------------------------
   $inc digits, nosize, "digits.fon"
'------------------------------------------------------------------------------------------------------------