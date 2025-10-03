$nocompile

'******************* Подпрограммы, обслуживающие USB драйвер *******************

Dim Usb_idlemode As Byte
Dim Usb_resetcounter As Word

Sub Usb_refresh()
   Usb_resetcounter = 0
   While _usb_pin._usb_dminus = 0
      Incr Usb_resetcounter
      If Usb_resetcounter >= 1000 Then
         Call Usb_reset()
      End If
   Wend
End Sub


Sub Usb_processsetup(txstate() As Byte)
   Senddescriptor = 0

   'Control transfers reset the sync bits like so
   Txstate(1) = _usb_setup_sync

   'These are the standard device, interface, and endpoint requests that the
   'USB spec requires that we support.
   Select Case _usb_rx_buffer(2)
      'Стандартные запросы устройств
      Case &B10000000:
         Select Case _usb_rx_buffer(3)
            Case _usb_req_get_descriptor:
               Select Case _usb_rx_buffer(5)
                  Case _usb_desc_device:
                     'Отправка дескриптора устройства
                     #if _usb_use_eeprom = 1
                        Readeeprom _usb_eepromaddrl , _usb_devicedescriptor
                     #else
                        Restore _usb_devicedescriptor
                     #endif
                     Senddescriptor = 1
                  Case _usb_desc_config:
                     'Отправка дескриптора конфигурации
                     #if _usb_use_eeprom = 1
                        Readeeprom _usb_eepromaddrl , _usb_configdescriptor
                     #else
                        Restore _usb_configdescriptor
                     #endif
                     Senddescriptor = 1
                  Case _usb_desc_string:
                     Select Case _usb_rx_buffer(4)
                        Case 0:
                           'Отправка дескриптора выбранного языка
                           #if _usb_use_eeprom = 1
                              Readeeprom _usb_eepromaddrl , _usb_langdescriptor
                           #else
                              Restore _usb_langdescriptor
                           #endif
                           Senddescriptor = 1
                        Case 1:
                           'Отправка дескриптора изготовителя
                           #if _usb_use_eeprom = 1
                              Readeeprom _usb_eepromaddrl , _usb_mandescriptor
                           #else
                              Restore _usb_mandescriptor
                           #endif
                           Senddescriptor = 1
                        Case 2:
                           'Отправка дескриптора продукта
                           #if _usb_use_eeprom = 1
                              Readeeprom _usb_eepromaddrl , _usb_proddescriptor
                           #else
                              Restore _usb_proddescriptor
                           #endif
                           Senddescriptor = 1
                        Case 3:
                           'Отправка дескриптора серийного номера
                           #if _usb_use_eeprom = 1
                              Readeeprom _usb_eepromaddrl , _usb_numdescriptor
                           #else
                              Restore _usb_numdescriptor
                           #endif
                           Senddescriptor = 1
                     End Select
               End Select
         End Select
      Case &B00000000:
         Select Case _usb_rx_buffer(3)
            Case _usb_req_set_address:
               'USB status reporting for control writes
               Call Usb_send(txstate(1) , 0)
               While Txstate(1)._usb_txc = 0 : Wend
               'We are now addressed.
               _usb_deviceid = _usb_rx_buffer(4)
            Case _usb_req_set_config:
               'Have to do status reporting
               Call Usb_send(txstate(1) , 0)
         End Select
      'Стандартные запросы интерфейса
      Case &B10000001:
         Select Case _usb_rx_buffer(3)
            Case _usb_req_get_descriptor
            '_usb_rx_buffer(4) Индекс дескриптора и (5) его тип
               Select Case _usb_rx_buffer(5)
                  Case _usb_desc_report:
                     #if _usb_use_eeprom = 1
                        Readeeprom _usb_eepromaddrl , _usb_hid_reportdescriptor
                     #else
                        Restore _usb_hid_reportdescriptor
                     #endif
                     Senddescriptor = 1
               End Select
         End Select
      Case &B00100001:
         'Class specific SET requests
         Select Case _usb_rx_buffer(3)
            Case _usb_req_set_idle:
               Usb_idlemode = 1
               'Do status reporting
               Call Usb_send(txstate(1) , 0)
         End Select
   End Select

   If Senddescriptor = 1 Then
      Call Usb_senddescriptor(txstate(1) , _usb_rx_buffer(8))
   End If

End Sub


Sub Usb_senddescriptor(txstate() As Byte , Maxlen As Byte)

   'Break the descriptor into packets and send to TxState
   Local Size As Byte
   Local I As Byte
   Local J As Byte
   Local Timeout As Word

   #if _usb_use_eeprom = 1
      'EEPROM access is a little funky.  The size has already been fetched
      'and stored in _usb_EEPROMADDRL, and the address of the descriptor
      'is now in the EEAR register pair.

      Size = _usb_eepromaddrl

      'Fetch the location of the descriptor and use it as an address pointer
      push R24
      in R24, EEARL
      sts {_USB_EEPROMADDRL}, R24
      in R24, eearH
      sts {_USB_EEPROMADDRH}, R24
      pop R24

   #else
      Read Size
   #endif


   If Maxlen < Size Then Size = Maxlen

   I = 2
   For J = 1 To Size
      Incr I
      #if _usb_use_eeprom = 1
         Incr _usb_eepromaddr
         Readeeprom Txstate(i) , _usb_eepromaddr
      #else
         Read Txstate(i)
      #endif

      If I = 10 Or J = Size Then
         I = I - 2
         Call Usb_send(txstate(1) , I)
         While Txstate(1)._usb_txc = 0
            Timeout = 0
            'To prevent an infinite loop, check for reset here
            While _usb_pin._usb_dminus = 0
               Incr Timeout
               If Timeout = 1000 Then             '
                  Call Usb_reset()
                  Exit Sub
               End If
            Wend
         Wend
         I = 2
      End If
   Next
End Sub


Sub Usb_send(txstate() As Byte , Byval Count As Byte)

   'Calculates and adds the CRC16,adds the DATAx PID,
   'and signals to the ISR that the data is ready to be sent.
   '
   '"Count" is the DATA payload size.  Range is 0 to 8. Do not exceed 8!

   'Reset all the flags except TxSync and RxSync
   Txstate(1) = Txstate(1) And _usb_syncmask
   'Calculate the 16-bit CRC
   _usb_crc = Crcusb(txstate(3) , Count)
   'Bytes to transmit will be PID + DATA payload + CRC16
   Count = Count + 3
   Txstate(1) = Txstate(1) + Count
   Txstate(count) = Low(_usb_crc)
   Incr Count
   Txstate(count) = High(_usb_crc)
   'Add the appropriate DATAx PID
   Txstate(2) = _usb_pid_data1
   If Txstate(1)._usb_txsync = 0 Then
      Txstate(2) = _usb_pid_data0
   End If
   'The last step is to signal that the packet is Ready To Transmit
   Txstate(1)._usb_rtt = 1
   Txstate(1)._usb_txc = 0
End Sub


Sub Usb_reset()
   'Reset the receive flags
   _usb_status._usb_rtr = 1
   _usb_status._usb_rxc = 0
   'Reset the transmit flags
   _usb_tx_status(1) = _usb_endp_init
   #if Varexist( "_usb_Endp2Addr")
   _usb_tx_status2(1) = _usb_endp_init
   #endif
   #if Varexist( "_usb_Endp3Addr")
   _usb_tx_status3(1) = _usb_endp_init
   #endif
   'Reset the device ID to 0
   _usb_deviceid = 0
   Usb_idlemode = 0
End Sub