' Ft800 Player, APP to demonstrate Audio playback using bargraph & Audio
' FT800 platform.
' Original code from http://www.ftdichip.com/Support/SoftwareExamples/EVE/FT_App_Player.zip
' Requires Bascom 2.0.7.8 or greater

' This Demo requires 'DARKAGES.ULW' file on the SD Card.

$Regfile = "M328pdef.dat"
$Crystal = 16000000
$Baud = 57600
$HwStack = 50
$SwStack = 50
$FrameSize = 128
$NOTYPECHECK
$BIGSTRINGS

Config ft800=spi, ftsave=0, ftdebug=0 , ftcs=portb.0 , platform=gameduino2, lcd_rotate=1 ' Gameduino2
'Config Ft800 = Spi , Ftsave = 0 , Ftdebug = 0 , Ftcs = Portd.4 , Ftpd = Portd.3  ' 4D AdamShield
'Config Ft800 = Spi , Ftcs = Portb.1 , Ftpd = Portd.4 ' VM801P

Config Base = 0
Config Submode = New
Config Spi = Hard, Interrupt = Off, Data_Order = Msb, Master = Yes, Polarity = Low, Phase = 0, Clockrate = 4, Noss = 1
SPSR = 1  ' Makes SPI run at 8Mhz instead of 4Mhz

SPI_SS Alias Portb.2
Config SPI_SS = Output
SPI_SS = 1

MMC_CS Alias PortB.1
Config MMC_CS = Output
MMC_CS = 1

Declare Sub Player
Declare Function AVRDOSInit() As Byte
Declare Function FileExist(Byval File As String * 12) As Byte

$Include "FT80x.inc"
$Include "FT80x_Functions.inc"
$include "Config_MMCSD_HC.bas"
$include "Config_AVR-DOS.BAS"

Dim Retn As Byte
Const Chunk = 512 '<-- to get a full screen requires 512 bytes
Dim Dat As String * Chunk

Spiinit


Retn = AVRDOSInit(): If Retn <> 0 Then End


if FT800_Init()=1 Then END    ' Initialise the FT800


Player

Do
Loop


End


Sub Player

   Local ftsize As Dword, rp As integer, Value As Dword, n As Dword, Offset As Dword
   Local wp As Integer, Tmp As Integer

    ' Intilaize the bitmap for Bargraph
   CmdMemSet 0, 0, 100 * 1024
    ' bit map settings for visualeffect from gram 8192
   Clear_B 1, 1, 1
   BitmapSource 4096
   BitmapLayout BARGRAPH, 256, 1
   BitmapSize NEAREST, BORDER, BORDER, 256, 256
   ColorRGB &Hff, &Hc0, &H80
   Begin_G BITMAPS
   Vertex2II 0, 0, 0, 0
   Vertex2II 256, 0, 0, 1
   ColorRGB 0, 0, 0
   Vertex2II 0, 32, 0, 0
   Vertex2II 256, 32, 0, 1

   UpdateScreen

    ' Intilaize the audio setting
   Wr32 REG_PLAYBACK_FREQ, 11025
   Wr32 Reg_PLAYBACK_START,0
   Wr32 REG_PLAYBACK_FORMAT, ULAW_SAMPLES
   Wr32 REG_PLAYBACK_LENGTH, 8192
   Wr32 REG_PLAYBACK_LOOP,1
   Wr8 REG_VOL_PB, 100

    ' open the audio file from the SD card

   If FileExist("DREAM.WAV") = False Then
      ClearScreen
      CmdText FT_DispWidth / 2, FT_DispHeight / 2, 28, OPT_CENTERX OR OPT_CENTERY,"Audio File not Found or Corrupt"
      UpdateScreen
      Close #1
      Wait 3
      Exit Sub
   Else
      Open "DREAM.WAV" for Binary as #1
      ftsize = Lof(1)
   End If

   wp = Chunk

    ' Initate to play
   Wr8 REG_PLAYBACK_PLAY, 1

   Get #1, Dat, 1, wp
   Rdmem_wrft800 0 , Dat , wp
   Offset = wp

   While ftsize > 0

      rp = Rd16 (REG_PLAYBACK_READPTR)
      Tmp = rp - wp
      value = 8191 AND Tmp
      If value > Chunk Then
         n = Chunk
         If ftsize < Chunk Then n = ftsize
         Get #1, Dat, Offset, n
         Rdmem_wrft800 wp , Dat , n
         Offset = Offset + n
         Tmp = wp + Chunk
         wp = Tmp AND 8191
         ftsize = ftsize - n
      End If
   Wend

   Wr8 REG_VOL_PB, 0
   Wr8 REG_PLAYBACK_PLAY, 0

End Sub ' Player

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