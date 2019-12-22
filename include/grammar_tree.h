#ifndef GRAMMARTREE_H
#define GRAMMARTREE_H
#include<iostream>
#include<string>
#include<vector>
#include<utility>
#include<queue>
#include<iomanip>
#include<deque>
#include<algorithm>
#include<fstream>
using std::ofstream;
using std::sort;
using std::vector;
using std::string;
using std::pair;
using std::deque;
using std::cout;
using std::queue;
using std::endl;
using std::setw;


class InterCode{
public:
    string op;
    string arg1;
    string arg2;
    string result;

    friend std::ostream& operator<<(std::ostream& out, InterCode ic){
        out<<ic.op<<'\t';
        if(ic.arg1.size()) out<<ic.arg1<<'\t';
        else out<<'_'<<'\t';
        if(ic.arg2.size()) out<<ic.arg2;
        else out<<'_';
        out<<'\t'<<ic.result;
        return out;
    }
    InterCode(string _op, string _result, string _arg1="", string _arg2=""){
        op=_op;
        result=_result;
        arg1=_arg1;
        arg2=_arg2;
    }
    InterCode(){}
};

class TreeNode{
public:
        string type;  // !

        string value; // for const

        string name; //for variable;

        // inter code
        vector<pair< int,InterCode> > code;

        // op num
        int num;
        int next;

        // node operation
        deque<TreeNode*> children;

        TreeNode(string type, string any="");

        void add_child(TreeNode *node){ children.push_front(node); }
};

using std::deque;
class GrammarTree{
public:
    vector<pair< int, InterCode> > intercodes;

    int global_num = 0;

    TreeNode* root;
    GrammarTree(){root=nullptr;}

    void print(TreeNode* node, int indent);

    void trim(TreeNode* node);

    void analysis(TreeNode*node, int layer);

    void gen_intercode(TreeNode *node);

    void print_to_file();

    void back_patch(TreeNode* node, string dst, string true_dst);

    void optimize();
};


extern GrammarTree my_tree;
#endif
