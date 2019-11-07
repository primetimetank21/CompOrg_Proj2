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

	badChar:
		li $v0, 4	#print_string command
		la $a0, invalid	#load "Invalid input" into $a0
		syscall		#execute print_string
		j exit		#jumps to exit


	exit:			#finishes the programs
		li $v0, 10	#exit_program command
		syscall		#terminates program