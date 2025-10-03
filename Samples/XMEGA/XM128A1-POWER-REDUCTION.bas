'-----------------------------------------------------------
'             XM128A1-POWER-REDUCTION.BAS
'               (c) 1995-2011 MCS Electronics
' sample provided by MAK3
'-----------------------------------------------------------

' CONFIG POWER_REDUCTION and USING EVENT SYSTEM

' This Example show how to use the config power_reduction and give first insights to the XMEGA EVENT SYSTEM

' Regarding the Eventsytem this example easy show after event configuration that one Port Pin is routed to another Port Pin.
' You can see it works even during the WAIT 4 command and there are no PORT READ OR WRITE commands in the Do .... Loop !
' It also shows how to manual fire an Event

$regfile = "xm128a1def.dat"
$crystal = 2000000                                          '2MHz
$hwstack = 64
$swstack = 40
$framesize = 40


Config Osc = Enabled
Config Sysclock = 2mhz                                      '2MHz

' YOU CAN MINIMIZE POWER CONSUMPTION FOR EXAMPLE WITH :
' 1. Use Low supply voltage
' 2. Use Sleep Modes
' 3. Keep Clock Frequencys low (also with Precsalers)
' 4. Use Powe Reduction Registers to shut down unused peripherals

'With Power_reduction you can shut down specific peripherals that are not used in your application
'Paramters: aes,dma,ebi,rtc,evsys,daca,dacb,adca,adcb,aca,acb,twic,usartc0,usartc1,spic,hiresc,tcc0,tcc1
Config Power_reduction = Dummy , Aes = Off , Twic = Off , Twid = Off , Twie = Off , Aca = Off , Adcb = Off , Tcc0 = Off , Tcc1 = Off , Dma = Off

'For the following we need the EVENT System therefore we do not shut down EVENT SYSTEM

Config Com1 = 9600 , Mode = Asynchroneous , Parity = None , Stopbits = 1 , Databits = 8
Open "COM1:" For Binary As #1
Waitms 2

Print #1 ,
Print #1 , "-----------S T A R T-----------------"



'Configure PC0 for input, triggered on falling edge
Config Pinc.0 = Input
Config Xpin = Portc.0 , Outpull = Pullup , Sense = Falling  'enable Pull up and reaction on falling edge

Config Event_system = Dummy , Mux0 = Portc.0 , Digflt0 = 8  'Select PC0 as input to event channel 0, 8 SAMPLES for Digital Filter


Config Pinc.7 = Output
'Event Channel 0 Ouput Configuration
Portcfg_clkevout = &B0_0_01_0_0_00                          'Output on PINC.7 /Clock Out must be disabled

Print #1 , "Portcfg_clkevout = " ; Bin(portcfg_clkevout)

Print #1 , "Mainloop -->"


Do

  'IMPORTANT: YOU WILL SEE THE PIN CHANGES ALSO DURING WAIT 4 BECAUSE IT USE EVENT SYSTEM
  Wait 4

  'This shows how to manual fire an Event
  Set Evsys_strobe.0

Loop

End                                                         'end program
