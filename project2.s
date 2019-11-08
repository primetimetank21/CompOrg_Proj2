# Base-N Calculation
#  N = 26 + (02839083 % 11)
#  N = 26 + 5
#  N = 31
#  M = N - 10
#  M = 21

.data
	array:		.space 4000			#1000 element array (1 NULL space)
	array_size:	.word 10			#10 elements in array
	char: 		.space 2			#1 byte for char, 1 byte for NULL
	invalid:	.asciiz "Invalid input"		#displays to user if input is invalid
	newline:	.asciiz "\n"			#newline character
	space:		.asciiz " "			#space character
	tab:		.asciiz "\t"			#tab character

.text
main:

	getInput:					#gets all of the input from a user until they hit '\n'
		la $s0, array				#load address of array into $s0
		move $s3, $zero				#counter to keep track of how many chars
		loop:	
			jal getChar			#jump to getChar
			lb $t0, char			#load a single byte into $t0, remove null
			sb $t0, 0($s0)			#store the char array
			lb $t1, newline			#load '\n' into $t1
			beq $t0, $t1, checkSpace	#end of string ? jump to exit
			beq $s3, 1000, checkSpace	#1000 chars ? jump to exit
			addi $s0, $s0, 4		#$s0 += 4

			j loop				#jumps back to start of loop

			
	
		getChar:				#gets a single character input from user
			li $v0, 8			#read_string command
			la $a0, char			#load address of char for read
			li $a1, 2			#length of string is 1byte char and 1byte for null
			syscall				#execute read_string
			addi $s3, $s3, 1		#adds 1 to $s3

			jr $ra				#return to loop
	
	checkSpace:					#checks for white space characters that appear before a non-white space character
		la $s0, array				#load address of array into $s0
		loop2:					#loops through array checking each character
			lb $t1, 0($s0)			#loads current char in array into $t1
			lb $t2, space			#load ' ' into $t2
			lb $t3, tab			#load '\t' into $t3
			#lb $t4, newline			#load '\n' into $t4
			bne $t1, $t2, checkChar		#char is ' ' ? jump to checkChar
			bne $t1, $t3, checkChar		#char is '\t' ? jump to checkChar
			#bne $t1, $t4, exit		#char is '\n' ? jump to exit

			addi $s0, $s0, 4		#increment address
			j loop2				#jump back to start of loop2
	
	checkChar:					#checks for characters that are within Base-N's range
		lb $t2, space				#load ' ' into $t2
		lb $t3, tab				#load '\t' into $t3
		lb $t4, newline				#load '\n' into $t4
		beq $t1, $t2, badChar			#char is ' ' ? jump to badChar
		beq $t1, $t3, badChar			#char is '\t' ? jump to badChar
		beq $t1, $t4, exit			#char is '\n' ? jump to exit


	badChar:
		li $v0, 4				#print_string command
		la $a0, invalid				#load "Invalid input" into $a0
		syscall					#execute print_string
		j exit					#jumps to exit


	exit:						#finishes the programs
		li $v0, 10				#exit_program command
		syscall					#terminates program