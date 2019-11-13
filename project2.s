# Base-N Calculation
#  N = 26 + (02839083 % 11)
#  N = 26 + 5
#  N = 31
#  M = N - 10
#  M = 21

.data
	array:			.space 4000			#1000 element array (1 NULL space)
	baseN:			.word 31			#base-N^1
	baseN2:			.word 961			#base-N^2
	baseN3:			.word 29791			#base-N^3
	char: 			.space 2			#1 byte for char, 1 byte for NULL
	invalid:		.asciiz "Invalid input"		#displays to user if input is invalid
	newline:		.asciiz "\n"			#newline character
	space:			.asciiz " "			#space character
	tab:			.asciiz "\t"			#tab character

.text
	main:

	getInput:						#gets all of the input from a user until they hit '\n'
		la $s0, array					#load address of array into $s0
		move $s3, $zero					#counter to keep track of valid chars
		move $s7, $zero					#stores sum
		move $s5, $zero					#counter to keep track of which valid element
		move $s6, $zero					#check whether or not to leave program
		loop:	
			jal getChar				#jump to getChar
			lb $t0, char				#load a single byte into $t0, remove null
			sb $t0, 0($s0)				#store the char array
			lb $t1, newline				#load '\n' into $t1
			beq $t0, $t1, checkSpace_start		#($t1) == '\n' ? jump to checkSpace
			addi $s0, $s0, 4			#$s0 += 4
			j loop					#jumps back to start of loop
	
		getChar:					#gets a single character input from user
			li $v0, 8				#read_string command
			la $a0, char				#load address of char for read
			li $a1, 2				#length of string is 1byte char and 1byte for null
			syscall					#execute read_string
			#addi $s3, $s3, 1			#$s3 += 1
			jr $ra					#return to loop
	
	checkSpace_start:					#checks for white space characters that appear before a non-white space character
		lb $t2, space					#load ' ' into $t2
		lb $t3, tab					#load '\t' into $t3
		lb $t4, newline					#load '\n' into $t4
		la $s0, array					#load address of array into $s0
		addi $s0, $s0, -4				#move 4 bytes before array

		loop2:						#loops through array checking each character
			move $s1, $s0				#stores address of FIRST CHAR to $s1
			addi $s0, $s0, 4			#increment address
			#addi $s3, $s3, 1			#adds 1 to $s3
			lb $t1, 0($s0)				#loads current char in array into $t1
			beq $t1, $t2, loop2			#char is ' ' ? jump to loop2
			beq $t1, $t3, loop2			#char is '\t' ? jump to loop2
			#beq $t1, $t4, exit			#char is '\n' ? jump to exit
			move $s3, $zero				#resets counter to keep track of how many chars
			#addi $s3, $s3, 1			#starts counter at 1
			j checkLength				#jump to checkLength

	pow1:							#multiplies number by baseN^1
		lw $t1, baseN					#($t1) = baseN^1
		mult $t1, $s4					#($LO) = base-N^1 * ($s4)
		mflo $s4					#($s4) = ($LO)
		j increase					#jumps to increase

	pow2:							#multiplies number by baseN^2
		lw $t1, baseN2					#($t1) = baseN^2
		mult $s4, $t1					#($LO) = ($s4) * baseN^2
		mflo $s4					#($s4) = ($LO)
		j increase					#jumps to increase

	pow3:							#multiplies number by baseN^3
		lw $t1, baseN3					#($t1) = baseN^3
		mult $t1, $s4					#($LO) = ($s4) * baseN^3
		mflo $s4					#($s4) = ($LO)
		j increase					#jumps to increase
	
	addChar:						#adds characters to a running sum
		convert:					#converts ascii values && checks for validity
			blt $s4, 48, badChar			#if ($s4) < 48, jump to badChar
			bgt $s4, 57, check_upper		#if ($s4) > 57, jump to check_upper
			addi $s4, $s4, -48			#else, ($s4) = ($s4) - 48

			_return:
				beq $s5, 1, pow1		#jumps to pow1 if ($s5) == 0
				beq $s5, 2, pow2		#jumps to pow2 if ($s5) == 0
				beq $s5, 3, pow3		#jumps to pow3 if ($s5) == 0

			increase:				#increments $s5 (power counter) && adds to $s7 (total sum)
				addi $s5, $s5, 1		#$s5 += 1
				add $s7, $s7, $s4		#adds $s4 to total sum
				jr $ra				#returns to checkChar in order to increment array element

	check_upper:						#checks upper case char range
		blt $s4, 65, badChar				#if array[i] < 65, jump to badChar 
		bgt $s4, 85, check_lower			#if array[i] > 85, jump to check_lower
		addi $s4, $s4, -64				#else, ($s4) = ($s4) - 64
		addi $s4, $s4, 9				#($s4) = ($s4) + 9
		j _return	  				#jumps to _return

	check_lower:						#checks lower case char range
		blt $s4, 97,  badChar				#if ($s4)] < 97, jump to badChar 
		bgt $s4, 117, badChar				#if ($s4) > 117, jump to badChar 
		addi $s4, $s4, -96				#else, ($s4) = ($s4) - 96
		addi $s4, $s4, 9				#($s4) = ($s4) + 9
		j _return	  				#jumps to _return		

	checkSpace_end:						#checks for white space characters that appear after a non-white space character
		addi $s6, $s6, 1				#$s6 += 1
		j back						#jumps to back

	checkLength:						#checks length of string
		beq $t1, $t4, checkChar				#($t1) == '\n' ? jump to checkChar
		beq $t1, $t2, checkSpace_end			#($t1) == ' '  ? jump to checkSpace_end
		beq $t1, $t3, checkSpace_end			#($t1) == '\t' ? jump to checkSpace_end
		beq $s3, 4, badChar				#($s3) == 4    ? jump to badChar
		addi $s3, $s3, 1				#$s3 += 1
		bgt $s6, 0, badChar				#jumps to badChar iff there are ' ' or '\t' in-between non-whitespace chars
		move $s2, $s0					#stores address of LAST CHAR (that isn't '\n') to $s2
	back:	addi $s0, $s0, 4				#increment address
		lb $t1, 0($s0)					#loads current char in array into $t1
		j checkLength					#jump back to start of checkLength
	
	checkChar:						#checks for characters that are within Base-N's range
		lb $s4, 0($s2)					#loads current char in array into $s4
		jal convert					#jumps to convert && remembers this address
		addi $s2, $s2, -4				#decrement address
		beq $s2, $s1, exit				#address is starting address ? jump to exit
		j checkChar					#jump back to start of checkChar

	badChar:						#prints out "Invalid input" && ends program
		li $v0, 4					#print_string command
		la $a0, invalid					#($a0) = "Invalid input"
		syscall						#execute print_string
		li $v0, 10					#exit_program command
		syscall						#terminates program

	exit:							#finishes the program
		li $v0, 1					#print_int command
		move $a0, $s7					#($a0) = ($s7)
		syscall						#prints total sum
		li $v0, 10					#exit_program command
		syscall						#terminates program