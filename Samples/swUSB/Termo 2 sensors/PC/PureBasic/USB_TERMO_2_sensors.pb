; Работа с 2 датчиками температуры http://bascom.at.ua/publ/usb_termometr_na_2_datchika/1-1-0-33


#USB_PID=$EF04
#USB_VID=$AAAA
#NO_Device="No HID device"
LoadFont(2,"Arial",20,#PB_Font_Bold)

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
     SetGadgetText(1,"OFF") : SetGadgetColor(1,#PB_Gadget_FrontColor,$DF0000)
     SetGadgetText(2,"OFF") : SetGadgetColor(2,#PB_Gadget_FrontColor,$DF0000)
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
    If HID::ReadDevice(DeviceHandle, @In(), 5) = 5 ; Чтение данных из USB термометра
     
       If In(2)=254 And In(1)=254      ;- **** Первый датчик ****
         SetGadgetText(1,"No sensor")
         SetGadgetColor(1,#PB_Gadget_FrontColor, $0003A9)
       Else  
         Temp = In(2) 
         Temp << 8                               ; Сдвиг влево на 8 пизиций
         Temp | In(1)                            ; Логическое ИЛИ
         Result.f=Temp/16
         If Result<150 And Result>-58           ; Отсеиваем возможные глюки!
           SetGadgetText(1,StrF(Result,1)+" °C") ; Отображение температуры в окне
           SetGadgetColor(1,#PB_Gadget_FrontColor,$DF0000)
         EndIf
       EndIf
     
       If In(4)=254 And In(3)=254     ;- **** Второй датчик ****
         SetGadgetText(2,"No sensor")
         SetGadgetColor(2,#PB_Gadget_FrontColor, $0003A9)
       Else  
         Temp = In(4) 
         Temp << 8                               ; Сдвиг влево на 8 пизиций
         Temp | In(3)                            ; Логическое ИЛИ
         Result.f=Temp/16
         If Result<150 And Result>-58           ; Отсеиваем возможные глюки!
           SetGadgetText(2,StrF(Result,1)+" °C") ; Отображение температуры в окне
           SetGadgetColor(2,#PB_Gadget_FrontColor,$DF0000)
         EndIf
       EndIf
       
     EndIf  
   EndIf
   Delay(100)
 ForEver
 
EndProcedure

HID::HID_Init()

OpenWindow(0,0,0,180,120,"USB_Termo", #PB_Window_MinimizeGadget|#PB_Window_Invisible|#PB_Window_ScreenCentered)
 StickyWindow(0,1)
 TextGadget(0,4,4,162,16,#NO_Device,#PB_Text_Center)
 TextGadget(1,0,24,180,40,"OFF",#PB_Text_Center)     ; Здесь отображается температура 1-го датчика
   SetGadgetFont(1,FontID(2))
   SetGadgetColor(1,#PB_Gadget_FrontColor,$DF0000)
 TextGadget(2,0,74,180,40,"OFF",#PB_Text_Center)     ; Здесь отображается температура 2-го датчика
   SetGadgetFont(2,FontID(2))
   SetGadgetColor(2,#PB_Gadget_FrontColor,$DF0000)
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
; CursorPosition = 104
; FirstLine = 62
; Folding = -
; EnableUnicode
; EnableThread
; EnableXP
; UseIcon = Icon.ico
; Executable = USB_TERMO_2_sensors.exe