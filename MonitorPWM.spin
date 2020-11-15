''This code example is from Propeller Education Kit Labs: Fundamentals, v1.2.
''A .pdf copy of the book is available from www.parallax.com, and also through
''the Propeller Tool software's Help menu (v1.2.6 or newer).
''https://www.parallax.com/downloads/propeller-education-kit-labs-fundamentals-example-code
''
{{
MonitorPWM.spin

Monitors characteristics of a probed PWM signal, and updates addresses in main RAM
with the most recently measured pulse high/low times and pulse count.  

How to Use this Object in Your Application
------------------------------------------
1) Declare variables for high time, low time, and pulse count.  Example:
   
   VAR 
     long tHprobe, tlprobe, pulseCnt

2) Declare the MonitorPWM object.  Example:
   
   OBJ 
     probe : MonitorPWM

3) Call the start method and pass the I/O pin used for probing and the variable addresses
   from step 1.  Example:
   
   PUB MethodInMyApp
     '... 
     probe.start(8, @tHprobe, @tLprobe, @pulseCnt)

4) The application can now use the values of tHprobe, tLprobe, and pulseCnt to monitor
   the pulses measured on the I/O pin passed to the start method (P8 in this example).
   In this example, this object will continuously update tHprobe, tLprobe, and pulseCnt
   with the most recent pulse high/low times and pulse count.  

See Also
--------
TestDualPwmWithProbes.spin for an application example.

Tips in this object's source code comments are discussed in the Propeller Education
Kit Labs: Fundamentals book.

}}


VAR
  long cog, stack[20]                ' Global variables for cog and stack
  long apin, tladdr, pcntaddr        ' Global variables for the process

  
PUB start(pin, tlowaddr{, pulsecntaddr}) : okay
  '' Starts the object and launches PWM monitoring process into a new cog  
  '' All time measurements are in terms of system clock ticks
  ''
  '' pin - I/O pin number
  '' tLowAddr - address of long that receives the current signal low time measurement
  '' pulseCntAddr - address of long that receives the current count of pulses that have 
  ''                been measured

  ' Copy local parameters to global values that will be used within the cog
  ' You could also use longmove(@apin, @pin, 4) instead of the four commands below
  apin := pin             
  tladdr := tLowAddr
  'pcntaddr := pulseCntAddr

  ' Launch the new cog
  okay := cog := cognew(PwmMonitor, @stack) + 1  
    
PUB stop
  '' Stop the PWM monitoring process and free a cog

  if cog
    cogstop(cog~ - 1)

PRI PwmMonitor {| start, end}
  ctra[30..26] := %01100                             ' NEG detector
  ctra[5..0] := apin                                 ' I/O pin
  frqa := 1                                          ' phsa increments when apin = LOW

  long[pcntaddr] := 0                                ' Clear counter
    
  ' Set up I/O pin directions and states
  dira[apin]~                                        ' Make apin an input
  apin := |<apin                                     ' Set up a pin mask for the waitpeq command

  repeat                                             ' Main loop for pulse monitoring cog
    {waitpne(apin, apin, 0)
    start := cnt
    waitpeq(apin, apin, 0)
    end := cnt
    long[tladdr] := end - start
    }
    
    waitpeq(0, apin, 0)                              ' Wait for apin to go low
    phsa~                                            ' Clear counter
    waitpeq(apin, apin, 0)                           ' Wait for apin to go high
    long[tladdr] := phsa                             ' Save pulse width time in clock ticks
     
    'long[pcntaddr]++                                 ' Increment pulse count

    
