%{
    #include "y.tab.h"
    #include <stdlib.h>
    // #include "header.h"

    void yyerror(char *);

    #define BOLD "\x1b[1m"
    #define RED "\x1b[31m"
    #define MAGENTA "\x1b[35m"
    #define RESET "\x1b[0m"

    int section=0;

    void checkSec2(char* token)
    {
        if (section != 2)
            printf(BOLD "tetris: " RED "fatal error: " RESET "'%s' used outside Section2 (line %d)\n", token, yylineno);
    }

    void checkSec3(char* token)
    {
        if (section != 3)
            printf(BOLD "tetris: " RED "fatal error: " RESET "'%s' used outside Section3 (line %d)\n", token, yylineno);
    }

%}

%option yylineno

%%

"Section1"              { 
                            if (section==0)
                                section++;
                            else
                                printf(BOLD "tetris: " RED "fatal error: " RESET "Section1 repeated (line %d)\n", yylineno);
                            return SEC1;
                        }

"Section2"              {
                            if (section==1)
                                section++;
                            else
                                printf(BOLD "tetris: " RED "fatal error: " RESET "Section2 repeated (line %d)\n", yylineno);
                            return SEC2;
                        }
"Section3"              {
                            if (section==2)
                                section++;
                            else
                                printf(BOLD "tetris: " RED "fatal error: " RESET "Section3 repeated (line %d)\n", yylineno);
                            return SEC3;
                        }

"call"                  { return CALL; }
"with"                  { return WITH; }
"while"                 { checkSec2("while"); return WHILE;}
"return"                { checkSec2("return"); return RETURN; }

"if"                    { checkSec2("if"); return IF; }
"then"                  { checkSec2("then"); return THEN; }
"else"                  { checkSec2("else"); return ELSE; }
"end"                   { checkSec2("end"); return END;  }

"play"                  { checkSec3("play"); return PLAY; }

[A-Za-z][A-Za-z0-9]*    {
                            yylval.chr = strdup(yytext);
                            return ID;
                        }

[0-9]+          {
                    yylval.chr = strdup(yytext);
                    return INTEGER;
                }

"="             { return EQU; }
"+"             { return ADD; }
"-"             { return SUB; }
"*"             { return MUL; }
"/"             { return DIV; }
"("             { return LPN; }
")"             { return RPN; }
"{"             { return CLPN; }
"}"             { return CRPN; }
"["             { return BLPN; }
"]"             { return BRPN; }
"\n"            { return NEWLINE; }

[ \t]   ;       /* skip whitespace */

.               {printf("%s\n", yytext); yyerror("Unknown character");}

%%

int yywrap(void) {
    return 1;
}