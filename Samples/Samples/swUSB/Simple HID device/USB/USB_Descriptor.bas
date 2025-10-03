$nocompile

Const Size_hid_reportdescriptor = 33                        ' Размер структуры HID дескриптора

'*******************************************************************************
'**************** Дескрипторы, сохранённые в EEPROM или FLASH ******************
'                     НЕ ИЗМЕНЯТЬ ПОРЯДОК СЛЕДОВАНИЯ ДЕСКРИПТОРОВ!
'
#if _usb_use_eeprom = 1
   $eeprom                                                  ' Дескрипторы во EEPROM
#else
   $data                                                    ' Дескрипторы во FLASH
#endif

'Дескрипторы устройства
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

#if _usb_hids > 0
'_usb_HIDDescriptor
Data _usb_hid_descr_len , _usb_desc_hid , _usb_hid_releasel , _usb_hid_releaseh
Data _usb_hid_country , _usb_hid_numdescriptors

'Next follows a list of bType and wLength bytes/words for each report and
'physical descriptor.  There must be at least 1 report descriptor.  In practice,
'There are usually 0 physical descriptors and only 1 report descriptor.
Data _usb_desc_report
Data Size_hid_reportdescriptor , 0
'End of report/physical descriptor list
#endif

#if _usb_endpoints > 1
'_usb_EndpointDescriptor
Data 7 , _usb_desc_endpoint , _usb_endp2attr , _usb_endp2type , 8 , 0
Data _usb_endp2interval
#endif

#if _usb_endpoints > 2
'_usb_EndpointDescriptor
Data 7 , _usb_desc_endpoint , _usb_endp3attr , _usb_endp3type , 8 , 0
Data _usb_endp3interval
#endif



#if _usb_hids > 0
' Дескриптор сообщения (репорта), описывающий тип HID устройства и его характеристики
_usb_hid_reportdescriptor:
Data Size_hid_reportdescriptor                              ' Размер дескриптора в байтах.
' Тип устройства. В данном случае, это нестандартное HID устройство
Data &H06 , &H00 , &HFF                                     ' Usage_page(vendor Defined Page 1)
Data &H09 , &H01                                            ' Usage(vendor Usage 1)
Data &HA1 , &H02                                            ' Collection(logical)
' Описание конечной точки, типа Input
Data &H09 , &H01                                            ' Usage(pointer)
Data &H15 , &H00                                            ' Logical_minimum(0)
Data &H25 , &HFF                                            ' Logical_maximum(255)
Data &H75 , &H08                                            ' Report_size(8)
Data &H95 , &H01                                            ' Report_count(1)
Data &H81 , &H02                                            ' Input(data , Var , Abs)
' Описание конечной точки, типа Output
Data &H09 , &H01                                            ' Usage(pointer)
Data &H15 , &H00                                            ' Logical_minimum(0)
Data &H26 , &HFF , 0                                        ' Logical_maximum(255)
Data &H75 , &H08                                            ' Report_size(8)
Data &H95 , &H01                                            ' Report_count(1)
Data &H91 , &H02                                            ' Output(data , Var , Abs)

Data &HC0                                                   ' End_collection
#endif


'Языковой дескриптор, используемый по умолчанию (индекс 0)
_usb_langdescriptor:
Data 4 , 4 , _usb_desc_string , 09 , 04 , 0 , 0             '&h0409 = English

'***************************** Строковые дескрипторы ***************************

'Эти строковые дескрипторы обязательно должны быть в формате юникода
'Для их создания, можно использовать утилиту "Bascom_USB_descriptor.exe", прилагаемую к статье.

'Дескриптор изготовителя (unicode)
_usb_mandescriptor:
Data 41 , 41 , _usb_desc_string
Data "p" , "u" , "r" , "e" , "-" , "b" , "a" , "s" , "i" , "c" , "."
Data "n" , "a" , "r" , "o" , "d" , "." , "r" , "u" , 0 , 0

'Product Descriptor (unicode)
_usb_proddescriptor:
' HID устройство
Data 31 , 31 , _usb_desc_string
Data &H48 , &H00 , &H49 , &H00 , &H44 , &H00 , &H20 , &H00 , &H43 , &H04
Data &H41 , &H04 , &H42 , &H04 , &H40 , &H04 , &H3E , &H04 , &H39 , &H04
Data &H41 , &H04 , &H42 , &H04 , &H32 , &H04 , &H3E , &H04 , &H00 , 0 , 0

' Дескриптор серийного номера (unicode)
_usb_numdescriptor:
Data 6 , 6 , _usb_desc_string
Data "2" , 0 , 0