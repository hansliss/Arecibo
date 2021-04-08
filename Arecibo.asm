	TITL	"Arecibo4"
	CPU	1802
			
	
	;		
	; ARECIBO PROGRAM FOR THE COSMAC 1802 MICROCOMPUTER	 7/05/05	
	; WRITTEN BY STEVE GEMENY	          ELF Version (256 bytes)	
	; ASSEMBLE FOR THE PSUDO-SAM CROSS-ASSEMBLER
	;
	; This program is intended to recreate the "Arecebo message" bit 
	; stream of 1679 bits which can only be arranged as a 23 x 73 matrix
	; (the product of two prime numbers). 
	; This program stores the data as 3 bytes per line (24 bits) in a 
	; data array that matches the bit pattern and orientation of the 
	; image to be transmitted. To arrive at the required 23 bits per line 
	; the MSB (left most bit) of the first byte in each row is skipped.		
	;		
	; 07/05/05  SEG  STARTED, GOT THE DATA LOADED
	;			WORKED OUT THE BASIC FLOW
	; 07/06/05  SEG  WORKED OUT THE OUTPUT ROUTINE, PART OF SETUP
	;			AND SOME OF THE BIT TIMING 
	; 07/18/06  SEG	After a year of inactivity, this finally bothered me enough 
	;			to get it finsihed.  After Assembly, the .OBJ file was converted
	;			to .BIN via Hex2Bin.exe and the resulting .BIN was renamed .COS 
	;			to be run in Visual Elf for debugging...  Successfully!
	; 07/19/06	SEG	Modified Data pointer to fit at at end of code
	;			so all but 14 lines live in 256 bytes "ELF Version"
	;		
;
; Register Definitions:
;
R0		EQU	0
R1		EQU	1
R2		EQU	2
R3		EQU	3
R4		EQU	4
R5		EQU	5
R6		EQU	6
R7		EQU	7
R8		EQU	8
R9		EQU	9
RA		EQU	10
RB		EQU	11
RC		EQU	12
RD		EQU	13
RE		EQU	14
RF		EQU	15
D		EQU	13

	; REGISTER ASSIGNMENTS:		
	;		
	;	     0	; PC (VIA RESET) AT ENTRY
	;	     1	; 
	;	     2	; 
	;	     3	; 
	;	     4	; 
	;	     5	; 
	;	     A	; DATA WORD HOLDER
	;	     B	; BIT COUNTER  (8)
	;	     C	; BYTE COUNTER (3)
	;	     D 	; ROW COUNTER  (73)
	;	     E	; DATA POINTER
	;	     F	; PIXEL CELL TIMER
BITCNT EQU	0BH	; COUNTS DOWN BITS BEING SHIFTED OUT
BITS EQU	8	; NUMBER OF BITS TO SHIFT OUT
BYTES EQU	3	; NUMBER OF BYTES PER ROW
ROWS EQU	73	 ; 049H - 15	; NUMBER OF ROWS TO BE SENT (49HEX) 
				;   less 15 rows for Elf
ROWCNTR EQU	0DH	; COUNTS DOWN THE ROWS TO SEND OUT
BYTCNT EQU	0CH 	; COUNTS DOWN THE BYTES PER ROW
	;
	;		

	;
	;
	; ****************************
	; *
	; *   
	; *
	; ****************************
	;
	;
	; ****************************
	; *
	; *   SETUP
	; *
	; ****************************
	;
SETUP	ORG	0000H
	;GET THINGS IN ORDER
	REQ			;RESET Q
	LDI 00H		;clean up high side of registers
	PHI RB		;
	PHI RC		;
	PHI RD		;
	PHI RE		;and some low side too
	PLO RF		;
	LDI LOW DATA	;SETUP THE DATA POINTER
	PLO RE		;ITS REG. E
	LDI HIGH DATA	;SETUP THE DATA POINTER
	PHI RE		;ITS REG. E
	SEX RE		;POINT TO THE DATA
				;
LDROW:			;For Lines = 1 to 73
	LDI ROWS		;SET ROW COUNTER TO 73
	PLO ROWCNTR		;ITS REG. D

LDBYT:			;For bytes = 1 to 3
	LDI BYTES		;SET BYTE COUNTER TO 3
	PLO BYTCNT		;ITS REG. C

READ:				;Read the FIRST data IN A ROW
	LDI BITS		;set for 8 bit bytes
	PLO BITCNT		;PUT IT IN THE BIT COUNTER
	LDX			; READ THE FIRST BYTE IN THIS ROW
	OUT 4			; show it
	SHL			;shift to skip the first bit of 24
	PLO RA		;SAVE IT
	DEC BITCNT		;KEEP COUNTER IN SYNC (23)
AGAIN:
	DEC BYTCNT		;BYTES REMAINING TO BE READ
	BR OUTIT		;shift it out
	;
	;If  bytes =1, 
	;Shift left
	;Bits = bits-1 
	;Else, Shift left
	;
	; ****************************
	; *
	; *   OUTPUT THE CARRY BIT
	; *	  ENTRY VIA OUT
	; *       STAYS INSIDE UNTIL BITCNT=0
	; *     EXIT VIA DONE
	; *        TO READ FOR FIRST OF 3
	; *        OR AGAIN OTHERWISE
	; *
	; *
	; *
	; ****************************
	; The bits should be shifted out at a speed
	; of 10 bits per second.
	; The clock frequency is 1.8MHz on the MC,
	; so an instruction takes 1/1800000 * 16
	; seconds, which means a bit frequency of
	; 10Hz requires 0.1 / ((1/1800000) * 16)
	; = 11250 instructions.
	; The code executed for each bit below consists
	; of 13 + 2 = 15 instructions plus 3 for the
	; delay loop, meaning we need to run the loop
	; for (11250 - 15) / 3 times. However, the
	; loop condition ignores the lower octet of RF,
	; so we need to assume that it is left at 255
	; when we exit the loop. Thus, we add 255 to
	; the initial counter value, ending up with
	; (11250 - 15) / 3 + 255 = 4000, or 0x0FA0
OUTIT:
	DEC BITCNT		;  SYNCHING
	GLO RA			;RECOVER SAVED DATA
	SHL			;SHIFT D LEFT
	PLO RA			;SAVE IT
	BDF SET			;ITS A 1 SET Q
	BR RSET			;MUST BE A 0 RESET Q
	;
SET:
	NOP			; EQUALIZE BIT TIME
	BQ ALREADY		;ALREADY SET, GO AWAY
	SEQ			;OTHERWISE SET IT
	BR CELL			;NOW GO AWAY
	;
RSET:
	BNQ ALREADY		;ALREADY RESET, GO AWAY
	REQ			;CLEAR IT
	BR CELL			;NOW GO AWAY
	;
ALREADY:
	NOP			;CHILL A FEW
	NOP			;TO EQUILIZE BIT TIMES
	;
CELL:				;NOW WAIT THE BIT CELL TIME
	LDI 00FH		;LOAD COUNTER
	PHI RF			;IT'S REG. F
	LDI 0A0H
	PLO RF
	;
CNTDN:
	DEC RF			;DECRIMENT THE COUNTER	
	GHI RF			;LOOK AT IT
	BNZ CNTDN		;NOT 0 YET? LOOP
				;
DONE:				;NEXT BIT, NOW IS IT...
	GLO BITCNT		; GET THE COUNT
	BNZ OUTIT		; LOOPING UNTIL ZERO
				;END OF THE BYTE, GET ANOTHER BYTE
	LDI BITS		;RELOAD THE BIT COUNTER
	PLO BITCNT		; FOR THE NEXT BYTE
	GLO BYTCNT		; GET THE BYTE COUNT
	BZ FINISH		; IF ZERO, END OF ROW, START ANOTHER ROW
	LDX			; GET NEXT BYTE
	OUT 4			; AND SHOW IT
	PLO RA		; AND SAVE IT
	BR AGAIN		;
FINISH:			;ALL DONE, START OVER ?
	LDI BYTES		;RESET THE BYTE COUNTER
	PLO BYTCNT		; for the next row
	DEC ROWCNTR		;FINISHED ANOTHER ROW
	GLO ROWCNTR		; CHECK FOR ZERO
	BNZ READ		; IF NOT, START ANOTHER ROW
	BR SETUP		; IS SO, REINIT AND DO OVER
	;
	; ****************************
	; *
	; *   DATA STARTS HERE
	; *
	; ****************************
	; Data was rechecked against excel sheet data, 7/11/06, SEG
	; Arranged in sets of three octets per row, 
	; supress MSB of first octet left shift out the remaining 23 bits. 
	; The next row down is the next group of three octets.
	;
	;START OF DATA
DATA:
	BYTE 000H,015H,040H	;line  1   Binary Counting
	BYTE 010H,014H,014H	;line  2   Binary Counting
	BYTE 026H,091H,011H	;line  3   Binary Counting
	BYTE 012H,055H,055H	;line  4   Binary Counting
	BYTE 000H,000H,000H	;line  5   Blank
	BYTE 000H,030H,000H	;line  6   Chemistry
	BYTE 000H,02CH,000H	;line  7   Chemistry
	BYTE 000H,02CH,000H	;line  8   Chemistry
	BYTE 000H,02AH,000H	;line  9   Chemistry
	BYTE 000H,03EH,000H	;line 10   Chemistry
	BYTE 000H,000H,000H	;line 11   Blank
	BYTE 00CH,031H,0C3H	;line 12   Amino Acid
	BYTE 004H,0C0H,001H	;line 13   Amino Acid
	BYTE 02CH,031H,08BH	;line 14   Amino Acid
	BYTE 07DH,0F7H,0DFH	;line 15   Amino Acid
	BYTE 000H,000H,000H	;line 16   Blank
	BYTE 020H,000H,008H	;line 17   Helix 
	BYTE 000H,000H,000H	;line 18   Helix 
	BYTE 040H,000H,010H	;line 19   Helix 
	BYTE 07CH,000H,01FH	;line 20   Helix 
	BYTE 000H,000H,000H	;line 21   Blank
	BYTE 00CH,070H,0C3H	;line 22   Amino Acid
	BYTE 004H,001H,001H	;line 23   Amino Acid
	BYTE 02CH,0E3H,00BH	;line 24   Amino Acid
	BYTE 07DH,0F7H,0DFH	;line 25   Amino Acid
	BYTE 000H,000H,000H	;line 26   Blank
	BYTE 020H,00CH,008H	;line 27   Helix 
	BYTE 000H,00CH,000H	;line 28   Helix 
	BYTE 040H,00CH,010H	;line 29   Helix 
	BYTE 07CH,00CH,01FH	;line 30   Helix 
	BYTE 000H,00CH,000H	;line 31   Population
	BYTE 010H,008H,004H	;line 32   Population & double helix
	BYTE 008H,00CH,008H	;line 33   Population & double helix
	BYTE 004H,00CH,030H	;line 34   Population & double helix
	BYTE 003H,008H,0C0H	;line 35   Population & double helix
	BYTE 000H,0CCH,000H	;line 36   Population & double helix
	BYTE 003H,008H,0C0H	;line 37   Population & double helix
	BYTE 004H,00CH,030H	;line 38   Population & double helix
	BYTE 008H,004H,008H	;line 39   Population & double helix
	BYTE 010H,00CH,004H	;line 40   Population & double helix
	BYTE 010H,00CH,002H	;line 41   Population & double helix
	BYTE 008H,008H,002H	;line 42   Population & double helix
	BYTE 004H,004H,004H	;line 43   Population & double helix
	BYTE 003H,000H,008H	;line 44   Population & double helix
	BYTE 000H,0C0H,030H	;line 45   Population & double helix
	BYTE 000H,035H,0C4H	;line 46    Man
	BYTE 000H,004H,004H	;line 47    Man
	BYTE 06DH,01FH,004H	;line 48    Man
	BYTE 07EH,02EH,084H	;line 49    Man
	BYTE 076H,04EH,040H	;line 50    Man
	BYTE 06EH,00EH,01DH	;line 51    Man
	BYTE 07EH,00AH,000H	;line 52    Man
	BYTE 006H,00AH,004H	;line 53    Man
	BYTE 000H,00AH,004H	;line 54    Man
	BYTE 000H,01BH,004H	;line 55    Man
	BYTE 000H,000H,000H	;line 56   Blank
	BYTE 000H,004H,01CH	;line 57   Solar System
	BYTE 055H,051H,05CH	;line 58   Solar System
	BYTE 015H,040H,01CH	;line 59   Solar System
	BYTE 001H,040H,000H	;line 60   Solar System
	BYTE 000H,01FH,000H	;line 61   Big Dish
	BYTE 000H,07FH,0C0H	;line 62   Big Dish
	BYTE 001H,0C0H,070H	;line 63   Big Dish
	BYTE 003H,000H,018H	;line 64   Big Dish
	BYTE 006H,080H,02CH	;line 65   Big Dish
	BYTE 00CH,0C0H,066H	;line 66   Big Dish
	BYTE 008H,0A0H,0A2H	;line 67   Big Dish
	BYTE 008H,091H,022H	;line 68   Big Dish
	BYTE 000H,08AH,020H	;line 69   Big Dish
	BYTE 000H,084H,020H	;line 70   Big Dish
	BYTE 000H,080H,020H	;line 71   Big Dish
	BYTE 000H,014H,080H	;line 72   How Big
	BYTE 00FH,02FH,09EH	;line 73   How Big
DATAEND:
	END