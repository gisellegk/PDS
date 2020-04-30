	.text						# executable code follows
# FUNCTIONS
# int sum_two(int a, int b)
	.global sum_two
sum_two:
	add r2, r4, r5
	ret

# int op_three(int a, int b, int c)
	.global op_three
op_three:
	subi sp, sp, 8
	stw r16, 4(sp) 
	stw ra, (sp)

	# r4 = a, r5 = b, r6 = c
	mov r16, r6 # saves value of c in r16
#	call sum_two
	call op_two
	# a o b is now in r2
	mov r4, r16 # move c into first parameter spot
	mov r5, r2 # move result of a o b into second parameter spot
#	call sum_two
	call op_two
	# a o b o c is now in r2.

	ldw ra, (sp)
	ldw r16, 4(sp)
	addi sp, sp, 8
	ret

# int fibonacci(int n) {
# 		if (n <= 1) return n;
#		else
#			result = fib(n-1)
#			return (fib(n-2) + result)

	.global fibonacci
fibonacci:
	subi sp, sp, 8
	stw ra, 4(sp)
	stw r4, 0(sp) # save on the stack

	movi r2, 1
	bgt r4, r2, fib_else
	mov r2, r4
	br fib_done

fib_else:
	subi r4, r4, 1
	call fibonacci
	#result in r2

	ldw r4, (sp) #take n out of the stack
	subi r4, r4, 2 # n - 1
	stw r2, 0(sp) # put result of previous in stack
	call fibonacci

	ldw r4, (sp) # intermediate result back in r4
	add r2, r2, r4

fib_done:
	ldw ra, 4(sp)
	addi sp, sp, 8
	ret

	.end
