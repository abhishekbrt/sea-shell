/*lexical analyzer for shell*/

%{
    #include<string.h>
    #include "y.tab.h"
    
%}

%option noyywrap

%%
\n    { return NEWLINE;}
[ \t] {/* discard spaces and tab*/}
">"   { return GREAT;}
"<"   {return LESS;}
">>"  {return GREATGREAT;}
">&"  {return GREATAMPERSAND;}
"|"   {return PIPE;}
"&"   {return AMPERSAND;}
[^ \t\n][^ \t\n]* {
    /*return only characters without spaces,tab and newline*/
    yylval.string_val=strdup(yytext);
    return WORD;
}


%%

