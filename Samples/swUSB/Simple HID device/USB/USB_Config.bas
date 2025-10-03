$nocompile

'Подключение библиотеки - USB драйвера.
$lib "swusb.lbx"
' Экспорт функций из библиотеки.
$external _swusb
$external Crcusb
Declare Function Crcusb(buffer() As Byte , Count As Byte) As Word

' Декларация подпрограмм.
Declare Sub Usb_refresh()
Declare Sub Usb_reset()
Declare Sub Usb_processsetup(txstate() As Byte)
Declare Sub Usb_send(txstate() As Byte , Byval Count As Byte)
Declare Sub Usb_senddescriptor(txstate() As Byte , Maxlen As Byte)

'*******************************************************************************
'*************************** Конфигурация USB **********************************
'
'Далее производится конфигурирование USB драйвера микроконтроллера.

'******************************* USB Connections *******************************

' Укажите к какому порту будут подключены линии шины USB.
_usb_port Alias Portd
_usb_pin Alias Pind
_usb_ddr Alias Ddrd

'Выберите к каким выводам порта, будут подключены линии D+ и D- шины USB.
'ВНИМАНИЕ! линия D+ должна быть подключена к ножке контроллера, отвечающей за
'внешнее прерывание INT0.
Const _usb_dplus = 2                                        ' Линия D+ шины USB
Const _usb_dminus = 3                                       ' Линия D- шины USB

'Выводы микроконтроллера, отвечающие за работу с USB, конфигурируются как входы.
Config Pind.2 = Input
Config Pind.3 = Input

'disable pullups
_usb_port._usb_dplus = 0
_usb_port._usb_dminus = 0


'Использовать EEPROM или FLASH память для хранения USB дескрипторов
'0 - FLASH; 1 - EEPROM.  Использование EEPROM уменьшит размер HEX и BIN файлов.
Const _usb_use_eeprom = 0

'Don't wait for sent packets to be ACK'd by the host before marking the
'transmission as complete.  This option breaks the USB spec but improves
'throughput with faster polling speeds.
'This may cause reliability issues.  Should leave set to 0 to be safe.
Const _usb_assume_ack = 0

'*************************** Дескриптор устройства *****************************

'USB Vendor ID and Product ID (Assigned by USB-IF)
'Идентификаторы устройства. Они должны быть уникальными для всех USB устройств!
Const _usb_vid = &H1234
Const _usb_pid = &H0001

'USB Device Release Number (BCD)
'Номер версии устройства
Const _usb_devrel = &H0002

'USB Release Spec (BCD)
Const _usb_spec = &H0110

'Класс USB устройства, подкласс, и протокол (assigned by USB-IF).
'&h00 = Класс задан в интерфейсе.(в данном случае, в интерфейсе HID класс)
'&hFF = Vendor определяет класс устройства (Нужно разрабатывать драйвер для ПК)
'Более подробная информация на сайте http://www.usb.org/developers/defined_class
Const _usb_devclass = 0
Const _usb_devsubclass = 0
Const _usb_devprot = 0

'Укажите индексы строковых UNICODE дескрипторов производителя, имени продукта и
'серийного номера устройства. 0 - дескриптор отсутствует.
'Эти дескрипторы можно найти в файле USB_Descriptor.bas
Const _usb_imanufacturer = 1
Const _usb_iproduct = 2
Const _usb_iserial = 3

'Число конфигураций для этого устройства (обычно 1).
Const _usb_numconfigs = 1

'Число интерфейсов для этого устройства (обычно 1).
Const _usb_numifaces = 1

'Номер конфигурации (не редактировать!)
Const _usb_confignum = 1

'Индекс дескриптора, который описывает эту конфигурацию (0 - отсутствует)
Const _usb_iconfig = 2

'  ************************** Управление питанием ******************************

'&H80 = Устройство питается от шины USB.
'&HC0 = Устройство имеет свой источник питания.
Const _usb_powered = &H80

'Потребляемый устройством ток * 2mA  (500mA max)
Const _usb_maxpower = 100                                   '100 * 2mA = 200mA

'  ************************** Дескрипторы интерфейса ***************************

'Число интерфейсов данного устройства (1 или 2)
Const _usb_ifaces = 1

'Номер интерфейса
Const _usb_ifaceaddr = 0

'Альтернативный индекс
Const _usb_alternate = 0

'USB класс интерфейса, подкласс, и протокол (назначенное USB-IF).
'&h00 = ЗАРЕЗЕРВИРОВАНО!
'&hFF = Vendor определяет класс устройства (Нужно разрабатывать драйвер для ПК)
'       Другие значения, определяют интерфейс класса устройства (например, HID)
'Более подробная информация на сайте http://www.usb.org/developers/defined_class
Const _usb_ifclass = 3
Const _usb_ifsubclass = 0
Const _usb_ifprotocol = 0

'Индекс в строковом дескрипторе для этого интерфейса (0 - отсутствует)
Const _usb_iiface = 0

'Если создаётся HID устройство, то константа должна быть равна 1
Const _usb_hids = 1

'BCD HID releasenumber.  Current spec is 1.11
Const _usb_hid_release = &H0111

'Country code from page 23 of the HID 1.11 specifications.
'Usually the country code is 0 unless you are making a keyboard.
Const _usb_hid_country = 0

'Число HID дескрипторов сообщения (report).
Const _usb_hid_numdescriptors = 1


'  ************************* Конфигурация конечных точек ***********************

'Число конечных точек (исключая  нулевую) для текущего интерфейса.
Const _usb_ifaceendpoints = 2

'Адрес дополнительных конечных точек.
'Если конечная точка не нужна - закомментируйте константу.
Const _usb_endp2addr = 1
Const _usb_endp3addr = 2

'Направление: 0=Out (из компьютера), 1=In (в компьютер).
'Проигнорировано управляющими конечными точками.
Const _usb_endp2direction = 1
Const _usb_endp3direction = 0

'Правильные типы - 0 для управляющей конечной точки или 3 - для прерываний.
Const _usb_endp2type = 3
Const _usb_endp3type = 3

'Интервал опроса (мс) для конечных точек.
'Проигнорировано управляющими конечными точками.
'Должно быть не менее 10.
Const _usb_endp2interval = 20
Const _usb_endp3interval = 20

'*******************************************************************************
'В подключаемом файле, находится код, автоконфигурации драйвера микроконтроллера
'Вычисляются требуемые размеры буферов для созданных конечных точек, создаются
'константы для дескрипторов и многое другое.
'Этот файл не следует модифицировать!
'$include "Const_swusb-includes.bas"
'*******************************************************************************

'**************************** USB Interrupt And Init ***************************
'Инициализация всех переменных, флагов и битов синхронизации.
Call Usb_reset()

Const _usb_intf = Intf0
Config Int0 = Rising
'Назначение подпрограммы (из "swusb.lbx") прерываний от INT0.
On Int0 Usb_isr Nosave
Enable Int0