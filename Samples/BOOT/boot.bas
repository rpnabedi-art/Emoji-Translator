'-------------------------------------------------------------------------------

'IMPORTANT : Look at BOOTLOADER.BAS which is simpler

'-------------------------------------------------------------------------------
'--------------------------------------------------------------------------------
'name                     : boot.bas
'copyright                : (c) 1995-2005, MCS Electronics
'purpose                  : bootloader example for the M163
'micro                    : Mega163
'suited for demo          : yes
'commercial addon needed  : no
'use in simulator         : not possible
'
'set fusebit FE to 512 bytes for bootspace for this example
'At start up a message is displayed. When you make PIND.7 low the
'bootloader will be started
'This program serves as an example. It can be changed for other chips.
'Especially the page size and the boot entry location might need a change
'--------------------------------------------------------------------------------
$regfile = "m163def.dat"

'Our communication settings
$crystal = 4000000
$baud = 19200
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 10                                               'default use 10 for the SW stack
$framesize = 40                                             'default use 40 for the frame space


Print "Checking bootloader"
Portd.7 = 1
If Pind.7 = 0 Then
   Print "Entering bootloader"
   goto $1e00                                                ' make a jump to the boot code location. See the datasheet for the entrypoint
End If
Print "Not entering bootloader"

'you code would continue here
End




'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
'                    B O O T  L O A D E R
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

'The fusebit FE is set so that we have 512 bytes for the boot code
'Only a part is used btw
'But it sets the bootstart address to 1E00 hex. which happens to be in the M161 too

'The $boot diretive will bind the code below into address specified
'This will generate large files with FFFF opcode from the end of the normal program to the start
'of the bootcode
'Note that the bootloader is written in ASM. This because the bootloader may not call routines from
'the main program. Why? Because during programming they get erased!
$boot = $1e00

'no interrupts are allowed during bootloader programming
Disable Interrupts


'Standard Intel hex file can be sent
':10 0000 00 0C 94 2400189500001895000018950000 25
':00 0000 01 FF
' size , address,record type, data, checksum
'The sample bootloader does not use the checksum

'The same baudrate is used as the main program is using
'but we can change it here when we like. Just unremark the next line and/or change it
'But take in mind that the bootloader sender must use the same baud rate !!!
'Baud = 19200

$asm
clr r18                                          ; word counter for written data
clr r23                                          ; page counter

rcall _erase_page                                ; erase first page

_read_lines:
  rcall _rec_line                                ; get line into SRAM pointed by X
  ldi r26,$61                                    ; point to start of line
  clr r27
  ld r24,x+                                      ; get char in r24
  rcall _hex2number                              ; convert result in r17
  ld r24,x+
  rcall _hex2number2                             ; convert second char , r17 holds the number of hex pairs to get
  mov r19,r17                                    ; number of entries
  tst r19
  brne _readnext                                 ; not the end record
  rjmp _write_last_page                          ; final line so write the last page

_readnext:
  adiw xl,6                                      ; point to first pair
_readnextpair:
  ld r24,x+                                      ; get char in r24
  rcall _hex2number                              ; convert result in r17
  ld r24,x+
  rcall _hex2number2                             ; convert second char , r17 holds the data
  mov r0,r17                                     ; save in r0
  dec r19                                        ; adjust pair data counter
  ld r24,x+                                      ; get char in r24
  rcall _hex2number                              ; convert result in r17
  ld r24,x+
  rcall _hex2number2                             ; convert second char , r17 holds the data
  mov r1,r17                                     ; save data
  rcall _write_page                              ; write into page buffer
  cpi r18,64                                     ; page is 128 bytes is 64 words
  breq _writeit                                  ; write page since it is full
_lbl1:
  dec r19                                        ; adjust data pair
  brne _readnextpair                             ; more data
  rjmp _read_lines                               ; next line

_writeit:
  rcall _save_page                               ; save page
  rcall _erase_page                              ; erase next page
  Rjmp _lbl1                                     ; continue

_write_last_page:
  rcall _save_page                               ; save last page
  rjmp _exit_page                                ; exit needs a reset



' get 1 byte from serial port and store in R24
_recbyte:
  Sbis USR, 7                                    ; Wait for character
  rjmp _recbyte
  in r24, UDR                                    ; get byte
Ret

'get one line from the serial port and store in location pointed by X
_rec_line:
  ldi r26,$60                                    ; point to first location in SRAM
  clr r27
_rec_line5:
  sbis usr,5
  rjmp _rec_line5
  ldi r24, 63 ; ?
  out udr,r24                                   ; show ? so we know we can send next line
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


'page address in z7-z13
_erase_page:
  mov r31,r23                                    ; page address
  lsr r31                                        ; get z8-z13 shift ls bit into carry
  clr r30
  ror r30                                        ; get z7
  ldi r24,3                                      ; page erase command
  rcall _do_spm
  clr r16 ; page cleared indicator
ret

_write_page:
  mov r31,r23                                    ; page address z8-z13
  lsr r31
  clr r30
  ror r30                                        ; carry to z7

  mov r24,r18                                    ; word address buffer counter
  lsl r24
  add r30,r24                                    ; z1-z6
  ldi r24,1                                      ; buffer fill
  rcall _do_spm
  inc r18
ret


_save_page:
'z0-z6 must be 0
'z7-z13 is the page address
'r0 and r1 are ignored
  mov r31,r23
  lsr r31
  clr r30
  ror r30

  ldi r24,5                                       ; write page
  rcall _do_spm
  clr r18                                         ; page word address counter
  inc r23                                         ; page counter
ret

'; execute spm instruction , data in R24
_do_spm:
  sbic eecr, eewe
  rjmp _Do_spm
  Out Spmcr , R24
  spm
  .obj Ffff                                         ; needs FFFF according to datasheet
  nop
_wait_spm:
  In r24,spmcr
  sbrc r24, 0
  rjmp _wait_spm
ret

_exit_page:
  in r24,spmcr
  sbrs r24,asb
  rjmp _exit_page1
  ldi r24,17
  rcall _do_spm
  rjmp _exit_page
_exit_page1:
$end asm
End
