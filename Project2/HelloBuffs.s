/******************************************************************************
 * Scrolling Messages
 * Write a busy-wait assembly program that scrolls "Hello Buffs---    "
 * Across the HEX display of the DE10 Lite Board. Only use the first 4 
 * HEX displays (the ones at 0xFF200020). 
 * The program should then alternate between Pattern A (all horizontal
 * segments) and Pattern B (all vertical segments) 3 times, followed by
 * the pattern (all 7 segments are lit). 
 * 
 * Repeat this infinitely: 
 * "Hello Buffs---    "
 * A B A B A B
 * C (blank) C (blank) C (blank)
 *
 ******************************************************************************/
	.text						# executable code follows
 	.equ	HEX,		0xFF200020 
	.global	_start
_start:
	movia	r2, HEX 			# HEX3-HEX0 register
	movia	r5, 32				# bitshift ctr / hack fix for zero problem
RESET:
	movia 	r3, BUFFS			# ptr to BUFFS data
	ldw		r4, 0(r3)			# current word = first index of buffs
	movia	r6, 0				# current frame
	movia	r7, 4				# frame_ctr
CRAWL_WORD: 		
	beq		r5, r0, NEXT_WORD
	subi	r5, r5, 8			# sub 8 from bitshift_ctr
	slli	r6, r6, 8			# push current_frame left by 1 letter
	srl		r8, r4, r5			# shift current_word by bitshift ctr, then store in temp var
	or		r6, r6, r8			# OR current_frame with temp(bitshifted current_word)
	stwio	r6, 0(r2)			# store current_frame into HEX reg
	movia	r9, 25000000		# delay counter
DELAY:
	subi	r9, r9, 1
	bne		r9, r0, DELAY		# sub 1, delay until 0
	br		CRAWL_WORD			# go back and check to see if you're done
NEXT_WORD:
	movia	r5, 32				# reset bitshift ctr
	ldw		r4, 4(r3)			# load new word
	addi	r3, r3, 4			# increment BUFFS ptr
	subi	r7, r7, 1			# decrement frame ctr
	bne		r7, r0, CRAWL_WORD	# if not out of data, go back
	br		RESET
/******************************************************************************/
	.data						# data follows
BUFFS:	#	HELL		O_BU		FFS-	 	--__
	.word 0x76793838, 0x3F007C3E, 0x71716D40, 0x40400000
AB: 	#  horizontal vertical
	.word 0x49494949, 0x36363636
CD:		#  All segs		no segs
	.word 0x7F7F7F7F, 0x00000000

	.end
/*
# H: 0111 0110
# E: 0111 1001
# L: 0011 1000
# O: 0011 1111
# b: 0111 1100
# U: 0011 1110
# F: 0111 0001
# S: 0110 1101
# -: 0100 0000
# NONE: 0000 0000
# HORIZ: 0100 1001
# VERT: 0011 0110 
# ALL: 0111 1111
*/
