#include"../include/utils.h"

void print_red1(string s){
    cout<<"\033[31m"<<s<<"\033[0m"<<endl;
}

void print_red2(string s){
    cerr<<"\033[31m"<<s<<"\033[0m"<<endl;
}

void print_blue1(string s){
    cout<<"\033[34m"<<s<<"\033[0m"<<endl;
}

void print_blue2(string s){
    cerr<<"\033[34m"<<s<<"\033[0m"<<endl;
}

void print_green1(string s){
    cout<<"\033[32m"<<s<<"\033[0m"<<endl;
}

void print_green2(string s){
    cerr<<"\033[32m"<<s<<"\033[0m"<<endl;
}

bool is_variable(string s){   //是否为变量
if(s.size() && (s[0] < '0' || s[0] >'9') && s[0] != '&') return true;
    return false;
}

bool is_constant(string s){  //是否为常量
    if(s.size() && (s[0] >= '0'  && s[0] <='9')&& s[0] != '&') return true;
    return false;
}

bool is_int(string s){   // 是否为整数
    for(auto i : s){
        if(i=='.') return false;
    }
    return true;
}

bool is_real(string s){   // 是否为实数
    for(auto i: s){
        if(i == '.') return true;
    }
    return false;
}

int str_2_int(string s){
    int temp;
    stringstream ss;
    ss<<s;
    ss>>temp;
    return temp;
}
