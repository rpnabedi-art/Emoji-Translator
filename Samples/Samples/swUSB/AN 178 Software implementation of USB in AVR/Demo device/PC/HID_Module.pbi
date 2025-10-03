DeclareModule HID

;-DeclareModule

Structure HID_CAPS
  Usage.w
  UsagePage.w
  InputReportByteLength.w
  OutputReportByteLength.w
  FeatureReportByteLength.w
  Reserved.w[17]
  NumberLinkCollectionNodes.w
  NumberInputButtonCaps.w
  NumberInputValueCaps.w
  NumberInputDataIndices.w
  NumberOutputButtonCaps.w
  NumberOutputValueCaps.w
  NumberOutputDataIndices.w
  NumberFeatureButtonCaps.w
  NumberFeatureValueCaps.w
  NumberFeatureDataIndices.w
EndStructure

Structure HID_Sub_DeviceInfo
  VendorID.u
  ProductID.u
  VersionNumber.u
  NumInputBuffers.u
  InputReportByteLength.u
  OutputReportByteLength.u
  FeatureReportByteLength.u
  Manufacturer.s
  Product.s
  SerialNumber.s
EndStructure

Structure HID_DeviceInfo
  CountDevice.w              ; Число обнаруженных HID устройств
  DeviceInfo.HID_Sub_DeviceInfo[258]
EndStructure


Structure HID_Attributes
  VID.u
  PID.u
  VersionNumber.u
EndStructure

Declare HID_Init()
Declare HID_End()
Declare OpenDevice(PID.u, VID.u, VersionNumber.w=-1, Index.u=0)
Declare CloseDevice(hDevice)
Declare TestDevice(PID.u, VID.u, VersionNumber.w=-1, Index.u=0)
Declare DeviceInfo(*Info.HID_DeviceInfo)
Declare ReadDevice(hDevice, *Buffer, Len)
Declare WriteDevice(hDevice, *Buffer, Len)
Declare GetFeature(hDevice, *Buffer, Len)
Declare SetFeature(hDevice, *Buffer, Len)
Declare GetInputReport(hDevice, *Buffer, Len)
Declare SetOutputReport(hDevice, *Buffer, Len)
Declare GetCaps(hDevice, *Capabilities.HID_CAPS)
 ; Узнаём по хендлу устройства, его PID, VID и номер версии.
Declare GetAttributes(hDevice, *DeviceInfo.HID_Attributes)
Declare GetNumInputBuffers(hDevice)
Declare.s GetManufacturerString(hDevice)
Declare.s GetProductString(hDevice)
Declare.s GetSerialNumberString(hDevice)
Declare.s GetIndexedString(hDevice, Index)

EndDeclareModule




Module HID


Structure HIDD_ATTRIBUTES
  Size.l
  VendorID.u
  ProductID.u
  VersionNumber.w
EndStructure

Structure PSP_DEVICE_INTERFACE_DETAIL_DATA
  cbSize.l
  CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
    DevicePath.l
  CompilerElse 
    DevicePath.c
  CompilerEndIf
EndStructure

CompilerIf Defined(SP_DEVICE_INTERFACE_DATA, #PB_Structure)=0
  Structure SP_DEVICE_INTERFACE_DATA
    cbSize.l
    InterfaceClassGuid.GUID
    Flags.l
    Reserved.l
  EndStructure
CompilerEndIf

EnableExplicit
Define.i

Prototype pGetHidGuid(*HidGuid.GUID)
Prototype pGetAttributes(*HidDeviceObject, *Attributes.HIDD_ATTRIBUTES)
Prototype pGetPreparsedData(*HidDeviceObject, *PreparsedData)
Prototype pGetCaps(*PreparsedData, *Capabilities.HID_CAPS)
Prototype pFreePreparsedData(PreparsedData)
Prototype pGetNumInputBuffers(HidHandle, *NumInputBuffers)
Prototype pGetManufacturerString(HidHandle, *Buffer, Len)
Prototype pGetProductString(HidHandle, *Buffer, Len)
Prototype pGetSerialNumberString(HidHandle, *Buffer, Len)
Prototype pGetIndexedString(HidHandle, Index, *Buffer, Len)
Prototype pGetFeature(HidHandle, *Buffer, Len)
Prototype pSetFeature(HidHandle, *Buffer, Len)
Prototype pGetInputReport(HidHandle, *Buffer, Len)
Prototype pSetOutputReport(HidHandle, *Buffer, Len)
Prototype pSetupDiEnumDeviceInterfaces(*DeviceInfoSet, DeviceInfoData, *InterfaceClassGuid.GUID,
                                       MemberIndex, *DeviceInterfaceData.SP_DEVICE_INTERFACE_DATA)
Prototype pSetupDiGetDeviceInterfaceDetail(*DeviceInfoSet, *DeviceInterfaceData.SP_DEVICE_INTERFACE_DATA,
                                           DeviceInterfaceDetailData, DeviceInterfaceDetailDataSize, 
                                           *RequiredSize, *DeviceInfoData)

Define hid_Lib, Setupapi_Lib, OS_Version

Procedure HID_Init()
  Shared hid_Lib, Setupapi_Lib, OS_Version
  
  OS_Version = OSVersion()
  
  hid_Lib=LoadLibrary_("hid.dll")
  Setupapi_Lib=LoadLibrary_("setupapi.dll")
  
  Global fGetHidGuid.pGetHidGuid=GetProcAddress_(hid_Lib, ?GetHidGuid)
  Global fGetAttributes.pGetAttributes=GetProcAddress_(hid_Lib, ?GetAttributes)
  Global fGetPreparsedData.pGetPreparsedData=GetProcAddress_(hid_Lib, ?GetPreparsedData)
  Global fFreePreparsedData.pFreePreparsedData=GetProcAddress_(hid_Lib, ?FreePreparsedData)
  Global fGetCaps.pGetCaps=GetProcAddress_(hid_Lib, ?GetCaps)
  Global fGetInputReport.pGetInputReport=GetProcAddress_(hid_Lib, ?GetInputReport)
  Global fSetOutputReport.pSetOutputReport=GetProcAddress_(hid_Lib, ?SetOutputReport)
  Global fGetFeature.pGetFeature=GetProcAddress_(hid_Lib, ?GetFeature)
  Global fSetFeature.pSetFeature=GetProcAddress_(hid_Lib, ?SetFeature)
  Global fGetNumInputBuffers.pGetNumInputBuffers=GetProcAddress_(hid_Lib, ?GetNumInputBuffers)
  Global fGetManufacturerString.pGetManufacturerString=GetProcAddress_(hid_Lib, ?GetManufacturerString)
  Global fGetProductString.pGetProductString=GetProcAddress_(hid_Lib, ?GetProductString)
  Global fGetSerialNumberString.pGetSerialNumberString=GetProcAddress_(hid_Lib, ?GetSerialNumberString)
  Global fGetIndexedString.pGetIndexedString=GetProcAddress_(hid_Lib, ?GetIndexedString)
  Global fSetupDiEnumDeviceInterfaces.pSetupDiEnumDeviceInterfaces=GetProcAddress_(Setupapi_Lib,
                                                                                   ?SetupDiEnumDeviceInterfaces)
  Global fSetupDiGetDeviceInterfaceDetail.pSetupDiGetDeviceInterfaceDetail=GetProcAddress_(Setupapi_Lib,
                                                                                           ?Setup_InterfaceDetail)
  
  DataSection
    
    GetHidGuid:
    ! db "HidD_GetHidGuid", 0, 0
    
    GetAttributes:
    ! db "HidD_GetAttributes", 0, 0
    
    GetPreparsedData:
    ! db "HidD_GetPreparsedData", 0, 0
    
    FreePreparsedData:
    ! db "HidD_FreePreparsedData", 0, 0
    
    GetCaps:
    ! db "HidP_GetCaps", 0, 0
    
    GetInputReport:
    ! db "HidD_GetInputReport", 0, 0
    
    SetOutputReport:
    ! db "HidD_SetOutputReport", 0, 0
    
    GetFeature:
    ! db "HidD_GetFeature", 0, 0
    
    SetFeature:
    ! db "HidD_SetFeature", 0, 0
    
    GetNumInputBuffers:
    ! db "HidD_GetNumInputBuffers", 0, 0
    
    GetManufacturerString:
    ! db "HidD_GetManufacturerString", 0, 0
    
    GetProductString:
    ! db "HidD_GetProductString", 0, 0
    
    GetSerialNumberString:
    ! db "HidD_GetSerialNumberString", 0, 0
    
    GetIndexedString:
    ! db "HidD_GetIndexedString", 0, 0
    
    SetupDiEnumDeviceInterfaces:
    ! db "SetupDiEnumDeviceInterfaces", 0, 0
    
    Setup_InterfaceDetail:
    CompilerIf #PB_Compiler_Unicode=0
      ! db "SetupDiGetDeviceInterfaceDetailA", 0, 0
    CompilerElse
      ! db "SetupDiGetDeviceInterfaceDetailW", 0, 0
    CompilerEndIf
    
  EndDataSection
  
EndProcedure

Procedure HID_End()
  Shared hid_Lib, Setupapi_Lib
  If hid_Lib
    FreeLibrary_(hid_Lib)
  EndIf
  If Setupapi_Lib
    FreeLibrary_(Setupapi_Lib)
  EndIf
EndProcedure

Procedure FunctInfo(hDevice, *Info.HID_DeviceInfo)
  Protected Attributes.HIDD_ATTRIBUTES, i
  Protected HIDP_CAPS.HID_CAPS
    
  Attributes\Size = SizeOf(HIDD_ATTRIBUTES)
  
  If fGetAttributes(hDevice, @Attributes)
    
    i = *Info\CountDevice
    *Info\CountDevice+1
    
    *Info\DeviceInfo[i]\VendorID        = Attributes\VendorID
    *Info\DeviceInfo[i]\ProductID       = Attributes\ProductID
    *Info\DeviceInfo[i]\VersionNumber   = Attributes\VersionNumber
    
    *Info\DeviceInfo[i]\Manufacturer    = GetManufacturerString(hDevice)
    *Info\DeviceInfo[i]\Product         = GetProductString(hDevice)
    *Info\DeviceInfo[i]\SerialNumber    = GetSerialNumberString(hDevice)
    *Info\DeviceInfo[i]\NumInputBuffers = GetNumInputBuffers(hDevice)
    GetCaps(hDevice, @HIDP_CAPS)
    *Info\DeviceInfo[i]\InputReportByteLength   = HIDP_CAPS\InputReportByteLength
    *Info\DeviceInfo[i]\OutputReportByteLength  = HIDP_CAPS\OutputReportByteLength
    *Info\DeviceInfo[i]\FeatureReportByteLength = HIDP_CAPS\FeatureReportByteLength
    
  EndIf
  
EndProcedure

; Получение доступа к HID устройству
Procedure Open_HID_Device(PID.u, VID.u, VersionNumber.w=-1, Index.u=0, *Funct=0, *Info.HID_DeviceInfo=0)
  Protected HidGuid.Guid
  Protected devInfoData.SP_DEVICE_INTERFACE_DATA
  Protected Attributes.HIDD_ATTRIBUTES, Security.SECURITY_ATTRIBUTES
  Protected *detailData.PSP_DEVICE_INTERFACE_DETAIL_DATA
  Protected Length.l, CurrentIndex.w, hDevInfo
  Protected i, Result, DevicePath.s
  Protected Required, hDevice
  
  If fGetHidGuid=0 Or fSetupDiEnumDeviceInterfaces=0 Or
     fSetupDiGetDeviceInterfaceDetail=0 Or fGetAttributes=0
    ProcedureReturn 0
  EndIf
  
  devInfoData\cbSize = SizeOf(SP_DEVICE_INTERFACE_DATA)
  
  Security\nLength=SizeOf(SECURITY_ATTRIBUTES)
  Security\bInheritHandle=1
  Security\lpSecurityDescriptor = 0
  
  fGetHidGuid(@HidGuid)
  
  hDevInfo=SetupDiGetClassDevs_(@HidGuid,0,0, #DIGCF_PRESENT|#DIGCF_DEVICEINTERFACE)
  If hDevInfo=0
    ProcedureReturn 0
  EndIf
  
  
  For i=0 To 255
    
    Result=fSetupDiEnumDeviceInterfaces(hDevInfo, 0, @HidGuid, i, @devInfoData)
    If Result
      Result = fSetupDiGetDeviceInterfaceDetail(hDevInfo, @devInfoData, 0, 0,@Length, 0)
      *detailData=AllocateMemory(Length)
      *detailData\cbSize=SizeOf(PSP_DEVICE_INTERFACE_DETAIL_DATA)
      Result = fSetupDiGetDeviceInterfaceDetail(hDevInfo, @devInfoData, *detailData, Length+1, @Required, 0)
      
      DevicePath.s=PeekS(@*detailData\DevicePath)
      FreeMemory(*detailData)
      
      hDevice=CreateFile_(@DevicePath, #GENERIC_READ|#GENERIC_WRITE,
                          #FILE_SHARE_READ|#FILE_SHARE_WRITE, @Security, #OPEN_EXISTING, 0, 0)
      
      If hDevice<>#INVALID_HANDLE_VALUE
        
        If *Funct And *Info
          
          CallFunctionFast(*Funct, hDevice, *Info)
          CloseHandle_(hDevice)
          
        Else
          
          Attributes\Size = SizeOf(HIDD_ATTRIBUTES)
          Result = fGetAttributes(hDevice, @Attributes)
          
          If Attributes\ProductID=PID And Attributes\VendorID=VID And 
             (Attributes\VersionNumber=VersionNumber Or VersionNumber=-1 ) 
            If CurrentIndex=Index
              SetupDiDestroyDeviceInfoList_(hDevInfo)
              ProcedureReturn hDevice
            Else
              CurrentIndex+1
              CloseHandle_(hDevice)
            EndIf 
          Else
            CloseHandle_(hDevice)
          EndIf 
          
        EndIf
        
      EndIf
    Else
      Break 
    EndIf
  Next i
  
  SetupDiDestroyDeviceInfoList_(hDevInfo)
  ProcedureReturn 0
EndProcedure

Procedure OpenDevice(PID.u, VID.u, VersionNumber.w=-1, Index.u=0)
  ProcedureReturn Open_HID_Device(PID, VID, VersionNumber, Index, 0, 0)
EndProcedure

Procedure CloseDevice(hDevice) ; Закрытие HID устройства.
  If hDevice
    ProcedureReturn CloseHandle_(hDevice)
  Else
    ProcedureReturn 0
  EndIf
EndProcedure

Procedure TestDevice(PID.u, VID.u, VersionNumber.w=-1, Index.u=0)
  Protected hHid.i, Result
  
  hHid=OpenDevice(PID, VID, VersionNumber, Index)
  If hHid
    CloseDevice(hHid)
    Result=#True
  Else
    Result=#False
  EndIf
  
  ProcedureReturn Result
EndProcedure

Procedure DeviceInfo(*Info.HID_DeviceInfo)
  If *Info
    ClearStructure(*Info, HID_DeviceInfo)
    Open_HID_Device(0, 0, 0, 0, @FunctInfo(), *Info)
    ProcedureReturn Bool(*Info\CountDevice>0)
  EndIf
EndProcedure

Procedure ReadDevice(hDevice, *Buffer, Len) ; Чтение данных из HID устройства
  Protected Written.l=0
  
  If hDevice=0 Or *Buffer=0 Or Len<=0
    ProcedureReturn 0
  EndIf
  
  ReadFile_(hDevice, *Buffer, Len, @Written, 0)
  ProcedureReturn Written
EndProcedure

Procedure WriteDevice(hDevice, *Buffer, Len) ; Запись данных в HID устройство
  Protected Written.l=0
  
  If hDevice=0 Or *Buffer=0 Or Len<=0
    ProcedureReturn 0
  EndIf
  
  WriteFile_(hDevice, *Buffer, Len, @Written,  0)
  ProcedureReturn Written
EndProcedure


Procedure GetFeature(hDevice, *Buffer, Len)
  If hDevice And *Buffer And Len>0 And fGetFeature
    ProcedureReturn fGetFeature(hDevice, *Buffer, Len)
  Else
    ProcedureReturn 0
  EndIf
EndProcedure

Procedure SetFeature(hDevice, *Buffer, Len)
  If hDevice And *Buffer And Len>0 And fSetFeature
    ProcedureReturn fSetFeature(hDevice, *Buffer, Len)
  Else
    ProcedureReturn 0
  EndIf
EndProcedure

 ; Чтение входного репорта. ВНИМАНИЕ функция появилась только в WinXP
Procedure GetInputReport(hDevice, *Buffer, Len)
  Shared OS_Version
  If hDevice And *buffer And Len>0 And
     OS_Version>=#PB_OS_Windows_XP And fGetInputReport
    ProcedureReturn fGetInputReport(hDevice, *Buffer, Len)
  Else
    ProcedureReturn 0
  EndIf
EndProcedure

 ; Запись в устройство выходного репорта. ВНИМАНИЕ функция появилась только в WinXP
Procedure SetOutputReport(hDevice, *Buffer, Len)
  Shared OS_Version
  If hDevice And *buffer And Len>0 And
     OS_Version>=#PB_OS_Windows_XP And fSetOutputReport
    ProcedureReturn fSetOutputReport(hDevice, *Buffer, Len)
  Else
    ProcedureReturn 0
  EndIf
EndProcedure

Procedure GetCaps(hDevice, *Capabilities.HID_CAPS) ; Узнаём размеры буферов и др. информацию об устройстве
  Protected result=0, PreparsedData
  If hDevice And fGetPreparsedData And
     fGetCaps And fFreePreparsedData
    
    If fGetPreparsedData(hDevice, @PreparsedData) 
      fGetCaps(PreparsedData, *Capabilities) 
      fFreePreparsedData(PreparsedData)
      result=1
    EndIf  
    
  EndIf
  ProcedureReturn result
EndProcedure

 ; Узнаём по хендлу устройства, его PID, VID и номер версии.
Procedure GetAttributes(hDevice, *DeviceInfo.HID_Attributes)
  Protected Info.HIDD_ATTRIBUTES, Result=#False
  
  If hDevice And *DeviceInfo And fGetAttributes
    Info\Size = SizeOf(HIDD_ATTRIBUTES)
    If fGetAttributes(hDevice, @Info)
      CopyMemory(@Info+OffsetOf(HIDD_ATTRIBUTES\VendorID), *DeviceInfo, SizeOf(HID_Attributes))
      Result=#True
    EndIf
  EndIf
  
  ProcedureReturn Result
EndProcedure

Procedure GetNumInputBuffers(hDevice)
  Protected NumInputBuffers=0
  If hDevice And fGetNumInputBuffers
    fGetNumInputBuffers(hDevice, @NumInputBuffers)
  EndIf
  ProcedureReturn NumInputBuffers
EndProcedure

Procedure.s GetManufacturerString(hDevice) ; Получаем идентификатор изготовителя
  Protected Result.s="", *mem
  If hDevice And fGetManufacturerString
    *mem=AllocateMemory(256)
    If *mem
      If fGetManufacturerString(hDevice, *mem, 252)
        Result=PeekS(*mem,-1,#PB_Unicode)
      EndIf
      FreeMemory(*mem)
    EndIf
  EndIf
  ProcedureReturn Result
EndProcedure

Procedure.s GetProductString(hDevice) ; Получаем идентификатор продукта
  Protected Result.s="", *mem
  If hDevice And fGetProductString
    *mem=AllocateMemory(256)
    If *mem
      If fGetProductString(hDevice, *mem, 252)
        Result=PeekS(*mem,-1,#PB_Unicode)
      EndIf
      FreeMemory(*mem)
    EndIf
  EndIf
  ProcedureReturn Result
EndProcedure

Procedure.s GetSerialNumberString(hDevice) ; Получаем серийный номер продукта
  Protected Result.s="", *mem
  If hDevice And fGetSerialNumberString
    *mem=AllocateMemory(256)
    If *mem
      If fGetSerialNumberString(hDevice, *mem, 252)
        Result=PeekS(*mem,-1,#PB_Unicode)
      EndIf
      FreeMemory(*mem)
    EndIf
  EndIf
  ProcedureReturn Result
EndProcedure

Procedure.s GetIndexedString(hDevice, Index) ; Чтение строки по её индексу из устройства
  Protected Result.s="", *mem
  If hDevice And fGetIndexedString
    *mem=AllocateMemory(256)
    If *mem
      If fGetIndexedString(hDevice, Index, *mem, 252)
        Result=PeekS(*mem,-1,#PB_Unicode)
      EndIf
      FreeMemory(*mem)
    EndIf
  EndIf
  ProcedureReturn Result
EndProcedure

EndModule
; IDE Options = PureBasic 5.31 (Windows - x86)
; CursorPosition = 6
; Folding = ----
; EnableXP