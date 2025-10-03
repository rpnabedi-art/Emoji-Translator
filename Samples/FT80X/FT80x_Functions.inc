$nocompile
' FT800_Functions.inc
'
' FT800 Library - Eve Version
' For Bascom 2.0.7.8 or greater

' See History FT800.txt
' Revision 7  24 May 2015


'------------------------------------------------------------------------------------------------------------
Sub Cmdloadidentity()
'------------------------------------------------------------------------------------------------------------
   ' Set the current Matrix to the Identity Matrix
    Cmd32 Cmd_loadidentity
End Sub                                                     ' CmdLoadIdentity

'------------------------------------------------------------------------------------------------------------
Sub Cmddlstart()
'------------------------------------------------------------------------------------------------------------
   ' Start a New Display List
   cmd32 cmd_DLstart
End Sub                                                     ' CmdDLStart

'------------------------------------------------------------------------------------------------------------
Sub Cmdswap()
'------------------------------------------------------------------------------------------------------------
   ' Swap the Current Display List
   cmd32 cmd_swap
End Sub                                                     ' CmdSwap

'------------------------------------------------------------------------------------------------------------
Sub Cmdcoldstart()
'------------------------------------------------------------------------------------------------------------
   ' Set Co-Processor Engine State to Default Values
   cmd32 cmd_coldstart
End Sub                                                     ' CmdColdStart

'------------------------------------------------------------------------------------------------------------
Sub Cmdsetmatrix()
'------------------------------------------------------------------------------------------------------------
   ' Write the current Matrix to the Display List
   cmd32 cmd_setmatrix
End Sub                                                     ' CmdSetMatrix

'------------------------------------------------------------------------------------------------------------
Sub Cmdlogo()
'------------------------------------------------------------------------------------------------------------
   ' Play FTDI Logo animation
   cmd32 cmd_logo
End Sub                                                     ' CmdLogo

'------------------------------------------------------------------------------------------------------------
Sub Cmdstop()
'------------------------------------------------------------------------------------------------------------
   ' Stop any Spinner, ScreenSaver or Sketch
   cmd32 cmd_stop
End Sub                                                     ' CmdStop

'------------------------------------------------------------------------------------------------------------
Sub RestoreContext()
'------------------------------------------------------------------------------------------------------------
   ' Restore the current Graphics Context from the Context Stack
   cmd32 _restorecontext()
End Sub

'------------------------------------------------------------------------------------------------------------
Sub SaveContext()
'------------------------------------------------------------------------------------------------------------
   ' Restore the current Graphics Context from the Context Stack
   cmd32 _savecontext()
End Sub

'------------------------------------------------------------------------------------------------------------
Sub Return_C()
'------------------------------------------------------------------------------------------------------------
   ' Return from previous CALL Command
   cmd32 _return_c()
End Sub

'------------------------------------------------------------------------------------------------------------
Sub End_g()
'------------------------------------------------------------------------------------------------------------
   ' End Drawing of Graphics Primitive
   cmd32 _end_g()
End Sub                                                     ' Endx

'------------------------------------------------------------------------------------------------------------
Sub Display_E()
'------------------------------------------------------------------------------------------------------------
   ' End the Display list. FT800 will ignore all the Commands following this Command
   cmd32 _display_e()
End Sub                                                     ' Displayx


Sub ClearColorA(Byreg r16 As Byte)
    cmd32 _clearColorA(R16)
End Sub

Sub ClearStencil(Byreg r16 As Byte)
   ' Specify Clear value for the Stencil Buffer
   cmd32 _clearstencil(r16)
End Sub                                                     ' ClearStencil

'-----------------------------------------------------------
Sub ClearTag(Byreg r16 As Byte)
   ' Specify Clear value for Tag Buffer
   cmd32 _cleartag(r16)
End Sub                                                     ' ClearTag

Sub StencilMask(Byreg r16 As Byte)
   ' Control the writing of individial bits in the Stencil planes

   cmd32 _stencilmask(r16)
End Sub

Sub Tag(Byreg r16 As Byte)
   ' Attach the 'Tag' value for the following graphics objects drawn on the Screen.
   cmd32 _tag(r16)
End Sub

Sub Color_A(Byreg r16 As Byte)
   ' Set the current colour Alpha
   cmd32 _color_a(r16)
End Sub                                                     ' ColorA


Sub Begin_G(Byreg r16 As Byte)
   cmd32 _begin_g(r16)
End Sub

Sub Cell(Byreg r16 As Byte)
   ' Specify the Bitmap Cell number for the Vertex2F Command
   ' range 0-&H7F
   cmd32 _cell(R16)
End Sub

Sub BitmapHandle(Byreg r16 As Byte)
    cmd32 _bitmaphandle(R16)
End Sub


Sub TagMask(Byreg r16 As Byte)
   ' Control the writting of the 'Tag' buffer
  'should be 0 or 1
   cmd32 _tagmask(r16)
End Sub


Sub BlendFunc(Byreg r16 As Byte , Byreg r17 As Byte)
   ' Specify Pixel Arithmetic
   cmd32 _blendfunc(R16,r17 )
End Sub                                                     ' BlendFunc


Sub ColorRGBdw(Byreg r16 As Dword)
    cmd32 _colorRGBdw(r16)
End Sub

Sub ClearColorRGBDW(Byreg r16 As Dword)
    cmd32 _clearcolorrgbdw(r16)
End Sub

Sub BitmapTransform(Byreg r16 As Dword,byreg R20 as byte)
   ' Specify the A Coefficient of the Bitmap Transform Matrix
   ' The SECOND param should be A,B,C,D,E or F for the transform matrix
   ' This param should be upper case
   cmd32 _BitmapTransform(r16,r20)
End Sub                                                     ' BitmapTransform


Sub BitmapSource(Byreg r16 As Dword)
   ' Specify the Source Address of Bitmap Data in FT800 Graphics Memory RAM_G
   cmd32 _bitmapsource(R16)
End Sub


Sub Jump(Byreg r16 As Word)
   ' Execute Commands at another location in the Display List

   cmd32 _jump(r16)
End Sub

Sub Call_C(Byreg R16 As Word)

   ' Execute a sequence of Commands at another location in the Display List
   CMD32 _call_c(R16)
End Sub                                                     ' Callx




'------------------------------------------------------------------------------------------------------------
function Ft800_init() as byte
'------------------------------------------------------------------------------------------------------------

   Powercycle True
   Hostcommand Ft_gpu_active
   Waitms 20

#if FT_PlatForm=Gameduino2
   Hostcommand Ft_gpu_internal_osc                          ' Set the clk to internal clock
#else
   Hostcommand Ft_gpu_external_osc                          ' Set the clk to external clock
#endif
   Waitms 10

   Hostcommand Ft_gpu_pll_48m                               ' Switch PLL output to 48MHz
   Waitms 10
   Hostcommand Ft_gpu_core_reset                            ' Do a Core reset

  ' Access address 0 to wake up the FT800
   Waitms 20

   ' Read Register ID to check if FT800 is ready
   If Chipid() = 1 Then
      Powercycle False
      Ft800_init = 1
      Exit Function
   Else
      Config_ft800_display
   End If


  ' Don't run any FT800 routines before StartTransfer, make sure they all run after this line
  ' Starttransfer

#if FT_Lcdcal = 1
   'Screen calibration
   'Let a touch anywhere during powerup be a request for screen calibration
   If Rd16(reg_touch_raw_xy) = &HFFFF Then                  ' No touch, but check that params are intact
      Touchcal
   Else
      Do
      Loop Until Rd16(reg_touch_raw_xy) = &HFFFF            ' Wait for touch release
      Cmdcalibratex                                         ' then calibrate
   End If
#endif

Ft800_init = 0


End Function                                                     ' FT800_Init

'------------------------------------------------------------------------------------------------------------
Sub Config_ft800_display
'------------------------------------------------------------------------------------------------------------

   Local Duty As Byte

   Clearfifoptr

#if FT_PlatForm=Gameduino2
   Tune
#endif

   Wr8 Reg_PCLK, Zero                                       ' Set PCLK to zero - don't clock the LCD until later
   Wr8 Reg_PWM_Duty, Zero                                   ' Turn off backlight

   Wr16 Reg_HCycle,  Ft_DispHCycle                          ' total number of clocks per line
   Wr16 Reg_HOffset, Ft_DispHOffset                         ' start of active line
   Wr16 Reg_HSync0,  Ft_dispHSync0                          ' start of horizontal sync pulse
   Wr16 Reg_HSync1,  Ft_dispHSync1                          ' end of horizontal sync pulse
   Wr16 Reg_VCycle,  Ft_dispVCycle                          ' total number of lines per screen, incl pre/post
   Wr16 Reg_VOffset, Ft_dispVOffset                         ' start of active screen
   Wr16 Reg_VSync0,  Ft_dispVSync0                          ' start of vertical sync pulse
   Wr16 Reg_VSync1,  Ft_DispVSync1                          ' end of vertical sync pulse
   Wr8  Reg_Swizzle, Ft_DispSwizzle                         ' FT800 output to LCD - pin order
   Wr8  Reg_PCLK_Pol,Ft_DispPCLKPol                         ' LCD data is clocked in on this PCLK edge

   Wr8 Reg_PCLK , Ft_DisppCLK                               ' Now start clocking data to the LCD panel

   Wr16 Reg_HSize,   Ft_DispWidth                           ' active display width
   Wr16 Reg_VSize,   Ft_DispHeight                          ' active display height

#if FT_Rotatedisplay = 1
   Wr8 Reg_Rotate , 1
#endif

   Wr8 Reg_GPIO_Dir , &H83
   Wr8 Reg_GPIO , &H83

   Wr16 Reg_Touch_rzThresh , 1200

   Wr32 Ram_DL + 0,  &H02FFFFFF
   Wr32 Ram_DL + 4,  &H26000007
   Wr32 Ram_DL + 8,  &H00000000
   Wr32 Ram_DL + 12, Cmd_memset                            ' Erases Sreen Area
   Wr32 Ram_DL + 16, &H00000000                            ' ptr
   Wr32 Ram_DL + 20, &H00000000                            ' value
   Wr32 Ram_DL + 24, &H00040000                            ' number of bytes
   Wr8 Reg_DLswap,   DLSwap_Frame

   For Duty = 1 To 127
      Wr16 Reg_PWM_Duty , Duty                              ' Turn on backlight - ramp up slowly to full brighness
      Waitms 2
   Next

End Sub                                                     ' Config_FT800_Display

'------------------------------------------------------------------------------------------------------------
Sub HostCommand(Byreg r18 As Byte)
   '-----------------------------------------------------------
   !jmp _ft_hostcmd
End Sub                                                       ' HostCommand


Sub Wr32x(Byreg r16 As Dword , Byreg r20 As Dword)
   '-----------------------------------------------------------
   !jmp _ft_wr32
End Sub                                                     ' Wr32


'------------------------------------------------------------------------------------------------------------
Sub Send32(byreg r16 As Dword , Byreg r20 As Dword)
'------------------------------------------------------------------------------------------------------------
    !jmp _ftsend32
End Sub                                                     ' Send32

'------------------------------------------------------------------------------------------------------------
Sub Adr32(byreg r16 As Dword)
'------------------------------------------------------------------------------------------------------------
!  jmp _ftadr32
End Sub                                                     ' Adr32


'------------------------------------------------------------------------------------------------------------
Sub Cmd32n(byreg r16 As Dword)
'------------------------------------------------------------------------------------------------------------
!   jmp _cmd32

End Sub                                                     ' Cmd32

'------------------------------------------------------------------------------------------------------------
Sub Cmd32x(byreg r16 As Dword)
'------------------------------------------------------------------------------------------------------------

  !jmp _cmd32_rev  ; reverse send order

End Sub                                                     ' Cmd32X


'------------------------------------------------------------------------------------------------------------
Sub Colorrgb(byreg R18 As Byte , Byreg R17 As Byte , Byreg R16 As Byte)
   Cmd32 _colorrgb(r18 , r17 , r16)
End Sub                                                     ' ColorRGB


Sub ClearColorRGB(Byreg r18 As Byte , Byreg r17 As Byte , Byreg r16 As Byte)
    cmd32 _clearcolorrgb(r18,r17,r16)
End Sub                                                     ' ClearColorRGB



'------------------------------------------------------------------------------------------------------------
Sub Clear_b(byreg r16 As Byte , Byreg r17 As Byte , Byreg r18 As Byte)
'------------------------------------------------------------------------------------------------------------
   Cmd32 _clear_b(r16 , r17 , r18)

End Sub                                                     ' Clear_B


'------------------------------------------------------------------------------------------------------------
Sub Vertex2ii(bystack x as Word , Byreg r18 As Word , Byreg r17 As Byte , Byreg r16 As Byte)
'------------------------------------------------------------------------------------------------------------
   !ld r21,y+
   !ld r20,y+
   Cmd32 _vertex2ii(___WTMPB , r18 ,r17 ,r16)
End Sub                                                     ' Vertex2II


'------------------------------------------------------------------------------------------------------------
Sub Pointsize(byreg r16 As word)
'------------------------------------------------------------------------------------------------------------
   Cmd32 _pointsize(r16)
End Sub                                                     ' PointSize


'------------------------------------------------------------------------------------------------------------
Sub Vertex2f(byreg r18 As word , Byreg r16 As word)
'------------------------------------------------------------------------------------------------------------

   Cmd32 _vertex2f(r18 , r16)

End Sub                                                     ' Vertex2f



'------------------------------------------------------------------------------------------------------------
Sub Linewidth(byreg r16 As Word)
'------------------------------------------------------------------------------------------------------------

   Cmd32 _linewidth(r16)

End Sub                                                     ' LineWidth

                                              ' _LineWidth

'------------------------------------------------------------------------------------------------------------
Sub Macro_r(byreg r16 As Byte) 'make mod to INC header file to use R20 as well ##############################
'------------------------------------------------------------------------------------------------------------
   ' Execute a Single Command from a Macro Register
   ' passed value should be 0 or 1 only !!!
   cmd32 _macro_r(r16)
End Sub                                                     ' Macro_R


'------------------------------------------------------------------------------------------------------------
Sub Alphafunc(byreg R16 As Byte , Byreg r17 As Byte)
    cmd32 _alphafunc(R16,R17)
End Sub




'------------------------------------------------------------------------------------------------------------
Sub Colormask(byreg R16 As Byte , Byreg r17 As Byte , Byreg r18 As Byte , Byreg r19 As Byte)
'------------------------------------------------------------------------------------------------------------
   Cmd32 _colormask(r16 , r17 ,r18 , r19)
End Sub                                                     ' ColorMask



'------------------------------------------------------------------------------------------------------------
Sub Bitmapsize(byreg R19 As Byte , Bystack R21 As Byte , Byreg R18 As Byte , _
               Byreg R30 As word , Byreg r16 As word)


!  ld r21,y+
   Cmd32 _bitmapsize(r19 , r21 , r18 ,r30 ,r16)
End Sub                                                     ' BitmapSize


'------------------------------------------------------------------------------------------------------------
Sub Bitmaplayout(byreg R18 As byte , Byreg r21 As word , Byreg r16 As word)
'------------------------------------------------------------------------------------------------------------
   Cmd32 _bitmaplayout(R18 , R21 ,R16)
End Sub                                                     ' BitmapLayout


'------------------------------------------------------------------------------------------------------------
Sub Scissorxy(byreg r18 As Word , Byreg r16 As Word)
'------------------------------------------------------------------------------------------------------------

   Cmd32 _scissorxy(r18 ,r16)

End Sub                                                     ' ScissorXY


'------------------------------------------------------------------------------------------------------------
Sub Scissorsize(byreg r18  As Word , Byreg r16 As Word)
'------------------------------------------------------------------------------------------------------------

   Cmd32 _scissorsize(r18 ,r16)

End Sub                                                     ' ScissorSize


'------------------------------------------------------------------------------------------------------------
Sub Stencilfunc(byreg  r18 As Byte , Byreg r17 As Byte , Byreg R16 As Byte)
'------------------------------------------------------------------------------------------------------------
  'r18 range 0-15
   Cmd32 _stencilfunc(r18 , R17 , r16)
End Sub                                                     ' StencilFunc


'------------------------------------------------------------------------------------------------------------
Sub Stencilop(byreg r16 As Byte , Byreg r17 As Byte)
'------------------------------------------------------------------------------------------------------------

   Cmd32 _stencilop(r16 ,r17)

End Sub                                                     ' StencilOp


'------------------------------------------------------------------------------------------------------------
' Utils and various Subs/Functions

'------------------------------------------------------------------------------------------------------------
Sub Cmdscreensaver() 'byval Ptr As Dword , Byval Num As Dword)
'------------------------------------------------------------------------------------------------------------

   ' After the ScreenSaver Command, the Co-processor engine continuously updates
   ' REG_MACRO_0 with Vertex2F with varying (x,y) coordinates. With an appropriate
   ' Display List this causes a bitmap to move around the screen without any MCU work.
   ' Command 'CMD_STOP' stops the update process.

   Cmd32 Cmd_screensaver
 '   Cmd32 Ptr                                                ' Starting Address of Memory Block
 '  Cmd32 Num                                                ' Number of Bytes in the Memory Block

End Sub                                                     ' CmdScreenSaver

'------------------------------------------------------------------------------------------------------------
Sub Cmdnumber(bystack X As Integer , Bystack Y As Integer , Bystack Fontx As Integer , Bystack Options As Word , Bystack Num As Long)
'------------------------------------------------------------------------------------------------------------
   ' Draws a Decimal Number
   ' No Justification = 0
   ' OPT_CENTERX
   ' OPT_CENTERY
   ' OPT_CENTER
   ' OPT_RIGHTX
   ' OPT_SIGNED

   Cmd32 Cmd_number
   cmdftstack 12
End Sub                                                     ' CmdNumber



'------------------------------------------------------------------------------------------------------------
Sub Cmdbutton(bystack X As Integer , Bystack Y As Integer , Bystack W As Integer , Bystack H As Integer , Bystack Fontx As Integer , Bystack Options As Word , Byval S As String)
'------------------------------------------------------------------------------------------------------------
   ' Draws Keyboard like buttons

   ' Options  Are
   ' OPT_3D = 0
   ' OPT_FLAT

   If Asc(S) = 0 Or Asc(S) > 127 then
!     Adiw yl,12
      Exit Sub
   End If

   Cmd32 Cmd_button
   cmdftstack 12,2
   Cmdstr S
!   adiw yl,12
End Sub                                                     ' CmdButton

'------------------------------------------------------------------------------------------------------------
Sub Cmdclock(bystack X As Integer , Bystack Y As Integer , Bystack R As Integer , Bystack Options As Word , Bystack H As Word , Bystack M As Word , Bystack S As Word , Bystack Ms As Word)
'------------------------------------------------------------------------------------------------------------

   ' Draws a Round Analog Clock

   ' Options  Are
   ' OPT_3D = 0
   ' OPT_FLAT
   ' OPT_NOBACK
   ' OPT_NOTICKS
   ' OPT_NOSECS
   ' OPT_NOHANDS
   ' OPT_NOHM

   Cmd32 Cmd_clock
   cmdftstack 16
End Sub                                                     ' CmdClock

'------------------------------------------------------------------------------------------------------------
Sub Cmdfgcolor(byval Rgbcol As Dword)
'------------------------------------------------------------------------------------------------------------

   ' Set ForeGround Colour
   Cmd32 Cmd_fgcolor
   Cmd32 Rgbcol                                             ' Send the above packet
End Sub                                                     ' CmdFGColor

'------------------------------------------------------------------------------------------------------------
Sub Cmdbgcolor(byval Rgbcol As Dword)
'------------------------------------------------------------------------------------------------------------

   ' Set BackGround Colour

   Cmd32 Cmd_bgcolor
   Cmd32 Rgbcol                                             ' Send the above packet
End Sub                                                     ' CmdBGColor

'------------------------------------------------------------------------------------------------------------
Sub Cmdgradcolor(byval Rgbcol As Dword)
'------------------------------------------------------------------------------------------------------------
   ' Used for 3D Button highlight colour

   Cmd32 Cmd_gradcolor
   Cmd32 Rgbcol                                             ' Send the above packet

End Sub                                                     ' CmdGradColor

'------------------------------------------------------------------------------------------------------------
Sub Cmdtext(bystack X As Integer , Bystack Y As Integer , Bystack Fontx As Integer , Bystack Options As Word , Byval S As String)
'------------------------------------------------------------------------------------------------------------
   ' Draws Text
   ' No Justification = 0
   ' OPT_CENTERX
   ' OPT_CENTERY
   ' OPT_CENTER
   ' OPT_RIGHTX

   If Asc(S) = 0 Or Asc(S) > 127 then
!     Adiw yl,8
      Exit Sub
   End If

   Cmd32 Cmd_text
   cmdftstack 8,2
   Cmdstr S
!   adiw yl,8
End Sub                                                     ' Cmd_Text

'------------------------------------------------------------------------------------------------------------
Sub Cmdgauge(bystack X As Integer , Bystack Y As Integer , Bystack R As Integer , Bystack Options As Word , Bystack Major As Word , Bystack Minor As Word , Bystack Value As Word , Bystack Range As Word)
'------------------------------------------------------------------------------------------------------------
   ' Draws a Analog Gauge

   ' Options  Are
   ' OPT_3D = 0
   ' OPT_FLAT
   ' OPT_NOBACK
   ' OPT_NOTICKS
   ' OPT_NOPOINTER

   Cmd32 Cmd_gauge
   cmdftstack 16
End Sub

'------------------------------------------------------------------------------------------------------------
Sub Cmdgradient(bystack X0 As Integer , Bystack Y0 As Integer , Bystack Rgb0 As Dword , Bystack X1 As Integer , Bystack Y1 As Integer , Bystack Rgb1 As Dword)
'------------------------------------------------------------------------------------------------------------
   ' Draw a smooth color gradient

   Cmd32 Cmd_gradient
   cmdftstack 16

End Sub                                                     ' CmdGradient

'------------------------------------------------------------------------------------------------------------
Sub Cmdkeys(bystack X As Integer , Bystack Y As Integer , Bystack W As Integer , Bystack H As Integer , Bystack Fontx As Integer , Bystack Options As Word , Byval S As String)
'------------------------------------------------------------------------------------------------------------
   ' Draws a Row of Keys (like keyboard keys)

   ' Options  Are
   ' OPT_3D = 0
   ' OPT_FLAT
   ' OPT_CENTRE

   If Asc(S) = 0 Or Asc(S) > 127 then
!     adiw yl,12
      Exit Sub
   End If

   Cmd32 Cmd_keys
   cmdftstack 12,2
   Cmdstr S
!   adiw yl,12
End Sub                                                     ' CmdKeys

'------------------------------------------------------------------------------------------------------------
Sub Cmdprogress(bystack X As Integer , Bystack Y As Integer , Bystack W As Integer , Bystack H As Integer , Bystack Options As Word , Bystack Value As Word , Bystack Range As Word)
'------------------------------------------------------------------------------------------------------------

   ' Draws a Progress Bar

   ' Options  Are
   ' OPT_3D = 0
   ' OPT_FLAT

   Cmd32 Cmd_progress
   cmdftstack 14
   Cmd16 &H0000

   ' was a total of 18 bytes, to align with 4byte boundary it had to be offset of 20
End Sub                                                     ' CmdProgress

'------------------------------------------------------------------------------------------------------------
Sub Cmdscrollbar(bystack X As Integer , Bystack Y As Integer , Bystack W As Integer , Bystack H As Integer , Bystack Options As Word , Bystack Value As Word , Bystack Size As Word , Bystack Range As Word)
'------------------------------------------------------------------------------------------------------------

   ' Draws a Scroll Bar

   ' Options  Are
   ' OPT_3D = 0
   ' OPT_FLAT

   Cmd32 Cmd_scrollbar
   cmdftstack 16
End Sub                                                     ' CmdScrollBar

'------------------------------------------------------------------------------------------------------------
Sub Cmdslider(bystack X As Integer , Bystack Y As Integer , Bystack W As Integer , Bystack H As Integer , Bystack Options As Word , Bystack Value As Word , Bystack Range As Word)
'------------------------------------------------------------------------------------------------------------

   ' Draws a Slider

   ' Options  Are
   ' OPT_3D = 0
   ' OPT_FLAT

   Cmd32 Cmd_slider
   cmdftstack 14
   Cmd16 &H0000

   ' was a total of 18 bytes, to align with 4byte boundary it had to be offset of 20

End Sub                                                     ' CmdSlider

'------------------------------------------------------------------------------------------------------------
Sub Cmddial(bystack X As Integer , Bystack Y As Integer , Bystack R As Integer , Bystack Options As Word , Bystack Value As Word)
'------------------------------------------------------------------------------------------------------------

   ' Draws a Slider

   ' Options  Are
   ' OPT_3D = 0
   ' OPT_FLAT

   Cmd32 Cmd_dial
   cmdftstack 10
   Cmd16 &H0000
   ' was a total of 14 bytes, to align with 4byte boundary it had to be offset of 16

End Sub                                                     ' CmdDial

'------------------------------------------------------------------------------------------------------------
Sub Cmdtoggle(bystack X As Integer , Bystack Y As Integer , Bystack W As Integer , Bystack Fontx As Integer , Bystack Options As Word , Bystack State As Word , Byval S As String)
'------------------------------------------------------------------------------------------------------------
   ' Draws a Toggle Switch
   ' use the word 'gap' between the 2 states of the Switch state eg: "ON"+ gap +"OFF"

   ' Options  Are
   ' OPT_3D = 0
   ' OPT_FLAT
   ' OPT_CENTRE

   If Asc(S) = 0 then
!     adiw yl,12
      Exit Sub
   End If

   Cmd32 Cmd_toggle
   cmdftstack 12,2
   Cmdstr S
 !  adiw yl,12
End Sub                                                     ' CmdToggle

'------------------------------------------------------------------------------------------------------------
Sub Cmdscale(bystack Sx As Long , Bystack Sy As Long)
'------------------------------------------------------------------------------------------------------------
   ' Apply a Scale to the current Matrix
   ' Input is if 2X Scale is required multiply 2 x 65536

   Cmd32 Cmd_scale
   cmdftstack 8
End Sub                                                     ' CmdScale

'------------------------------------------------------------------------------------------------------------
Sub Cmdrotate(bystack Ang As Long)
'------------------------------------------------------------------------------------------------------------

   ' Apply a Rotation to the current Matrix
   ' Input is 1/65536 of a Circle

   Cmd32 Cmd_rotate
   cmdftstack 4
End Sub                                                     ' CmdRotate

'------------------------------------------------------------------------------------------------------------
Sub Cmdrotatea(byval Ang As Integer)
'------------------------------------------------------------------------------------------------------------

   ' Apply a Rotation to the current Matrix
   ' Input is 360 degree Angle

   ' Divide by 360 is equal to multiply by 182 followed by division of 65536
   ' The division is however unnecessary as it cancels with the upscaling by the same amount
   ' This method will allow angles from -11800 to +11800 degrees at 1 deg resolution

   ' NOT USED
   ' TempDw = a * 65536
   ' TempDw = TempDw / 360

   Cmd32 Cmd_rotate
   Cmd32 Ang * 182                                          ' Send the above packet

End Sub                                                     ' CmdRotateA

'------------------------------------------------------------------------------------------------------------
Sub Cmdtranslate(bystack Tx As Long , Bystack Ty As Long)
'------------------------------------------------------------------------------------------------------------

   ' Apply a Translation to the current Matrix

   Cmd32 Cmd_translate
   cmdftstack 8
End Sub                                                     ' CmdTranslate

'------------------------------------------------------------------------------------------------------------
Sub Cmdtranslatep(bystack Tx As Integer , Bystack Ty As Integer)
'------------------------------------------------------------------------------------------------------------
   ' Apply a Translation to the current Matrix
   ' Input is in Pixels
   ' To Convert to Pixels you Multiply it by 65536

   ' Using Overlay variables, W32, W32H and W32L for multiplication

   Cmd32 Cmd_translate
   cmd16 0
   !ld r16,y+3
   !ld r17,y+2
   cmd16 ___wtmpa
   'cmdftstack 2
   cmd16 0
   'cmdftstack 2
   !ld r16,y+1
   !ld r17,y+0
   cmd16 ___wtmpa
   !adiw r28,4
End Sub                                                     ' CmdTranslateP

'------------------------------------------------------------------------------------------------------------
Sub Cmdgetmatrix(bystack A As Long , Bystack B As Long , Bystack C As Long , Bystack D As Long , Bystack E As Long , Bystack F As Long)
'------------------------------------------------------------------------------------------------------------

   ' Retrieves the current Matrix coefficients

   Cmd32 Cmd_getmatrix
   cmdftstack 24
End Sub                                                     ' CmdGetMatrix

'------------------------------------------------------------------------------------------------------------
Sub Cmdinterrupt(bystack Ms As Dword)
'------------------------------------------------------------------------------------------------------------

   ' Trigger Interrupt 'Int_CmdFlag'

   Cmd32 Cmd_interrupt
   cmdftstack 4
End Sub                                                     ' CmdInterrupt

'------------------------------------------------------------------------------------------------------------
Sub Cmdappend(bystack Ptr As Dword , Bystack Num As Dword)
'------------------------------------------------------------------------------------------------------------

   ' Append Memory to Display List
   ' Note: 'num' must be in multiples of 4

   Cmd32 Cmd_append
   cmdftstack 8
End Sub                                                     ' CmdAppend

'------------------------------------------------------------------------------------------------------------
Sub Cmdregread(bystack Ptr As Dword , Bystack Result As Dword)
'------------------------------------------------------------------------------------------------------------

   ' Read a Register value

   Cmd32 Cmd_regread
   cmdftstack 8
End Sub                                                     ' CmdRegRead

'------------------------------------------------------------------------------------------------------------
Sub Cmdmemwrite(bystack Ptr As Dword , Bystack Num As Dword)
'------------------------------------------------------------------------------------------------------------

   ' Writes Bytes into Memory

   Cmd32 Cmd_memwrite
   cmdftstack 8
End Sub                                                     ' CmdMemWrite

'------------------------------------------------------------------------------------------------------------
Sub Cmdloadimage(bystack Ptr As Dword , Bystack Options As Dword)
'------------------------------------------------------------------------------------------------------------
   ' Load a JPEG image
   ' options =
   ' Opt_RGB565
   ' Opt_Mono
   ' Opt_NoDl

   Cmd32 Cmd_loadimage
   cmdftstack 8
End Sub                                                     ' CmdLoadImage

'------------------------------------------------------------------------------------------------------------
Sub Cmdgetptr(bystack Result As Long)
'------------------------------------------------------------------------------------------------------------

   ' Write the current Matrix to the Display List

   Cmd32 Cmd_getptr
   cmdftstack 4
End Sub                                                     ' CmdGetPtr

'------------------------------------------------------------------------------------------------------------
Sub Cmdmemcrc(bystack Ptr As Dword , Bystack Num As Dword , Bystack Result As Dword)
'------------------------------------------------------------------------------------------------------------

   ' Compute a CRC32 for Memory

   Cmd32 Cmd_memcrc
   cmdftstack 12

End Sub                                                     ' CmdMemCRC

'------------------------------------------------------------------------------------------------------------
Sub Cmdmemzero(bystack Ptr As Dword , Bystack Num As Dword)
'------------------------------------------------------------------------------------------------------------

   ' Write Zero to a Block of Memory

   Cmd32 Cmd_memzero
   cmdftstack 8
End Sub                                                     ' CmdMemZero

'------------------------------------------------------------------------------------------------------------
Sub Cmdmemset(bystack Ptr As Dword , Bystack Value As Dword , Bystack Num As Dword)
'------------------------------------------------------------------------------------------------------------

   ' Fill Memory with a Byte value

   Cmd32 Cmd_memset
   cmdftstack 12
End Sub                                                     ' CmdMemSet

'------------------------------------------------------------------------------------------------------------
Sub Cmdmemcpy(bystack Dest As Dword , Bystack Src As Dword , Bystack Num As Dword)
'------------------------------------------------------------------------------------------------------------

   ' Copy a Block of Memory

   Cmd32 Cmd_memcpy
   cmdftstack 12

   ' WaitCmdfifoempty => Page 160 says to check complettion of Cmd_MemCpy you check it
   ' Reg_Cmd_Read = Reg_Cmd_Write, do we add it here or not worry about it?

End Sub                                                     ' CmdMemCpy

'------------------------------------------------------------------------------------------------------------
Sub Cmdcalibrate()
'------------------------------------------------------------------------------------------------------------
   ' Execute the Touch Screen Calibration Routine

   Cmd32 Cmd_calibrate
   Cmd32 &H00000000

End Sub                                                     ' CmdCalibrate

'------------------------------------------------------------------------------------------------------------
Sub Cmdspinner(bystack X As Integer , Bystack Y As Integer , Bystack Style As Word , Bystack Scale As Word , Byval Message As String)
'------------------------------------------------------------------------------------------------------------
   ' Start an Animated Spinner
   ' Styles = 0 to 3 ' see page 222 of FT800 Programmer Manual
   If Message <> "" Then
      Cmdtext X , Y -50 , 27 , Opt_center , Message
   End If

   Cmd32 Cmd_spinner
   cmdftstack 8,2
!   adiw yl,8
End Sub                                                     ' CmdSpinner

#IF FT_CHIP=800
'------------------------------------------------------------------------------------------------------------
Sub Cmdsketch(bystack X As Integer , Bystack Y As Integer , Bystack W As Word , Bystack H As Word , Bystack Ptr As Dword , Bystack Formatx As Word)
'------------------------------------------------------------------------------------------------------------
   ' Start a Continuous Sketch Update

   Cmd32 Cmd_sketch
   cmdftstack 14
   Cmd16 &H0000                                             ' was 18 bytes, added 2 bytes for padding to make it divisible by 4

End Sub                                                     ' CmdSketch
#ELSE
Sub Cmdsketch(bystack X As Integer , Bystack Y As Integer , Bystack W As Word , Bystack H As Word , Bystack Ptr As Dword , Bystack Formatx As Word, Bystack Freq As Word)
'------------------------------------------------------------------------------------------------------------
   ' Start a Continuous Sketch Update
   Cmd32 Cmd_sketch
   cmdftstack 16
End Sub                                                     ' CmdSketch
#ENDIF

'------------------------------------------------------------------------------------------------------------
Sub Cmdsetfont(bystack Font As Dword , Bystack Ptr As Dword)
'------------------------------------------------------------------------------------------------------------

   ' Setup a Custom Font
   ' CMD_SETFONT is used to register one custom defined Bitmap font
   ' into the FT800 Co-Processor Engine.

   Cmd32 Cmd_setfont
   cmdftstack 8
End Sub                                                     ' CmdSetFont

'------------------------------------------------------------------------------------------------------------
Sub Cmdtrack(bystack X As Integer , Bystack Y As Integer , Bystack W As Integer , Bystack H As Integer , Bystack Tagx As Integer)
'------------------------------------------------------------------------------------------------------------
   ' Tracks Touches for a Graphic Object

   Cmd32 Cmd_track
   cmdftstack 10
   Cmd16 &H0000                                             ' was 14 bytes, added 2 bytes to make 16 to make it divisible by 4

End Sub                                                     ' CmdTrack

'------------------------------------------------------------------------------------------------------------
Sub Cmdsnapshot(bystack Ptr As Dword)
'------------------------------------------------------------------------------------------------------------
   ' Takes a Snapshot of the current Screen

   Cmd32 Cmd_snapshot
   cmdftstack 4
End Sub                                                     ' CmdSnapShot


'------------------------------------------------------------------------------------------------------------
Sub Cmdcalibratex
'------------------------------------------------------------------------------------------------------------
   ' Execute the Touch Screen Calibration Routine
   ' This is all in one version displaying the prompts on the screen

   Cmddlstart
   Clearscreen                                              ' CLS
   Cmdfgcolor Black
   Cmdbgcolor Blue
   Colorrgbdw Green
   Cmdtext Ft_dispwidth / 2 , 80 , 24 , Opt_center , "Tap into the center of each"
   Cmdtext Ft_dispwidth / 2 ,160 , 24 , Opt_center , "dot as accurate as possible"

   Cmdcalibrate

   'Waitcmdfifoempty
   UpdateScreen

   ' Save TOUCH variables to EEPROM
   Writetouchvariables

End Sub                                                     ' CmdCalibratex

'------------------------------------------------------------------------------------------------------------
Sub Cmdinflatex(byval Ptr As Dword , Byref Varaddress As Word , Byval Count As Dword)
'------------------------------------------------------------------------------------------------------------

   Local Length As Dword

   Cmd32 Cmd_inflate
   Cmd32 Ptr

   For Length = 1 To Count
      Tb = Cpeek(varaddress)
      Cmd8 Tb
      Incr Varaddress
   Next

   Alignfifo Count

End Sub                                                     ' CmdInflatex

'------------------------------------------------------------------------------------------------------------
Sub Dlswap()
'------------------------------------------------------------------------------------------------------------
   ' API to check the status of previous DLSWAP and perform DLSWAP of new DL
   ' Check for the status of previous DLSWAP and if still not done wait for few ms and check again

   Local Swap_done As Byte

   ' Perform a new DL swap
   Wr8 Reg_dlswap , Dlswap_frame

   ' Wait till the swap is done
   While Swap_done > 0
      Swap_done = Rd8(reg_dlswap)
      If Dlswap_done <> Swap_done Then
         Waitms 10
      End If
   Wend

End Sub                                                     ' Dlswap

'------------------------------------------------------------------------------------------------------------
Sub Endpage()
'------------------------------------------------------------------------------------------------------------

   Display_e
   Cmdswap
   Waitcmdfifoempty
End Sub                                                     ' EndPage

'------------------------------------------------------------------------------------------------------------
Function Chipid() As Byte
'------------------------------------------------------------------------------------------------------------
   Local Chip As Byte
   Local Cnt As Byte

   #IF _SIM
      CHipid=0
      exit function
   #ENDIF

   Chip = Rd8(reg_id)

   Cnt = 0

   While Chip <> &H7C
      Chip = Rd8(reg_id)
      If Cnt > 10 Then
         #IF FT_Debugger
            Print "Error, No ID sent from FT800"
         #ENDIF
         Chipid = 1
         Exit Function
      End If

      Incr Cnt
      Waitms 100
   Wend

   Chipid = 0

End Function                                                ' ChipId

'------------------------------------------------------------------------------------------------------------
Sub Powercycle(byreg r16 As Byte)
'------------------------------------------------------------------------------------------------------------

#if FT_PlatForm=Gameduino2
   ' Gameduino2 has no PD pin, it's held High at all times
   Exit Sub
#endif

   !jmp _ft_powercycle
End Sub                                                     ' PowerCycle

'------------------------------------------------------------------------------------------------------------
Function Incrcmdoffset(byval Offset As Word , Byval Size As Word) As Word
'------------------------------------------------------------------------------------------------------------

   Local Newoffset As Word

   Newoffset = Offset + Size
   Newoffset = Newoffset AND 4095

   Incrcmdoffset = Newoffset

End Function

'------------------------------------------------------------------------------------------------------------
Function Ftfreespace() As Word
'------------------------------------------------------------------------------------------------------------
   ' Reports the amount of Free Space left in the FIFO Buffer

   Local Fullness As Word
   Local Retval As Word

   Fullness = ftFifo_writeptr - Rd16(reg_cmd_read)
   Fullness = Fullness And 4095
   Retval = Ft_cmd_fifo_size - 4
   Retval = Retval - Fullness

   Ftfreespace = Retval

End Function                                                ' Freespace

'------------------------------------------------------------------------------------------------------------
Sub Chipsel(byreg  r24 As Byte)
!    jmp _ftChipSel
End Sub                                                     ' ChipSel

'------------------------------------------------------------------------------------------------------------
Sub Readtouchvariables
'------------------------------------------------------------------------------------------------------------

   Tempdw = Transmatrix(0 + _base)
   Wr32 Reg_touch_transform_a , Tempdw
   Tempdw = Transmatrix(1 + _base)
   Wr32 Reg_touch_transform_b , Tempdw
   Tempdw = Transmatrix(2 + _base)
   Wr32 Reg_touch_transform_c , Tempdw
   Tempdw = Transmatrix(3 + _base)
   Wr32 Reg_touch_transform_d , Tempdw
   Tempdw = Transmatrix(4 + _base)
   Wr32 Reg_touch_transform_e , Tempdw
   Tempdw = Transmatrix(5 + _base)
   Wr32 Reg_touch_transform_f , Tempdw

End Sub                                                     ' GetTouchVariables

'------------------------------------------------------------------------------------------------------------
Sub Writetouchvariables
'------------------------------------------------------------------------------------------------------------

   Tempdw = Rd32(reg_touch_transform_a)
   Transmatrix(0 + _base) = Tempdw
   Tempdw = Rd32(reg_touch_transform_b)
   Transmatrix(1 + _base) = Tempdw
   Tempdw = Rd32(reg_touch_transform_c)
   Transmatrix(2 + _base) = Tempdw
   Tempdw = Rd32(reg_touch_transform_d)
   Transmatrix(3 + _base) = Tempdw
   Tempdw = Rd32(reg_touch_transform_e)
   Transmatrix(4 + _base) = Tempdw
   Tempdw = Rd32(reg_touch_transform_f)
   Transmatrix(5 + _base) = Tempdw
   ' Save a flag, If we check if TouchID = AA we know the Calibration is done.
   Tc = &HAA
   Touchid = Tc

End Sub                                                     ' WriteTouchVariables

'------------------------------------------------------------------------------------------------------------
Sub Executebuffercmds()
'------------------------------------------------------------------------------------------------------------
   ' Tell the Co-pro where is has to jump to start executing
   ' ftFifo_WritePtr is a Global

   Wr16 Reg_Cmd_Write , ftFifo_WritePtr

End Sub                                                     ' ExecuteBufferCmds

'------------------------------------------------------------------------------------------------------------
Sub Waitcmdfifoempty()
'------------------------------------------------------------------------------------------------------------
   ' Loops Untill Reg_Cmd_Read is equal to Reg_Cmd_Write.
   ' This tells us the Co-Pro is ready and has caught up executing.
! jmp _ftWaitCmdFIFOempty
End Sub                                                     ' WaitCmdfifoEmpty

'------------------------------------------------------------------------------------------------------------
Sub Clearscreen()
'------------------------------------------------------------------------------------------------------------
   ' CLS

   Clearcolorrgb 0 , 0 , 0
   Clear_b 1 , 1 , 1                                        ' Must alway use this after ClearColorRGB

End Sub                                                     ' ClearScreen

'------------------------------------------------------------------------------------------------------------
Sub Starttransfer()
'------------------------------------------------------------------------------------------------------------

   ftStream = True

   Chipsel 0                                                ' Make Chip Select Low

   Adr32 Ram_cmd + ftFifo_writeptr

End Sub                                                     ' StartTransfer

'------------------------------------------------------------------------------------------------------------
Sub Endtransfer()
'------------------------------------------------------------------------------------------------------------
    !call _ftEndTransfer
   ftStream = False

   Chipsel 1                                                ' Make Chip Select High

End Sub                                                     ' EndTransfer

'------------------------------------------------------------------------------------------------------------
Sub Updatescreen()
'------------------------------------------------------------------------------------------------------------

   Display_E
   Cmdswap
   Cmddlstart
   Waitcmdfifoempty

End Sub                                                     ' UpdateScreen

'------------------------------------------------------------------------------------------------------------
Sub Freespaceft(byreg r30 As Word)                        ' as used in Gamduino
'------------------------------------------------------------------------------------------------------------
' Waits till a certain amount of bytes are Free

!    jmp  _ftGetfree

End Sub                                                   ' FreeSpaceFT

'------------------------------------------------------------------------------------------------------------
Sub Cmdstr(byval Strpacket As String * 80)
'------------------------------------------------------------------------------------------------------------

   Datas = Strpacket                                        ' Copy the String to the Overlay variable DataT(x) and DataS

   ' TC is a Global Byte
   Tc = Len(datas)

   ' Is this going to slow it down much or should the user
   ' be responsible for checking its not a blank ?
   'If TC = 0 Then Exit Sub ' Just quit if there is nothing

   Incr Tc
   Datat(tc + _base) = 0                                    ' Add a Terminator

   ' TB is a Global Byte
   For Tb = 0 To Tc -1

      Cmd8 Datat(tb + _base)

      #if FT_Debugger = 1
         Print "Tx - CmdStr " ; Hex(datat(tb + _base)) ; " " ; Chr(datat(tb + _base))
      #endif

   Next

   ' Call Alignfifo to align/Pad to a 4 Byte Boundary so next Write aligns up.
   ' It will also handle any additional corrections to Fifo_writeptr/Freespaceleft.

   Alignfifo Tc

End Sub                                                     ' CmdStr
'------------------------------------------------------------------------------------------------------------
Sub Getfree(byreg r30 As Word)
'------------------------------------------------------------------------------------------------------------

   Freespaceft r30                                            ' FreeSpaceLeft is updated from FreeSpaceFT

End Sub                                                     ' GetFree

'------------------------------------------------------------------------------------------------------------
Sub Loadcmd(byreg r30 As Word , Byreg r16 As Dword)
'------------------------------------------------------------------------------------------------------------
!    mov r24,r16
!    andi r24,3  ; should be zero
!    breq _align4_loadcmd
!    ldi r25,4
!    sub r25,r24
!    clr r24
!    add r16,r25
!    adc r17,r24
!    Adc R18,r24
!    adc r19,r24
_align4_loadcmd:
!    push r16
!    push r17
!    push r18
!    push r19
!    Lpm r16,z+
!    push r30
!    push r31
!    call _cmd8
!    pop r31
!    pop r30
!    pop r19
!    pop r18
!    pop r17
!    pop r16
!    Subi R16,1
!    Sbci R17,0
!    sbci R18,0
!    Sbci R19,0
!    brne _align4_loadcmd
End Sub                                                     ' LoadCmd

'------------------------------------------------------------------------------------------------------------
Sub Rdflash_wrft800(byval Ptr As Dword , Byref Varadr As Dword , Byval Count As Dword)
'------------------------------------------------------------------------------------------------------------
   ' Reads from any AVR Flash Address (Data Statements or $incl) and sends it to the FT800
   ' Note this routine does not do any Error checking since it's not for FIFO use

   ' Ptr should be the Address of a Label, example:
   ' TempDW = Loadlabel(Bitmap_RawData)
   ' dFlash_WrFT800 RAM_G, TempDW, Header_Stride(0+_base) * Header_Height(0+_base)

   If ftStream = True Then
      Chipsel 1
      ftStream = False
   End If

   Chipsel 0

   Adr32 Ptr

   For Ti = 1 To Count
      R24 = Cpeek(varadr)
      ! call _ft_spi
      Incr Varadr
   Next

   Chipsel 1

End Sub                                                     ' RdFlash_WrFT800

'------------------------------------------------------------------------------------------------------------
Sub Rdmem_wrft800(byval Ptr As Dword , Byref Var As Dword , Byval Count As Dword)
'------------------------------------------------------------------------------------------------------------
   ' Reads from any AVR Ram Address and sends it to the FT800
   ' Note this routine does not do any Error checking since it's not for FIFO use
    ' <Varadr> can be a 'String' or Byte 'Array'

   Local Varadr As Dword

   Varadr = Varptr(var)

   If ftStream = True Then
      Chipsel 1
      ftStream = False
   End If

   Chipsel 0

   Adr32 Ptr

   For Ti = 1 To Count
      R24 = Inp(varadr)
      !call _ft_spi
      Incr Varadr
   Next

   Chipsel 1

End Sub                                                     ' RdMem_WrFT800

'------------------------------------------------------------------------------------------------------------
Sub Rdft800_wrmem(byval Ptr As Dword , Byref Var As Dword , Byval Count As Dword)
'------------------------------------------------------------------------------------------------------------
   ' Reads from any FT800 Address and stores it to any AVR Variable
   ' Note this routine does no Error checking since it's not for FIFO use
   ' Var = The Variable which you want information returned to.
   ' example: return information from FT800 about a Font.
   ' RdFT800_WrMem TempDW, Display_fontstruct, FT_Gpu_FONT_TABLE_SIZE

   Local Varadr As Dword

   Varadr = Varptr(var)

   If ftStream = True Then
      Chipsel 1
      ftStream = False
   End If

   Chipsel 0

   Adr32 Ptr

   For Ti = 1 To Count

      Tb = Rd8(ptr)
      Out Varadr , Tb

      Incr Varadr
      Incr Ptr

   Next

   Chipsel 1

End Sub                                                     ' RdFT800_WrMem

'------------------------------------------------------------------------------------------------------------
Sub Alignfifo(byreg r16 As Byte)
  ' Pads Fifo buffer if bytes are not in a 4 byte boundary
Alignfifo2:
!   andi R16,3
!   breq Alignfifo1
!   call _cmd8
!   inc r16
!   rjmp Alignfifo2
Alignfifo1:
End Sub                                                 ' AlignFifo

'------------------------------------------------------------------------------------------------------------
Sub Align4 (byref var as dword)
'------------------------------------------------------------------------------------------------------------
    loadadr var,x
!    ld r16,x+
!    ld r17,x+
!    ld r18,x+
!    ld r19,x
!    mov r24,r16
!    andi r24,3                        ; should be zero
!    breq _align4_done
!    ldi r25,4
!    sub r25,r24
!    clr r24
!    add r16,r25
!    adc r17,r24
!    Adc R18,r24
!    adc r19,r24
!    st x,r19
!    st -x,r18
!    st -x,r17
!    st -x,r16
_align4_done:

End sub ' Align4

'------------------------------------------------------------------------------------------------------------
Sub Play_sound(byval Soundx As Integer , Byval Volume As Byte)
'------------------------------------------------------------------------------------------------------------
   ' Api to play Key sound

   Wr8 Reg_vol_sound , Volume
   Wr16 Reg_sound , Soundx
   Wr8 Reg_play , 1

End Sub                                                     ' Play_Sound

'------------------------------------------------------------------------------------------------------------
Function Measurefreq() As Dword
'------------------------------------------------------------------------------------------------------------

   Local T0 As Dword
   Local T1 As Dword
   Local T3 As Dword

   T0 = Rd32(reg_clock)

   Waitus 15625

   T1 = Rd32(reg_clock)

   T3 = T1 - T0
   Shift T3 , Left , 6

   Measurefreq = T3

#if FT_Debugger = 1
   Print "MeasureFreq = " ; T3
#endif

End Function                                                ' MeasureFreq

'------------------------------------------------------------------------------------------------------------
Sub Tune
'------------------------------------------------------------------------------------------------------------

   Local I As Byte
   Local F As Dword

   For I = 0 To 30
      F = Measurefreq()
      If F < Low_freq_bound Then
         Wr8 Reg_trim , I
      End If
   Next

   Wr32 Reg_frequency , F

End Sub

'------------------------------------------------------------------------------------------------------------
Sub Touchcal
'------------------------------------------------------------------------------------------------------------

   ' Check if Calibaration has been done before

   Tb = Touchid
   If Tb <> &HAA Then
      Cmdcalibratex
   Else
      ' Get the REG_TOUCH_TRANSFORM_A-F variables from EEPROM
      Readtouchvariables
   End If

End Sub

'------------------------------------------------------------------------------------------------------------
Sub Clearfifoptr
'------------------------------------------------------------------------------------------------------------

   ftFifo_writeptr = 0
   ftFreespaceleft = 4092

End Sub
'------------------------------------------------------------------------------------------------------------
Sub Radiobutton(byval X As Integer , Byval Y As Integer , Byval Bgcolor As Dword , Byval Fgcolor As Dword , Byval Psize As Byte , Byval Tagx As Byte , Byval Opt As Byte)
'------------------------------------------------------------------------------------------------------------

   Local Check_size As Byte

   Check_size = Psize / 2

   Savecontext
   Colorrgbdw Bgcolor
   Tag Tagx
   Pointsize Psize * 16
   Begin_g Ftpoints
   Vertex2f X * 16 , Y * 16

   If Tagx = Opt Then

      Colorrgbdw Fgcolor
      Pointsize Check_size * 16
      Vertex2f X * 16 , Y * 16

   End If

   Restorecontext

End Sub                                                     ' RadioButton


'------------------------------------------------------------------------------------------------------------
'  ELEMENTARY GRAPHIC FUNCTIONS LIKE CIRCLE, BOX, LINE, TRIANGLE etc.
'  They shall be preceeded by a call to Ft800_init() and then to Cmddlstart()
'  One or more calls to these routines will build a displaylist.
'  The list is finally activated by a call to Updatescreen()
'  See example: LINE_CIRCLE_BOX.BAS
'------------------------------------------------------------------------------------------------------------

'--------------------------------------------------------------------------------------------
Sub Ft_cls(byreg r16 As Dword)
   '-----------------------------------------------------------------------------------------
'Clear entire screen and paint background with a uniform color C
   Clearcolorrgbdw r16                                         'Area background color
   Clear_b 1 , 0 , 0
End Sub

'-------------------------------------------------------------------------------------------
Sub Ft_line(byval X1 As Word , Byval Y1 As Word , Byval X2 As Word , Byval Y2 As Word , Byval W As Word , Byval C As Dword )
'-------------------------------------------------------------------------------------------
'Draw a line from coordiante X1,Y1 to X2,Y2 using linewidth W (pixels)
'C is the line color
   Colorrgbdw C
   Linewidth W * 16

   Begin_g Lines                                            'Start Drawing Lines
   Vertex2ii X1 , Y1 , 0 , 0                                'Draw line
   Vertex2ii X2 , Y2 , 0 , 0                                'Draw line
   End_g

End Sub

'-------------------------------------------------------------------------------------------
Sub Ft_box(byval X1 As Word , Byval Y1 As Word , Byval X2 As Word , Byval Y2 As Word , Byval W As Word , Byval C As Dword )
'-------------------------------------------------------------------------------------------
'Draw a rectangle with sharp corners at coordiantes X1,Y1 and X2,Y2 using linewidth W (pixels)
'C is the line color
   Colorrgbdw C
   Linewidth W * 16

   Begin_g Line_strip                                       'Start Drawing a non filled shape
      Vertex2ii X1 , Y1 , 0 , 0                             'Upper left corner
      Vertex2ii X2 , Y1 , 0 , 0
      Vertex2ii X2 , Y2 , 0 , 0
      Vertex2ii X1 , Y2 , 0 , 0
      Vertex2ii X1 , Y1 , 0 , 0                             'Closed shape
   End_g

End Sub

'-------------------------------------------------------------------------------------------
Sub Ft_triangle(byval X1 As Word , Byval Y1 As Word , Byval X2 As Word , Byval Y2 As Word , _
                Byval X3 As Word , Byval Y3 As Word , Byval W As Word , Byval C As Dword )
'-------------------------------------------------------------------------------------------
'Draw a triangle with sharp corners at coordiantes X1,Y1 and X2,Y2 and X3,Y3 using linewidth W (pixels)
'C is the line color
   Colorrgbdw C
   Linewidth W * 16

   Begin_g Line_strip                                       'Start Drawing a non filled shape
      Vertex2ii X1 , Y1 , 0 , 0                             'Upper left corner
      Vertex2ii X2 , Y2 , 0 , 0
      Vertex2ii X3 , Y3 , 0 , 0
      Vertex2ii X1 , Y1 , 0 , 0                             'Closed shape
   End_g

End Sub

'-------------------------------------------------------------------------------------------
Sub Ft_boxrnd(byval X1 As Word , Byval Y1 As Word , Byval X2 As Word , Byval Y2 As Word , Byval R As Word , Byval C As Dword)
'-------------------------------------------------------------------------------------------
'Draw a filled rectangle with rounded corners at coordiantes X1,Y1 and X2,Y2
'R is the corner radius ("Linewidth" is used for passing this param)
'C is the line color

   'Compensate size for linewidth
   X1 = X1 + R
   Y1 = Y1 + R
   X2 = X2 - R
   Y2 = Y2 - R

   Colorrgbdw C
   Linewidth R * 16

   Begin_g Rects                                            'Start Drawing Rectangles
      Vertex2ii X1 , Y1 , 0 , 0                             'Draw First corner
      Vertex2ii X2 , Y2 , 0 , 0                             'Draw Second corner
   End_g

End Sub

'-------------------------------------------------------------------------------------------
Sub Ft_dot1(byval X As Word , Byval Y As Word , Byval S As Word , Byval C As Dword)
'-------------------------------------------------------------------------------------------
'Draw a monochrome dot at coordiante X,Y
'S is the dot size
'C is the dot color
   Colorrgbdw C
   Pointsize S * 16

   Begin_g Ftpoints                                         'Start Drawing Points
      Vertex2ii X , Y , 0 , 0                               'Draw dot
   End_g

End Sub


'-------------------------------------------------------------------------------------------
Sub Ft_dot2(byval X As Word , Byval Y As Word , Byval R As Word , Byval W As Word , Byval C1 As Dword , Byval C2 As Dword)
'-------------------------------------------------------------------------------------------
'Draw a filled circle at coordinate X1,Y1 with radius R using linewidth W (pixels)
'FT800 have no native circle command so we will emulate a circle by writing two ovelapping dots
'Observe that the inside of the circle will be overwritten using color C2
'Line width will add to circle dimension inside as well as outside.
'C1 is the line color
'If W > 2*R then no inner color C2 will be visible
'This is a very fast command but will not preserve the center which is painted by color C2.
'If you need a true circle (or arc)  with transparent center, then use FT_ARC() instead. (slower)
   R = R * 16
   W = W * 8                                                'Half linewidth

   Begin_g Ftpoints                                         'Start Drawing Points
      Pointsize R + W
      Colorrgbdw C1
      Vertex2ii X , Y , 0 , 0                               'Draw dot
      If R > W Then
         Pointsize R - W
         Colorrgbdw C2
         Vertex2ii X , Y , 0 , 0                            'Draw inner dot if not too small
      End If
   End_g

End Sub

'-------------------------------------------------------------------------------------------
Sub Ft_circle(byval X As Integer , Byval Y As Integer , Byval R As Word , Byval W As Byte , Byval C As Dword )
'-------------------------------------------------------------------------------------------
'Draw a circle at coordinate X,Y with radius R using linewidth W (pixels)
'FT800 have no native circle command so we will emulate a circle by writing ovelapping "points"
'R is the line center radius. Independent of width W, but W must be smaller than 2R
'Circles are allowed to extend outside the screen, byt must be inside the virtual x,y = -1024 to +1024 range
'C1 is the line color

   Select Case W
      Case 0 : Exit Sub                                     'Draw nothing
      Case 1 :                                              'Draw thin circle
      Case Else:
         Shift W , Right , 1                                'Half linewidth
         If W >= R Then W = R - 1
         R = R - W                                          'Start drawing half width inside the specified radius
         Shift W , Left , 2                                 'Draw twice as many circles as stipulated width
   End Select

  'Scale to suit VERTEX2F() function
   Shift X , Left , 4
   Shift Y , Left , 4
   Shift R , Left , 4

   Begin_g Ftpoints
   Colorrgbdw C
   Blendfunc One_minus_src_alpha , Src_alpha             'Preserve background
   Do
      Pointsize R
      Vertex2f X , Y
      R = R + 8                                          'Draw 2 circles per pixel width to avoid graphic interference
      Decr W                                             'W is now used as a counter
   Loop Until W = 0
   End_g

   Blendfunc Src_alpha , One_minus_src_alpha                'Restore default blending
End Sub

'-------------------------------------------------------------------------------------------
Sub Ft_arc(byval X As Integer , Byval Y As Integer , Byval R As Word , _
   Byval A1 As Word , Byval A2 As Word , Byval W As Word , Byval C As Dword )
'-------------------------------------------------------------------------------------------
'Draw an arc with center at coordinate X,Y and radius R using linewidth W (pixels)
'FT800 have no native arc command so we will emulate an circle by writing a dotted line.
'Observe that no trancendendent functions like Sin and Cos are being used for speed reasons.
'R is the line center radius. Independent of width W
'C1 is the line color
'Ang is the arc angle 0-360 deg. Zero angle is 3 o'clock, growing anticlockwise
'If W > 2*R then no inner color C2 will be visible
   Local I As Integer
   Local Ramp As Integer                                    'Sawtooth ramp
   Local Slope As Integer                                   'Ramp direction
   Local Sine As Long                                       'Sine accumulator (-243000 to +243000)
   Local Cosine As Integer                                  'Cosine accumulator (-4095 to +4095)
   Local Lx0 As Long
   Local Ly0 As Long
   Local X0 As Integer
   Local Y0 As Integer
   Local Ry As Integer

   X = X * 16
   Y = Y * 16
   R = R * 256
   Ry = R / 60                                              'Not quite 64 ...
   Slope = 1                                                'Ramping UP
   Ramp = 0                                                 'Ramp is crossing zero
   Sine = -4095                                             'Initial accumulator settings
   Cosine = 4050                                            'These initial values will make accumulation symmetric

   Begin_g Ftpoints                                         'Start Drawing Points
      Pointsize W * 16                                      'Linewidth
      Colorrgbdw C
      For I = 0 To A2
         Select Case Ramp
            Case -90 : Slope = 1                            'Sine = -4095  , Cosine=0  , ramp up from now!
            Case 90 : Slope = -1                            'Sine = 4095  , Cosine=0 , ramp down from now!
         End Select

         Sine = Sine + Cosine
         Cosine = Cosine - Ramp
         If I >= A1 Then                                    'Don't draw until we reach start-angle
            Lx0 = Cosine * R                                'R*256*4096*Cos(I)
            Ly0 = Sine * Ry
            X0 = Highw(lx0)                                 'Divide by 65536
            Y0 = Highw(ly0)
            X0 = X + X0                                     'Adjust for center offset
            Y0 = Y - Y0                                     '
            Vertex2f X0 , Y0
         End If
         Ramp = Ramp + Slope                                'Linear ramp
      Next I
   End_g

End Sub