# Base-N Calculation
#  N = 26 + (02839083 % 11)
#  N = 26 + 5
#  N = 31
#  M = N - 10
#  M = 21

.data
	array:		.space 4000		#1000 element array (1 NULL space)
	array_size:	.word 10		#10 elements in array
	char: 		.space 2		#1 byte for char, 1 byte for NULL
	newline:	.asciiz "\n"		#newline character
	invalid:	.asciiz "Invalid input"	#displays to user if input is invalid

.text
main:

	getInput:				#gets all of the input from a user until they hit '\n'
		la $s0, array			#load address of array into $s0
		move $s3, $zero			#counter to keep track of how many chars
		loop:	
			jal getChar		#jump to getChar
			lb $t0, char		#load a single byte into $t0, remove null
			sb $t0, 0($s0)		#store the char array
			lb $t1, newline		#load '\n' into $t1
			beq $t0, $t1, exit	#end of string ? jump to exit
			beq $s3, 1000, exit	#1000 chars ? jump to exit
			addi $s0, $s0, 4	#$s0 += 4

			j loop			#jumps back to start of loop

			
	
		getChar:		#gets a single character input from user
			li $v0, 8	#read_string command
			la $a0, char	#load address of char for read
			li $a1, 2	#length of string is 1byte char and 1byte for null
			syscall
			addi $s3, $s3, 1#adds 1 to $s3

			jr $ra
	
	badChar:
		li $v0, 4	#print_string command
		la $a0, invalid	#load "Invalid input" into $a0
		syscall		#execute print_string
		j exit		#jumps to exit


	exit:			#finishes the programs
		li $v0, 10	#exit_program command
		syscall		#terminates program