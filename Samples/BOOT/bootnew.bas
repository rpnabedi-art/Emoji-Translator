'--------------------------------------------------------------------------------
'name                     : bootnew.bas
'copyright                : (c) 1995-2014, MCS Electronics
'purpose                  : test the bootloader
'micro                    : Mega128
'suited for demo          : yes
'commercial addon needed  : no
'use in simulator         : possible
'
' After the ? mark from the loader, set the focus to this window and then
' Select Upload from the Terminal Emulator
'--------------------------------------------------------------------------------

$crystal = 4000000
$baud = 19200
$regfile = "m128def.dat"
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 10                                               'default use 10 for the SW stack
$framesize = 40                                             'default use 40 for the frame space

Do
  Print "Hello, this is a new prog"
  Waitms 500
Loop
End