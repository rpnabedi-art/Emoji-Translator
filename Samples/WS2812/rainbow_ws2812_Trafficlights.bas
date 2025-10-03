'-------------------------------------------------------------------------------
'                   rainbow_ws2812_Trafficlights.bas
'
' This example  simulates two simple Trafficlights.
' It shows how switch between two Stripes with just one defined Rainbow.
' The active output gets changed by the RB_ChangePin statement.
' Thus the use of memory is small.
'
'-------------------------------------------------------------------------------
'(
Following situation:
The one way route from the Weststreet to Nothstreet and vice versa is the main route
and cars on these roads have priority.The corresponding light will show green light normally.
In our simple world, every five seconds a car wants to drive from the Eaststreet to the Northstreet.
Thus, the trafficflow from the main street has to stop, to let the cars pass.
'              Northstreet
'
'               |     |
'               |     |
'               |     | ooo
'         ------'     '------
'                              EastStreet
'          --->        ------
WestStreet            |
'         -----------/
'              ooo
'
'
')
$Regfile = "m88pdef.dat"
$Crystal=8000000
$hwstack=40
$swstack=16
$framesize=32
'We use just one Channel for both Trafficlights, cause LED stripes are static
Config RAINBOW= 1, RB0_LEN=3, RB0_PORT=PORTB,rb0_pin=0
Rb_SelectChannel 0   'we use the defined Channel

'Port+Pin combinations, formed to a word
Const MainStreet_0 = (((varptr(portb) + &H20) *256) OR PB0)
Const EastStreet_1 = (((varptr(portb) + &H20) *256) OR PB1)
 '----[MAIN]---------------------------------------------------------------------
Dim PortPin as Word
Dim Street as Byte  'selects the current PortPin cofiguration
Const Mainstreet = 0
Const Eaststreet = 1
'Index for LED and colors also
Const Red = 0
Const Yellow = 1
Const Green = 2
Gosub inital_state
Do
   Gosub Wait_for_car
   'Trafficlight turns to Red
   Street =  Mainstreet
   Gosub Turn_to_Red
   'Trafficlight turns to green
   Street = Eaststreet
   Gosub Turn_to_green
   Gosub Wait_for_car 'let some cars passing
   Gosub Turn_to_red
   'Mainstreet becomes green
   Street =  Mainstreet
   Gosub Turn_to_green
Loop

Wait_for_car:
   Wait 5
Return

Turn_to_Green:
   Gosub Change_Port_Pin
   RB_SettableColor Yellow,Yellow,Light    'load and set color from table
   RB_Send                                 'refresh stripe
   Wait 1
   RB_clearcolors                          'clear colors in memory
   RB_SettableColor green,green,Light      'load and set color from table
   RB_Send                                 'refresh stripe
   Wait 2
Return

Turn_to_red:
   Gosub Change_Port_Pin
   RB_clearcolors                          'clear colors in memory
   RB_SettableColor Yellow,Yellow,Light    'load and set color from table
   RB_Send                                 'refresh stripe
   Wait 3
   RB_clearcolors                          'clear colors in memory
   RB_SettableColor red,red,Light          'load and set color from table
   RB_Send                                 'refresh stripe
   Wait 2
Return

Inital_State:
'select Mainstreet, green
   Street = Mainstreet
   Gosub Change_Port_Pin
   RB_clearcolors
   RB_SettableColor green,green,Light
   RB_Send
'select Eaststreet, red
   Street = Eaststreet
   Gosub Change_Port_Pin
   RB_clearcolors
   RB_SettableColor Red,Red,Light
   RB_Send
Return

Change_PORT_PIN:
   PortPin = Lookup(Street,PortPin_Tbl)   'get PortPin comination
   RB_ChangePin High(PortPin),PortPin     'use PortPin
Return

PortPin_Tbl:
   Data MainStreet_0%
   Data EastStreet_1%

Light:
   Data 150,0,0      'Red
   Data 100,50,0     'Yello
   Data 0,150,0      'Green
