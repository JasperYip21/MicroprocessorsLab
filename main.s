


	#include <xc.inc>
	
psect	code, abs
main:
	org 0x00
	goto	setup
	
	org 0x100		    ; Main code starts here at address 0x100

	; ******* Programme FLASH read Setup Code ****  
setup:	
	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	goto	start
	; ******* My data and where to put it in RAM *
myTable:
	db	0x01, 0x02, 0x04, 0x08, 0x80, 0x40, 0x20, 0x10
	db  0x03, 0x06, 0x0C, 0x88, 0xC0, 0x60, 0x30, 0x18
	myArray EQU 0x400	; Address in RAM for data
	counter EQU 0x10
	delayLevel EQU 0x12
	delayCounter EQU 0x14
	delayCounter2 EQU 0x16
	align	2		; ensure alignment of subsequent instructions 
	; ******* Main programme *********************
start:	
        movlw	0x00	; set W=0
	movwf	TRISC, A    ; setup port C to be show only (TRIS=0)
	movlw	0xFF	; set W=FF
	movwf	TRISD, A    ; setup port B to be read only (TRIS=1)
	lfsr	0, myArray	; Load FSR0 with address in RAM	
	movlw	low highword(myTable)	; address of data in PM
	movwf	TBLPTRU, A	; load upper bits to TBLPTRU
	movlw	high(myTable)	; address of data in PM
	movwf	TBLPTRH, A	; load high byte to TBLPTRH
	movlw	low(myTable)	; address of data in PM
	movwf	TBLPTRL, A	; load low byte to TBLPTRL
	movlw	8		; 22 bytes to read
	movwf 	counter, A	; our counter register
loop:
        tblrd*+			; move one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, PORTC	; displays the byte of the TABLAT in PORTB
	movff	TABLAT, POSTINC0	; move read data from TABLAT to (FSR0), increment FSR0
	movff	PORTD, delayLevel	; reads the value of port D and assigns that to the delay-level (outer counter)
	call	delayBody   ; calls the delay loop
	decfsz	counter, A	; count down to zero
	bra	loop		; keep going until finished
		
	goto	0
	
delayBody:
	movlw	0xFF
	movwf	delayCounter, A	    ; sets inner counter to 255
	movff	delayCounter, delayCounter2	; sets innter counter2 to 255
	
delayLoop:  
	decfsz  delayCounter, F ; Decrement inner loop counter, skip next instruction if 0
	goto    delayLoop   ; Loop back to delayLoop if not yet 0
	
	decfsz  delayCounter2, F ; Decrement inner loop counter2, skip next instruction if 0
	goto    delayLoop   ; Loop back to delayLoop if not yet 0

	decfsz  delayLevel, F ; Decrement outer loop counter, skip next instruction if 0
	goto    delayBody   ; Loop back to delayBody if not yet 0
	
	return	; should return to main loop to go through byte sequence

	end	main
	
