{{
+-------------------------------------------------+
| JTAGulator                                      |
| Pulse Width Detection Object                    |  
|                                                 |
| Author: Joe Grand                               |                     
| Copyright (c) 2020 Grand Idea Studio, Inc.      |
| Web: http://www.grandideastudio.com             |
|                                                 |
| Distributed under a Creative Commons            |
| Attribution 3.0 United States license           |
| http://creativecommons.org/licenses/by/3.0/us/  |
+-------------------------------------------------+

Program Description:

This object measures and stores the negative-going
pulse widths (high-low-high) of a signal on the
specified input pin.
 
}}


VAR
  long cog                   ' Used to store ID of newly started cog
     
  long rxPin                 ' Parameters used by cog
  long resultPtr

  
PUB Start(pin, val): okay    'Start a new cog with the assembly routine   
  Stop
                             
  rxPin     := pin              ' Pin to measure    
  resultPtr := val              ' Pointer to result

  okay := cog := cognew(@Init, @rxPin) + 1

  
PUB Stop     'Stop the currently running cog, if any 
  if cog
    cogstop(cog~ - 1)


dat                     ' assembly program 
                        org      0
Init
                        mov      rx_pin, par                   ' start of structure
                        rdlong   rx_pin, rx_pin                ' point to the variable passed into the cog

                        mov      rx_mask, #1
                        shl      rx_mask, rx_pin                        

                        andn     dira, rx_mask                  ' make rx pin an input
                                              
                        mov      res_ptr, par                     
                        add      res_ptr, #4  
                        rdlong   res_ptr, res_ptr              ' point to the variable passed into the cog

                        mov      tmp, #0                       ' clear return value
                        wrlong   tmp, res_ptr

                        movi     ctra, #%01100_000
                        movs     ctra, rx_pin

                        mov      frqa, #1
Measure
                        waitpne  rx_mask, rx_mask                ' wait for pin low
                        mov      phsa, #0
                        waitpeq  rx_mask, rx_mask                ' wait for pin high
                        mov      phsa, phsa
                        wrlong   phsa, res_ptr
                        
                        jmp      #Measure                  

' VARIABLES stored in cog RAM (uninitialized)
rx_pin                  res      1         ' rx pin          
rx_mask                 res      1         ' mask for rx pin                  
res_ptr                 res      1         ' pointer for result

tmp                     res      1

                        fit      ' make sure all instructions/data fit within the cog's RAM 

         
