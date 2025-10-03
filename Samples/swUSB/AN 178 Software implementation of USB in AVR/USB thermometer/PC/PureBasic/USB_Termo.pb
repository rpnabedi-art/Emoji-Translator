#USB_PID=$EF02
#USB_VID=$AAAA
#NO_Device="No HID device"
LoadFont(2,"Arial",22,#PB_Font_Bold)

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
     SetGadgetText(0,"Connected device")
  Else
     HID::CloseDevice(DeviceHandle)                   ; Разрыв связи с USB HID устройством
     DeviceHandle=0
     SetGadgetText(0,#NO_Device)
     SetGadgetText(1,"OFF")
  EndIf
 EndIf
EndProcedure

Procedure Thread(*x) ; Эта процедура работает в отдельном потоке
 Shared DeviceHandle
 Dim In.c(4)  ; Байтовый массив, используемый как бцфер приёма данных.
 Temp.w       ; Переменная типа Word.
 
 Repeat
   If DeviceHandle   ; Установлена ли связь с USB термометром?
     In(0)=0
     HID::ReadDevice(DeviceHandle, @In(), 3) ; Чтение данных из USB термометра
       Temp=In(2)
       Temp<<8                                  ; Сдвиг влево на 8 пизиций
       Temp | In(1)
       Result.f=Temp/16
       If Result<150 And Result>-58           ; Отсеиваем возможные глюки!
         SetGadgetText(1,StrF(Result,1)+" °C")      ; Отображение температуры в окне
       EndIf
   EndIf
   Delay(100)
 ForEver
 
EndProcedure

HID::HID_Init()

; Открываем окно
OpenWindow(0,0,0,170,70,"USB_Termo", #PB_Window_MinimizeGadget|#PB_Window_Invisible|#PB_Window_ScreenCentered)
 StickyWindow(0,1)
 TextGadget(0,4,4,162,16,#NO_Device,#PB_Text_Center)
 StringGadget(1,16,24,140,40,"OFF",#PB_Text_Center|#PB_String_ReadOnly)
   SetGadgetFont(1,FontID(2))
   SetGadgetColor(1,#PB_Gadget_FrontColor,$DF0000)
FindDevice_Timer()
HideWindow(0,0)

AddWindowTimer(0,1,400)    ; Запуск таймера
CreateThread(@Thread(),0)  ; Создание отдельного потока из процедуры Thread()

Repeat ; Главный цикл проги Repeat - Until
  Event=WaitWindowEvent() ; Идентификатор события
  If  Event=#PB_Event_Timer
    If EventTimer()=1
      FindDevice_Timer()  ; Вызов процедуры по таймеру, каждые 400 мс.
    EndIf
  EndIf
Until Event=#PB_Event_CloseWindow ; Прерывание главного цикла при закрытии окна

HID::HID_End()

; IDE Options = PureBasic 5.31 (Windows - x86)
; CursorPosition = 73
; FirstLine = 31
; Folding = -
; EnableXP
; UseIcon = Icon.ico
; Executable = USB_Termo.exe