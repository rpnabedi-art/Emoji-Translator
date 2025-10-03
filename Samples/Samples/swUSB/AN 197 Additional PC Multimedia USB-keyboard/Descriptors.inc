$nocompile
'*********************** Descriptors stored in FLASH ***************************
'                  Do not change the order of the descriptors!
'
$data

'Device Descriptor
_usb_devicedescriptor:
Data 18 , 18 , _usb_desc_device , _usb_specl , _usb_spech , _usb_devclass
Data _usb_devsubclass , _usb_devprot , 8 , _usb_vidl , _usb_vidh , _usb_pidl
Data _usb_pidh , _usb_devrell , _usb_devrelh , _usb_imanufacturer
Data _usb_iproduct , _usb_iserial , _usb_numconfigs


'Retrieving the configuration descriptor also gets all the interface and
'endpoint descriptors for that configuration.  It is not possible to retrieve
'only an interface or only an endpoint descriptor.  Consequently, this is a
'large transaction of variable size.

_usb_configdescriptor:
Data _usb_descr_total , 9 , _usb_desc_config , _usb_descr_totall
Data _usb_descr_totalh , _usb_numifaces , _usb_confignum , _usb_iconfig
Data _usb_powered , _usb_maxpower

'_usb_IFaceDescriptor
Data 9 , _usb_desc_iface , _usb_ifaceaddr , _usb_alternate
Data _usb_ifaceendpoints , _usb_ifclass , _usb_ifsubclass , _usb_ifprotocol
Data _usb_iiface

'_usb_HIDDescriptor
Data _usb_hid_descr_len , _usb_desc_hid , _usb_hid_releasel , _usb_hid_releaseh
Data _usb_hid_country , _usb_hid_numdescriptors

'Next follows a list of bType and wLength bytes/words for each report and
'physical descriptor.
Data _usb_desc_report
Data 63 , 0
'End of report/physical descriptor list

'_usb_EndpointDescriptor
Data 7 , _usb_desc_endpoint , _usb_endp2attr , _usb_endp2type , 8 , 0
Data _usb_endp2interval

'_usb_IFaceDescriptor1 *************************************************************************************
Data 9 , _usb_desc_iface , _usb_ifaceaddr1 , _usb_alternate1       '                            ***********
Data _usb_ifaceendpoints1 , _usb_ifclass1 , _usb_ifsubclass1 , _usb_ifprotocol1       '         ***********
Data _usb_iiface1                                 '                                   ***********

'_usb_HIDDescriptor1  *************************************************************************************
Data _usb_hid_descr_len , _usb_desc_hid , _usb_hid_releasel , _usb_hid_releaseh       '         ***********
Data _usb_hid_country , _usb_hid_numdescriptors , _usb_desc_report       '                      ***********
Data 50 , 0                                       '                                   ***********

'_usb_EndpointDescriptor
Data 7 , _usb_desc_endpoint , _usb_endp3attr , _usb_endp3type , 3 , 0       'Multimedia message lenght is 3 bytes !!!!!!!!!!!!!!!!
Data _usb_endp3interval

_usb_hid_reportdescriptor:
Data 63                                           'Length = 63
Data &H05 , &H01                                  'USAGE_PAGE (Generic Desktop)
Data &H09 , &H06                                  'USAGE (Keyboard)
Data &HA1 , &H01                                  'COLLECTION (Application)
Data &H05 , &H07                                  '   USAGE_PAGE (Keyboard)
Data &H19 , &HE0                                  '   USAGE_MINIMUM (Keyboard LeftControl)
Data &H29 , &HE7                                  '   USAGE_MAXIMUM (Keyboard Right GUI)
Data &H15 , &H00                                  '   LOGICAL_MINIMUM (0)
Data &H25 , &H01                                  '   LOGICAL_MAXIMUM (1)
Data &H75 , &H01                                  '   REPORT_SIZE (1)
Data &H95 , &H08                                  '   REPORT_COUNT (8)
Data &H81 , &H02                                  '   INPUT (Data,Var,Abs) - Modifier Byte -
Data &H95 , &H01                                  '   REPORT_COUNT (1)
Data &H75 , &H08                                  '   REPORT_SIZE (8)
Data &H81 , &H03                                  '   INPUT (Cnst,Var,Abs) - Reserved Byte -
Data &H95 , &H05                                  '   REPORT_COUNT (5)
Data &H75 , &H01                                  '   REPORT_SIZE (1)
Data &H05 , &H08                                  '   USAGE_PAGE (LEDs)
Data &H19 , &H01                                  '   USAGE_MINIMUM (Num Lock)
Data &H29 , &H05                                  '   USAGE_MAXIMUM (Kana)
Data &H91 , &H02                                  '   OUTPUT (Data,Var,Abs) - LED Report -
Data &H95 , &H01                                  '   REPORT_COUNT (1)
Data &H75 , &H03                                  '   REPORT_SIZE (3)
Data &H91 , &H03                                  '   OUTPUT (Cnst,Var,Abs) - LED Report Padding
Data &H95 , &H06                                  '   REPORT_COUNT (6) - here we define the maximum number of simultaneous keystrokes we can detect **
Data &H75 , &H08                                  '   REPORT_SIZE (8)
Data &H15 , &H00                                  '   LOGICAL_MINIMUM (0)
Data &H25 , &H65                                  '   LOGICAL_MAXIMUM (101)
Data &H05 , &H07                                  '   USAGE_PAGE (Keyboard)
Data &H19 , &H00                                  '   USAGE_MINIMUM (Reserved (no event indicated))
Data &H29 , &H65                                  '   USAGE_MAXIMUM (Keyboard Application)
Data &H81 , &H00                                  '   INPUT (Data,Ary,Abs) - Key arrays (6 bytes) -
Data &HC0                                         'END_COLLECTION

_usb_hid_reportdescriptor1:                       '                                               ************
Data 50                                           '                                               ************
Data &H05 , &H0C                                  'Usage Page (Consumer Devices)                  ************
Data &H09 , &H01                                  'Usage (Consumer Control)                       ************
Data &HA1 , &H01                                  'Collection (Application)                       ************
Data &H85 , &H01                                  '  Report ID (1)                                ************
Data &H19 , &H00                                  '  Usage Minimum (Undefined)                    ************
Data &H2A , &H3C , &H02                           '  Usage Maximum (reserved 0x023c)              ************
Data &H15 , &H00                                  '  Logical Minimum (0)                          ************
Data &H26 , &H3C , &H02                           '  Logical Maximum (572)                        ************
Data &H95 , &H01                                  '  Report Count (1)                             ************
Data &H75 , &H10                                  '  Report Size (16)                             ************
Data &H81 , &H00                                  '  Input (Data,Ary,Abs)                         ************
Data &HC0                                         'End Collection                                 ************
Data &H05 , &H01                                  'Usage Page (Generic Desktop)                   ************
Data &H09 , &H80                                  'Usage (System Control)                         ************
Data &HA1 , &H01                                  'Collection (Application)                       ************
Data &H85 , &H02                                  '  Report ID (2)                                ************
Data &H19 , &H81                                  '  Usage Minimum (System Power Down)            ************
Data &H29 , &H83                                  '  Usage Maximum (System Wake Up)               ************
Data &H25 , &H01                                  '  Logical Maximum (1)                          ************
Data &H75 , &H01                                  '  Report Size (1)                              ************
Data &H95 , &H03                                  '  Report Count (3)                             ************
Data &H81 , &H02                                  '  Input (Data,Var,Abs,NWrp,Lin,Pref,NNul,Bit)  ************
Data &H95 , &H05                                  '  Report Count (5)                             ************
Data &H81 , &H01                                  '  Input (Cnst,Ary,Abs)                         ************
Data &HC0                                         'End Collection                                 ************

'*****************************String descriptors********************************
'Default language descriptor (index 0)
_usb_langdescriptor:
Data 4 , 4 , _usb_desc_string , 09 , 04           '&h0409 = English

'Manufacturer Descriptor (unicode)
_usb_mandescriptor:
Data 34 , 34 , _usb_desc_string
Data &H52 , &H00 , &H61 , &H00 , &H64 , &H00 , &H61 , &H00 , &H6E , &H00
Data &H20 , &H00 , &H26 , &H00 , &H20 , &H00 , &H4D , &H00 , &H72 , &H00
Data &H53 , &H00 , &H68 , &H00 , &H69 , &H00 , &H6C , &H00 , &H6F , &H00
Data &H76 , &H00 , &H00 , 0

'Product Descriptor (unicode)
_usb_proddescriptor:
Data 70 , 70 , _usb_desc_string
Data &H10 , &H04 , &H42 , &H04 , &H3E , &H04 , &H3C , &H04 , &H3D , &H04
Data &H30 , &H04 , &H4F , &H04 , &H20 , &H00 , &H3A , &H04 , &H3B , &H04
Data &H30 , &H04 , &H32 , &H04 , &H38 , &H04 , &H30 , &H04 , &H42 , &H04
Data &H43 , &H04 , &H40 , &H04 , &H30 , &H04 , &H20 , &H00 , &H32 , &H04
Data &H38 , &H04 , &H3D , &H04 , &H34 , &H04 , &H43 , &H04 , &H3A , &H04
Data &H41 , &H04 , &H3E , &H04 , &H38 , &H04 , &H34 , &H04 , &H30 , &H04
Data &H20 , &H00 , &H76 , &H00 , &H2E , &H00 , &H32 , &H00 , &H00 , 0

_usb_numdescriptor:
Data 4 , 4 , _usb_desc_string
Data "2" , 0 , 0

'*******************************************************************************
'************************* Subroutines - Подпрограммы ***************************
'*******************************************************************************

Sub Usb_processsetup(txstate() As Byte)
Senddescriptor = 0
   Txstate(1) = _usb_setup_sync                   'Control transfers reset the sync bits like so

   'These are the standard device, interface, and endpoint requests that the
   'USB spec requires that we support.
   Select Case _usb_rx_buffer(2)

      Case &B10000000:                            'Standard Device Requests
         Select Case _usb_rx_buffer(3)
           ' Case _usb_req_get_status:
            Case _usb_req_get_descriptor:
               Select Case _usb_rx_buffer(5)
                  Case _usb_desc_device:
                     Restore _usb_devicedescriptor
                     Senddescriptor = 1
                  Case _usb_desc_config:
                        Restore _usb_configdescriptor
                     Senddescriptor = 1
                  Case _usb_desc_string:
                     Select Case _usb_rx_buffer(4)
                        Case 0:
                           Restore _usb_langdescriptor
                           Senddescriptor = 1
                        Case 1:
                           Restore _usb_mandescriptor
                           Senddescriptor = 1
                        Case 2:
                           Restore _usb_proddescriptor
                           Senddescriptor = 1
                        Case 3:
                           Restore _usb_numdescriptor
                           Senddescriptor = 1

                     End Select
               End Select
         End Select

      Case &B00000000:
         Select Case _usb_rx_buffer(3)
            Case _usb_req_set_address:
               Call Usb_send(txstate(1) , 0)      'USB status reporting for control writes
               While Txstate(1)._usb_txc = 0 : Wend
               _usb_deviceid = _usb_rx_buffer(4)  'We are now addressed.
            Case _usb_req_set_config:
               Call Usb_send(txstate(1) , 0)      'Have to do status reporting
         End Select

      Case &B10000001:
         Select Case _usb_rx_buffer(3)
            Case _usb_req_get_descriptor
               Select Case _usb_rx_buffer(5)      '_usb_rx_buffer(5) is the type of descriptor
                  Case _usb_desc_report:          '_usb_rx_buffer(6) is the interface number
                     If _usb_rx_buffer(6) = 0 Then Restore _usb_hid_reportdescriptor       'First Interface  ****************
                     If _usb_rx_buffer(6) = 1 Then Restore _usb_hid_reportdescriptor1       'Second Interface ****************
                     Senddescriptor = 1
               End Select
         End Select

      Case &B00100001:
         Select Case _usb_rx_buffer(3)            'Class specific SET requests
            Case _usb_req_set_report:             'NumLock, CapsLock и ScrollLock
               _usb_status._usb_rxc = 0           '*********************************************************************
               _usb_status._usb_rtr = 1           '*********************************************************************
               _usb_status2._usb_ignore = 0       '*********************************************************************
               'Do status reporting                          '********************************************************************
               Call Usb_send(txstate(1) , 0)      '********************************************************************
               Do                                 '********************************************************************
               Loop Until _usb_status._usb_rxc = 1       '*******************************************************************
               Numlock_led = _usb_rx_buffer(2).0  'NumLock LED status                            ***********************
               Capslock_led = _usb_rx_buffer(2).1 'CapsLock LED status                           ***********************
               Scrolllock_led = _usb_rx_buffer(2).2       'ScrollLock LED status                         ***********************

            Case _usb_req_set_idle:
               Idlemode = 1
               Call Usb_send(txstate(1) , 0)      'Do status reporting
         End Select
   End Select

   If Senddescriptor = 1 Then
      Call Usb_senddescriptor(txstate(1) , _usb_rx_buffer(8))
   End If

End Sub

Sub Usb_senddescriptor(txstate() As Byte , Maxlen As Byte)       'Break the descriptor into packets and send to TxState
   Local Size As Byte
   Local I As Byte
   Local J As Byte
   Local Timeout As Word
   Read Size
   If Maxlen < Size Then Size = Maxlen
   I = 2
   For J = 1 To Size
      Incr I
      Read Txstate(i)
      If I = 10 Or J = Size Then
         I = I - 2
         Call Usb_send(txstate(1) , I)
         While Txstate(1)._usb_txc = 0
            Timeout = 0
            While _usb_pin._usb_dminus = 0        'To prevent an infinite loop, check for reset here
               Incr Timeout
               If Timeout = 1000 Then
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

   Txstate(1) = Txstate(1) And _usb_syncmask      'Reset all the flags except TxSync and RxSync
    _usb_crc = Crcusb(txstate(3) , Count)
   Count = Count + 3                              'Bytes to transmit will be PID + DATA payload + CRC16
   Txstate(1) = Txstate(1) + Count
   Txstate(count) = Low(_usb_crc)
   Incr Count
   Txstate(count) = High(_usb_crc)
   Txstate(2) = _usb_pid_data1                    'Add the appropriate DATAx PID
   If Txstate(1)._usb_txsync = 0 Then
      Txstate(2) = _usb_pid_data0
   End If
   Txstate(1)._usb_rtt = 1                        'The last step is to signal that the packet is Ready To Transmit
   Txstate(1)._usb_txc = 0
End Sub

Sub Usb_reset()
   'Reset the receive flags
   _usb_status._usb_rtr = 1
   _usb_status._usb_rxc = 0
   'Reset the transmit flags
   _usb_tx_status(1) = _usb_endp_init
   _usb_tx_status2(1) = _usb_endp_init
   _usb_tx_status3(1) = _usb_endp_init
   _usb_deviceid = 0                              'Reset the device ID to 0
   Idlemode = 0
End Sub