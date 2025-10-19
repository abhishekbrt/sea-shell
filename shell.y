%{
    #include<stdio.h>
    #include<stdlib.h>
    #include "command.h"
    void yyerror(const char *s);
    extern int yylex(void);

    //track simple command being built
    SimpleCommand *currentSimpleCmd=NULL;

%}

%union{
    char* string_val;
}
%token <string_val> WORD
%token NOTOKEN,GREAT,NEWLINE,LESS,GREATGREAT,GREATAMPERSAND,PIPE,AMPERSAND


%%
goal:command_list;

arg_list:
        arg_list WORD {
                insertArgument(currentSimpleCmd,$2);   
        }
        | /*empty*/ {
                }
        ;

cmd_and_args:
        WORD {
                //create new simple command
                currentSimpleCmd=new_simpleCommand();
                if(currentSimpleCmd==NULL){
                        yyerror("failed to create simple command");
                        YYABORT;
                }
                //insert the first word in currentSimpleCmd
                insertArgument(currentSimpleCmd,$1);
        
        }
        arg_list {
                //after all argument parsed add currentSimplecmd to the Command
                insertSimpleCommand(currentSimpleCmd);
                currentSimpleCmd=NULL;
        }
        ;


pipe_list:
        pipe_list PIPE cmd_and_args { }
        | cmd_and_args {
                }
        ;

io_modifier:
        GREATGREAT WORD {
                setOutputFile($2); //TODO: correction required: it should append the word to the end of file
                }
        | GREAT WORD { 
                setOutputFile($2);
                 }
        | GREATAMPERSAND WORD {
                setOutputFile($2);
                setErrorFile($2);
                 }
        | LESS WORD {
                setInputFile($2);
                 }
        | GREAT error {
                yyerror("Missing filename after '>'");
                yyerrok;
                }
        | LESS error {
                yyerror("Missing filename after '<'");
                yyerrok;
                }
        |  GREATGREAT error {
                yyerror("Missing filename after '>>'");
                yyerrok;
                }
        |  GREATAMPERSAND error {
                yyerror("Missing filename after '>&'");
                yyerrok;
                }
        ;

io_modifier_list:
        io_modifier_list io_modifier { }
        | /*empty*/ { }
        ;

background_optional:
        AMPERSAND { 
                setBackgroundProcess(1);
                 }
        | /*empty*/ { setBackgroundProcess(0); }
        ;

command_line:
        pipe_list io_modifier_list background_optional NEWLINE {  
            Execute();
            Command_clear(); //clear for the next round
            printf("sea-shell> ");
        }
        | NEWLINE { printf("sea-shell> ");}
        | error NEWLINE { 
                yyerrok;
                Command_clear();
                printf("sea-shell> ");
                 }
        ;

command_list:
        command_list command_line { }
        | command_line { }
        ; /*command loop*/
%%
 

int main(void){
        //initialize command structure
        Command_init();
        printf("sea-shell> ");
        int result=yyparse();
        //cleanup
        Command_clear();
        return result;
    
}

void yyerror(const char *s){
    fprintf(stderr,"Parse error: %s\n",s);
}

