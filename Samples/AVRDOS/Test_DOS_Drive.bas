$regfile = "M128def.dat"
$crystal = 16000000
$hwstack = 128
$swstack = 128
$framesize = 128
$baud = 9600

Open "Com1:" for Binary As #1                                ' use #1 for fs_interpreter
Config Clock = Soft
Enable Interrupts
Config Date = Mdy , Separator = .
Dim Btemp1 As Byte

Print #1 , "Wait for Drive"

' Include here you driver for Compactflash/HardDisk or other
$include "Config_CompactFlash_M128.bas"                     ' Does drive init too
'$Include "Config_HardDisk_M128.bas"

If Gbdriveerror = 0 Then

  ' Include AVR-DOS Configuration and library
$include "Config_AVR-DOS.BAS"

  Print #1 , "Init File System ... ";
  Btemp1 = Initfilesystem(1)                                ' Partition 1
                                          ' use 0 for drive without Master boot record
  If Btemp1 <> 0 Then
     Print #1 , "Error: " ; Btemp1 ; " at Init file system"
  Else
     Print #1 , " OK"
     Print #1 , "Filesystem: " ; Gbfilesystem
     Print #1 , "FAT Start Sector: " ; Glfatfirstsector
     Print #1 , "Root Start Sector: " ; Glrootfirstsector
     Print #1 , "Data First Sector: " ; Gldatafirstsector
     Print #1 , "Max. Cluster Nummber: " ; Glmaxclusternumber
     Print #1 , "Sectors per Cluster: " ; Gbsectorspercluster
     Print #1 , "Root Entries: " ; Gwrootentries
     Print #1 , "Sectors per FAT: " ; Glsectorsperfat
     Print #1 , "Number of FATs: " ; Gbnumberoffats
  End If
Else
   Print #1 , "Error during Drive Init: " ; Gbdriveerror
End If


' If you want to test with File-System Interpreter uncomment next line
'$include "FS_Interpreter.bas"