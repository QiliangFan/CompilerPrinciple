%{
#include<iostream>
#include<cstdio>
#include<string>
#include<sstream>
#include<cstring>
#include<vector>
#include<stack>
#include"../include/utils.h"
#include"../include/globaldata.h"
#include"../include/symboltable.h"
#include"../include/grammar_tree.h"

using namespace std;

extern int linno;
extern int colno;

extern "C"{
    extern int yyerror(const char *);
    extern int yylex();
    extern int yyparse();
}

extern int lino;
extern int colno;
extern TableManager table_manager;
TreeNode* child=NULL;
stack<TreeNode*> action_stack;
#define ADD_NODE child=action_stack.top();action_stack.pop();node->add_child(child);
#define ADD_NEW_NODE(type, any) child=new TreeNode(type, any);node->add_child(child);
#define ADD_TO_STACK action_stack.push(node);
%}

%union{
    char* value;         //for NUM value
    char* str;              //for STR value
    struct{
        char *name;
        char* type;
        char *value;
        int address;
    } id;                         // for ID struct

    char* type;          //for T type information

}

%token <id> ID
%token <value> NUM
%token <str> STR
%token <type> T

%type <id> e


%token TRUE FALSE

%token PTR INC DEC LEFT_OP RIGHT_OP LE GE EQ NE
%token AND OR
%token STRUCT
%token CASE DEFAULT IF ELSE SWITCH WHILE DO FOR GOTO CONTINUE BREAK RETURN
%token PRINT INPUT

%start all

%nonassoc lt_else
%nonassoc ELSE


%right '='
%left OR
%left AND
%left EQ NE
%left '>' GE '<' LE
%left '+' '-'
%left '*' '/' '%'
%right '!' INC DEC
%left '&' '^' 
%nonassoc UMINUS


%%
all
    : p_list      {
            TreeNode* node = new TreeNode("all");
            while(action_stack.size()){
                node->add_child(action_stack.top());
                action_stack.pop();
            }
            my_tree.root = node;
            my_tree.trim(node);

            // my_tree.print(node, 0);
            my_tree.analysis(node, -1);
            my_tree.back_patch(node, "return_position", "_");
            my_tree.gen_intercode(node);
            my_tree.print_to_file();
    }
    | error {
                                stringstream ss;
                                string temp;
                                ss<<linno;
                                ss>>temp;
                                                    print_red2(string() + "line: " + temp + " Maybe you can think twice here.");
                                                    exit(0);
            }
    ;

p_list
    : p p_list  
    | s p_list 
    | s 
    | p
    ;

p
    :T ID '(' dec_param_list ')' '{' s_list '}'  {
                                                                                    TreeNode* node = new TreeNode("p");
                                                                                    ADD_NODE
                                                                                    ADD_NODE
                                                                                    ADD_NEW_NODE("ID", $2.name)
                                                                                    ADD_NEW_NODE("T", $1)
                                                                                    ADD_TO_STACK
                                                                                }
    | T ID  '(' ')' '{' s_list  '}'                                {
                                                                                    TreeNode* node = new TreeNode("p");
                                                                                    ADD_NODE
                                                                                    ADD_NEW_NODE("ID", $2.name)
                                                                                    ADD_NEW_NODE("T", $1)
                                                                                    ADD_TO_STACK
                                                                                 }
    ;

s_list
    :  s s_list                                                             {
                                                                                        TreeNode* node = new TreeNode("s_list");
                                                                                        ADD_NODE
                                                                                        ADD_NODE
                                                                                        ADD_TO_STACK
                                                                                   }
    | s                                                                           {
                                                                                        TreeNode* node = new TreeNode("s_list");
                                                                                        ADD_NODE
                                                                                        ADD_TO_STACK
                                                                                    }

s
    : IF '(' e ')' '{' s_list '}'  %prec lt_else        {
                                                                                        TreeNode* node = new TreeNode("s");
                                                                                        ADD_NODE
                                                                                        ADD_NODE
                                                                                        ADD_NEW_NODE("IF", "")
                                                                                        ADD_TO_STACK
                                                                                    }
    | IF '(' e ')' '{' s_list '}' ELSE '{' s_list '}'      {
                                                                                        TreeNode* node = new TreeNode("s");
                                                                                        ADD_NODE
                                                                                        ADD_NEW_NODE("ELSE", "")
                                                                                        ADD_NODE
                                                                                        ADD_NODE
                                                                                        ADD_NEW_NODE("IF", "")
                                                                                        ADD_TO_STACK
                                                                                    }
    | WHILE '(' e ')' '{' s_list '}'         {
                                                                                        TreeNode* node = new TreeNode("s");
                                                                                        ADD_NODE
                                                                                        ADD_NODE
                                                                                        ADD_NEW_NODE("WHILE","")
                                                                                        ADD_TO_STACK
                                                                                    }
    | DO '{' s_list '}' WHILE '(' e ')' ';'   {
                                                                                        TreeNode* node = new TreeNode("s");
                                                                                        ADD_NODE
                                                                                        ADD_NEW_NODE("WHILE","")
                                                                                        ADD_NODE
                                                                                        ADD_NEW_NODE("DO", "")
                                                                                        ADD_TO_STACK
                                                                                        //some unknown error :do-while not supported!
                                                                                    }
    | FOR '(' e ';' e ';' e ')' '{' s_list '}'                 {
                                                                                        TreeNode* node = new TreeNode("s");
                                                                                        ADD_NODE
                                                                                        ADD_NODE
                                                                                        ADD_NODE
                                                                                        ADD_NODE
                                                                                        ADD_NEW_NODE("FOR", "")
                                                                                        ADD_TO_STACK
                                                                                    }
    | T Did_list ';'                                                      {
                                                                                        TreeNode* node = new TreeNode("s");
                                                                                        ADD_NODE
                                                                                        ADD_NEW_NODE("T", $1)
                                                                                        ADD_TO_STACK
                                                                                    }
    | T Aid_list ';'                                                      {
                                                                                        TreeNode* node = new TreeNode("s");
                                                                                        ADD_NODE
                                                                                        ADD_NEW_NODE("T", $1)
                                                                                        ADD_TO_STACK
                                                                                    }
    | PRINT '(' e ')' ';'                                               {
                                                                                        TreeNode* node = new TreeNode("s");
                                                                                        ADD_NODE
                                                                                        ADD_NEW_NODE("PRINT", "")
                                                                                        ADD_TO_STACK
                                                                                    }
    | e ';'                                                                       {
                                                                                        TreeNode* node = new TreeNode("s");
                                                                                        ADD_NODE
                                                                                        ADD_TO_STACK
                                                                                    }
    | RETURN e ';'                                                    {
                                                                                        TreeNode* node = new TreeNode("s");
                                                                                        ADD_NODE
                                                                                        ADD_NEW_NODE("RETURN","")
                                                                                        ADD_TO_STACK
                                                                                    }
    ;

dec_param_list
    : dec_param ',' dec_param_list                  {
                                                                                            TreeNode* node = new TreeNode("dec_param_list");
                                                                                            ADD_NODE
                                                                                            ADD_NODE
                                                                                            ADD_TO_STACK
                                                                                    }
    | dec_param                                                       {
                                                                                            TreeNode* node = new TreeNode("dec_param_list");
                                                                                            ADD_NODE
                                                                                            ADD_TO_STACK
                                                                                    }
    ;

dec_param
    : T ID                                                                      {
                                                                                                TreeNode* node= new TreeNode("dec_param");
                                                                                                ADD_NEW_NODE("ID", $2.name);
                                                                                                ADD_NEW_NODE("T", $1);
                                                                                                ADD_TO_STACK
                                                                                    }
    ;

param_list
    : e ',' param_list                                                 {
                                                                                                TreeNode* node = new TreeNode("param_list");
                                                                                                ADD_NODE
                                                                                                ADD_NODE
                                                                                                ADD_TO_STACK
                                                                                      }
    | e                                                                            {
                                                                                                TreeNode* node = new TreeNode("param_list");
                                                                                                ADD_NODE
                                                                                                ADD_TO_STACK
                                                                                        }
    ;

Aid_list
    : Aid ',' Aid_list                                                       {
                                                                                                TreeNode* node = new TreeNode("Aid_list");
                                                                                                ADD_NODE
                                                                                                ADD_NODE
                                                                                                ADD_TO_STACK
                                                                                        }
    | Aid                                                                            {
                                                                                                TreeNode* node = new TreeNode("Aid_list");
                                                                                                ADD_NODE
                                                                                                ADD_TO_STACK
                                                                                         }
    ;

Aid
    : ID '[' NUM ']'                                                          {
                                                                                                TreeNode* node = new TreeNode("Aid");
                                                                                                ADD_NEW_NODE("NUM", $3)
                                                                                                ADD_NEW_NODE("ID", $1.name)
                                                                                                ADD_TO_STACK
                                                                                          }
    ;

Did_list
    : Did ',' Did_list                                                         {
                                                                                                    TreeNode* node = new TreeNode("Did_list");
                                                                                                    ADD_NODE
                                                                                                    ADD_NODE
                                                                                                    ADD_TO_STACK
                                                                                            }
    | Did                                                                               {
                                                                                                    TreeNode* node = new TreeNode("Did_list");
                                                                                                    ADD_NODE
                                                                                                    ADD_TO_STACK
                                                                                             }
    ;

Did
    : '*' Did                                                                           {
                                                                                                        TreeNode* node = new TreeNode("Did");
                                                                                                        ADD_NODE
                                                                                                        ADD_NEW_NODE("*", "")
                                                                                                        ADD_TO_STACK
                                                                                              }
    | ID                                                                                    {
                                                                                                        TreeNode* node = new TreeNode("Did");
                                                                                                        ADD_NEW_NODE("ID", $1.name);
                                                                                                        ADD_TO_STACK
                                                                                               }
    | ID '=' e                                                                            {
                                                                                                        TreeNode* node = new TreeNode("Did");
                                                                                                        ADD_NODE
                                                                                                        ADD_NEW_NODE("=", "")
                                                                                                        ADD_NEW_NODE("ID", $1.name)
                                                                                                        ADD_TO_STACK
                                                                                                }
    ;
e
    : e OR e                        {
                                                        TreeNode* node = new TreeNode("e");
                                                        ADD_NODE
                                                        ADD_NEW_NODE("OR", "")
                                                        ADD_NODE
                                                        ADD_TO_STACK
                                            }

    | e AND e                       {
                                                        TreeNode* node = new TreeNode("e");
                                                        ADD_NODE
                                                        ADD_NEW_NODE("AND", "")
                                                        ADD_NODE
                                                        ADD_TO_STACK
                                            }
    | '!' e                               {
                                                        TreeNode* node = new TreeNode("e");
                                                        ADD_NODE
                                                        ADD_NEW_NODE("!", "")
                                                        ADD_TO_STACK
                                            }
    | ID '(' param_list ')'  {
                                                    TreeNode* node = new TreeNode("e");
                                                    ADD_NEW_NODE(")", "")
                                                    ADD_NODE
                                                    ADD_NEW_NODE("(", "")
                                                    ADD_NEW_NODE("ID", $1.name)
                                                    ADD_TO_STACK
                                                   
                                            }
    | ID '('  ')'             {
                                                    TreeNode* node = new TreeNode("e");
                                                    ADD_NEW_NODE(")", "")
                                                    ADD_NEW_NODE("(", "")
                                                    ADD_NEW_NODE("ID", $1.name)
                                                    ADD_TO_STACK
                                            }       
    | '(' e ')'               {
                                                        TreeNode* node = new TreeNode("e");
                                                        ADD_NEW_NODE(")", "")
                                                        ADD_NODE
                                                        ADD_NEW_NODE("(", "")
                                                        ADD_TO_STACK
                                            }
    | e '<' e                          {
                                                        TreeNode* node = new TreeNode("e");
                                                        ADD_NODE
                                                        ADD_NEW_NODE("<", "")
                                                        ADD_NODE
                                                        ADD_TO_STACK
                                            }
    | e '>' e                          {
                                                        TreeNode* node = new TreeNode("e");
                                                        ADD_NODE
                                                        ADD_NEW_NODE(">", "")
                                                        ADD_NODE
                                                        ADD_TO_STACK
                                            }
    | e LE e                          {
                                                        TreeNode* node = new TreeNode("e");
                                                        ADD_NODE
                                                        ADD_NEW_NODE("LE", "")
                                                        ADD_NODE
                                                        ADD_TO_STACK
                                            }
    | e GE e                         {
                                                        TreeNode* node = new TreeNode("e");
                                                        ADD_NODE
                                                        ADD_NEW_NODE("GE", "")
                                                        ADD_NODE
                                                        ADD_TO_STACK
                                            }
    | e EQ e                         {
                                                        TreeNode* node = new TreeNode("e");
                                                        ADD_NODE
                                                        ADD_NEW_NODE("EQ", "")
                                                        ADD_NODE
                                                        ADD_TO_STACK
                                            }
    | e NE e                         {
                                                        TreeNode* node = new TreeNode("e");
                                                        ADD_NODE
                                                        ADD_NEW_NODE("NE", "")
                                                        ADD_NODE
                                                        ADD_TO_STACK
                                            }
    | e '+' e                          {
                                                        TreeNode* node = new TreeNode("e");
                                                        ADD_NODE
                                                        ADD_NEW_NODE("+", "")
                                                        ADD_NODE
                                                        ADD_TO_STACK
                                            }
    | e '-' e                           {
                                                        TreeNode* node = new TreeNode("e");
                                                        ADD_NODE
                                                        ADD_NEW_NODE("-", "")
                                                        ADD_NODE
                                                        ADD_TO_STACK
                                            }
    | e '*' e                          {
                                                        TreeNode* node = new TreeNode("e");
                                                        ADD_NODE
                                                        ADD_NEW_NODE("*", "")
                                                        ADD_NODE
                                                        ADD_TO_STACK
                                            }
    | e '/' e                           {
                                                        TreeNode* node = new TreeNode("e");
                                                        ADD_NODE
                                                        ADD_NEW_NODE("/", "")
                                                        ADD_NODE
                                                        ADD_TO_STACK
                                            }
    | e '%' e                         {
                                                        TreeNode* node = new TreeNode("e");
                                                        ADD_NODE
                                                        ADD_NEW_NODE("%", "")
                                                        ADD_NODE
                                                        ADD_TO_STACK
                                            }
    | e '^' e                           {
                                                        TreeNode* node = new TreeNode("e");
                                                        ADD_NODE
                                                        ADD_NEW_NODE("^", "")
                                                        ADD_NODE
                                                        ADD_TO_STACK
                                            }
    | TRUE                          {
                                                        TreeNode* node = new TreeNode("e");
                                                        ADD_NEW_NODE("TRUE", "")
                                                        ADD_TO_STACK
                                            }
    | FALSE                         {
                                                        TreeNode* node = new TreeNode("e");
                                                        ADD_NEW_NODE("FALSE", "")
                                                        ADD_TO_STACK
                                            }
    | '-' e %prec UMINUS {
                                                        TreeNode* node = new TreeNode("e");
                                                        ADD_NODE
                                                        ADD_NEW_NODE("-", "")
                                                        ADD_TO_STACK
                                            }
    | e '=' e                              {
                                                        TreeNode* node = new TreeNode("e");
                                                        ADD_NODE
                                                        ADD_NEW_NODE("=", "")
                                                        ADD_NODE
                                                        ADD_TO_STACK
                                            }
    | INPUT '(' ')'                {
                                                        TreeNode* node =new  TreeNode("e");
                                                        ADD_NEW_NODE(")", "")
                                                        ADD_NEW_NODE("(", "")
                                                        ADD_NEW_NODE("INPUT", "")
                                                        ADD_TO_STACK
                                            }
    | NUM                            {
                                                    TreeNode* node = new TreeNode("e");
                                                    ADD_NEW_NODE("NUM",  $1)
                                                    ADD_TO_STACK
                                            }
    | STR                              {
                                                    TreeNode* node = new TreeNode("e");
                                                    ADD_NEW_NODE("STR", $1)
                                                    ADD_TO_STACK
                                            }
    | ID                                 {
                                                    TreeNode* node = new TreeNode("e");
                                                    ADD_NEW_NODE("ID", $1.name)
                                                    ADD_TO_STACK
                                            }
    | e INC                           {
                                                    TreeNode* node = new TreeNode("e");
                                                    ADD_NEW_NODE("INC","")
                                                    ADD_NODE
                                                    ADD_TO_STACK
                                            }
    | e DEC                          {
                                                    TreeNode* node = new TreeNode("e");
                                                    ADD_NEW_NODE("DEC", "")
                                                    ADD_NODE
                                                    ADD_TO_STACK
                                            }
    | INC e                           {
                                                    TreeNode* node = new TreeNode("e");
                                                    ADD_NODE
                                                    ADD_NEW_NODE("INC", "")
                                                    ADD_TO_STACK
                                            }
    | DEC e                          {
                                                    TreeNode* node = new TreeNode("e");
                                                    ADD_NODE
                                                    ADD_NEW_NODE("DEC", "")
                                                    ADD_TO_STACK
                                            }
    | ID '[' e ']'                    {
                                                    TreeNode* node = new TreeNode("e");
                                                    ADD_NEW_NODE("]","")
                                                    ADD_NODE
                                                    ADD_NEW_NODE("[", "")
                                                    ADD_NEW_NODE("ID", $1.name)
                                                    ADD_TO_STACK
                                            }
    | '*' e    %prec UMINUS    {
                                                    TreeNode* node = new TreeNode("e");
                                                    ADD_NODE
                                                    ADD_NEW_NODE("*", "")
                                                    ADD_TO_STACK
                                            }
    | '&' e                             {
                                                    TreeNode* node  = new TreeNode("e");
                                                    ADD_NODE
                                                    ADD_NEW_NODE("&", "")
                                                    ADD_TO_STACK
                                            }
    ;

wrong
    : T Did_list ':'                       {
                                                    stringstream ss;
                                                    string temp;
                                                    ss<<linno;
                                                    ss>>temp;
                                                    print_red2(string() + "line: " + temp + "  if ':' should be replaced by ';'?");
                                                    exit(0);
                                         }
    | e ':'                             {
                                                    stringstream ss;
                                                    string temp;
                                                    ss<<linno;
                                                    ss>>temp;
                                                    print_red2(string() + "line: " + temp + " if ':' should be replaced by ';'?");
                                                    exit(0);
                                            }
    | PRINT '('  ')'      {
                                                stringstream ss;
                                                string temp;
                                                ss<<linno;
                                                ss>>temp;
                                                print_red2(string() + "line: " + temp + "传入参数不应为空！");
                                                exit(0);
                                        }
    ;

%%

int main(){
    yyparse();
    // do something here

    //end action
    return 0;
}

int yyerror(const char * str){
    char buf[256];
    snprintf(buf, 256, "%s", str);
    print_red2(buf);
    return 0;
}
