Imports System.Math

Public Class frmUSB
    ' vendor and product IDs
    Private Const VendorID = &HAAAA    'Replace with your device's
    Private Const ProductID = &HEF55    'product and vendor IDs
    ' read and write buffers
    Private Const BufferInSize As Short = 1 'Size of the data buffer coming IN to the PC - данные от контроллера
    Private Const BufferOutSize As Short = 1    'Size of the data buffer going OUT from the PC - данные в контроллер
    Dim BufferIn(BufferInSize) As Byte          'Received data will be stored here - the first byte in the array is unused
    Dim BufferOut(BufferOutSize) As Byte    'Transmitted data is stored here - the first item in the array must be 0
    Private OUT As Byte = 0
    Dim pHandle As Integer
    Dim i As Integer
    Dim dfg
    Dim rus

    ' ****************************************************************
    ' when the form loads, connect to the HID controller - pass
    ' the form window handle so that you can receive notification
    ' events...
    '*****************************************************************
    Private Sub Form1_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load
        ' do not remove!
        ConnectToHID(Me)

        Timer1.Enabled = True
    End Sub

    '*****************************************************************
    ' disconnect from the HID controller...
    '*****************************************************************
    Private Sub Form1_FormClosed(ByVal sender As Object, ByVal e As System.Windows.Forms.FormClosedEventArgs) Handles Me.FormClosed
        'данные на выход USB
        OUT = 0
        OnWrite(pHandle)

        For i = 1 To 16
            OUT = Asc(" ")
            OnWrite(pHandle)
        Next

    End Sub

    '*****************************************************************
    ' a HID device has been plugged in...
    '*****************************************************************
    Public Sub OnPlugged(ByVal pHandle As Integer)
        If hidGetVendorID(pHandle) = VendorID And hidGetProductID(pHandle) = ProductID Then
            ' ** YOUR CODE HERE **
            'Timer1.Enabled = True
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
            'данные на выход USB
            OUT = 0
            OnWrite(pHandle)

            For i = 1 To 16
                OUT = Asc(" ")
                OnWrite(pHandle)
            Next


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
        'Dim zamer As Decimal
        'Dim temperatura

        If hidRead(pHandle, BufferIn(0)) Then
            ' ** YOUR CODE HERE **
            ' first byte is the report ID, e.g. BufferIn(0)
            ' the other bytes are the data from the microcontroller...
            If BufferIn(1) < 255 Then
                TextBox3.Text = BufferIn(1)
            End If

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


    Private Sub Timer1_Tick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Timer1.Tick
        'данные на выход USB
        OUT = 0
        OnWrite(pHandle)
        TextBox2.Text = DateTime.Now.ToLongTimeString
        dfg = RTrim(TextBox2.Text)
        For i = 1 To Len(TextBox2.Text)
            OUT = Asc(Mid(dfg, i, 1))
            OnWrite(pHandle)
        Next i
        For i = Len(TextBox2.Text) To 15
            OUT = Asc(" ")
            OnWrite(pHandle)
        Next i
       
    End Sub

    Private Sub koder_rus(ByVal C)
        ''' Функция выводит в заданную позицию руссифицированное сообщение

        Dim A
        A = C
        Select Case C
            Case "А" : rus = ("A")
            Case "Б" : rus = (" ")
            Case "В" : rus = ("B")
            Case "Г" : rus = ("Ў")
            Case "Д" : rus = ("а")
            Case "Е" : rus = ("E")
            Case "Ё" : rus = ("E")
            Case "Ж" : rus = ("Ј")
            Case "З" : rus = ("¤")
            Case "И" : rus = ("Ґ")
            Case "Й" : rus = ("Ґ")
            Case "К" : rus = ("K")
            Case "Л" : rus = ("§")
            Case "М" : rus = ("M")
            Case "Н" : rus = ("H")
            Case "О" : rus = ("O")
            Case "П" : rus = ("Ё")
            Case "Р" : rus = ("P")
            Case "С" : rus = ("C")
            Case "Т" : rus = ("T")
            Case "У" : rus = ("©")
            Case "Ф" : rus = ("Є")
            Case "Х" : rus = ("X")
            Case "Ц" : rus = ("б")
            Case "Ч" : rus = ("«")
            Case "Ш" : rus = ("¬")
            Case "Щ" : rus = ("в")
            Case "Ъ" : rus = ("­")
            Case "Ы" : rus = ("®")
            Case "Ь" : rus = ("b")
            Case "Э" : rus = ("®")
            Case "Ю" : rus = ("°")
            Case "Я" : rus = ("±")
            Case "а" : rus = ("a")
            Case "б" : rus = ("І")
            Case "в" : rus = ("і")
            Case "г" : rus = ("ґ")
            Case "д" : rus = ("г")
            Case "е" : rus = ("e")
            Case "ё" : rus = ("e")
            Case "ж" : rus = ("¶")
            Case "з" : rus = ("·")
            Case "и" : rus = ("ё")
            Case "й" : rus = ("ё")
            Case "к" : rus = ("є")
            Case "л" : rus = ("»")
            Case "м" : rus = ("ј")
            Case "н" : rus = ("Ѕ")
            Case "о" : rus = ("o")
            Case "п" : rus = ("ѕ")
            Case "р" : rus = ("p")
            Case "с" : rus = ("c")
            Case "т" : rus = ("ї")
            Case "у" : rus = ("y")
            Case "ф" : rus = ("д")
            Case "х" : rus = ("x")
            Case "ц" : rus = ("е")
            Case "ч" : rus = ("А")
            Case "ш" : rus = ("Б")
            Case "щ" : rus = ("ж")
            Case "ъ" : rus = ("В")
            Case "ы" : rus = ("Г")
            Case "ь" : rus = ("Д")
            Case "э" : rus = ("Е")
            Case "ю" : rus = ("Ж")
            Case "я" : rus = ("З")
            Case Else : rus = A
        End Select




    End Sub

End Class
