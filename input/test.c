int main()
{
    int a[2];
    a[1]=2;
    print(a[1] * 3);
    a[1]=333;

    int *p=a;
    p[0]=1;
    p[1]=p[0]+3;
    print(p[1] + 1);
    return 0;
}
