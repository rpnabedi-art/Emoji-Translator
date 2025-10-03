'----------------------------------------------------------------
' test of Xmega32E5 -Module test Xmega32E5 Xplain from Atmel
' led is blinking followinf pwm set by period and compare
'  J.S et JP décember 2014
'and the help of Mark Alberts !
'-----------------------------------------------------------------
$regfile = "xm32e5def.dat"
$crystal = 32000000                                                             '32MHz
$hwstack = 64
$swstack = 40
$framesize = 40
Config Osc = Enabled , Pllosc = Enabled , Pllmul = 10
Config Sysclock = Pll , Prescalea = 1 , Prescalebc = 1_1
Config Priority = Static , Vector = Application , Lo = Enabled
Config Portd.4 = Output                                                         ' leds on the prototyep boards
Config Portd.5 = Output
Config Tcc4 = Pwm , Prescale = 1024 , Capmodeah = Both_enabled
Tcc4_per = 5000                                                                 ' set blink frequence
Tcc4_cca = 4990                                                                 ' set led on start time
On Tcc4_ovf Tc4_isr                                                             ' interrupt when count = period
On Tcc4_cca Myisr                                                               ' interrupt when timer = compare (CCA)
Enable Tcc4_ovf , Lo                                                            'Enable overflow interrupt in LOW Priority
Enable Tcc4_cca , Lo                                                            'Enable overflow interrupt in LOW Priority
Enable Interrupts
Do
 !nop
Loop
End                                                                             'end program
'--------------------[Interrupt Service Routines]-------------------------------
Tc4_isr:                                                                        ' overflow interrupt
  Toggle Portd.4                                                                ' change status led D4
  Set Portd.5                                                                   ' led D5 is Off (ON by pull-down)
  Tcc4_intflags.0 = 1                                                           ' clear interrupt flag
Return
Myisr:
  Reset Portd.5                                                                 ' led D5 is OFF(off by pull-down)
Return