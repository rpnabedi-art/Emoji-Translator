'------------------------------------------------------------------------------
' BASCOM-AVR - FT801 Graph - Capacitive Touch.bas
' Code demonstrates using gestures and swipes using the VM801P - FT801 Capacitive Touch LCD
' Original code from http://www.ftdichip.com/Support/SoftwareExamples/EVE/FT_App_Graph.zip
' Requires Bascom 2.0.7.9 or greater.
'------------------------------------------------------------------------------

$Regfile = "M328pdef.dat"
$Crystal = 16000000
$Baud = 57600
$HwStack = 90
$SwStack = 90
$FrameSize = 200
$NOTYPECHECK

Config Base = 0
Config Submode = New
Config Ft800 = Spi , ftsave = 0, ftdebug = 0 , Ftcs = Portb.1 , Ftpd = Portd.4, LCD_CALIBRATION=1 ' VM801P - FTDI
Config Spi = Hard, Interrupt = Off, Data_Order = mSb, Master = Yes, Polarity = Low, Phase = 0, Clockrate = 4, Noss = 0
SPSR = 1  ' Makes SPI run at 8Mhz instead of 4Mhz

Spiinit

$Include "FT80x.inc"
$Include "FT80x_Functions.inc"

Const SUBDIV = 4
Const YY = FT_DispWidth / SUBDIV
Const m_min = 10 / 65536
Const DisplayTouches = 1

Dim sx(5) As Integer, sy(5) As Integer
Dim cx As Integer, cy As Integer
Dim i As Byte
Dim mS1 As Single, cS1 As Single
Dim down(2) As Byte
Dim m(2) As Long
Dim TempL As Long
Dim TempI As Integer

Declare Sub Read_Extended (Byref sx() As Integer, Byref sy() As Integer)
Declare Sub TSet (Byval x0 As Long, Byval y0 As Integer, Byval x1 As Long, Byval y1 As Integer )
Declare Sub TSset (Byval x0 As Long, Byval y0 As Integer)
Declare Function rsin (Byval r As Integer, Byval th As Word) As Integer
Declare Function m2s (Byval x As Long) As Integer
Declare Function s2m(Byval y2 As Integer) As Long
Declare Sub Plot()


If FT800_Init() = 1 Then
   ' put your own message if not successfull.
   End ' Initialise the FT800
Else
   ' Print "Success"
End if

TSet 0, 0, &H10000, FT_DispWidth
Wr8 Reg_cTouch_Extended, Reg_cTouch_Extended

Do

   Read_Extended sx(), sy()

   For i = 0 to 1

      If sx(i) > -10 AND down(i) < 1 Then
         down(i) = 1
         m(i) = s2m (sx(i))

      End If

      If sx(i) < -10 Then
         down(i) = 0
      End If

   Next

   If down(0) > 0 AND down(1) > 0 Then

      If m(0) <> m(1) Then
         Tset m(0), sx(0), m(1), sx(1)

      End If

   ElseIf down(0) > 0 AND down(1) < 1 Then
      TSset m(0), sx(0)

   ElseIf down(0) < 1 AND down(1) > 0 Then
      TSset m(1), sx(1)

   End If


   Plot

    ' display touches
   #If DisplayTouches
      ColorRGB &Hff, &Hff, &Hff
      LineWidth 8
      Begin_G Lines
      For i = 0 to 1
         If sx(i) > -10 Then
            Vertex2II sx(i), 0, 0, 0
            Vertex2II sx(i), 272, 0, 0
         End If
      Next
   #EndIF

   UpdateScreen

Loop

End

'-------------------------------------------------------------------------------------------
Sub Plot()
'-------------------------------------------------------------------------------------------

   Dim mm(2) As Long
   Dim y(YY + 1) As Integer
   Local pixels_per_div As Integer, c1 As Integer, x As Integer, w As Integer, v As Integer
   Local clock_r As Integer
   Local fadeout As Byte, h As Byte
   Local n As Long, x32 As Long, m1 As Long, TempL As Long
   Local options As Word

   StencilOP ZERO, ZERO
   CmdGradient 0, 0, &H202020, 0, &H11f, &H107fff

   mm(0) = s2m(0)
   mm(1) = s2m(FT_DispWidth)

   pixels_per_div = m2s(&H4000) - m2s(0)

   c1 = pixels_per_div - 32
   c1 = c1 * 16

   If c1 < 0 Then c1 = 0

   If c1 > 255 Then fadeout = 255 else fadeout = c1

   c1 = pixels_per_div
   Shift c1, Right, 2, Signed

   If c1 > 8 Then
      LineWIDTH c1
   Else
      LineWIDTH 8
   End If



   TempL = mm(0) AND -16384
   For m1 = TempL to mm(1) Step &H4000

      x = m2s(m1)

      If -60 <= x AND x <= 512 Then
         n = m1
         Shift n, Right, 14, Signed
         h = 7 AND n
         h = 3 * n

         ColorRGB 0, 0, 0
         If h = 0 Then
            Color_A 192
         Else
            Color_A 64
         End If

         Begin_G LINES
         Vertex2F x * 16, 0
         Vertex2F x * 16, 272 * 16

         If fadeout > 0 Then
            Decr x
            ColorRGB &Hd0, &Hd0, &Hd0
            Color_A fadeout
            CmdNumber x, 0, 26, OPT_RIGHTX OR 2, h
            CmdText x, 0, 26, 0, ":00"
         End IF
      End IF

   Next

   Color_A 255

   For i = 0 to YY

      x32 = s2m(SUBDIV * i)

      x = x32 + rsin(7117, x32)

      TempL = 217 * x32
      Shift TempL, Right, 8, Signed
      w = rsin(1200, TempL)
      v = rsin(700, 3 * x)

      y(i) = 130 * 16
      y(i) = y(i) + v
      y(i) = y(i) + w

   Next


   StencilOP INCRx, INCRx
   Begin_G EDGE_STRIP_B
   For i = 0 to YY
      x = 16 * SUBDIV
      x = x * i
      Vertex2F x, y(i)
   Next

   StencilFUNC EQUAL, 1, 255
   StencilOP KEEP, KEEP
   CmdGradient 0, 0, &Hf1b608, 0, 220, &H98473a

   StencilFUNC ALWAYS, 1, 255
   ColorRGB &HE0, &HE0, &HE0
   LineWIDTH 24
   Begin_G LINE_STRIP

   for i = 0 to YY
      x = 16 * SUBDIV
      x = x * i
      Vertex2F x, y(i)
   Next

   c1 = pixels_per_div
   Shift c1, Right, 2, Signed

   If c1 > 24 Then
      clock_r = 24
   Else
      clock_r = c1
   End If

   If clock_r > 4 Then

      Color_A 200
      ColorRGB &Hff, &Hff, &Hff
      options = OPT_NOSECS OR OPT_FLAT

      If clock_r < 10 Then
         options = options OR OPT_NOTICKS
      End If

      TempL = mm(0) AND -16384
      For m1 = TempL to mm(1) Step &H4000

         x = m2s(m1)

         n = m1
         Shift n, Right, 14, Signed
         h = 3 AND n
         h = h * 3

         If x >= -1024 Then
            CmdClock x, 270 - 24, clock_r, options, h, 0, 0, 0
         End If
      Next

   End If

End Sub ' End of Plot


'-------------------------------------------------------------------------------------------
Function rsin (Byval r As Integer, Byval th As Word) As Integer
'-------------------------------------------------------------------------------------------
   Local th4 As Integer, p as Integer, x As Long
   Local s As Word
   Local t As Long

   Shift th, Right, 6, Signed

   th4 = th AND 511

   x = th4 AND 256
   If x > 0 Then
      th4 = 512 - th4 ' 256->256 257->255, etc
   End If

   s = Lookup(th4, sintab)

   t = s * r
   Shift t, Right, 16, Signed
   p = t

   x = th AND 512
   If x > 0 Then
      p = -p
   End If

   rsin =  p

End Function ' End of rSin

'-------------------------------------------------------------------------------------------
Sub TSet (Byval x0 As Long, Byval y0 As Integer, Byval x1 As Long, Byval y1 As Integer )
'-------------------------------------------------------------------------------------------
   Local xd As Long
   Local yd As Integer

   xd = x1 - x0
   yd = y1 - y0
   mS1 = yd / xd

   If mS1 < m_min Then
      mS1 = m_min
   End If

   cS1 = mS1 * x0
   cS1 = y0 - cS1

End Sub

'-------------------------------------------------------------------------------------------
Sub TSset (Byval x0 As Long, Byval y0 As Integer)
'-------------------------------------------------------------------------------------------

   cS1 = mS1 * x0
   cS1 = y0 - cS1

End Sub

'-------------------------------------------------------------------------------------------
Function m2s (Byval x As Long) As Integer
'-------------------------------------------------------------------------------------------

   Local Temp2L As Single

   Temp2L = mS1 * x
   Temp2L = Temp2L + cS1

   m2s = Temp2L

End Function

'-------------------------------------------------------------------------------------------
Function s2m(Byval y2 As Integer) As Long
'-------------------------------------------------------------------------------------------

   Local Temp2S As Single

   Temp2S = y2 - cS1
   Temp2S = Temp2S / mS1

   s2m = Temp2S

End Function

'-------------------------------------------------------------------------------------------
Sub Read_Extended (Byref sx() As Integer, Byref sy() As Integer)
'-------------------------------------------------------------------------------------------

   Local sxy0 As Dword, sxyA As Dword, sxyB As Dword, sxyC As Dword
   Local xx As Dword


   sxy0 = Rd32(Reg_cTouch_Touch0_XY)
   sxyA = Rd32(Reg_cTouch_Touch1_XY)
   sxyB = Rd32(Reg_cTouch_Touch2_XY)
   sxyC = Rd32(Reg_cTouch_Touch3_XY)

   xx = sxy0
   Shift xx, Right, 16, SIGNED
   sx(0+_base) = xx
   sy(0+_base) = sxy0

   xx = sxyA
   Shift xx, Right, 16, SIGNED
   sx(1+_base) = xx
   sy(1+_base) = sxyA

   xx = sxyB
   Shift xx, Right, 16, SIGNED
   sx(2+_base) = xx
   sy(2+_base) = sxyB

   xx = sxyC
   Shift xx, Right, 16, SIGNED
   sx(3+_base) = xx
   sy(3+_base) = sxyC

   sx(4+_base) = Rd16(Reg_cTouch_Touch4_X)
   sy(4+_base) = Rd16(Reg_cTouch_Touch4_Y)

End Sub

'-------------------------------------------------------------------------------------------

sintab:
   Data     0%,   402%,   804%,  1206%,  1608%,  2010%,  2412%,  2813%,  3215%,  3617%,  4018%,  4419%
   Data  4821%,  5221%,  5622%,  6023%,  6423%,  6823%,  7223%,  7622%,  8022%,  8421%,  8819%,  9218%
   Data  9615%, 10013%, 10410%, 10807%, 11203%, 11599%, 11995%, 12390%, 12785%, 13179%, 13573%, 13966%
   Data 14358%, 14750%, 15142%, 15533%, 15923%, 16313%, 16702%, 17091%, 17479%, 17866%, 18252%, 18638%
   Data 19023%, 19408%, 19791%, 20174%, 20557%, 20938%, 21319%, 21699%, 22078%, 22456%, 22833%, 23210%
   Data 23585%, 23960%, 24334%, 24707%, 25079%, 25450%, 25820%, 26189%, 26557%, 26924%, 27290%, 27655%
   Data 28019%, 28382%, 28744%, 29105%, 29465%, 29823%, 30181%, 30537%, 30892%, 31247%, 31599%, 31951%
   Data 32302%, 32651%, 32999%, 33346%, 33691%, 34035%, 34378%, 34720%, 35061%, 35400%, 35737%, 36074%
   Data 36409%, 36742%, 37075%, 37406%, 37735%, 38063%, 38390%, 38715%, 39039%, 39361%, 39682%, 40001%
   Data 40319%, 40635%, 40950%, 41263%, 41574%, 41885%, 42193%, 42500%, 42805%, 43109%, 43411%, 43711%
   Data 44010%, 44307%, 44603%, 44896%, 45189%, 45479%, 45768%, 46055%, 46340%, 46623%, 46905%, 47185%
   Data 47463%, 47739%, 48014%, 48287%, 48558%, 48827%, 49094%, 49360%, 49623%, 49885%, 50145%, 50403%
   Data 50659%, 50913%, 51165%, 51415%, 51664%, 51910%, 52155%, 52397%, 52638%, 52876%, 53113%, 53347%
   Data 53580%, 53810%, 54039%, 54265%, 54490%, 54712%, 54933%, 55151%, 55367%, 55581%, 55793%, 56003%
   Data 56211%, 56416%, 56620%, 56821%, 57021%, 57218%, 57413%, 57606%, 57796%, 57985%, 58171%, 58355%
   Data 58537%, 58717%, 58894%, 59069%, 59242%, 59413%, 59582%, 59748%, 59912%, 60074%, 60234%, 60391%
   Data 60546%, 60699%, 60849%, 60997%, 61143%, 61287%, 61428%, 61567%, 61704%, 61838%, 61970%, 62100%
   Data 62227%, 62352%, 62474%, 62595%, 62713%, 62828%, 62941%, 63052%, 63161%, 63267%, 63370%, 63472%
   Data 63570%, 63667%, 63761%, 63853%, 63942%, 64029%, 64114%, 64196%, 64275%, 64353%, 64427%, 64500%
   Data 64570%, 64637%, 64702%, 64765%, 64825%, 64883%, 64938%, 64991%, 65042%, 65090%, 65135%, 65178%
   Data 65219%, 65257%, 65293%, 65326%, 65357%, 65385%, 65411%, 65435%, 65456%, 65474%, 65490%, 65504%
   Data 65515%, 65523%, 65530%, 65533%, 65535%