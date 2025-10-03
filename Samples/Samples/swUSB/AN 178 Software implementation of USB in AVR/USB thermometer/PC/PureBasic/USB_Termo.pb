#USB_PID=$EF02
#USB_VID=$AAAA
#NO_Device="No HID device"
LoadFont(2,"Arial",22,#PB_Font_Bold)

XIncludeFile "HID_Module.pbi"

Procedure FindDevice_Timer() ; ������������� (������ 400 ��.) �������� ����������� ����������
Shared DeviceHandle
Static Old_Test
Test=HID::TestDevice(#USB_PID, #USB_VID) ; ���� �� ��������� USB HID ����������?
 If Test<>Old_Test
  Old_Test=Test
  If Test 
     HID::CloseDevice(DeviceHandle)
     DeviceHandle=HID::OpenDevice(#USB_PID, #USB_VID) ; ����������� � USB HID ����������
     SetGadgetText(0,"Connected device")
  Else
     HID::CloseDevice(DeviceHandle)                   ; ������ ����� � USB HID �����������
     DeviceHandle=0
     SetGadgetText(0,#NO_Device)
     SetGadgetText(1,"OFF")
  EndIf
 EndIf
EndProcedure

Procedure Thread(*x) ; ��� ��������� �������� � ��������� ������
 Shared DeviceHandle
 Dim In.c(4)  ; �������� ������, ������������ ��� ����� ����� ������.
 Temp.w       ; ���������� ���� Word.
 
 Repeat
   If DeviceHandle   ; ����������� �� ����� � USB �����������?
     In(0)=0
     HID::ReadDevice(DeviceHandle, @In(), 3) ; ������ ������ �� USB ����������
       Temp=In(2)
       Temp<<8                                  ; ����� ����� �� 8 �������
       Temp | In(1)
       Result.f=Temp/16
       If Result<150 And Result>-58           ; ��������� ��������� �����!
         SetGadgetText(1,StrF(Result,1)+" �C")      ; ����������� ����������� � ����
       EndIf
   EndIf
   Delay(100)
 ForEver
 
EndProcedure

HID::HID_Init()

; ��������� ����
OpenWindow(0,0,0,170,70,"USB_Termo", #PB_Window_MinimizeGadget|#PB_Window_Invisible|#PB_Window_ScreenCentered)
 StickyWindow(0,1)
 TextGadget(0,4,4,162,16,#NO_Device,#PB_Text_Center)
 StringGadget(1,16,24,140,40,"OFF",#PB_Text_Center|#PB_String_ReadOnly)
   SetGadgetFont(1,FontID(2))
   SetGadgetColor(1,#PB_Gadget_FrontColor,$DF0000)
FindDevice_Timer()
HideWindow(0,0)

AddWindowTimer(0,1,400)    ; ������ �������
CreateThread(@Thread(),0)  ; �������� ���������� ������ �� ��������� Thread()

Repeat ; ������� ���� ����� Repeat - Until
  Event=WaitWindowEvent() ; ������������� �������
  If  Event=#PB_Event_Timer
    If EventTimer()=1
      FindDevice_Timer()  ; ����� ��������� �� �������, ������ 400 ��.
    EndIf
  EndIf
Until Event=#PB_Event_CloseWindow ; ���������� �������� ����� ��� �������� ����

HID::HID_End()

; IDE Options = PureBasic 5.31 (Windows - x86)
; CursorPosition = 73
; FirstLine = 31
; Folding = -
; EnableXP
; UseIcon = Icon.ico
; Executable = USB_Termo.exe