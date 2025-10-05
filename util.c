#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<errno.h>
#include "util.h"

void printError(char* message){
    fprintf(stderr,"ERROR: %s\n",message);
    if(errno!=0){
        fprintf(stderr,"System ERROR: %s\n",strerror(errno));
        errno=0;
    }
}

