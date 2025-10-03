' FT800 RadioButton.Bas  Demonstrating the use of a RadioButton
' FT800 platform.
' Original Function came from FT800 Signals.Bas
' Requires Bascom 2.0.7.8 or greater

$regfile = "xm128a1def.dat"
$crystal = 32000000
$hwstack = 52
$swstack = 52
$framesize = 60

Config Osc = Enabled , 32mhzosc = Enabled
Config Sysclock = 32mhz                                     '--> 32MHz

Config Com1 = 57600 , Mode = Asynchroneous , Parity = None , Stopbits = 1 , Databits = 8
Open "COM1:" For Binary As #1

Config Submode = New

Config Ft800 = Spid , Ftsave = 0 , Ftdebug = 0 , Ftcs = Portd.4 , Ftpd = Portd.0  ' Olimex
Config Spid = Hard , Master = Yes , Mode = 0 , Clockdiv = Clk32 , Data_order = Msb , Ss = none

$Include "FT80x.inc"
$Include "FT80x_Functions.inc"

Declare Function Read_Keys() As Byte

Spiinit

If FT800_Init()=1 Then End   ' Initialise the FT800


Dim tagx As Byte
Dim opt As Byte
Dim Temp_Tag As Byte  ' used in Read_Keys() Function
Dim Sk  As Byte       ' used in Read_Keys() Function

opt = 3  ' Default RadioButton


Do
   ClearScreen

   ColorRGBdw red
   Color_A 100
   LineWidth 10 * 16
   Begin_G Lines
   Vertex2II 40, 20, 0, 0
   Vertex2II 170, 20, 0, 0
   RestoreContext

   CmdText 40, 20, 26, OPT_CENTERY, "RadionButton Demo"

   tagx = Read_keys()
   If tagx > 0 Then opt = tagx

   'Radiobutton Byval X As Integer      ' X Position
   '            Byval Y As Integer      ' Y Position
   '            Byval Bgcolor As Dword  ' BackGround Color
   '            Byval Fgcolor As Dword  ' ForGround Color
   '            Byval Psize As Byte     ' Circle Diameter
   '            Byval Tagx As Byte      ' Tag value
   '            Byval Opt As Byte       ' Selection

   RadioButton 50 ,  60, White, Black, 8, 1, opt
   RadioButton 50 ,  80, White, Black, 8, 2, opt
   RadioButton 50 , 100, White, Black, 8, 3, opt
   RadioButton 50 , 120, White, Black, 8, 4, opt
   RadioButton 50 , 140, White, Black, 8, 5, opt
   RadioButton 50 , 160, White, Black, 8, 6, opt
   RadioButton 50 , 180, White, Black, 8, 7, opt
   RadioButton 50 , 200, White, Black, 8, 8, opt

   ColorRGBdw Purple
   CmdText 70 ,  60, 26, OPT_CENTERY,"Option 1"
   ColorRGBdw Cyan
   CmdText 70 ,  80, 26, OPT_CENTERY,"Option 2"
   ColorRGBdw Green
   CmdText 70 , 100, 26, OPT_CENTERY,"Option 3"
   ColorRGBdw Yellow
   CmdText 70 , 120, 26, OPT_CENTERY,"Option 4"
   ColorRGBdw Orange
   CmdText 70 , 140, 26, OPT_CENTERY,"Option 5"
   ColorRGBdw Red
   CmdText 70 , 160, 26, OPT_CENTERY,"Option 6"
   ColorRGBdw Brown
   CmdText 70 , 180, 26, OPT_CENTERY,"Option 7"
   ColorRGBdw White
   CmdText 70 , 200, 26, OPT_CENTERY,"Option 8"

   Select Case opt

      CASE 1
         ColorRGBdw Purple
         CmdText 40, Ft_DispHeight-10, 26, OPT_CENTERY, "Option 1 Selected"

      CASE 2
         ColorRGBdw Cyan
         CmdText 40, Ft_DispHeight-10, 26, OPT_CENTERY, "Option 2 Selected"

      CASE 3
         ColorRGBdw Green
         CmdText 40, Ft_DispHeight-10, 26, OPT_CENTERY, "Option 3 Selected"

      CASE 4
         ColorRGBdw Yellow
         CmdText 40, Ft_DispHeight-10, 26, OPT_CENTERY, "Option 4 Selected"

      CASE 5
         ColorRGBdw Orange
         CmdText 40, Ft_DispHeight-10, 26, OPT_CENTERY, "Option 5 Selected"

      CASE 6
         ColorRGBdw Red
         CmdText 40, Ft_DispHeight-10, 26, OPT_CENTERY, "Option 6 Selected"

      CASE 7
         ColorRGBdw Brown
         CmdText 40, Ft_DispHeight-10, 26, OPT_CENTERY, "Option 7 Selected"

      CASE 8
         ColorRGBdw White
         CmdText 40, Ft_DispHeight-10, 26, OPT_CENTERY, "Option 8 Selected"

   End Select

   UpdateScreen

Loop


End

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