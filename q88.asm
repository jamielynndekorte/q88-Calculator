# Jamie Laughlin
# Project 1
# CS0447
.text
loop:
	beq $t9, $zero, loop
	
	add $s0, $zero, $a0	# put A in $s0
	add $s1, $zero, $a1	# put B is $s1
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Addition~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	add $s2, $s0, $s1	# A + B put in $s2
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Subtraction~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	sub $s3, $s0, $s1	# A - B put in $s1
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Prepare results in $v0: A - B | A + B~~~~~~~~~~~~~~~~~~~~~
	add $v0, $zero, $s3	# Put subtraction answer in
	sll $v0, $v0, 16	# Shift over 16 bits
	andi $s2, $s2, 0xffff	
	or $v0, $v0, $s2	# Put in addition answer
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Multiplication~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	add $t0, $zero, $s0	# Makes copy of A in $t0		
	add $t1, $zero, $s1	# Makes copy of B in $t1
	addi $s2, $zero, 0	# Sets $s2 to 0
	slti $t3, $t0, 0	# Checks if A is negative
	beq $t3, 0, nextNumber	# Does nothing if A is positive
	xori $t0, $t0, 0xffffffff	# Converts A to positive if negative
	addi $t0, $t0, 1
nextNumber:
	slti $t4, $t1, 0	# Checks if B is negative
	beq $t4, 0, addLoop	# Does nothing if B is positive
	xori $t1, $t1, 0xffffffff	# Converts B to potivie if negative
	addi $t1, $t1, 1	
addLoop:
	andi $t2, $t1, 1		# Stores the LSB of the second integer
	beq  $t2, $zero, skip		# if the LSB is zero, skip adding
	add  $s2, $s2, $t0		# if the LSB is one, addition will occur
skip:
	sll $t0, $t0, 1			# Shifts the first integer left by one
	srl $t1, $t1, 1			# Shifts the second integer right by one
	beq $t0, $zero, done1		# Checks if the first integer has been shifted to zero
	beq $t1, $zero, done1		# Checks if the second integer has been shifted to zero
	j addLoop			# Performs algorithm again if neither integers are zero
done1:	
	beq $t3, $t4, doneMult		# Checks if the answer should be negative
	xori $s2, $s2, 0xffffffff	# Converts to negative if the answer should be negative
	addi $s2, $s2, 1
doneMult:
	srl $s2, $s2, 8		# Shifts answer over 8
	
	add $v1, $zero, $zero	# Empties $v1
	andi $s2, $s2, 0xffffffff	
	or $v1, $v1, $s2	# Puts multiplication answer into $v1
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Division~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	add $t0, $zero, $s0	# Clears out variables 
	add $t1, $zero, $s1	# Saves copies of B
	add $t8, $zero, $s1	
	addi $s2, $zero, 0	# Clears out variables
	addi $s3, $zero, 0
	addi $s4, $zero, 0
	slti $t5, $t0, 0	# Checks if A is negative
	beq $t5, 0, nextNumber1	# Does nothing if A is positive
	xori $t0, $t0, 0xffffffff	# Converts to positive if A was negative
	addi $t0, $t0, 1
nextNumber1:
	slti $t6, $t1, 0	# Checks if B is negative
	beq $t6, 0, division	# Does nothing ig B is positive
	xori $t1, $t1, 0xffffffff	# Converts to positive if B was negative
	addi $t1, $t1, 1
	add $t8, $zero, $t1
	
division:	
	addi $t2, $zero, 0x10000	# Sets variable that will pull desired bits
	addi $t3, $zero, 0	# Clears $t3
	sll $t1, $t1, 16	# shifts $t1 left 16
divisionloop:
	slt $t4, $t0, $t1	# Checks if $t4 < $t0
	beq $t4, 1, divskip	# skips if $t4 < $t0
	add $s3, $s3, $t2	# Adds $s3, $t2
	sub $t0, $t0, $t1	# Subtracts $t0, $t1
divskip:
	srl $t1, $t1, 1		# Shifts $t1 to the right one
	srl $t2, $t2, 1		# Shifts $t2 ot the left 1
	addi $t3, $t3, 1	# adds one to $t3
	beq $t3, 17, donediv1	# Checks if the algorithm has been performed enough times
	j divisionloop		# goes back to top of loop
		
		# Repeat of the division algorithm to find remainder decimal
donediv1:
	sll $s3, $s3, 8
	sll $t0, $t0, 8
	add $t1, $zero, $t8
	addi $t2, $zero, 0x10000 
	addi $t3, $zero, 0
	sll $t1, $t1, 16
divisionloop2:
	slt $t4, $t0, $t1
	beq $t4, 1, divskip2
	add $s4, $s4, $t2
	sub $t0, $t0, $t1
divskip2:
	srl $t1, $t1, 1
	srl $t2, $t2, 1
	addi $t3, $t3, 1
	beq $t3, 17, donediv2
	j divisionloop2
donediv2:	
	or $s5, $s3, $s4 	# Puts together answer with decimal
	
	beq $t5, $t6, donediv	# If the answer is supposed to be positive, skip
	xori $s5, $s5, 0xffffffff	# Converts to negative
	addi $s5, $s5, 1
donediv:	
	sll $s5, $s5, 16	# Shift answer over to put in $v1
	andi $v1, $v1, 0x0000ffff	# Puts answer into $v1
	or $v1, $s5, $v1
	
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Square Root~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	add $t0, $zero, $s0		# put A in $t0	
	slti $t3, $t0, 0		# check if A is negative
	beq $t3, 0, donedone		# do nothing if A is positive
	xori $t0, $t0, 0xffffffff	# Converts A to positive if negative
	addi $t0, $t0, 1
donedone:
	addi $t5, $t5, 0	#initialize counter
	addi $t4, $t4, 0	
	add $t1, $zero, $t0	# put number to square root in $t1
	sll $t1, $t1, 8		# shift number over by 8
	addi  $t0, $zero, 1	# Set $t0 to 1
  	sll   $t0, $t0, 30      # Shift to get first two bits
sqrtgetbit:
  	slt   $t2, $t1, $t0     # see if number is less than one
  	beq   $t2, $zero, findnextloop	# If number is greater then one skip 
  	srl   $t0, $t0, 2       # shift $t0 right 2
  	j     sqrtgetbit	# loop if number is less than one
findnextloop:
  	beq   $t0, $zero, sqrtdone	# If $t0 is zero then square root has been found 	
  	add   $t3, $s3, $t0     # Add the bit to the answer
  	slt   $t2, $t1, $t3	# If number is less than temporary number
  	beq   $t2, $zero, sqrtone	# if temporary number is not less than answer subtract it from the number
  	srl   $s3, $s3, 1       # Shift the answer one
  	j     sqrtloopnext	# add the next two bits on to the number
sqrtone:
  	sub   $t1, $t1, $t3     # subtract the temporary number from the answer
  	srl   $s3, $s3, 1       # shift the answer one
  	add   $s3, $s3, $t0     # add one to the answer
sqrtloopnext:
  	srl   $t0, $t0, 2       # get the next two bits
  	j     findnextloop
sqrtdone:
	

	
	addi $a2, $s3, 0	# put answer into $a2
	
	add $t9, $zero, $zero	# end 
	j loop
