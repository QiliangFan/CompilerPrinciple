
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
Label2:
	li $t1,1
Label3:
	move $t2,$t1
Label4:
	li $t1,10
Label5:
	li $t3,2
Label6:
	li $t4,3
Label7:
	li $a0,1
	move $t5,$t3
Labelmi7:
	mul $t3,$t3,$t5
	addi $a0,$a0,1
	blt $a0,$t4,Labelmi7
	move $t3,$t3
Label8:
	div $t1,$t3
	mflo $t1
Label9:
	add $t3,$t2,$t1
Label10:
	move $t1,$t3
Label11:
	li $t3,0
Label12:
	bne $t1,$t3,Label14
Label13:
	j Label36
Label14:
	li $t3,10
Label15:
	blt $t1,$t3,Label17
Label16:
	j Label26
Label17:
	li $t3,10
Label18:
	blt $t2,$t3,Label20
Label19:
	j Label26
Label20:
	mul $t3,$t1,$t2
Label21:
	move $t1,$t3
Label22:
	li $t3,2
Label23:
	add $t4,$t2,$t3
Label24:
	move $t2,$t4
Label25:
	j Label14
Label26:
	li $t3,0
Label27:
	move $t4,$t3
Label28:
	li $t3,1
Label29:
	blt $t4,$t3,Label31
Label30:
	j Label36
Label31:
	move $t4,$t2
Label33:
	addi $t3,$t4,1
Label34:
	move $t4,$t3
Label35:
	j Label28
Label36:
	move $t0,$a0
	move $a0,$t1
Label37:
	addi $sp,$sp,-4
	sw $ra,0($sp)
	jal PRINT
	lw $ra,0($sp)
	addi $sp,$sp,4
