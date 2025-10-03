$regfile = "m8def.dat"
$crystal = 12000000

$hwstack = 40
$swstack = 40
$framesize = 50

$include "USB\USB_Config.bas"
$include "USB\Const_swusb-includes.bas"

Dim Buttons_current As Byte
Dim Buttons_last As Byte

Config Portb = Input
Config Portb.0 = Output
Config Portc = Input
Portb.0 = 0

' Разрешаем прерывания.
Enable Interrupts

Do

   Call Usb_refresh()

   ' Получены данные от компьютера.
   If _usb_status._usb_rxc = 1 Then
      If _usb_status._usb_setup = 1 Then
         ' Обработка системных сообщений нулевой конечной точки.
         Call Usb_processsetup(_usb_tx_status(1))
      Elseif _usb_status._usb_endp1 = 1 Then
         ' Пришёл пакет данных из компьютера в 1 конечную точку.
         Toggle _usb_rx_buffer(2)
         Portb = _usb_rx_buffer(2)                          ' Запись данных в порт.
      End If
      ' Признак готовности принять следующий пакет данных.
      _usb_status._usb_rtr = 1
      _usb_status._usb_rxc = 0
   End If


   Buttons_current = Pinc
   Buttons_current = Buttons_current And 1
   If Buttons_current <> Buttons_last Then
     If _usb_tx_status2._usb_txc = 1 Then
       Buttons_last = Buttons_current
       If Buttons_current <> 0 Then
         _usb_tx_buffer2(2) = 40
       Else
         _usb_tx_buffer2(2) = 20
       End If
       Call Usb_send(_usb_tx_status2(1) , 1)       ' Передача в компьютер одного байта.
     End If
   End If


Loop

End

$include "USB\USB_Descriptor.bas"
$include "USB\USB_Subroutines.bas"