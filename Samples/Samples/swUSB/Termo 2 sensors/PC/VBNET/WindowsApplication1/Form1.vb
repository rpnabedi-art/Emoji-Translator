Public Class Form1

    Dim vid As Integer = &HAAAA '&H16C0 '43690
    Dim pid As Integer = &HEF04 '&H5DF '61188
    Dim ver As Short = -1
    Dim ind As Short = 0
    Dim Handless, res As Integer
    Dim Buffer(4) As Byte

    Private Sub Form1_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load
        'При открытии формы открыть девайс
        Handless = HID_OpenDevice(pid, vid, ver, ind)
    End Sub

    Private Sub Form1_FormClosed(ByVal sender As Object, ByVal e As System.Windows.Forms.FormClosedEventArgs) Handles Me.FormClosed
        'При закрытии формы закрыть девайс
        res = HID_CloseDevice(Handle)
    End Sub

    Private Sub Timer1_Tick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Timer1.Tick
        ' ВЫЧИСЛЕНИЕ ТЕМПЕРАТУРЫ ИЗ ДВУХ ПРИНЯТЫХ БАЙТОВ И ОТОБРАЖЕНИЕ В НЕОБХОДИМОМ ФОРМАТЕ
        Dim zamer As Decimal
        Dim temperatura
        Dim State

        State = HID_DeviceTest(pid, vid, ver, ind)

        If State = 0 Then 'если устройство отключено
            Label1.Text = "Девайс отключен"
            Buffer(1) = 0
            Buffer(2) = 0
        Else    'если устройство подключено, то вычисляем температуру
            Handless = HID_OpenDevice(pid, vid, ver, ind)
            res = HID_ReadDevice(Handless, Buffer, Buffer.Length)
            'zamer = Buffer(1) / 16 + Buffer(2) * 16
            'If zamer < 150 And zamer > -50 Then
            '    temperatura = Format(zamer, ".0")
            '    Label1.Text = temperatura & " °C"
            'End If


            '######################################################################################
            ' ВЫЧИСЛЕНИЕ ТЕМПЕРАТУРЫ ИЗ ДВУХ ПРИНЯТЫХ БАЙТОВ И ОТОБРАЖЕНИЕ В НЕОБХОДИМОМ ФОРМАТЕ
            If Buffer(1) = 254 And Buffer(2) = 254 Then
                Label1.ForeColor = Color.Red
                Label1.Text = "No datchik"
            Else
                zamer = Buffer(1) / 16 + Buffer(2) * 16
                If zamer < 150 And zamer > -50 Then
                    temperatura = Format(zamer, ".0")
                    Label1.ForeColor = Color.Black
                    Label1.Text = temperatura & " °C"
                End If

            End If

            If Buffer(3) = 254 And Buffer(4) = 254 Then
                Label2.ForeColor = Color.Red
                Label2.Text = "No datchik"
            Else
                zamer = Buffer(3) / 16 + Buffer(4) * 16
                If zamer < 150 And zamer > -50 Then
                    temperatura = Format(zamer, ".0")
                    Label2.ForeColor = Color.Black
                    Label2.Text = temperatura & " °C"
                End If

            End If

            '######################################################################################





        End If

    End Sub

End Class
