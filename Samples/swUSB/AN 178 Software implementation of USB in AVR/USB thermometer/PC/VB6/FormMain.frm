VERSION 5.00
Begin VB.Form MainForm 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "VB6_USB_termo"
   ClientHeight    =   1830
   ClientLeft      =   5490
   ClientTop       =   4080
   ClientWidth     =   2895
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   1830
   ScaleWidth      =   2895
   StartUpPosition =   2  'CenterScreen
   Begin VB.Frame Frame1 
      Caption         =   "Temperatura"
      Height          =   735
      Left            =   120
      TabIndex        =   2
      Top             =   960
      Width           =   2655
      Begin VB.Label Label1 
         Alignment       =   2  'Center
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   18
            Charset         =   204
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   375
         Left            =   120
         TabIndex        =   3
         Top             =   240
         Width           =   2415
      End
   End
   Begin VB.Frame Fr_Connect 
      Caption         =   "Connect USB"
      Height          =   735
      Left            =   120
      TabIndex        =   0
      Top             =   120
      Width           =   2655
      Begin VB.Label Label_Connect 
         Alignment       =   2  'Center
         Caption         =   "Disconnect"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   18
            Charset         =   204
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   375
         Left            =   120
         TabIndex        =   1
         Top             =   240
         Width           =   2415
      End
   End
End
Attribute VB_Name = "MainForm"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Const VendorID = 43690 ' &HAAAA - Replace with your device's
Private Const ProductID = 61188 ' &HEF04 - product and vendor IDs
' read and write buffers
' Размер буффера чтения - записи
Private Const BufferInSize = 2
Private Const BufferOutSize = 0
Dim BufferIn(0 To BufferInSize) As Byte
Dim BufferOut(0 To BufferOutSize) As Byte


' ****************************************************************
' when the form loads, connect to the HID controller - pass
' the form window handle so that you can receive notification
' events...
' Действие при загрузке формы
'*****************************************************************
Private Sub Form_Load()
   ' do not remove!
   ConnectToHID (Me.hwnd)
End Sub

'*****************************************************************
' disconnect from the HID controller...
' При выгрузки программы принудительное отсоединение от HID
'*****************************************************************
Private Sub Form_Unload(Cancel As Integer)
   DisconnectFromHID
End Sub

'*****************************************************************
' a HID device has been plugged in...
' Действие при присоединении HID устройства
'*****************************************************************
Public Sub OnPlugged(ByVal pHandle As Long)
   If hidGetVendorID(pHandle) = VendorID And hidGetProductID(pHandle) = ProductID Then
      ' ** YOUR CODE HERE **
    Label_Connect.Caption = "Connect"
   End If
End Sub

'*****************************************************************
' a HID device has been unplugged...
' Действие при отсоединении HID устройства
'*****************************************************************
Public Sub OnUnplugged(ByVal pHandle As Long)
   If hidGetVendorID(pHandle) = VendorID And hidGetProductID(pHandle) = ProductID Then
      ' ** YOUR CODE HERE **
    Label_Connect.Caption = "Disconnect"
    Label1.Caption = ""
   End If
End Sub

'*****************************************************************
' controller changed notification - called
' after ALL HID devices are plugged or unplugged

'*****************************************************************
Public Sub OnChanged()
   Dim DeviceHandle As Long
   ' get the handle of the device we are interested in, then set
   ' its read notify flag to true - this ensures you get a read
   ' notification message when there is some data to read...
   DeviceHandle = hidGetHandle(VendorID, ProductID)
   hidSetReadNotify DeviceHandle, True
End Sub

'*****************************************************************
' on read event...
' Читаем данные из AVR
'*****************************************************************
Public Sub OnRead(ByVal pHandle As Long)
        Dim zamer
        Dim temperatura

   If hidRead(pHandle, BufferIn(0)) Then
      ' ** YOUR CODE HERE **
            '######################################################################################
'CALCULATION OF TEMPERATURE OF TWO received bytes and display the required format
'ВЫЧИСЛЕНИЕ ТЕМПЕРАТУРЫ ИЗ ДВУХ ПРИНЯТЫХ БАЙТОВ И ОТОБРАЖЕНИЕ В НЕОБХОДИМОМ ФОРМАТЕ
            zamer = BufferIn(1) / 16 + BufferIn(2) * 16
            If zamer < 150 And zamer > -50 Then
                temperatura = Format(zamer, ".0")
                Label1.Caption = temperatura & " °C"
            End If
            '######################################################################################

   End If
End Sub

'*****************************************************************
' on Write event...
' Процедура для записи в AVR
'*****************************************************************
Public Sub WriteSomeData()
   BufferOut(0) = 0   ' first by is always the report ID
   hidWriteEx VendorID, ProductID, BufferOut(0)
End Sub
