' FT800 Keyboard
' This application is a Keyboard Demonstration
' using CmdButtons (FT800 platform).
' Ported from http://www.ftdichip.com/Support/SoftwareExamples/EVE/FT_App_Keyboard.zip
' Requires Bascom 2.0.7.8 or greater

$Regfile = "M328pdef.dat"
$Crystal = 8000000
$Baud = 19200
$HwStack = 90
$SwStack = 90
$FrameSize = 400
$NOTYPECHECK

'Config ft800=spi , ftsave=0, ftdebug=0 , ftcs=portb.0 ', platform=gameduino2, lcd_rotate=1 ' Gameduino2
Config Ft800 = Spi , Ftsave = 0 , Ftdebug = 0 , Ftcs = Portd.4 , Ftpd = Portd.3  ' 4D AdamShield
'Config Ft800 = Spi , Ftcs = Portb.1 , Ftpd = Portd.4 ' VM801P

Config Submode = New
Config Spi = Hard , Interrupt = Off , Data_Order = Msb , Master = Yes , Polarity = Low , Phase = 0 , Clockrate = 4, Noss = 1
SPSR = 1  ' Makes SPI run at 8Mhz instead of 4Mhz

$Include "FT80x.inc"
$Include "FT80x_Functions.inc"

Declare Sub Notepad
Declare Function Read_Keypad() As Byte
Declare Function Read_Keys() As Byte
Declare Function Ft_Gpu_Rom_Font_WH (Byval CharAsc As Byte, Byval font As Byte) As Byte
Declare Function istouch() As Byte
Declare Sub IntroFTDI

Const SPECIAL_FUN = 251
Const BACK_SPACE  = 251      ' Back space
Const CAPS_LOCK   = 252      ' Caps Lock
Const NUMBER_LOCK = 253      ' Number Lock
Const BACK        = 254      ' Clear
Const Font        = 27       ' Font Size
Const MAX_LINES   = 4
Const LINE_STARTPOS = FT_DispWidth/50     ' Start of Line
Const LINE_ENDPOS   = FT_DispWidth
Const MaxPixelsPerLIne  = (LINE_ENDPOS - LINE_STARTPOS)

Key_Detect Alias 0
Caps       Alias 1
Numeric    Alias 2

' General Program Variables and Declarations
Dim Temp1      As Byte
Dim temp_tag   As Byte
Dim touch_detect As Byte
Dim Flag       As Byte
Dim LastChr    AS String * 1
Dim fontx      As Byte
Dim notepadx(MAX_LINES) As String * 80
Dim PixelsInLine(MAX_LINES) As Integer
Dim Read_sfk   As Byte
Dim tval       As Byte
Dim But_opt    As Word
Dim HowManyChars As Byte
Dim line2disp  As Integer
Dim nextline   As Integer
Dim MaxPixelsWide   As Integer
Dim LastWidth  As Byte
Dim Char       As String * 10

Spiinit

touch_detect = 1
notepadx  = ""
fontx     = 27              ' Font Size
line2disp = 1
nextline  = 1
MaxPixelsWide  = MaxPixelsPerLIne
LastWidth = 0

if FT800_Init()=1 then end   ' Initialise the FT800

IntroFTDI

Do

   Gosub Notepad

Loop


End

'------------------------------------------------------------------------------------------------------------
Notepad:
'------------------------------------------------------------------------------------------------------------

   ' intial setup

   Read_sfk = Read_Keypad()            ' read the keys

   If Flag.Key_Detect > 0 Then         ' check if key is pressed

      Flag.Key_Detect = 0              ' clear it

      If Read_sfk >= SPECIAL_FUN Then  ' check any special function keys are pressed

         Select Case Read_sfk

            Case BACK_SPACE

               ' Check we have room to delete a characters or it has to be deleted on the previous line
               HowManyChars = Len(notepadx(line2disp))

               If HowManyChars > 1 Then

                  LastChr = Right(notepadx(line2disp), 1)
                  Read_sfk = Asc(LastChr)
                     'Get the current width of the character

                  tval = Ft_Gpu_Rom_Font_WH(Read_sfk, font)

                  Decr HowManyChars
                  notepadx(line2disp) = Left(notepadx(line2disp), HowManyChars)

                  PixelsInLine(line2disp) = PixelsInLine(line2disp) - tval
               Else
                  PixelsInLine(line2disp) = 0
                  notepadx(line2disp) = ""
                  If line2disp > 1 Then Decr line2disp

               End If


            Case CAPS_LOCK
               Toggle Flag.Caps                    ' toggle the caps lock on when the detected

            Case NUMBER_LOCK
               Toggle Flag.Numeric                 ' toggle the number lock on when detected

            Case BACK
               line2disp = 1
               notepadx(1) = ""
               notepadx(2) = ""
               notepadx(3) = ""
               notepadx(4) = ""
               PixelsInLine(1) = 0
               PixelsInLine(2) = 0
               PixelsInLine(3) = 0
               PixelsInLine(4) = 0
               LastWidth = 0
               HowManyChars = 0

         End Select

      Else

         'Get the current width of the character
         tval = Ft_Gpu_Rom_Font_WH(Read_sfk, font)

         ' Check that the Width of all the characters
         ' in the current line don't exceed the Length of 'MaxPixelsPerLIne'
         PixelsInLine(line2disp) = PixelsInLine(line2disp) + tval

         If PixelsInLine(line2disp) > MaxPixelsWide Then

            ' remove the last width from previous
            PixelsInLine(line2disp) = PixelsInLine(line2disp) - tval

            If line2disp < MAX_LINES Then
               Incr line2disp
               ' Add the pixels to the next line
               PixelsInLine(line2disp) = PixelsInLine(line2disp) + tval
            End If

         Else

            notepadx(line2disp) = notepadx(line2disp) + Chr(Read_sfk)

         End If

      End if

   End IF

   ' Start the new Display list
   ClearColorRGB 100, 100, 100
   Clear_B 1, 1, 1
   COLORRGB 255, 255,255
   TagMask 1                  ' Enable tagbuffer update
   CmdFgColor &H703800
   CmdBgColor &H703800

   If Read_sfk = BACK Then
      But_opt = OPT_FLAT
   Else
      But_opt = 0             ' Button color change if the button during press
   End if

   TAG BACK                   ' Back   Return to Home
   CmdButton FT_DispWidth*0.850 , FT_DispHeight*0.83, FT_DispWidth*0.146, FT_DispHeight*0.112, font, But_opt, "Clear"

   If Read_sfk = BACK_SPACE Then
      But_opt = OPT_FLAT
   Else
      But_opt = 0
   End If

   TAG BACK_SPACE             ' BackSpace
   CmdButton  FT_DispWidth*0.871, FT_DispHeight*0.70, FT_DispWidth*0.125, FT_DispHeight*0.112, font, But_opt,"<-"

   If Read_sfk = 32 Then
      But_opt = OPT_FLAT
   Else
      But_opt = 0
   End if

   TAG 32                     ' Space
   CmdButton FT_DispWidth*0.115, FT_DispHeight*0.83, FT_DispWidth*0.73, FT_DispHeight*0.112, font,But_opt, "Space"

   If Flag.Numeric =  0 Then

      If Flag.Caps = 1 Then Char = "QWERTYUIOP" Else Char = "qwertyuiop"
      CmdKeys 0, FT_DispHeight * 0.442, FT_DispWidth-2, FT_DispHeight*0.112, font,Read_sfk, Char

      If Flag.Caps = 1 Then Char = "ASDFGHJKL" Else Char = "asdfghjkl"
      CmdKeys FT_DispWidth*0.036, FT_DispHeight*0.57, FT_DispWidth*0.96, FT_DispHeight*0.112,font, Read_sfk,Char

      If Flag.Caps = 1 Then Char = "ZXCVBNM" Else Char = "zxcvbnm"
      CmdKeys FT_DispWidth*0.125, FT_DispHeight*0.70, FT_DispWidth*0.73, FT_DispHeight*0.112, font,Read_sfk, Char


      If Read_sfk = CAPS_LOCK Then
         But_opt = OPT_FLAT
      Else
         But_opt = 0
      End if

      TAG CAPS_LOCK ' Capslock
      CmdButton 0, FT_DispHeight * 0.70, FT_DispWidth*0.10, FT_DispHeight*0.112, font,But_opt, "a^"

      If Read_sfk = NUMBER_LOCK Then
         But_opt = OPT_FLAT
      Else
         But_opt = 0
      End If

      TAG NUMBER_LOCK         ' Num lock
      CmdButton 0, FT_DispHeight * 0.83, FT_DispWidth*0.10, FT_DispHeight*0.112, font,But_opt,"12*"
   End If

   If Flag.Numeric = 1 Then

      CmdKeys 0, FT_DispHeight * 0.442, FT_DispWidth-2, FT_DispHeight*0.112, font,Read_sfk, "1234567890"
      CmdKeys FT_DispWidth*0.036, FT_DispHeight*0.57, FT_DispWidth*0.96, FT_DispHeight*0.112, font,Read_sfk,"-@#$%^&*("
      CmdKeys FT_DispWidth * 0.125, FT_DispHeight * 0.70, FT_DispWidth * 0.73, FT_DispHeight*0.112, font,Read_sfk,")_+[]{}"

      If Read_sfk = NUMBER_LOCK Then
         But_opt = OPT_FLAT
      Else
         But_opt = 0
      End IF

      TAG 253
      CmdButton 0, FT_DispHeight * 0.83, FT_DispWidth * 0.10, FT_DispHeight*0.112, font,But_opt, "AB*"
   End if

   TagMask 0                  ' Disable the tag buffer updates
   ScissorXY 0,0
   ScissorSize FT_DispWidth, FT_DispHeight * 0.405
   ClearColorRGB 255,255,255
   Clear_B 1, 1, 1
   ColorRGB 0,0,0             ' Text Color

   Const S8 = FT_DispHeight * .073
   nextline = 1

   For Temp1 = 1 to line2disp

      If Temp1 = line2disp Then
         CmdText 1, nextline, font, 0, notepadx(Temp1) + "_"
      Else
         CmdText Temp1, nextline, font, 0, notepadx(Temp1)
      End IF
      nextline = nextline + S8
      nextline = nextline + 3

   Next

   UpdateScreen

Return ' NotePad

'------------------------------------------------------------------------------------------------------------
Function Ft_Gpu_Rom_Font_WH (Byval CharAsc As Byte, Byval font As Byte) As Byte
'------------------------------------------------------------------------------------------------------------

   Local ptr   As Dword
   Local Wptr  As Dword
   Local Width As Byte
   Local TempB As Byte

   ptr = Rd32(&HFFFFC)
   TempB = font - 16     ' table starts at font 16
   Wptr = 148 * TempB
   Wptr = Wptr + ptr
   Wptr = Wptr + CharAsc
   ' Read Width of the character
   Width = Rd8(Wptr)

   Ft_Gpu_Rom_Font_WH = Width

End Function ' Ft_Gpu_Rom_Font_WH

'------------------------------------------------------------------------------------------------------------
Function Read_Keypad() As Byte
'------------------------------------------------------------------------------------------------------------
   Local Read_tag   As Byte

   Read_tag = Rd8(Reg_Touch_Tag)

   If istouch() = 0 Then touch_detect = 0

   If Read_tag <> 0 Then   ' Allow if the Key is released

      If temp_tag <> Read_tag AND touch_detect = 0 Then

         temp_tag = Read_tag  ' Load the Read tag to temp variable
         Play_Sound &H51,100
         touch_detect = 1
      End If

   Else

      If temp_tag <> 0 Then
         Flag.Key_Detect = 1
         Read_tag = temp_tag
      End If

      temp_tag = 0

   End If

   Read_Keypad = Read_tag

End Function ' Read_Keypad

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
Function istouch() As Byte
'------------------------------------------------------------------------------------------------------------
   Local RetIstouch As Word

   RetIstouch = Rd16(Reg_Touch_Raw_XY)
   RetIstouch = RetIstouch AND &H8000

   istouch = RetIstouch

End Function ' istouch

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
      CmdText FT_DispWidth/2, 20, 28, OPT_CENTERX OR OPT_CENTERY, "FT800 Gauges Application"
      CmdText FT_DispWidth/2, 60, 26, OPT_CENTERX OR OPT_CENTERY, "APP to demonstrate interactive Key Board,"
      CmdText FT_DispWidth/2, 90, 26, OPT_CENTERX OR OPT_CENTERY, "using String, Keys & Buttons."
      CmdText FT_DispWidth/2, 140, 28, OPT_CENTERX OR OPT_CENTERY,"written using BASCOM Compiler"
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