/******************************************************************************
 * LED program
 ******************************************************************************/

	.text						# executable code follows
	.equ	TIMER_STATUS, 			0xFF202000
	.equ	TIMER_CTRL,				0xFF202004
	.equ	TIMER_START_LSB,		0xFF202008
	.equ	TIMER_START_MSB, 		0xFF20200C
	.equ	TIMER_SNAP_LSB,			0xFF202010
	.equ	TIMER_SNAP_MSB,			0xFF202014
	.equ	GPIO_IO,				0xFF200060
	.equ	GPIO_DIR,				0xFF200064
	.equ	TIMER_START,			0x4
	.equ	TIMER_STATUS_TO,		0x1
	.equ	ZERO_H,					0x19 # 25 clock cycles
	.equ	ZERO_L,					0x41 # 65 clock cycles
	.equ	ONE_H,					0x37 # 55 clock cycles
	.equ	ONE_L,					0x2D # 45 clock cycles
	.equ	NUM_PIXELS,				0x9
	.equ	RST,					0x1388
.macro WRITE_ONE
	movia	r4, 0x1
	movia 	r5, ONE_H 
	call 	WRITE_DATA
	movia	r4, 0x0
	movia 	r5, ONE_L 
	call 	WRITE_DATA
.endm
.macro WRITE_ZERO
	movia	r4, 0x1
	movia 	r5, ZERO_H 
	call 	WRITE_DATA
	movia	r4, 0x0
	movia 	r5, ZERO_L 
	call 	WRITE_DATA
.endm
.macro WRITE_RST
	movia	r4, 0x0
	movia 	r5, RST 
	call 	WRITE_DATA
.endm

	.global	_start
_start:
	# Set Default Value to output as off
	movia 	r16, GPIO_IO
	stwio	r0, 0(r16)
	# Set Pin 0 as an output
	movia 	r8, GPIO_DIR
	movia	r9, 0x1
	stwio	r9, 0(r8)
	# initialize timer MSB to be zero
	movia	r8, TIMER_START_MSB
	stwio	r0, 0(r8)
	# initialize some variables
	movia 	r17, TIMER_START_LSB
	movia	r18, TIMER_CTRL
	movia	r19, TIMER_STATUS

	# num pixels
	movia	r20, NUM_PIXELS
	movia 	r14, 0xFF0000
	movia 	r13, 0x00FF00
	movia 	r12, 0x0000FF
	movia 	r11, 0x8

#MAIN GOES HERE
MAIN_LOOP:
#	WRITE_ZERO
#	WRITE_ONE
	mov		r15, r20

POPULATE_STRIP:
	mov	r4, r14
	call 	WRITE_PIXEL
	mov	r4, r13
	call 	WRITE_PIXEL
	mov	r4, r12
	call 	WRITE_PIXEL
	subi	r15, r15, 0x3
	bne		r0, r15, POPULATE_STRIP
	WRITE_RST
	call 	DELAY

	rol r14, r14, r11
	rol r13, r13, r11
	rol r12, r12, r11
	br		MAIN_LOOP
#END OF MAIN

# DELAY
DELAY:
	movia	r9, 10000000		# delay counter
DELAY_LOOP:
	subi	r9, r9, 1
	bne		r9, r0, DELAY_LOOP		# sub 1, delay until 0
	ret

# WRITE_SEQUENCE(int color)
WRITE_PIXEL:
	subi	sp, sp, 4 	#1
	stw		ra, (sp)	#4
	movia	r21, 0x18 # there are 24 bits in a pixel 
	mov		r22, r4  # data
	movia 	r23, 0x800000 # constant ugh

LOOP:
	# AND data with 0x800000 to get msb
	and 	r9, r22, r23
	# if it's a 1 br, else don't br 
	bne		r0, r9, ONE
	WRITE_ZERO
	br		CONT
ONE:
	WRITE_ONE
CONT: 
	# shift data left #1
	slli	r22, r22, 0x1
	# subtract 1 from r21 #1
	subi	r21, r21, 0x1
	# if r21 != 0, loop. #2
	bne		r0, r21, LOOP

	ldw		ra, (sp)
	addi	sp, sp, 4
	ret


# WRITE_DATA(bool data, int delay)
WRITE_DATA:
#	subi	sp, sp, 4 	#1
#	stw		ra, (sp)	#4
	
	#write data to the output
	stwio	r4, 0(r16) #4
	#clear TO register
	stwio	r0, 0(r19) #4
	# set counter value
	subi 	r5, r5, 0x17 #1	# subtract some constant for the function
	stwio	r5, 0(r17) #4	# store in TIMER_START_LSB
	# start timer
	movia	r9, TIMER_START	# 1
	stwio	r9, 0(r18) #4			# write 1 to start bit in ctrl reg
POLL:
	# read STATUS
	movia	r9, TIMER_STATUS
	ldwio	r9, 0(r9)
	# Mask off TO
	andi	r9, r9, TIMER_STATUS_TO
	# if TO = 0, jump to POLL
	beq		r9, r0, POLL
	# else return
#	ldw		ra, (sp)
#	addi	sp, sp, 4
	ret

TEST_LOOP:
	movia	r4, 0x1
	stwio	r4, 0(r16)
	movia	r4, 0x0
	stwio	r4, 0(r16)
	br 		TEST_LOOP


END:
/******************************************************************************/
	.data						# data follows

RED:
	.word 0x0000FF00
	.end
