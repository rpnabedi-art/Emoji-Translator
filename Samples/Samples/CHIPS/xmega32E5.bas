'Xmega32E5  New Processor Test Program
'File: X32E5 DIP ISR Test V6.bas    Fails right now...
'Bascom  JEC   March 2, 2013

'Note:  Atmel's NEW Xmega32E5 is not yet available.
'I have a pre-release version of the chip, and made a DIP Module for it.
'This program attempts to set up a Timer/Counter to generate an interrupt.
'This is a minimalistic program to attempt to do this, it mirros John's
'successful effort to generate a T/C ISR.

'I kludged together a new Def.Dat file for the Bascom compiler.
'I added the chip's name, signature, T/C 4 & 5 registers and interrupts.
'This is a potentially error prone process!

'There are know to be issues with the T/C's in the new E5 chip, but it is
'possible to generate an interrupt as demonstrated by John.

'John's program:
'  Sets up the Xmega clock
'  Initializes the Ports for an LED on PortD.4 and PortD.5
'  Configures Timer/Counter Port C, Type 4, by setting 4 registers.
'     Registers used:
'        TCC4_CtrlA           /64         = 5 dec
'        TCC4_CtrlB           Freq Mode   = 1 dec
'        TCC4_CCA             CC Channel A, Top Value   = 249 or whatever
'        TCC4_IntCtrlB        Enable Low Pri Intr for Channel A, B, C, or D
'                             Ch D is enabled in the version I'm reviewing
'                             Other Channel's line's were commented out.
'                             I've tested each Channel alone, and all together.
'
'  It does NOT init:
'        TCC4_CtrlE           Used to Enable the Compare Channels
'        TCC4_ CtrlGClr       Used to Disable the T/C Stop bit,
'                             Stopped mode = the default
'  It enables global interrupts.
'
'  It defines ISR subroutines for the TCC4_CCA/B/C/D Interrupts.
'  It has an empty Main Loop.

'I believe the C program sets the various bits in the registers for different
'functions one line at a time, using named bit masks, while Bascom typically
'loads the register with a number leaving it up to the User to know which
'bits are being set/cleared.
'
'Note that my hardware platform is an Xmega32E5 mounted on a DIP Breadboard
'module.  It works for general I/O, Flashing and LED, driving a Piezo beeper,
'and driving a character 2x16 LCD.

'...............................................................................
'Hardware Setup and Notes:
'XMega runs at 2 MHz on startup, default.
'The XMega uses a PDI Programmer, a 6-Pin PDI Header is on the DIP PCB.
'Use the Internal 32 MHz Osc.
'The Dip Module gets power from the Breadboard.
'Don't connect the Vtg Header if the programmer provides power, (e.g. Mini-PDI)

'No external Xtal is currently installed.

'LCD is Char Mode, 2x16, 3.3V.
'R/W is tied to Ground for Write Only.
'Can connect BackLight Transistor to PWM output when test that on the E5 chip.
'
'Piezo is direct drive, without a transistor buffer.
'Can tied to a I/O pin for program driven Beep, or to a PWM output.
'
'Port A:
'PortA.0  LED2
'PortA.1  LED3
'PortA.2
'PortA.3
'PortA.4
'PortA.5
'PortA.6
'PortA.7

'Port C:
'PortC.0  LCD RS
'PortC.1  LCD Enable
'PortC.2  LCD DB4
'PortC.3  LCD DB5
'PortC.4  LCD DB6
'PortC.5  LCD DB7
'PortC.6  LED1, High = On
'PortC.7  Piezo, Direct drive, no transistor.

'Port D: N/C
'PortD.0
'PortD.1
'PortD.2
'PortD.3
'PortD.4    External LED, High = On
'PortD.5    External LED, High = On
'PortD.6
'PortD.7

'-------------------------------------------------------------------------------
$regfile = "xm32E5def.dat"                                  'Specify the uC
$crystal = 32000000                                      '32 MHz

$hwstack = 128                                           ' default use 32 for the hardware stack
$swstack = 128                                           ' default use 10 for the SW stack
$framesize = 128                                         ' default use 40 for the frame space

Config Com3 = 19200 , Mode = Asynchroneous , Parity = None , Stopbits = 1 , Databits = 8
Open "COM3:" For Binary As #1

Led4 Alias Portd.4                                       'LED, High = On
Led5 Alias Portd.5                                       'LED, High = On

Dim B1 As Byte
Dim W1 As Word

Const Lotnum0_offset = &H08                                 ' Lot Number Byte 0, ASCII
Const Lotnum1_offset = &H09                                 ' Lot Number Byte 1, ASCII
Const Lotnum2_offset = &H0A                                 ' Lot Number Byte 2, ASCII
Const Lotnum3_offset = &H0B                                 ' Lot Number Byte 3, ASCII
Const Lotnum4_offset = &H0C                                 ' Lot Number Byte 4, ASCII
Const Lotnum5_offset = &H0D                                 ' Lot Number Byte 5, ASCII
Const Wafnum_offset = &H10                                  ' Wafer Number
Const Coordx0_offset = &H12                                 ' Wafer Coordinate X Byte 0
Const Coordx1_offset = &H13                                 ' Wafer Coordinate X Byte 1
Const Coordy0_offset = &H14                                 ' Wafer Coordinate Y Byte 0
Const Coordy1_offset = &H15                                 ' Wafer Coordinate Y Byte 1


Const Adcacal0_offset = &H20                                ' ADCA Calibration Byte 0
Const Adcacal1_offset = &H21                                ' ADCA Calibration Byte 1
Const Adcbcal0_offset = &H24                                ' ADCB Calibration Byte 0
Const Adcbcal1_offset = &H25                                ' ADCB Calibration Byte 1
Const Tempsense0_offset = &H2E                              ' Temperature Sensor Calibration Byte 0
Const Tempsense1_offset = &H2F                              ' Temperature Sensor Calibration Byte 0
Const Daca0offcal_offset = &H30                             ' DACA Calibration Byte 0
Const Daca0gaincal_offset = &H31                            ' DACA Calibration Byte 1
Const Daca1offcal_offset = &H34                             ' DACB Calibration Byte 0
Const Daca1gaincal_offset = &H35                            ' DACB Calibration Byte 1



'Now Configure the Port's Pins for Input or Output mode.
'Config the General Digital I/O pins for two LEDs.
'Ignore the other pins for now.

Config Osc = Enabled , 32mhzosc = Enabled
'Next configure the systemclock:
Config Sysclock = 32mhz , Prescalea = 1 , Prescalebc = 1_1


Config Led4 = Output

Print #1 , "MEGA32E5 SIG"

Print #1 , Hex(readsig(lotnum0_offset))
Print #1 , Hex(readsig(lotnum1_offset))
Print #1 , Hex(readsig(lotnum2_offset))
Print #1 , Hex(readsig(lotnum3_offset))
Print #1 , Hex(readsig(lotnum4_offset))
Print #1 , Hex(readsig(lotnum5_offset))

Print #1 , Hex(readsig(wafnum_offset))
Print #1 , Hex(readsig(coordx0_offset))
Print #1 , Hex(readsig(coordx1_offset))
Print #1 , Hex(readsig(coordy0_offset))
Print #1 , Hex(readsig(coordy1_offset))
Print #1 , Hex(readsig(adcacal0_offset))
Print #1 , Hex(readsig(adcacal1_offset))
Print #1 , Hex(readsig(adcbcal0_offset))
Print #1 , Hex(readsig(adcbcal1_offset))
Print #1 , Hex(readsig(tempsense0_offset))
Print #1 , Hex(readsig(tempsense1_offset))


Do
   Toggle Led4
   Waitms 1000
   Print #1 , "test"
Loop

