#USB_PID=$EF22
#USB_VID=$AAAA
#NO_Device="No HID device"
#Name="HID_Example_IO"

XIncludeFile "HID_Module.pbi"

Global R_DeviceHandle, W_DeviceHandle

Procedure FindDevice_Timer()
Static Old_Test
Test=HID::TestDevice(#USB_PID, #USB_VID)
 If Test<>Old_Test
  Old_Test=Test 
  If Test 
     HID::CloseDevice(R_DeviceHandle) : HID::CloseDevice(W_DeviceHandle)
     W_DeviceHandle=HID::OpenDevice(#USB_PID, #USB_VID)
     R_DeviceHandle=HID::OpenDevice(#USB_PID, #USB_VID)
     SetGadgetText(0,"Ñonnected device")
  Else
     HID::CloseDevice(R_DeviceHandle) : HID::CloseDevice(W_DeviceHandle)
     R_DeviceHandle=0 : W_DeviceHandle=0
     SetGadgetText(0,#NO_Device)
     SetGadgetText(10,"Up") : SetGadgetText(11,"Up")
  EndIf
 EndIf
EndProcedure

Procedure ReadDevice_Thread(*x)
 Dim InBytes.a(2)
 Repeat
   If R_DeviceHandle
     HID::ReadDevice(R_DeviceHandle, @InBytes(), 2)
     Debug InBytes(1)
     If InBytes(1)&1
       SetGadgetText(10,"Up")
     Else
       SetGadgetText(10,"Down")
     EndIf
     
     If InBytes(1)&%10
       SetGadgetText(11,"Up")
     Else
       SetGadgetText(11,"Down")
     EndIf
     
   EndIf
   Delay(20)
 ForEver
EndProcedure

Procedure SendDevice()
Command.a=0
Dim OutBytes.a(2)  
For i=4 To 1 Step -1
  If GetGadgetState(i)=1
    Command | 1
  Else
    Command & %11111110
  EndIf
  Command << 1
Next i
If W_DeviceHandle
  OutBytes(0) = 0
  OutBytes(1) = Command
  HID::WriteDevice(W_DeviceHandle, @OutBytes(), 2)
Else
  MessageRequester(#Name, #NO_Device, 16)
EndIf
EndProcedure

HID::HID_Init()

OpenWindow(0,0,0,224,150,#Name,#PB_Window_MinimizeGadget|#PB_Window_Invisible|#PB_Window_ScreenCentered)
TextGadget(0,4,4,182,16,#NO_Device,#PB_Text_Center)
FrameGadget(#PB_Any,4,30,80,104,"Leds")
y=48
For i=1 To 4
  CheckBoxGadget(i,20,y,50,16,"Led "+Str(i))
  y+20
Next i
FrameGadget(#PB_Any,100,30,120,64,"Buttons")
TextGadget(#PB_Any,104,48,50,16,"Button 1:",#PB_Text_Right)
TextGadget(10,160,48,50,16,"Up") : SetGadgetColor(10,#PB_Gadget_FrontColor,$C70000)
TextGadget(#PB_Any,104,68,50,16,"Button 2:",#PB_Text_Right)
TextGadget(11,160,68,50,16,"Up") : SetGadgetColor(11,#PB_Gadget_FrontColor,$C70000)

HideWindow(0,0)

FindDevice_Timer()
AddWindowTimer(0, 2, 400)
CreateThread(@ReadDevice_Thread(),0)

Repeat
  Event=WaitWindowEvent()
  If Event=#PB_Event_Timer
    If EventTimer()=2
      FindDevice_Timer()
    EndIf
    
  ElseIf Event=#PB_Event_Gadget
    Select EventGadget()
      Case 1 To 4
        SendDevice()
    EndSelect
  EndIf
Until Event=#PB_Event_CloseWindow

HID::HID_End()

; IDE Options = PureBasic 5.31 (Windows - x86)
; CursorPosition = 18
; Folding = -
; EnableThread
; EnableXP
; UseIcon = Icon.ico
; Executable = HID_Example_IO.exe
; IncludeVersionInfo
; VersionField0 = 1.0.0.0
; VersionField1 = 1.0.0.0
; VersionField2 = Petr
; VersionField3 = Hid_IO
; VersionField4 = 1.0
; VersionField5 = 1.0
; VersionField6 = HID_Example_IO
; VersionField7 = HID_Example_IO
; VersionField8 = HID_Example_IO
; VersionField9 = Petr
; VersionField13 = pure-basic@yandex.ru
; VersionField14 = http://pure-basic.narod.ru
; VersionField17 = 0409 English (United States)