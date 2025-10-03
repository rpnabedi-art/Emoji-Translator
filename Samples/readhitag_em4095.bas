'-------------------------------------------------------------------------------
'                  (c) 1995-2013 MCS Electronics
'  This sample will read a HITAG chip based on the EM4095 chip
'  Consult EM4102 and EM4095 datasheets for more info
'-------------------------------------------------------------------------------
'  The EM4095 was implemented after an idea of Gerhard Günzel
'  Gerhard provided the hardware and did research at the coil and capacitors.
'  The EM4095 is much simpler to use than the HTRC110. It need less pins.
'  A reference design with all parts is available from MCS
'-------------------------------------------------------------------------------
$regfile = "M88def.dat"
$baud = 19200
$crystal = 8000000
$hwstack = 40
$swstack = 40
$framesize = 40


'Make SHD and MOD low
Config Portd.4 = Output
Portd.4 = 0

Shd Alias Portd.5
Config Shd = Output
Shd = 0

Dim Tags(5) As Byte                                         'make sure the array is at least 5 bytes
Dim J As Byte

Config Hitag = 64 , Type = Em4095 , Demod = PIND.3 , Int = INT1

Print "Test EM4095"


'you could use the PCINT option too, but you must mask all pins out so it will only respond to our pin
' Pcmsk2 = &B0000_0100
' On Pcint2 Checkints
' Enable Pcint2
On Int1 Checkints Nosave                                    'we use the INT1 pin all regs are saved in the lib
Config Int1 = Change                                        'we have to config so that on each pin change the routine will be called
Enable Interrupts                                           'as last we have to enable all interrupts



Do
   Print "Check..."

   If Readhitag(tags(1)) = 1 Then                           'this will enable INT1
      For J = 1 To 5
         Print Hex(tags(j)) ; ",";
      Next
      Print
  Else
     Print "Nothing"
  End If
  Waitms 500
Loop


Checkints:
 Call _checkhitag                                           'in case you have used a PCINT, you could have other code here as well
Return