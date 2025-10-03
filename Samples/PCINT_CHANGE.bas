'---------------------------------------------------------------------------
'                       (c) 1995-2013, MCS Electronics
'                             PCINT_CHANGE.BAS
' This sample shows how to use the PC interrupts
'---------------------------------------------------------------------------

$regfile = "m88def.dat"
$crystal = 8000000
$baud = 19200
$hwstack = 32
$swstack = 16
$framesize = 24

Print "{027}[2J";                                           ' when you have a terminal emulator, this will clear the screen
Print "Test M88 ints"                                       ' init message

'The M88 and M168 can detect a level change on all port pins.
'We will just check on portB, pins 0-3

Config Portb = Input
Portb = &HF                                                 'activate pull up

Enable Interrupts                                           'enable global ints
Enable Pcint0                                               'we enable pcint0 as this has pcint0-pcint7
On Pcint0 Isr_pcint0                                        'we jump to this label when one of the pins is changed
Pcmsk0 = &B00001111                                         'enable pcint0-pcint3  (portb.0-portb.3)
'With pcmsk you individual select which pins must react on a logic level
'When you write a 1, the change in logic level will be detected.

Do
! nop
  'you can do anything here
  'But we show how to use the pin level change in manual mode without interrupts
  'Say we want to detect logic level change of pin 23, (PINC.0) / INT8
  Config Pinc.0 = Input                                     'you can also detect output changes but we use input
  Pcmsk1 = &B00000001                                       ' enable the bit of PCINT8 which is in PCMSK1
  If Pcifr.pcif1 = 1 Then                                   ' change detected
      Print "pinc.0 has changed"                            'in this case it must be pinc.0
      Pcifr.pcif1 = 1                                       ' write a 1 to clear the flag so we can detect it again
  End If
Loop


Isr_pcint0:
  Print "Pin change " ; Bin(pcmsk0) ; Spc(3) ; Bin(pinb)
  'As you see the mask does not change, so to find out which pin changed,
  'you need to read the PINB register.
Return

End