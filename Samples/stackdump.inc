'------------------------------------------------------------------------------------------------
'                Stackdump.inc include module for $StACKDUMP
'                      code and idea by MWS
'------------------------------------------------------------------------------------------------
$noramclear
Const Stck_siz_sav = 16                                     ' amount of stack to be saved beginning from SP, saving upwards, max bytes = 255
Const Ignore_sp = 0                                         ' set this to 1 if the amount of stack has to be saved always, independently of SP
Const SP_adr_size = 2                                       ' size in bytes of var: SP_last_acsd
Const St_cop_size = 1                                       ' size in bytes of var: Stck_byt_cpd
Const St_svd_size = Stck_siz_sav                            ' size in bytes of var: Stck_svd
Const Cont_size = SP_adr_size + St_cop_size + St_svd_size   ' size of container for protected memory block
Const SP_adr_ofs = 0                                        ' offsets of variables within container
Const St_cop_ofs = SP_adr_size
Const St_svd_ofs = SP_adr_size + St_cop_size
Dim Container(Cont_size) As Byte                            ' container for stack data, can be overlayed also, but vars are not cleared then
Dim SP_last_acsd As Word At Container + SP_adr_ofs Overlay  ' last accessed stack address
Dim Stck_byt_cpd As Byte At Container + St_cop_ofs Overlay  ' amount of bytes copied till stack end
Dim Stck_svd(St_svd_size) As Byte At Container + St_svd_ofs Overlay       ' array to hold saved stack


Lbl_Start:                                                  ' code to clear sram, leaves memory for saved stack variables untouched
!LDI   ZL,           lbyte(_HWSTACKSTART)                   ' get sram end from Bascom's internal constants
!LDI   ZH,           hbyte(_HWSTACKSTART)
!ADIW  ZL,           1                                      ' compensate for the following Z pre-decrement
!MOVW  R24,          ZL
loadadr Container(Cont_size) , X                            ' load upper end of array to calculate protected range
!ADIW  XL,           1                                      ' now XL/XH points to the first memory cell following the stack array
!CLC
!SBC   R24,          XL                                     ' calculate range
!SBC   R25,          XH
CLR    R16
!Mem_clear_loop1:
!ST    -Z,           R16                                    ' clear sram cell, store with pre-decrement
!SBIW  R24,          1
BRNE   Mem_clear_loop1
!LDI   XL,           lbyte(_HWSTACKSTART)                   ' calculate sram start from Bascom's internal constants
!LDI   XH,           hbyte(_HWSTACKSTART)
!LDI   R17,          hbyte(_RAMSIZE)
!SUBI  XL,           lbyte(_RAMSIZE)
!SBC   XH,           R17                                    ' ZL/ZH contains now sram start -1
loadadr Container(1) , Z                                    ' load lower end of array to clear till sram start
!Mem_clear_loop2:                                           ' clear any other (internal) variables
!SBIW  ZL,           1
!CP    XL,           ZL
!CPC   XH,           ZH
!BRCC  Mem_clear_loop2_lower                                ' don't clear cell if Z-pointer got too low
!ST    Z,            R16
!Mem_clear_loop2_lower:
!BRCS  Mem_clear_loop2
