
.data
_prompt: .asciiz "Enter an integer:"
_ret: .asciiz "\n"
.globl main
.text
jal main
addi $v0 $v0 10
syscall
INPUT:
    li $v0,4 # The address of the string to be PRINTed is assigned to $a0
    la $a0,_prompt
    syscall
    li $v0,5 # Assigns the INPUT integer to $v0
    syscall
    jr $ra # jr -> goto # $ra  the returned address

PRINT:
    li $v0,1 # The integer to be PRINTed is assigned to $a0
    syscall
    li $v0,4 # The address of the string to be PRINTed is assigned to $a0
    la $a0,_ret # LA(Load Address) An instruction is used to store an address or label into a register
    syscall
    move $v0,$0
    jr $ra
main:
Label0:
Label1:
	li $t1,2
Label3:
	li $t2,3
Label4:
	mul $t3,$t1,$t2
Label5:
	move $t0,$a0
	move $a0,$t3
Label6:
	addi $sp,$sp,-4
	sw $ra,0($sp)
	jal PRINT
	lw $ra,0($sp)
	addi $sp,$sp,4
Label7:
	li $t1,333
Label9:
	li $t1,1
Label11:
	li $t2,3
Label12:
	add $t3,$t1,$t2
Label14:
	li $t1,1
Label15:
	add $t2,$t3,$t1
Label16:
	move $t0,$a0
	move $a0,$t2
Label17:
	addi $sp,$sp,-4
	sw $ra,0($sp)
	jal PRINT
	lw $ra,0($sp)
	addi $sp,$sp,4
Label18:
	li $t1,0
Label19:
	move $v0,$t1
	jr $ra
