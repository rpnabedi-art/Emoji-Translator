'http://www.helmpcb.com/Software/USBHIDVB/USBHIDVB.aspx
'USB HID Template for Visual Basic
'Amr Bekhit



Public Class frmUSB
    ' vendor and product IDs

    Private Const VendorID = &HAAAA    'Replace with your device's
    Private Const ProductID = &HEF04    'product and vendor IDs

    ' read and write buffers
    Private Const BufferInSize As Short = 2 'Size of the data buffer coming IN to the PC - данные от контроллера
    Private Const BufferOutSize As Short = 1    'Size of the data buffer going OUT from the PC - данные в контроллер
    Dim BufferIn(BufferInSize) As Byte          'Received data will be stored here - the first byte in the array is unused
    Dim BufferOut(BufferOutSize) As Byte    'Transmitted data is stored here - the first item in the array must be 0

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
            'Device is disabled
            Label1.Text = "OFF"
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
        Dim pHandle As Integer
        pHandle = hidGetHandle(VendorID, ProductID)
        hidSetReadNotify(hidGetHandle(VendorID, ProductID), True)
    End Sub

    '*****************************************************************
    ' on read event...
    '*****************************************************************
    Public Sub OnRead(ByVal pHandle As Integer)
        ' read the data (don't forget, pass the whole array)...
        Dim zamer As Decimal
        Dim temperatura

        If hidRead(pHandle, BufferIn(0)) Then
            ' ** YOUR CODE HERE **
            ' first byte is the report ID, e.g. BufferIn(0)
            ' the other bytes are the data from the microcontroller...

            '######################################################################################
            ' CALCULATION OF THE TEMPERATURE OF TWO received bytes and display the required format
            zamer = BufferIn(1) / 16 + BufferIn(2) * 16
            If zamer < 150 And zamer > -50 Then
                temperatura = Format(zamer, ".0")
                Label1.Text = temperatura & " °C"
            End If
            '######################################################################################

        End If
    End Sub


    Public Sub OnWrite(ByVal pHandle As Integer)
        ' read the data (don't forget, pass the whole array)...
        BufferOut(1) = 255
        hidWriteEx(VendorID, ProductID, BufferOut(0))
        'hidWrite(pHandle, BufferOut(0))
        ' ** YOUR CODE HERE **
        ' first byte is the report ID, e.g. BufferIn(0)
        ' the other bytes are the data from the microcontroller...

    End Sub

End Class
