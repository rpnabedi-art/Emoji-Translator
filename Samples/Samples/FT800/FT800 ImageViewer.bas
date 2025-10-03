' FT800 ImageViewer Application
' APP to demonstrate interactive Jpeg decode, using Blend function, Bitmap flip & Jpeg decode.
' Ported from http://www.ftdichip.com/Support/SoftwareExamples/EVE/FT_App_Imageviewer.zip
' Requires Bascom 2.0.7.8 or greater

' This program requires the following files onto an SD Card.
' BSPLASH.JPG, DAISY.JPG, EMPIRE.JPG, FRED2.JPG, ME320.JPG, PENCILS.JPG, TULIPS.JPG, AUTUMN.JPG

' !!NOTE!!: This demo is just a bare essential with hardly any SRAM left, chose another processor for proper use.

$Regfile = "M328pdef.dat"
$Crystal = 16000000
$Baud = 115200
$HwStack = 50    ' <-- low values
$SwStack = 50    ' <-- low values
$FrameSize = 120
$NOTYPECHECK

Config ft800=spi , ftsave=0, ftdebug=0  , ftcs=portb.1, ftpd=portb.0

Config Base = 0
Config Submode = New
Config Spi = Hard, Interrupt = Off, Data_Order = Msb, Master = Yes, Polarity = Low, Phase = 0, Clockrate = 4, Noss = 1
'Config Spi = Soft , Din = Pinb.3 , Dout = Portb.2 , Ss =Portb.0 , Clock = Portb.1, Noss = 1, Mode=0
SPSR = 1  ' Makes SPI run at 8Mhz instead of 4Mhz
Spiinit

Declare Sub LoadJpeg(Byval file As Byte)
Declare Sub Imageviewer
Declare Sub Loadimage2ram (Byval bmphandle As Byte)
Declare Function FileExist(Byref File As String * 12) As Byte
Declare Sub SendFromLabel(byval Varaddress As Word , Byval Count As Dword)
Declare Function AVRDOSInit() As Byte

SPI_SS Alias Portb.2
Config SPI_SS = Output
SPI_SS = 1

MMC_CS Alias PortD.5
Config MMC_CS = Output
MMC_CS = 1

$Include "FT800.inc"
$Include "FT800_Functions.inc"
$include "Config_MMCSD_HC.bas"
$include "Config_AVR-DOS.BAS"

Const Chunk = 200
Dim Retn As Byte
Dim Dat As String * Chunk
Dim aDat(Chunk) As Byte At Dat Overlay

Const MAX_IMAGES = 8
Dim imagename(MAX_IMAGES) As String * 12

imagename(00+_base) = "bsplash.jpg"
imagename(01+_base) = "DAISY.JPG"
imagename(02+_base) = "EMPIRE.JPG"
imagename(03+_base) = "FRED2.JPG"
imagename(04+_base) = "ME320.JPG"
imagename(05+_base) = "PENCILS.JPG"
imagename(06+_base) = "TULIPS.JPG"
imagename(07+_base) = "AUTUMN.JPG"

Retn = AVRDOSInit(): If Retn <> 0 Then End


if FT800_Init()=1 then end   ' Initialise the FT800

Imageviewer

Do
Loop


End


'-------------------------------------------------------------------------------------------
Sub Imageviewer
'-------------------------------------------------------------------------------------------

   Local nooffiles As Integer, i As Integer, x As Integer , x1 As Integer, xv As Integer, px As Integer
   Local transform  As Integer, boot As Integer, Temp As Integer
   Local X2 As Long
   Local tracker As Dword, temp_x As Dword
   Local r As Byte, loaded As Byte, Touch_detected As Byte, tmp As Byte
   Dim image_index As Byte

   image_index = 0

   px = FT_DispWidth - 320
   px = px / 2
   x = FT_DispWidth - 320
   x = x / 2
   temp_x = x
   transform = 273
   boot = 1
   tracker=0
   r = 1
   loaded = 0
   Touch_detected = 0

   Wr16 REG_VOL_SOUND, 100
   Wr16 REG_SOUND, 80

   Clear_B 1,1,1
   Loadimage2ram r

    ' Compute the gradient
   For i = 0 to  63
      tmp = 3 * i
      tmp = tmp  / 2
      tmp=96-tmp
      Wr8 i, tmp
   Next

    ' Set the bitmap properties
   Clear_B 1,1,1
   BitmapHandle r
   If r > 0 Then BitmapSource 131072 Else BitmapSource 100
   BitmapLayout RGB565, 320 * 2,194
   BitmapSize NEAREST, BORDER, BORDER, 320, 194
   BitmapHandle 2
   BitmapSource 0
   BitmapLayout L8, 1, 64
   BitmapSize NEAREST, REPEAT, BORDER, FT_DispWidth, 64

   Begin_G BITMAPS
   Vertex2II x, 10, r, 0

   UpdateScreen

   Do
      Clear_B 1, 1, 1
      CmdGradient 0, FT_DispHeight/2, 0, 0, FT_DispHeight, &H605040
      ColorRGB 255, 255, 255
      Begin_G BITMAPS
      If x <> temp_x Then
         BitmapHandle r XOR 1
         Cell 0
         X1 = x - FT_DispWidth
         X1 = X1 - temp_x
         Vertex2F 16 * X1, 16 * 10
      End If

        ' Image reflection on the floor
      Vertex2II x, 10, r, 0
      SaveContext
      ColorMask 0, 0, 0, 1
      BlendFunc ONE, ZERO

      #If Wqvga  = 1
         Vertex2II 0, 212, 2, 0
      #Else
         Vertex2II 0, 207, 2, 0
      #Endif

      ColorMASK 1, 1, 1, 1
      BlendFunc DST_ALPHA, ONE_MINUS_DST_ALPHA

      CmdLoadIdentity
      CmdTranslate temp_x * 65536, 65536 * 96.5
      CmdScale 1 * 65536, 65536 * -1
      X2 = -temp_x
      X2 = X2 * 65536
      CmdTranslate X2, 65536 * -96.5
      CmdSetMatrix
      If x <> temp_x Then
         BitmapHandle r XOR 1
         Cell 0

         Vertex2F 16 * X1, 16 * 212
      End If

      #If Wqvga  = 1
         Vertex2II x, 212, r, 0
      #Else
         Vertex2II x, 207, r, 0
      #Endif

      RestoreContext

      If px = temp_x AND loaded =0 AND boot =0 Then
         BitmapHandle r XOR 1
         X1 = r XOR 1
         If X1 > 0 Then BitmapSource 131072 Else BitmapSource 100

         BitmapLayout RGB565, 320 * 2, 194
         BitmapSize NEAREST, BORDER, BORDER, 320, 194
         Loadimage2ram r XOR 1
         loaded = 1
      End If

      If Retn = True Then ' Retn = Global variable
         CmdText x + 40, FT_DispHeight / 3, 28, OPT_CENTERY,"Storage Device not Found"
      End If

      UpdateScreen

      boot = 0
        ' read the tracker
      tracker = Rd32 (REG_TOUCH_SCREEN_XY)
        ' change the bitmap handle if touch is detected
      If loaded = 1 AND x = temp_x AND tracker <> &H80008000 Then
         Wr8 REG_PLAY, 1 ' Play the Sound
         x = FT_DispWidth
         r = r XOR 1
         loaded = 0
      End If

      xv = x / 16
      xv = xv + 1
      px = x

      Temp = x - xv
      If temp_x > Temp Then x = temp_x Else x = Temp

   Loop


End Sub ' Imageviewer

'-------------------------------------------------------------------------------------------
Sub Loadimage2ram (Byval bmphandle As Byte)
'-------------------------------------------------------------------------------------------
   Const PP = 320 * 2 * 194
   Const P1 = MAX_IMAGES-1
   Local FF As Byte
   Local Check1 As Integer

   Endtransfer
   ff = FileExist (imagename(image_index+_base))


   ' If file not found then blank screen.
   If ff = False Then
      Cmd32 Cmd_MemSet
      If bmphandle > 0 Then Cmd32 131072 Else Cmd32 100
      If bmphandle > 0 Then Cmd32 150 Else Cmd32 100
      Cmd32 PP
   Else
      Cmd32 Cmd_LoadImage
      If bmphandle > 0 Then Cmd32 131072 Else Cmd32 100
      Cmd32 0

      LoadJpeg image_index + _base '<=== Global
   End If

   Incr image_index
   If image_index > P1 then image_index = 0

End Sub ' Loadimage2ram

'-------------------------------------------------------------------------------------------
Sub LoadJpeg( Byval file As Byte)
'-------------------------------------------------------------------------------------------
   ' API's used to upload the image to GRAM from SD card

   Local fsize As Dword
   Local BlockLen As Word, Ptr1 As Word, Ptr2 As Word, Ptr3 As Word

   Endtransfer
   Open imagename(file) for Binary as #1

   fsize = Lof(1)

   Ptr1 = 1 ' Start at the first byte
   BlockLen = Chunk
   While fsize > 0
      If fsize > Chunk Then BlockLen = Chunk Else BlockLen = fsize
      fsize = fsize - BlockLen
      Endtransfer
      Get #1, Dat, Ptr1, BlockLen

      ALign4 BlockLen

      Ptr2 = BlockLen
      Ptr3 = _base

      While Ptr2 > 0
         Cmd8 aDat(Ptr3)
         Incr Ptr3
         Decr Ptr2
      Wend

      EndTransfer
      WaitCmdFifoEmpty

      Ptr1 = Ptr1 + BlockLen
   Wend
   Close #1

End Sub ' LoadJpeg

'-------------------------------------------------------------------------------------------
Function FileExist(Byref File As String * 12) As Byte
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

'-------------------------------------------------------------------------------------------
Function AVRDOSInit() As Byte
'-------------------------------------------------------------------------------------------

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
'-------------------------------------------------------------------------------------------


' api to reset coprocessor only - do this only when coprocessor returns error. for graphic processor error, utilize reset() api
'Sub ResetCopro
'{
'        ' first set the reset bit high
'        Wr8 REG_CPURESET, FT_RESET_HOLD_COPROCESSOR ' first hold the coprocessor in reset
'        ' make the cmd read write pointers to 0
'        CmdFifoWp = 0
'        FreeSpace = FT_CMDFIFO_SIZE - 4;
'        Wr16 REG_CMD_READ, 0
'        Wr16 REG_CMD_WRITE, 0
'        DelayMs 10 ' just to make sure reset is fine
'        ' release the coprocessors from reset
'        Wr8 REG_CPURESET, FT_RESET_RELEASE_COPROCESSOR
'        ' ideally delay of 25ms is required for audio engine to playback mute sound to avoid pop sound */
'End Sub


'  "FT800 ImageViewer Application",
'  "APP to demonstrate interactive Jpeg decode,",
'  "using Blend function, Bitmap flip,",
'  "& Jpeg decode"