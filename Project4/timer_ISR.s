	.include "address_map_nios2.s"
	.include "globals.s"
	.global INTERVAL_TIMER_ISR
INTERVAL_TIMER_ISR:	
	subi	sp,  sp, 40				# reserve space on the stack
	stw		ra, 0(sp)
	stw		r4, 4(sp)
	stw		r8, 8(sp)
	stw		r9, 12(sp)
	stw		r10, 16(sp)
	stw		r11, 20(sp)
	stw		r16, 24(sp)
	stw		r17, 28(sp)
	stw		r18, 32(sp)
	stw		r19, 36(sp)

	movia	r4, TIMER_BASE			# interval timer base address
	sthio	r0,  0(r4)				# clear the interrupt
	movia 	r4, HEX3_HEX0_BASE		# Display address

    movia	r16, STATE				# pointer to state
	ldw		r8, 0(r16)				# load state

	bne 	r8, r0, CLEAR_SCREEN	# if state==0, SCROLL_WORD, 1== CLEAR_SCREEN

SCROLL_WORD:
    movia	r17, BITSHIFT_CTR		# pointer to BITSHIFT_CTR
	ldw		r9, 0(r17)				# load BITSHIFT_CTR
	ldw		r10, 0(r4)				# load CURR_DISP from HEX. 

	movia	r19, CURR_WORD_PTR 		# save CUR_WORD_PTR here (addr to addr)
	ldw 	r18, (r19)				# address of CUR_WORD (addr to value)
	ldw 	r11, (r18)				# value of CUR_WORD (value)

	subi 	r9, r9, 8				# subtract 8 from BITSHIFT_CTR
	slli	r10, r10, 8				# push curr_disp left by 1 char	
	srl		r11, r11, r9			# CURR_WORD >> BITSHIFT_CTR
	or 		r10, r10, r11			# curr_disp |= CURR_WORD
	stwio	r10, 0(r4)				# store new curr_disp into hex

	bne		r9, r0, END_SCROLL		# end if bitshift_counter not zero
NEXT_WORD:
    movia	r11, WORD_CTR			# pointer to WORD_CTR
	ldw		r10, 0(r11)				# load WORD_CTR
	subi	r10, r10, 1				# decrement WORD_CTR
	beq		r10, r0, SWITCH_CLEAR	# if WORD_CTR == 0, time to clear screen next

	movi	r9, 32					# Reset bitshift ctr
	addi	r18, r18, 4					# increment curr_word_ptr

	# save current_word (the ptr not the value), word_ctr
	stw		r10, 0(r11)				# save word_ctr
	stw		r18, 0(r19)				# save incremented curr_word pointer

END_SCROLL:
	# save bitshift_ctr, current_disp does not need to be saved bc it's in HEX. 
	stw		r9, 0(r17)				# store new bitshift value
	br		END_TIMER_ISR

SWITCH_CLEAR:
	movi	r8, CLEAR_STR_STATE		# set state to 1 for clear str
	stw		r8, 0(r16)				# store new state
	br		END_TIMER_ISR			# it will go into clear state at next interrupt

CLEAR_SCREEN:
	ldw		r10, 0(r4)				# load CURR_DISP from HEX. 
	slli	r10, r10, 8				# shift left by 8
	stwio	r10, 0(r4)				# store new curr_disp into hex
	
	bne		r10, r0, END_TIMER_ISR	# if not equal to 0, end isr

RESET_VARS:
	movia	r10, BITSHIFT_CTR		# pointer to BITSHIFT_CTR
	movi	r4, 32					# put default value 
	stw		r4, 0(r10)				# store in BITSHIFT_CTR

	movia	r10, CURR_WORD_PTR		# get address to CURR_WORD 
	movia	r4, BUFFS				# get BUFFS[0] address (default)
	stw 	r4, (r10)				# put default value back in CURR_WORD_PTR

	movia	r10, WORD_CTR			# pointer to WORD_CTR
	movi	r4, 4					# default value
	stw		r4, 0(r10)				# store in WORD_CTR

	movi	r8, SCROLL_STR_STATE	# set state to 0 for scroll str
	stw		r8, 0(r16)				# store new state

END_TIMER_ISR:
	ldw		ra, 0(sp)
	ldw		r4, 4(sp)
	ldw		r8, 8(sp)
	ldw		r9, 12(sp)
	ldw		r10, 16(sp)
	ldw		r11, 20(sp)
	ldw		r16, 24(sp)
	ldw		r17, 28(sp)
	ldw		r18, 32(sp)
	ldw		r19, 36(sp)
	addi	sp,  sp, 40				# release the reserved space on the stack

	ret
	.end
