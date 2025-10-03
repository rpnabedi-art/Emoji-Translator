
; Для компиляции нужна библиотека HID_Lib, которую можно найти здесь http://pure-basic.narod.ru/libs.html


#USB_PID = $EF22
#USB_VID = $AAAA

Enumeration
  #Window_0
EndEnumeration

;- Gadget Constants
;
Enumeration
  #Frame3D_0
  #Radio_0
  #Radio_1
  #TrackBar_0
EndEnumeration

XIncludeFile "HID_Module.pbi"

Procedure FindDevice_Timer() ; Периодическая (каждые 400 мс.) проверка доступности термометра
Shared DeviceHandle
Static Old_Test
Test=HID::TestDevice(#USB_PID, #USB_VID) ; Есть ли требуемое USB HID устройство?
 If Test<>Old_Test
  Old_Test=Test
  If Test 
     HID::CloseDevice(DeviceHandle)
     DeviceHandle=HID::OpenDevice(#USB_PID, #USB_VID) ; Подключение к USB HID устройству
  Else
     HID::CloseDevice(DeviceHandle)                   ; Разрыв связи с USB HID устройством
     DeviceHandle=0
  EndIf
 EndIf
EndProcedure

Procedure SendDevice(Handle)
  Dim OutBufer.a(2)
  
  If Handle
    
    If GetGadgetState(#Radio_0)=1
      Type = 2
    Else
      Type = 5
    EndIf
    
    OutBufer(0) = 0
    OutBufer(1) = 255
    If HID::WriteDevice(Handle, @OutBufer(), 2) = 2
      
      For i=#TrackBar_0 To #TrackBar_0+Type
        OutBufer(0) = 0
        OutBufer(1) = GetGadgetState(i)
        If HID::WriteDevice(Handle, @OutBufer(), 2) <> 2
          Break
        EndIf 
      Next i
    EndIf
    
  EndIf
EndProcedure

Procedure Open_Window_0()
  If OpenWindow(#Window_0, 310, 266, 278, 300, "USB HID PWM",  #PB_Window_ScreenCentered | #PB_Window_MinimizeGadget | #PB_Window_Invisible | #PB_Window_TitleBar )
      FrameGadget(#Frame3D_0, 30, 10, 210, 40, "Count of channels")
      OptionGadget(#Radio_0, 40, 30, 85, 15, "3 channels")
        GadgetToolTip(#Radio_0, "ATmega8")
      OptionGadget(#Radio_1, 150, 30, 85, 15, "6 channels")
        GadgetToolTip(#Radio_1, "ATmega48")
      SetGadgetState(#Radio_0,1)
      
      y=60
      For i=#TrackBar_0 To #TrackBar_0+5
        TrackBarGadget(i, 5, y, 270, 35, 0, 254)
        If i >= #TrackBar_0 + 3
          DisableGadget(i, 1)
        EndIf
        y+40
      Next i
      
      HideWindow(#Window_0, 0)
  EndIf
EndProcedure

HID::HID_Init()

Open_Window_0()
AddWindowTimer(#Window_0, 2, 400)

Repeat
  Event=WaitWindowEvent()
  
  If Event=#PB_Event_Gadget
    Select EventGadget()
      Case #Radio_0, #Radio_1
         For i=#TrackBar_0+3 To #TrackBar_0+5
           DisableGadget(i, GetGadgetState(#Radio_0))
         Next i
       Case #TrackBar_0 To #TrackBar_0+5
         SendDevice(DeviceHandle)
    EndSelect
     
  ElseIf Event=#PB_Event_Timer
    If EventTimer()=2
      FindDevice_Timer()
    EndIf
  EndIf
  
Until Event=#PB_Event_CloseWindow

HID::HID_End()


; IDE Options = PureBasic 5.31 (Windows - x86)
; CursorPosition = 115
; FirstLine = 74
; Folding = -
; EnableXP
; UseIcon = usb.ico
; Executable = ..\PWM.exe