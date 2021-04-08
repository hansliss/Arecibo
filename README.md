ARECIBO PROGRAM FOR THE COSMAC 1802 MICROCOMPUTER	

(original readme text below)

This is modified version of Steve Gemeny's Arecibo4 program,
to blink the Q led on a CDP1802 computer to simulate the
"Arecibo message" sent on Nov 16, 1974. You can find lots
of info about this message on Wikipedia.

The message was sent at a bitrate of 10 bits/s, so I've
modified the code slightly to do a controlled bit-banging
with a precise number of instructions, in order to achieve
that. This version is tuned for the 1.8 MHz CDP1802
"Membership Card" by Lee Hart, but the calculation is
included in code comments, so it's easy to modify for any
clock rate.

I've also reinstated the message rows that were removed
in the original version in order to keep it below 256 bytes.

Finally, I've converted the assembler code to work with
the "a18" assembler, and written a simple Makefile.

"make install" won't do anything of the sort, but it will
display the iNTEL hex code of the compiled program, which
you can copy and paste into a terminal program, after
entering the "L" (load) command in the monitor.

For more ideas for improvement and other info, check
https://www.retrotechnology.com/memship/arecibo.html

/Hans Liss


--------------------------------------------------------
ARECIBO PROGRAM FOR THE COSMAC 1802 MICROCOMPUTER	

Started 7/05/2005	   
Revised 07/19/2006 ELF Version (256 bytes)

Posted to Yahoo Groups    04/07/2010

WRITTEN BY STEVE GEMENY
steve@gemeny.com	

ASSEMBLED USING THE PSUDO-SAM CROSS-ASSEMBLER

This program is intended to recreate the "Arecebo message" bit 
stream of 1679 bits which can only be arranged as a 23 x 73 matrix
(the product of two prime numbers). 

This program stores the data as 3 bytes per line (24 bits) in a 
data array that matches the bit pattern and orientation of the 
image to be transmitted. To arrive at the required 23 bits per line 
the MSB (left most bit) of the first byte in each row is skipped.	

I/O  
This program uses only the Q line for output there is no user input.
There are no hardware dependencies.
The program should load and run in any 1/4 k page of ram.

	
		
	
