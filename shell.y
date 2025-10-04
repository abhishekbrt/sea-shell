%{
    #include<stdio.h>
    #include<stdlib.h>
    void yyerror(const char *s);
    extern int yylex(void);

%}

%union{
    char* string_val;
}
%token <string_val> WORD
%token NOTOKEN,GREAT,NEWLINE,LESS,GREATGREAT,GREATAMPERSAND,PIPE,AMPERSAND


%%
goal:command_list;

arg_list:
        arg_list WORD { }
        | /*empty*/ { }
        ;

cmd_and_args:
        WORD arg_list { }
        ;

pipe_list:
        pipe_list PIPE cmd_and_args { }
        | cmd_and_args { }
        ;

io_modifier:
        GREATGREAT WORD { }
        | GREAT WORD { }
        | GREATAMPERSAND WORD { }
        | LESS WORD { }
        ;

io_modifier_list:
        io_modifier_list io_modifier { }
        | /*empty*/ { }
        ;

background_optional:
        AMPERSAND { }
        | /*empty*/ { }
        ;

command_line:
        pipe_list io_modifier_list background_optional NEWLINE { }
        | NEWLINE { }
        | error NEWLINE { yyerrok; }
        ;

command_list:
        command_list command_line { }
        | command_line { }
        ; /*command loop*/
%%
 

int main(void){
    printf("sea-shell> ");
    return yyparse();
}

void yyerror(const char *s){
    fprintf(stderr,"Parse error: %s\n",s);
}