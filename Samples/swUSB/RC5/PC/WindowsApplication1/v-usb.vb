

Module v_usb

    Public Declare Function HID_OpenDevice Lib "HID_Lib_PB.dll" (ByVal PID As Integer, ByVal VID As Integer, ByVal VersionNumber As Short, ByVal Index As Short) As Integer
    Public Declare Function HID_GetFeature Lib "HID_Lib_PB.dll" (ByVal Handle As Integer, ByVal buffer() As Byte, ByVal LenBuffer As Integer) As Integer
    Public Declare Function HID_SetFeature Lib "HID_Lib_PB.dll" (ByVal Handle As Integer, ByVal buffer() As Byte, ByVal LenBuffer As Integer) As Integer
    Public Declare Function HID_CloseDevice Lib "HID_Lib_PB.dll" (ByVal Handle As Integer) As Integer

    Public Declare Function HID_ReadDevice Lib "HID_Lib_PB.dll" (ByVal Handle As Integer, ByVal buffer() As Byte, ByVal LenBuffer As Integer) As Integer
    Public Declare Function HID_WriteDevice Lib "HID_Lib_PB.dll" (ByVal Handle As Integer, ByVal buffer() As Byte, ByVal LenBuffer As Integer) As Integer
    Public Declare Function HID_GetInputReport Lib "HID_Lib_PB.dll" (ByVal Handle As Integer, ByRef buffer() As Byte, ByVal LenBuffer As Integer) As Integer
    Public Declare Function HID_SetOutputReport Lib "HID_Lib_PB.dll" (ByVal Handle As Integer, ByRef buffer() As Byte, ByVal LenBuffer As Integer) As Integer
    Public Declare Function HID_GetNumInputBuffers Lib "HID_Lib_PB.dll" (ByVal Handle As Integer) As Integer

    Public Declare Function HID_DeviceTest Lib "HID_Lib_PB.dll" (ByVal PID As Integer, ByVal VID As Integer, ByVal VersionNumber As Short, ByVal Index As Short) As Integer

End Module
