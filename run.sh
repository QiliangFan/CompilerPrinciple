#!/bin/sh
for file in `ls input`
do
    echo "$file asm result======>"
    java -jar asm_output/Mars4_5.jar asm_output/$file.asm
done