' FT800 Sketch.
' This application demonstrates an Interactive Sketch using
' Sketch Slider and Buttons (FT800 platform).
' Original code from http://www.ftdichip.com/Support/SoftwareExamples/EVE/FT_App_Sketch.zip
' Requires Bascom 2.0.7.8 or greater

$Regfile ="M328pdef.dat"
$Crystal = 16000000
$Baud = 576000
$HwStack = 90
$SwStack = 90
$FrameSize = 300
$NOTYPECHECK

'Config ft800=spi , ftsave=0, ftdebug=0 , ftcs=portb.0 ', platform=gameduino2, lcd_rotate=1 ' Gameduino2
Config Ft800 = Spi , Ftsave = 0 , Ftdebug = 0 , Ftcs = Portd.4 , Ftpd = Portd.3  ' 4D AdamShield
'Config Ft800 = Spi , Ftcs = Portb.1 , Ftpd = Portd.4 ' VM801P

Config Submode = New
Config Spi = Hard , Interrupt = Off , Data_Order = Msb , Master = Yes , Polarity = Low , Phase = 0 , Clockrate = 4, Noss = 1
SPSR = 1  ' Makes SPI run at 8Mhz instead of 4Mhz


$Include "FT80x.inc"
$Include "FT80x_Functions.inc"

Declare Sub IntroFTDI()
Declare Function Read_Keys() As Byte

' General Program Variables and Declarations
Dim color   As DWord
Dim tracker As Dword
Dim value   As Word
Dim tagx    As Byte
Dim Temp1   As Integer
Dim Temp2   As Integer

Dim temp_tag  As Byte

Spiinit

if FT800_Init()=1 then end   ' Initialise the FT800

IntroFTDI

value = 32768
color = 0
tagx  = 0

   ' Set the bitmap properties , sketch properties and Tracker for the sliders
ClearScreen
CmdFgColor &HFFFFFF     ' Set the BG color
CmdTrack FT_DispWidth-30, 40, 8, FT_DispHeight-100,1

#IF FT_CHIP=801
  CmdSketch 0, 10, FT_DispWidth-40, FT_DispHeight-30, 0, FT_L8, 1500
#Else
  CmdSketch 0, 10, FT_DispWidth-40, FT_DispHeight-30, 0, FT_L8
#EndIF


BitmapSource 0
BitmapLayout FT_L8 , FT_DispWidth-40, FT_DispHeight-20
BitmapSize NEAREST, BORDER, BORDER, FT_DispWidth-40, FT_DispHeight-20

CmdMemZero 0, 256 * 1024
WaitCmdfifoEmpty

Do
      ' Check the tracker
   tracker = Rd32(REG_TRACKER)
      ' Check the Tag
   Tagx = Rd8(REG_TOUCH_TAG)

      ' clear the GRAM when user enter the Clear button
   If Tagx = 2 Then
      CmdMemZero 0, 256 * 1024 ' Clear the G_Ram from 1024
      WaitCmdfifoEmpty
   End If

      ' Compute the color from the tracker
   TempDw = tracker AND &HFF

   If TempDw = 1  Then    ' check the tag val
      Shift tracker, Right, 16
      value = tracker
   End If

   color = value * 255
   Clear_B 1, 1, 1      ' clear the display
   COLORRGB 255,255,255 ' color
   CmdBgColor color
   TagMask 1
   Tag 1                ' assign the tag value
   CmdFgColor color

      ' draw the sliders
   CmdSlider FT_DispWidth-30, 40, 8, FT_DispHeight-100, 0, value, 65535

   If tagx = 2 then
      CmdFgColor &H0000FF
   Else
      CmdFgColor color
   End If

   Tag 2                ' assign the tag value
   CmdButton FT_DispWidth-35, FT_DispHeight-45, 35, 25, 26, 0, "CLR"
   TagMask 0

   CmdText FT_DispWidth-35, 10, 26, 0, "Color"
   LineWidth 1 * 16
   Begin_G RECTS
   Vertex2F 0, 10 * 16
   Vertex2F (FT_DispWidth - 40) * 16, (FT_DispHeight - 20) * 16

   ColorRGBdw Color
   Begin_G BITMAPS
   Vertex2II 0, 10, 0, 0

   UpdateScreen

Loop

End

'------------------------------------------------------------------------------------------------------------
Sub IntroFTDI
'------------------------------------------------------------------------------------------------------------

   Local TempW  As Dword
   Local dloffset As Word
   Local tagx    As Byte
   Local Temp2   As Byte

   ' Variables for Read_Keys()
   Dim Sk  As Byte

    ' home_setup()
   TempW = LoadLabel(Home_Star_Icon)
   CMDINFLATEx 250*1024, TempW, 460

   'Set the Bitmap properties for the ICONS
   Clear_B 1,1,1
   COLORRGB 255, 255, 255
   BITMAPHANDLE 13         ' handle for background stars
   BITMAPSOURCE 250*1024   ' Starting address in gram
   BITMAPLAYOUT FT_L4 , 16, 32 ' format
   BITMAPSIZE NEAREST, REPEAT, REPEAT, 512, 512
   BITMAPHANDLE 14         ' handle for background stars
   BITMAPSOURCE 250*1024   ' Starting address in G_RAM
   BITMAPLAYOUT FT_L4, 16, 32 ' format
   BITMAPSIZE NEAREST, BORDER, BORDER, 32, 32
   UpdateScreen

   ' Touch Screen Calibration
   ClearScreen
   CmdText FT_DispWidth/2, FT_DispHeight/2, 26, OPT_CENTERX OR OPT_CENTERY, "Please tap on a dot"
   CmdCalibrate

   ' Ftdi Logo animation
   CmdLogo
   WaitCmdFifoEmpty

   Do
      Temp2 = Rd16(REG_CMD_WRITE)
   Loop Until Temp2 = 0

   ftFifo_WritePtr = 0
   ftFreeSpaceLeft = 4092 ' (4096-4)

   dloffset = Rd16(REG_CMD_DL)
   dloffset = dloffset - 4
   ' Copy the Displaylist from DL RAM to GRAM
   CMDMEMCPY 100000, RAM_DL,dloffset

   'Enter into Info Screen
   Do

      ClearScreen
      CmdAppend 100000, dloffset

      'Reset the BITMAP properties used during Logo animation
      BITMAPTRANSFORM 256, "A"
      BITMAPTRANSFORM 0, "B"
      BITMAPTRANSFORM 0, "C"
      BITMAPTRANSFORM 0, "D"
      BITMAPTRANSFORM 256, "E"
      BITMAPTRANSFORM 0, "F"
      SAVECONTEXT
      ' Display the information with transparent Logo using Edge Strip
      COLORRGB 219,180,150
      COLOR_A 220
      BEGIN_G EDGE_STRIP_A
      VERTEX2F 0,FT_DispHeight*16
      VERTEX2F FT_DispWidth*16, FT_DispHeight*16
      COLOR_A 255
      RESTORECONTEXT
      COLORRGB 0,0,0

      ' INFORMATION
      CmdText FT_DispWidth/2, 20, 28, OPT_CENTERX OR OPT_CENTERY, "FT800 Sketch Application"
      CmdText FT_DispWidth/2, 60, 26, OPT_CENTERX OR OPT_CENTERY, "APP to demonstrate interactive Sketch,"
      CmdText FT_DispWidth/2, 90, 26, OPT_CENTERX OR OPT_CENTERY, "using Sketch, Slider & Buttons"
      CmdText FT_DispWidth/2, 140, 28, OPT_CENTERX OR OPT_CENTERY, "written using BASCOM Compiler"
      CmdText FT_DispWidth/2, FT_DispHeight-30, 26, OPT_CENTERX OR OPT_CENTERY, "Click to play"

      'Check the Play key and change the color
      If sk <> 80 Then ' "P"
         COLORRGB 255,255,255
      Else
         COLORRGB 100,100,100
      End if

      BEGIN_G FTPOINTS
      POINTSIZE 20 * 16
      TAG 80 ' "P"
      VERTEX2F (FT_DispWidth/2) * 16, (FT_DispHeight-60) * 16
      COLORRGB 180,35,35
      BEGIN_G BITMAPS
      VERTEX2II (FT_DispWidth/2) - 14, FT_DispHeight-75, 14, 4

      UpdateScreen

      tagx = Read_Keys()

   Loop Until tagx = 80 ' "P"


End Sub 'IntroFTDI

'-----------------------------------------------------------
Function Read_Keys() As Byte
'-----------------------------------------------------------

   Local Read_Tag  As Byte
   Local Ret_Tag   As Byte

   Read_Tag = Rd8(Reg_Touch_Tag)
   Ret_Tag  = 0


   If Read_Tag <> 0 And Temp_Tag <> Read_Tag Then    ' Allow if the Key is released

      Temp_Tag = Read_Tag
      Sk = Read_Tag        ' Load the Read tag to temp variable

   End If

   If Read_Tag =  0 Then

      Ret_Tag = Temp_Tag
      Temp_tag = 0
      Sk = 0

   End If

   Read_Keys = Ret_Tag

End Function ' Read_Keys

'------------------------------------------------------------------------------------------------------------
Home_Star_Icon: '460 items

   Data &H78,&H9C,&HE5,&H94,&HBF,&H4E,&HC2,&H40,&H1C,&HC7,&H7F,&H2D,&H04,&H8B,&H20,&H45,&H76,&H14,&H67,&HA3,&HF1,&H0D,&H64
   Data &H75,&HD2,&HD5,&H09,&H27,&H17,&H13,&HE1,&H0D,&HE4,&H0D,&H78,&H04,&H98,&H5D,&H30,&H26,&H0E,&H4A,&HA2,&H3E,&H82,&H0E
   Data &H8E,&H82,&HC1,&H38,&H62,&H51,&H0C,&H0A,&H42,&H7F,&HDE,&HB5,&H77,&HB4,&H77,&H17,&H28,&H21,&H26,&H46,&HFD,&H26,&HCD
   Data &HE5,&HD3,&H7C,&HFB,&HBB,&HFB,&HFD,&HB9,&H02,&HCC,&HA4,&HE8,&H99,&H80,&H61,&HC4,&H8A,&H9F,&HCB,&H6F,&H31,&H3B,&HE3
   Data &H61,&H7A,&H98,&H84,&H7C,&H37,&HF6,&HFC,&HC8,&HDD,&H45,&H00,&HDD,&HBA,&HC4,&H77,&HE6,&HEE,&H40,&HEC,&H0E,&HE6,&H91
   Data &HF1,&HD2,&H00,&H42,&H34,&H5E,&HCE,&HE5,&H08,&H16,&HA0,&H84,&H68,&H67,&HB4,&H86,&HC3,&HD5,&H26,&H2C,&H20,&H51,&H17
   Data &HA2,&HB8,&H03,&HB0,&HFE,&H49,&HDD,&H54,&H15,&HD8,&HEE,&H73,&H37,&H95,&H9D,&HD4,&H1A,&HB7,&HA5,&H26,&HC4,&H91,&HA9
   Data &H0B,&H06,&HEE,&H72,&HB7,&HFB,&HC5,&H16,&H80,&HE9,&HF1,&H07,&H8D,&H3F,&H15,&H5F,&H1C,&H0B,&HFC,&H0A,&H90,&HF0,&HF3
   Data &H09,&HA9,&H90,&HC4,&HC6,&H37,&HB0,&H93,&HBF,&HE1,&H71,&HDB,&HA9,&HD7,&H41,&HAD,&H46,&HEA,&H19,&HA9,&HD5,&HCE,&H93
   Data &HB3,&H35,&H73,&H0A,&H69,&H59,&H91,&HC3,&H0F,&H22,&H1B,&H1D,&H91,&H13,&H3D,&H91,&H73,&H43,&HF1,&H6C,&H55,&HDA,&H3A
   Data &H4F,&HBA,&H25,&HCE,&H4F,&H04,&HF1,&HC5,&HCF,&H71,&HDA,&H3C,&HD7,&HB9,&HB2,&H48,&HB4,&H89,&H38,&H20,&H4B,&H2A,&H95
   Data &H0C,&HD5,&HEF,&H5B,&HAD,&H96,&H45,&H8A,&H41,&H96,&H7A,&H1F,&H60,&H0D,&H7D,&H22,&H75,&H82,&H2B,&H0F,&HFB,&HCE,&H51
   Data &H3D,&H2E,&H3A,&H21,&HF3,&H1C,&HD9,&H38,&H86,&H2C,&HC6,&H05,&HB6,&H7B,&H9A,&H8F,&H0F,&H97,&H1B,&H72,&H6F,&H1C,&HEB
   Data &HAE,&HFF,&HDA,&H97,&H0D,&HBA,&H43,&H32,&HCA,&H66,&H34,&H3D,&H54,&HCB,&H24,&H9B,&H43,&HF2,&H70,&H3E,&H42,&HBB,&HA0
   Data &H95,&H11,&H37,&H46,&HE1,&H4F,&H49,&HC5,&H1B,&HFC,&H3C,&H3A,&H3E,&HD1,&H65,&H0E,&H6F,&H58,&HF8,&H9E,&H5B,&HDB,&H55
   Data &HB6,&H41,&H34,&HCB,&HBE,&HDB,&H87,&H5F,&HA9,&HD1,&H85,&H6B,&HB3,&H17,&H9C,&H61,&H0C,&H9B,&HA2,&H5D,&H61,&H10,&HED
   Data &H2A,&H9B,&HA2,&H5D,&H61,&H10,&HED,&H2A,&H9B,&HA2,&H5D,&H61,&H10,&HED,&H2A,&H9B,&HED,&HC9,&HFC,&HDF,&H14,&H54,&H8F
   Data &H80,&H7A,&H06,&HF5,&H23,&HA0,&H9F,&H41,&HF3,&H10,&H30,&H4F,&H41,&HF3,&H18,&H30,&HCF,&HCA,&HFC,&HFF,&H35,&HC9,&H79
   Data &HC9,&H89,&HFA,&H33,&HD7,&H1D,&HF6,&H5E,&H84,&H5C,&H56,&H6E,&HA7,&HDA,&H1E,&HF9,&HFA,&HAB,&HF5,&H97,&HFF,&H2F,&HED
   Data &H89,&H7E,&H29,&H9E,&HB4,&H9F,&H74,&H1E,&H69,&HDA,&HA4,&H9F,&H81,&H94,&HEF,&H4F,&HF6,&HF9,&H0B,&HF4,&H65,&H51,&H08