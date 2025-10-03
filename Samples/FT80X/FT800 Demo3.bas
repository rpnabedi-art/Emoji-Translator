' Demo Set 3
' FT800 platform.
' Original code http://www.ftdichip.com/Support/SoftwareExamples/EVE/FT800_SampleApp_1.0.zip
' Requires Bascom 2.0.7.8 or greater

' These Demos require 'Bold12.bin' and 'Chinese.bin' onto an SD Card.

$Regfile = "M328pdef.dat"
$Crystal = 16000000
$Baud = 57600
$HwStack = 128
$SwStack = 128
$FrameSize = 192
$NOTYPECHECK

'Config ft800=spi , ftsave=0, ftdebug=0 , ftcs=portb.0 ', platform=gameduino2, lcd_rotate=1 ' Gameduino2
Config Ft800 = Spi , Ftsave = 0 , Ftdebug = 0 , Ftcs = Portd.4 , Ftpd = Portd.3  ' 4D AdamShield
'Config Ft800 = Spi , Ftcs = Portb.1 , Ftpd = Portd.4 ' VM801P

Config Base = 0
Config Submode = New
Config Spi = Hard, Interrupt = Off, Data_Order = Msb, Master = Yes, Polarity = Low, Phase = 0, Clockrate = 4, Noss = 1
SPSR = 1  ' Makes SPI run at 8Mhz instead of 4Mhz
Spiinit

SPI_SS Alias Portb.2
Config SPI_SS = Output
SPI_SS = 1

MMC_CS Alias PortD.5
Config MMC_CS = Output
MMC_CS = 1


Declare Sub Screen (ByVal Characters As String)
Declare Sub Set_font
Declare Sub Set_font2
Declare Sub ChineseFont
Declare Function AVRDOSInit() As Byte
Declare Function FileExist(Byval File As String * 12) As Byte

$Include "FT80x.inc"
$Include "FT80x_Functions.inc"
$include "Config_MMCSD_HC.bas"
$include "Config_AVR-DOS.BAS"

Const Chunk = 200
Const FontName1 = "Bold12.bin"
Const FontName2 = "Chinese.bin"

Dim Retn As Byte
Dim Dat As String * Chunk
Dim aDat(Chunk) As Byte At Dat Overlay

Retn = AVRDOSInit(): If Retn <> 0 Then End

Retn = FileExist (FontName1)
If Retn = False Then
   Print FontName1;" not found on SD Card"
   End
End If

if FT800_Init()=1 Then END    ' Initialise the FT800

   '<< Un-Rem each demo to view >>
'------------------------------
' Set 3  Demo's
'------------------------------
Screen "Set3 START"
Set_font
Set_font2
ChineseFont
Screen "Set3 END!"

Do
Loop

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
Sub Set_font
'------------------------------------------------------------------------------------------------------------
    ' API To demonstrate Custom Font Display

    '***********************************************************************
    ' This Code demonstrates the usage of Setfont. The Setfont Function draws
    ' Custom configured fonts on to the LCD screen.
    '***********************************************************************

   Const Bold12bin_Size = 19348  ' Bold12.bin file size

   Local FontAddr As Dword

    ' Copy the header from start of the file into RAM_G
   Load_File FontName1, RAM_G, 0, Ft_Font_Table_Size

    ' update the address of the font data - last 4 bytes of the index table contains the font data address
   Wr32 RAM_G + Ft_Font_Table_Size - 4, 1024

    ' Download the custom font data - note the first 32 characters in the ascii table are control commands and need to take care of offset
    ' Next download the data at location 32*8*25 - skip the first 32 characters */
    ' each character size is 8 x 25 (200 bytes).
   fontaddr = RAM_G + 7424 ' 1024 + 32 * 8 * 25, make sure space is left at the start of the buffer for first 32 characters

   Load_File FontName1, fontaddr, Ft_Font_Table_Size+1, Bold12bin_Size - Ft_Font_Table_Size

   ClearColorRGB &Hff, &Hff, &Hff 'Set the background To white
   Clear_B 1, 1, 1
   ColorRGB 32, 32, 32 'black Color Text

    ' Display of information string on screen - using inbuilt font
   CmdText FT_DispWidth / 2, 20, 27, OPT_CENTER, "SetFont - format L4"
   BitmapHandle 6         ' use index table 6
   BitmapSource 1024      ' make the address to 0
   BitmapLayout FT_L4, 8, 25 ' stride is 8 and height is 25
   BitmapSize NEAREST, BORDER, BORDER, 16, 25 ' width is 16 and height is 25

    ' Set the font table to the coprocessor engine, bitmap handle used is 6 and the starting
    ' address of the table is 0
   CmdSetFont 6, 0

   CmdText FT_DispWidth /2 ,  80, 6, OPT_CENTER, "The quick brown fox jumps"
   CmdText FT_DispWidth /2 , 120, 6, OPT_CENTER, "over the lazy dog."
   CmdText FT_DispWidth /2 , 160, 6, OPT_CENTER, "1234567890"

   UpdateScreen

   Wait 3

End Sub ' Set_font

'------------------------------------------------------------------------------------------------------------
Sub Set_font2 ' Using '$Inc' instead of the SD Card
'------------------------------------------------------------------------------------------------------------
    ' API To demonstrate Custom Font Display

    '***********************************************************************
    ' This Code demonstrates the usage of Setfont. The Setfont Function draws
    ' Custom configured fonts on to the LCD screen.
    '***********************************************************************

   Const Bold12bin_Size = 19348  ' Bold12.bin file size

   Local FontAddr As Dword
   Local TempDW As  Dword

    ' Copy the header from start of the file into RAM_G

   TempDW = Loadlabel(Bold)
   RdFlash_WrFT800 RAM_G, TempDW, Ft_Font_Table_Size

    ' update the address of the font data - last 4 bytes of the index table contains the font data address
   Wr32 RAM_G + Ft_Font_Table_Size - 4, 1024

    ' Download the custom font data - note the first 32 characters in the ascii table are control commands and need to take care of offset
    ' Next download the data at location 32*8*25 - skip the first 32 characters */
    ' each character size is 8 x 25 (200 bytes).
   fontaddr = RAM_G + 7424 ' 1024 + 32 * 8 * 25, make sure space is left at the start of the buffer for first 32 characters

   TempDW = Loadlabel(Bold)
   TempDW = TempDW + Ft_Font_Table_Size
   RdFlash_WrFT800 fontaddr, TempDW, Bold12bin_Size - Ft_Font_Table_Size

   ClearColorRGB &Hff, &Hff, &Hff 'Set the background To white
   Clear_B 1, 1, 1
   ColorRGB 32, 32, 32 'black Color Text

    ' Display of information string on screen - using inbuilt font
   CmdText FT_DispWidth / 2, 20, 27, OPT_CENTER, "SetFont - format L4 (using $Inc)"
   BitmapHandle 6         ' use index table 6
   BitmapSource 1024      ' make the address to 0
   BitmapLayout FT_L4, 8, 25 ' stride is 8 and height is 25
   BitmapSize NEAREST, BORDER, BORDER, 16, 25 ' width is 16 and height is 25

    ' Set the font table to the coprocessor engine, bitmap handle used is 6 and the starting
    ' address of the table is 0
   CmdSetFont 6, 0

   CmdText FT_DispWidth /2 ,  80, 6, OPT_CENTER, "The quick brown fox jumps"
   CmdText FT_DispWidth /2 , 120, 6, OPT_CENTER, "over the lazy dog."
   CmdText FT_DispWidth /2 , 160, 6, OPT_CENTER, "1234567890"

   UpdateScreen

   Wait 3

End Sub ' Set_font2


'------------------------------------------------------------------------------------------------------------
Sub ChineseFont
'------------------------------------------------------------------------------------------------------------

   Const ChineseFont_SIZE = 21092

   Load_File FontName2, RAM_G + 1000, 0, Ft_Font_Table_Size
   Load_File FontName2, RAM_G + 1000 + Ft_Font_Table_Size, Ft_Font_Table_Size, ChineseFont_SIZE

   ClearColorRGB &Hff, &Hff, &Hff ' set the background to white
   Clear_B 1, 1, 1
   ColorRGB 32, 32, 32 ' black color text

   CmdText FT_DispWidth / 2, 20, 27, OPT_CENTER, "FangSong Font L8 Traditional Chinese"
   ColorRGB 255, 0, 0 ' black color text
   BitmapHandle 7
   BitmapSource 196

   BitmapLayout FT_L8, 28, 34
   BitmapSize NEAREST, BORDER, BORDER, 28, 34

   CmdSetFont 7, RAM_G + 1000

   CmdText FT_DispWidth / 2, 80, 7, OPT_CENTER, "{001}{002}{003}{004}{005}"
   CmdText FT_DispWidth / 2, 80 + 34, 7, OPT_CENTER, "{006}{007}{008}{009}{010}"
   CmdText FT_DispWidth / 2, 80 + 34 + 34, 7, OPT_CENTER, "{011}{012}{013}{014}{015}"
   CmdText FT_DispWidth / 2, 80 + 34 + 34 + 34, 7, OPT_CENTER, "{016}{017}{018}{019}{020}"

   CmdButton FT_DispWidth / 2, 80 + 34 + 34 + 34 + 34, 80, 34, 7, 0, "{021}{022}"

   UpdateScreen

   Wait 3

End Sub ' ChineseFont

'------------------------------------------------------------------------------------------------------------
Sub Load_Jpeg ( Byval file As String * 12)
'------------------------------------------------------------------------------------------------------------
   ' API's used to upload the image to GRAM from SD card

   Local fsize As Dword
   Local BlockLen As Word, Ptr1 As Word, Ptr2 As Word, Ptr3 As Word

   Local fs As Dword

   Endtransfer
   Open file for Binary as #1

   fsize = Lof(1)

   fs = fsize

   Ptr1 = 1 ' Start at the first byte
   BlockLen = Chunk
   While fsize > 0
      If fsize > Chunk Then BlockLen = Chunk Else BlockLen = fsize
      fsize = fsize - BlockLen
      Endtransfer
      Get #1, Dat, Ptr1, BlockLen

      'ALign4 BlockLen

      Ptr2 = BlockLen
      Ptr3 = _base

      While Ptr2 > 0
         Cmd8 aDat(Ptr3)
         Incr Ptr3
         Decr Ptr2
      Wend

      'WaitCmdFifoEmpty

      Ptr1 = Ptr1 + BlockLen
   Wend

   Close #1

   AlignFifo fs
   WaitCmdFifoEmpty


End Sub ' Load_Jpeg

'------------------------------------------------------------------------------------------------------------
Sub Load_File ( Byval file As String * 12, Byval Ptr As Dword, Byval offset As Dword, Byval fsize As Dword )
'------------------------------------------------------------------------------------------------------------
   ' file = 8+3 Filename
   ' Ptr  = Memory Address to send to
   ' offset = optional - Start position of read,  if 0 it starts reading from the beginning of file.
   ' fsize  = optional - Number of bytes to read, if 0 it reads the file size to determin the length for you.

   ' API's used to upload the image to GRAM from SD card
   ' If you run out out room using 'Data' Statements, you can use this routine
   ' as an alternative to read and send a file to the FT800.

   Local BlockLen As Word, Ptr1 As Word

   Endtransfer
   Open file for Binary as #1

   ' If no length specified in the parameter fsize, use the File Length instead.
   If fsize = 0 then fsize = Lof(1)

   If offset = 0 Then
      Ptr1 = 1 ' Start at the first byte
   Else
      Ptr1 = offset
   End If
   BlockLen = Chunk '<-- Global Variable

   While fsize > 0
      If fsize > Chunk Then BlockLen = Chunk Else BlockLen = fsize
      fsize = fsize - BlockLen
      Endtransfer
      Get #1, Dat, Ptr1, BlockLen

      Rdmem_WrFT800 Ptr, aDat(_base), BlockLen

      Ptr1 = Ptr1 + BlockLen
      Ptr  = Ptr  + BlockLen
   Wend

   Close #1

End Sub ' Load_File

'-------------------------------------------------------------------------------------------
Function FileExist(Byval File As String * 12) As Byte
'-------------------------------------------------------------------------------------------

   Local FileX As String * 12

   FileExist = 0

   FileX = Dir( "*.*")

   While FileX <> ""
      If FileX = UCASE(File) Then
         FileExist = 1
         Exit While
      End If

      FileX = Dir()
   Wend

End Function ' FileFile

'------------------------------------------------------------------------------------------------------------
Function AVRDOSInit() As Byte
'------------------------------------------------------------------------------------------------------------

   Local Temp As Byte

   AVRDOSInit = 0

   Gbdriveerror = DriveInit()

   If Gbdriveerror = 0 Then
      Temp = Initfilesystem(1) ' use 0 for drive without Master boot record
      If Temp <> 0 Then
         AVRDOSInit = Temp
      End If
   Else
      AVRDOSInit = Gbdriveerror
   End If

End Function ' AVRDOSInit
'------------------------------------------------------------------------------------------------------------

$INC Bold, nosize, "Bold12.bin"     ' used in SUB Set_font2, rem this line if not needed