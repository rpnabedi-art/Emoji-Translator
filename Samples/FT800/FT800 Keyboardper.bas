' FT800 Keyboard
' This application is a Keyboard Demonstration
' using CmdButtons (FT800 platform).
' Ported from http://www.ftdichip.com/Support/SoftwareExamples/EVE/FT_App_Keyboard.zip
' Requires Bascom 2.0.7.8 or greater

$regfile = "M328pdef.dat"
$crystal = 8000000
$baud = 19200
$hwstack = 90
$swstack = 90
$framesize = 400
$notypecheck

Config Ft800 =  spi , Ftsave = 0 , Ftdebug = 0 , Ftcs = portd.4 , Ftpd = Portd.3       'Arduino Eleven
'Config Ft800 =  spi , Ftsave = 0 , Ftdebug = 0 , Ftcs = Portd.4 , Ftpd = Portd.3       'Arduino Eleven

Config Submode = New
Config Spi = Hard , Interrupt = Off , Data_order = Msb , Master = Yes , Polarity = Low , Phase = 0 , Clockrate = 4 , Noss = 1
Spsr = 1                                                    ' Makes SPI run at 8Mhz instead of 4Mhz

'Ft800_cs = 1
'Ft800_pd = 1


$include "FT800.inc"            'Definitions
$include "FT800_Functions.inc"  'High level Functions

Declare Sub Notepad
Declare Function Read_keypad() As Byte
Declare Function Read_keys() As Byte
Declare Function Ft_gpu_rom_font_wh(byval Charasc As Byte , Byval Font As Byte) As Byte
Declare Function Istouch() As Byte
Declare Sub Introftdi

Const Special_fun = 251
Const Back_space = 251                                      ' Back space
Const Caps_lock = 252                                       ' Caps Lock
Const Number_lock = 253                                     ' Number Lock
Const Back = 254                                            ' Clear
Const Font = 27                                             ' Font Size
Const Max_lines = 4
Const Line_startpos = Ft_dispwidth / 50                     ' Start of Line
Const Line_endpos = Ft_dispwidth
Const Maxpixelsperline =(line_endpos - Line_startpos)

Key_detect Alias 0
Caps Alias 1
Numeric Alias 2

' General Program Variables and Declarations
Dim Temp1 As Byte
Dim Temp_tag As Byte
Dim Touch_detect As Byte
Dim Flag As Byte
Dim Lastchr As String * 1
Dim Fontx As Byte
Dim Notepadx(max_lines) As String * 80
Dim Pixelsinline(max_lines) As Integer
Dim Read_sfk As Byte
Dim Tval As Byte
Dim But_opt As Word
Dim Howmanychars As Byte
Dim Line2disp As Integer
Dim Nextline As Integer
Dim Maxpixelswide As Integer
Dim Lastwidth As Byte
Dim Char As String * 10

Spiinit

Touch_detect = 1
Notepadx = ""
Fontx = 27                                                  ' Font Size
Line2disp = 1
Nextline = 1
Maxpixelswide = Maxpixelsperline
Lastwidth = 0

   If Ft800_init() = 1 Then End                             ' Initialise the FT800

   Introftdi

Do

   Gosub Notepad

Loop


End

'------------------------------------------------------------------------------------------------------------
Notepad:
'------------------------------------------------------------------------------------------------------------

   ' intial setup

   Read_sfk = Read_keypad()                                 ' read the keys

   If Flag.key_detect > 0 Then                              ' check if key is pressed

      Flag.key_detect = 0                                   ' clear it

      If Read_sfk >= Special_fun Then                       ' check any special function keys are pressed

         Select Case Read_sfk

            Case Back_space

               ' Check we have room to delete a characters or it has to be deleted on the previous line
               Howmanychars = Len(notepadx(line2disp))

               If Howmanychars > 1 Then

                     Lastchr = Right(notepadx(line2disp) , 1)
                     Read_sfk = Asc(lastchr)
                     'Get the current width of the character

                     Tval = Ft_gpu_rom_font_wh(read_sfk , Font)

                     Decr Howmanychars
                     Notepadx(line2disp) = Left(notepadx(line2disp) , Howmanychars)

                     Pixelsinline(line2disp) = Pixelsinline(line2disp) - Tval
               Else
                     Pixelsinline(line2disp) = 0
                     Notepadx(line2disp) = ""
                     If Line2disp > 1 Then Decr Line2disp

               End If


            Case Caps_lock
               Toggle Flag.caps                             ' toggle the caps lock on when the detected

            Case Number_lock
               Toggle Flag.numeric                          ' toggle the number lock on when detected

            Case Back
               Line2disp = 1
               Notepadx(1) = ""
               Notepadx(2) = ""
               Notepadx(3) = ""
               Notepadx(4) = ""
               Pixelsinline(1) = 0
               Pixelsinline(2) = 0
               Pixelsinline(3) = 0
               Pixelsinline(4) = 0
               Lastwidth = 0
               Howmanychars = 0

         End Select

      Else

         'Get the current width of the character
         Tval = Ft_gpu_rom_font_wh(read_sfk , Font)

         ' Check that the Width of all the characters
         ' in the current line don't exceed the Length of 'MaxPixelsPerLIne'
         Pixelsinline(line2disp) = Pixelsinline(line2disp) + Tval

         If Pixelsinline(line2disp) > Maxpixelswide Then

            ' remove the last width from previous
            Pixelsinline(line2disp) = Pixelsinline(line2disp) - Tval

            If Line2disp < Max_lines Then
               Incr Line2disp
               ' Add the pixels to the next line
               Pixelsinline(line2disp) = Pixelsinline(line2disp) + Tval
            End If

         Else

            Notepadx(line2disp) = Notepadx(line2disp) + Chr(read_sfk)

         End If

      End If

   End If

   ' Start the new Display list
   Clearcolorrgb 100 , 100 , 100
   Clear_b 1 , 1 , 1
   Colorrgb 255 , 255 , 255
   Tagmask 1                                                ' Enable tagbuffer update
   Cmdfgcolor &H703800
   Cmdbgcolor &H703800

   If Read_sfk = Back Then
      But_opt = Opt_flat
   Else
      But_opt = 0                                           ' Button color change if the button during press
   End If

   Tag Back                                                 ' Back   Return to Home
   Cmdbutton Ft_dispwidth * 0.850 , Ft_dispheight * 0.83 , Ft_dispwidth * 0.146 , Ft_dispheight * 0.112 , Font , But_opt , "Clear"

   If Read_sfk = Back_space Then
      But_opt = Opt_flat
   Else
      But_opt = 0
   End If

   Tag Back_space                                           ' BackSpace
   Cmdbutton Ft_dispwidth * 0.871 , Ft_dispheight * 0.70 , Ft_dispwidth * 0.125 , Ft_dispheight * 0.112 , Font , But_opt , "<-"

   If Read_sfk = 32 Then
      But_opt = Opt_flat
   Else
      But_opt = 0
   End If

   Tag 32                                                   ' Space
   Cmdbutton Ft_dispwidth * 0.115 , Ft_dispheight * 0.83 , Ft_dispwidth * 0.73 , Ft_dispheight * 0.112 , Font , But_opt , "Space"

   If Flag.numeric = 0 Then

      If Flag.caps = 1 Then Char = "QWERTYUIOP" Else Char = "qwertyuiop"
      Cmdkeys 0 , Ft_dispheight * 0.442 , Ft_dispwidth -2 , Ft_dispheight * 0.112 , Font , Read_sfk , Char

      If Flag.caps = 1 Then Char = "ASDFGHJKL" Else Char = "asdfghjkl"
      Cmdkeys Ft_dispwidth * 0.036 , Ft_dispheight * 0.57 , Ft_dispwidth * 0.96 , Ft_dispheight * 0.112 , Font , Read_sfk , Char

      If Flag.caps = 1 Then Char = "ZXCVBNM" Else Char = "zxcvbnm"
      Cmdkeys Ft_dispwidth * 0.125 , Ft_dispheight * 0.70 , Ft_dispwidth * 0.73 , Ft_dispheight * 0.112 , Font , Read_sfk , Char


      If Read_sfk = Caps_lock Then
         But_opt = Opt_flat
      Else
         But_opt = 0
      End If

      Tag Caps_lock                                         ' Capslock
      Cmdbutton 0 , Ft_dispheight * 0.70 , Ft_dispwidth * 0.10 , Ft_dispheight * 0.112 , Font , But_opt , "a^"

      If Read_sfk = Number_lock Then
         But_opt = Opt_flat
      Else
         But_opt = 0
      End If

      Tag Number_lock                                       ' Num lock
      Cmdbutton 0 , Ft_dispheight * 0.83 , Ft_dispwidth * 0.10 , Ft_dispheight * 0.112 , Font , But_opt , "12*"
   End If

   If Flag.numeric = 1 Then

      Cmdkeys 0 , Ft_dispheight * 0.442 , Ft_dispwidth -2 , Ft_dispheight * 0.112 , Font , Read_sfk , "1234567890"
      Cmdkeys Ft_dispwidth * 0.036 , Ft_dispheight * 0.57 , Ft_dispwidth * 0.96 , Ft_dispheight * 0.112 , Font , Read_sfk , "-@#$%^&*("
      Cmdkeys Ft_dispwidth * 0.125 , Ft_dispheight * 0.70 , Ft_dispwidth * 0.73 , Ft_dispheight * 0.112 , Font , Read_sfk , ")_+[]{}"

      If Read_sfk = Number_lock Then
         But_opt = Opt_flat
      Else
         But_opt = 0
      End If

      Tag 253
      Cmdbutton 0 , Ft_dispheight * 0.83 , Ft_dispwidth * 0.10 , Ft_dispheight * 0.112 , Font , But_opt , "AB*"
   End If

   Tagmask 0                                                ' Disable the tag buffer updates
   Scissorxy 0 , 0
   Scissorsize Ft_dispwidth , Ft_dispheight * 0.405
   Clearcolorrgb 255 , 255 , 255
   Clear_b 1 , 1 , 1
   Colorrgb 0 , 0 , 0                                       ' Text Color

   Const S8 = Ft_dispheight * .073
   Nextline = 1

   For Temp1 = 1 To Line2disp

      If Temp1 = Line2disp Then
         Cmdtext 1 , Nextline , Font , 0 , Notepadx(temp1) + "_"
      Else
         Cmdtext Temp1 , Nextline , Font , 0 , Notepadx(temp1)
      End If
      Nextline = Nextline + S8
      Nextline = Nextline + 3

   Next

   Updatescreen

Return                                                      ' NotePad

'------------------------------------------------------------------------------------------------------------
Function Ft_gpu_rom_font_wh(byval Charasc As Byte , Byval Font As Byte) As Byte
'------------------------------------------------------------------------------------------------------------

   Local Ptr As Dword
   Local Wptr As Dword
   Local Width As Byte
   Local Tempb As Byte

   Ptr = Rd32(&Hffffc)
   Tempb = Font - 16                                        ' table starts at font 16
   Wptr = 148 * Tempb
   Wptr = Wptr + Ptr
   Wptr = Wptr + Charasc
   ' Read Width of the character
   Width = Rd8(wptr)

   Ft_gpu_rom_font_wh = Width

End Function                                                ' Ft_Gpu_Rom_Font_WH

'------------------------------------------------------------------------------------------------------------
Function Read_keypad() As Byte
'------------------------------------------------------------------------------------------------------------
   Local Read_tag As Byte

   Read_tag = Rd8(reg_touch_tag)

   If Istouch() = 0 Then Touch_detect = 0

   If Read_tag <> 0 Then                                    ' Allow if the Key is released

      If Temp_tag <> Read_tag And Touch_detect = 0 Then

         Temp_tag = Read_tag                                ' Load the Read tag to temp variable
         Play_sound &H51 , 100
         Touch_detect = 1
      End If

   Else

      If Temp_tag <> 0 Then
         Flag.key_detect = 1
         Read_tag = Temp_tag
      End If

      Temp_tag = 0

   End If

   Read_keypad = Read_tag

End Function                                                ' Read_Keypad

'-----------------------------------------------------------
Function Read_keys() As Byte
'-----------------------------------------------------------

   Local Read_tag As Byte
   Local Ret_tag As Byte

   Read_tag = Rd8(reg_touch_tag)
   Ret_tag = 0


   If Read_tag <> 0 And Temp_tag <> Read_tag Then           ' Allow if the Key is released

      Temp_tag = Read_tag
      Sk = Read_tag                                         ' Load the Read tag to temp variable

   End If

   If Read_tag = 0 Then

      Ret_tag = Temp_tag
      Temp_tag = 0
      Sk = 0

   End If

   Read_keys = Ret_tag

End Function                                                ' Read_Keys

'------------------------------------------------------------------------------------------------------------
Function Istouch() As Byte
'------------------------------------------------------------------------------------------------------------
   Local Retistouch As Word

   Retistouch = Rd16(reg_touch_raw_xy)
   Retistouch = Retistouch And &H8000

   Istouch = Retistouch

End Function                                                ' istouch

'------------------------------------------------------------------------------------------------------------
Sub Introftdi
'------------------------------------------------------------------------------------------------------------

   Local Tempw As Dword
   Local Dloffset As Word
   Local Tagx As Byte
   Local Temp2 As Byte

   ' Variables for Read_Keys()
   Dim Sk As Byte

    ' home_setup()
   Tempw = Loadlabel(home_star_icon)
   Cmdinflatex 250 * 1024 , Tempw , 460

   'Set the Bitmap properties for the ICONS
   Clearscreen
   Colorrgb 255 , 255 , 255
   Bitmaphandle 13                                          ' handle for background stars
   Bitmapsource 250 * 1024                                  ' Starting address in gram
   Bitmaplayout L4 , 16 , 32                                ' format
   Bitmapsize Nearest , Repeat , Repeat , 512 , 512
   Bitmaphandle 14                                          ' handle for background stars
   Bitmapsource 250 * 1024                                  ' Starting address in G_RAM
   Bitmaplayout L4 , 16 , 32                                ' format
   Bitmapsize Nearest , Border , Border , 32 , 32
   Updatescreen

   ' Touch Screen Calibration
   Clearscreen
   Cmdtext Ft_dispwidth / 2 , Ft_dispheight / 2 , 26 , Opt_centerx Or Opt_centery , "Please tap on a dot"
   Cmdcalibrate

   ' Ftdi Logo animation
   Cmdlogo
   Waitcmdfifoempty

   Do
     Temp2 = Rd16(reg_cmd_write)
   Loop Until Temp2 = 0

   Ftfifo_writeptr = 0
   Ftfreespaceleft = 4092                                   ' (4096-4)

   Dloffset = Rd16(reg_cmd_dl)
   Dloffset = Dloffset - 4
   ' Copy the Displaylist from DL RAM to GRAM
   Cmdmemcpy 100000 , Ram_dl , Dloffset

   'Enter into Info Screen
   Do

      Cmddlstart
      Clearscreen
      Cmdappend 100000 , Dloffset

      'Reset the BITMAP properties used during Logo animation
      Bitmaptransform 256 , "A"
      Bitmaptransform 0 , "B"
      Bitmaptransform 0 , "C"
      Bitmaptransform 0 , "D"
      Bitmaptransform 256 , "E"
      Bitmaptransform 0 , "F"
      Savecontext
      ' Display the information with transparent Logo using Edge Strip
      Colorrgb 219 , 180 , 150
      Color_a 220
      Begin_g Edge_strip_a
      Vertex2f 0 , Ft_dispheight * 16
      Vertex2f Ft_dispwidth * 16 , Ft_dispheight * 16
      Color_a 255
      Restorecontext
      Colorrgb 0 , 0 , 0

      ' INFORMATION
      Cmdtext Ft_dispwidth / 2 , 20 , 28 , Opt_centerx Or Opt_centery , "FT800 Gauges Application"
      Cmdtext Ft_dispwidth / 2 , 60 , 26 , Opt_centerx Or Opt_centery , "APP to demonstrate interactive Key Board,"
      Cmdtext Ft_dispwidth / 2 , 90 , 26 , Opt_centerx Or Opt_centery , "using String, Keys & Buttons."
      Cmdtext Ft_dispwidth / 2 , 140 , 28 , Opt_centerx Or Opt_centery , "written using BASCOM Compiler"
      Cmdtext Ft_dispwidth / 2 , Ft_dispheight -30 , 26 , Opt_centerx Or Opt_centery , "Click to play"

      'Check the Play key and change the color
      If Sk <> 80 Then                                      ' "P"
         Colorrgb 255 , 255 , 255
      Else
         Colorrgb 100 , 100 , 100
      End If

      Begin_g Ftpoints
      Pointsize 20 * 16
      Tag 80                                                ' "P"
      Vertex2f(ft_dispwidth / 2) * 16 ,(ft_dispheight -60) * 16
      Colorrgb 180 , 35 , 35
      Begin_g Bitmaps
      Vertex2ii(ft_dispwidth / 2) - 14 , Ft_dispheight -75 , 14 , 4


      Updatescreen

      Tagx = Read_keys()

   Loop Until Tagx = 80                                     ' "P"

End Sub                                                     'IntroFTDI

'------------------------------------------------------------------------------------------------------------
Home_star_icon:                                             '460 items

   Data &H78 , &H9C , &HE5 , &H94 , &HBF , &H4E , &HC2 , &H40 , &H1C , &HC7 , &H7F , &H2D , &H04 , &H8B , &H20 , &H45 , &H76 , &H14 , &H67 , &HA3 , &HF1 , &H0D , &H64
   Data &H75 , &HD2 , &HD5 , &H09 , &H27 , &H17 , &H13 , &HE1 , &H0D , &HE4 , &H0D , &H78 , &H04 , &H98 , &H5D , &H30 , &H26 , &H0E , &H4A , &HA2 , &H3E , &H82 , &H0E
   Data &H8E , &H82 , &HC1 , &H38 , &H62 , &H51 , &H0C , &H0A , &H42 , &H7F , &HDE , &HB5 , &H77 , &HB4 , &H77 , &H17 , &H28 , &H21 , &H26 , &H46 , &HFD , &H26 , &HCD
   Data &HE5 , &HD3 , &H7C , &HFB , &HBB , &HFB , &HFD , &HB9 , &H02 , &HCC , &HA4 , &HE8 , &H99 , &H80 , &H61 , &HC4 , &H8A , &H9F , &HCB , &H6F , &H31 , &H3B , &HE3
   Data &H61 , &H7A , &H98 , &H84 , &H7C , &H37 , &HF6 , &HFC , &HC8 , &HDD , &H45 , &H00 , &HDD , &HBA , &HC4 , &H77 , &HE6 , &HEE , &H40 , &HEC , &H0E , &HE6 , &H91
   Data &HF1 , &HD2 , &H00 , &H42 , &H34 , &H5E , &HCE , &HE5 , &H08 , &H16 , &HA0 , &H84 , &H68 , &H67 , &HB4 , &H86 , &HC3 , &HD5 , &H26 , &H2C , &H20 , &H51 , &H17
   Data &HA2 , &HB8 , &H03 , &HB0 , &HFE , &H49 , &HDD , &H54 , &H15 , &HD8 , &HEE , &H73 , &H37 , &H95 , &H9D , &HD4 , &H1A , &HB7 , &HA5 , &H26 , &HC4 , &H91 , &HA9
   Data &H0B , &H06 , &HEE , &H72 , &HB7 , &HFB , &HC5 , &H16 , &H80 , &HE9 , &HF1 , &H07 , &H8D , &H3F , &H15 , &H5F , &H1C , &H0B , &HFC , &H0A , &H90 , &HF0 , &HF3
   Data &H09 , &HA9 , &H90 , &HC4 , &HC6 , &H37 , &HB0 , &H93 , &HBF , &HE1 , &H71 , &HDB , &HA9 , &HD7 , &H41 , &HAD , &H46 , &HEA , &H19 , &HA9 , &HD5 , &HCE , &H93
   Data &HB3 , &H35 , &H73 , &H0A , &H69 , &H59 , &H91 , &HC3 , &H0F , &H22 , &H1B , &H1D , &H91 , &H13 , &H3D , &H91 , &H73 , &H43 , &HF1 , &H6C , &H55 , &HDA , &H3A
   Data &H4F , &HBA , &H25 , &HCE , &H4F , &H04 , &HF1 , &HC5 , &HCF , &H71 , &HDA , &H3C , &HD7 , &HB9 , &HB2 , &H48 , &HB4 , &H89 , &H38 , &H20 , &H4B , &H2A , &H95
   Data &H0C , &HD5 , &HEF , &H5B , &HAD , &H96 , &H45 , &H8A , &H41 , &H96 , &H7A , &H1F , &H60 , &H0D , &H7D , &H22 , &H75 , &H82 , &H2B , &H0F , &HFB , &HCE , &H51
   Data &H3D , &H2E , &H3A , &H21 , &HF3 , &H1C , &HD9 , &H38 , &H86 , &H2C , &HC6 , &H05 , &HB6 , &H7B , &H9A , &H8F , &H0F , &H97 , &H1B , &H72 , &H6F , &H1C , &HEB
   Data &HAE , &HFF , &HDA , &H97 , &H0D , &HBA , &H43 , &H32 , &HCA , &H66 , &H34 , &H3D , &H54 , &HCB , &H24 , &H9B , &H43 , &HF2 , &H70 , &H3E , &H42 , &HBB , &HA0
   Data &H95 , &H11 , &H37 , &H46 , &HE1 , &H4F , &H49 , &HC5 , &H1B , &HFC , &H3C , &H3A , &H3E , &HD1 , &H65 , &H0E , &H6F , &H58 , &HF8 , &H9E , &H5B , &HDB , &H55
   Data &HB6 , &H41 , &H34 , &HCB , &HBE , &HDB , &H87 , &H5F , &HA9 , &HD1 , &H85 , &H6B , &HB3 , &H17 , &H9C , &H61 , &H0C , &H9B , &HA2 , &H5D , &H61 , &H10 , &HED
   Data &H2A , &H9B , &HA2 , &H5D , &H61 , &H10 , &HED , &H2A , &H9B , &HA2 , &H5D , &H61 , &H10 , &HED , &H2A , &H9B , &HED , &HC9 , &HFC , &HDF , &H14 , &H54 , &H8F
   Data &H80 , &H7A , &H06 , &HF5 , &H23 , &HA0 , &H9F , &H41 , &HF3 , &H10 , &H30 , &H4F , &H41 , &HF3 , &H18 , &H30 , &HCF , &HCA , &HFC , &HFF , &H35 , &HC9 , &H79
   Data &HC9 , &H89 , &HFA , &H33 , &HD7 , &H1D , &HF6 , &H5E , &H84 , &H5C , &H56 , &H6E , &HA7 , &HDA , &H1E , &HF9 , &HFA , &HAB , &HF5 , &H97 , &HFF , &H2F , &HED
   Data &H89 , &H7E , &H29 , &H9E , &HB4 , &H9F , &H74 , &H1E , &H69 , &HDA , &HA4 , &H9F , &H81 , &H94 , &HEF , &H4F , &HF6 , &HF9 , &H0B , &HF4 , &H65 , &H51 , &H08