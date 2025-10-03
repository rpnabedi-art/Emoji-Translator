'-------------------------------------------------------------------------------

'IMPORTANT : Look at BOOTLOADER.BAS which is simpler

'-------------------------------------------------------------------------------
'name                     : boot128.bas
'copyright                : (c) 1995-2005, MCS Electronics
'purpose                  : bootloader example for the M128 in M128 mode
'micro                    : Mega128
'suited for demo          : yes
'commercial addon needed  : no
'use in simulator         : not possible
'
'set fusebit KL and M to '1'
'At start up a message is displayed. When you make PIND.7 low the
'bootloader will be started
'This program serves as an example. It can be changed for other chips.
'Especially the page size and the boot entry location might need a change
'-------------------------------------------------------------------------------

'Our communication settings
$crystal = 4000000
$baud = 19200
$regfile = "m128def.dat"
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 10                                               'default use 10 for the SW stack
$framesize = 40                                             'default use 40 for the frame space

Print "Checking bootloader"
Portd.7 = 1
If Pind.7 = 0 Then
   Print "Entering bootloader"
   jmp $fe00                                                ' make a jump to the boot code location. See the datasheet for the entrypoint
End If
Print "Not entering bootloader"

'you code would continue here
End




'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
'                    B O O T  L O A D E R
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
'The $boot diretive will bind the code below into address specified
'This will generate large files with FFFF opcode from the end of the normal program to the start
'of the bootcode
'Note that the bootloader is written in ASM. This because the bootloader may not call routines from
'the main program. Why? Because during programming they get erased!
$boot = $fe00

'no interrupts are allowed during bootloader programming
Disable Interrupts


'Standard Intel hex file can be sent
':10 0000 00 0C 94 2400189500001895000018950000 25
':00 0000 01 FF
' size , address,record type, data, checksum
'This sample bootloader checks for the checksum and displays ! so you know something wend wrong

'The same baudrate is used as the main program is using
'but we can change it here when we like. Just unremark the next line and/or change it
'But take in mind that the bootloader sender must use the same baud rate !!!
'Baud = 19200


clr r18                                          ; word counter for written data
clr r22                                          ; page counter LSB
clr r23                                          ; page counter MSB

rcall _erase_page



_read_lines:
  rcall _rec_line                                ; get line into SRAM pointed by X
  ldi r26,$01                                    ; point to start of line
  ldi r27,$01
  ld r24,x+                                      ; get char in r24
  rcall _hex2number                              ; convert result in r17
  ld r24,x+
  rcall _hex2number2                             ; convert second char , r17 holds the number of hex pairs to get
  mov r19,r17                                    ; number of entries
! sub r16,r17                                    ; checksum
  tst r19
  brne _readnext                                 ; not the end record
  rjmp _write_last_page                          ; final line so write the last page

_readnext:
 ldi r25,3
_docheck:
 ld r24,x+                                      ; get char in r24
 rcall _hex2number                              ; convert result in r17
 ld r24,x+
 rcall _hex2number2                             ; convert second char , r17 holds the data
 !sub r16,r17
 dec r25
 brne _docheck

'  adiw xl,6                                      ; point to first pair
_readnextpair:
  ld r24,x+                                      ; get char in r24
  rcall _hex2number                              ; convert result in r17
  ld r24,x+
  rcall _hex2number2                             ; convert second char , r17 holds the data
  mov r0,r17                                     ; save in r0
! sub r16,r17                                    ; checksum
  dec r19                                        ; adjust pair data counter
  ld r24,x+                                      ; get char in r24
  rcall _hex2number                              ; convert result in r17
  ld r24,x+
  rcall _hex2number2                             ; convert second char , r17 holds the data
  mov r1,r17                                     ; save data
! sub r16,r17                                    ; checksum
  rcall _write_page                              ; write into page buffer
  cpi r18,128                                     ; page is 256 bytes is 128 words
  breq _writeit                                  ; write page since it is full
_lbl1:
  dec r19                                        ; adjust data pair
  brne _readnextpair                             ; more data
' ----------------checksum checkining ---------------
  ld r24,x+                                      ; get char in r24
  rcall _hex2number                              ; convert result in r17
  ld r24,x+
  rcall _hex2number2                             ; convert second char , r17 holds the data
  cp r16,r17                                     ; checksum ok?
  breq _checkok                                  ; yes
_lbl2:
  sbis usr,5
  rjmp _lbl2
  ldi r24, asc("!")                              ; load !
  !out udr,r24                                   ; show ! so we know there is an error
' note that you only get an indication something wend wrong,there is no error recovery !!!

_checkok:
  rjmp _read_lines                               ; next line

_writeit:
  rcall _save_page                               ; save page
  rcall _erase_page                              ; erase next page
  Rjmp _lbl1                                     ; continue

_write_last_page:
  rcall _save_page                               ; save last page
_exit_page:
  jmp $0000                                      ; exit needs a reset



' get 1 byte from serial port and store in R24
_recbyte:
  Sbis USR, 7                                    ; Wait for character
  rjmp _recbyte
  in r24, UDR                                    ; get byte
Ret

'get one line from the serial port and store in location pointed by X
_rec_line:
  ldi r26,$00                                    ; point to first location in SRAM
  ldi r27,$01
  clr r16
_rec_line5:
  sbis usr,5
  rjmp _rec_line5
  ldi r24, 63 ; ?
  !out udr,r24                                   ; show ? so we know we can send next line
_rec_line1:
  rcall _recbyte                                 ; get byte
  cpi r24,13                                     ; enter?
  breq _rec_line2                                ; yes ready
  st x+,r24                                      ; no so store in sram buffer
  rjmp _rec_line1                                ; next byte
_rec_line2:
  clr r24                                        ; string terminator
  st x,r24
ret

' convert HEX byte in r24 into bin value , on exit byte in r17
_hex2number:
  clr r17
_hex2number4:
  Subi R24,65                                    ; subtract 65
  Brcc _hex2number3                              ; in case carry was cleared
  Subi R24,249                                   ; not
_hex2number3:
  Subi R24,246
  Add R17,R24                                    ; add to accu
ret

';called for the second byte
_hex2number2:
  Lsl R17                                        ; shift data
  Lsl R17
  Lsl R17
  Lsl R17
  rjmp _hex2number4                              ; handle the conversion



_enable_page:
 rcall _wait_spm
 ldi r24,17                                      ; reenable page
 sts  Spmcr , R24
 spm
 nop
 nop
rjmp _wait_spm



'page address in z7-z13
_erase_page:
  rcall _wait_spm
  mov r31,r22                                    ; page address z8-z15
! out rampz,r23                                  ; bit 9 of pageaddress goes into Z16
  clr r30
  ldi r24,3                                      ; page erase command
  sts  Spmcr , R24
  spm
  nop
  nop
  rcall _wait_spm
  rcall _enable_page
ret

_write_page:
  rcall _wait_spm
  mov r31,r22                                    ; page address z8-z15
! out rampz,r23                                  ; bit 9 of page address goes into Z16(bit 0 of rampz)
  mov r30,r18                                    ; word address buffer counter
  lsl r30
  ldi r24,1                                      ; buffer fill
  sts  Spmcr, R24
  spm
  nop
  nop
  rcall _wait_spm
  inc r18  ; next word address
ret


_save_page:
'z0-z6 must be 0
'z7-z13 is the page address
'r0 and r1 are ignored
  rcall _wait_spm
  mov r31,r22                                     ; LSB of page counter
! out rampz,r23                                   ; bit nine goes into bit 0 of rampz
  clr r30
  ldi r24,5                                       ; write page
  sts  Spmcr , R24
  spm
  nop
  nop
  rcall _wait_spm

  rcall _enable_page
  clr r18                                         ; page word address counter
  subi r22,-1                                     ; increment page counter
  sbci r23,255
ret

_wait_spm:
   LDS R25,SPMCR
   SBRC R25,0
   RJMP _WAIT_SPM                                 ; Wait for SPMEN flag cleared
RET

End

'Note that this is just an example. A better usage of the bootloader is to
'set the reset vector to the bootloader.
'The bootloader then can check at reset, if it must program the chip
'When the chip does not need to be programmed, it can jump to the normal reset vector(0)
'You can test for a few magic bytes sendt by the loader to see if the chip must be programmed. This way you do
'not need the additional pin/switch.
'you can send the data in binary form too to speed up things. This way you can also handle errors
'