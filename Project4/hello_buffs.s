	.include "address_map_nios2.s"
/******************************************************************************
 * Scrolling Messages
 * 
 * Repeat this infinitely: 
 * "Hello Buffs---    "
 *
 ******************************************************************************/
	.text						# executable code follows

	.global	_start
_start:

	/* Set Up Stack */
	movia 	sp, 0x04000000

	/* Set Up Timer */
	movia	r16, HEX3_HEX0_BASE  # HEX3-HEX0 register
	movia 	r12, 5000000		 # 50 ms delay
	sthio 	r12, 8(r16)			 # store LSHW in LS counter regs
	srli	r12, r12, 16		 # bitshift by 2 bytes to get MSHW
	sthio	r12, 0xC(r16)		 # store MSHW in MS counter reg

	/* start interval timer, enable its interrupts */
	movi	r15, 0b0111			 # START = 1, CONT = 1, ITO = 1
	sthio	r15, 4(r16)

	/* Enable Processor Interrupts */
	movia 	r7, 0b0001			# interrupt bit mask for interval timer
	wrctl 	ienable, r7			# write desired interrupts into enable
	movi	r7, 1				# PIE bit mask
	wrctl 	status, r7			# enable PIE in status register

IDLE: 
	br 		IDLE				# what to do when not in an ISR

/******************************************************************************/
	.data						# data follows

	.global BUFFS
BUFFS:	#	HELL		O_BU		FFS-	 	--__
	.word 0x76793838, 0x3F007C3E, 0x71716D40, 0x40400000

	.global BITSHIFT_CTR
BITSHIFT_CTR:	
	.word 0 # out of 32

	.global FRAME_CTR
FRAME_CTR:
	.word 0 # out of 4

	.global END_CTR
END_CTR:
	.word 0 # out of 2

	.end
