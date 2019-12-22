%{
#include<iostream>
#include<cstring>
#include<string>
#include<sstream>
using namespace std;
#include"../include/utils.h"
#include"../include/globaldata.h"

#include"y.tab.h"

extern "C"{
    extern int yylex();
    extern int yywrap();
    extern int yyerror(const char * str);
}


extern YYSTYPE yylval;

#define COMMON_ACTION ECHO;cout<<endl;
#define COMMON_ACTION ;
#define TYPE_ACTION   yylval.type = (char*)malloc(yyleng+1);snprintf(yylval.type, yyleng+1, "%s", yytext );
%}



%s BLOCK_COMMENT

%%
 /*consume the comments  */
"//"[^\n]*          {/* consume the line comment*/}
"/*"                      { /* consume the line comment */
                                    colno+=strlen(yytext);
                                    BEGIN BLOCK_COMMENT;

                              }
<BLOCK_COMMENT>"*/"                    {
                                                                              colno+=strlen(yytext);
                                                                              BEGIN INITIAL;
                                                                        }
<BLOCK_COMMENT>.+/"*/"               { /* consume the block comment */colno+=strlen(yytext);}
<BLOCK_COMMENT>\n                        {
                                                                                linno++;
                                                                                colno=1;
                                                                         }
 /*space words */
[\r\t\v\f ]              { /* 占位,缩进符 */
                                        colno++;
                                }
\n                            {
                                        COMMON_ACTION
                                        linno++;
                                        colno=1;
                                }
","                           {
                                         colno+=1;
                                         return ',';
                               }
";"                          {COMMON_ACTION
                                         colno+=1;
                                         return ';';
                               }
[{}]                        {COMMON_ACTION
                                          colno+=1;
                                          return yytext[0];
                               }
"("|")"                  {
                                           colno+=1;
                                           return yytext[0];
                              }

 /* key words*/
 /* type specifier */
"char"                  {
                                    COMMON_ACTION
                                    TYPE_ACTION
                                    colno+=4;return T;
                                }
"short"                {
                                    COMMON_ACTION
                                    TYPE_ACTION
                                    colno+=5;return T;
                                }
"int"                      {
                                    COMMON_ACTION
                                    TYPE_ACTION
                                     colno+=3;return T;
                                }
"long"                  {
                                    COMMON_ACTION
                                    TYPE_ACTION
                                     colno+=4;return T;
                                }
"signed"              {
                                    COMMON_ACTION
                                    TYPE_ACTION
                                     colno+=6;return T;
                                }
"unsigned"        {
                                    COMMON_ACTION
                                    TYPE_ACTION
                                    colno+=8;return T;
                                }
"float"                  {
                                    COMMON_ACTION
                                    TYPE_ACTION
                                     colno+=5;return T;
                                }
"double"             {
                                    COMMON_ACTION
                                    TYPE_ACTION
                                     colno+=6;return T;
                                }
"void"                   {
                                    COMMON_ACTION
                                    TYPE_ACTION
                                     colno+=4;return T;
                                }
"struct"                {
                                    COMMON_ACTION
                                      colno+=6;return STRUCT;
                                }
"true"                    {
                                        COMMON_ACTION
                                        colno += 5;return TRUE;
                                }
"false"                   {
                                        COMMON_ACTION
                                        colno += 5;return FALSE;
                                }
 /* flow control  */
"case"                  {
                                    COMMON_ACTION
                                    colno+=4;return CASE;
                               }
"default"            {
                                    COMMON_ACTION
                                     colno+=7;return DEFAULT;
                                }
"if"                         {
                                    COMMON_ACTION
                                     colno+=2;return IF;
                                }
"else"                   {
                                    COMMON_ACTION
                                     colno+=4;return ELSE;
                                }
"switch"              {
                                    COMMON_ACTION
                                    colno+=6;return SWITCH;
                                }
"while"                {
                                    COMMON_ACTION
                                    colno+=5;return WHILE;
                                }
"do"                      {
                                    COMMON_ACTION
                                     colno+=2;return DO;
                                }
"for"                      {
                                    COMMON_ACTION
                                     colno+=3;return FOR;
                                }
"goto"                  {
                                    COMMON_ACTION
                                    colno+=4;return GOTO;
                                }
"continue"         {
                                    COMMON_ACTION
                                    colno+=8;return CONTINUE;
                                }
"break"                {
                                    COMMON_ACTION
                                    colno+=5;return BREAK;
                                }
"return"               {
                                    COMMON_ACTION
                                    colno+=6;return RETURN;
                                }
 /* ops  */
"->"                       {  /* pointer's op*/
                                        COMMON_ACTION
                                        colno+=2;return PTR;
                               }
"++"                      { /* increment op*/
                                        COMMON_ACTION
                                        colno+=2;return INC;
                               }
"--"                       { /* descend op*/
                                        COMMON_ACTION
                                         colno+=2;return DEC;
                              }
"<<"                    {  /* left op */
                                        COMMON_ACTION
                                         colno+=2;return LEFT_OP;
                              }
">>"                     { /* right op */
                                        COMMON_ACTION
                                         colno+=2;return RIGHT_OP;
                              }
"<="                     { /* le op*/
                                        COMMON_ACTION
                                          colno+=2;return LE;
                              }
">="                     { /* ge op */
                                        COMMON_ACTION
                                        colno+=2;return GE;
                              }
"=="                     {  /* eq op */
                                        COMMON_ACTION
                                        colno+=2;return EQ;
                              }
"!="                      {  /* ne op */
                                        COMMON_ACTION
                                        colno+=2;return NE;
                              }
":"                         {
                                        COMMON_ACTION
                                        colno+=1;return ':';
                              }
"="                       {
                                        COMMON_ACTION
                                        colno+=1;return '=';
                              }
"["                        {
                                        COMMON_ACTION
                                        colno+=1;return '[';
                              }
"]"                        {
                                        COMMON_ACTION
                                        colno+=1;return ']';
                              }
"."                         {
                                        COMMON_ACTION
                                        colno+=1;return '.';
                              }
"&&"                    {
                                        COMMON_ACTION
                                        colno+=2;return AND;
                              }
"||"                        {
                                        COMMON_ACTION
                                        colno+=2;return OR;
                              }
"&"                      {
                                        COMMON_ACTION
                                        colno+=1;return '&';
                              }
"!"                        {
                                        COMMON_ACTION
                                        colno+=1;return '!';
                              }
"~"                       {
                                        COMMON_ACTION
                                        colno+=1;return '~';
                              }
"-"                        {
                                        COMMON_ACTION
                                        colno+=1;return '-';
                              }
"+"                       {
                                        COMMON_ACTION
                                        colno+=1;return '+';
                              }
"*"                       {
                                        COMMON_ACTION
                                        colno+=1;return '*';
                              }
"/"                        {
                                        COMMON_ACTION
                                        colno+=1;return '/';
                              }
"%"                      {
                                        COMMON_ACTION
                                        colno+=1;return '%';
                              }
"<"                       {
                                        COMMON_ACTION
                                        colno+=1;return '<';
                              }
">"                       {
                                        COMMON_ACTION
                                        colno+=1;return '>';
                              }
"^"                       {
                                        COMMON_ACTION
                                        colno+=1;return '^';
                              }
"|"                        {
                                        COMMON_ACTION
                                        colno+=1;return '|';
                              }
"?"                       {
                                        COMMON_ACTION
                                        colno+=1;return '?';
                              }
 /* functions */
"print"              {
                                        COMMON_ACTION
                                        colno+=5;return PRINT;
                              }
"input"               {
                                        COMMON_ACTION
                                        colno+=5;return INPUT;
                              }

[_a-zA-Z][_0-9a-zA-Z]*                             {
                                                                                COMMON_ACTION
                                                                                yylval.id.name = (char *)malloc(yyleng+1);
                                                                                snprintf(yylval.id.name, yyleng+1, "%s", yytext);
                                                                                colno+=yyleng;
                                                                                return ID;
                                                                          }
[0-9]+                                                               {
                                                                                COMMON_ACTION
                                                                                yylval.value = (char *)malloc(yyleng+1);
                                                                                snprintf(yylval.value, yyleng+1, "%s", yytext);
                                                                                colno+=yyleng;
                                                                                return NUM;
                                                                           }
[0-9]*\.[0-9]+                                                {
                                                                                COMMON_ACTION
                                                                                yylval.value = (char*)malloc(yyleng+1);
                                                                                snprintf(yylval.value, yyleng+1, "%s", yytext);
                                                                                 colno+=yyleng;
                                                                                 stringstream ss;
                                                                                 ss<<linno;
                                                                                 string  temp;
                                                                                 ss>>temp;
                                                                                 print_red2(string() + "line:" + temp + " type error!");
                                                                                 exit(-1);
                                                                                 return NUM;
                                                                           }
 /* string literal  */
<INITIAL>\"[^"]+?\"                                 {
                                                                                COMMON_ACTION
                                                                                yylval.str = (char*)malloc(yyleng+1);
                                                                                string s = string(yytext);
                                                                                s.erase(s.begin());
                                                                                s.erase(s.end()-1);
                                                                                snprintf(yylval.value, yyleng+1, "%s", s.c_str());
                                                                                colno+=yyleng;
                                                                                BEGIN INITIAL;
                                                                                return STR;
                                                                         }

[0-9][a-zA-Z0-9_]+ {   /* to complain about  illegal words */
                                            COMMON_ACTION
                                            yyerror("Illegal identifier!!!");
                                   }

.                             {  /* to complain about unknown characters*/
                                            COMMON_ACTION
                                            yyerror("Unexpected character!");
                              }


%%


int yywrap(){
    return 1;
}
