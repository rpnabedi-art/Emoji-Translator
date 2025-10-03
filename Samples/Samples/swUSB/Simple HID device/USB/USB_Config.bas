$nocompile

'����������� ���������� - USB ��������.
$lib "swusb.lbx"
' ������� ������� �� ����������.
$external _swusb
$external Crcusb
Declare Function Crcusb(buffer() As Byte , Count As Byte) As Word

' ���������� �����������.
Declare Sub Usb_refresh()
Declare Sub Usb_reset()
Declare Sub Usb_processsetup(txstate() As Byte)
Declare Sub Usb_send(txstate() As Byte , Byval Count As Byte)
Declare Sub Usb_senddescriptor(txstate() As Byte , Maxlen As Byte)

'*******************************************************************************
'*************************** ������������ USB **********************************
'
'����� ������������ ���������������� USB �������� ����������������.

'******************************* USB Connections *******************************

' ������� � ������ ����� ����� ���������� ����� ���� USB.
_usb_port Alias Portd
_usb_pin Alias Pind
_usb_ddr Alias Ddrd

'�������� � ����� ������� �����, ����� ���������� ����� D+ � D- ���� USB.
'��������! ����� D+ ������ ���� ���������� � ����� �����������, ���������� ��
'������� ���������� INT0.
Const _usb_dplus = 2                                        ' ����� D+ ���� USB
Const _usb_dminus = 3                                       ' ����� D- ���� USB

'������ ����������������, ���������� �� ������ � USB, ��������������� ��� �����.
Config Pind.2 = Input
Config Pind.3 = Input

'disable pullups
_usb_port._usb_dplus = 0
_usb_port._usb_dminus = 0


'������������ EEPROM ��� FLASH ������ ��� �������� USB ������������
'0 - FLASH; 1 - EEPROM.  ������������� EEPROM �������� ������ HEX � BIN ������.
Const _usb_use_eeprom = 0

'Don't wait for sent packets to be ACK'd by the host before marking the
'transmission as complete.  This option breaks the USB spec but improves
'throughput with faster polling speeds.
'This may cause reliability issues.  Should leave set to 0 to be safe.
Const _usb_assume_ack = 0

'*************************** ���������� ���������� *****************************

'USB Vendor ID and Product ID (Assigned by USB-IF)
'�������������� ����������. ��� ������ ���� ����������� ��� ���� USB ���������!
Const _usb_vid = &H1234
Const _usb_pid = &H0001

'USB Device Release Number (BCD)
'����� ������ ����������
Const _usb_devrel = &H0002

'USB Release Spec (BCD)
Const _usb_spec = &H0110

'����� USB ����������, ��������, � �������� (assigned by USB-IF).
'&h00 = ����� ����� � ����������.(� ������ ������, � ���������� HID �����)
'&hFF = Vendor ���������� ����� ���������� (����� ������������� ������� ��� ��)
'����� ��������� ���������� �� ����� http://www.usb.org/developers/defined_class
Const _usb_devclass = 0
Const _usb_devsubclass = 0
Const _usb_devprot = 0

'������� ������� ��������� UNICODE ������������ �������������, ����� �������� �
'��������� ������ ����������. 0 - ���������� �����������.
'��� ����������� ����� ����� � ����� USB_Descriptor.bas
Const _usb_imanufacturer = 1
Const _usb_iproduct = 2
Const _usb_iserial = 3

'����� ������������ ��� ����� ���������� (������ 1).
Const _usb_numconfigs = 1

'����� ����������� ��� ����� ���������� (������ 1).
Const _usb_numifaces = 1

'����� ������������ (�� �������������!)
Const _usb_confignum = 1

'������ �����������, ������� ��������� ��� ������������ (0 - �����������)
Const _usb_iconfig = 2

'  ************************** ���������� �������� ******************************

'&H80 = ���������� �������� �� ���� USB.
'&HC0 = ���������� ����� ���� �������� �������.
Const _usb_powered = &H80

'������������ ����������� ��� * 2mA  (500mA max)
Const _usb_maxpower = 100                                   '100 * 2mA = 200mA

'  ************************** ����������� ���������� ***************************

'����� ����������� ������� ���������� (1 ��� 2)
Const _usb_ifaces = 1

'����� ����������
Const _usb_ifaceaddr = 0

'�������������� ������
Const _usb_alternate = 0

'USB ����� ����������, ��������, � �������� (����������� USB-IF).
'&h00 = ���������������!
'&hFF = Vendor ���������� ����� ���������� (����� ������������� ������� ��� ��)
'       ������ ��������, ���������� ��������� ������ ���������� (��������, HID)
'����� ��������� ���������� �� ����� http://www.usb.org/developers/defined_class
Const _usb_ifclass = 3
Const _usb_ifsubclass = 0
Const _usb_ifprotocol = 0

'������ � ��������� ����������� ��� ����� ���������� (0 - �����������)
Const _usb_iiface = 0

'���� �������� HID ����������, �� ��������� ������ ���� ����� 1
Const _usb_hids = 1

'BCD HID releasenumber.  Current spec is 1.11
Const _usb_hid_release = &H0111

'Country code from page 23 of the HID 1.11 specifications.
'Usually the country code is 0 unless you are making a keyboard.
Const _usb_hid_country = 0

'����� HID ������������ ��������� (report).
Const _usb_hid_numdescriptors = 1


'  ************************* ������������ �������� ����� ***********************

'����� �������� ����� (��������  �������) ��� �������� ����������.
Const _usb_ifaceendpoints = 2

'����� �������������� �������� �����.
'���� �������� ����� �� ����� - ��������������� ���������.
Const _usb_endp2addr = 1
Const _usb_endp3addr = 2

'�����������: 0=Out (�� ����������), 1=In (� ���������).
'��������������� ������������ ��������� �������.
Const _usb_endp2direction = 1
Const _usb_endp3direction = 0

'���������� ���� - 0 ��� ����������� �������� ����� ��� 3 - ��� ����������.
Const _usb_endp2type = 3
Const _usb_endp3type = 3

'�������� ������ (��) ��� �������� �����.
'��������������� ������������ ��������� �������.
'������ ���� �� ����� 10.
Const _usb_endp2interval = 20
Const _usb_endp3interval = 20

'*******************************************************************************
'� ������������ �����, ��������� ���, ���������������� �������� ����������������
'����������� ��������� ������� ������� ��� ��������� �������� �����, ���������
'��������� ��� ������������ � ������ ������.
'���� ���� �� ������� ��������������!
'$include "Const_swusb-includes.bas"
'*******************************************************************************

'**************************** USB Interrupt And Init ***************************
'������������� ���� ����������, ������ � ����� �������������.
Call Usb_reset()

Const _usb_intf = Intf0
Config Int0 = Rising
'���������� ������������ (�� "swusb.lbx") ���������� �� INT0.
On Int0 Usb_isr Nosave
Enable Int0