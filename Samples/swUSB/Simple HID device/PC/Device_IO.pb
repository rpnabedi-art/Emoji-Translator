#USB_PID=1
#USB_VID=$1234
Global W_DeviceHandle=0, R_DeviceHandle=0

XIncludeFile "HID_Module.pbi"

Procedure FindDevice_Timer()
Static Old_Test
Test=HID::TestDevice(#USB_PID, #USB_VID)
 If Test<>Old_Test
  Old_Test=Test
  If Test 
     HID::CloseDevice(W_DeviceHandle)
     HID::CloseDevice(R_DeviceHandle)
     W_DeviceHandle=HID::OpenDevice(#USB_PID, #USB_VID)
     R_DeviceHandle=HID::OpenDevice(#USB_PID, #USB_VID)
     SetGadgetText(1,"Connected HID device")
  Else
     HID::CloseDevice(W_DeviceHandle)
     HID::CloseDevice(R_DeviceHandle)
     W_DeviceHandle=0 : R_DeviceHandle=0
     SetGadgetText(1,"HID device not found ( PID — "+Hex(#USB_PID)+"H;  VID — "+Hex(#USB_VID)+"H) ")
     SetGadgetText(5,"Not")
  EndIf
 EndIf
EndProcedure

Procedure SendDevice(Command.w)
 If W_DeviceHandle
   HID::WriteDevice(W_DeviceHandle, @Command,2)
 Else
   MessageRequester("", "No connection with HID device!", #MB_OK|#MB_ICONWARNING)
 EndIf
EndProcedure

Procedure Thread(*xx)
Dim InBuffer.b(2)
 Repeat
   If R_DeviceHandle
     HID::ReadDevice(R_DeviceHandle, @InBuffer(), 2)
       If InBuffer(1)=20
         SetGadgetText(5,"Yes")
       ElseIf InBuffer(1)=40
         SetGadgetText(5,"Not")
       EndIf
   EndIf
   Delay(10)
 ForEver
EndProcedure

HID::HID_Init()

OpenWindow(0,0,0,320,100,"Example of a HID device",#PB_Window_MinimizeGadget|#PB_Window_Invisible|#PB_Window_ScreenCentered)
   TextGadget(1,10,10,300,16,"HID device not found ( PID — "+Hex(#USB_PID)+"H;  VID — "+Hex(#USB_VID)+"H )",#PB_Text_Center)
   ButtonGadget(2,40,70,120,24,"Led on")
   ButtonGadget(3,170,70,120,24,"Led off")
   TextGadget(4,50,40,98,16,"Button is pressed?")
   StringGadget(5,140,36,40,20,"Not",1|#PB_String_ReadOnly)
FindDevice_Timer()
HideWindow(0,0)
SetTimer_(WindowID(0),1,200,@FindDevice_Timer())
CreateThread(@Thread(),0)
Repeat
  Event=WaitWindowEvent()
  If Event=#PB_Event_Gadget
    Select EventGadget()
      Case 2
        SendDevice($AA00)
      Case 3
        SendDevice($5500)
    EndSelect
  EndIf
Until Event=#PB_Event_CloseWindow

HID::HID_End()

; IDE Options = PureBasic 5.31 (Windows - x86)
; CursorPosition = 75
; FirstLine = 34
; Folding = -
; EnableXP
; UseIcon = Icon.ico
; Executable = Device_IO.exe