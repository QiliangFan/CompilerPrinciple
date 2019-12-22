#include "../include/symboltable.h"
#include "../include/utils.h"
#include <iostream>

// global data
int linno = 1;
int colno = 0;
int num_of_temporary = 0;

string SymbolTable::add_temp_var(string op, string arg1, string arg2) {
  if (arg2.size() == 0)
    arg2 = "0";
  if (arg1.size() == 0)
    arg1 = "0";
  num_of_temporary++;
  char buf[32];
  snprintf(buf, 32, "temphh%d", num_of_temporary);
  string tem_var_name(buf);
  if (is_variable(arg1) && is_variable(arg2)) { // var op var
    return tem_var_name;
  } else if (is_variable(arg1) && is_constant(arg2)) { // var op const
    return tem_var_name;
  } else if (is_constant(arg1) && is_variable(arg2)) { // const op var
    return tem_var_name;
  } else if (is_constant(arg1) && is_constant(arg2)) { // const op const
    return tem_var_name;
  }
}

VarEntity *SymbolTable::operator[](string var_name) {
  for (int i = 0; i < table.size(); i++) {
    if (table[i].name == var_name) {
      return &(table[i]);
    }
  }

  if (this->last) {
    return (*last)[var_name];
  } else {
    return nullptr;
  }
}

// return 0:if everything go correctly
// return 1: if var has been defined
int SymbolTable::add_var(string name, string type, string value) {
  // if variable in this scope already exist:
  for (auto i : table) {
    if (i.name == name) { // 变量已经定义过
      string s = "the variable ";
      s += name;
      s += " has been defined already.";
      print_red2(s);
      (*this)[name]->value = value;
      (*this)[name]->type = type;
      return 1;
    }
  }
  table.push_back(VarEntity(name, type, value));
  return 0;
}

void TableManager::add_table() {
  SymbolTable *new_table = new SymbolTable();
  if (global_tables.size())
    new_table->last = (global_tables.top());
  tables.push(new_table);
}

void TableManager::add_sub_table() {
  SymbolTable *new_table = new SymbolTable();
  if (tables.size())
    new_table->last = (tables.top());
  tables.push(new_table);
}

void TableManager::add_global_table() {
  SymbolTable *new_table = new SymbolTable();
  if (global_tables.size())
    new_table->last = (global_tables.top());
  global_tables.push(new_table);
}

void TableManager::add_function(string name) {
  FunctionDef *new_function = new FunctionDef();
  new_function->name = name;
  if (global_tables.size())
    new_function->canIuse = global_tables.top();
  functions.push_back(new_function);
}

void TableManager::add_array(string name, int max) {
  for (int i = 0; i < table_manager.array_tables.top()->size(); i++) {
    if (name == (*table_manager.array_tables.top())[i]) {
      print_red2(string() + "The variable " + name + "has been defined ....");
    }
  }
  table_manager.array_tables.top()->push_back(name);
}

void TableManager::add_array_index(string name, string index, string temp_var) {
  int sign = 0;
  for (int i = 0; i < table_manager.array_tables.top()->size(); i++) {
    if (name == (*table_manager.array_tables.top())[i]) {
      sign = 1;
    }
  }
  if (sign == 0) {
    print_red2(string() + "The variable " + name + "has not been defined...");
    return;
  }
  for (int i = 0; i < table_manager.array_index_tables.top()->size(); i++) {
    if (name == (*table_manager.array_index_tables.top())[i].array_name &&
        index == (*table_manager.array_index_tables.top())[i].index) {
      (*table_manager.array_index_tables.top())[i].temp_var = temp_var;
      return;
    }
  }
  table_manager.array_index_tables.top()->push_back(
      Array_index(name, index, temp_var));
}

string TableManager::get_array_index(
    string name,
    string index) { //返回"0" 表示数组名不存在， 返回“-1”表示无此索引
  int sign = 0;
  for (int i = 0; i < table_manager.array_tables.top()->size(); i++) {
    if (name == (*table_manager.array_tables.top())[i]) {
      sign = 1;
    }
  }
  if (sign == 0) {
      cerr<<name<<index<<endl;
    print_red2(string() + "The variable " + name + "has not been defined...");
    return "0";
  }
  for (int i = 0; i < table_manager.array_index_tables.top()->size(); i++) {
    if (name == (*table_manager.array_index_tables.top())[i].array_name &&
        index == (*table_manager.array_index_tables.top())[i].index) {
      return (*table_manager.array_index_tables.top())[i].temp_var;
    }
  }
  return "-1";
}

void TableManager::set_array_index_value(string temp_var, string new_temp_var) {
  for (int i = 0; i < table_manager.array_index_tables.top()->size(); i++) {
    if (temp_var == (*table_manager.array_index_tables.top())[i].temp_var) {
      (*table_manager.array_index_tables.top())[i].temp_var = new_temp_var;
    }
  }
}

bool TableManager::has_array(string name) {
  for (int i = 0; i < table_manager.array_tables.top()->size(); i++) {
    if (name == (*table_manager.array_tables.top())[i]) {
      return true;
    }
  }
  return false;
}

TableManager table_manager;
