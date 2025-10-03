
' Using the new CONFIG EVENT_SYSTEM function

' Bascom Version 2.0.4.0 or higher

' The Eventsytem in this example easy show after event configuration that one Port Pin is routed to another Port Pin.
' You can see it works even during the WAIT 4 command and there are no PORT READ OR WRITE commands in the Do .... Loop !
' It also shows how to manual fire an Event

' When you want to measure the Event on PortC.7 you need to know that an Event is only  one Clock Cycle so you need a trigger to see it !


' PINC.0 (INPUT FOR EVENT CHANNEL 0) ---------------->>>  PINC.7 (OUTPUT FOR EVENT CHANNEL 0)

$regfile = "xm32a4def.dat"
$crystal = 32000000                                         '32MHz
$hwstack = 64
$swstack = 40
$framesize = 100

Config Osc = Disabled , 32mhzosc = Enabled                  '32MHz
Config Sysclock = 32mhz , Prescalea = 1 , Prescalebc = 1_1  'CPU Clock = 32MHz


Config Com1 = 57600 , Mode = Asynchroneous , Parity = None , Stopbits = 1 , Databits = 8


Print
Print "-----------S T A R T-----------------"



'Configure PC0 for input, Event triggered on falling edge
Config Portc.0 = Input
Config Xpin = Portc.0 , Outpull = Pullup , Sense = Falling  'enable Pullup and reaction on falling edge


' Select PortC.0 as INPUT to event channel 0
' Digflt0 = 8 --> Enable Digital Filtering for Event Channel 0. The Event must be active for 8 samples in order to be passed to the Event system
' Event Channel 1 INPUT = Timer/Counter C0 Overflow
' Event Channel 2 INPUT = Analog Input Port A Channel 0
' Event Channel 3 INPUT = Real Timer overflow
Config Event_system = Dummy , _
Mux0 = Portc.0 , Digflt0 = 8 , _
Mux1 = Tcc0_ovf , _
Mux2 = Adca_ch0 , _
Mux3 = Rtc_ovf


Config Portc.7 = Output
'Event Channel 0 Ouput Configuration
Portcfg_clkevout = &B0_0_01_0_0_00                          'Output on PortC.7 /Clock Out must be disabled

Print "Mainloop -->"


Do

  'IMPORTANT: YOU WILL SEE THE PIN CHANGES ALSO DURING WAIT 4 BECAUSE IT USE THE EVENT SYSTEM
  Wait 4


  'This shows how to manual fire an Event
  Set Evsys_strobe.0

Loop

End                                                         'end program