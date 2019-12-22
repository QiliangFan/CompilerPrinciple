#ifndef SYMBOTABLE_H
#define SYMBOTABLE_H
#include<iostream>
#include<string>
#include<deque>
#include<stack>
#include<vector>
#include<utility>
using std::stack;
using std::pair;
using std::deque;
using std::string;
using std::cout;
using std::vector;


#include"utils.h"

class VarEntity{
public:
    string name;
    string value;
    string type;
    VarEntity(){}
    VarEntity(string _name, string _type, string _value="0"){
        name = _name;
        type = _type;
        value = _value;
    }
};


class SymbolTable{
public:

    SymbolTable* last;  // go back to trace the caller's symboltable

    deque<VarEntity> table;   // double ended queue as symboltable

    string add_temp_var(string op, string arg1="", string arg2="");  // gernerate the temporary variable
                                                                                                                        // return the var_name of temporary var

    VarEntity*operator[](string var_name);                                           // overload the [] operator, get and modify value by subindex, return the  corresponding variable

    int add_var(string name, string type, string value="0");    // add a variable, defalut value is NULL

    SymbolTable(){last=nullptr;}
};

class FunctionDef{
public:
    string name;
    int param_num;
    SymbolTable* canIuse;
    FunctionDef(){canIuse=nullptr;}
    FunctionDef(string name, int num){
        this->name = name;
        this->param_num = num;
    }
};

class Array_index{
public:
    string array_name;
    string index;
    string temp_var;
    Array_index(string array_name, string index, string temp_var){
        this->array_name=array_name;
        this->index = index;
        this->temp_var = temp_var;
    }
};


class TableManager{
public:
    stack<SymbolTable*> tables;
    stack<SymbolTable*> global_tables;

    stack<vector<Array_index> *> array_index_tables;  // reserved for simulate array
    stack<vector<string> *> array_tables;

// function definitions
    vector<FunctionDef*> functions;

    void add_table();
    void add_sub_table();
    void add_global_table();
    void add_function(string name);
    void add_array(string name, int max);
    void add_array_index(string name, string index, string temp_var);
    string get_array_index(string name, string index);
    void set_array_index_value(string temp_var, string new_temp_var);
    bool has_array(string name);
};

extern TableManager table_manager;
#endif
