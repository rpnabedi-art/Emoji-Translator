' FT800 ImageViewer Application demonstrating APP to demonstrate interactive Jpeg decode
' Original code from http://www.ftdichip.com/Support/SoftwareExamples/EVE/FT_App_Imageviewer.zip
' Requires Bascom 2.0.7.8 or greater

$Regfile = "M328pdef.dat"
$Crystal = 8000000
$Baud = 115200
$HwStack = 80
$SwStack = 80
$FrameSize = 128
$NOTYPECHECK

Config ft800=spi , ftsave=0, ftdebug=0 , ftcs=portb.2, ftpd=portb.1

Config Base = 0
Config Submode = New
Config Spi = Hard, Interrupt = Off, Data_Order = Msb, Master = Yes, Polarity = Low, Phase = 0, Clockrate = 4, Noss = 1
SPSR = 1  ' Makes SPI run at 8Mhz instead of 4Mhz
'Config Spi = Soft , Din = Pinb.4 , Dout = Portb.3 , Ss =Portb.2 , Clock = Portb.5, Noss = 1, Mode=0

Declare Sub LoadImage

$Include "FT800.inc"
$Include "FT800_Functions.inc"

 ' Macro for size of raw data
Const GOLF_JPEGDATA_SIZE = 4187
Const FT_NUM_BITMAPCELLS = 4
' Application specific includes

Const Bitmap_Format = RGB565
Const Bitmap_Width  = 68
Const Bitmap_Height = 86
Const Bitmap_Stride = 68 * 2
Const Bitmap_Arrayoffset = 0

Spiinit

if FT800_Init()=1 then end   ' Initialise the FT800

LoadImage


Do
Loop


End

'------------------------------------------------------------------------------------------------------------
Sub LoadImage
'------------------------------------------------------------------------------------------------------------

   Local xoffset As Integer, yoffset As Integer
   Local TempDW As Dword

   '*************************************************************************
   '* Below code demonstrates the usage of LoadImage functionality          *
   '* Download the jpeg encoded data into command buffer and in turn        *
   '* coprocessor decodes the jpeg data and output at 0 location            *
   '*************************************************************************

   '* Calculate the screen centre offset based on image dimension *
   xoffset = FT_NUM_BITMAPCELLS * Bitmap_Width
   xoffset = Ft_DispWidth - xoffset
   xoffset = xoffset / 2
   yoffset = Ft_DispHeight - Bitmap_Height
   yoffset = yoffset / 2

   '* Clear the memory at location 0 - any previous junk or bitmap data */
   Const X1 = Bitmap_Stride * Bitmap_Height * FT_NUM_BITMAPCELLS
   CmdMemset 0, 255, X1

   '* Construction of display list to display background and set of golf bitmaps on the foreground */
   ClearColorRGB 0, 255, 255 ' clear the background color
   Clear_B 1, 0, 0 ' clear the color component
   ColorRGB 255, 255, 255 'set the bitmap color to White

   '* Assign the bitmap parameters and display the bitmap at (xoffset,yoffset) coordinates */
   Begin_G BITMAPS
   BitmapSource 0
   BitmapLayout Bitmap_Format, Bitmap_Stride, Bitmap_Height
   BitmapSize BILINEAR, BORDER, BORDER, Bitmap_Width, Bitmap_Height
   Vertex2ii xoffset, yoffset, 0, 0 ' display at (xoffset,yoffset) pixel coordinates
   xoffset = xoffset + Bitmap_Width
   yoffset = yoffset + 10
   Vertex2ii xoffset, yoffset, 0, 1 ' display other cells
   xoffset = xoffset + Bitmap_Width
   yoffset = yoffset + 10
   Vertex2ii xoffset, yoffset, 0, 2
   xoffset = xoffset + Bitmap_Width
   yoffset = yoffset + 10
   Vertex2ii xoffset, yoffset, 0, 3
   End_G

   '* Display of information string at (xoffset,yoffset) pixel coordinates */
   xoffset = Ft_DispWidth / 2
   yoffset = Ft_DispHeight - Bitmap_Height
   yoffset = yoffset - 20
   yoffset = yoffset / 2

   ColorRGBdw &H000000 ' set the color of the informative text to black
   CmdText xoffset, yoffset, 26, OPT_CENTER, "Display bitmap by LoadImage"
   End_G

   ' decode jpeg data into location 0
   CmdLoadImage 0, OPT_NODL ' using option not to generate DL for jpeg image

   SendFromLabel loadlabel(Golf_JpegData) , GOLF_JPEGDATA_SIZE

   UpdateScreen

End Sub

'------------------------------------------------------------------------------------------------------------
Sub SendFromLabel(Byval Label As Word , Byval Count As Dword)
'------------------------------------------------------------------------------------------------------------

   Local LAddr As Dword, Temp As Dword

   Align4 Count

   For ftAddrptr = 0 To Count-1
      Tb = Lookup (ftAddrptr,Label)
      Cmd8 Tb
   Next

End Sub
'------------------------------------------------------------------------------------------------------------

Golf_JpegData: ' 4187
   DATA &Hff,&Hd8,&Hff,&He0,&H00,&H10,&H4a,&H46,&H49,&H46,&H00,&H01,&H01,&H01,&H00,&H48
   DATA &H00,&H48,&H00,&H00,&Hff,&Hdb,&H00,&H43,&H00,&H10,&H0b,&H0c,&H0e,&H0c,&H0a,&H10
   DATA &H0e,&H0d,&H0e,&H12,&H11,&H10,&H13,&H18,&H28,&H1a,&H18,&H16,&H16,&H18,&H31,&H23
   DATA &H25,&H1d,&H28,&H3a,&H33,&H3d,&H3c,&H39,&H33,&H38,&H37,&H40,&H48,&H5c,&H4e,&H40
   DATA &H44,&H57,&H45,&H37,&H38,&H50,&H6d,&H51,&H57,&H5f,&H62,&H67,&H68,&H67,&H3e,&H4d
   DATA &H71,&H79,&H70,&H64,&H78,&H5c,&H65,&H67,&H63,&Hff,&Hdb,&H00,&H43,&H01,&H11,&H12
   DATA &H12,&H18,&H15,&H18,&H2f,&H1a,&H1a,&H2f,&H63,&H42,&H38,&H42,&H63,&H63,&H63,&H63
   DATA &H63,&H63,&H63,&H63,&H63,&H63,&H63,&H63,&H63,&H63,&H63,&H63,&H63,&H63,&H63,&H63
   DATA &H63,&H63,&H63,&H63,&H63,&H63,&H63,&H63,&H63,&H63,&H63,&H63,&H63,&H63,&H63,&H63
   DATA &H63,&H63,&H63,&H63,&H63,&H63,&H63,&H63,&H63,&H63,&H63,&H63,&H63,&H63,&Hff,&Hc0
   DATA &H00,&H11,&H08,&H01,&H58,&H00,&H44,&H03,&H01,&H22,&H00,&H02,&H11,&H01,&H03,&H11
   DATA &H01,&Hff,&Hc4,&H00,&H1b,&H00,&H00,&H01,&H05,&H01,&H01,&H00,&H00,&H00,&H00,&H00
   DATA &H00,&H00,&H00,&H00,&H00,&H00,&H00,&H01,&H02,&H03,&H04,&H05,&H06,&H07,&Hff,&Hc4
   DATA &H00,&H3b,&H10,&H00,&H01,&H04,&H00,&H03,&H05,&H06,&H04,&H04,&H06,&H01,&H05,&H01
   DATA &H00,&H00,&H00,&H01,&H00,&H02,&H03,&H11,&H04,&H12,&H21,&H05,&H13,&H31,&H41,&H51
   DATA &H22,&H61,&H71,&H81,&H91,&Ha1,&H06,&H14,&H32,&H52,&Hb1,&Hc1,&Hd1,&Hf0,&H15,&H23
   DATA &H33,&H42,&H62,&Hf1,&H72,&H43,&H53,&H63,&H73,&H92,&He1,&Hff,&Hc4,&H00,&H19,&H01
   DATA &H00,&H02,&H03,&H01,&H00,&H00,&H00,&H00,&H00,&H00,&H00,&H00,&H00,&H00,&H00,&H00
   DATA &H01,&H02,&H00,&H03,&H04,&H05,&Hff,&Hc4,&H00,&H25,&H11,&H00,&H02,&H02,&H01,&H04
   DATA &H02,&H02,&H02,&H03,&H00,&H00,&H00,&H00,&H00,&H00,&H00,&H00,&H01,&H02,&H11,&H03
   DATA &H12,&H13,&H21,&H51,&H14,&H31,&H04,&H41,&H32,&H52,&H22,&H61,&H91,&Hff,&Hda,&H00
   DATA &H0c,&H03,&H01,&H00,&H02,&H11,&H03,&H11,&H00,&H3f,&H00,&Ha7,&H95,&H19,&H55,&H83
   DATA &H1b,&H11,&Hba,&H66,&H6e,&H2b,&Had,&H68,&He0,&H69,&H91,&H5e,&H91,&H49,&Hb8,&Hc9
   DATA &He3,&Hc3,&H39,&H8c,&H03,&H79,&H23,&Hac,&Hd5,&Hd0,&H68,&Hea,&H4a,&H93,&H0c,&H44
   DATA &Hcd,&H21,&Hec,&H31,&H48,&Hd3,&H4e,&H69,&H37,&Hee,&H95,&H64,&H8d,&Hd5,&Hf2,&H3b
   DATA &Hc3,&H35,&H1d,&H4d,&H70,&H37,&H2a,&H70,&H8f,&Hbd,&H4a,&H60,&Hef,&H40,&H85,&Hed
   DATA &He0,&H53,&H36,&H84,&H51,&H97,&Hd8,&Hc1,&H19,&Hfe,&Hd2,&H12,&H88,&Hdf,&Hd0,&H15
   DATA &H20,&H6c,&Ha3,&H98,&H4e,&H6e,&Hf3,&Hfb,&H80,&H3e,&H49,&H5b,&H2c,&H8c,&H57,&Ha2
   DATA &H0c,&Hae,&He6,&Hd4,&H2b,&H0f,&H6b,&Hb4,&Hbe,&H88,&H52,&Hd1,&H1c,&H5d,&Hfb,&H18
   DATA &H59,&Hda,&Hf3,&H54,&Hf1,&Hd8,&Hd8,&Hf0,&H6d,&Ha3,&Hda,&H90,&Hf0,&H68,&He5,&He2
   DATA &Haf,&H62,&H1e,&Hc8,&H21,&H92,&H69,&H3e,&H96,&H02,&He3,&Hd4,&Ha8,&H30,&H58,&H6c
   DATA &H31,&Hf8,&H7e,&H7c,&H6c,&H91,&Hb6,&H5c,&H46,&H32,&H19,&H9d,&H9d,&He2,&Hcb,&H0b
   DATA &H41,&Hd1,&Hbe,&H8a,&H9c,&Hb9,&H1c,&H52,&H4b,&Hdb,&H34,&H60,&Hc0,&Ha4,&Hed,&Hfa
   DATA &H22,&Hd9,&H38,&Hd8,&H9e,&Hc9,&H0c,&Hd1,&Hde,&H21,&Hc4,&H35,&Hc4,&H0b,&Hb6,&H78
   DATA &H74,&H1f,&Ha2,&H95,&H90,&H6e,&Hf1,&H53,&H98,&Hf2,&H88,&H5e,&He2,&He0,&Hc0,&Hda
   DATA &Hcb,&He5,&Hc1,&H52,&Hd8,&H50,&H09,&H18,&H67,&H0c,&H39,&Hd8,&He7,&H34,&H9d,&H6b
   DATA &H2d,&H37,&Hf3,&H3f,&H8a,&Hd7,&Hcb,&Hdc,&Haa,&Hc3,&H8d,&H36,&He6,&Hdf,&H26,&H8f
   DATA &H91,&H91,&He9,&H58,&Hd2,&He0,&H8a,&H8a,&H50,&H1f,&Hd1,&H49,&H95,&H19,&H56,&Hbb
   DATA &H46,&H05,&H16,&H86,&H80,&H53,&H83,&H4a,&H51,&H6d,&He6,&H8c,&Hc5,&H2b,&H63,&Haa
   DATA &H5e,&Hc4,&H73,&H0d,&Hf1,&H42,&H71,&H72,&H11,&He7,&Hb1,&H5a,&He7,&Hd1,&H16,&Hd0
   DATA &H66,&H0f,&H13,&H8a,&H8f,&H67,&Hcf,&H8c,&H18,&H68,&Hc9,&H0e,&H92,&H4a,&H27,&H5e
   DATA &H43,&Ha0,&Heb,&H65,&H3f,&He2,&Ha9,&Hf6,&H76,&Hc9,&Hd9,&H98,&H7d,&H9f,&H83,&H60
   DATA &Hde,&H7d,&H54,&Hdd,&H46,&H42,&H08,&H24,&H9e,&H76,&Hb0,&H36,&Hb3,&H25,&H87,&H6a
   DATA &Hce,&H1f,&H54,&Hf7,&H6f,&H1a,&H4d,&H83,&H47,&Hbf,&Hd9,&H49,&Hb2,&Hf0,&H51,&H62
   DATA &Hb1,&Hd1,&H99,&Hd8,&H0e,&H56,&H97,&H50,&He0,&Hea,&He4,&H47,&He8,&Hb0,&H3b,&H94
   DATA &H8e,&Ha4,&H52,&H8c,&H6d,&H1b,&Hbf,&H0d,&Hc6,&Hc6,&Hec,&Hcc,&H47,&Hf4,&Hc0,&H94
   DATA &H87,&H65,&H66,&H6b,&H15,&Hd6,&Hf9,&He8,&Hae,&He4,&H67,&H43,&He8,&Ha9,&Hb9,&Hcf
   DATA &Hc2,&H63,&H43,&He8,&H98,&H66,&H75,&H13,&H5f,&H43,&H8f,&He4,&H7f,&H55,&H6c,&H7f
   DATA &H8d,&Ha3,&H8a,&Hd3,&H71,&H60,&Hcc,&He2,&He2,&Ha4,&H85,&H0d,&H67,&H4f,&H64,&H6e
   DATA &Hdb,&Hd1,&H1a,&Ha5,&Hb7,&Hab,&Hf9,&H33,&Hf1,&Hd0,&Hd3,&H1b,&H3e,&Hc0,&H52,&H65
   DATA &H8f,&Hfe,&Hdf,&He2,&H9d,&Hdb,&H49,&Hdb,&Hea,&Ha5,&Hff,&H00,&H64,&He3,&Ha1,&H37
   DATA &H61,&Hda,&Hb5,&H84,&H79,&H14,&H20,&He6,&H1f,&H53,&Hfd,&Hd0,&Ha7,&H20,&H54,&H67
   DATA &Hfc,&H4b,&H82,&H32,&Hec,&Hfd,&Hf8,&H07,&H36,&H1c,&He6,&Hbe,&H79,&H79,&Hfe,&Hbe
   DATA &H4b,&H17,&H64,&Hcf,&Hbb,&Hc5,&H40,&H49,&He0,&Hf0,&H0f,&H78,&H3a,&H7e,&H6b,&Hb5
   DATA &H94,&Hc5,&Hb9,&H93,&H7d,&H46,&H3c,&Ha7,&H3d,&Hf0,&Hcb,&Hcd,&H70,&H4c,&H6b,&H18
   DATA &Hd7,&Hee,&Hef,&H25,&H9c,&Hb7,&Ha1,&Haf,&H05,&H8e,&H39,&H1c,&Hb9,&H37,&Hbc,&H6a
   DATA &H2a,&Hac,&Hec,&Hb1,&Hd8,&H1f,&H9b,&Hc2,&Hbe,&H3d,&H43,&Hc1,&H0e,&H63,&Hbe,&Hd7
   DATA &H0e,&H09,&H20,&H91,&Hed,&Hc9,&H0c,&Hf1,&H16,&Hcb,&H55,&H63,&H56,&Hb8,&Hf1,&Hd0
   DATA &Hab,&H4c,&H79,&H2c,&H04,&Hf1,&H2d,&H17,&He2,&H9d,&H98,&Hb7,&H51,&Hc8,&H84,&H8f
   DATA &H33,&Hbb,&Ha1,&Hd6,&H05,&Ha5,&Hab,&H22,&Ha1,&Hd1,&H2d,&H7f,&H82,&H90,&Hbc,&H71
   DATA &He1,&Hdf,&Hc9,&H00,&Hdf,&Hee,&H93,&H2c,&Hef,&Ha1,&H3c,&H65,&Hd9,&H1e,&H9d,&H12
   DATA &H02,&H3a,&H05,&H29,&H23,&H4b,&H28,&Hd3,&H2f,&H2f,&H44,&Hcb,&H3a,&Hfb,&H42,&Hbf
   DATA &H8e,&Hfe,&H99,&H19,&Hcb,&Hd0,&H7a,&Ha1,&H3c,&H96,&H1e,&H4e,&H1e,&H1c,&H10,&Ha7
   DATA &H90,&H4f,&H19,&H94,&H36,&Hd6,&H20,&H43,&Hb2,&H71,&H04,&H3f,&Hea,&H68,&H68,&Hf1
   DATA &H26,&Hbf,&H05,&Hca,&Hc7,&H1e,&H77,&H31,&H9d,&H5c,&H1b,&H5d,&He5,&H6a,&Hed,&Hc9
   DATA &H8e,&H26,&H28,&He3,&H81,&H8e,&H91,&H81,&He5,&Hce,&H2d,&H16,&H1b,&Hc8,&H70,&Hf3
   DATA &H54,&Hf0,&H4c,&H79,&Hc6,&He1,&Hb3,&Hb0,&H81,&H9d,&Ha4,&Hdb,&H48,&Hd0,&H6b,&Hf9
   DATA &H2a,&Ha1,&Hc4,&H6d,&H96,&Hcd,&Ha6,&Hd5,&H1d,&H6b,&Hac,&H3b,&H87,&H3d,&H35,&H25
   DATA &H21,&Hde,&H70,&Ha0,&H3c,&Hca,&Ha9,&Hf3,&Hcf,&H6d,&He4,&Hf2,&Hb1,&Hc5,&H3e,&H3c
   DATA &H71,&H73,&H3b,&H74,&H1f,&H7f,&H69,&H22,&Hbc,&H95,&H0d,&Hf2,&H59,&Ha9,&H5f,&Hb2
   DATA &H62,&H24,&He6,&H05,&H77,&Hf3,&H4f,&H0f,&Hcd,&Hd8,&H34,&H1d,&H5a,&H1c,&Hca,&Ha8
   DATA &Hc6,&H76,&Hfb,&H4f,&H24,&H1e,&Hee,&H0a,&H59,&Hb1,&H71,&H16,&H76,&H1e,&H2f,&Hfe
   DATA &H25,&H4d,&H48,&H2e,&H4b,&Hb1,&Hee,&H2f,&H6e,&H86,&H87,&H9f,&He6,&H93,&H31,&Hee
   DATA &H3a,&H70,&Hb5,&H5e,&H3c,&H56,&H56,&H8c,&Hf7,&Hcb,&Hae,&H81,&H49,&Hf3,&H91,&H0e
   DATA &Hdc,&H92,&Hb6,&H36,&Hb5,&Ha5,&Hc5,&Hc4,&H80,&H3f,&H7d,&Hc8,&Ha7,&H7e,&H80,&Ha4
   DATA &H9f,&Hd9,&H20,&H93,&H28,&H01,&Hc6,&Hcf,&H8a,&H14,&H43,&H68,&Hc1,&H23,&H5a,&Hf8
   DATA &Ha5,&H6c,&H8c,&H23,&H47,&H7e,&Hc2,&H14,&Hb6,&H1d,&H48,&Hce,&Hc1,&He2,&H7f,&H87
   DATA &He7,&H18,&H27,&H88,&H43,&Hcd,&Hb8,&H33,&H40,&H7b,&Hf8,&H2b,&H9f,&Hc7,&Hb1,&Hb4
   DATA &H07,&Hcc,&H83,&H5c,&Hcb,&H01,&Hfc,&H96,&H51,&H1a,&Ha0,&H85,&Hd5,&Hf0,&He1,&Hdb
   DATA &H38,&H5e,&H64,&Hfa,&H2d,&H4d,&H8a,&H38,&H89,&H4c,&H93,&H48,&H1e,&Hf3,&Hc4,&H90
   DATA &H99,&Hbd,&H67,&H51,&Hee,&Ha0,&H22,&H90,&H38,&H21,&He0,&He3,&Hed,&H83,&Hcd,&Hc9
   DATA &Hd1,&H3e,&Hf6,&H3f,&Hbf,&Hd9,&H1b,&Hd8,&Hfe,&Hef,&H65,&H10,&H22,&Hf5,&H01,&H38
   DATA &H06,&Hb8,&Hea,&H02,&H0f,&He0,&He3,&Hed,&H85,&H7c,&Hc9,&Hf4,&H87,&Hef,&H23,&Hea
   DATA &H3d,&H13,&H25,&H8f,&H0f,&H3d,&H09,&H63,&H8e,&H40,&H38,&H66,&H04,&Hd2,&H70,&H85
   DATA &Ha7,&H97,&Hba,&H77,&Hcb,&H83,&Hc2,&Hc2,&H1e,&H1e,&H35,&Hf6,&Hc7,&Hf2,&H72,&H74
   DATA &H86,&H65,&H8a,&H80,&H01,&Ha0,&H34,&H50,&H19,&H38,&H04,&H29,&H3e,&H5d,&Hdd,&He8
   DATA &H47,&Hc3,&Hc7,&Hdb,&H27,&H93,&H93,&Ha1,&Ha1,&Hc3,&Hed,&Hb4,&Ha1,&Hcd,&Hab,&H2d
   DATA &H15,&Hcd,&H1b,&Hb0,&H35,&H79,&Hec,&H8e,&H2a,&Ha3,&H30,&H87,&H1b,&Hf0,&Hbe,&H2b
   DATA &H68,&Hc9,&H2b,&Hf3,&H89,&H83,&H18,&H01,&Ha0,&H1b,&Ha0,&H22,&H87,&Hfc,&Hbd,&H96
   DATA &H8c,&H99,&H34,&H14,&He1,&Hc2,&Hf2,&H32,&H67,&H61,&Hf1,&Hb3,&H67,&H96,&H20,&H59
   DATA &H1b,&H2f,&H2b,&H74,&H05,&Hc0,&H5f,&H6b,&H51,&H5c,&Hb8,&H25,&Hc3,&Hc8,&Hd9,&H70
   DATA &Hec,&H7b,&Hdb,&Ha9,&H1a,&Hd0,&H49,&H81,&Hdb,&H12,&H62,&H71,&H31,&H42,&H23,&H2d
   DATA &H70,&H86,&H9d,&Ha0,&H20,&H91,&Ha9,&H3d,&Hc9,&Hcc,&H85,&Hb1,&H87,&H64,&H05,&Ha1
   DATA &Hc6,&He9,&H51,&H81,&Hce,&H52,&H76,&H6b,&Hf9,&H51,&Hc7,&H08,&Ha5,&H15,&Hc8,&Hfc
   DATA &Hb1,&Hfd,&Ha8,&Hdd,&H47,&Hc7,&H82,&H41,&H1d,&Hf3,&H29,&Hed,&H66,&Hbc,&H4a,&Hd6
   DATA &Hce,&H7a,&Ha6,&H34,&H46,&Hde,&H44,&Ha9,&H1a,&Hc6,&Hf5,&H4e,&H11,&Hf7,&Ha7,&H06
   DATA &H01,&Hc5,&H23,&H2d,&H8a,&Ha1,&H43,&H19,&H5c,&H90,&H96,&H9a,&H84,&H46,&H6c,&Had
   DATA &H89,&Ha7,&H31,&Hd0,&Hef,&H04,&H6e,&H7b,&H7e,&Ha2,&H2c,&H36,&Hf9,&H95,&H0c,&Hf3
   DATA &Hce,&Hcf,&H86,&Hc6,&H0f,&H0c,&Hf3,&H2d,&Hcb,&H9a,&H72,&H68,&Hbb,&H4e,&H40,&H74
   DATA &Hb0,&H13,&H36,&Hce,&H2b,&H02,&H71,&H52,&H44,&Hfc,&H13,&Ha6,&H92,&H26,&H0c,&Hb2
   DATA &H36,&H4c,&Ha5,&Ha7,&H8d,&H55,&H6a,&H3c,&H4a,&Hc2,&H87,&H68,&He3,&H1e,&He2,&H58
   DATA &H59,&H98,&H9b,&Hca,&H22,&H6e,&Ha7,&Hd1,&H73,&Hf2,&Hca,&H52,&H67,&H47,&H0c,&H63
   DATA &H08,&H9b,&Hdf,&H0e,&H3e,&H47,&H60,&Hb1,&H71,&Hb9,&Hbd,&H99,&H58,&He8,&H43,&Hb9
   DATA &Hb0,&H11,&Ha8,&H1e,&H67,&Hd9,&H5f,&H31,&H11,&Hfd,&Ha5,&H59,&Hc2,&Hbf,&H11,&Hf2
   DATA &He1,&H98,&Had,&Hdb,&H9d,&H79,&Hbb,&H3a,&H51,&Ha1,&Hfb,&He6,&Ha6,&Hb1,&Hd0,&H2b
   DATA &Hb0,&Hea,&H8d,&Hd9,&H57,&Hc8,&Hd3,&H3a,&Ha3,&H3f,&H74,&H7a,&H14,&H6e,&Hcf,&H42
   DATA &Hb4,&H41,&Hee,&H08,&Hf0,&Ha5,&H76,&Hb3,&H36,&Hd2,&H33,&H8b,&H5c,&H12,&H80,&Hee
   DATA &H4a,&Hf9,&H2e,&Had,&H29,&H20,&H74,&H9d,&H01,&Hf1,&H53,&H59,&H36,&Hd7,&H65,&H1a
   DATA &H7a,&H15,&Hfc,&Hcf,&Hfb,&H5a,&H85,&H35,&H87,&H41,&Hc8,&H6d,&H66,&Hba,&H0d,&Hb5
   DATA &H35,&H3c,&Hb4,&H3c,&H07,&H01,&H43,&H9d,&H5f,&Hbd,&Haa,&Hf8,&H39,&H06,&H13,&H6b
   DATA &H44,&H23,&H19,&H8b,&H65,&H1e,&H40,&Hf1,&Hfc,&H4a,&Hd7,&Hf8,&Ha6,&H07,&H33,&H15
   DATA &H85,&H9c,&H01,&H72,&H34,&Hb0,&H9e,&Hf1,&Haf,&He6,&Hb2,&H0c,&H4d,&H6c,&Hc2,&H56
   DATA &H8e,&H2d,&Hf5,&Hff,&H00,&Hf5,&H63,&H6f,&H9b,&H46,&He4,&H9e,&H9a,&H3b,&H52,&H2b
   DATA &H4a,&He0,&H8a,&H3d,&H14,&Hcd,&H16,&Hc0,&Hed,&H0d,&H80,&H51,&H5d,&H00,&H56,&Hee
   DATA &Hc4,&Ha7,&H66,&H5d,&H10,&Hd1,&H45,&H15,&H28,&H3d,&Hc9,&Hc0,&H9e,&H4d,&H47,&H71
   DATA &H31,&H76,&Hd9,&H06,&H52,&H7a,&Ha4,&Hdd,&H93,&Hd5,&H4f,&H6e,&He6,&H3d,&H91,&H67
   DATA &Hf6,&H14,&Hd4,&H89,&Ha0,&H87,&H76,&H7b,&Hd0,&Ha7,&Hb2,&H85,&H37,&H11,&H36,&Hdf
   DATA &H46,&H17,&Hc5,&H05,&Hae,&H76,&H0d,&Ha3,&H8d,&Hb8,&H8f,&H65,&H89,&H2d,&Hd5,&H0e
   DATA &H85,&H6d,&H7c,&H4c,&He6,&H97,&H60,&H88,&Hd0,&Hdb,&Hc6,&Ha2,&Hba,&H2c,&Hcc,&H24
   DATA &H3f,&H33,&H8e,&Hc3,&Hc4,&H4e,&H8e,&H78,&Hbe,&H7a,&H0d,&H4a,&Hc9,&H17,&Hfc,&H0d
   DATA &Hd2,&Hfc,&H8e,&Hba,&H3f,&He5,&Hc6,&Hc0,&H78,&H86,&H81,&Haf,&H82,&H79,&Hd0,&H83
   DATA &Hec,&H9c,&H23,&H27,&H52,&Hf1,&Hae,&Hbc,&H13,&H37,&H4f,&H24,&Hdb,&He9,&H51,&Hf6
   DATA &H68,&H42,&H97,&H8d,&H79,&H22,&Hc7,&H13,&Hee,&H9a,&H22,&H75,&Hfd,&H77,&He4,&H0a
   DATA &H1c,&Hd7,&H01,&H4e,&H35,&He4,&H85,&H93,&H81,&Hd7,&Had,&H01,&He8,&H82,&Hea,&H3a
   DATA &H6a,&H79,&Hdf,&H35,&H18,&H69,&H76,&Had,&H39,&H87,&H70,&H4a,&H23,&H73,&Haa,&Hbf
   DATA &H04,&Hd6,&Hc0,&Hd7,&Hf4,&H29,&H78,&Hbe,&H14,&H84,&H85,&H8f,&H69,&Haa,&Hbf,&Hdf
   DATA &H8a,&H10,&Hd4,&H4a,&H39,&Hfc,&H64,&H18,&H9d,&Hb3,&H3c,&H43,&H07,&H0e,&H7d,&Hd1
   DATA &H25,&Hc4,&H90,&Hca,&Hbe,&H1c,&H4f,&H72,&Hd1,&Hd9,&Hbf,&H0e,&H6d,&H1c,&H26,&H31
   DATA &Hb3,&H39,&Hb0,&H38,&H06,&H38,&Hff,&H00,&H52,&He8,&H91,&H55,&He2,&Ha8,&Hba,&H6b
   DATA &H37,&H94,&Hfa,&Ha3,&H7a,&H3e,&Hdf,&H75,&Haa,&H3f,&H1f,&H2d,&H56,&H93,&H9b,&He5
   DATA &He3,&Hbb,&Hb2,&Hfc,&Hd2,&H4f,&H13,&H9d,&H1b,&Hdf,&H95,&Hdd,&H43,&Hec,&H7b,&H25
   DATA &H18,&Hb7,&He4,&H00,&H97,&H38,&H8e,&H79,&H8e,&Hbe,&H2b,&H3f,&H7d,&Hfe,&H27,&Hff
   DATA &H00,&Ha4,&H6f,&Hff,&H00,&Hc4,&Hfa,&Haa,&Hdf,&Hc4,&Hcd,&Hd0,&Hde,&H64,&H3b,&H34
   DATA &H23,&Hc5,&H98,&Hcf,&Hd0,&H2b,&Hc5,&H13,&He2,&Hcc,&Hce,&Hb0,&H0b,&H75,&Hea,&Ha8
   DATA &H6f,&Hc7,&Hd9,&Hee,&H81,&H3f,&Hfe,&H3f,&H74,&H3c,&H4c,&Hdd,&H13,&Hcd,&H87,&H65
   DATA &Hd1,&H8a,&H78,&H20,&Hb4,&H06,&Hd5,&H56,&Ha5,&H4c,&Hdc,&H70,&H6c,&H7f,&Hd3,&H2e
   DATA &H71,&H26,&Hc5,&Hf8,&H57,&H25,&H99,&Hbe,&H23,&Hfe,&H99,&Hf2,&H29,&H1c,&Hf6,&H3f
   DATA &Heb,&H65,&Hf8,&H95,&H3c,&H5c,&Hdd,&H13,&Hcc,&H87,&H66,&H81,&Hc4,&H67,&H36,&He8
   DATA &H1a,&H4f,&Hef,&Hb9,&H0b,&H20,&He1,&Hb0,&H8e,&Hd4,&Hc4,&Heb,&Hff,&H00,&Hd8,&Hef
   DATA &Hd5,&H08,&Hf8,&Hb9,&H7a,&H0f,&H99,&H0e,&Hc9,&H9d,&H1b,&H9a,&H48,&H73,&H48,&H21
   DATA &H19,&H4f,&H45,&H30,&H98,&Hd9,&H6b,&Hfb,&H4c,&Hb3,&H5d,&H47,&H82,&H42,&He7,&H01
   DATA &H77,&Ha2,&Hec,&Ha6,&H71,&H9c,&H53,&Hf4,&H45,&H90,&Hf4,&H48,&H58,&H47,&H2f,&H5d
   DATA &H13,&Hce,&H21,&Had,&H6b,&H9e,&He7,&H00,&Hc6,&H3b,&H2b,&H9d,&H46,&H81,&He9,&H7c
   DATA &H2d,&H3a,&H2c,&H00,&Hda,&H05,&H92,&H4b,&H27,&Hf2,&H9c,&Hd1,&Hb9,&H14,&H3b,&Had
   DATA &Hc4,&H11,&H45,&H55,&H93,&H3c,&H60,&Hac,&Hd1,&H87,&He2,&Hcb,&H23,&Ha2,&H2c,&Ha7
   DATA &H4d,&H12,&H6a,&H39,&H14,&H61,&H89,&H82,&H49,&Hb0,&H92,&H7d,&H51,&Hbc,&Hd0,&H23
   DATA &Hfb,&H7b,&H95,&H9d,&He5,&Hfd,&Ha9,&He1,&H3d,&H4a,&Hca,&Hb2,&H62,&Hdb,&H96,&H96
   DATA &Hc8,&H5a,&Hf6,&Hf3,&Hb4,&Hf6,&Hbd,&H87,&H89,&H3e,&H89,&He4,&Hb4,&Hf2,&H08,&Hd0
   DATA &Hf2,&H08,&Hb6,&H05,&H11,&H2e,&H3e,&H64,&H7a,&H21,&H3f,&Hb1,&Hd0,&Ha1,&H01,&Ha9
   DATA &H09,&H90,&H6a,&H6b,&H52,&H99,&H2c,&H9f,&H2d,&H13,&Ha5,&H02,&He8,&H70,&Hab,&Hbf
   DATA &H10,&Had,&Hee,&H9d,&Hd1,&H45,&H89,&H61,&H8e,&H07,&H97,&H0e,&H3a,&H0e,&Hfb,&Hd1
   DATA &H2c,&Ha5,&Hfc,&H47,&H84,&H2a,&H56,&H01,&Had,&H9f,&He1,&He7,&H6c,&H88,&H21,&H6b
   DATA &Hb1,&H2e,&H70,&H98,&H03,&H2b,&H6c,&Hdb,&Haf,&H5b,&Ha2,&H08,&H07,&H5f,&H05,&H43
   DATA &H01,&H86,&Hda,&H99,&Ha0,&H86,&H67,&H18,&H30,&Hd0,&Hbc,&H92,&H5c,&Hdd,&H40,&Hd6
   DATA &Hc0,&H03,&H53,&Hce,&H87,&H7a,&Hc4,&H6e,&H3a,&H6c,&H2e,&H2b,&H7f,&H0c,&Haf,&H61
   DATA &H61,&Ha6,&Hbc,&H1b,&H27,&Hc5,&H6c,&H6c,&H07,&He2,&Hb1,&Hec,&H9e,&H69,&Hb1,&H12
   DATA &Hbd,&Ha1,&Hed,&H0d,&H25,&Hdc,&Heb,&Hfd,&H2e,&H6e,&H99,&H36,&H76,&H35,&H46,&H31
   DATA &Hb2,&Hdc,&H6f,&H18,&H88,&Hc4,&Ha0,&H3b,&Hb7,&Hf7,&H68,&H78,&Ha7,&H6e,&Hc7,&H45
   DATA &H71,&Hb8,&H47,&H35,&H81,&H8d,&H00,&H00,&H29,&H1f,&H2c,&Hfe,&H8b,&Ha3,&H16,&H92
   DATA &H39,&H33,&H83,&H72,&Hb2,&Hb3,&H5a,&Hd0,&H9e,&H32,&H7e,&Hc2,&H97,&He5,&H9f,&Hd1
   DATA &H1f,&H2c,&Hf1,&Hfd,&Ha8,&Hb9,&H21,&H54,&H5a,&Hfa,&H23,&Hec,&Ha1,&H49,&Hf2,&H72
   DATA &H9e,&H54,&H85,&H35,&H21,&Ha9,&Hf4,&H5a,&Hde,&H0e,&H83,&Hd1,&H73,&H3f,&H12,&Hed
   DATA &H29,&H99,&H8d,&H8e,&H18,&H46,&H50,&Hc6,&Hdb,&H88,&H6e,&Hba,&Hae,&H9b,&H2f,&H82
   DATA &He6,&H7e,&H22,&H87,&H26,&Hd5,&H8a,&H5c,&Hb6,&H1f,&H17,&Ha9,&H07,&Hfd,&H2c,&Hf3
   DATA &Hf5,&Hc1,&Hab,&H1f,&H32,&He4,&Hc3,&H66,&H1f,&He6,&H4b,&H1a,&Hc2,&He1,&H6e,&Hca
   DATA &H03,&H86,&H9e,&Hab,&Hb7,&Hd9,&H78,&H53,&Hb3,&Hf0,&H11,&H61,&Hff,&H00,&Hb8,&H0b
   DATA &H71,&H1f,&H71,&He3,&Hfb,&Hee,&H5c,&Hb4,&H8f,&Hac,&H43,&H43,&H7b,&H36,&Hd3,&H44
   DATA &H7e,&H0b,&Hae,&Hc1,&Hb9,&Hd3,&He0,&He2,&H92,&Hc9,&Hb6,&H82,&H74,&He7,&Hcf,&Hdd
   DATA &H57,&H8f,&Hdf,&H25,&H99,&H6f,&Hd1,&H36,&H62,&H96,&Hd1,&H90,&Hf7,&Ha0,&H30,&Hab
   DATA &H9d,&H14,&Hab,&H14,&Hbb,&Ha9,&H4d,&Hd0,&Hf3,&H4e,&H31,&Hf5,&Hb4,&H6e,&H9d,&Hd1
   DATA &H02,&H72,&H46,&H7f,&He6,&H85,&H20,&H86,&Hc2,&H11,&Hb2,&H72,&H4b,&H5a,&H5e,&Hab
   DATA &H0b,&He2,&H98,&Hc6,&Hef,&H09,&H28,&H3d,&Ha1,&H23,&H9b,&H55,&Hc8,&H8b,&Hfc,&H82
   DATA &Hde,&H2f,&H24,&H74,&Hf2,&H58,&H7f,&H13,&H38,&H96,&He0,&Hdb,&Ha7,&Hf5,&H1d,&Hf8
   DATA &H05,&H81,&H64,&H6d,&H9d,&H29,&H62,&H8c,&H55,&Hd1,&H80,&Hfc,&Haf,&H78,&He6,&H40
   DATA &H24,&H7b,&H2e,&Haf,&H62,&H10,&Hed,&H95,&H10,&Hb3,&Ha1,&H70,&Haf,&H32,&Hb9,&H49
   DATA &H1a,&H6e,&H31,&H64,&H34,&H59,&H1e,&H75,&Hfa,&H05,&Hd5,&H6c,&H66,&Hba,&H3d,&H95
   DATA &H07,&H57,&H02,&Hff,&H00,&H53,&Hfa,&H26,&H94,&H9c,&H7d,&H09,&H18,&H46,&H5e,&Hcb
   DATA &He0,&H6b,&H56,&H51,&H47,&H9d,&H0f,&H14,&H38,&Hd6,&Ha3,&Hc5,&H26,&Hf3,&H5a,&H34
   DATA &H7c,&H52,&H2c,&Hd2,&H2d,&Hd8,&H83,&H16,&H8f,&H32,&H42,&H4a,&H3d,&H47,&Hba,&H51
   DATA &Hf4,&H80,&H75,&Hb4,&H85,&Hd6,&H45,&H9a,&H47,&H7a,&H42,&H3c,&H11,&H0a,&H3d,&He8
   DATA &H4e,&Hcc,&H39,&H65,&Ha4,&H29,&Hbd,&H22,&H6c,&H44,&H1f,&H79,&H4b,&H83,&H9b,&H55
   DATA &Hdf,&H6b,&H0f,&He2,&H47,&H13,&H87,&Hc2,&Hdd,&H12,&H26,&Hab,&H03,&Hab,&H4f,&He8
   DATA &H91,&Hf8,&H9c,&H73,&H8b,&H4b,&H71,&H11,&H4a,&Hda,&Hd0,&H18,&Hf2,&Hff,&H00,&Hb4
   DATA &Hc9,&H60,&H7e,&Hd0,&H73,&H1b,&H8a,&H9c,&H40,&Hd6,&H3b,&H3e,&H60,&Hd3,&H25,&H9e
   DATA &H15,&Ha5,&H75,&H2a,&H98,&Hf0,&Hc3,&H2c,&H89,&Haa,&H32,&H0c,&H66,&H57,&Hb6,&H38
   DATA &Hc1,&H2e,&H73,&H83,&H40,&Hf1,&H5d,&Ha4,&H63,&H0f,&H0c,&H6d,&H65,&H80,&H18,&Hd0
   DATA &Hda,&H26,&Hb4,&H1c,&H3f,&H05,&H9d,&H16,&Hca,&Hd8,&Hd1,&H4b,&H04,&Had,&Hc7,&He2
   DATA &H1a,&He8,&Hdd,&H98,&Hff,&H00,&H2e,&Haf,&Hc2,&H86,&H9a,&Hf8,&Ha4,&Hc4,&H18,&H84
   DATA &H8f,&H10,&Hca,&He9,&H18,&H79,&H96,&He5,&Hb4,&Hd9,&H25,&H7e,&H84,&H8c,&H94,&H4d
   DATA &H30,&H22,&H34,&H73,&H37,&H5e,&H02,&Hc6,&Ha9,&H03,&H22,&H73,&H8d,&H59,&Had,&H16
   DATA &H5b,&H66,&H7b,&H18,&H18,&Hd7,&H10,&Hd1,&Hcb,&H44,&Had,&H9a,&H46,&Hbb,&H30,&H24
   DATA &H1a,&Hae,&H4a,&Had,&H45,&H9b,&Ha8,&Hd4,&H91,&Hac,&H88,&H5b,&H8b,&H75,&He1,&Ha9
   DATA &H51,&Hb5,&Hcc,&H79,&H35,&H40,&H9b,&Hab,&H0b,&H3e,&H4c,&H4c,&Hb3,&H0a,&H91,&Hd9
   DATA &Hbc,&H82,&H6e,&Hf6,&H43,&Ha6,&H73,&H5e,&H3c,&H14,&Hd4,&H4d,&Hc4,&H69,&Hb9,&H8d
   DATA &H04,&H82,&H38,&H77,&H14,&H2a,&H31,&He2,&Hde,&Hc1,&H44,&H07,&H78,&H9f,&Hd1,&H0a
   DATA &H6a,&H26,&He2,&H28,&H6f,&H64,&H16,&H03,&Hbd,&H92,&Hb4,&Hcb,&H2c,&H8d,&H6b,&H69
   DATA &Hcf,&H71,&Ha0,&H32,&H8b,&H27,&Hd1,&H39,&Hd1,&Hf6,&Hcf,&H2b,&H4f,&Hdc,&H49,&H14
   DATA &H6c,&Hc4,&H35,&He1,&Hb2,&H07,&H8d,&Hd8,&H23,&Hea,&Hae,&H37,&Hdd,&H4b,&Hb9,&H38
   DATA &He2,&H8a,&Hfc,&H51,&Hc3,&Hc7,&Hb9,&H39,&H56,&Ha7,&H44,&H05,&Hf2,&H34,&H96,&H9d
   DATA &H08,&H34,&H41,&H03,&H42,&H8c,&Hef,&Heb,&Hec,&Haf,&H62,&He1,&H76,&H22,&Hb1,&H51
   DATA &Hb4,&H65,&H70,&Hed,&H0f,&Hb5,&Hdc,&Hc1,&H55,&H77,&H0f,&He5,&H48,&H42,&H38,&Ha4
   DATA &Hb9,&H48,&H99,&H56,&H68,&H4a,&Had,&H91,&He7,&H7f,&H51,&He8,&H12,&H87,&H49,&Hf7
   DATA &H0f,&H44,&Hbb,&H97,&H9e,&H49,&H77,&H52,&H0e,&H01,&H58,&Hf1,&H62,&Hfd,&H57,&Hf8
   DATA &H55,&Hb9,&H97,&Hb6,&H26,&H69,&H79,&H1b,&Hf4,&H40,&H74,&Hb7,&Hf9,&Ha5,&H19,&Hc7
   DATA &H16,&H5a,&H7b,&H5c,&H7e,&Hc4,&Hbb,&H58,&Hff,&H00,&H55,&Hfe,&H0c,&Hb2,&H4d,&Hfd
   DATA &Hb0,&H0d,&H7d,&H71,&H1e,&H54,&H85,&H20,&Hb2,&H34,&H6d,&H21,&H2e,&Hd4,&H3f,&H54
   DATA &H5a,&Ha5,&H2e,&Hd9,&H1b,&H40,&H13,&H5b,&Hec,&H36,&Hf5,&Ha1,&H6b,&H52,&H6d,&H9f
   DATA &H2e,&H33,&H0c,&H31,&H38,&H79,&Ha3,&H94,&H06,&Hf6,&H63,&H67,&H4e,&H81,&H67,&H96
   DATA &Hd9,&Hba,&Hef,&H4d,&H7c,&Hbf,&H2a,&Hc3,&H39,&H7b,&H98,&Hd8,&Hbb,&H67,&H21,&Hab
   DATA &Ha3,&He9,&Hfe,&Hd4,&Hcb,&H06,&Hda,&H95,&Hfa,&H0e,&H19,&H25,&H70,&Hec,&H36,&H7e
   DATA &H36,&H26,&H63,&H9b,&H13,&Ha6,&Had,&He6,&H8f,&H63,&Hb9,&H5f,&H03,&H45,&H2f,&Hc9
   DATA &H37,&H68,&H19,&He4,&Hc3,&H4f,&Hab,&H1c,&Hed,&Hd8,&H61,&Hec,&Hd0,&Hd0,&H58,&He3
   DATA &Ha9,&H04,&Hdf,&H45,&Hcd,&H4b,&H8e,&H74,&H9b,&H4c,&He3,&He4,&H6b,&H1d,&H36,&Hf4
   DATA &H4a,&H43,&Hc5,&H8b,&H1c,&H07,&H86,&H9f,&Hba,&H5d,&H8e,&Hd0,&Hd8,&Hb2,&H66,&Hfe
   DATA &H27,&H81,&Hc9,&H87,&H94,&H7f,&H5e,&H22,&H48,&H63,&Hc7,&H3a,&Haf,&Hd9,&Hd0,&Hf1
   DATA &H58,&Ha5,&H26,&Hdf,&H07,&H46,&H2a,&H31,&H8d,&H35,&H66,&H46,&H16,&H77,&H3a,&H20
   DATA &H1e,&He2,&He9,&H18,&H4b,&H5c,&H0f,&H1b,&H1d,&Hea,&H7c,&He5,&H4f,&H24,&H6d,&Hed
   DATA &H3e,&H31,&H4d,&H27,&H5d,&H35,&H07,&Hf7,&Hcf,&Hf3,&H4d,&H1e,&Hab,&Ha1,&H0f,&Hc7
   DATA &H93,&H91,&H97,&Hf2,&H6d,&H0d,&H0e,&H71,&He4,&H94,&H66,&He4,&H13,&H81,&Hae,&H49
   DATA &H43,&Hc7,&H4a,&H4c,&H14,&H00,&Hbb,&Ha2,&H13,&Hb3,&H0e,&Ha8,&H4b,&H65,&H88,&Hb1
   DATA &Hf2,&Hce,&H3c,&H35,&H1c,&H8a,&Hc7,&Hf8,&H96,&H46,&Hc1,&H85,&H66,&H1d,&Ha6,&He4
   DATA &H91,&Hc4,&Hbc,&H0e,&H40,&H70,&H1e,&H64,&Hfb,&H2d,&Hb2,&Hff,&H00,&H4f,&H15,&Hcc
   DATA &H49,&H8e,&H18,&Hfd,&He3,&H31,&H23,&H78,&Hc7,&H3e,&Hdb,&H43,&Hb4,&Hc0,&H79,&H03
   DATA &Hcf,&H4e,&H47,&Hf1,&H59,&Hf2,&H49,&Hd1,&Ha7,&H14,&H15,&Hd9,&H8b,&H2d,&H16,&H69
   DATA &Hcc,&H70,&H5e,&H8d,&Hf3,&H12,&He2,&Hb0,&H51,&H45,&H2b,&H4c,&H42,&H30,&H1a,&H41
   DATA &H3a,&Hb8,&H8d,&H2e,&Hb9,&H6b,&H74,&Hb8,&Hdd,&H97,&H80,&H8e,&H7c,&H64,&H44,&He2
   DATA &H1b,&H94,&H3b,&H30,&H63,&H81,&H0e,&H24,&H51,&H1d,&Hd5,&He6,&Hba,&Hf2,&H4d,&Heb
   DATA &Hc5,&H26,&H28,&Hdf,&H25,&H99,&H65,&H4a,&H86,&Hb2,&H0c,&H84,&H91,&He0,&H47,&H54
   DATA &Hd3,&H86,&H65,&Hd3,&H5e,&H3c,&H39,&Ha9,&H2d,&H54,&H9b,&H06,&He9,&H76,&H9c,&H18
   DATA &Hb1,&H3b,&Hd8,&Hd8,&H9b,&H94,&Hc6,&Hd1,&H59,&Hb8,&Hf3,&H57,&H36,&Hca,&H14,&H57
   DATA &Hd9,&H39,&Hc3,&H34,&H69,&H99,&H37,&He5,&H99,&Hf7,&Hd7,&H92,&H9f,&H36,&H9c,&H0a
   DATA &H69,&H23,&Hed,&Hb4,&H6d,&H8b,&Ha6,&H24,&H5f,&H2f,&H1f,&Hde,&H10,&Ha4,&Hbf,&Hf0
   DATA &H42,&H96,&Hc3,&H51,&H24,&Hdd,&Hea,&H6b,&H55,&Hc7,&H63,&H20,&Hfe,&H1f,&Hb5,&Ha5
   DATA &H83,&H50,&Hc2,&H73,&Hb2,&H8f,&Hf6,&H9f,&Hd3,&Hf2,&H5d,&Hb1,&H6e,&Hb7,&Ha1,&H0b
   DATA &H9d,&Hf8,&Ha2,&H38,&Hfe,&H6f,&H0e,&H45,&H89,&H0b,&H0d,&Hd7,&H4b,&Hd3,&Hde,&Hd6
   DATA &H49,&H65,&H52,&He0,&Hdb,&H1c,&H32,&H87,&H26,&H3b,&H6d,&H92,&H96,&H5d,&H0b,&Hb0
   DATA &H0f,&H02,&H17,&H65,&H87,&H70,&Hc4,&H61,&He3,&H99,&Ha2,&H83,&Hdb,&H75,&Hd3,&Hb9
   DATA &H72,&H0f,&H8d,&Hdd,&H89,&H2a,&Hc5,&H96,&H59,&He6,&H45,&H1a,&Hf4,&H3e,&Hc5,&H74
   DATA &H9b,&H02,&H40,&Hfc,&H1b,&Ha2,&H77,&H18,&Hdf,&Ha5,&H8e,&H47,&H5f,&Hd5,&H45,&H93
   DATA &H48,&H1e,&H2d,&H7e,&H8b,&Hfb,&Hba,&He2,&H8c,&H81,&H3e,&Haf,&H40,&H35,&H4a,&H5b
   DATA &H42,&Hca,&H3e,&H42,&H03,&Hf8,&Hd2,&H19,&H90,&H75,&H46,&H46,&Hf5,&H4e,&Ha1,&Hdd
   DATA &Hea,&H80,&H2f,&H82,&H3b,&Hf1,&H07,&H8f,&H3e,&H84,&H0c,&H6f,&H54,&H27,&H50,&H1c
   DATA &Hd0,&H8e,&Hf4,&H7b,&H06,&Hcc,&Hfa,&H10,&H59,&H00,&H83,&Hc5,&H73,&H7f,&H10,&H6b
   DATA &Hb6,&H03,&H7a,&H42,&Hd3,&Haf,&H8b,&H97,&H43,&H2b,&H98,&Hd7,&Hf1,&Ha2,&Hde,&H44
   DATA &Hf0,&H5c,&Hd6,&Hd9,&H91,&H8f,&Hda,&H4e,&H7b,&H48,&H35,&H1b,&H5a,&H75,&He0,&H75
   DATA &H3f,&H9a,&Hc5,&H0f,&H66,&Hd9,&Hbe,&H0a,&H18,&Hd9,&H9a,&Hfc,&H3c,&H18,&H42,&H2c
   DATA &H09,&H1d,&H2b,&Hbd,&H00,&H1f,&H81,&Hf5,&H5d,&H17,&Hc3,&Hd0,&H88,&H70,&H1b,&Hc7
   DATA &H1a,&H33,&H3b,&H30,&Hd3,&H90,&Hd0,&H2e,&H63,&H74,&He9,&Hb6,&H83,&H58,&H38,&Hb8
   DATA &H06,&H82,&H0a,&Hed,&H9b,&H8c,&H82,&H28,&He2,&H84,&H34,&H86,&H86,&H80,&H07,&H77
   DATA &H2b,&H4f,&H92,&H54,&H26,&H31,&He5,&He0,&H76,&H90,&Hd9,&H33,&H71,&H34,&H3b,&Hd3
   DATA &H9f,&H38,&H8c,&H1c,&Had,&H24,&H8e,&H64,&Hd0,&H3e,&H09,&Hd1,&H3d,&Hb3,&H0e,&Hbe
   DATA &H05,&H53,&H68,&Hba,&Hc6,&Hef,&H05,&Hf1,&H3e,&H00,&H26,&H87,&Hd1,&H3c,&H7b,&Hb4
   DATA &H4c,&H96,&H73,&Hbc,&Hc8,&Hde,&Hcf,&H20,&H4a,&H51,&H2c,&H6e,&H04,&H1b,&H06,&Hae
   DATA &Haf,&H8a,&H9a,&H81,&H63,&H8c,&H94,&H7e,&H9b,&Hf1,&H08,&H52,&H64,&H04,&H03,&H40
   DATA &H5f,&Hf9,&H14,&H23,&Ha8,&H3c,&H76,&H73,&Hee,&Hc3,&H76,&Hcb,&Hda,&Hf9,&Ha3,&H27
   DATA &H52,&H1a,&Hfb,&H1e,&H84,&H2b,&Hd8,&H0c,&H58,&Hc2,&H65,&Hbc,&H36,&H1e,&H67,&H81
   DATA &Hfd,&H57,&H42,&H33,&H9f,&H34,&H21,&H45,&H68,&Hc8,&H3d,&Hd8,&H9c,&H27,&Hcc,&Hbb
   DATA &H11,&H16,&Hcb,&H85,&Hb3,&H39,&Ha5,&Ha4,&H92,&H5c,&Hd1,&Hdf,&H96,&H80,&H0a,&Ha9
   DATA &H71,&H2e,&H24,&H37,&H28,&H3c,&H85,&He9,&Hdc,&H84,&H29,&H2e,&H7d,&H80,&H4e,&H1c
   DATA &Hab,&Hc9,&H1e,&H15,&He8,&H84,&H25,&Hd2,&H35,&H05,&H77,&H0f,&H20,&H96,&H8d,&H73
   DATA &H02,&Hfa,&H21,&H0a,&H69,&H25,&H0c,&H95,&Hf2,&Hbd,&Hf9,&H8b,&H03,&H89,&H03,&H57
   DATA &H3b,&H53,&Hec,&H84,&H21,&H32,&H8a,&H07,&H27,&Hff,&Hd9