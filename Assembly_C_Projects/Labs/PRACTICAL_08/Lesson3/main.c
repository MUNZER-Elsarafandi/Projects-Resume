#include "stdio.h"

int main()
{
    int a; 

    //call to printf function a is substituted for %d
    printf("Value of a is %d\n", a);

    // Scope
    {
        a=10;
        printf("Value of a is %d\n", a);
    }

    //scope
    {
        a = 100;
        printf("Vlaue of a is %d\n", a);

    }

    printf("Value of a is %d\n", a);


    return 0;
}