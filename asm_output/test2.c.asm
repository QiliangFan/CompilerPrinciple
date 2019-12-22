
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
fact:
Label0:
Label2:
	li $t1,1
Label3:
	beq $a0,$t1,Label5
Label4:
	j Label7
Label5:
	move $v0,$a0
	jr $ra
Label6:
	j Label14
Label7:
	li $t1,1
Label8:
	sub $t2,$a0,$t1
Label9:
	move $t0,$a0
	move $a0,$t2
Label10:
	addi $sp,$sp,-24
	sw $t0,0($sp)
	sw $ra,4($sp)
	sw $t1,8($sp)
	sw $t2,12($sp)
	sw $t3,16($sp)
	sw $t4,20($sp)
	jal fact
	lw $a0,0($sp)
	lw $ra,4($sp)
	lw $t1,8($sp)
	lw $t2,12($sp)
	lw $t3,16($sp)
	lw $t4,20($sp)
	addi $sp,$sp,24
	move $t1 $v0
Label11:
	mul $t2,$a0,$t1
Label12:
	move $t1,$t2
Label13:
	move $v0,$t1
	jr $ra
Label14:
	move $v0,$t2
	jr $ra
main:
Label15:
Label16:
	addi $sp,$sp,-4
	sw $ra,0($sp)
	jal INPUT
	lw $ra,0($sp)
	move $t3,$v0
	addi $sp,$sp,4
Label17:
	move $t4,$t3
Label18:
	li $t3,0
Label19:
	move $t5,$t3
Label20:
	blt $t5,$t4,Label22
Label21:
	j Label39
Label22:
	addi $sp,$sp,-4
	sw $ra,0($sp)
	jal INPUT
	lw $ra,0($sp)
	move $t3,$v0
	addi $sp,$sp,4
Label23:
	move $t6,$t3
Label24:
	li $t3,1
Label25:
	bgt $t6,$t3,Label27
Label26:
	j Label31
Label27:
	move $t0,$a0
	move $a0,$t6
Label28:
	addi $sp,$sp,-24
	sw $t0,0($sp)
	sw $ra,4($sp)
	sw $t1,8($sp)
	sw $t2,12($sp)
	sw $t3,16($sp)
	sw $t4,20($sp)
	jal fact
	lw $a0,0($sp)
	lw $ra,4($sp)
	lw $t1,8($sp)
	lw $t2,12($sp)
	lw $t3,16($sp)
	lw $t4,20($sp)
	addi $sp,$sp,24
	move $t3 $v0
Label29:
	move $t7,$t3
Label30:
	j Label33
Label31:
	li $t3,1
Label32:
	move $t7,$t3
Label33:
	move $t0,$a0
	move $a0,$t7
Label34:
	addi $sp,$sp,-4
	sw $ra,0($sp)
	jal PRINT
	lw $ra,0($sp)
	addi $sp,$sp,4
Label36:
	addi $t3,$t5,1
Label37:
	move $t5,$t3
Label38:
	j Label20
Label39:
	li $t3,0
Label40:
	move $v0,$t3
	jr $ra
