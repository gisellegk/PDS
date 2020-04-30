	.include "address_map_nios2.s"
	.include "globals.s"

/*******************************************************************************
 * This program demonstrates use of interrupts. It
 * first starts an interval timer with 50 msec timeouts, and then enables 
 * Nios II interrupts from the interval timer and pushbutton KEYs
 *
 * The interrupt service routine for the interval timer displays a pattern
 * on the HEX3-0 displays, and rotates this pattern either left or right:
 *		KEY[0]: loads a new pattern from the SW switches
 *		KEY[1]: toggles rotation direction
 ******************************************************************************/

	.text						# executable code follows
	.global _start
_start:
	/* set up the stack */
	movia 	sp, SDRAM_END - 3	# stack starts from largest memory address

	movia	r16, TIMER_BASE		# interval timer base address
	/* set the interval timer period for scrolling the HEX displays */
	movia	r12, 50000000		# 1/(100 MHz) x (5 x 10^6) = 50 msec
	sthio	r12, 8(r16)			# store the low half word of counter start value
	srli	r12, r12, 16
	sthio	r12, 0xC(r16)		# high half word of counter start value

	/* start interval timer, enable its interrupts */
	movi	r15, 0b0111			# START = 1, CONT = 1, ITO = 1
	sthio	r15, 4(r16)

	/* write to the pushbutton port interrupt mask register */
	movia	r15, KEY_BASE		# pushbutton key base address
	movi	r7, 0b11			# set interrupt mask bits
	stwio	r7, 8(r15)			# interrupt mask register is (base + 8)

	/* Initialize CURR_WORD_PTR */
	movia	r7, BUFFS			# Initialize CUR_WORD_PTR
	movia	r8, CURR_WORD_PTR
	stw 	r7, (r8)

	/* enable Nios II processor interrupts */
	movia	r7, 0x00000001		# get interrupt mask bit for interval timer
	movia	r8, 0x00000002		# get interrupt mask bit for pushbuttons
	or		r7, r7, r8
	wrctl	ienable, r7			# enable interrupts for the given mask bits
	movi	r7, 1
	wrctl	status, r7			# turn on Nios II interrupt processing

IDLE:
	br 		IDLE				# main program simply idles

	.data
/*******************************************************************************
 * The global variables used by the interrupt service routines for the interval
 * timer and the pushbutton keys are declared below
 ******************************************************************************/
	.global STATE
STATE:
	.word 	0x0

	.global BITSHIFT_CTR
BITSHIFT_CTR:
	.word 	32

	.global BUFFS
BUFFS:	#	HELL		O_BU		FFS-	 	--__
	.word 0x76793838, 0x3F007C3E, 0x71716D40, 0x40400000, 0x00000000

	.global CURR_WORD_PTR
CURR_WORD_PTR:
	.word 0x0 # MUST POPULATE WITH PTR TO BUFFS[n]

	.global WORD_CTR
WORD_CTR:
	.word 0x4

	.end
