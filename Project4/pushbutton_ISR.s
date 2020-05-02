	.include "address_map_nios2.s"
	.include "globals.s"
	.extern	PATTERN					# externally defined variables
	.extern	SHIFT_DIR
	.extern	SHIFT_EN
/*******************************************************************************
 * Pushbutton - Interrupt Service Routine
 *
 * This routine checks which KEY has been pressed and updates the global
 * variables as required.
 ******************************************************************************/
	.global	PUSHBUTTON_ISR
PUSHBUTTON_ISR:
	subi	sp, sp, 20				# reserve space on the stack
	stw		ra, 0(sp)
	stw		r10, 4(sp)
	stw		r11, 8(sp)
	stw		r12, 12(sp)
	stw		r13, 16(sp)

	movia	r10, KEY_BASE			# base address of pushbutton KEY parallel port
	ldwio	r11, 0xC(r10)			# read edge capture register
	stwio	r11, 0xC(r10)			# clear the interrupt	  

	movia	r10, LEDR_BASE			# base address of LEDs
	ldwio	r12, 0(r10)				# get speed value from LEDs (binary)

CHECK_KEY0: # increase speed
	andi	r13, r11, 0b0001		# check KEY0
	beq		r13, zero, CHECK_KEY1

	movi	r13, 6
	beq		r12, r13, END_PUSHBUTTON_ISR # if speed == 6 end

	addi	r12, r12, 1				#increase speed
	stwio	r12, 0(r10)				#store to leds
	
	movia 	r10, TIMER_BASE			# timer base
	ldhio	r13, 0xC(r10)			# get current delay
	subi	r13, r13, 0x40			# subtract 0x40
	sthio 	r13, 0xC(r10)			# store new delay
	
CHECK_KEY1:
	andi	r13, r11, 0b0010		# check KEY1
	beq		r13, zero, END_PUSHBUTTON_ISR
	
	beq		r12, r0, END_PUSHBUTTON_ISR

	subi	r12, r12, 1				#decrease speed
	stwio	r12, 0(r10)				#store to leds

	movia 	r10, TIMER_BASE			# timer base
	ldhio	r13, 0xC(r10)			# get current delay
	addi	r13, r13, 0x40			# addi 0x40
	sthio 	r13, 0xC(r10)			# store new delay

END_PUSHBUTTON_ISR:
	movi	r13, 0b0111			# START = 1, CONT = 1, ITO = 1
	sthio	r13, 4(r16)

	ldw		ra,  0(sp)				# Restore all used register to previous
	ldw		r10, 4(sp)
	ldw		r11, 8(sp)
	ldw		r12, 12(sp)
	ldw		r13, 16(sp)
	addi	sp,  sp, 20

	ret
	.end	
