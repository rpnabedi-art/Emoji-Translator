'----------------------------------------------------------------
'                  (c) 1995-2011, MCS
'             xm128A1-ReadFusesWriteLockBits.bas
'  This sample demonstrates the reading writing lock and fuse bytes
'  Based on code from forum user reinhars
'-----------------------------------------------------------------

$regfile = "xm128a1def.dat"
$crystal = 32000000
$hwstack = 64
$swstack = 40
$framesize = 40


'first enable the osc of your choice
Config Osc = Enabled , 32mhzosc = Enabled

'configure the systemclock
Config Sysclock = 32mhz , Prescalea = 1 , Prescalebc = 1_1

Config Com1 = 38400 , Mode = Asynchroneous , Parity = None , Stopbits = 1 , Databits = 8


Declare Function Read_fuses(byval Fuse_address As Byte)as Byte
Declare Function Read_lockbits()as Byte
Declare Sub Write_lockbits(byval Lockbyte As Byte)

print hex(read_fuses(0))
print hex(read_fuses(1))
print hex(read_fuses(2))
'print hex(read_fuses(3))
print hex(read_fuses(4))
print hex(read_fuses(5))

print hex(Read_lockbits())
'note that it is not possible to change fusebytes from within the program

end




Function Read_fuses(byval Fuse_address As Byte)as Byte
  Nvm_addr0 = Fuse_address                                    'load Addressbyte 0
  Nvm_addr1 = 0                                               'load Addressbyte 1
  Nvm_addr2 = 0                                               'load Addressbyte 2
  Nvm_cmd = &H07                                              'Read fuse byte at index ADDR0 into DATA0
  Cpu_ccp = &HD8                                              '0xD8 IOREG Protected IO register (this disables interrupts for 4 cycles)
  Nvm_ctrla.0 = 1                                             'Non-Volatile Memory Command Execute
  bitwait  NVM_STATUS.7, reset
  Read_fuses = Nvm_data0
  Nvm_cmd = 0
End Function

Function Read_lockbits()as Byte
  Read_lockbits = Nvm_lockbits
End Function

Sub Write_lockbits(lockbyte As Byte)
  Nvm_data0 = Lockbyte
  Nvm_data1 = 0
  Nvm_data2 = 0
  Nvm_cmd = &H08                                              'Load the NVM CMD register with the Write Lock Bit command
  Cpu_ccp = &HD8                                              '0xD8 IOREG Protected IO register (this disables interrupts for 4 cycles)
  Nvm_ctrla.0 = 1                                             'Non-Volatile Memory Command Execute
  bitwait  NVM_STATUS.7, reset
  Nvm_cmd = 0
End Sub
