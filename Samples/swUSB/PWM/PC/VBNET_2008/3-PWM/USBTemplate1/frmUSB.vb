'http://www.helmpcb.com/Software/USBHIDVB/USBHIDVB.aspx
'USB HID Template for Visual Basic
'Amr Bekhit
'Imports System.Math

Public Class frmUSB
    Private Const VendorID = &HAAAA    'Replace with your device's
    Private Const ProductID = &HEF22    'product and vendor IDs
    ' read and write buffers
    Private Const BufferInSize As Short = 0 'Size of the data buffer coming IN to the PC - данные от контроллера
    Private Const BufferOutSize As Short = 1    'Size of the data buffer going OUT from the PC - данные в контроллер
    Dim BufferIn(BufferInSize) As Byte          'Received data will be stored here - the first byte in the array is unused
    Dim BufferOut(BufferOutSize) As Byte    'Transmitted data is stored here - the first item in the array must be 0
    Private OUT As Byte = 0
    Private PWM1 As Byte = 0
    Private PWM2 As Byte = 0
    Private PWM3 As Byte = 0
    Dim pHandle As Integer

    ' ****************************************************************
    ' when the form loads, connect to the HID controller - pass
    ' the form window handle so that you can receive notification
    ' events...
    '*****************************************************************
    Private Sub Form1_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load
        ' do not remove!
        ConnectToHID(Me)
    End Sub

    '*****************************************************************
    ' disconnect from the HID controller...
    '*****************************************************************
    Private Sub Form1_FormClosed(ByVal sender As Object, ByVal e As System.Windows.Forms.FormClosedEventArgs) Handles Me.FormClosed
        'данные на выход USB
        OUT = 255 'маркер начала пакетов
        OnWrite(pHandle)
        OUT = 0
        OnWrite(pHandle)
        OUT = 0
        OnWrite(pHandle)
        OUT = 0
        OnWrite(pHandle)
        DisconnectFromHID()
    End Sub

    '*****************************************************************
    ' a HID device has been plugged in...
    '*****************************************************************
    Public Sub OnPlugged(ByVal pHandle As Integer)
        If hidGetVendorID(pHandle) = VendorID And hidGetProductID(pHandle) = ProductID Then
            ' ** YOUR CODE HERE **
        End If
    End Sub

    '*****************************************************************
    ' a HID device has been unplugged...
    '*****************************************************************
    Public Sub OnUnplugged(ByVal pHandle As Integer)
        If hidGetVendorID(pHandle) = VendorID And hidGetProductID(pHandle) = ProductID Then
            hidSetReadNotify(hidGetHandle(VendorID, ProductID), False)
            ' ** YOUR CODE HERE **
            'УСТРОЙСТВО ОТКЛЮЧЕНО
        End If
    End Sub

    '*****************************************************************
    ' controller changed notification - called
    ' after ALL HID devices are plugged or unplugged
    '*****************************************************************
    Public Sub OnChanged()
        ' get the handle of the device we are interested in, then set
        ' its read notify flag to true - this ensures you get a read
        ' notification message when there is some data to read...
        'Dim pHandle As Integer
        pHandle = hidGetHandle(VendorID, ProductID)
        hidSetReadNotify(hidGetHandle(VendorID, ProductID), True)
    End Sub

    '*****************************************************************
    ' on read event...
    '*****************************************************************
    Public Sub OnRead(ByVal pHandle As Integer)
        ' read the data (don't forget, pass the whole array)...
        If hidRead(pHandle, BufferIn(0)) Then
            ' ** YOUR CODE HERE **
            ' first byte is the report ID, e.g. BufferIn(0)
            ' the other bytes are the data from the microcontroller...
        End If
    End Sub

    Public Sub OnWrite(ByVal pHandle As Integer)
        ' read the data (don't forget, pass the whole array)...
        BufferOut(0) = 0
        BufferOut(1) = OUT
        hidWriteEx(VendorID, ProductID, BufferOut(0))
        ' ** YOUR CODE HERE **
        ' first byte is the report ID, e.g. BufferIn(0)
        ' the other bytes are the data from the microcontroller...

    End Sub

    Private Sub TrackBar2_Scroll(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles TrackBar2.Scroll
        PWM1 = TrackBar2.Value
        OUTPUT_PAKET()
    End Sub

    Private Sub TrackBar3_Scroll(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles TrackBar3.Scroll
        PWM2 = TrackBar3.Value
        OUTPUT_PAKET()
    End Sub

    Private Sub TrackBar4_Scroll(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles TrackBar4.Scroll
        PWM3 = TrackBar4.Value
        OUTPUT_PAKET()
    End Sub

    Private Sub OUTPUT_PAKET()
        OUT = 255
        OnWrite(pHandle)
        OUT = PWM1
        OnWrite(pHandle)
        OUT = PWM2
        OnWrite(pHandle)
        OUT = PWM3
        OnWrite(pHandle)
    End Sub

End Class
