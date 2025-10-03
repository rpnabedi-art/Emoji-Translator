' FT800 Gauges Application demonstrating interactive Gauges using Lines & Custom Font
' FT800 platform.
' Original code from http://www.ftdichip.com/Support/SoftwareExamples/EVE/FT_App_Gauges.zip
' Requires Bascom 2.0.7.8 or greater
$Regfile = "M328pdef.dat"
$Crystal = 16000000
$Baud = 57600
$HwStack = 90
$SwStack = 90
$FrameSize = 300
$NOTYPECHECK

'Config ft800=spi , ftsave=0, ftdebug=0 , ftcs=portb.0 ', platform=gameduino2, lcd_rotate=1 ' Gameduino2
Config Ft800 = Spi , Ftsave = 0 , Ftdebug = 0 , Ftcs = Portd.4 , Ftpd = Portd.3  ' 4D AdamShield
'Config Ft800 = Spi , Ftcs = Portb.1 , Ftpd = Portd.4 ' VM801P

Config Base = 0
Config Submode = NEW
Config Spihard = Hard , Interrupt = Off , Data_Order = Msb , Master = Yes , Polarity = Low , Phase = 0 , Clockrate = 4, Noss = 1
SPSR = 1  ' Makes SPI run at 8Mhz instead of 4Mhz


' Swaps Scales
' 1 = Resitive - Random
' 0 = Random   - Resistive
Const Resistive = 1

#If Resistive = 0
   Const First = 1
   Const Second = 0
#Else
   Const First = 0
   Const Second = 1
#EndIf

$Include "FT80x.inc"
$Include "FT80x_Functions.inc"

Declare Sub cs(Byval i As Byte)
Declare Function da (Byval i As Long) As Word
Declare Sub Polar(byval R As Long , Byval Th As Word)
Declare Sub Polarxy(byval R As Long , Byval Th As Word , Byref X As Long , Byref Y As Long)
Declare Sub IntroFTDI
Declare Sub Gauges
Declare Function Read_Keys() As Byte

' General Program Variables and Declarations
Dim temp_tag  As Byte
Dim ox As Long

#if FT_LCDSCREEN = 480272
   Const noofch = 2
   Const dt = 10
#Else
   Const noofch = 1
   Const dt = 50
#endif

Const A5 = FT_DispWidth / (2 * noofch)

Spiinit

if FT800_Init()=1 then end   ' Initialise the FT800

 '  IntroFTDI

Gauges

Do
Loop

End


'------------------------------------------------------------------------------------------------------------
Sub Gauges
'------------------------------------------------------------------------------------------------------------
   ' Draw the Gauges

   Local w As Word
   Local h As Word
   Local n As Word
   Local value As Word
   Local a As Word
   Local th As Word
   Local tval As Word
   Local dloffset As Word

   Local rval As Long
   Local tgt  As Long
   Local x    As Long
   Local y    As Long
   Local tx   As Long
   Local ty   As Long
   Local o    As Long
   Local d    As Long

   Local i  As Byte
   Local bi As Byte
   Local z  As Byte

   Local D2 as Integer
   Local D3 as Integer

   value = 0
   w = 220
   h = 130

  ' Clear GRAM
   CmdMemSet 0, 0, 10 * 1024
   WaitCmdFifoEmpty

   ' Load the deflated icons to GRAM via J1
   TempDW = LoadLabel(digits)
   CmdInflateX 0, TempDW, 6358

   ClearScreen

   ' Set the bitmap properties
   CmdSetFont 13, 0
   BitmapHandle 13
   BitmapSource 144 - (32 * (54/2) * 87 )
   BitmapLayout FT_L4, 54/2, 87
   BitmapSize NEAREST, BORDER, BORDER, 54, 87
   UpdateScreen

   ' Construct the Gauge background
   ClearColorRGB 55, 55, 55
   Clear_B 1,1,1
   ClearColorRGB 0,0,0
   y = 10
   D2 = FT_DispWidth / w
   D2 = D2 - 1

   For z = 0 TO D2

      ox = 240 * z

      ScissorXY ox + dt, y
      ScissorSize w, h
      Clear_B 1, 1, 1
      Begin_G LINES
      LineWidth 10

      ' Puts the gradiations/pips in Meter Scale
      For bi = 0 TO 80 Step 10
         cs bi
         For i = 2 TO 9 Step 2
            a = da(bi + i)
            polar 220, a
            polar 240, a
         Next
      Next

      ' Major Tick Thickness
      LineWidth 16

      ' Puts the Major graduations/pips
      For i = 0 to 90 Step 10
         cs i
         a = da(i)
         polar 220, a
         polar 250, a

      Next

      ' Color for Scale Numbers and Resistance/Random words
      ColorRGB 255,255,255

      ' Places Numbers above Scale
      For i = 0 to 90 Step 10
         a = da(i)
         polarxy 260, a, tx, ty
         Shift tx, Right ,4
         Shift ty, Right ,4
         CmdNumber tx, ty, 26, OPT_CENTER, i
      Next

      ox = FT_DispWidth / noofch
      ox = z * ox
      ox = ox + A5

      ' Names below Scales
      If z = First  Then CmdText ox, h-10, 28, OPT_CENTERX, "Resistance"
      If z = Second Then CmdText ox, h-10, 28, OPT_CENTERX, "Random"

   Next

   WaitCmdFifoEmpty

   ' Copy the displaylist from DLRAM to GRAM
   dloffset =  Rd16(REG_CMD_DL)
   CmdMemCpy 100000, RAM_DL, dloffset

   y = 10 + 120
   y = y + 20
   rval = 0
   tgt  = 4500

   Do

      ' Start the New Displaylist
      CmdAppend 100000, dloffset

      D3 = FT_DispWidth / w

      For z = 0 to D3 -1

         ox = FT_DispWidth/2
         ox = ox * z

         ' Resistive Display
         If z = First Then

            value = Rd16(REG_TOUCH_RZ)
            'value = 10 * min(899,value)
            If 899 <= value Then
               value = 10 * 899
            Else
               value = 10 * value
            End If

         Else

            ' Random Display
            If z = Second Then

               d = tgt - rval
               d = d / 16
               rval = rval + d
               value = rval
               ' 9000 is the max scale range
               If Rnd(60) = 0 Then tgt = Rnd(9000)

            End If

         End if

         ' Scissor the Value display position
         ScissorXY ox + dt, 10
         ScissorSize w, 120
         ColorRGB 255, 255, 255
         Begin_G LINES
         LineWidth 10

         ' original calc was
         ' th = (value - 4500) * 32768 / 36000
         o = value - 4500
         o = o * 32768
         o = o / 36000
         th = o

         For o = -5  to  5
            D2 = o
            Shift D2, Left, 5
            polar 170, th + D2
            polar 235, th
         Next

         ScissorXY ox + dt, y
         ScissorSize w, FT_DispHeight * 0.36
         Clear_B 1, 1, 1
         ColorRGB 255, 0, 0
         D2 = ox + dt
         D2 = D2 + 10
         CmdNumber D2, 160, 13, 2, value / 100
         D2 = ox + dt
         D2 = D2 + 96
         CmdText D2, 160, 13, 0, "."
         D2 = ox + dt
         D2 = D2 + 106
         CmdNumber D2, 160, 13, 2, value Mod 100

      Next

      UpdateScreen

   Loop

End Sub ' Gauges

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
   ClearScreen
   COLORRGB 255, 255, 255
   BITMAPHANDLE 13         ' handle for background stars
   BITMAPSOURCE 250*1024   ' Starting address in gram
   BITMAPLAYOUT FT_L4, 16, 32 ' format
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

      CmdDlstart
      ClearScreen
      CmdAppend 100000, dloffset

      'Reset the BITMAP properties used during Logo animation
      BITMAPTRANSFORM 256,"A"
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
      CmdText FT_DispWidth/2, 20, 28, OPT_CENTERX OR OPT_CENTERY, "FT800 Gauges Application"
      CmdText FT_DispWidth/2, 60, 26, OPT_CENTERX OR OPT_CENTERY, "APP to demonstrate interactive Gauges,"
      CmdText FT_DispWidth/2, 90, 26, OPT_CENTERX OR OPT_CENTERY, "using Lines & custom Font."
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
Sub cs(Byval i As Byte)
'------------------------------------------------------------------------------------------------------------

   Select Case I

      case  0: COLORRGB 200,255,200
      case 60: COLORRGB 255,255,0
      case 80: COLORRGB 255,0,0

   End Select

End Sub ' cs

'------------------------------------------------------------------------------------------------------------
Function da (Byval i As Long) As Word
'------------------------------------------------------------------------------------------------------------
   Local F As Long

   F = i - 45
   F = F * 32768
   F = F / 360
   da = F

End Function ' da

'------------------------------------------------------------------------------------------------------------
Sub Polarxy(byval R As Long , Byval Th As Word , Byref X As Long , Byref Y As Long)
'------------------------------------------------------------------------------------------------------------

   Local Temp2 As Long
   Local Temp3 As Long

   ' Note uses 'ox' variable - external
   '*x = (16 * (FT_DispWidth/(2*noofch)) + (((long)r * qsin(th)) >> 11) + 16 * ox);
   '*y = (16 * 300 - (((long)r * qcos(th)) >> 11));

   Temp3 = Qsin(th) * R
   Shift Temp3 , Right , 11 , Signed

   Temp2 = Ox * 16
   Temp2 = Temp2 + Temp3

   Temp3 = 16 * A5
   X = Temp3 + Temp2

   Temp3 = Qcos(th) * R
   Shift Temp3 , Right , 11 , Signed

   ' 16 * 300 = 4800
   Y = 4800 - Temp3

End Sub ' Polarxy

'------------------------------------------------------------------------------------------------------------
Sub Polar(byval R As Long , Byval Th As Word)
'------------------------------------------------------------------------------------------------------------

   Local X As Long
   Local Y As Long

   Polarxy R , Th , X , Y
   Vertex2f X , Y

End Sub ' Polar

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

'------------------------------------------------------------------------------------------------------------
   $inc digits, nosize, "digits.fon"

'------------------------------------------------------------------------------------------------------------