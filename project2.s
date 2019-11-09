# Base-N Calculation
#  N = 26 + (02839083 % 11)
#  N = 26 + 5
#  N = 31
#  M = N - 10
#  M = 21

.data
	array:			.space 4000			#1000 element array (1 NULL space)
	baseN:			.word 31			#base-N number
	char: 			.space 2			#1 byte for char, 1 byte for NULL
	invalid:		.asciiz "Invalid input"		#displays to user if input is invalid
	newline:		.asciiz "\n"			#newline character
	space:			.asciiz " "			#space character
	tab:			.asciiz "\t"			#tab character

.text
main:

	getInput:					#gets all of the input from a user until they hit '\n'
		la $s0, array				#load address of array into $s0
		move $s3, $zero				#counter to keep track of how many chars
		move $s7, $zero				#stores sum
		loop:	
			jal getChar			#jump to getChar
			lb $t0, char			#load a single byte into $t0, remove null
			sb $t0, 0($s0)			#store the char array
			lb $t1, newline			#load '\n' into $t1
			beq $t0, $t1, checkSpace	#end of string ? jump to checkSpace
			beq $s3, 1000, checkSpace	#1000 chars ? jump to checkSpace
			addi $s0, $s0, 4		#$s0 += 4

			j loop				#jumps back to start of loop

			
	
		getChar:				#gets a single character input from user
			li $v0, 8			#read_string command
			la $a0, char			#load address of char for read
			li $a1, 2			#length of string is 1byte char and 1byte for null
			syscall				#execute read_string
			addi $s3, $s3, 1		#$s3 += 1

			jr $ra				#return to loop
	
	checkSpace:					#checks for white space characters that appear before a non-white space character
		lb $t2, space				#load ' ' into $t2
		lb $t3, tab				#load '\t' into $t3
		lb $t4, newline				#load '\n' into $t4
		la $s0, array				#load address of array into $s0
		addi $s0, $s0, -4			#move 4 bytes before array
		loop2:					#loops through array checking each character
			move $s1, $s0			#stores address of FIRST CHAR to $s1
			addi $s0, $s0, 4		#increment address
			addi $s3, $s3, 1		#adds 1 to $s3
			lb $t1, 0($s0)			#loads current char in array into $t1
			beq $t1, $t2, loop2		#char is ' ' ? jump to loop2
			beq $t1, $t3, loop2		#char is '\t' ? jump to loop2
			beq $t1, $t4, exit		#char is '\n' ? jump to exit
			move $s3, $zero			#resets counter to keep track of how many chars
			addi $s3, $s3, 1		#starts counter at 1
			j checkLength			#jump to checkLength

	
	addChar:					#adds characters to a running sum
		convert:				#converts ascii values && checks for validity
			blt $s4, 48, _zero		#if ($s4) < 48, jump to _zero
			bgt $s4, 57, check_upper	#if ($s4) > 57, jump to check_upper
			addi $s4, $s4, -48		#else, ($s4) = ($s4) - 48
			add $s7, $s7, $s4		#adds $t3 to total sum
			jr $ra				#returns to checkChar in order to increment array element

	_zero:
	check_upper:
	check_lower:

	checkLength:
		beq $t1, $t4, checkChar			#char is '\n' ? jump to preCheckChar
		beq $t1, $t2, badChar			#char is ' ' ? jump to badChar
		beq $t1, $t3, badChar			#char is '\t' ? jump to badChar
		beq $s3, 5, badChar			#$s3 == 5 ? jump to badChar
		addi $s3, $s3, 1			#$s3 += 1
		move $s2, $s0				#stores address of LAST CHAR (that isn't '\n') to $s2
		addi $s0, $s0, 4			#increment address
		
		lb $t1, 0($s0)				#loads current char in array into $t1
		j checkLength				#jump back to start of checkLength
	
	checkChar:					#checks for characters that are within Base-N's range
		lb $s4, 0($s2)				#loads current char in array into $s4

#this is	#li $v0, 11
#for debug	#move $a0, $s4
#testing	#syscall
		
		jal convert				#jumps to convert && remembers this address
		addi $s2, $s2, -4			#decrement address
		beq $s2, $s1, exit			#address is starting address ? jump to exit

		j checkChar				#jump back to start of checkChar


	badChar:
		li $v0, 4				#print_string command
		la $a0, invalid				#load "Invalid input" into $a0
		syscall					#execute print_string
		j exit					#jumps to exit


	exit:						#finishes the program
		li $v0, 10				#exit_program command
		syscall					#terminates program