' USB Midi Controller Y.D.E. 2010
'Test setup is on the STK500 with Vtarget set to 3.6V
'Using an atmega644 and external 12MHz crystal
'
'when you connect the RS232 SPARE to your COM port of your PC
'you must connect TXD SPARE to PORTD.1 (txd pin)

'Save about 38 bytes of code size
'$noramclear

$hwstack = 40
$swstack = 40
$framesize = 50                                   '24 bytes reserved

$regfile = "m16def.dat"

$crystal = 12000000


'Include the software USB library
$lib "swusb.lbx"
$external _swusb
$external Crcusb
Declare Function Crcusb(buffer() As Byte , Count As Byte) As Word

Declare Sub Usb_reset()
Declare Sub Usb_processsetup(txstate() As Byte)
Declare Sub Usb_send(txstate() As Byte , Byval Count As Byte)
Declare Sub Usb_senddescriptor(txstate() As Byte , Maxlen As Byte)

'*******************************************************************************
'*************************** Конфигурация USB **********************************
'
'Set the following parameters to match your hardware configuration and USB
'device parameters.

'******************************* USB Connections *******************************

'Define the AVR port that the two USB pins are connected to
_usb_port Alias Portd
_usb_pin Alias Pind
_usb_ddr Alias Ddrd

'Define the D+ and D- pins. (put D+ on an interrupt pin)
Const _usb_dplus = 2
Const _usb_dminus = 3


'Configure the pins as inputs
Config Pind.2 = Input
Config Pind.3 = Input
Config Pind.6 = Input

Config Pind.0 = Output
Config Pind.7 = Output

Config Pinb.2 = Input                             ' клавиши
Config Pinb.3 = Input

Config Pinb.4 = Output
Config Pinb.5 = Output
Config Pinb.6 = Output
Config Pinb.7 = Output



Config Portc = Output
Portc = &HFF
Portb = &HFF

'disable pullups
_usb_port._usb_dplus = 0
_usb_port._usb_dminus = 0




'*******************************************************************************
'************************* USB константы конфигурации **************************

'Использовать EEPROM или FLASH для хранения USB дескрипторов
'1 = EEPROM, 0 = FLASH.  Использование EEPROM немного уменьшит размер кода.
Const _usb_use_eeprom = 0

'Don't wait for sent packets to be ACK'd by the host before marking the
'transmission as complete.  This option breaks the USB spec but improves
'throughput with faster polling speeds.
'This may cause reliability issues.  Should leave set to 0 to be safe.
Const _usb_assume_ack = 0

'  *************************** Дескриптор устройства****************************

'USB Vendor ID and Product ID (Assigned by USB-IF)
Const _usb_vid = &H16C0
Const _usb_pid = &H05E4

'USB Device Release Number (BCD)
Const _usb_devrel = &H0001

'USB Release Spec (BCD)
Const _usb_spec = &H0110

'USB Device Class, subclass, and protocol (assigned by USB-IF).
'&h00 = Class defined by interface. (HID is defined in the interface)
'&hFF = Vendor-defined class (You must write your own PC driver)
'See http://www.usb.org/developers/defined_class  for more information
Const _usb_devclass = 0
Const _usb_devsubclass = 0
Const _usb_devprot = 0

'These are _indexes_ to UNICODE string descriptors for the manufacturer,
'product name, and serial number.  0 means there is no descriptor.
Const _usb_imanufacturer = 1
Const _usb_iproduct = 2
Const _usb_iserial = 0

'Количество конфигураций для этого устройства.  Не изменяйте это если,
'вы не знаете то, что Вы делаете!  Обычно равно 1
Const _usb_numconfigs = 1

'  *************************** Конфигурация дискиптора *************************

'Количество интерфейсов для этого устройства (Обычно 1)
Const _usb_numifaces = 1

'Номер конфигурации (не редактировать!)
Const _usb_confignum = 1

'Индекс дескриптора строки УНИКОДА, который описывает эту конфигурацию (0 - отсутствует)
Const _usb_iconfig = 2

'&H80 = Устройство питается от шины USB.
'&HC0 = Устройство имеет свой источник питания.
Const _usb_powered = &H80                         '&HC0

'Потребляемый устройством ток * 2mA  (500mA max)
Const _usb_maxpower = 50                          '50 * 2mA = 100mA

'  ************************** Дескрипторы интерфейса ***************************

'Число интерфейсов для этого устройства (1 или 2)
Const _usb_ifaces = 1

'Номер интерфейса
Const _usb_ifaceaddr = 2

'Альтернативный индекс
Const _usb_alternate = 0

'Количество конечных точек для этого интерфейса (исключая  нулевую)
Const _usb_ifaceendpoints = 1

'USB класс интерфейса, подкласс, и протокол (назначенное USB-IF).
'&h00 = RESERVED
'&hFF = Vendor-defined class (You must write your own PC driver)
'       Other values are USB interface device class. (such as HID)
'See http://www.usb.org/developers/defined_class  for more information
Const _usb_ifclass = 1
Const _usb_ifsubclass = 1
Const _usb_ifprotocol = 0

'Индекс в дескрипторе строки УНИКОДА для этого интерфейса (0 - отсутствует)
Const _usb_iiface = 0

'  ************************* Дополнительный HID дескриптор *********************
'HID класс, устройств являются вещами подобно клавиатуре, мыши, джойстику.
'See http://www.usb.org/developers/hidpage/  for the specification,
'tools, and resources.

'Учтите, что для устройства HID, класс устройства, подкласс, и протокол
'должен быть 0. Класс интерфейса должен быть 3 (HID).
'Подкласс Интерфейса и протокола должны быть 0 если Вы не делаете
'клавиатурой или мышь, которые поддерживают встроенный протокол.
'Смотрите страницы 8 и 9 спецификации HID 1.11 PDF.

'Число HID дескриптора  (EXCLUDING report and physical)
'Если Вы не делаете устройство HID, тогда установите эту константу на 0
Const _usb_hids = 1

'BCD HID releasenumber.  Current spec is 1.11
Const _usb_hid_release = &H0111

'Country code from page 23 of the HID 1.11 specifications.
'Usually the country code is 0 unless you are making a keyboard.
Const _usb_hid_country = 0

' Номер сообщения и физических дескрипторов для этого HID
' Должно быть в 1! Все HID устройства иметь по крайней мере 1 дескриптор сообщения.
Const _usb_hid_numdescriptors = 1

'Use a software tool to create the report descriptor and $INCLUDE it.


'  ************************* Дескриптор конечной точки *************************

'Конечная точка 0 не включается здесь.  Эти - только для других
'конечных точек.
'Примечание: HID устройства требуют 1 прерывание В конечной точке

'Адрес дополнительных конечных точек (Должно быть > 0. сделать  комментарием, если не требуется)
Const _usb_endp2addr = 1
Const _usb_endp3addr = 1

'Правильные типы - 0 для управления или 3 для прерывания
Const _usb_endp2type = 3
Const _usb_endp3type = 3                          '0

'Направление: 0=Out (от компа), 1=In (в комп).  Проигнорированно управляющими конечными точками
Const _usb_endp2direction = 1
Const _usb_endp3direction = 0

' Интервал опроса (мс) для конечных точек прерывания.
' Проигнорированно управляющими конечными точками
' (Должно быть не менее 10)
Const _usb_endp2interval = 200
Const _usb_endp3interval = 100

'*******************************************************************************
'The includes need to go right here--between the configuration constants above
'and the start of the program below.  The includes will automatically calculate
'constants based on the above configuration, dimension required variables, and
'allocate transmit and receive buffers.  Nothing inside the includes file needs
'to be modified.
$include "Const_swusb-includes.bas"
'*******************************************************************************

'**************************** USB Interrupt And Init ***************************
'Инициализация всех переменных, флагов, и бит синхронизации
Call Usb_reset()

Reset Watchdog

Portd.0 = 0
Waitms 400
Portd.0 = 1


Config Watchdog = 2048
Start Watchdog
Reset Watchdog
Dim Midimsg1(4) As Byte
Dim Midimsg2(4) As Byte
Dim Key(24) As Byte
Dim Lastkey(24) As Byte
Dim K As Byte


Const _usb_intf = Intf0
Config Int0 = Rising
On Int0 Usb_isr Nosave
Enable Int0

Enable Interrupts

'*******************************************************************************
'*************************** Завершение концигурации USB ***********************

Dim Buttons_current As Byte
Dim Buttons_last As Byte
Dim Resetcounter As Word
Dim Idlemode As Byte

Config Adc = Single , Prescaler = Auto
Start Adc
'Enable Interrupts

Dim B As Byte
Dim B1 As Byte
Dim W As Byte
Dim W1 As Byte
Dim W2 As Byte
Dim Ww As Word


W1 = 63


Do
   Reset Watchdog
   Resetcounter = 0

   'Флаг сброса
   While _usb_pin._usb_dminus = 0
      Incr Resetcounter
      If Resetcounter = 1000 Then
         Call Usb_reset()
      End If
   Wend

   'Флаг полученных данных
   If _usb_status._usb_rxc = 1 Then

      If _usb_status._usb_setup = 1 Then
         'Обработка пакет/управление сообщения установки
         Call Usb_processsetup(_usb_tx_status(1))
      End If

      'Восстановление бита RXC и установка бита RTR (готовность получить новый пакет)
      _usb_status._usb_rtr = 1
      _usb_status._usb_rxc = 0

   End If

   B1 = Encoder(pinb.0 , Pinb.1 , Links , Rechts , 0)       ' опрос энкодера
   Ww = Getadc(0)                                 ' опрос АЦП
   Shift Ww , Right , 3                           'уменьшение разрядности 127 макс значение
   W = Ww
   Ww = Getadc(0)
   Shift Ww , Right , 3
   W1 = Ww
   Ww = Getadc(0)
   Shift Ww , Right , 3
   W2 = Ww
   If W = W1 And W = W2 And W <> B Then           'подавление ложных срабатываний
     B = W                                        'формирование миди сообщения
      Midimsg1(1) = &H0B                          ' команда Control Change (Только для USB ) см. www.usb.org/developers/devclass_docs/midi10.pdf
      Midimsg1(2) = &HB0                          ' команда Control Change Midi канал 1
      Midimsg1(3) = &H02                          ' Номер ноты
      Midimsg1(4) = W                             ' Значение
   Gosub Send_u4                                  ' отправка сообщения
   End If

   'сканирование клавиатуры
   Portc.1 = 0 : Key(1) = Pinb.3 : Key(13) = Pinb.2 : Portc.1 = 1       '3c 48коды нот
   Portc.2 = 0 : Key(2) = Pinb.3 : Key(14) = Pinb.2 : Portc.2 = 1       '3e 49
   Portc.0 = 0 : Key(3) = Pinb.3 : Key(15) = Pinb.2 : Portc.0 = 1       '3d 4a
   Portc.3 = 0 : Key(4) = Pinb.3 : Key(16) = Pinb.2 : Portc.3 = 1       '3f 4b
   Portc.4 = 0 : Key(5) = Pinb.3 : Key(17) = Pinb.2 : Portc.4 = 1       '40 4c
   Portc.5 = 0 : Key(6) = Pinb.3 : Key(18) = Pinb.2 : Portc.5 = 1       '41 4d
   Portc.7 = 0 : Key(7) = Pinb.3 : Key(19) = Pinb.2 : Portc.7 = 1       '42 4e
   Portc.6 = 0 : Key(8) = Pinb.3 : Key(20) = Pinb.2 : Portc.6 = 1       '43 4f
   Portb.5 = 0 : Key(9) = Pinb.3 : Key(21) = Pinb.2 : Portb.5 = 1       '44 50
   Portb.6 = 0 : Key(10) = Pinb.3 : Key(22) = Pinb.2 : Portb.6 = 1       '45  51
   Portb.4 = 0 : Key(11) = Pinb.3 : Key(23) = Pinb.2 : Portb.4 = 1       '46  52
   Portb.7 = 0 : Key(12) = Pinb.3 : Key(24) = Pinb.2 : Portb.7 = 1       '47  53

   For K = 1 To 24
   If Key(k) <> Lastkey(k) Then                   ' проверка нажатий клавиатуры
    Lastkey(k) = Key(k)
    If Key(k) = 1 Then
      Midimsg1(1) = &H08                          ' команда Нота Выкл (Только для USB ) см. www.usb.org/developers/devclass_docs/midi10.pdf
      Midimsg1(2) = &H80                          ' 8-Нота выкл 0- канал №1
      Midimsg1(3) = K + 59                        ' Номер ноты
      Midimsg1(4) = &H00                          ' Длительность
      Gosub Send_u4
    Else
      Midimsg1(1) = &H09                          ' команда Нота Вкл (Только для USB ) см. www.usb.org/developers/devclass_docs/midi10.pdf
      Midimsg1(2) = &H90                          ' 8-Нота вкл 0- канал №1
      Midimsg1(3) = K + 59                        ' Номер ноты
      Midimsg1(4) = &H7F                          ' Длительность
      Gosub Send_u4
    End If
   End If
   Next K
Loop


Links:                                            ' энкодер в лево
      Midimsg1(1) = &H0B                          ' команда  Control Change
      Midimsg1(2) = &HB0                          ' команда Control Change
      Midimsg1(3) = &H01                          '
      Midimsg1(4) = &H3F                          ' Значение
      Midimsg2(1) = &H0B                          'команда Control Change
      Midimsg2(2) = &HB0                          'команда Control Change
      Midimsg2(3) = &H01                          '
      Midimsg2(4) = &H00                          ' Значение
Gosub Send_u8
Return

Rechts:                                           ' энкодер в право
      Midimsg1(1) = &H0B                          '
      Midimsg1(2) = &HB0                          '
      Midimsg1(3) = &H01                          '
      Midimsg1(4) = &H41                          '
      Midimsg2(1) = &H0B                          '
      Midimsg2(2) = &HB0                          '
      Midimsg2(3) = &H01                          '
      Midimsg2(4) = &H7F                          '
Gosub Send_u8
Return

Send_u4:                                          'посылка одной миди команды
         If _usb_tx_status._usb_txc = 1 Then
         Portd.0 = 0
            _usb_tx_buffer2(2) = Midimsg1(1)      '_usb_tx_buffer2(2) первый элемент имеет индекс 2
            _usb_tx_buffer2(3) = Midimsg1(2)
            _usb_tx_buffer2(4) = Midimsg1(3)
            _usb_tx_buffer2(5) = Midimsg1(4)
           Call Usb_send(_usb_tx_status2(1) , 4)  ' или Call Usb_send(_usb_tx_status2 , 4) для одного сообщения
         Portd.0 = 1
         End If
Return

Send_u8:                                          ' посылка двух миди команд за один раз
         If _usb_tx_status._usb_txc = 1 Then
         Portd.0 = 0
            _usb_tx_buffer2(2) = Midimsg1(1)      '_usb_tx_buffer2(2) первый элемент имеет индекс 2
            _usb_tx_buffer2(3) = Midimsg1(2)
            _usb_tx_buffer2(4) = Midimsg1(3)
            _usb_tx_buffer2(5) = Midimsg1(4)

            _usb_tx_buffer2(6) = Midimsg2(1)
            _usb_tx_buffer2(7) = Midimsg2(2)
            _usb_tx_buffer2(8) = Midimsg2(3)
            _usb_tx_buffer2(9) = Midimsg2(4)
           Call Usb_send(_usb_tx_status2(1) , 8)  ' или Call Usb_send(_usb_tx_status2 , 4) для одного сообщения
         Portd.0 = 1
         End If
Return
End

'*******************************************************************************
'**************** Дескрипторы, сохранённые в EEPROM или FLASH ******************
'                     Не изменять порядок дескрипторов!
'
#if _usb_use_eeprom = 1
   $eeprom
#else
   $data
#endif

'Дескрипторы устройства MIDI
_usb_devicedescriptor:
Data 18                                           'length of descriptor in bytes
Data 18                                           'sizeof(usbDescriptorDevice): length of descriptor in bytes
Data _usb_desc_device                             '1  descriptor type
Data _usb_specl , _usb_spech                      '&H10 , &H01  USB version supported
Data _usb_devclass                                '0  device class: defined at interface level
Data _usb_devsubclass                             '0  subclass
Data _usb_devprot                                 '0  protocol
Data 8                                            'max packet size
Data _usb_vidl , _usb_vidh                        '&HC0 , &H16  USB_CFG_VENDOR_ID, /* 2 bytes */
Data _usb_pidl , _usb_pidh                        '&HE4 , &H05  USB_CFG_DEVICE_ID, /* 2 bytes */
Data _usb_devrell , _usb_devrelh                  '&H01 , &H00  USB_CFG_DEVICE_VERSION, /* 2 bytes */
Data _usb_imanufacturer                           '1  manufacturer string index
Data _usb_iproduct                                '2  product string index
Data _usb_iserial                                 '0  serial number string index
Data _usb_numconfigs                              '1  number of configurations


'Retrieving the configuration descriptor also gets all the interface and
'endpoint descriptors for that configuration.  It is not possible to retrieve
'only an interface or only an endpoint descriptor.  Consequently, this is a
'large transaction of variable size.

_usb_configdescriptor:
Data 101                                          '_usb_descr_total
Data 9                                            ' sizeof(usbDescrConfig): length of descriptor in bytes */
Data 2                                            'Usbdescr_config , / * Descriptor Type * /
Data 101 , 0                                      ',   /* total length of data returned (including inlined descriptors) */
Data 2                                            ',   /* number of interfaces in this configuration */
Data 1                                            ',   /* index of this configuration */
Data 0                                            ',   /* configuration name string index */
Data &H80                                         'USB_CFG_IS_SELF_POWERED
Data &H32                                         ' USB_CFG_MAX_BUS_POWER / 2, /* max USB current in 2mA units */

'Ac Interface Descriptor Follows Inline
Data 9                                            ',   /* sizeof(usbDescrInterface): length of descriptor in bytes */
Data 4                                            'USBDESCR_INTERFACE, /* descriptor type */
Data 0                                            ',   /* index of this interface */
Data 0                                            ',   /* alternate setting for this interface */
Data 0                                            ',   /* endpoints excl 0: number of endpoint descriptors to follow */
Data 1                                            ',   /* */
Data 1                                            ',   /* */
Data 0                                            ',   /* */
Data 0                                            ',   /* string index for interface */

'Ac Class -specific Descriptor
Data 9                                            ',   /* sizeof(usbDescrCDC_HeaderFn): length of descriptor in bytes */
Data 36                                           ',   /* descriptor type */
Data 1                                            ',   /* header functional descriptor */
Data 0 , 1                                        ',  /* bcdADC */
Data 9 , 0                                        ',   /* wTotalLength */
Data 1                                            ',   /* */
Data 1                                            ',   /* */

'// B.4 MIDIStreaming Interface Descriptors
'// B.4.1 Standard MS Interface Descriptor
Data 9                                            ',   /* length of descriptor in bytes */
Data 4                                            'USBDESCR_INTERFACE, /* descriptor type */
Data 1                                            ',   /* index of this interface */
Data 0                                            ',   /* alternate setting for this interface */
Data 2                                            ',   /* endpoints excl 0: number of endpoint descriptors to follow */
Data 1                                            ',   /* AUDIO */
Data 3                                            ',   /* MS */
Data 0                                            ',   /* unused */
Data 0                                            ',   /* string index for interface */

'// B.4.2 Class-specific MS Interface Descriptor
Data 7                                            ',   /* length of descriptor in bytes */
Data 36                                           ',   /* descriptor type */
Data 1                                            ',   /* header functional descriptor */
Data 0 , 1                                        ',  /* bcdADC */
Data 65 , 0                                       ',   /* wTotalLength */

'// B.4.3 MIDI IN Jack Descriptor
Data 6                                            ',   /* bLength */
Data 36                                           ',   /* descriptor type */
Data 2                                            ',   /* MIDI_IN_JACK desc subtype */
Data 1                                            ',   /* EMBEDDED bJackType */
Data 1                                            ',   /* bJackID */
Data 0                                            ',   /* iJack */

'Midi In Jack Descriptor
Data 6                                            ',   /* bLength */
Data 36                                           ',   /* descriptor type */
Data 2                                            ',   /* MIDI_IN_JACK desc subtype */
Data 2                                            ',   /* EXTERNAL bJackType */
Data 2                                            ',   /* bJackID */
Data 0                                            ',   /* iJack */

'//B.4.4 MIDI OUT Jack Descriptor
Data 9                                            ',   /* length of descriptor in bytes */
Data 36                                           ',   /* descriptor type */
Data 3                                            ',   /* MIDI_OUT_JACK descriptor */
Data 1                                            ',   /* EMBEDDED bJackType */
Data 3                                            ',   /* bJackID */
Data 1                                            ',   /* No of input pins */
Data 2                                            ',   /* BaSourceID */
Data 1                                            ',   /* BaSourcePin */
Data 0                                            ',   /* iJack */

Data 9                                            ',   /* bLength of descriptor in bytes */
Data 36                                           ',   /* bDescriptorType */
Data 3                                            ',   /* MIDI_OUT_JACK bDescriptorSubtype */
Data 2                                            ',   /* EXTERNAL bJackType */
Data 4                                            ',   /* bJackID */
Data 1                                            ',   /* bNrInputPins */
Data 1                                            ',   /* baSourceID (0) */
Data 1                                            ',   /* baSourcePin (0) */
Data 0                                            ',   /* iJack */


'// B.5 Bulk OUT Endpoint Descriptors
'//B.5.1 Standard Bulk OUT Endpoint Descriptor
Data 9                                            ',   /* bLenght */
Data 5                                            'USBDESCR_ENDPOINT, /* bDescriptorType = endpoint */
Data 1                                            ',   /* bEndpointAddress OUT endpoint number 1 */
Data 3                                            ',   /* bmAttributes: 2:Bulk, 3:Interrupt endpoint */
Data 8 , 0                                        ',   /* wMaxPacketSize */
Data 10                                           ',   /* bIntervall in ms */
Data 0                                            ',   /* bRefresh */
Data 0                                            ',   /* bSyncAddress */

'// B.5.2 Class-specific MS Bulk OUT Endpoint Descriptor
Data 5                                            ',   /* bLength of descriptor in bytes */
Data 37                                           ',   /* bDescriptorType */
Data 1                                            ',   /* bDescriptorSubtype */
Data 1                                            ',   /* bNumEmbMIDIJack  */
Data 1                                            ',   /* baAssocJackID (0) */


'//B.6 Bulk IN Endpoint Descriptors
Data 9                                            ',   /* bLenght */
Data 5                                            'USBDESCR_ENDPOINT, /* bDescriptorType = endpoint */
Data &H81                                         ',   /* bEndpointAddress IN endpoint number 1 */
Data 3                                            ',   /* bmAttributes: 2: Bulk, 3: Interrupt endpoint */
Data 8 , 0                                        ',   /* wMaxPacketSize */
Data 10                                           ',   /* bIntervall in ms */
Data 0                                            ',   /* bRefresh */
Data 0                                            ',   /* bSyncAddress */

'// B.6.2 Class-specific MS Bulk IN Endpoint Descriptor
Data 5                                            ',   /* bLength of descriptor in bytes */
Data 37                                           ',   /* bDescriptorType */
Data 1                                            ',   /* bDescriptorSubtype */
Data 1                                            ',   /* bNumEmbMIDIJack (0) */
Data 3                                            ',   /* baAssocJackID (0) */


'#if _usb_hids > 0
'_usb_HIDDescriptor
'Data _usb_hid_descr_len , _usb_desc_hid , _usb_hid_releasel , _usb_hid_releaseh
'Data _usb_hid_country , _usb_hid_numdescriptors

'Next follows a list of bType and wLength bytes/words for each report and
'physical descriptor.  There must be at least 1 report descriptor.  In practice,
'There are usually 0 physical descriptors and only 1 report descriptor.
'Data _usb_desc_report
'Data 20 , 0                                                 '48 , 0
'End of report/physical descriptor list
'#endif

'#if _usb_endpoints > 1
'_usb_EndpointDescriptor
'Data 7 , _usb_desc_endpoint , _usb_endp2attr , _usb_endp2type , 8 , 0
'Data _usb_endp2interval
'#endif

'#if _usb_endpoints > 2
''_usb_EndpointDescriptor
'Data 7 , _usb_desc_endpoint , _usb_endp3attr , _usb_endp3type , 8 , 0
'Data _usb_endp3interval
'#endif
'------------------------------------------------




#if _usb_hids > 0
_usb_hid_reportdescriptor:
Data 0                                            'Не HID устройство длинна дескриптора 0
#endif

'*****************************String descriptors********************************
'Yes, they MUST be written like "t","e","s","t".  Doing so pads them with
'0's.  If you write it like "test," I promise you it won't work.

'Default language descriptor (index 0)
_usb_langdescriptor:
Data 4 , 4 , _usb_desc_string , 09 , 04 , 0 , 0   '&h0409 = English
'Data 4 , 4 , _usb_desc_string , 19 , 04                     '&h0419 = Русский

'Дескриптор изготовителя (unicode)
_usb_mandescriptor:
Data 20 , 20 , _usb_desc_string
Data "Y" , "D" , "E" , "-" , "M" , "I" , "D" , "I" , 0 , 0

'Дескриптор продукта (unicode)
_usb_proddescriptor:
Data 46 , 46 , _usb_desc_string
Data "Y" , "D" , "E" , "_" , "m" , "i" , "d" , "i" , "_" , "c" , "o" , "n" , "t" , "r" , "o" , "l" , "l" , "e"
Data "r" , "_" , "V" , "1" , 0 , 0

_usb_numdescriptor:
Data 6 , 6 , _usb_desc_string
Data "1" , 0 , 0


'*******************************************************************************



'*******************************************************************************
'******************************** Subroutines **********************************
'*******************************************************************************

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
           ' Case _usb_req_get_status:                       ' 00 - Определение состояния устройства

            Case _usb_req_get_descriptor:
               Select Case _usb_rx_buffer(5)
                  Case _usb_desc_device:
                     'Отправка дескриптора устроства
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
                           'Отправка дескриптора выбраного языка
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
                           #if _usb_use_eeprom = 1
                              Readeeprom _usb_eepromaddrl , _usb_numdescriptor
                           #else
                              Restore _usb_numdescriptor
                           #endif
                           Senddescriptor = 1
                     End Select
               End Select
'            CASE _usb_REQ_GET_CONFIG:
         End Select
      Case &B00000000:
         Select Case _usb_rx_buffer(3)
'            CASE _usb_REQ_CLEAR_FEATURE: ' 01 Сброс устройства
'            CASE _usb_REQ_SET_FEATURE:   ' 03 Установить свойство
            Case _usb_req_set_address:
               'USB status reporting for control writes
               Call Usb_send(txstate(1) , 0)
               While Txstate(1)._usb_txc = 0 : Wend
               'We are now addressed.
               _usb_deviceid = _usb_rx_buffer(4)
'            CASE _usb_REQ_SET_DESCRIPTOR:
            Case _usb_req_set_config:
               'Have to do status reporting
               Call Usb_send(txstate(1) , 0)
         End Select
      'Стандартные запросы интерфейса
      Case &B10000001:
         Select Case _usb_rx_buffer(3)
'            CASE _usb_REQ_GET_STATUS:
'            CASE _usb_REQ_GET_IFACE:
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

'                  CASE _usb_DESC_PHYSICAL

'                  CASE _USB_DESC_HID

               End Select
         End Select
      Case &B00100001:
         'Class specific SET requests
         Select Case _usb_rx_buffer(3)
            'CASE _usb_REQ_SET_REPORT:
            Case _usb_req_set_idle:
               Idlemode = 1
               'Do status reporting
               Call Usb_send(txstate(1) , 0)
            'CASE _usb_REQ_SET_PROTOCOL:
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
   Idlemode = 0
End Sub

