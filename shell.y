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
                printf("Found argument: %s\n",$2);   
                insertArgument(currentSimpleCmd,$2);   
        }
        | /*empty*/ {printf("Empty argument list\n"); }
        ;

cmd_and_args:
        WORD {
                printf("intial command word: %s\n",$1);
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
                printf("Command: %s\n", $1); 
                //after all argument parsed add currentSimplecmd to the pipeline
                insertSimpleCommand(currentSimpleCmd);
                printf("simple command added with %d arguments\n",currentSimpleCmd->noOfArguments);
                currentSimpleCmd=NULL;
        }
        ;


pipe_list:
        pipe_list PIPE cmd_and_args { printf("Adding command to pipeline\n");}
        | cmd_and_args {printf("Single command (no pipe)\n"); }
        ;

io_modifier:
        GREATGREAT WORD {
                printf("Redirect append to: %s\n", $2); 
                setOutputFile($2); //TODO: correction required: it should append the word to the end of file
                }
        | GREAT WORD { 
                printf("Redirect output to: %s\n", $2);
                setOutputFile($2);
                 }
        | GREATAMPERSAND WORD {
                printf("Redirect stdout+stderr to: %s\n", $2);
                setOutputFile($2);
                setErrorFile($2);
                 }
        | LESS WORD {
                printf("Redirect input from: %s\n", $2);
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
                printf("Running in background!\n");
                setBackgroundProcess(1);
                 }
        | /*empty*/ { setBackgroundProcess(0); }
        ;

command_line:
        pipe_list io_modifier_list background_optional NEWLINE {  
            printf("=== Command complete ===\n");
            printCommand(); //print the command table
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

