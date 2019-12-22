import os
import re
import sys
regs=['t1','t2','t3','t4','t5','t6','t7','t8','t9','s0','s1','s2','s3','s4','s5','s6','s7']
table={}
reg_ok={}
variables=[]

def translate(line):
    if line[1]=='=':
        if line[3] == '_':
            if line[2][0] == '#':  # ['15:', '=', '#1', '_', 'a'] li加载立即数
                return '%s\n\tli %s,%s'%("Label"+line[0],Get_R(line[4]),line[2].replace('#',''))
            else:  # ['15:', '=', 't1', '_', 'a']
                return '%s\n\tmove %s,%s'%("Label"+line[0],Get_R(line[4]),Get_R(line[2]))
    if line[1] == '+': 
        if line[3][0] == '#':  # ['2:', '+', 'a', '#1', 't2']
            return '%s\n\taddi %s,%s,%s'%("Label"+line[0],Get_R(line[4]),Get_R(line[2]),line[3].replace('#',''))
        elif line[2][0] == '#':  # ['2:', '+', '#1', 'a', 't2'] 
            return '%s\n\taddi %s,%s,%s'%("Label"+line[0],Get_R(line[4]),Get_R(line[3]),line[2].replace('#',''))
        else:  # ['2:', '+', 'b', 'a', 't2']
            return '%s\n\tadd %s,%s,%s'%("Label"+line[0],Get_R(line[4]),Get_R(line[2]),Get_R(line[3]))
    if line[1] == '-': 
        if line[3][0] == '#':  # ['2:', '-', 'a', '#1', 't2'] 
            return '%s\n\taddi %s,%s,-%s'%("Label"+line[0],Get_R(line[4]),Get_R(line[2]),line[3].replace('#',''))
        elif line[2][0] == '#':  # ['2:', '-', '#1', 'a', 't2'] 
            return '%s\n\taddi %s,%s,-%s'%("Label"+line[0],Get_R(line[4]),Get_R(line[3]),line[2].replace('#',''))
        else:  # ['2:', '-', 'b', 'a', 't2']
            return '%s\n\tsub %s,%s,%s'%("Label"+line[0],Get_R(line[4]),Get_R(line[2]),Get_R(line[3]))
    if line[1] == '*':  # ['3:', '*', 't2', 'a', 't3']
        return '%s\n\tmul %s,%s,%s'%("Label"+line[0],Get_R(line[4]),Get_R(line[2]),Get_R(line[3]))
    if line[1]=='/':  # div:两个定点寄存器的内容相除。  ['3:', '/', 't2', 'a', 't3'] 商数存放在 lo, 余数存放在 hi ;不能直接获取 hi 或 lo中的值; 需要mfhi, mflo指令传值给寄存器
        return '%s\n\tdiv %s,%s\n\tmflo %s'%("Label"+line[0],Get_R(line[2]),Get_R(line[3]),Get_R(line[4]))
    if line[1]=='%':  # %:两个定点寄存器的内容求余。  ['3:', '%', 't2', 'a', 't3'] 商数存放在 lo, 余数存放在 hi ;不能直接获取 hi 或 lo中的值; 需要mfhi, mflo指令传值给寄存器
        return '%s\n\tdiv %s,%s\n\tmfhi %s'%("Label"+line[0],Get_R(line[2]),Get_R(line[3]),Get_R(line[4]))
    if line[1]=='<': # slt $1,$2,$3  if($2<$3)  $1=1 else   $1=0  ['3:', '<', 'var0', 't4', 't5']
        return '%s\n\tslt %s,%s,%s'%("Label"+line[0],Get_R(line[4]),Get_R(line[2]),Get_R(line[3]))
    if line[1]=='>':
        return '%s\n\tslt %s,%s,%s'%("Label"+line[0],Get_R(line[4]),Get_R(line[3]),Get_R(line[2]))
    if line[1] == 'CALL':
        if line[4] != '_': # ['1:','CALL','fun','_',t1]
            if line[2] == 'INPUT' or line[2] == 'PRINT':  # ['1:','CALL','INPUT','_',t1]
                # $sp 栈指针，指向栈顶 -4 (指向temp9);  sw $ra,0($sp)-> memory[$sp+0]=$ra 返回地址; jal INPUT/PRINT; 
                # lw $ra,0($sp) -> $ra=memory[$sp+0]; move Get_R(temp9),$v0 INPUT就是读取的整数，PRINT是0 ; addi $sp,$sp,4
                return '%s\n\taddi $sp,$sp,-4\n\tsw $ra,0($sp)\n\tjal %s\n\tlw $ra,0($sp)\n\tmove %s,$v0\n\taddi $sp,$sp,4'%("Label"+line[0],line[2],Get_R(line[4]))
            else:  # ['1:','CALL','fun','_',t1]
                # addi $sp,$sp,-24
	            # sw $t0,0($sp) -> memory[$sp+0]=$t0
	            # sw $ra,4($sp) -> memory[$sp+4]=$ra 返回地址
	            # sw $t1,8($sp) -> memory[$sp+8]=$t1
	            # sw $t2,12($sp) -> memory[$sp+12]=$t2
	            # sw $t3,16($sp) -> memory[$sp+16]=$t3
	            # sw $t4,20($sp) -> memory[$sp+20]=$t4
	            # jal fact -> goto line[-1]
	            # lw $a0,0($sp) -> $a0=memory[$sp+0]
	            # lw $ra,4($sp) -> $ra=memory[$sp+4]
	            # lw $t1,8($sp) -> $t1=memory[$sp+8]
	            # lw $t2,12($sp) -> $t2=memory[$sp+12]
	            # lw $t3,16($sp) -> $t3=memory[$sp+16]
	            # lw $t4,20($sp) -> $t4=memory[$sp+20]
	            # addi $sp,$sp,24
                return '%s\n\taddi $sp,$sp,-24\n\tsw $t0,0($sp)\n\tsw $ra,4($sp)\n\tsw $t1,8($sp)\n\tsw $t2,12($sp)\n\tsw $t3,16($sp)\n\tsw $t4,20($sp)\n\tjal %s\n\tlw $a0,0($sp)\n\tlw $ra,4($sp)\n\tlw $t1,8($sp)\n\tlw $t2,12($sp)\n\tlw $t3,16($sp)\n\tlw $t4,20($sp)\n\taddi $sp,$sp,24\n\tmove %s $v0'%("Label"+line[0],line[2],Get_R(line[4]))
        else:  # ['1:','CALL','fun','_','_']
            if line[2] == 'INPUT' or line[2] == 'PRINT':  # ['1:','CALL','INPUT','_','_']
                return '%s\n\taddi $sp,$sp,-4\n\tsw $ra,0($sp)\n\tjal %s\n\tlw $ra,0($sp)\n\taddi $sp,$sp,4'%("Label"+line[0],line[2])
            else:  # ['1:','CALL','fun','_','_']
                return '%s\n\taddi $sp,$sp,-24\n\tsw $t0,0($sp)\n\tsw $ra,4($sp)\n\tsw $t1,8($sp)\n\tsw $t2,12($sp)\n\tsw $t3,16($sp)\n\tsw $t4,20($sp)\n\tjal %s\n\tlw $a0,0($sp)\n\tlw $ra,4($sp)\n\tlw $t1,8($sp)\n\tlw $t2,12($sp)\n\tlw $t3,16($sp)\n\tlw $t4,20($sp)\n\taddi $sp,$sp,24\n\tmove %s $v0'%("Label"+line[0],line[2],Get_R(line[1]))
    if line[1]=='GOTO':  # ['1:','GOTO','_','_','Label'+2]
        return '%s\n\tj %s'%("Label"+line[0],'Label'+line[4])
    if line[1]=='RETURN':# ['1:','RETURN','t1','_','_'] 用v0存储返回值
        return '%s\n\tmove $v0,%s\n\tjr $ra'%("Label"+line[0],Get_R(line[2]))
    # ['1:','JEQ','t1','t2','Label'+2] -> == ; beq $1,$2,10 -> if($1==$2)  goto PC+4+40
    if line[1] == 'JEQ':
        return '%s\n\tbeq %s,%s,%s'%("Label"+line[0],Get_R(line[2]),Get_R(line[3]),"Label"+line[-1]) 
    # ['1:','JNZ','t1','t2','Label'+2] -> != ; bne $1,$2,10 -> if($1!=$2)  goto PC+4+40
    if line[1] == 'JNE':
        return '%s\n\tbne %s,%s,%s'%("Label"+line[0],Get_R(line[2]),Get_R(line[3]),"Label"+line[-1])
    # ['1:','J>','t1','t2','Label'+2]  ; bgt $1,$2,10 -> if($1>$2)  goto PC+4+40
    if line[1] == 'J>':
        return '%s\n\tbgt %s,%s,%s'%("Label"+line[0],Get_R(line[2]),Get_R(line[3]),"Label"+line[-1])
    # ['1:','J<','t1','t2','Label'+2] ; blt $1,$2,10 -> if($1<$2)  goto PC+4+40
    if line[1] == 'J<':
        return '%s\n\tblt %s,%s,%s'%("Label"+line[0],Get_R(line[2]),Get_R(line[3]),"Label"+line[-1])
    # ['1:','JGE','t1','t2','Label'+2] -> >= ; bge $1,$2,10 -> if($1>=$2)  goto PC+4+40
    if line[1] == 'JGE':
        return '%s\n\tbge %s,%s,%s'%("Label"+line[0],Get_R(line[2]),Get_R(line[3]),"Label"+line[-1])
    # ['1:','JLE','t1','t2','Label'+2] -> <= ; ble $1,$2,10 -> if($1<=$2)  goto PC+4+40
    if line[1] == 'JLE':
        return '%s\n\tble %s,%s,%s'%("Label"+line[0],Get_R(line[2]),Get_R(line[3]),"Label"+line[-1])
    # ['1:','FUNCTION','_','_','main']
    if line[1]=='FUNCTION':
        return '%s:\n%s'%(line[4],"Label"+line[0])
    # ['1:','ARG','var2','_','_'] 
    if line[1]=='ARG':
        return '%s\n\tmove $t0,$a0\n\tmove $a0,%s'%("Label"+line[0],Get_R(line[2]))
    if line[1]=='param': # ['1:','param','_','_','var2'] 
        table[line[4]]='a0'
    if line[1]=='^':  # ['1:','^','a','b','t1'] mul a,b,a  mul a,b,a  mul a,b,a mul a,b,t1
        return '%s\n\tli $a0,1\n\tmove %s,%s\n%s\n\tmul %s,%s,%s\n\taddi $a0,$a0,1\n\tblt $a0,%s,%s\n\tmove %s,%s'%("Label"+line[0],Get_R(line[0]),Get_R(line[2]),'Labelmi'+line[0],Get_R(line[2]),Get_R(line[2]),Get_R(line[0]),Get_R(line[3]),'Labelmi'+line[0][0:-1],Get_R(line[2]),Get_R(line[4]))
    return ''

def write_to_txt(Obj):
    f = sys.stdout
    template='''
.data
_prompt: .asciiz "Enter an integer:"
_ret: .asciiz "\\n"
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
'''
    f.write(template)
    for line in Obj:
        f.write(line+'\n')
    f.close()
def Load_Var(Inter):
    global variables
    temp_re = '(temphh\d+)'
    for line in Inter:
        temps=re.findall(temp_re,' '.join(line))
        variables+=temps

def Load_Inter(filename):
    lines=[]
    for line in open(filename,'r',encoding='utf-8'):
        line=line.replace('\r','').replace('\n','')
        if line =='':
            continue
        lines.append(line.split('\t'))
    return lines

def Get_R(string):
    try:
        variables.remove(string)
    except:
        pass
    if string in table:
        return '$'+table[string]  #如果已经存在寄存器分配，那么直接返回寄存器
    else:
        keys=[]
        for key in table:         #已经分配寄存器的变量key
            keys.append(key)
        for key in keys:          #当遇到未分配寄存器的变量时，清空之前所有分配的临时变量的映射关系！！！
            if 'temphh' in  key and key not in variables: #
                reg_ok[table[key]]=1
                del table[key]
        for reg in regs:          #对于所有寄存器
            if reg_ok[reg]==1:    #如果寄存器可用
                table[string]=reg #将可用寄存器分配给该变量，映射关系存到table中
                reg_ok[reg]=0     #寄存器reg设置为已用
                return '$'+reg
def parser():
    for reg in regs:
        reg_ok[reg]=1  #初始化，所有寄存器都可用
    Inter=Load_Inter(sys.argv[1])  #读取中间代码
    Load_Var(Inter)    #第一遍扫描，记录所有变量
    Obj=[]
    for line in Inter:
        obj_line=translate(line) #翻译中间代码成MIPS汇编
        if obj_line=='':
            continue
        Obj.append(obj_line)
    write_to_txt(Obj)

if __name__ == "__main__":
    parser()
