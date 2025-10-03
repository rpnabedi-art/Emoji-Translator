' Demo Set 2
' FT800 platform.
' Original code http://www.ftdichip.com/Support/SoftwareExamples/EVE/FT800_SampleApp_1.0.zip
' Requires Bascom 2.0.7.8 or greater

' These Demos require 'lenaface.bin' and 'mandrill.jpg' onto an SD Card.


$Regfile = "M328pdef.dat"
$Crystal = 16000000
$Baud = 115200
$HwStack = 80
$SwStack = 80
$FrameSize = 128
$NOTYPECHECK

Config ft800=spi , ftsave=0, ftdebug=0 , ftcs=portb.1, ftpd=portb.0

Config Base = 0
Config Submode = New
Config Spi = Hard, Interrupt = Off, Data_Order = Msb, Master = Yes, Polarity = Low, Phase = 0, Clockrate = 4, Noss = 1
SPSR = 1  ' Makes SPI run at 8Mhz instead of 4Mhz
Spiinit


MMC_CS Alias PortD.5
Config MMC_CS = Output
MMC_CS = 1

SPI_SS Alias Portb.2
Config SPI_SS = Output
SPI_SS = 1

Declare Sub Screen (ByVal Characters As String)
Declare Sub Inflate
Declare Sub Loadimage
Declare Function AVRDOSInit() As Byte

$Include "FT800.inc"
$Include "FT800_Functions.inc"
$include "Config_MMCSD_HC.bas"
$include "Config_AVR-DOS.BAS"

Const Chunk = 200
Dim Retn As Byte
Dim Dat As String * Chunk
Dim aDat(Chunk) As Byte At Dat Overlay

Const Header_Format = RGB565
Const Header_Width  = 40
Const Header_Height = 40
Const Header_Stride = 80
Const Header_Arrayoffset = 0


Retn = AVRDOSInit(): If Retn <> 0 Then End

if FT800_Init()=1 Then END    ' Initialise the FT800

'------------------------------
' Set 2  Demo's
' Unremark on or more demos and compile
'------------------------------
Screen "Set2 START"

Inflate
Loadimage

Screen "Set2 END!"

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
Sub Inflate '  API To demonstrate the usage Of inflate command - compression done via zlib
'------------------------------------------------------------------------------------------------------------

   Local xoffset As Integer, yoffset As Integer
   Local FF2 As Long

   '***********************************************************************
   ' Code demonstrating the usage of the Inflate function.
   ' Downloads the deflated Data into the Command buffer then the Coprocessor infaltes
   ' the deflated Data and outputs it at location 0.
   '***********************************************************************

   xoffset = FT_DispWidth - Header_Width
   xoffset = xoffset / 2
   yoffset = FT_DispHeight - Header_Height
   yoffset = yoffset / 2

   ' Clear the Memory At location 0 - Any previous Bitmap Data
   Cmdmemset 0, 255, Header_Stride * Header_Height

   ' Set the Display list for Graphics Processor
   ' Bitmap construction by MCU - Display Lena At 200 x 90 offset
   ClearColorRGB 0, 0, 255
   Clear_B 1, 1, 1
   ColorRGB 255, 255, 255
   Begin_G BITMAPS
   BitmapSource 0
   BitmapLayout Header_Format, Header_Stride, Header_Height
   BitmapSize BILINEAR, BORDER, BORDER, Header_Width, Header_Height
   Vertex2F xoffset * 16, yoffset * 16
   End_G

   '  Display the Text information
   COLOR_A 255
   xoffset = xoffset - 50
   yoffset = yoffset + 40
   CmdText xoffset, yoffset, 26, 0, "Display bitmap by inflate"

   ' inflate the Data read from binary file
   ' Inflate the Data into location 0
   Cmd32 Cmd_inflate
   Cmd32 0
   Load_Jpeg "lenaface.bin"

   UpdateScreen

   Wait 1

End Sub ' Inflate

'------------------------------------------------------------------------------------------------------------
Sub Loadimage
'------------------------------------------------------------------------------------------------------------

   Local ImgW As Integer, ImgH As Integer, xoffset As Integer, yoffset As Integer
   Local Tmp As Integer

   '***********************************************************************
   ' Code demonstrates the usage of the Loadimage Function
   ' Downloads the JPG Data into Command buffer which then the Coprocessor decodes
   ' and dumps into location 0 in a rgb565 format.
   '***********************************************************************

   ImgW = 256
   ImgH = 256
   xoffset = FT_DispWidth - ImgW
   xoffset = xoffset / 2
   yoffset = FT_DispHeight - ImgH
   yoffset = yoffset / 2

   ' Clear the Memory At location 0 - Any previous Bitmap Data
   CmdMemset 0, 255, 131072 '256 * 2 * 256

   ' Set the Display list For graphics processor
   ClearColorRGB 0, 255, 255
   Clear_B 1,1,1
   ColorRGB 255, 255, 255
   Begin_G BITMAPS
   BitmapSource 0
   BitmapLayout RGB565, ImgW * 2, ImgH
   BitmapSize BILINEAR, BORDER, BORDER, ImgW, ImgH
   Vertex2F xoffset * 16, yoffset * 16
   End_G

   '  Display the Text information
   xoffset = FT_DispWidth / 2
   yoffset = FT_DispHeight / 2
   CmdText xoffset, yoffset, 26, OPT_CENTER, "Display bitmap by jpg decode"

   UpdateScreen

   ' Decode jpg Output into location 0 And Output Color format As RGB565
   CmdLoadImage 0, 0
   Load_Jpeg "mandrill.jpg"

   Wait 1

   ' Decode jpg Output into location 0 and Output As MONOCHROME
   ' Clear the Memory At location 0 - Any previous Bitmap Data
   xoffset = FT_DispWidth - ImgW
   xoffset = xoffset / 2
   yoffset = FT_DispHeight - ImgH
   yoffset = yoffset / 2

   CmdMemSet 0, 255, 131072 '256 * 2 * 256

   ' Set the Display list For graphics processor
   ClearColorRGB 0, 0, 0
   Clear_B 1, 1, 1
   ColorRGB 255, 255, 255
   Begin_G BITMAPS
   BitmapSource 0
   BitmapLayout L8, ImgW, ImgH 'monochrome
   BitmapSize BILINEAR, BORDER, BORDER, ImgW, ImgH
   Vertex2F xoffset * 16, yoffset * 16
   End_G

   '  Display the Text information
   xoffset = FT_DispWidth / 2
   yoffset = FT_DispHeight / 2
   CmdText xoffset, yoffset, 26, OPT_CENTER, "Display bitmap by jpg decode L8"
   UpdateScreen

   CmdLoadImage 0, OPT_MONO
   Load_Jpeg "mandrill.jpg"

   Wait 2

End Sub ' Loadimage

'------------------------------------------------------------------------------------------------------------
Function FindFile (Byref File As String * 12) As Byte
'------------------------------------------------------------------------------------------------------------

   Local FileX As String * 12

   FindFile = 0

   FileX = Dir( "*.*")

   While FileX <> ""
      If FileX = UCase(File) Then
         FindFile = 1
         Exit While
      End If

      FileX = Dir()
   Wend

End Function ' FindFile

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
Function FileExist(Byref File As String * 12) As Byte
'------------------------------------------------------------------------------------------------------------

   Local FileX As String * 12

   FileExist = 0

   FileX = Dir( "*.*")

   While FileX <> ""
      If FileX = File Then
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