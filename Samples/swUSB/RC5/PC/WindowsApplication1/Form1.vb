Public Class Form1

    Dim vid As Integer = &HAAAA
    Dim pid As Integer = &HEF55
    Dim ver As Short = -1
    Dim ind As Short = 0
    Dim Handless, res As Integer
    Dim Buffer(1) As Byte
    Dim Buffers(1) As Byte
    Dim Schet As Integer = 0

    Private Sub Form1_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load
        'При открытии формы открыть девайс
        Handless = HID_OpenDevice(pid, vid, ver, ind)
    End Sub

    Private Sub Form1_FormClosed(ByVal sender As Object, ByVal e As System.Windows.Forms.FormClosedEventArgs) Handles Me.FormClosed
        'При закрытии формы закрыть девайс
        res = HID_CloseDevice(Handle)
    End Sub

    Private Sub Timer1_Tick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Timer1.Tick
        Dim State

        Schet = Schet + 1

        If Schet >= 9 Then
            Schet = 1
            Buffers(1) = 0 'Метка стартового пакета
            res = HID_WriteDevice(Handless, Buffers, 2)
        End If

        State = HID_DeviceTest(pid, vid, ver, ind)

        If State = 0 Then 'если устройство отключено
            Label1.Text = "Девайс отключен"
            Buffer(1) = 0
        Else    'если устройство подключено, то принимаем и обрабатуем комманду
            Handless = HID_OpenDevice(pid, vid, ver, ind)
            res = HID_ReadDevice(Handless, Buffer, Buffer.Length)
            If Buffer(1) < 255 Then
                Label3.Text = Buffer(1)
            Else
                Label3.Text = ""
            End If

            If Buffer(1) = 32 Then
                If ProgressBar1.Value < 100 Then
                    ProgressBar1.Value = ProgressBar1.Value + 10
                End If
            End If

            If Buffer(1) = 33 Then
                If ProgressBar1.Value > 0 Then
                    ProgressBar1.Value = ProgressBar1.Value - 10
                End If
            End If

            If Buffer(1) = 1 Then
                RadioButton1.Checked = True
            End If
            If Buffer(1) = 2 Then
                RadioButton2.Checked = True
            End If
            If Buffer(1) = 3 Then
                RadioButton3.Checked = True
            End If
            If Buffer(1) = 4 Then
                RadioButton4.Checked = True
            End If
            If Buffer(1) = 5 Then
                RadioButton5.Checked = True
            End If
            If Buffer(1) = 6 Then
                RadioButton6.Checked = True
            End If
            If Buffer(1) = 7 Then
                RadioButton7.Checked = True
            End If
            If Buffer(1) = 8 Then
                RadioButton8.Checked = True
            End If
            If Buffer(1) = 9 Then
                RadioButton9.Checked = True
            End If
            If Buffer(1) = 0 Then
                RadioButton10.Checked = True
            End If

        End If
        Label2.Text = DateTime.Now.ToLongTimeString

        Dim dfg
        dfg = RTrim(Label2.Text)
        'передача часов в девайс
        Buffers(1) = Asc(Mid(dfg, Schet, 1))
        res = HID_WriteDevice(Handless, Buffers, 2)

    End Sub

End Class
