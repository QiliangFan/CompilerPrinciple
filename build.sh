#!/bin/bash
rm -rf dist
rm -rf output
if [ !  -d 'dist' ]; then
    mkdir dist
fi
if [ ! -d 'output' ]; then
    mkdir output
fi
if [ ! -d 'asm_output' ]; then
    mkdir asm_output
fi

cd dist

yacc -dv ../parse.y
lex ../read.l
clang++ -o  run -g lex.yy.c y.tab.c  ../src/symboltable.cpp   ../src/grammar_tree.cpp ../src/utils.cpp -lfl

cd ..

for file in `ls input`
do
    echo "$file========>" >&2 :
    ./dist/run <input/$file >>output/$file.txt # 2>output/$file.output
    python3 ./asm/object.py output/$file.txt > asm_output/$file.asm
done
