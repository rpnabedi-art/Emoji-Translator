' FT800 Signals Application demonstrating drawing Signals using Strips, Points & Blend function
' FT800 platform.
' Original code from http://www.ftdichip.com/Support/SoftwareExamples/EVE/FT_App_Signals.zip
' Requires Bascom 2.0.7.8 or greater

$Regfile = "M328pdef.dat"
$Crystal = 8000000
$Baud = 19200
$HwStack = 90
$SwStack = 90
$FrameSize = 300
$NOTYPECHECK


Config ft800=spi , ftsave=0, ftdebug=0   , ftcs=portb.2, ftpd=portb.1

Config Submode = New
Config Spi = Hard, Interrupt = Off, Data_Order = Msb, Master = Yes, Polarity = Low, Phase = 0, Clockrate = 4, Noss = 1
SPSR = 1  ' Makes SPI run at 8Mhz instead of 4Mhz


$Include "FT800.inc"
$Include "FT800_Functions.inc"

Declare Function istouch() As Word
Declare Sub Sine_wave (Byval amp As Byte)
Declare Sub Triangle_wave(Byval amp As Byte)
Declare Sub Heartbeat
Declare Sub Signals
Declare Function Read_Keys() As Byte
Declare Sub IntroFTDI


Const A1 = FT_DispHeight/2

Const Volume = 10

Dim rate As Byte
Dim x As Integer
Dim y As Integer
Dim tx As Integer
Dim add2write As Word
Dim beats(10) As Byte
Dim beats_Incr(10) As Integer
Dim temp (FT_DispHeight) As Byte

Dim temp_x As Word
Dim temp_p As Word
Dim temp_y As Word
Dim en     As Word

Dim dc As Byte
Dim p  As Byte

Dim Sk  As Byte
Dim Temp_Tag  As Byte

Dim played As Byte
Dim change As Byte

Dim tempW1 As Word
Dim pk As Byte

Dim tempa As Integer
Dim tempb As Integer
Dim tempi1 As Integer
Dim tempi2 As Integer
Dim tempi3 As Integer
Dim tempi4 As Integer
Dim tempi5 As Integer
Dim templ1 As long
Dim templ2 As Long
Dim tempdw1 As Dword
Dim tempdw2 As Dword

beats_Incr(1) = -10
beats_Incr(2) = 10
beats_Incr(3) = 5
beats_Incr(4) = -5
beats_Incr(5) = -20
beats_Incr(6) = 20
beats_Incr(7) = 12
beats_Incr(8) = -12
beats_Incr(9) = -5
beats_Incr(10) = 5

rate = 1

Spiinit

if FT800_Init()=1 then end   ' Initialise the FT800

IntroFTDI

Signals

Do
Loop

End

'------------------------------------------------------------------------------------------------------------
Sub Signals
'------------------------------------------------------------------------------------------------------------
' waves application

   Local i As Integer
   Local xx As Integer
   Local tval As Word
   Local th_cts As Word
   Local amp As Word
   Local hide_x As Byte
   Local tagx As Byte
   Local opt As Byte

   opt = 3  ' Default startup signal
   hide_x = 0
   xx = 0
   th_cts = 0

   ' Background shadeing to LCD
   For tval = 1 to A1 ' A1 = FT_DispHeight/2
      temp(tval) = tval * 0.90
      temp(FT_DispHeight - tval) = temp(tval)
   Next

   RdMem_WrFT800 2048, temp(0+_base), FT_DispHeight

   y = A1 ' A1 = FT_DispHeight/2

   For tval = 1 to 10
      i = beats_Incr(tval)
      i = i * 5
      y = y + i
      beats(tval) = y
   Next

   For tval = 1 to FT_DispWidth step rate
      i = tval / rate
      i = i * 4
      i = i + RAM_G

      tempi1 = tval * 16
      tempdw1 = tempi1 AND &H7FFF
      Shift tempdw1, Left, 15

      tempi2 = y * 16
      tempdw2 = tempi2 AND &H7FFF
      W32 = tempdw1 OR tempdw2
      Set W32.30

      Wr32 i, W32

   Next

   BitmapSource 2048
   BitmapLayout L8,1,FT_DispHeight
   BitmapSize NEAREST, REPEAT, BORDER, FT_DispWidth, FT_DispHeight
   UpdateScreen

   Do
      ' Menu
      If istouch() = 0 Then

         hide_x = 0
         th_cts = 0

      Else

         Incr th_cts

         If th_cts > 250 Then

            IF hide_x < 85 Then
               Incr hide_x
            End If

         End If

      End If

      ' Option
      tagx = Read_keys()

      IF tagx <> 0 Then

         x = 0: temp_p = 0: en = 0: temp_x = 0: temp_y = 0

         If tagx > 2 Then opt = tagx

         If tagx = 1 Then
            If rate > 1 Then decr rate
         End If

         If tagx = 2 Then
            If rate < 6 Then Incr rate
         End If

         y = A1

         For tval = 1 to FT_DispWidth step rate

            ' Ft_Gpu_Hal_Wr32(phost, RAM_G+(tval/rate)*4, VERTEX2F(x*16,y*16));
            tempi3 = tval / rate
            tempi3 = tempi3 + RAM_G
            tempi3 = tempi3 * 4

            tempi1 = x * 16
            tempdw1 = tempi1 AND &H7FFF
            Shift tempdw1, Left, 15

            tempi2 = y * 16
            tempdw2 = tempi2 AND &H7FFF

            W32 = tempdw1 Or tempdw2
            Set W32.30
            Wr32 tempi3, W32

         Next

      End If

      ' Signals
      amp = 100
      Select Case opt

         CASE 6
            amp = 50
            Heartbeat

         CASE 5
            Triangle_wave amp

         CASE 4
            Sawtooth_wave amp

         CASE 3
            Sine_wave amp

      End Select

      ' Start of Display List
      Clear_B 1, 1, 1
      ColorRGB &H12, &H4A, &H26
      TagMask 1
      LineWidth 2 * 16
      Begin_G BITMAPS
      Tag 0
      Vertex2f 0, 0
      ColorRGB &H1B, &HE0, &H67
      Begin_G LINE_STRIP
      ' Append first few datas of GRAM data to Displaylist
      tempdw1 = x / rate
      tempdw1 = tempdw1 * 4
      CmdAppend RAM_G, tempdw1
      Begin_G LINE_STRIP

      ' Eliminate some bytes of GRAM data to the display list
      ' if ( (x/rate) < (FT_DispWidth/rate) - (50/rate))

      tempi1 = x / rate
      tempi2 = FT_DispWidth / rate
      tempi3 = 50 /rate
      tempi4 = tempi2 - tempi3

      IF tempi1 < tempi4 Then

         ' RAM_G + (x/rate) * 4 + ((50/rate)*4), ((FT_DispWidth/rate) * 4) - ((x/rate) * 4) - ((50/rate) * 4))

         tempi4 = tempi2 * 4 ' (FT_DispWidth/rate) * 4
         tempi5 = tempi3 * 4 ' (50/rate) * 4
         tempi3 = tempi1 * 4 ' (x/rate) * 4

         tempdw1 = RAM_G + tempi3   ' RAM_G + ((x/rate) * 4)
         tempdw1 = tempdw1 + tempi5 ' +  ((50/rate) * 4)

         tempdw2 = tempi4 - tempi3  ' ((FT_DispWidth/rate) * 4) - ((x/rate) * 4)
         tempdw2 = tempdw2 - tempi5 ' - ((50/rate) * 4))
         CmdAppend tempdw1, tempdw2

      End If

      PointSize 6 * 16
      Begin_G FTPOINTS
      Vertex2f x * 16, y * 16
      ColorRGB &Hff, &Hff, &Hff
      Color_A 100

      ' menu
      Begin_G EDGE_STRIP_R
      Const A2 = FT_DispWidth-80
      tempdw1 = hide_x + A2
      tempdw1 = tempdw1 * 16
      Vertex2f tempdw1, 0
      Vertex2f tempdw1, FT_DispHeight * 16
      Color_A 50
      PointSize 15 * 16
      Begin_G FTPOINTS

      If Sk = 1 Then Color_A 150
      Tag 1
      Const A3 = FT_DispWidth - 60
      tempdw1 = hide_x + A3
      tempdw1 = tempdw1 * 16
      Vertex2f tempdw1, 20 * 16
      Color_A 50

      If Sk = 2 Then Color_A 150
      Tag 2
      Const A4 = FT_DispWidth - 20
      tempdw1 = hide_x + A4
      tempdw1 = tempdw1 * 16
      Vertex2f tempdw1, 20 * 16
      Color_A 255

      Const A5 = FT_DispWidth - 70
      RadioButton hide_x + A5, FT_DispHeight - 80, &Hffffff, 0, 8, 6, opt
      RadioButton hide_x + A5, FT_DispHeight - 60, &Hffffff, 0, 8, 3, opt
      RadioButton hide_x + A5, FT_DispHeight - 40, &Hffffff, 0, 8, 4, opt
      RadioButton hide_x + A5, FT_DispHeight - 20, &Hffffff, 0, 8, 5, opt

      TagMask 0

      Const A6 = FT_DispWidth - 80
      Const A7 = FT_DispWidth - 30
      Const A8 = FT_DispWidth - 40

      CmdText hide_x + A3, FT_DispHeight - 80, 26, OPT_CENTERY,"ECG"
      CmdText hide_x + A3, FT_DispHeight - 60, 26, OPT_CENTERY,"Sine"
      CmdText hide_x + A3, FT_DispHeight - 40, 26, OPT_CENTERY,"Sawtooth"
      CmdText hide_x + A3, FT_DispHeight - 20, 26, OPT_CENTERY,"Triangle"

      CmdText hide_x + A3, 20, 30, OPT_CENTERY OR OPT_CENTERX,"-"
      CmdText hide_x + A4, 20, 30, OPT_CENTERY OR OPT_CENTERX,"+"
      CmdText hide_x + A6, 50, 28, 0, "Rate:"
      CmdNumber hide_x + A7, 50, 28, 0, rate
      CmdText hide_x + A6, 80, 28, 0, "Pk:"
      CmdNumber hide_x + A8, 80, 28, 0,amp

      UpdateScreen

   Loop


End Sub ' Signals

'------------------------------------------------------------------------------------------------------------
Sub Sine_wave (Byval amp As Byte)
'------------------------------------------------------------------------------------------------------------

   ' Generate the Sine wave

   Local temp1 As Long

   x = x + rate

   IF x > FT_DispWidth Then x = 0

   ' y = (FT_DispHeight/2) + ((ft_int32_t)amp * qsin(-65536 * x /(25*rate)) / 65536)
   tempi1 = 25 * rate
   templ1 = -65536 * x
   templ1 = templ1 / tempi1
   templ2 = qsin (templ1)

   templ1 = amp * templ2
   templ1 = templ1 /65536
   templ1 = templ1 + A1
   y = templ1

   IF played = 0 AND change < y Then
      played = 1
      Play_Sound 27664, Volume
   End If

   IF change > y Then played = 0

   change = y

   ' Ft_Gpu_Hal_Wr16(phost, RAM_G+(x/rate)*4, VERTEX2F(x*16,y*16));
   tempi3 = x / rate
   tempi3 = tempi3 + RAM_G
   tempi3 = tempi3 * 4

   tempi1 = x * 16
   tempdw1 = tempi1 AND &H7FFF
   Shift tempdw1, Left, 15

   tempi2 = y * 16
   tempdw2 = tempi2 AND &H7FFF

   W32 = tempdw1 Or tempdw2
   Set W32.30

   Wr32 tempi3, W32

End Sub ' Sine_wave

'------------------------------------------------------------------------------------------------------------
Sub Sawtooth_wave(Byval amp As Byte)
'------------------------------------------------------------------------------------------------------------

   ' Generate the sawtooth wave

   x = x +rate

   IF x > FT_DispWidth Then x = 0

   tempW1 = tempW1 + 2

   If tempW1 > 65535 Then tempW1 = 0

   y = tempW1 MOD amp

   pk = amp - 2
   pk = y / pk
   IF pk > 0 Then Play_Sound 27664, Volume

   y = A1 - y

   ' Ft_Gpu_Hal_Wr16(phost, RAM_G+(x/rate)*4, VERTEX2F(x*16,y*16));
   tempi3 = x / rate
   tempi3 = tempi3 + RAM_G
   tempi3 = tempi3 * 4

   tempi1 = x * 16
   tempdw1 = tempi1 AND &H7FFF
   Shift tempdw1, Left, 15

   tempi2 = y * 16
   tempdw2 = tempi2 AND &H7FFF

   W32 = tempdw1 Or tempdw2
   Set W32.30

   Wr32 tempi3, W32

End Sub ' Sawtooth_wave

'------------------------------------------------------------------------------------------------------------
Sub Triangle_wave(Byval amp As Byte)
'------------------------------------------------------------------------------------------------------------

   ' Generate the Triangle wave

   x = x + rate

   If x > FT_DispWidth Then x = 0

   tempW1 = tempW1 + 2

   If tempW1 > 65535 Then tempW1 = 0

   y = tempW1 MOD amp

   tempi1 = amp - 2
   tempi2 = y / tempi1
   pk = tempi2 MOD 2

   tempi1 = tempW1 / amp
   dc = tempi1 MOD 2


   IF pk > 0 Then
      IF p = 0 Then
         p = 1
         Play_Sound 27664, Volume
      Else
         p = 0
      End If
   End If

   If dc > 0 Then
      tempi1 = amp - y
      y = A1 - tempi1
   Else
      y = A1 -  y
   End If

   ' Ft_Gpu_Hal_Wr16(phost, RAM_G+(x/rate)*4, VERTEX2F(x*16,y*16));
   tempi3 = x / rate
   tempi3 = tempi3 + RAM_G
   tempi3 = tempi3 * 4

   tempi1 = x * 16
   tempdw1 = tempi1 AND &H7FFF
   Shift tempdw1, Left, 15

   tempi2 = y * 16
   tempdw2 = tempi2 AND &H7FFF

   W32 = tempdw1 Or tempdw2
   Set W32.30

   Wr32 tempi3, W32

End Sub ' Triangle_wave

'------------------------------------------------------------------------------------------------------------
Sub Heartbeat
'------------------------------------------------------------------------------------------------------------

   ' Generate the ECG

   x = x + rate

   IF x > FT_DispWidth Then
      x = 0
      temp_p = 0
      temp_y = 0
      y = A1
      en = 0
      temp_x = 0
   End If

   tx = 5 * rate
   tempi1 = temp_x * temp_p
   tempi2 = temp_p + 1
   tempi2 = tx * temp_p
   tx = tx + tempi2
   tx = tx + tempi1

   If tx <= x Then
      IF en = 0 Then en = 1
   End IF

   If en = 1 Then

      If y <> beats(temp_y+1) Then

         tempi1 = 5 * beats_Incr(temp_y+1)
         y = y + tempi1

         tempi1 = beats_Incr(5) * 5
         tempi1 = tempi1 + A1
         If y = tempi1 Then Play_Sound 27664, Volume

         Else

         Incr temp_y

         IF temp_y > 9 Then
            temp_y = 0
            Incr temp_p
            en = 0
            temp_x = x - tx
         End If

      End If

   End If

   ' Ft_Gpu_Hal_Wr16(phost, RAM_G+(x/rate)*4, VERTEX2F(x*16,y*16));
   tempi3 = x / rate
   tempi3 = tempi3 + RAM_G
   tempi3 = tempi3 * 4

   tempi1 = x * 16
   tempdw1 = tempi1 AND &H7FFF
   Shift tempdw1, Left, 15

   tempi2 = y * 16
   tempdw2 = tempi2 AND &H7FFF

   W32 = tempdw1 Or tempdw2
   Set W32.30

   Wr32 tempi3, W32

End Sub ' Heartbeat

'------------------------------------------------------------------------------------------------------------
Function istouch() As Word
'------------------------------------------------------------------------------------------------------------
   Local RetIstouch As Word

   RetIstouch = Rd16(Reg_Touch_Raw_XY)
   RetIstouch = RetIstouch AND &H8000

   istouch = RetIstouch

End Function ' istouch()

'------------------------------------------------------------------------------------------------------------
Function Read_Keys() As Byte
'------------------------------------------------------------------------------------------------------------

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
Sub IntroFTDI
'------------------------------------------------------------------------------------------------------------

   Local TempW  As Dword
   Local dloffset As Word
   Local tagx    As Byte
   Local Temp2   As Byte

   ' Variables for Read_Keys()
   ' Dim Sk  As Byte < already in Main

    ' home_setup()
   TempW = LoadLabel(Home_Star_Icon)
   CMDINFLATEx 250*1024, TempW, 460

   'Set the Bitmap properties for the ICONS
   ClearScreen
   COLORRGB 255, 255, 255
   BITMAPHANDLE 13         ' handle for background stars
   BITMAPSOURCE 250*1024   ' Starting address in gram
   BITMAPLAYOUT L4, 16, 32 ' format
   BITMAPSIZE NEAREST, REPEAT, REPEAT, 512, 512
   BITMAPHANDLE 14         ' handle for background stars
   BITMAPSOURCE 250*1024   ' Starting address in G_RAM
   BITMAPLAYOUT L4, 16, 32 ' format
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
      BITMAPTRANSFORM 0,"B"
      BITMAPTRANSFORM 0,"C"
      BITMAPTRANSFORM 0,"D"
      BITMAPTRANSFORM 256,"E"
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
      CmdText FT_DispWidth/2,20,28,OPT_CENTERX OR OPT_CENTERY,"FT800 Signals Application"
      CmdText FT_DispWidth/2,60,26,OPT_CENTERX OR OPT_CENTERY,"APP to demonstrate drawing Signals,"
      CmdText FT_DispWidth/2,90,26,OPT_CENTERX OR OPT_CENTERY,"using Strips, Points & Blend function"
      CmdText FT_DispWidth/2,140,28,OPT_CENTERX OR OPT_CENTERY,"written using 'BASCOM' Compiler"
      CmdText FT_DispWidth/2,FT_DispHeight-30,26,OPT_CENTERX OR OPT_CENTERY,"Click to play"

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