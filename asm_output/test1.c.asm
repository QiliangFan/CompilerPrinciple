
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
func:
Label0:
Label1:
	li $t1,1
Label2:
	move $t2,$t1
Label4:
	move $t1,$t3
Label5:
	li $t4,2
Label6:
	div $t5,$t4
	mflo $t4
Label7:
	move $t0,$a0
	move $a0,$t4
Label8:
	addi $sp,$sp,-4
	sw $ra,0($sp)
	jal PRINT
	lw $ra,0($sp)
	addi $sp,$sp,4
Label9:
	li $t4,0
Label10:
	move $t6,$t4
Label11:
	li $t4,4
Label12:
	blt $t6,$t4,Label14
Label13:
	j Label22
Label14:
	move $t0,$a0
	move $a0,$t4
Label15:
	addi $sp,$sp,-4
	sw $ra,0($sp)
	jal PRINT
	lw $ra,0($sp)
	addi $sp,$sp,4
Label16:
	add $t7,$t4,$t4
Label19:
	addi $t4,$t6,1
Label20:
	move $t6,$t4
Label21:
	j Label11
Label22:
	li $t4,99
Label24:
	move $t0,$a0
	move $a0,$t4
Label25:
	addi $sp,$sp,-4
	sw $ra,0($sp)
	jal PRINT
	lw $ra,0($sp)
	addi $sp,$sp,4
Label27:
	j Label32
Label28:
	move $t4,$t2
Label29:
	addi $t4,$t2,-1
Label30:
	move $t2,$t4
Label31:
	j Label26
Label32:
	move $v0,$t4
	jr $ra
main:
Label33:
Label35:
	li $t7,2
Label36:
	move $t8,$t7
Label37:
	li $t7,65
Label38:
	move $t9,$t7
Label39:
	li $t7,1
Label40:
	move $s0,$t7
Label41:
	add $t7,$t8,$s0
Label42:
	move $t8,$t7
Label43:
	div $t8,$s0
	mflo $t7
Label44:
	move $t9,$t7
Label45:
	mul $t7,$t8,$s0
Label46:
	move $s0,$t7
Label47:
	sub $t7,$t8,$s0
Label48:
	move $s0,$t7
Label49:
	li $t7,2
Label50:
	div $t8,$t7
	mfhi $t7
Label51:
	move $t8,$t7
Label52:
	li $t7,2
Label53:
	li $a0,1
	move $s1,$t9
Labelmi53:
	mul $t9,$t9,$s1
	addi $a0,$a0,1
	blt $a0,$t7,Labelmi53
	move $t9,$t7
Label54:
	move $t8,$t7
Label55:
	li $t7,1
Label56:
	move $s2,$t7
Label58:
	j Label59
Label59:
	li $t7,2
Label60:
	move $t2,$t7
Label61:
	li $t7,100
Label62:
	ble $s2,$t7,Label64
Label63:
	j Label67
Label64:
	li $t7,1
Label65:
	bgt $t8,$t7,Label69
Label66:
	j Label67
Label68:
	j Label69
Label69:
	move $t0,$a0
	move $a0,$s2
Label70:
	addi $sp,$sp,-4
	sw $ra,0($sp)
	jal PRINT
	lw $ra,0($sp)
	addi $sp,$sp,4
Label71:
	j Label75
Label72:
	move $t7,$s2
Label73:
	addi $t7,$s2,-1
Label74:
	move $s2,$t7
Label75:
	li $t7,1
Label76:
	move $t2,$t7
Label77:
	li $t7,2
Label78:
	blt $t2,$t7,Label80
Label79:
	j Label86
Label80:
	move $t0,$a0
	move $a0,$t7
Label81:
	addi $sp,$sp,-4
	sw $ra,0($sp)
	jal PRINT
	lw $ra,0($sp)
	addi $sp,$sp,4
Label83:
	addi $s3,$t2,1
Label84:
	move $t2,$s3
Label85:
	j Label77
Label86:
	li $s3,1
Label87:
	move $t2,$s3
Label88:
	addi $sp,$sp,-24
	sw $t0,0($sp)
	sw $ra,4($sp)
	sw $t1,8($sp)
	sw $t2,12($sp)
	sw $t3,16($sp)
	sw $t4,20($sp)
	jal func
	lw $a0,0($sp)
	lw $ra,4($sp)
	lw $t1,8($sp)
	lw $t2,12($sp)
	lw $t3,16($sp)
	lw $t4,20($sp)
	addi $sp,$sp,24
	move $s3 $v0
