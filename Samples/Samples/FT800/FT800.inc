$nocompile
' FT800.inc
' FT800 Definitions
' Revision 6  19 November 2014
'------------------------------------------------------------
Const Gameduino2            = 0 ' For the Gameduino2 Board
Const WqVGA                 = 0 ' 1 = Default Display 480x272 otherwise 0 = 320x240 (for 3.5" display)
Const Debugger              = 0 ' Prints all SPI Data Output to Serial
Const LcdCal                = 1 ' Prompts for LCD Calibration (if not previously done)
Const RotateDisplay         = 0 ' Rotate Screen 180 degrees
'------------------------------------------------------------

Const True              = 1
Const False             = 0
Const Gap               = "{255}"

Const Fudgefactor1          = 1705 ' rough estimate of cycles of While/Wend in Sub Waitcmdfifoempty
Const Fudgefactor2          = 1096 ' rough estimate of cycles of While/Wend in Sub FreeSpaceFt
Const ClockTicks            = (1 / _Xtal) * 1000
Const FT_TimeOut            = 1000 ' mS
Const EndTime1              = (FT_TimeOut / ClockTicks) / Fudgefactor1
Const EndTime2              = (FT_TimeOut / ClockTicks) / Fudgefactor2


Const Ft_Ok             = &H00
Const Ft_GPU_Read       = &H00
Const Ft_GPU_Write      = &H01

Const Ft_GPU_Active     = &H00
Const Ft_GPU_Standby    = &H41
Const Ft_GPU_Sleep      = &H42
Const Ft_GPU_PowerDown  = &H50

Const Ft_GPU_Internal_Osc = &H48
Const Ft_GPU_External_Osc = &H44

Const Ft_GPU_PLL_48m    = &H62
Const Ft_GPU_PLL_36m    = &H61
Const Ft_GPU_PLL_24m    = &H64
Const Low_Freq_Bound    = 47040000

Const Ft_GPU_Core_Reset = &H68

Const Ft_GPU_I2C_Mode   = 0
Const Ft_GPU_SPI_Mode   = 1
Const Ft_GPU_Mode_Count = 2
Const Ft_GPU_Mode_unknown = Ft_GPU_Mode_Count

Const Ft_GPU_Opened         = 0
Const Ft_GPU_Reading        = 1
Const Ft_GPU_Writing        = 2
Const Ft_GPU_Closed         = 3
Const Ft_GPU_Status_Count   = 4
Const Ft_GPU_Status_Error   = Ft_GPU_Status_Count


' Definitions used for FT800 co processor command buffer
Const Cmdbuf_Size       = 4096
Const FT_Copro_Error    = 4095
Const Ft_DL_Size        = 8 * 1024                           ' 8KB Display List buffer size
Const Ft_Cmd_FIFO_Size  = 4 * 1024                           ' 4KB coprocessor Fifo size
Const Ft_Cmd_Size       = 4                                  ' 4 byte per coprocessor command of EVE
Const Ft_Numchar_Per_Font   = 128
Const Ft_Font_Table_Size    = 148
Const Ft_TotalBufflen   = Ft_Cmd_FIFO_Size - 1

' Graphics Engine Commands
Const Cmd_Append        = &HFFFFFF1E
Const Cmd_BgColor       = &HFFFFFF09
Const Cmd_Bitmap_Transform = &HFFFFFF21
Const Cmd_Button        = &HFFFFFF0D
Const Cmd_Calibrate     = &HFFFFFF15
Const Cmd_Clock         = &HFFFFFF14
Const Cmd_Coldstart     = &HFFFFFF32
Const Cmd_CRC           = &HFFFFFF03
Const Cmd_Dial          = &HFFFFFF2D
Const Cmd_DLStart       = &HFFFFFF00
Const Cmd_Execute       = &HFFFFFF07
Const Cmd_FgColor       = &HFFFFFF0A
Const Cmd_Gauge         = &HFFFFFF13
Const Cmd_GetMatrix     = &HFFFFFF33
Const Cmd_GetPoint      = &HFFFFFF08
Const Cmd_GetProps      = &HFFFFFF25
Const Cmd_GetPTR        = &HFFFFFF23
Const Cmd_GradColor     = &HFFFFFF34
Const Cmd_Gradient      = &HFFFFFF0B
Const Cmd_Hammeraux     = &HFFFFFF04
Const Cmd_Idct          = &HFFFFFF06
Const Cmd_Inflate       = &HFFFFFF22
Const Cmd_Interrupt     = &HFFFFFF02
Const Cmd_Keys          = &HFFFFFF0E
Const Cmd_LoadIdentity  = &HFFFFFF26
Const Cmd_LoadImage     = &HFFFFFF24
Const Cmd_Logo          = &HFFFFFF31
Const Cmd_March         = &HFFFFFF05
Const Cmd_MemCpy        = &HFFFFFF1D
Const Cmd_MemCRC        = &HFFFFFF18
Const Cmd_MemSet        = &HFFFFFF1B
Const Cmd_MemWrite      = &HFFFFFF1A
Const Cmd_MemZero       = &HFFFFFF1C
Const Cmd_Number        = &HFFFFFF2E
Const Cmd_Progress      = &HFFFFFF0F
Const Cmd_Regread       = &HFFFFFF19
Const Cmd_Rotate        = &HFFFFFF29
Const Cmd_Scale         = &HFFFFFF28
Const Cmd_ScreenSaver   = &HFFFFFF2F
Const Cmd_ScrollBar     = &HFFFFFF11
Const Cmd_SetFont       = &HFFFFFF2B
Const Cmd_SetMatrix     = &HFFFFFF2A
Const Cmd_Sketch        = &HFFFFFF30
Const Cmd_Slider        = &HFFFFFF10
Const Cmd_Snapshot      = &HFFFFFF1F
Const Cmd_Spinner       = &HFFFFFF16
Const Cmd_Stop          = &HFFFFFF17
Const Cmd_Swap          = &HFFFFFF01
Const Cmd_Text          = &HFFFFFF0C
Const Cmd_Toggle        = &HFFFFFF12
Const Cmd_Touch_Transform = &HFFFFFF20
Const Cmd_Track         = &HFFFFFF2C
Const Cmd_Translate     = &HFFFFFF27

' Command and register value options
Const Clr_Col           = 4
Const Clr_Stn           = 2
Const Clr_Tag           = 1
Const Decrx             = 4
Const Decr_Wrap         = 7
Const Dlswap_Done       = 0
Const Dlswap_Frame      = 2
Const Dlswap_Line       = 1
Const Dst_Alpha         = 3
Const Edge_Strip_a      = 7
Const Edge_Strip_b      = 8
Const Edge_Strip_l      = 6
Const Edge_Strip_r      = 5
Const Equal             = 5
Const Gequal            = 4
Const Greater           = 3
Const Incrx             = 3
Const Incr_Wrap         = 6
Const Int_CmdEmpty      = 32
Const Int_CmdFlag       = 64
Const Int_ConvComplete  = 128
Const Int_Playback      = 16
Const Int_Sound         = 8
Const Int_Swap          = 1
Const Int_Tag           = 4
Const Int_Touch         = 2
Const Invert            = 5
Const Display_x         = 0
Const Keep              = 1
Const L1                = 1
Const L4                = 2
Const L8                = 3
Const Lequal            = 2
Const Less              = 1
Const Linear_Samples    = 0
Const Lines             = 3
Const Line_Strip        = 4
Const Nearest           = 0
Const Never             = 0
Const Notequal          = 6

Const One               = 1
Const One_Minus_Dst_Alpha = 5
Const One_Minus_Src_Alpha = 4

Const Opt_3D            = 0
Const Opt_Center        = 1536
Const Opt_CenterX       = 512
Const Opt_CenterY       = 1024
Const Opt_RightX        = 2048
Const Opt_Signed        = 256
Const Opt_Flat          = 256
Const Opt_Mono          = 1
Const Opt_NoBack        = 4096
Const Opt_NoDL          = 2
Const Opt_NoHands       = 49152
Const Opt_NoHm          = 16384
Const Opt_NoPointer     = 16384
Const Opt_NoSecs        = 32768
Const Opt_NoTicks       = 8192

Const Paletted          = 8
Const Ftpoints          = 2
Const Rects             = 9
Const Repeat            = 1
Const Replace           = 2
Const Rgb332            = 4
Const Rgb565            = 7
Const Src_Alpha         = 2
Const Text8x8           = 9
Const TextVGA           = 10
Const TouchMode_Continuous = 3
Const TouchMode_Frame   = 2
Const TouchMode_Off     = 0
Const TouchMode_Oneshot = 1
Const Aw_Samples        = 1
Const Ulaw_Samples      = 1
Const Zero              = 0

' FT800 Memory Map Addresses
Const Ram_G             = &H00000000
Const Ram_DL            = &H00100000
Const Ram_Pal           = &H00102000
Const Ram_Reg           = &H00102400
Const Ram_Cmd           = &H00108000
Const Ram_ScreenShot    = &H001C2000


' FT800 Register Addresses
Const Reg_Analog        = &H00102538
Const Reg_Ana_Comp      = &H00102570
Const Reg_Clock         = &H00102408
Const Reg_Cmd_DL        = &H001024EC
Const Reg_Cmd_Read      = &H001024E4
Const Reg_Cmd_Write     = &H001024E8
Const Reg_CpuReset      = &H0010241C
Const Reg_CRC           = &H00102568
Const Reg_CSpread       = &H00102464
Const Reg_Cya0          = &H001024D0
Const Reg_Cya1          = &H001024D4
Const Reg_Cya_Touch     = &H00102534
Const Reg_DateStamp     = &H0010253C
Const Reg_Dither        = &H0010245C
Const Reg_DlSwap        = &H00102450
Const Reg_Frames        = &H00102404
Const Reg_Frequency     = &H0010240C
Const Reg_GPIO          = &H00102490
Const Reg_GPIO_dir      = &H0010248C
Const Reg_hCycle        = &H00102428
Const Reg_hOffset       = &H0010242C
Const Reg_hSize         = &H00102430
Const Reg_hSync0        = &H00102434
Const Reg_hSync1        = &H00102438
Const Reg_ID            = &H00102400
Const Reg_Int_En        = &H0010249C
Const Reg_Int_Flags     = &H00102498
Const Reg_Int_Mask      = &H001024A0
Const Reg_Macro_0       = &H001024C8
Const Reg_Macro_1       = &H001024CC
Const Reg_OutBits       = &H00102458
Const Reg_PCLK          = &H0010246C
Const Reg_PCLK_Pol      = &H00102468
Const Reg_Play          = &H00102488
Const Reg_PlayBack_Format = &H001024B4
Const Reg_PlayBack_Freq = &H001024B0
Const Reg_PlayBack_Length = &H001024A8
Const Reg_PlayBack_Loop = &H001024B8
Const Reg_PlayBack_Play = &H001024BC
Const Reg_PlayBack_ReadPTR = &H001024AC
Const Reg_PlayBack_Start= &H001024A4
Const Reg_PWM_Duty      = &H001024C4
Const Reg_PWM_Hz        = &H001024C0
Const Reg_RenderMode    = &H00102410
Const Reg_RomSub_Sel    = &H001024E0
Const Reg_Rotate        = &H00102454
Const Reg_ScreenShot_EN     = &H00102410 ' Set to enable screenshot mode
Const Reg_ScreenShot_Y      = &H00102414 ' Y line register
Const Reg_ScreenShot_Start  = &H00102418 ' Screenshot start trigger
Const Reg_ScreenShot_Busy   = &H001024d8 ' Screenshot ready flags
Const Reg_ScreenShot_Read   = &H00102554 ' Set to enable readout
Const Reg_SnapShot      = &H00102418
Const Reg_Snapy         = &H00102414
Const Reg_Sound         = &H00102484
Const Reg_Swizzle       = &H00102460
Const Reg_Tag           = &H00102478
Const Reg_Tag_x         = &H00102470
Const Reg_Tag_y         = &H00102474
Const Reg_Tap_CRC       = &H00102420
Const Reg_Tap_Mask      = &H00102424
Const Reg_Touch_ADC_Mode = &H001024F4
Const Reg_Touch_Charge  = &H001024F8
Const Reg_Touch_Direct_XY = &H00102574
Const Reg_Touch_Direct_Z1Z2 = &H00102578
Const Reg_Touch_Mode    = &H001024F0
Const Reg_Touch_OverSample = &H00102500
Const Reg_Touch_Raw_XY  = &H00102508
Const Reg_Touch_rz      = &H0010250C
Const Reg_Touch_rzThresh = &H00102504
Const Reg_Touch_Screen_XY = &H00102510
Const Reg_Touch_Settle  = &H001024FC
Const Reg_Touch_Tag     = &H00102518
Const Reg_Touch_Tag_XY  = &H00102514
Const Reg_Touch_Transform_A = &H0010251C
Const Reg_Touch_Transform_B = &H00102520
Const Reg_Touch_Transform_C = &H00102524
Const Reg_Touch_Transform_D = &H00102528
Const Reg_Touch_Transform_E = &H0010252C
Const Reg_Touch_Transform_F = &H00102530
Const Reg_Tracker       = &H00109000
Const Reg_Trim          = &H0010256C
Const Reg_vCycle        = &H0010243C
Const Reg_vOffset       = &H00102440
Const Reg_Vol_PB        = &H0010247C
Const Reg_Vol_Sound     = &H00102480
Const Reg_vSize         = &H00102444
Const Reg_vSync0        = &H00102448
Const Reg_vSync1        = &H0010244C

' Display list commands to be embedded in Graphics Processor
Const Dl_Alpha_Func     = &H09
Const Dl_Bitmap_Handle  = &H05
Const Dl_Bitmap_Layout  = &H07
Const Dl_Bitmap_Size    = &H08
Const Dl_Bitmap_Source  = &H01
Const Dl_Bitmap_tForm_A = &H15
Const Dl_Bitmap_tForm_B = &H16
Const Dl_Bitmap_tForm_C = &H17
Const Dl_Bitmap_tForm_D = &H18
Const Dl_Bitmap_tForm_E = &H19
Const Dl_Bitmap_tForm_F = &H1A
Const Dl_Blend_Func     = &H0B
Const Dl_Begin          = &H1F
Const Dl_Call           = &H1D
Const Dl_Clear          = &H26
Const Dl_Cell           = &H06
Const Dl_Clear_RGB      = &H02
Const Dl_Clear_Stencil  = &H11
Const Dl_Clear_Tag      = &H12
Const Dl_Color_A        = &H10
Const Dl_Color_Mask     = &H20
Const Dl_Color_RGB      = &H04
Const Dl_Display        = &H00
Const Dl_End            = &H21
Const Dl_Jump           = &H1E
Const Dl_Line_Width     = &H0E
Const Dl_Macro          = &H25
Const Dl_Point_Size     = &H0D
Const Dl_Restore_Context= &H23
Const Dl_Return         = &H24
Const Dl_Save_Context   = &H22
Const Dl_Scissor_Size   = &H1C
Const Dl_Scissor_XY     = &H1B
Const Dl_Stencil_Func   = &H0A
Const Dl_Stencil_Mask   = &H13
Const Dl_Stencil_OP     = &H0C
Const Dl_Tag            = &H03
Const Dl_Tag_Mask       = &H14
Const Dl_Vertex2f       = &H40
Const Dl_Vertex2II      = &H80

Const ADC_Differential  = 1
Const ADC_Single_Ended  = 0
Const ADPCM_Samples     = 2
Const Always            = 7
Const ARGB1555          = 0
Const ARGB2             = 5
Const ARGB4             = 6
Const Bargraph          = 11
Const Bilinear          = 1
Const Bitmaps           = 1
Const Border            = 0

' Basic Colors
Const Black             = &H000000
Const White             = &HFFFFFF
Const Red               = &HFF0000
Const Lime              = &H00FF00
Const Blue              = &H0000FF
Const Yellow            = &HFFFF00
Const Cyan              = &H00FFFF
Const Magenta           = &HFF00FF
Const Silver            = &HC0C0C0
Const Grey              = &H808080
Const Maroon            = &H800000
Const Olive             = &H808000
Const Green             = &H008000
Const Purple            = &H800080
Const Teal              = &H008080
Const Navy              = &H000080
Const Brown             = &H703800
Const Orange            = &H00A5FF

' Default is WQVGA - 480x272
#if Wqvga = 1
   Const Ft_DispWidth      = 480
   Const Ft_DispHeight     = 272
   Const Ft_DisphCycle     = 548
   Const Ft_DisphOffset    = 43
   Const Ft_DisphSync0     = 0
   Const Ft_DisphSync1     = 41
   Const Ft_DispvCycle     = 292
   Const Ft_DispvOffset    = 12
   Const Ft_DispvSync0     = 0
   Const Ft_DispvSync1     = 10
   Const Ft_DisppClkPol    = 1
   Const Ft_DisppCLK       = 5    ' 5 = 60 Hz, 4 = 75 Hz    3 = good no flicker but overclocks the LCD

   #if Gameduino2 = 1
      Const Ft_DispSwizzle = 3
   #else
      Const Ft_DispSwizzle = 0
   #endif

#else                                                       ' QVGA LCD display

   Const Ft_DispWidth      = 320
   Const Ft_DispHeight     = 240
   Const Ft_DisphCycle     = 408
   Const Ft_DisphOffset    = 70
   Const Ft_DisphSync0     = 0
   Const Ft_DisphSync1     = 10
   Const Ft_DispvCycle     = 263
   Const Ft_DispvOffset    = 13
   Const Ft_DispvSync0     = 0
   Const Ft_DispvSync1     = 2
   Const Ft_DisppCLKpol    = 0
   Const Ft_DisppCLK       = 5                                  ' was 8, stopped fickering of lcd
   Const Ft_DispSwizzle    = 2

#endif

Declare Sub Alphafunc(byreg R16 As Byte , Byreg r17 As Byte)
Declare Sub Begin_g(byreg r16 As Byte)
Declare Sub Blendfunc(Byreg r16 As Byte , Byreg r17 As Byte)
Declare Sub Bitmaphandle(byreg R16 As Byte)
declare Sub Bitmaplayout(byreg R18 As byte , Byreg r21 As word , Byreg r16 As word)
declare Sub Bitmapsize(byreg R19 As Byte , Bystack R21 As Byte , Byreg R18 As Byte , Byreg R30 As word , Byreg r16 As word)
Declare Sub Bitmapsource(byreg R16 As Dword)
Declare Sub Bitmaptransform(byreg R16 As Dword,Byreg R20 as byte) 'pass A,B,C,D,E,F
Declare Sub Call_c(byreg  r16 As Word)
Declare Sub Cell(byreg r16 As Byte)
Declare Sub Colorrgb(byreg R18 As Byte , Byreg R17 As Byte , Byreg R16 As Byte)
Declare Sub ColorrgbDW(byreg R16 As Dword) 'RENAMED FROM COLORRGBX
Declare Sub Color_a(byreg r16 As Byte)
declare Sub Colormask(byreg R16 As Byte , Byreg r17 As Byte , Byreg r18 As Byte , Byreg r19 As Byte)
Declare Sub Clearcolora(byreg r16 As Byte)
Declare Sub ClearColorrgb(byreg R18 As Byte , Byreg R17 As Byte , Byreg R16 As Byte)
Declare Sub ClearcolorrgbDW(byreg R16 As Dword)        ' RENAMED FROM ClearcolorrgbX
Declare Sub Cleartag(byreg r16 As Byte)
Declare Sub Clear_b(byreg r16 As Byte , Byreg r17 As Byte , Byreg r18 As Byte)
Declare Sub Clearstencil(byreg r16 As Byte)
Declare Sub Display_e()
Declare Sub End_g()

Declare Sub Ft_cls(byreg r16 As Dword)
'--------------UNCONVERTED
Declare Sub Ft_boxrnd(byval X1 As Word , Byval Y1 As Word , Byval X2 As Word , Byval Y2 As Word , Byval R As Word , Byval C As Dword)
Declare Sub Ft_dot1(byval X As Word , Byval Y As Word , Byval S As Word , Byval C As Dword)
Declare Sub Ft_dot2(byval X As Word , Byval Y As Word , Byval R As Word , Byval W As Word , Byval C1 As Dword , Byval C2 As Dword)
Declare Sub Ft_triangle(byval X1 As Word , Byval Y1 As Word , Byval X2 As Word , Byval Y2 As Word , Byval X3 As Word , Byval Y3 As Word , Byval W As Word , Byval C As Dword )
Declare Sub Ft_box(byval X1 As Word , Byval Y1 As Word , Byval X2 As Word , Byval Y2 As Word , Byval W As Word , Byval C As Dword )
Declare Sub Ft_line(byval X1 As Word , Byval Y1 As Word , Byval X2 As Word , Byval Y2 As Word , Byval W As Word , Byval C As Dword )
Declare Sub Ft_circle(byval X As Integer , Byval Y As Integer , Byval R As Word , Byval W As Byte , Byval C As Dword )
'------------END UNCONVERTED---

Declare Sub Jump(byreg r16 As Word)
Declare Sub Linewidth(byreg r16 As Word)
Declare Sub Macro_r(byreg r16 As Byte)
Declare Sub Pointsize(byreg r16 As word)
Declare Sub Restorecontext()
Declare Sub Return_c()
Declare Sub Savecontext()
Declare Sub Stencilfunc(byreg  r18 As Byte , Byreg r17 As Byte , Byreg R16 As Byte)
Declare Sub Stencilmask(byreg r16 As Byte)
Declare Sub Stencilop(byreg r16 As Byte , Byreg r17 As Byte)
Declare Sub Scissorxy(byreg r18 As Word , Byreg r16 As Word)
Declare Sub Scissorsize(byreg r18 As Word , Byreg r16 As Word)
Declare Sub Tag(byreg r16 As Byte)
Declare Sub Tagmask(byreg r16 As Byte)
'Declare Sub Vertex2ii(byreg r20 As Word , Byreg r18 As Word , Byreg r17 As Byte , Byreg r16 As Byte)
Declare Sub Vertex2ii(bystack x As Word , Byreg r18 As Word , Byreg r17 As Byte , Byreg r16 As Byte)
Declare Sub Vertex2f(byreg r18 As word , Byreg r16 As word)

Declare Sub Cmd32n(byreg r16 As Dword)
Declare Sub Cmd32x(byreg r16 As Dword)

Declare Sub Cmdappend(bystack Ptr As Dword , Bystack Num As Dword)
Declare Sub Cmdbgcolor(byval Rgbcol As Dword)
Declare Sub Cmdbutton(bystack X As Integer , Bystack Y As Integer , Bystack W As Integer , Bystack H As Integer , Bystack Fontx As Integer , Bystack Options As Word , Byval S As String)
Declare Sub Cmdcalibrate()
Declare Sub Cmdcalibratex()
Declare Sub Cmdclock(bystack X As Integer , Bystack Y As Integer , Bystack R As Integer , Bystack Options As Word , Bystack H As Word , Bystack M As Word , Bystack S As Word , Bystack Ms As Word)
Declare Sub Cmdcoldstart()
Declare Sub Cmddial(bystack X As Integer , Bystack Y As Integer , Bystack R As Integer , Bystack Options As Word , Bystack Value As Word)
Declare Sub Cmddlstart()
Declare Sub Cmdfgcolor(byval Rgbcol As Dword)
Declare Sub Cmdgetmatrix(bystack A As Long , Bystack B As Long , Bystack C As Long , Bystack D As Long , Bystack E As Long , Bystack F As Long)
Declare Sub Cmdgetptr(bystack Result As Long)
Declare Sub Cmdgradcolor(byval Rgbcol As Dword)
Declare Sub Cmdgauge(bystack X As Integer , Bystack Y As Integer , Bystack R As Integer , Bystack Options As Word , Bystack Major As Word , Bystack Minor As Word , Bystack Value As Word , Bystack Range As Word)
Declare Sub Cmdgradient(bystack X0 As Integer , Bystack Y0 As Integer , Bystack Rgb0 As Dword , Bystack X1 As Integer , Bystack Y1 As Integer , Bystack Rgb1 As Dword)
Declare Sub Cmdinterrupt(bystack Ms As Dword)
Declare Sub Cmdinflatex(byval Ptr As Dword , Byref Varaddress As Word , Byval Count As Dword)
Declare Sub Cmdkeys(bystack X As Integer , Bystack Y As Integer , Bystack W As Integer , Bystack H As Integer , Bystack Fontx As Integer , Bystack Options As Word , Byval S As String)
Declare Sub Cmdlogo()
Declare Sub Cmdloadidentity()
Declare Sub Cmdloadimage(bystack Ptr As Dword , Bystack Options As Dword)
Declare Sub Cmdmemzero(bystack Ptr As Dword , Bystack Num As Dword)
Declare Sub Cmdmemcrc(bystack Ptr As Dword , Bystack Num As Dword , Bystack Result As Dword)
Declare Sub Cmdmemset(bystack Ptr As Dword , Bystack Value As Dword , Bystack Num As Dword)
Declare Sub Cmdmemcpy(bystack Dest As Dword , Bystack Src As Dword , Bystack Num As Dword)
Declare Sub Cmdmemwrite(bystack Ptr As Dword , Bystack Num As Dword)
Declare Sub Cmdnumber(bystack X As Integer , Bystack Y As Integer , Bystack Fontx As Integer , Bystack Options As Word , Bystack Num As Long)
Declare Sub Cmdprogress(bystack X As Integer , Bystack Y As Integer , Bystack W As Integer , Bystack H As Integer , Bystack Options As Word , Bystack Value As Word , Bystack Range As Word)
Declare Sub Cmdregread(bystack Ptr As Dword , Bystack Result As Dword)
Declare Sub Cmdrotate(bystack Ang As Long)
Declare Sub Cmdrotatea(byval Ang As Integer)
Declare Sub Cmdsetfont(bystack Font As Dword , Bystack Ptr As Dword)
Declare Sub Cmdstr(byval Strpacket As String * 80)
Declare Sub Cmdspinner(bystack X As Integer , Bystack Y As Integer , Bystack Style As Word , Bystack Scale As Word , Byval Message As String)
Declare Sub Cmdsnapshot(bystack Ptr As Dword)
Declare Sub Cmdscale(bystack Sx As Long , Bystack Sy As Long)
Declare Sub Cmdsketch(bystack X As Integer , Bystack Y As Integer , Bystack W As Word , Bystack H As Word , Bystack Ptr As Dword , Bystack Formatx As Word)
Declare Sub Cmdscreensaver() 'byval Ptr As Dword , Byval Num As Dword)
Declare Sub Cmdsetmatrix()
Declare Sub Cmdscrollbar(bystack X As Integer , Bystack Y As Integer , Bystack W As Integer , Bystack H As Integer , Bystack Options As Word , Bystack Value As Word , Bystack Size As Word , Bystack Range As Word)
Declare Sub Cmdslider(bystack X As Integer , Bystack Y As Integer , Bystack W As Integer , Bystack H As Integer , Bystack Options As Word , Bystack Value As Word , Bystack Range As Word)
Declare Sub Cmdstop()
Declare Sub Cmdswap()
Declare Sub Cmdtoggle(bystack X As Integer , Bystack Y As Integer , Bystack W As Integer , Bystack Fontx As Integer , Bystack Options As Word , Bystack State As Word , Byval S As String)
Declare Sub Cmdtext(bystack X As Integer , Bystack Y As Integer , Bystack Fontx As Integer , Bystack Options As Word , Byval S As String)
Declare Sub Cmdtrack(bystack X As Integer , Bystack Y As Integer , Bystack W As Integer , Bystack H As Integer , Bystack Tagx As Integer)
Declare Sub Cmdtranslate(bystack Tx As Long , Bystack Ty As Long)
Declare Sub Cmdtranslatep(bystack Tx As Integer , Bystack Ty As Integer)

Declare Sub Hostcommand(byreg r18 As Byte)

Declare Sub Wr32x(byreg r16 As Dword , Byreg r20 As Dword)
'Declare Sub Wr16(byreg r16 As Dword , Byreg r20 As Word)
'Declare Sub Wr8(byreg r16 As Dword , Byreg r20 As Byte)

Declare Sub Send32(byreg r16 As Dword , Byreg r20 As Dword)

Declare Sub Alignfifo(byreg r16 As Byte)
Declare Sub Align4 (Byref var as Dword)
Declare Sub Adr32(byreg r16 As Dword)
Declare Function Chipid() As Byte
Declare Sub Clearfifoptr()
Declare Sub Clearscreen()
Declare Sub Checkspace(byval Qty As Byte)
Declare Sub Chipsel(byreg r24 As Byte)
Declare Sub Config_ft800_display()
Declare Sub Dlswap()
Declare Sub Displaypage()
Declare Sub Endtransfer()
Declare Sub Endpage()
Declare Sub Executebuffercmds()
Declare function Ft800_init() as byte
Declare Sub Freespaceft(byreg r30 As Word)
Declare Function Ftfreespace() As Word
Declare Sub Getfree(byreg r30 As Word)
Declare Function Incrcmdoffset(byval Offset As Word , Byval Size As Word) As Word
Declare Sub Loadcmd(byreg r30 As Word , Byreg r16 As Dword)
Declare Function Measurefreq() As Dword
Declare Sub Powercycle(byreg r16 As Byte)
Declare Sub Play_sound(byval Soundx As Integer , Byval Volume As Byte)
Declare Sub Radiobutton(byval X As Integer , Byval Y As Integer , Byval Bgcolor As Dword , Byval Fgcolor As Dword , Byval Psize As Byte , Byval Tagx As Byte , Byval Opt As Byte)
Declare Sub Readtouchvariables()
Declare Sub Rdflash_wrft800(byval Ptr As Dword , Byref Varadr As Dword , Byval Count As Dword)
Declare Sub Rdmem_wrft800(byval Ptr As Dword , Byref Var As Dword , Byval Count As Dword)
Declare Sub Rdft800_wrmem(byval Ptr As Dword , Byref Var As Dword , Byval Count As Dword)
Declare Sub Starttransfer()
Declare Sub Swapscreen()
'Declare Sub Sintable
Declare Sub Tune
Declare Sub Touchcal()
Declare Sub Updatescreen()
Declare Sub Waitcmdfifoempty()
Declare Sub Writetouchvariables()

' Exclusive Variables for FT800_Functions.inc

' Map of the W32 Dword variable
' If W32 = &H11223344
' W32H = &H1122
' WB3  = &H11
' WB2  = &H22
' W32L = &H3344
' WB1  = &H33
' WB0  = &H44
' DataX(4) = &H11
' DataX(3) = &H22
' DataX(2) = &H33
' DataX(1) = &H44

Const StrSize = 80
Dim Datax(4) As Byte
Dim W32 As Dword At Datax(_base) Overlay
Dim W32h As Word At W32 + 2 Overlay
Dim W32l As Word At W32 + 0 Overlay
Dim Wb3 As Byte At W32 + 3 Overlay
Dim Wb2 As Byte At W32 + 2 Overlay
Dim Wb1 As Byte At W32 + 1 Overlay
Dim Wb0 As Byte At W32 + 0 Overlay
Dim Datas As String * strSize
Dim Datat(strSize) As Byte At Datas Overlay

Dim FtError As Byte
'FtError.0 = WaitCmdFifoEmpty Sub when Overflowed
'FtError.1 = WaitCmdFifoEmpty Sub when TimeOut
'FtError.2 = FreeSpaceFt Sub when OverFlowed
'FtError.3 = FreeSpaceFt Sub when TimeOut

Dim ftFifo_WritePtr As Word
Dim ftFifo_ReadPtr As Word
Dim ftFreeSpaceLeft As Integer
Dim ftAddrPtr As Dword
Dim ftStream As Byte
Dim TempDw As Dword
Dim Tb As Byte
Dim Tc As Byte
Dim Ti As Integer

' Touch Variables
Dim Touchid As Eram Byte
Dim Transmatrix(6) As Eram Dword
' End of FT800_Functions.inc variables