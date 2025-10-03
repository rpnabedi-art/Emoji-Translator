' Demo Set 4
' FT800 platform.
' Original code http://www.ftdichip.com/Support/SoftwareExamples/EVE/FT800_SampleApp_1.0.zip
' Requires Bascom 2.0.7.8 or greater

$Regfile = "M328pdef.dat"
$Crystal = 16000000
$Baud = 57600
$HwStack = 128
$SwStack = 128
$FrameSize = 400
$NOTYPECHECK

'Config ft800=spi , ftsave=0, ftdebug=0 , ftcs=portb.0 ', platform=gameduino2, lcd_rotate=1 ' Gameduino2
Config Ft800 = Spi , Ftsave = 0 , Ftdebug = 0 , Ftcs = Portd.4 , Ftpd = Portd.3  ' 4D AdamShield
'Config Ft800 = Spi , Ftcs = Portb.1 , Ftpd = Portd.4 ' VM801P

Config Base = 0
Config Submode = New
Config Spi = Hard, Interrupt = Off, Data_Order = Msb, Master = Yes, Polarity = Low, Phase = 0, Clockrate = 4, Noss = 1
SPSR = 1  ' Makes SPI run at 8Mhz instead of 4Mhz

Declare Sub Screen (ByVal Characters As String)
Declare Sub Widget_Text
Declare Sub Widget_Number
Declare Sub Widget_Button
Declare Sub Append_Cmds
Declare Sub Sounds
Declare Sub Screensaver
Declare Sub Snapshot
Declare Sub Sketch
Declare Sub Matrix
Declare Sub Track
'Declare Function AVRDOSInit() As Byte

$Include "FT80x.inc"
$Include "FT80x_Functions.inc"

Const Header_Format = RGB565
Const Header_Width  = 40
Const Header_Height = 40
Const Header_Stride = 80
Const Header_Arrayoffset = 0

Const Chunk = 200  ' depending on the amount of memory you have, you can increase this value to help transfer bigger packets of data
Dim Dat As String * Chunk
Dim aDat(Chunk) As Byte At Dat Overlay
Dim Retn As Byte

Spiinit

if FT800_Init()=1 Then END    ' Initialise the FT800

'Cmdcalibratex

   '<< Un-Rem each demo to view >>
'------------------------------
   ' Set 4  Demo's
'------------------------------
   Screen "Set4 START"
'   Widget_Text
'   Widget_Number
'   Widget_Button
'   Append_Cmds
   Sounds  ' requires LcdCal=1 in FT800.inc
'   Screensaver
'   Snapshot
'   Sketch
'   Matrix
'   Track
'   Screen "Set4 END!"

    End

'------------------------------------------------------------------------------------------------------------
Sub Screen (ByVal Characters As String)
'------------------------------------------------------------------------------------------------------------

    ClearColorRGB &HFF, &HFF, &HFF  ' background colour
    Clear_B 1, 1, 1

    ColorRGB &H80, &H80, &H00
    CmdText FT_DispWidth/2, FT_DispHeight/2, 31, OPT_CENTER, Characters

    UpdateScreen

    Wait 1

End Sub ' Screen

'------------------------------------------------------------------------------------------------------------
SUB Widget_Text
'------------------------------------------------------------------------------------------------------------
    ' API To demonstrate Text Widget

    '***********************************************************************
    ' This Code demonstrates the usage of the Text function. Text Function
    ' draws Text with either in-built or externally configured text. Text
    ' Color can be changed by 'ColorRGB' and also supports text justification
    ' Left, Right, Top, Bottom And Center respectively.
    '***********************************************************************

    ClearColorRGB 64, 64, 64
    Clear_B 1, 1, 1
    ColorRGB &Hff, &Hff, &Hff
    ' Draw Text At 0,0 location
    ColorRGB &H00, &H00, &H80
    CmdText 0, 0, 29, 0, "FTDI!"
    ColorRGB &Hff, &Hff, &Hff
    CmdText 0, 40, 26, 0, "Text29 at 0,0" 'Text info
    ' Text with CenterX
    ColorRGB &H80, &H00, &H00
    CmdText FT_DispWidth / 2, 50, 29, OPT_CENTERX, "FTDI!"
    ColorRGB &Hff, &Hff, &Hff
    Const P1 = (FT_DispWidth / 2) - 30
    CmdText P1, 90, 26, 0, "Text29 CenterX" 'Text info
    ' Text with CenterY
    ColorRGB &H41, &H01, &H05
    CmdText FT_DispWidth / 5 , 120, 29, OPT_CENTERY, "FTDI!"
    ColorRGB &Hff, &Hff, &Hff
    CmdText FT_DispWidth / 5, 140, 26, 0, "Text29 CenterY" 'Text info
    ' Text with Center
    ColorRGB &H0b, &H07, &H21
    CmdText FT_DispWidth / 2, 180, 29, OPT_CENTER, "FTDI!"
    ColorRGB &Hff, &Hff, &Hff
    Const P2 = (FT_DispWidth / 2) - 50
    CmdText P2, 200, 26, 0, "Text29 Center" 'Text info
    ' Text with Rightx
    ColorRGB &H57, &H5e, &H1b
    CmdText FT_DispWidth, 60, 29, OPT_RIGHTX, "FTDI!"
    ColorRGB &Hff, &Hff, &Hff
    CmdText FT_DispWidth - 90, 100, 26, 0, "Text29 RightX" 'Text info

    UpdateScreen

    Wait 3

End Sub ' Widget_Text

'------------------------------------------------------------------------------------------------------------
Sub Widget_Number
'------------------------------------------------------------------------------------------------------------
    ' API To demonstrate the Number Widget

    '***********************************************************************
    ' This Code demonstrates the usage of the Number function. Number Function
    ' draws text/numbers using a 32Bit decimal number as signed or unsigned.
    ' Options like CenterX, CenterY, Center and RightX are also supported.
    '***********************************************************************

    ClearColorRGB 64, 64, 64
    Clear_B 1, 1, 1
    ColorRGB &Hff, &Hff, &Hff
    ' Draw number At 0,0 location
    ColorRGB &H00, &H00, &H80
    CmdNumber 0, 0, 29, 0, 1234
    ColorRGB &Hff, &Hff, &Hff
    CmdText 0, 40, 26, 0, "Number29 at 0,0" 'Text info
    ' Number with CenterX
    ColorRGB &H80, &H00, &H00
    CmdNumber FT_DispWidth / 2, 50, 29, OPT_CENTERX Or OPT_SIGNED, -1234
    ColorRGB &Hff, &Hff, &Hff
    Const P3 = (FT_DispWidth / 2) - 30
    CmdText P3, 90, 26, 0, "Number29 CenterX"' Text info
    ' Number with CenterY
    ColorRGB &H41, &H01, &H05
    CmdNumber FT_DispWidth / 5, 120, 29, OPT_CENTERY, 1234
    ColorRGB &Hff, &Hff, &Hff
    CmdText FT_DispWidth / 5, 140, 26, 0, "Number29 CenterY" ' Text info
    ' Number with Center
    ColorRGB &H0b, &H07, &H21
    CmdNumber FT_DispWidth / 2, 180, 29, OPT_CENTER Or OPT_SIGNED, -1234
    ColorRGB &Hff, &Hff, &Hff
    Const P4 = (FT_DispWidth / 2) - 50
    CmdText P4, 200, 26, 0, "Number29 Center" ' Text info
    ' Number with RightX
    ColorRGB &H57, &H5e, &H1b
    CmdNumber FT_DispWidth, 60, 29, OPT_RIGHTX, 1234
    ColorRGB &Hff, &Hff, &Hff
    CmdText FT_DispWidth - 100, 100, 26, 0, "Number29 RightX" ' Text info

    UpdateScreen

    Wait 3

End Sub ' Widget_Number

'------------------------------------------------------------------------------------------------------------
Sub Widget_Button
'------------------------------------------------------------------------------------------------------------
    ' API To demonstrate Button functionality

    '***********************************************************************
    ' This Code demonstrates the usage of the Button function. Buttons can be
    ' constructed in a Flat or 3D effect. Button Color can be changed by
    ' the 'CmdFgColor' command and Text color by 'ColorRGB'.
    '***********************************************************************

    Local xOffset As Integer, yOffset As Integer, bWidth As Integer, bHeight As Integer
    Local bDistx As Integer, bDisty As Integer, Temp As Integer

    bWidth  = 60
    bHeight = 30
    Temp = 4 * bWidth
    Temp = FT_DispWidth - Temp
    Temp = Temp / 5
    bDistx  = bWidth + Temp
    bDisty  = bHeight + 5
    xOffset = 10
    Const P6 = FT_DispHeight/ 2
    yOffset = 2 * bDisty
    yOffset = P6 - yOffset

    ' Construct a buttons With 'ONE/TWO/THREE' Text and Default background
    ' Draw buttons 60x30 resolution At 10x40, 10x75, 10x110
    ClearColorRGB 64, 64, 64
    Clear_B 1, 1, 1
    ColorRGB 255, 255, 255
    ' Flat effect and default Color background
    CmdFgColor &H0000ff

    yOffset = FT_DispHeight / 2
    Temp = 2 * bDisty
    yOffset = yOffset - Temp
    CmdButton xOffset, yOffset, bWidth, bHeight, 28, OPT_FLAT, "ABC"
    yOffset = yOffset + bDisty
    CmdButton xOffset, yOffset, bWidth, bHeight, 28, OPT_FLAT, "ABC"
    yOffset = yOffset + bDisty
    CmdButton xOffset, yOffset, bWidth, bHeight, 28, OPT_FLAT, "ABC"
    CmdText   xOffset, yOffset + 40, 26, 0, "Flat effect" ' Text info

    ' 3D effect
    xOffset = xOffset + bDistx
    yOffset = 2 * bDisty
    yOffset = P6 - yOffset
    CmdButton xOffset, yOffset, bWidth, bHeight, 28, 0, "ABC"
    yOffset = yOffset + bDisty
    CmdButton xOffset, yOffset, bWidth, bHeight, 28, 0, "ABC"
    yOffset = yOffset + bDisty
    CmdButton xOffset, yOffset, bWidth, bHeight, 28, 0, "ABC"
    CmdText   xOffset, yOffset + 40, 26, 0, "3D Effect" ' Text info

    ' 3D effect with Background Color
    CmdFgColor &Hffff00
    xOffset = xOffset + bDistx
    yOffset = 2 * bDisty
    yOffset = P6 - yOffset

    CmdButton xOffset, yOffset, bWidth, bHeight, 28, 0, "ABC"
    yOffset = yOffset + bDisty
    CmdFgColor &H00ffff
    CmdButton xOffset, yOffset, bWidth, bHeight, 28, 0, "ABC"
    yOffset = yOffset + bDisty
    CmdFgColor &Hff00ff
    CmdButton xOffset, yOffset, bWidth, bHeight, 28, 0, "ABC"
    CmdText xOffset, yOffset + 40, 26, 0, "3D Color" ' Text info
    ' 3D effect with Gradient Color
    CmdFgColor &H101010
    CmdGradColor &Hff0000
    xOffset =  xOffset + bDistx

    yOffset = 2 * bDisty
    yOffset = P6 - yOffset

    CmdButton xOffset, yOffset, bWidth, bHeight, 28, 0, "ABC"
    yOffset = yOffset + bDisty
    CmdGradColor &H00ff00
    CmdButton xOffset, yOffset, bWidth, bHeight, 28, 0, "ABC"
    yOffset = yOffset + bDisty
    CmdGradColor &H0000ff
    CmdButton xOffset, yOffset, bWidth, bHeight, 28, 0, "ABC"
    CmdText xOffset, yOffset + 40, 26, 0, "3D Gradient" ' Text info

    UpdateScreen

    Wait 3

End Sub ' Widget_Button

'------------------------------------------------------------------------------------------------------------
Sub Append_Cmds
'------------------------------------------------------------------------------------------------------------
    ' API To demonstrate the use of transfer commands

    Dim AppendCmds(9) As Dword
    Local xoffset As Integer, yoffset As Integer
    Local Temp As Integer
    Local TempDW As Dword

    '***********************************************************************
    ' This Code demonstrates the usage of the Append command - To 'Append' any
    ' MCU specific graphics commands to CoProcessor.
    '***********************************************************************

    ' Bitmap construction by MCU - Display lena At 20x60 offset
    ' Construct the Bitmap Data to be copied in the temp buffer then by using
    ' coprocessor Append command Copy it into graphics processor DL Memory
    xoffset = FT_DispWidth - Header_Width
    xoffset =  xoffset  / 2
    yoffset = FT_DispHeight / 3
    Temp =  Header_Height / 2
    yoffset = yoffset - Temp

    'Note: All Coprocessor Comamds starting with an underscore '_' are a Function of the equivalent Sub name
    AppendCmds(0+_base) = _ClearColorRGB(255, 0, 0)
    AppendCmds(1+_base) = _Clear_B(1, 1, 1)
    AppendCmds(2+_base) = _ColorRGB(255, 255, 255)
    AppendCmds(3+_base) = _Begin_G(BITMAPS)
    AppendCmds(4+_base) = _BitmapSource(0)
    AppendCmds(5+_base) = _BitmapLayout(Header_Format, Header_Stride, Header_Height)
    AppendCmds(6+_base) = _BitmapSize(BILINEAR, BORDER, BORDER, Header_Width, Header_Height)
    AppendCmds(7+_base) = _Vertex2F(xoffset * 16, yoffset * 16)
    W32 = &H00000000
    Wb3 = Dl_End
    AppendCmds(8+_base) = W32 '_End_G

    ' Download the Bitmap Data from SD-Card
    ' Load_File "Lenaraw.bin", RAM_G, Header_Stride * Header_Height

    ' Download the Bitmap Data from Data Statements
    TempDW = Loadlabel(Lena)
    RdFlash_WrFT800 RAM_G, TempDW , Header_Stride * Header_Height


    ' Download the DL Data constructed by the MCU to location 40*40*2 in sram
    RdMem_WrFT800 RAM_G + Header_Stride * Header_Height, AppendCmds(_base), 9 * 4

    ' Call the Append api For copying the above generated Data into graphics processor
    ' DL commands are stored At location 40*40*2 offset From the starting Of the sram
    CmdAppend RAM_G + Header_Stride * Header_Height, 9 * 4
    ' Display the Text information
    CmdFgColor &Hffff00
    xoffset = xoffset - 50
    yoffset = yoffset + 40
    CmdText xoffset, yoffset, 26, 0, "Display bitmap by Append"

    UpdateScreen

    Wait 2

End Sub ' Append_Cmds

'------------------------------------------------------------------------------------------------------------
Sub Sounds
'------------------------------------------------------------------------------------------------------------
    ' API to demonstrate the usage of sound engine of FT800

    Local LoopFlag As Long, wbutton As Long, hbutton As Long, tagval As Long, tagvalsnd As Long
    Local numbtnrow As Long, numbtncol As Long, i As Long, j As Long, prevtag As Long, Tmp As Long, Tmp2 As Long, Tmp3 As Long
    Local freqtrack As Dword , currfreq As Dword , prevcurrfreq As Dword , TmpDW As Dword
    Local StringArray As String * 6
    Local Rtn As Byte, Tmp1 As Byte, Ptr2 As Byte


    '*************************************************************************
    '* This code demonstrates the usage of the Sound function. All supported *
    '* sounds and respective pitches are represented as keys/buttons when pressed
    '*************************************************************************
    prevtag = -1
    tagvalsnd = -1
    freqtrack = 0
    currfreq = 0
    LoopFlag = 200
    numbtnrow = 7 ' number of rows to be created - note that mute and unmute are not played in this application
    numbtncol = 8 ' number of colomns to be created

    wbutton = FT_DispWidth - 40
    wbutton = wbutton / numbtncol
    hbutton = FT_DispHeight / numbtnrow

    ' set the volume to maximum
    Wr8 REG_VOL_SOUND, 255

    ' set the tracker to track the slider for frequency
    CmdTrack FT_DispWidth - 15, 20, 8, FT_DispHeight - 40, 100

    While LoopFlag > 0

        tagval      = Rd8(REG_TOUCH_TAG)
        freqtrack   = Rd32(REG_TRACKER)

        Tmp = freqtrack And &Hff

        If Tmp = 100 Then
            Shift freqtrack, Right, 16
            currfreq = freqtrack
            currfreq = 88 * currfreq
            currfreq = currfreq / 65536
            If currfreq > 108 Then currfreq = 108
        End If

        If tagval > 0 Then

            If tagval <= 99 Then tagvalsnd = tagval
            If tagvalsnd = &H63 Then tagvalsnd = 0

            If prevtag <> tagval Or prevcurrfreq <> currfreq Then
                ' Play sound pitch
                TmpDW  = currfreq + 21
                Shift TmpDW, Left, 8

                TmpDW = TmpDW Or tagvalsnd
                Wr16 REG_SOUND, TmpDW
                Wr8  REG_PLAY, 1
            End If

            If tagvalsnd = 0 Then  tagvalsnd = 99

        End If

         ' Start a new display list for construction of screen
        ClearColorRGB 64, 64, 64
        Clear_B 1, 1, 1
        ' line width for the rectangle
        LineWidth 1 * 16

        ' custom keys for sound input
        ' First draw all the rectangles followed by the font
        ' yellow color for background color
        ColorRGB &H80, &H80, &H00
        Begin_G RECTS

        Ptr2 = 0
        For i = 0 To  numbtnrow - 1
            For j = 0 To numbtncol - 1

                Tag Lookup(Ptr2, Snd_TagArray)
                Tmp = i * hbutton
                Tmp = Tmp + 2
                Tmp2 = wbutton * j
                Tmp2 = Tmp2 + 2
                Vertex2II Tmp2, Tmp, 0, 0
                Tmp = j * wbutton
                Tmp = Tmp + wbutton
                Tmp = Tmp - 2
                Tmp2 = hbutton * i
                Tmp2 = Tmp2 + hbutton
                Tmp2 = Tmp2 -2
                Vertex2II Tmp, Tmp2, 0, 0

                Incr Ptr2

            Next j

        Next i

        End_G
        ColorRGB &Hff, &Hff, &Hff

        ' draw the highlight rectangle and text info

        Tmp1 = 0
        Ptr2 = 0

        For i = 0 To numbtnrow - 1
            For j = 0 To numbtncol - 1

                Tag Lookup(Ptr2, Snd_TagArray)

                If tagvalsnd = Rtn Then
                    ' red color for highlight effect
                    ColorRGB &H80, &H00, &H00
                    Begin_G RECTS
                    Tag Lookup(Ptr2, Snd_TagArray)
                    Tmp = j * wbutton
                    Tmp = Tmp + 2
                    Tmp2 = i * hbutton
                    Tmp2 = Tmp2 + 2
                    Vertex2II Tmp, Tmp2, 0, 0
                    Tmp = j * wbutton
                    Tmp = Tmp + wbutton
                    Tmp = Tmp - 2
                    Tmp2 = hbutton * i
                    Tmp2 = Tmp2 + hbutton
                    Tmp2 = Tmp2 - 2
                    Vertex2II Tmp, Tmp2, 0, 0
                    End_G
                    ' reset the color to make sure font doesnt get impacted
                    ColorRGB &Hff, &Hff, &Hff
                End If

                Incr Ptr2

                ' to make sure that highlight rectangle as well as font to take the same tag values
                Tmp = j * wbutton
                Tmp2 = wbutton/2
                Tmp = Tmp + Tmp2
                Tmp2 = hbutton * i
                Tmp3  = hbutton / 2
                Tmp2 = Tmp2 + Tmp3
                StringArray = LookupStr(Tmp1, Snd_Array)
                CmdText Tmp, Tmp2, 26, OPT_CENTER, StringArray
                Tmp = Tmp + 4
                Incr Tmp1
            Next j
        Next i

        ' Draw vertical slider bar for frequency control
        TmpDW = currfreq + 21
        StringArray = "Pt " + Str(TmpDW)
        TagMask 0
        CmdText FT_DispWidth - 20, 10, 26, OPT_CENTER, StringArray
        TagMask 1
        Tag 100
        CmdSlider FT_DispWidth - 15, 20, 8, FT_DispHeight - 40, 0, currfreq, 88

        UpdateScreen

        prevtag = tagval
        prevcurrfreq = currfreq


        Waitms 10
        Decr LoopFlag

    Wend

    Wr16 REG_SOUND, 0
    Wr8  REG_PLAY,  1

End Sub ' Sound

'------------------------------------------------------------------------------------------------------------
Sub Screensaver
'------------------------------------------------------------------------------------------------------------
    ' API To demonstrate Screen saver widget - playing Of Bitmap via macro0

    '***********************************************************************
    ' This Code demonstrates the usage of the Screensaver function. Screen
    ' Saver modifies Macro 0 with the Vertex2f command.
    '***********************************************************************

    Local TempDW As Dword

    ' Download the Bitmap Data
    TempDW = Loadlabel(Lena)
    RdFlash_WrFT800 RAM_G, TempDW , Header_Stride * Header_Height

    ' Send command Screen saver
    CmdScreenSaver ' Screen saver command will continuously update the macro0 With vertex2f command

    ' Copy the Display list
    ClearColorRGB 0, 0, &H80
    Clear_B 1, 1, 1
    ColorRGB &Hff, &Hff, &Hff
    ' lena Bitmap
    CmdLoadIdentity
    CmdScale 3 * 65536, 3 * 65536 ' Scale the Bitmap 3 times On both sides
    CmdSetMatrix
    Begin_G BITMAPS
    BitmapSource 0
    BitmapLayout Header_Format, Header_Stride, Header_Height
    BitmapSize BILINEAR, BORDER, BORDER, Header_Width * 3, Header_Height * 3
    Macro_R 0
    End_G
    ' Display the Text
    CmdLoadIdentity
    CmdSetMatrix
    CmdText FT_DispWidth / 2, FT_DispHeight / 2, 27, OPT_CENTER, "Screen Saver ..."
    CmdMemSet RAM_G + 3200, &Hff, 160 * 2 * 120

    UpdateScreen

    Wait 10

    ' Send the Stop command
    CmdStop
    ' Update the command buffer pointers - both Read And Write pointers
    WaitCmdFifoEmpty


End Sub ' Screensaver

'------------------------------------------------------------------------------------------------------------
Sub Snapshot
'------------------------------------------------------------------------------------------------------------
    ' Sample app To demonstrate snapshot widget/functionality
    '***********************************************************************
    ' This Code demonstrates the usage of the Snapshot Function.
    ' Snapshot captures the present screen and dumps it into a Bitmap as a ARGB4
    ' Color format
    '***********************************************************************

    ' fadeout before switching Off the pclock
    FadeOut
    ' Switch Off the lcd
    Wr8 REG_GPIO, &H7f

    Waitms 100

    ' Disable the pclock
    Wr8 REG_PCLK, 0
    ' Configure the resolution To 160 x 120 dimention
    Wr16 REG_HSIZE, 160
    Wr16 REG_VSIZE, 120

    ' Construct Screen Shot for Snapshot
    ClearColorRGB 0, 0, 0
    Clear_B 1, 1, 1
    ColorRGB 28, 20, 99
    ' captured snapshot
    Begin_G FTPOINTS
    Color_A 128
    PointSize 20 * 16
    Vertex2F 0 * 16, 0 * 16
    PointSize 25 * 16
    Vertex2F 20 * 16, 10 * 16
    PointSize 30 * 16
    Vertex2F 40 * 16, 20 * 16
    PointSize 35 * 16
    Vertex2F 60 * 16, 30 * 16
    PointSize 40 * 16
    Vertex2F 80 * 16, 40 * 16
    PointSize 45 * 16
    Vertex2F 100 * 16, 50 * 16
    PointSize 50 * 16
    Vertex2F 120 * 16, 60 * 16
    PointSize 55 * 16
    Vertex2F 140 * 16, 70 * 16
    PointSize 60 * 16
    Vertex2F 160 * 16, 80 * 16
    PointSize 65 * 16
    Vertex2F 0 * 16, 120 * 16
    PointSize 70 * 16
    Vertex2F 160 * 16, 0 * 16
    End_G 'Display the Bitmap At the center Of the Display
    Color_A 255
    ColorRGB 32, 32, 32
    CmdText 80, 60, 26, OPT_CENTER, "Points"

    UpdateScreen

    WaitmS 100 ' TimeOut For snapshot To be performed by coprocessor

    ' Take snap shot Of the current Screen
    CmdSnapShot 3200 ' store the RGB content At location 3200

    ' TimeOut For snapshot To be performed by coprocessor
    ' Wait till coprocessor completes the operation
    WaitCmdFifoEmpty

    WaitmS 100 ' TimeOut For snapshot To be performed by coprocessor

    ' Reconfigure the resolution wrt configuration
    Wr16 REG_HSIZE, FT_DispWidth
    Wr16 REG_VSIZE, FT_DispHeight

    ClearColorRGB &Hff, &Hff, &Hff
    Clear_B 1, 1, 1
    ColorRGB &Hff, &Hff, &Hff
    ' captured snapshot
    Begin_G BITMAPS
    BitmapSource 3200
    BitmapLayout ARGB4, 160 * 2, 120
    BitmapSize BILINEAR, BORDER, BORDER, 160, 120
    Vertex2F ((FT_DispWidth - 160) / 2) * 16, ((FT_DispHeight - 120) / 2) * 16
    End_G ' Display the Bitmap At the center Of the Display
    ' Display the Text info
    ColorRGB 32, 32, 32
    CmdText FT_DispWidth / 2, 40, 27, OPT_CENTER, "Snap Shot"

    UpdateScreen

    ' re-enable the pclock
    Wr8 REG_PCLK, FT_DispPCLK
    WaitmS 60

    ' Power On the LCD
    Wr8 REG_GPIO, &Hff

    WaitmS 200 ' give some time For the lcd To switch on - hack For one perticular panel

    ' Set the Display pwm back To 128
    Fadein

    Wait 1

End Sub ' Snapshot


'------------------------------------------------------------------------------------------------------------
SUB Sketch
'------------------------------------------------------------------------------------------------------------
    ' API To demonstrate sketch widget

    '***********************************************************************
    ' This Code demonstrates the usage of the Sketch function. Sketch Function
    ' draws a Line in a pen movement. Skecth supports Bitmap_Fmt_L1 And Bitmap_Fmt_L8 Output formats
    '***********************************************************************

    Const BORDERSz = 40
    Const MemZeroSz = 1 * (FT_DispWidth - 2 * BORDERSz) * (FT_DispHeight - 2 * BORDERSz)

    ' Send command sketch
    CmdMemZero RAM_G, MemZeroSz
    CmdSketch BORDERSz, BORDERSz, FT_DispWidth - 2 * BORDERSz, FT_DispHeight - 2 * BORDERSz, 0, Bitmap_Fmt_L1 ' sketch In L1 format

    ' Display the sketch
    ClearColorRGB &H80, &H00, &H00
    Clear_B 1, 1, 1
    ColorRGB &Hff, &Hff, &Hff
    ScissorSize FT_DispWidth - 2 * BORDERSz ,FT_DispHeight - 2 * BORDERSz
    ScissorXY BORDERSz, BORDERSz
    ClearColorRGB &Hff, &Hff, &Hff
    Clear_B 1,1,1
    ScissorSize 512, 512
    ScissorXY 0, 0
    ColorRGB 0, 0, 0

    ' Bitmap_Fmt_L1 Bitmap Display
    Begin_G BITMAPS
    BitmapSource 0
    BitmapLayout Bitmap_Fmt_L1, (FT_DispWidth - 2 * BORDERSz) / 8, FT_DispHeight - 2 * BORDERSz
    BitmapSize BILINEAR, BORDER, BORDER, FT_DispWidth - 2 * BORDERSz, FT_DispHeight - 2 * BORDERSz
    Vertex2F BORDERSz * 16, BORDERSz * 16
    End_G
    ' Display the Text
    ColorRGB &Hff, &Hff, &Hff
    CmdText FT_DispWidth / 2, 20, 27, OPT_CENTER, "Sketch L1"

    UpdateScreen

    Wait 5

    ' Send the Stop command
    CmdStop

    ' Update the command buffer pointers - both Read And Write pointers
    WaitCmdFifoEmpty

    ' Sketch Bitmap_Fmt_L8 format
    ' Send command sketch
    CmdMemZero RAM_G, MemZeroSz
    CmdSketch BORDERSz, BORDERSz, FT_DispWidth - 2 * BORDERSz, FT_DispHeight - 2 * BORDERSz, 0, Bitmap_Fmt_L8 ' sketch In L8 format
    ' Display the sketch
    ClearColorRGB &H00, 0, &H80
    Clear_B 1, 1, 1
    ColorRGB &Hff, &Hff, &Hff
    ScissorSize FT_DispWidth - 2 * BORDERSz, FT_DispHeight - 2 * BORDERSz
    ScissorXY BORDERSz, BORDERSz
    ClearColorRGB &Hff, &Hff, &Hff
    Clear_B 1, 1, 1

    ScissorSize 512, 512
    ScissorXY 0, 0
    ColorRGB 0, 0, 0
    ' Bitmap_Fmt_L8 Bitmap Display
    Begin_G BITMAPS
    BitmapSource 0
    BitmapLayout Bitmap_Fmt_L8, FT_DispWidth - 2 * BORDERSz, FT_DispHeight - 2 * BORDERSz
    BitmapSize BILINEAR, BORDER, BORDER, FT_DispWidth - 2 * BORDERSz, FT_DispHeight - 2 * BORDERSz
    Vertex2F BORDERSz * 16, BORDERSz * 16
    End_G
    ' Display the Text
    ColorRGB &Hff, &Hff, &Hff
    CmdText FT_DispWidth / 2, 20, 27, OPT_CENTER, "Sketch L8"

    UpdateScreen

    Wait 5

    ' Send the Stop command
    CmdStop
    ' Update the command buffer pointers - both Read And Write pointers
    WaitCmdFifoEmpty


End Sub ' Sketch

'------------------------------------------------------------------------------------------------------------
Sub Matrix
'------------------------------------------------------------------------------------------------------------
    ' API To demonstrate Scale, Rotate and translate functionality

    '***********************************************************************
    ' This code demonstrates the usage of the Bitmap Matrix processing APIs.
    ' Matrix APIs consist of Scale, Rotate And Translate.
    ' Units of Translation and Scale are interms of 1/65536, Rotation is in
    ' degrees of 1/65536. +ve theta is anti-clock wise, and -ve
    ' theta is clock-wise rotation
    '***********************************************************************

    Const imagewidth  = Header_Width
    Const imageheight = Header_Height
    Const imagestride = Header_Stride

    Local imagexoffset As Long, imageyoffset As Long
    Local TempDW As Dword

    ' Download the Bitmap Data
    TempDW = Loadlabel(Lena)
    RdFlash_WrFT800 RAM_G, TempDW , Header_Stride * Header_Height

    ClearColorRGB &Hff, &Hff, &Hff
    Clear_B 1, 1, 1
    ColorRGB 32, 32, 32
    CmdText 10, 5, 16, 0, "BM with rotation"
    CmdText 10, 20 + 40 + 5, 16, 0, "BM with scaling"
    CmdText 10, 20 + 40 + 20 + 80 + 5, 16, 0, "BM with flip"

    imagexoffset = 10 * 16
    imageyoffset = 20 * 16

    ColorRGB &Hff, &Hff, &Hff
    Begin_G BITMAPS
    BitmapSource 0
    BitmapLayout Header_Format, imagestride, imageheight
    BitmapSize BILINEAR, BORDER, BORDER, imagewidth, imageheight

    ' Perform Display of Bitmap with Rotation

    ' Perform Display of plain Bitmap
    Vertex2F imagexoffset, imageyoffset

    ' Perform Display Of plain Bitmap With 45 degrees anti clock wise And the rotation Is performed On top Left coordinate
    Const Calc0 = (imagewidth + 10) * 16
    imagexoffset = imagexoffset + Calc0
    CmdLoadIdentity
    CmdRotate -45 * 65536 / 360 ' Rotate by 45 degrees anticlock wise
    CmdSetMatrix
    Vertex2F imagexoffset, imageyoffset

    ' Perform Display Of plain Bitmap With 30 degrees clock wise And the rotation is performed On top Left coordinate
    Const Calc5 = (imagewidth * 1.42 + 10) * 16
    imagexoffset = imagexoffset + Calc5 ' add the Width * 1.41 As diagonal is New Width And extra 10 Pixels
    CmdLoadIdentity
    CmdRotate  30 * 65536 / 360 'Rotate by 33 degrees clock wise
    CmdSetMatrix
    Vertex2F imagexoffset, imageyoffset

    ' Perform Display Of plain Bitmap With 45 degrees anti clock wise and the rotation Is performed wrt centre Of the Bitmap
    imagexoffset = imagexoffset + Calc5 ' add the Width * 1.41 As diagonal is New Width And extra 10 Pixels
    CmdLoadIdentity
    CmdTranslate 65536 * imagewidth / 2, 65536 * imageheight / 2 ' make the rotation coordinates at the center
    CmdRotate -45 * 65536 / 360 ' Rotate by 45 degrees anticlock wise
    CmdTranslate -65536 * imagewidth / 2, -65536 * imageheight / 2
    CmdSetMatrix
    Vertex2F imagexoffset, imageyoffset

    ' Perform Display Of plain Bitmap With 45 degrees clock wise and the rotation Is performed so that whole Bitmap is viewable
    imagexoffset = imagexoffset + Calc5 ' add the Width * 1.41 as diagonal Is New Width And extra 10 Pixels
    CmdLoadIdentity
    CmdTranslate 65536 * imagewidth / 2, 65536 * imageheight / 2 ' make the rotation coordinates At the center
    CmdRotate 45 * 65536 / 360 ' Rotate by 45 degrees clock wise
    CmdTranslate -65536 * imagewidth / 10, -65536 * imageheight / 2
    CmdSetMatrix
    BitmapSize BILINEAR, BORDER, BORDER, imagewidth * 2, imageheight * 2
    Vertex2F imagexoffset, imageyoffset

    ' Perform Display Of plain Bitmap With 90 degrees anti clock wise and the rotation is performed so that whole Bitmap is viewable
    Const Calc1 = (imagewidth * 2 + 10) * 16
    imagexoffset = imagexoffset + Calc1

    CmdLoadIdentity
    CmdTranslate 65536 * imagewidth / 2, 65536 * imageheight / 2 ' make the rotation coordinates at the center
    CmdRotate -90 * 65536 / 360 ' Rotate by 90 degrees anticlock wise
    CmdTranslate -65536 * imagewidth / 2, -65536 * imageheight / 2
    CmdSetMatrix
    BitmapSize BILINEAR, BORDER, BORDER, imagewidth, imageheight
    Vertex2F imagexoffset, imageyoffset

    ' Perform Display Of plain Bitmap With 180 degrees clock wise and the rotation is performed so that whole Bitmap Is viewable
    imagexoffset = imagexoffset + Calc0
    CmdLoadIdentity
    CmdTranslate 65536 * imagewidth / 2, 65536 * imageheight / 2 ' make the rotation coordinates At the center
    CmdRotate -180 * 65536 / 360 ' Rotate by 180 degrees anticlock wise
    CmdTranslate -65536 * imagewidth / 2, -65536 * imageheight / 2
    CmdSetMatrix
    Vertex2F imagexoffset, imageyoffset

    ' Perform Display Of Bitmap With Scale

    ' Perform Display of plain Bitmap With Scale factor Of 2x2 In xANDy direction
    imagexoffset = 10 * 16
    Const Calc2 = (imageheight + 20) * 16
    imageyoffset = imageyoffset + Calc2
    CmdLoadIdentity
    CmdScale 2 * 65536, 2 * 65536 ' Scale by 2x2
    CmdSetMatrix
    BitmapSize BILINEAR, BORDER, BORDER, imagewidth * 2, imageheight * 2
    Vertex2F imagexoffset, imageyoffset

    ' Perform Display of a plain Bitmap with a Scale factor of .5 x.25 in the x and y direction, rotate by 45 degrees clock-wise wrt top Left
    Const Calc3 = (imagewidth * 2 + 10) * 16
    imagexoffset = imagexoffset + Calc3
    CmdLoadIdentity
    CmdTranslate 65536 * imagewidth / 2, 65536 * imageheight / 2 ' make the rotation coordinates at the center

    CmdRotate 45 * 65536 / 360 ' Rotate by 45 degrees clock wise
    CmdScale 65536 / 2, 65536 / 4 ' Scale by .5x.25
    CmdTranslate -65536 * imagewidth / 2, -65536 * imageheight / 2
    CmdSetMatrix
    Vertex2F imagexoffset, imageyoffset

    ' Perform Display of plain Bitmap with Scale factor of.5x2 in the x and y direction, rotate by 75 degrees anticlock wise wrt center of the image
    imagexoffset =  imagexoffset + Calc0
    CmdLoadIdentity
    CmdTranslate 65536 * imagewidth / 2, 65536 * imageheight / 2 ' make the rotation coordinates At the center
    CmdRotate  -75 * 65536 / 360 ' Rotate by 75 degrees anticlock wise
    CmdScale 65536 / 2, 2 * 65536 ' Scale by .5x2
    CmdTranslate -65536 * imagewidth / 2, -65536 * imageheight / 8
    CmdSetMatrix
    BitmapSize BILINEAR, BORDER, BORDER, imagewidth * 5 / 2, imageheight * 5 / 2
    Vertex2F imagexoffset, imageyoffset

    ' Perform Display Of Bitmap flip

    ' perform Display Of plain Bitmap With 1x1 And flip Right
    imagexoffset = 10 * 16
    Const Calc4 = (imageheight * 2 + 20) * 16
    imageyoffset = imageyoffset + Calc4
    CmdLoadIdentity
    CmdTranslate 65536 * imagewidth / 2, 65536 * imageheight / 2 ' make the rotation coordinates at the center
    CmdScale -1 * 65536, 1 * 65536 ' flip Right
    CmdTranslate -65536 * imagewidth/ 2, -65536 * imageheight / 2
    CmdSetMatrix
    BitmapSize BILINEAR, BORDER, BORDER, imagewidth, imageheight
    Vertex2F imagexoffset, imageyoffset

    ' Perform Display of plain Bitmap With 2x2 scaling, flip bottom
    imagexoffset = imagexoffset + Calc0 ' (imagewidth + 10) * 16
    CmdLoadIdentity
    CmdTranslate 65536 * imagewidth / 2, 65536 * imageheight / 2 ' make the rotation coordinates At the center
    CmdScale 2 * 65536, -2 * 65536 ' flip bottom And Scale by 2 on both sides
    CmdTranslate -65536 * imagewidth / 4, -65536 * imageheight / 1.42
    CmdSetMatrix
    BitmapSize BILINEAR, BORDER, BORDER, imagewidth * 4, imageheight * 4
    Vertex2F imagexoffset, imageyoffset

    ' Perform Display of plain Bitmap with 2x1 scaling, rotation and flip Right and make sure whole image Is viewable
    imagexoffset = imagexoffset + Calc1
    CmdLoadIdentity
    CmdTranslate 65536 * imagewidth / 2, 65536 * imageheight / 2 ' make the rotation coordinates at the center

    CmdRotate  -45 * 65536 / 360   ' Rotate by 45 degrees anticlock wise
    CmdScale -2 * 65536, 1 * 65536 ' flip Right and Scale by 2 on x axis
    CmdTranslate -65536 * imagewidth / 2, -65536 * imageheight / 8
    CmdSetMatrix
    BitmapSize BILINEAR, BORDER, BORDER, imagewidth * 5, imageheight * 5
    Vertex2F imagexoffset, imageyoffset

    End_G

    UpdateScreen

    Wait 2

End Sub ' Matrix

'------------------------------------------------------------------------------------------------------------
Sub Track
'------------------------------------------------------------------------------------------------------------
    ' Sample app to demonstrate Track Widget funtionality

    Local NumBytesGen As Dword, TrackRegisterVal As Long 'Dword
    Local angleval As Word, slideval As Word, scrollval As Word
    Local CurrWriteOffset As Integer, LoopFlag As Integer
    Local tmpval0 As Long, tmpval1 As Long, tmpval2 As Long, Ttmp As Long
    Local angval As Byte, sldval As Byte, scrlval As Byte, tagval As Byte

    '***********************************************************************
    ' This Code demonstrates the usage of the Track Function. Track Function
    ' tracks the pen touch on any specific object. Track Function supports
    ' rotary and horizontal/vertical tracks. Rotary is given by rotation
    ' angle and horizontal/vertucal track is by offset position.
    '***********************************************************************

    ' Set the tracker For 3 bojects
    CmdTrack FT_DispWidth / 2, FT_DispHeight / 2, 1,1, 10
    CmdTrack 40, FT_DispHeight - 40, FT_DispWidth - 80, 8, 11
    CmdTrack FT_DispWidth - 40, 40, 8, FT_DispHeight - 80, 12

    ' Wait till coprocessor completes the operation
    WaitCmdFifoEmpty

    LoopFlag = 600

    ' update the background Color continuously For the Color change In Any Of the trackers
    While LoopFlag > 0

        TrackRegisterVal = Rd32 (REG_TRACKER)
        tagval = TrackRegisterVal And &Hff

        If tagval <> 0 Then

            If tagval = 10 Then
                Shift TrackRegisterVal, Right , 16
                angleval = TrackRegisterVal
            ElseIf tagval = 11 Then
                Shift TrackRegisterVal, Right, 16
                slideval = TrackRegisterVal
            ElseIf tagval = 12 Then
                Shift TrackRegisterVal, Right, 16
                scrollval = TrackRegisterVal

                Ttmp = scrollval + 65535
                Ttmp = Ttmp / 10
                If Ttmp > 58981 Then ' (9 * 65535 / 10) Then
                    scrollval =   52428 '8 * 65535 / 10
                ElseIf scrollval <  6553 Then ' (1 * 65535 / 10)
                    scrollval = 0
                Else
                    scrollval = scrollval - 6553 ' (1 * 65535 / 10)
                End If

            End If
        End If

        ' Display a rotary dial, horizontal slider And vertical Scroll
        tmpval0 = angleval  * 255
        tmpval0 = tmpval0 / 65536

        tmpval1 = slideval  * 255
        tmpval1 = tmpval1 / 65536

        tmpval2 = scrollval * 255
        tmpval2 = tmpval2 / 65536

        angval = tmpval0 And &Hff
        sldval = tmpval1 And &Hff
        scrlval = tmpval2 And &Hff

        ClearColorRGB angval, sldval, scrlval

        Clear_B 1,1,1
        ColorRGB &Hff, &Hff, &Hff

        ' Draw dial With 3d effect
        CmdFgColor &H00ff00
        CmdBgColor &H800000
        Tag 10
        CmdDial FT_DispWidth / 2, FT_DispHeight / 2, FT_DispWidth / 8, 0, angleval

        ' Draw slider With 3d effect
        CmdFgColor &H00A000
        CmdBgColor &H800000
        Tag 11
        CmdSlider 40, FT_DispHeight - 40, FT_DispWidth - 80, 8, 0, slideval, 65535

        ' Draw Scroll With 3d effect
        CmdFgColor &H00A000
        CmdBgColor &H000080
        Tag 12
        CmdScrollbar FT_DispWidth - 40, 40, 8, FT_DispHeight - 80, 0, scrollval, 65535 * 0.2, 65535

        TagMask 0
        ColorRGB &Hff, &Hff, &Hff
        CmdText FT_DispWidth / 2, ((FT_DispHeight / 2) + (FT_DispWidth / 8) + 8), 26, OPT_CENTER, "Rotary track"
        CmdText FT_DispWidth / 2, ((FT_DispHeight - 40) + 8 + 8), 26, OPT_CENTER, "Horizontal track"
        CmdText FT_DispWidth - 45, 20, 26, OPT_CENTER, "Vertical track"

        UpdateScreen

        Waitms  5

        Decr LoopFlag
    Wend

    ' Set the tracker For 3 bojects

    CmdTrack 240, 136, 0, 0, 10
    CmdTrack 40, 232, 0, 0, 11
    CmdTrack 400, 40, 0,0, 12

    ' Wait till coprocessor completes the operation
    WaitCmdFifoEmpty


End Sub ' Track

'------------------------------------------------------------------------------------------------------------
Sub Fadeout
'------------------------------------------------------------------------------------------------------------
   ' API To give fadeout effect by changing the Display PWM From 100 till 0

   Local i AS Long

   For i = 100 To 0 Step -3
      Wr8 REG_PWM_DUTY, i
      Waitms 2
   Next i

End Sub ' Fadeout

'------------------------------------------------------------------------------------------------------------
Sub Fadein
'------------------------------------------------------------------------------------------------------------
   ' API To perform Display fadein effect by changing the Display PWM From 0 till 100 and Finally 128

   Local i AS Long

    For i = 0 To 100 Step 3
        Wr8 REG_PWM_DUTY, i
        Waitms 2
    Next i

    '  Finally make the PWM 100%
    Wr8 REG_PWM_DUTY, 128

End Sub ' Fadein

'------------------------------------------------------------------------------------------------------------

Snd_Array: ' used in Sounds
    Data "Slce","Sqrq","Sinw","Saww","Triw","Beep","Alrm","Warb","Crsl","Pp01","Pp02","Pp03","Pp04","Pp05","Pp06"
    Data "Pp07","Pp08","Pp09","Pp10","Pp11","Pp12","Pp13","Pp14","Pp15","Pp16","DMF#","DMF*","DMF0","DMF1","DMF2"
    Data "DMF3","DMF4","DMF5","DMF6","DMF7","DMF8","DMF9","Harp","Xyph","Tuba","Glok","Orgn","Trmp","Pian","Chim"
    Data "MBox","Bell","Clck","Swth","Cowb","Noth","Hiht","Kick","Pop ","Clak","Chak","Mute","uMut"

Snd_TagArray: ' used in Sounds
    Data &H63,&H01,&H02,&H03,&H04,&H05,&H06,&H07,&H08,&H10,&h11,&H12,&H13,&H14,&H15,&H16,&H17,&H18,&H19,&H1a
    Data &H1b,&H1c,&H1d,&H1e,&H1f,&H23,&h2a,&H30,&H31,&H32,&H33,&H34,&H35,&H36,&H37,&H38,&H39,&H40,&H41,&H42
    Data &H43,&H44,&H45,&H46,&H47,&H48,&H49,&H50,&H51,&H52,&H53,&H54,&H55,&H56,&H57,&H58,&H60,&H61

$inc Lena, nosize, "Lenaraw.bin"   ' used in SUB Screensaver, rem if not needed