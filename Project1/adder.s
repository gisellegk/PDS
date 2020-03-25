	.text
	.equ	LEDs,		0xFF200000
	.equ	SWITCHES,	0xFF200040
	.global _start
_start:
	movia	r2, LEDs		# Address of LEDs         
	movia	r3, SWITCHES	# Address of switches

LOOP:
	ldwio	r4, (r3)		# Read the state of switches
	mov		r5, r4			# make a copy of the sw state 
	andi 	r4, r4, 0x1f    # mask off the lower 5 bits
	srli	r5, r5, 0x05	# bit shift contents of r5 to the right to get the higher 4 bits
	andi	r5, r5, 0x1f	# mask that off to isolate those 5 bits
	add 	r4, r4, r5		# add the 2 numbers together
	stwio	r4, (r2)		# Display the state on LEDs
	br		LOOP

	.end
