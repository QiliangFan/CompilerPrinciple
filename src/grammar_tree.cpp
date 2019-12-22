#include "../include/grammar_tree.h"
#include "../include/symboltable.h"
#define PUSH_CODE(num, intercode)                                              \
  node->code.push_back(pair<int, InterCode>(num, intercode));

#define DEFAULT_ACTION                                                         \
  for (auto child : node->children) {                                          \
    analysis(child, -1);                                                       \
  }
void GrammarTree::print(TreeNode *node, int indent) {
  for (int i = 0; i < indent; i++) {
    cout << "  ";
  }
  if (node->type.size()) {
    cout << node->type << "    " << node->name << "" << node->value << endl;
  }

  for (auto i : node->children) {
    print(i, indent + 1);
  }
}

TreeNode::TreeNode(string type, string value) {
  this->type = type;
  if (type == "ID") {
    this->name = value;
  } else {
    this->value = value;
  }
}

void GrammarTree::trim(TreeNode *node) {
  for (int i = 0; i < node->children.size(); i++) {
    if (node->children[i]->type == "s_list" ||
        node->children[i]->type == "Did_list" ||
        node->children[i]->type == "dec_param_list" ||
        node->children[i]->type == "param_list") {
      TreeNode *temp = node->children[i];
      if (temp->children.size() > 1) {
        queue<TreeNode *> result;
        while (temp->children.size() > 1) {
          result.push(temp->children[0]);
          temp = temp->children[1];
        }
        result.push(temp->children[0]);
        node->children[i]->children.clear();
        while (result.size()) {
          node->children[i]->children.push_back(result.front());
          result.pop();
        }
      }
      trim(node->children[i]);
    } else {
      trim(node->children[i]);
    }
  }
}

void GrammarTree::back_patch(TreeNode *node, string dst, string true_dst) {

  for (int i = 0; i < node->code.size(); i++) {
    if (node->code[i].second.result == dst) {
      node->code[i].second.result = true_dst;
    }
  }
  for (auto i : node->children) {
    back_patch(i, dst, true_dst);
  }
}
void GrammarTree::analysis(
    TreeNode *node, int layer) { // -1: expression 0: global   1: function 2: if
  if (node->type == "all") {
    for (auto child : node->children) {
      analysis(child, 0);
    }
  } else if (layer == 0) {
    // 如果语句是 p:
    if (node->type == "p") {
      if (table_manager.tables.size()) {
        table_manager.tables.pop();
        table_manager.array_tables.pop();
        table_manager.array_index_tables.pop();
        PUSH_CODE(global_num++, InterCode("RETURN", "_", "0", "_"));
      }
      table_manager.array_tables.push(new vector<string>());
      table_manager.array_index_tables.push(new vector<Array_index>);
      table_manager.add_table();

      PUSH_CODE(global_num++, InterCode("FUNCTION", node->children[1]->name))
      if (node->children.size() == 3) { // 无参函数
        table_manager.functions.push_back(
            new FunctionDef(node->children[1]->name, 0));
        analysis(node->children[2], 1);

      } else { //带参数的函数
        table_manager.functions.push_back(new FunctionDef(
            node->children[1]->name, node->children[2]->children.size()));

        for (auto child : node->children[2]->children) {
          table_manager.tables.top()->add_var(child->children[1]->name,
                                              ""); // 不检查参数类型
          PUSH_CODE(global_num++, InterCode("param", child->children[1]->name))
        }
        analysis(node->children[3], 1);
      }
    }

  } else if (node->type == "e") {
    if (node->children.size() >= 3 && node->children[0]->type == "ID" &&
        node->children[1]->type == "(") { // 函数调用===============
      if (layer == -1) {                  //普通表达式中
        int sign = 0;
        for (int i = 0; i < table_manager.functions.size(); i++) {
          if (table_manager.functions[i]->name == node->children[0]->name) {
            sign = 1;
          }
        }
        if (sign == 0) {
          print_red2(string(node->children[0]->name) +
                     ":function has not defined!");
        }
        if (node->children.size() == 3) { // 无参函数
          for (auto item : table_manager.functions) {
            if (item->name == node->children[0]->name) {
              if (item->param_num > 0) {
                print_red2("参数个数不匹配!");
                exit(-1);
              }
            }
          }
          string temp_var = table_manager.tables.top()->add_temp_var(
              "CALL", node->children[0]->name);
          PUSH_CODE(global_num++,
                    InterCode("CALL", temp_var, node->children[0]->name, ""))
          node->value = temp_var;
          return;
        } else { // 有参函数
          vector<TreeNode *> param_list;
          for (int i = 0; i < node->children[2]->children.size(); i++) {
            analysis(node->children[2]->children[i], -1);
            param_list.push_back(node->children[2]->children[i]);
          }
          for (auto item : table_manager.functions) {
            if (item->name == node->children[0]->name) {
              if (item->param_num != param_list.size()) {
                cerr << item->param_num << endl;
                print_red2("参数个数不匹配!");
                exit(-1);
              }
            }
          }
          for (auto param : param_list) {
            PUSH_CODE(global_num++, InterCode("ARG", "_", param->value))
          }
          string temp_var = table_manager.tables.top()->add_temp_var(
              "CALL", node->children[0]->name);
          PUSH_CODE(global_num++,
                    InterCode("CALL", temp_var, node->children[0]->name))
          node->value = temp_var;
          return;
        }
        return;
      } else if (layer == 2) {
        if (node->children.size() == 3) { // 无参函数
          string temp_funvalue = table_manager.tables.top()->add_temp_var(
              "CALL", node->children[0]->name);
          PUSH_CODE(global_num++, InterCode("CALL", temp_funvalue,
                                            node->children[0]->name, ""))
          node->value = temp_funvalue;
          PUSH_CODE(global_num++, InterCode("Jnz", "e.true", node->value))
          PUSH_CODE(global_num++, InterCode("GOTO", "e.false"))
        } else { //有参函数
          vector<TreeNode *> param_list;
          for (auto child : node->children[2]->children) {
            analysis(child, -1);
            param_list.push_back(child);
          }
          for (auto param : param_list) {
            PUSH_CODE(global_num++, InterCode("ARG", "_", param->value))
          }
          string temp_var = table_manager.tables.top()->add_temp_var(
              "CALL", node->children[0]->name);
          PUSH_CODE(global_num++,
                    InterCode("CALL", temp_var, node->children[0]->name))

          node->value = temp_var;
          PUSH_CODE(global_num++, InterCode("Jnz", "e.true", node->value))
          PUSH_CODE(global_num++, InterCode("GOTO", "e.false"))
        }
      } else {
        DEFAULT_ACTION
      }
    } else if (node->children.size() == 1) { // e->ID  e->NUM e->str
      if (layer == -1) {
        if (node->children[0]->type == "ID") {
          if (!table_manager.has_array(node->children[0]->name)) {
            if ((*table_manager.tables.top())[node->children[0]->name] ==
                nullptr) {
              print_red2(string() + "the variable " + node->children[0]->name +
                         " has not been defined!");
            }
          }
          node->value = node->children[0]->name;
        }
        if (node->children[0]->type == "NUM") {
          string temp_var =
              table_manager.tables.top()->add_temp_var("_", "", "");
          PUSH_CODE(global_num++,
                    InterCode("=", temp_var,
                              string() + "#" + node->children[0]->value))
          node->value = temp_var;
        }
        if (node->children[0]->type == " STR") {
          node->value = node->children[0]->value;
        }
      } else if (layer == 2) {
        if (node->children[0]->type == "ID") {
          node->value = node->children[0]->name; //优化. 缩减表达式!
        }
        if (node->children[0]->type == "NUM") {
          node->value = string() + "#" + node->children[0]->value;
        }
        if (node->children[0]->type == " STR") {
          node->value = node->children[0]->value;
        }
        PUSH_CODE(global_num++, InterCode("Jnz", "e.true", node->value))
        PUSH_CODE(global_num++, InterCode("GOTO", "e.false"))
      }

    } else if (node->children.size() == 2) {
      if (layer == -1) {                          //在纯表达式中
        if (node->children[0]->type == "e") {     // e op =>  op e - temp
          if (node->children[1]->type == "INC") { // 消除自增自减
            analysis(node->children[0], -1);
            node->value = node->children[0]->value;
            string temp_var = table_manager.tables.top()->add_temp_var(
                "=", node->children[0]->value);
            PUSH_CODE(global_num++,
                      InterCode("=", temp_var, node->children[0]->value))
            string temp_inc = table_manager.tables.top()->add_temp_var(
                "-", node->children[0]->value, "1");
            PUSH_CODE(global_num++,
                      InterCode("+", temp_inc, node->children[0]->value, "#1"))
            PUSH_CODE(global_num++,
                      InterCode("=", node->children[0]->value, temp_inc))
          } else if (node->children[1]->type == "DEC") {
            analysis(node->children[0], -1);
            node->value = node->children[0]->value;
            string temp_var = table_manager.tables.top()->add_temp_var(
                "=", node->children[0]->value);
            PUSH_CODE(global_num++,
                      InterCode("=", temp_var, node->children[0]->value))
            string temp_dec = table_manager.tables.top()->add_temp_var(
                "-", node->children[1]->value, "1");
            PUSH_CODE(global_num++,
                      InterCode("-", temp_dec, node->children[0]->value, "#1"))
            PUSH_CODE(global_num++,
                      InterCode("=", node->children[0]->value, temp_dec))
          } else {
            analysis(node->children[0], -1);
            node->value = table_manager.tables.top()->add_temp_var(
                node->children[1]->type, node->children[0]->value, "");
            PUSH_CODE(global_num++,
                      InterCode(node->children[1]->type, node->value,
                                node->children[0]->value, ""))
          }

        } else if (node->children[1]->type == "e") { // op e => op - e temp
          if (node->children[0]->type == "INC") {    // 消除自增自减
            analysis(node->children[1], -1);
            string temp_inc = table_manager.tables.top()->add_temp_var(
                "+", node->children[1]->value, "1");
            PUSH_CODE(global_num++,
                      InterCode("-", temp_inc, node->children[1]->value, "#1"))
            PUSH_CODE(global_num++, InterCode("+", node->children[1]->value,
                                              node->children[1]->value, "#1"))
            node->value = node->children[1]->value;
            string temp_var = table_manager.tables.top()->add_temp_var(
                "=", node->children[1]->value);
            PUSH_CODE(global_num++, InterCode("=", temp_var))
          } else if (node->children[0]->type == "DEC") { // DEC
            analysis(node->children[1], -1);
            string temp_dec = table_manager.tables.top()->add_temp_var(
                "-", node->children[1]->value, "1");
            PUSH_CODE(global_num++,
                      InterCode("-", temp_dec, node->children[1]->value, "#1"))
            PUSH_CODE(global_num++,
                      InterCode("=", node->children[1]->value, temp_dec))
            node->value = node->children[1]->value;
            string temp_var = table_manager.tables.top()->add_temp_var(
                "=", node->children[1]->value);
            PUSH_CODE(global_num++, InterCode("=", temp_var))
          } else if (node->children[0]->type == "*") {
            string temp = table_manager.get_array_index(
                node->children[1]->children[0]->name, "0");
            node->value = temp;
          } else {
            analysis(node->children[1], -1);
            node->value = table_manager.tables.top()->add_temp_var(
                node->children[0]->type, "", node->children[1]->value);
            PUSH_CODE(global_num++,
                      InterCode(node->children[0]->type, node->value, "",
                                node->children[1]->value))
          }
        }
      } else if (layer == 2) {                  //在其他中
        if (node->children[0]->type == "INC") { // INC e
          analysis(node->children[1], -1);
          PUSH_CODE(global_num++,
                    InterCode("J>", "s.true", node->children[1]->value, "0"));
          PUSH_CODE(global_num++, InterCode("GOTO", "s.false"))
          string temp_var = table_manager.tables.top()->add_temp_var(
              "+", node->children[1]->value, "#1");
          PUSH_CODE(global_num++,
                    InterCode("+", temp_var, node->children[1]->value, "#1"))
          PUSH_CODE(global_num++,
                    InterCode("=", node->children[1]->value, temp_var));
          node->value = temp_var;
        } else if (node->children[1]->type == "INC") { // e INC
          analysis(node->children[0], -1);
          string temp_var = table_manager.tables.top()->add_temp_var(
              "+", node->children[0]->value, "#1");
          PUSH_CODE(global_num++,
                    InterCode("+", temp_var, node->children[0]->value, "#1"))
          PUSH_CODE(global_num++,
                    InterCode("=", node->children[0]->value, temp_var))

          stringstream ss;
          string temp;
          ss << global_num + 2;
          ss >> temp;
          PUSH_CODE(global_num++,
                    InterCode("J>", temp, node->children[0]->value, "#-1"))
          PUSH_CODE(global_num++, InterCode("GOTO", "s.next"))
          node->value = node->children[0]->value;
        } else if (node->children[0]->type == "DEC") {
          analysis(node->children[1], -1);
          PUSH_CODE(global_num++,
                    InterCode("J>", "e.true", node->children[1]->value, "0"));
          PUSH_CODE(global_num++, InterCode("GOTO", "e.false"))
          string temp_var = table_manager.tables.top()->add_temp_var(
              "-", node->children[1]->value, "#1");
          PUSH_CODE(global_num++,
                    InterCode("-", temp_var, node->children[1]->value, "#1"))
          PUSH_CODE(global_num++,
                    InterCode("=", node->children[1]->value, temp_var));
          node->value = temp_var;
        } else if (node->children[1]->type == "DEC") {
          analysis(node->children[0], -1);
          string temp_var = table_manager.tables.top()->add_temp_var(
              "-", node->children[0]->value, "#1");
          PUSH_CODE(global_num++,
                    InterCode("-", temp_var, node->children[0]->value, "#1"))
          PUSH_CODE(global_num++,
                    InterCode("=", node->children[0]->value, temp_var))

          PUSH_CODE(global_num++,
                    InterCode("J>", "e.true", node->children[0]->value, "#1"))
          PUSH_CODE(global_num++, InterCode("GOTO", "e.false"))
          node->value = node->children[0]->value;
        } else if (node->children[0]->type == "!") { // ! e
          analysis(node->children[1], 2);
          back_patch(node->children[1], "e.true", "temp");
          back_patch(node->children[1], "e.false", "e.true");
          back_patch(node->children[1], "temp", "e.false");
        }
      }
    } else if (node->children.size() == 3) {
      if (layer == -1) {                      //纯表达式
        if (node->children[1]->type == "=") { // e = e
          analysis(node->children[0], -1);
          analysis(node->children[2], -1);
          PUSH_CODE(global_num++, InterCode("=", node->children[0]->value,
                                            node->children[2]->value))
          back_patch(node->children[2], "return_position",
                     node->children[0]->value);
          table_manager.set_array_index_value(node->children[0]->value,
                                              node->children[2]->value);

        } else if (node->children[1]->type == "+" ||
                   node->children[1]->type == "-" ||
                   node->children[1]->type == "*" ||
                   node->children[1]->type == "/" ||
                   node->children[1]->type == "%" ||
                   node->children[1]->type == "^" ||
                   node->children[1]->type == "<" ||
                   node->children[1]->type == "LE" ||
                   node->children[1]->type == ">" ||
                   node->children[1]->type == "GE" ||
                   node->children[1]->type == "EQ" ||
                   node->children[1]->type == "NE" ||
                   node->children[1]->type == "AND" ||
                   node->children[1]->type == "OR") {
          analysis(node->children[0], -1);
          analysis(node->children[2], -1);
          node->value = table_manager.tables.top()->add_temp_var(
              node->children[1]->type, node->children[0]->value,
              node->children[2]->value);
          PUSH_CODE(global_num++,
                    InterCode(node->children[1]->type, node->value,
                              node->children[0]->value,
                              node->children[2]->value))
        } else if (node->children[0]->type == "INPUT") { // input()
          string temp_var =
              table_manager.tables.top()->add_temp_var("CALL", "INPUT");
          PUSH_CODE(global_num++, InterCode("CALL", temp_var, "INPUT", ""));
          node->value = temp_var;
        } else if (node->children.size() >= 3 &&
                   node->children[0]->type == "(" &&
                   node->children[2]->type == ")") {
          DEFAULT_ACTION
          node->value = node->children[1]->value;
        } else if (node->children.size() == 4 &&
                   node->children[0]->type == "[" &&
                   node->children[2]->type == "]") {
          analysis(node->children[1], -1);
          string temp_var = table_manager.get_array_index(
              node->children[0]->name, node->children[2]->value);
          if (temp_var == "0") {
            exit(0);
          } else if (temp_var == "-1") {
            temp_var = table_manager.tables.top()->add_temp_var("=", "1");
            PUSH_CODE(global_num++, InterCode("=", temp_var, "#0"))
            table_manager.add_array_index(node->children[0]->name,
                                          node->children[2]->value, temp_var);
          }
          node->value = temp_var;
        } else {
          DEFAULT_ACTION
        }
      } else if (layer == 2) {
        if (node->children[1]->type == "=") { // if t1 = t2
          analysis(node->children[0], -1);
          analysis(node->children[2], -1);
          PUSH_CODE(global_num++, InterCode("=", node->children[0]->value,
                                            node->children[2]->value))
          back_patch(node->children[2], "return_position",
                     node->children[0]->value);
          PUSH_CODE(global_num++,
                    InterCode("J>", "e.true", node->children[0]->value, 0))
          PUSH_CODE(global_num++, InterCode("GOTO", "e.false"))
          table_manager.set_array_index_value(node->children[0]->value,
                                              node->children[2]->value);
        } else if (node->children[1]->type == "+" ||
                   node->children[1]->type == "-" ||
                   node->children[1]->type == "*" ||
                   node->children[1]->type == "/" ||
                   node->children[1]->type == "%" ||
                   node->children[1]->type == "^") {
          analysis(node->children[0], -1);
          analysis(node->children[2], -1);
          stringstream ss;
          string temp;
          ss << global_num + 2;
          ss >> temp;
          string temp_var = table_manager.tables.top()->add_temp_var(
              node->children[1]->type, node->children[0]->value,
              node->children[2]->value);
          PUSH_CODE(global_num++, InterCode(node->children[1]->type, temp_var,
                                            node->children[0]->value,
                                            node->children[2]->value))
          PUSH_CODE(global_num++, InterCode("J>", "e.true", temp_var, "#0"))
          PUSH_CODE(global_num++, InterCode("GOTO", "e.false"))
        } else if (node->children[1]->type == "<" ||
                   node->children[1]->type == "LE" ||
                   node->children[1]->type == ">" ||
                   node->children[1]->type == "GE" ||
                   node->children[1]->type == "EQ" ||
                   node->children[1]->type == "NE") {
          analysis(node->children[0], -1);
          analysis(node->children[2], -1);
          PUSH_CODE(global_num++,
                    InterCode(string() + "J" + node->children[1]->type,
                              "e.true", node->children[0]->value,
                              node->children[2]->value))
          PUSH_CODE(global_num++, InterCode("GOTO", "e.false"))
        } else if (node->children[1]->type == "AND") { // e AND e
          analysis(node->children[0], 2);
          stringstream ss;
          string temp;
          ss << global_num;
          ss >> temp;
          back_patch(node->children[0], "e.true", temp);
          analysis(node->children[2], 2);
        } else if (node->children[1]->type == "OR") { // e OR e
          analysis(node->children[0], 2);
          stringstream ss;
          string temp;
          ss << global_num;
          ss >> temp;
          back_patch(node->children[0], "e.false", temp);
          analysis(node->children[2], 2);
        } else if (node->children[0]->type == "INPUT") {
          PUSH_CODE(global_num++,
                    InterCode("CALL", "return_position", "INPUT", ""))
          string temp_var =
              table_manager.tables.top()->add_temp_var("CALL", "INPUT");
          node->value = temp_var;
          PUSH_CODE(global_num++, InterCode("Jnz", "e.true", node->value, ""))
          PUSH_CODE(global_num++, InterCode("GOTO", "e.false"))
        } else if (node->children.size() >= 3 &&
                   node->children[0]->type == "(" &&
                   node->children[2]->type == ")") {
          DEFAULT_ACTION
          node->value = node->children[1]->value;
        } else {
          DEFAULT_ACTION
        }
      } else { //其他的情况:
        DEFAULT_ACTION
      }
    } else if (node->children.size() == 4) {
      string temp = table_manager.get_array_index(node->children[0]->name,
                                                  node->children[2]->value);
      if (temp == "0") {
        exit(0);
      } else if (temp == "-1") {
        temp = table_manager.tables.top()->add_temp_var("=", "", "");
        table_manager.add_array_index(node->children[0]->name,
                                      node->children[2]->value, temp);
      }
      node->value = temp;
    }
  } else if (node->type == "s") {
    if (node->children[0]->type == "IF") {
      if (node->children.size() == 3) { // if e s_list
        analysis(node->children[1], 2); // GOTO generation
        stringstream ss;
        string temp;
        ss << global_num;
        ss >> temp;
        back_patch(node->children[1], "e.true", temp);
        analysis(node->children[2], -1);
        ss.clear();
        ss << global_num;
        ss >> temp;
        back_patch(node->children[1], "e.false", temp);
      } else if (node->children.size() == 5) { // if e s_list else s_list
        analysis(node->children[1], 2);        // GOTO generation
        stringstream ss;
        string temp;
        ss << global_num;
        ss >> temp;
        back_patch(node->children[1], "e.true", temp);
        analysis(node->children[2], -1);
        PUSH_CODE(global_num++, InterCode("GOTO", "s.next"))
        ss.clear();
        ss << global_num;
        ss >> temp;
        back_patch(node->children[1], "e.false", temp);
        analysis(node->children[4], -1);
        ss.clear();
        ss << global_num;
        ss >> temp;
        back_patch(node, "s.next", temp);
      }

    } else if (node->children[0]->type == "WHILE") {
      int while_begin = global_num;
      analysis(node->children[1], 2); // GOTOs generation
      stringstream ss;
      string temp;
      ss << global_num;
      ss >> temp;
      ss.clear();
      back_patch(node->children[1], "e.true", temp);
      analysis(node->children[2], -1);
      ss.clear();
      ss << while_begin;
      ss >> temp;
      PUSH_CODE(global_num++, InterCode("GOTO", temp));
      ss.clear();
      ss << global_num;
      ss >> temp;
      back_patch(node->children[1], "e.false", temp);
    } else if (node->children[0]->type == "DO") { // do while 暂时规约有问题

    } else if (node->children[0]->type == "FOR") {
      analysis(node->children[1], -1); // e1
      stringstream ss;
      string temp;
      string begin;
      ss << global_num;
      ss >> begin;
      ss.clear();
      analysis(node->children[2], 2); // e2
      ss << global_num;
      ss >> temp;
      ss.clear();
      back_patch(node->children[2], "e.true", temp);
      analysis(node->children[4], -1); // s
      analysis(node->children[3], -1); // e3
      PUSH_CODE(global_num++, InterCode("GOTO", begin))
      ss.clear();
      ss << global_num;
      ss >> temp;
      back_patch(node->children[2], "e.false", temp);
    } else if (node->children[0]->type == "T") { // define variables
      TreeNode *var_list = node->children[1];
      if (node->children[1]->type == "Did_list") {
        for (auto child : var_list->children) { // Did
          if (child->children.size() == 1) {    // int a;
            DEFAULT_ACTION
            table_manager.tables.top()->add_var(child->children[0]->name,
                                                node->children[0]->value);
          } else if (child->children.size() == 2) { // int *a;
            table_manager.add_array(child->children[1]->children[0]->name,
                                    0);             //只处理一级指针
          } else if (child->children.size() == 3) { // int a=1;
            analysis(child->children[2], -1);
            table_manager.tables.top()->add_var(child->children[0]->name,
                                                node->children[0]->value,
                                                child->children[2]->value);
            PUSH_CODE(global_num++, InterCode("=", child->children[0]->name,
                                              child->children[2]->value, ""))
          }
        }
      } else if (node->children[1]->type == "Aid_list") {
        for (auto child : var_list->children) {
          if (child->children.size() == 2) { // int a[2];
            stringstream ss;
            int temp;
            ss << child->children[1]->value;
            ss >> temp;
            table_manager.add_array(child->children[0]->name, temp);
          }
        }
      }
    } else if (node->children[0]->type == "ID") { // call function
      int sign = 0;
      for (int i = 0; i < table_manager.functions.size(); i++) {
        if (table_manager.functions[i]->name == node->children[0]->name) {
          sign = 1;
        }
      }
      if (sign == 0) {
        print_red2(string(node->children[0]->name) +
                   ":function has not defined!");
      }
      if (node->children.size() == 3) { // 无参函数
        string temp_var = table_manager.tables.top()->add_temp_var(
            "CALL", node->children[0]->name);
        PUSH_CODE(global_num++,
                  InterCode("CALL", temp_var, node->children[0]->name, ""))
        node->value = temp_var;
        return;
      } else { // 有参函数
        vector<TreeNode *> param_list;
        for (int i = 0; i < node->children[2]->children.size(); i++) {
          analysis(node->children[2]->children[i], -1);
          param_list.push_back(node->children[2]->children[i]);
        }
        for (auto param : param_list) {
          PUSH_CODE(global_num++, InterCode("ARG", "_", param->value))
        }
        string temp_var = table_manager.tables.top()->add_temp_var(
            "CALL", node->children[0]->name);
        PUSH_CODE(global_num++,
                  InterCode("CALL", temp_var, node->children[0]->name))
        node->value = temp_var;
        return;
      }
      return;
      DEFAULT_ACTION
    } else if (node->children[0]->type == "PRINT") { // the "print" function
      DEFAULT_ACTION
      PUSH_CODE(global_num++, InterCode("ARG", "_", node->children[1]->value))
      PUSH_CODE(global_num++, InterCode("CALL", "_", "PRINT", ""))
    } else if (node->children[0]->type == "RETURN") {
      TreeNode *return_child = node->children[0];
      if (node->children.size() == 1) { // return ;
        PUSH_CODE(global_num++, InterCode("RETURN", "_"));
      } else if (node->children.size() == 2) { // return e;
        analysis(node->children[1], -1);
        PUSH_CODE(global_num++,
                  InterCode("RETURN", "_", node->children[1]->value))
      }
    } else {
      DEFAULT_ACTION
    }
  } else {
    DEFAULT_ACTION
  }
}

void GrammarTree::gen_intercode(TreeNode *node) {
  if (node->code.size()) {
    for (int i = 0; i < node->code.size(); i++) {
      intercodes.push_back(node->code[i]);
    }
  }
  for (auto child : node->children) {
    gen_intercode(child);
  }
}

bool cmp(const pair<int, InterCode> &p1, const pair<int, InterCode> &p2) {
  return p1.first < p2.first;
}

void GrammarTree::print_to_file() {
  sort(intercodes.begin(), intercodes.end(), cmp);
  optimize();
  // ofstream fo("intercode.txt", ofstream::out);
  for (auto item : intercodes) {
    if (item.first != -1) {
      cout << item.first << ":\t" << item.second << endl;
    }
  }
  // fo.flush();
  // fo.close();
}

void GrammarTree::optimize() {
  for (int i = this->intercodes.size() - 2; i >= 0; i--) {
    if(intercodes[i].second.result[0] != 't'){
      stringstream ss;
      int temp;
      ss << intercodes[i].second.result;
      ss>>temp;
      this->intercodes[temp].first = temp;
    }
    if (intercodes[i].first != -1 && intercodes[i].second.op!="FUNCTION" && intercodes[i].second.result != "_"&&intercodes[i].second.op!="RETURN" 
        && intercodes[i].second.result[0] == 't') {
      string name = this->intercodes[i].second.result;
      int sign = 0;
      for (int j = i + 1; j < this->intercodes.size(); j++) {
        if (this->intercodes[j].second.arg1 == name ||
            this->intercodes[j].second.arg2 == name) {
          sign = 1;
        }
      }
      if (sign == 0) {
        this->intercodes[i].first = -1;
        i = this->intercodes.size() - 2;
      }
    }
  }
}
GrammarTree my_tree;
