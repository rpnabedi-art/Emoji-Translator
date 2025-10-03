' FT800 Capture.Bas
' Allows you to do a Screen Capture from the FT800 sending data via serial in 'PPM' file format.
' Thanks to James Bowman for the example code, original code from  http://gameduino2.proboards.com/thread/23/screenshots
'
' Sub ScreenShot: is the original demo (just streams the data till it's finished)
'
' Sub ScreenShot2: use 'Capture FT800.exe' to capture the Screen Shot data from the FT800.
'
' Requires Bascom 2.0.7.8 or greater

$Regfile = "M328pdef.dat"
$Crystal = 16000000
$Baud = 115200
$HwStack = 128
$SwStack = 128
$FrameSize = 300

'Config ft800=spi , ftsave=0, ftdebug=0 , ftcs=portb.0 ', platform=gameduino2, lcd_rotate=1 ' Gameduino2
Config Ft800 = Spi , Ftsave = 0 , Ftdebug = 0 , Ftcs = Portd.4 , Ftpd = Portd.3  ' 4D AdamShield
'Config Ft800 = Spi , Ftcs = Portb.1 , Ftpd = Portd.4 ' VM801P

Config Base = 0
Config Submode = New
Config Spi = Hard, Interrupt = Off, Data_Order = Msb, Master = Yes, Polarity = Low, Phase = 0, Clockrate = 4, Noss = 1
SPSR = 1  ' Makes SPI run at 8Mhz instead of 4Mhz


$Include "FT80x.inc"
$Include "FT80x_Functions.inc"

Declare Sub ScreenShot
Declare Sub ScreenShot2
Declare Sub Demo

Spiinit

if FT800_Init() = 1 Then END    ' Initialise the FT800

Do
   Demo

       ' Wait 5

  ' ScreenShot2

Loop

End

'------------------------------------------------------------------------------------------------------------
Sub Demo
'------------------------------------------------------------------------------------------------------------

   Local I As Integer

   CmdGradient 0, 0, 0, Ft_DispWidth, Ft_DispHeight, &H303080
   Begin_G FtPoints

   For I = 0  to 99
      ColorRGB  Rnd(256), Rnd(256), Rnd(256)
      PointSize Rnd(200)
      Vertex2ii Rnd(Ft_DispWidth), Rnd (Ft_DispHeight),0,0
   Next I

   ColorRGBdw White
   CmdText 240, 136, 31, OPT_CENTER, "This is a ScreenShot"

   ColorRGBdw Yellow
   CmdText 240, 236, 28, OPT_CENTER, "About to be captured by PC Capture Program"
   UpdateScreen

End Sub

'------------------------------------------------------------------------------------------------------------
Sub ScreenShot ' Original Capture and Transmit Program
'------------------------------------------------------------------------------------------------------------

   Local B As Byte
   Local G As Byte
   Local R As Byte
   Local X As Integer, Y As Integer
   Local Calc1 As Integer, Calc2 As Dword
   Local Str1 As String * 4
   Local Str2 As String * 4

   Str1 = Str(Ft_DispWidth)
   Str2 = Str(Ft_DispHeight)

   Wr8 Reg_ScreenShot_EN, 1

   Print "P6" + Chr(&H0A) + LTrim(Str1) + Chr(&H0A) + LTrim(Str2) + Chr(&H0A) + "255" + Chr(&H0A); ' PPM header

   For Y = 0 to Ft_DispHeight-1

      Wr16 Reg_ScreenShot_Y, Y
      Wr8  Reg_ScreenShot_Start , 1

      While Rd32(Reg_ScreenShot_Busy) > 0 OR Rd32(Reg_ScreenShot_Busy + 4) > 0 : Wend

      Wr8 Reg_ScreenShot_Read, 1

      For X = 0 to Ft_DispWidth-1
         Calc1 = X * 4
         Calc2 = Ram_ScreenShot + Calc1
         B = Rd8(Calc2+0)
         G = Rd8(Calc2+1)
         R = Rd8(Calc2+2)
         PrintBin R
         PrintBin G
         PrintBin B

      Next X

      Wr8 Reg_ScreenShot_Read, 0

   Next Y

   Wr16 Reg_ScreenShot_EN, 0

End Sub


'------------------------------------------------------------------------------------------------------------
Sub ScreenShot2
'------------------------------------------------------------------------------------------------------------

   Const EOT = 4
   Const ACK = 6
   Const ESC = 27

   Local B As Byte
   Local G As Byte
   Local R As Byte
   Local Char As Byte
   Local X As Integer, Y As Integer
   Local Calc1 As Integer, Calc2 As Dword
   Local Str1 As String * 4
   Local Str2 As String * 4

   Str1 = Str(Ft_DispWidth)
   Str2 = Str(Ft_DispHeight)

    ' Make sure the PC is Ready for the Header
   Gosub GetCmd
   If Char = ESC Then Exit Sub

    ' Send the Header
   Print "P6" + Chr(&H0A) + LTrim(Str1) + Chr(&H0A) + LTrim(Str2) + Chr(&H0A) + "255" + Chr(&H0A); ' PPM header

    ' Ready for the Next Data
   Gosub GetCmd
   If Char = ESC Then Exit Sub

   Wr8 Reg_ScreenShot_EN, 1

    ' Now send the actual Data

   For Y = 0 to Ft_DispHeight-1

      Wr16 Reg_ScreenShot_Y, Y
      Wr8  Reg_ScreenShot_Start , 1

      While Rd32(Reg_ScreenShot_Busy) > 0 OR Rd32(Reg_ScreenShot_Busy + 4) > 0 : Wend

      Wr8 Reg_ScreenShot_Read, 1

      For X = 0 to Ft_DispWidth-1
         Calc1 = X * 4
         Calc2 = Ram_ScreenShot + Calc1
         B = Rd8(Calc2+0)
         G = Rd8(Calc2+1)
         R = Rd8(Calc2+2)
         PrintBin R
         PrintBin G
         PrintBin B

         If Ischarwaiting() = True Then
            If Inkey() = ESC Then
               Wr8 Reg_ScreenShot_Read, 0
               Wr16 Reg_ScreenShot_EN, 0
               Clear_B 1,1,1
               ColorRGBdw Red
               CmdText 240, 136, 31, OPT_CENTER, "ESCaping"
               UpdateScreen

               Wait 1
               Exit Sub
            End If
         End If

      Next X

      Wr8 Reg_ScreenShot_Read, 0

   Next Y

   Wr16 Reg_ScreenShot_EN, 0

   PrintBin EOT

   Exit Sub


   GetCmd:

      Char = 0

      Do
         Char = Waitkey()

         If Char = ACK or Char = ESC Then
            Exit Do
         End if
      Loop

   Return


End Sub

'------------------------------------------------------------------------------------------------------------