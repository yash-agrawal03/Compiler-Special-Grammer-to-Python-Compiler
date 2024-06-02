%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <stdbool.h>
    #include <string.h>

    // #include "header.h"

    void yyerror(char *);
    int yylex(void);

    #define MAX_SYMBOLS 1024
    #define FUNC 1
    #define VAR 2

    #define BOLD "\x1b[1m"
    #define RED "\x1b[31m"
    #define MAGENTA "\x1b[35m"
    #define RESET "\x1b[0m"

    typedef struct {
        char name[32];
        int type;
    } Symbol;

    Symbol symbol_table[MAX_SYMBOLS];
    int sym_count = 0;

    void addSymbol(char* name, int type)
    {
        strcpy(symbol_table[sym_count].name, name);
        symbol_table[sym_count].type = type;
        sym_count++;
    }

    Symbol* searchSymbol(char* name)
    {
        for (int i=0; i<sym_count; i++)
        {
            if (!strcmp(name, symbol_table[i].name))
            {
                return &symbol_table[i];
            }
        }

        return NULL;
    }

    void printSymbols()
    {
        for (int i=0; i<sym_count; i++)
        {
            printf("%s %d\n", symbol_table[i].name, symbol_table[i].type);
        }
    }

    FILE* file;

    void print(char* stream)
    {
        char* temp = strdup(stream);
        char* line = strtok(temp, "<>");
        while (line != NULL)
        {
            fprintf(file, "%s\n", line);
            line = strtok(NULL, "<>");
        }
    }

%}

/* %error-verbose */

%union {
    int num;
    char* chr;
}

%token EQU ADD SUB MUL DIV
%token LPN RPN CLPN CRPN BLPN BRPN
%token SEC1 SEC2 SEC3
%token IF THEN ELSE WHILE END
%token CALL WITH RETURN
%token NEWLINE
%token PLAY

%token <chr> INTEGER 
%token <chr> ID

%left ADD SUB
%left MUL DIV

%type <chr> ARITHLOGIC IFSTATEMENT STATEMENT FUNCTION FUNCTIONS BODY PRIMITIVE START WHILELOOP EXPR ENGINE PARAM PARAMLIST

%%      

START:
        SEC1 NEWLINE PRIMITIVE SEC2 NEWLINE FUNCTIONS SEC3 NEWLINE ENGINE   {
                                                                                $$ = malloc(1024 + strlen($3) + 1024 + strlen($6));
                                                                                memset($$, 0, strlen($$));
                                                                                sprintf($$, "from engine import Tetris\n\n"
                                                                                        "# Section 1\n%s\n\n"
                                                                                        "# Section 2\n%s\n\n"
                                                                                        "# Section 3\n%s", $3, $6, $9);
                                                                                print($$);
                                                                                // printSymbols();
                                                                                // if (searchSymbol("num2") != NULL)
                                                                                //     printf("FOUND\n");
                                                                                // printf("%d\n", section);
                                                                            }
        ;

ENGINE:
        BLPN PLAY BRPN                              {
                                                        $$ = strdup("game = Tetris()\ngame.run()");
                                                    }
        | BLPN PLAY WITH PARAM PARAMLIST BRPN       {
                                                        if (strcmp($5,""))
                                                            sprintf($$,"game = Tetris(%s , %s)\n", $4, $5);
                                                        else
                                                            sprintf($$,"game = Tetris(%s)\n", $4);

                                                        strcat($$, "game.run()");
                                                    }

FUNCTIONS:
        FUNCTION NEWLINE FUNCTIONS      {
                                            $$ = malloc(strlen($1) + 3 + strlen($3));
                                            memset($$, 0, strlen($$));
                                            if (strcmp($3, ""))
                                                sprintf($$, "%s\n\n\n%s", $1, $3);
                                            else
                                                sprintf($$, "%s", $1);
                                            // print($$);
                                        }
        |                               {   $$ = "";    }
        ;

FUNCTION:
        CLPN ID BODY CRPN               {
                                            $$ = malloc(4 + strlen($2) + 2 + strlen($3) + 1024); // 1024 for \t
                                            memset($$, 0, strlen($$));
                                            sprintf($$, "def %s():<>", $2);

                                            char* temp = strdup($3);
                                            char* line = strtok(temp, "<>");
                                            while (line != NULL)
                                            {
                                                strcat($$, "<>\t");
                                                strcat($$, line);
                                                line = strtok(NULL, "<>");
                                            }
                                            
                                            
                                            // print($$);
                                        }
        | CLPN ID BODY RETURN ID CRPN   {
                                            $$ = malloc(4 + strlen($2) + 2 + strlen($3) + 1024); // 1024 for \t
                                            memset($$, 0, strlen($$));
                                            sprintf($$, "def %s():<>", $2);

                                            char* temp = strdup($3);
                                            char* line = strtok(temp, "<>");
                                            while (line != NULL)
                                            {
                                                strcat($$, "<>\t");
                                                strcat($$, line);
                                                line = strtok(NULL, "<>");
                                            }
                                            strcat($$, "<>\treturn ");
                                            strcat($$, $5);
                                            addSymbol($2, FUNC);
                                            
                                            // print($$);
                                        }
        ;

PRIMITIVE:
        ID EQU EXPR NEWLINE PRIMITIVE   {
                                            $$ = malloc(strlen($1) + 3 + strlen($3) + 1 + strlen($5));
                                            memset($$, 0, strlen($$));
                                            sprintf($$, "%s = %s\n%s", $1, $3, $5);
                                            if ($3[strlen($3)-1] == ')')
                                                addSymbol($1, FUNC);
                                            else
                                                addSymbol($1, VAR);
                                        }
        |                               { $$ = ""; }
        ; 

BODY:
        STATEMENT BODY                  {
                                            $$ = malloc(strlen($1) + 2 + strlen($2));
                                            memset($$, 0, strlen($$));
                                            sprintf($$, "%s<>%s", $1, $2);
                                        }
        | STATEMENT                     {   $$ = strdup($1);    }
        ;

STATEMENT:
        IFSTATEMENT                     {
                                            $$ = strdup($1);
                                        }
        | WHILELOOP                     {}
        | ID EQU EXPR                   {
                                            $$ = malloc(strlen($1) + 3 + strlen($3));
                                            memset($$, 0, strlen($$));
                                            // printf("%s = %s\n", $1, $3);
                                            sprintf($$, "%s = %s", $1, $3);
                                            
                                            if (searchSymbol($1) == NULL)
                                            {
                                                printf(BOLD "tetris: " MAGENTA "name warning: " RESET "name '%s' not defined\n", $1);
                                            }
                                        }
        ;

IFSTATEMENT:
        IF LPN EXPR RPN THEN BODY END                   {
                                                            $$ = malloc(3 + strlen($3) + 2 + strlen($6) + 1024); // 1024 for \t
                                                            memset($$, 0, strlen($$));
                                                            sprintf($$, "if %s:", $3);

                                                            char* temp = strdup($6);
                                                            char* line = strtok(temp, "<>");
                                                            while (line != NULL)
                                                            {
                                                                strcat($$, "<>\t");
                                                                strcat($$, line);
                                                                line = strtok(NULL, "<>");
                                                            }
                                                            // print($$);
                                                                        
                                                        }
        | IF LPN EXPR RPN THEN BODY ELSE BODY END       {
                                                            $$ = malloc(3 + strlen($3) + 2 + strlen($6) + 6 + strlen($8) + 1024); // 1024 for \t
                                                            memset($$, 0, strlen($$));
                                                            sprintf($$, "if %s:", $3);
                                                            
                                                            char* temp = strdup($6);
                                                            char* line = strtok(temp, "<>");
                                                            while (line != NULL)
                                                            {
                                                                strcat($$, "<>\t");
                                                                strcat($$, line);
                                                                line = strtok(NULL, "<>");
                                                            }
                                                            
                                                            strcat($$, "<>else:");
                                                            temp = strdup($8);
                                                            line = strtok(temp, "<>");
                                                            while (line != NULL)
                                                            {
                                                                strcat($$, "<>\t");
                                                                strcat($$, line);
                                                                line = strtok(NULL, "<>");
                                                            }
                                                                        
                                                        }
        ;

WHILELOOP:
        WHILE LPN EXPR RPN BODY END                     {
                                                            $$ = malloc(6 + strlen($3) + 1 + strlen($5) + 1024); // 1024 for \t
                                                            memset($$, 0, strlen($$));
                                                            sprintf($$, "while %s:", $3);

                                                            char* temp = strdup($5);
                                                            char* line = strtok(temp, "<>");
                                                            while (line != NULL)
                                                            {
                                                                strcat($$, "<>\t");
                                                                strcat($$, line);
                                                                line = strtok(NULL, "<>");
                                                            }
                                                            // print($$);
                                                                        
                                                        }
        ;
        
EXPR:
        ARITHLOGIC                                      { $$ = strdup($1); }
        | BLPN CALL ID BRPN                             { 
                                                            $$ = strdup($3); 
                                                            strcat($$,"()");

                                                            if (searchSymbol($3) == NULL)
                                                                printf(BOLD "tetris: " MAGENTA "name warning: " RESET "name '%s' not defined\n", $3);
                                                        }
        | BLPN CALL ID WITH PARAM PARAMLIST BRPN        { 
                                                            $$ = malloc(strlen($3) + 3 + strlen($5) + strlen($6));
                                                            memset($$, 0, strlen($$));
                                                            
                                                            if (strcmp($6,""))
                                                                sprintf($$, "%s(%s , %s)", $3, $5, $6);
                                                            else
                                                                sprintf($$, "%s(%s)", $3, $5);

                                                            if (searchSymbol($3) == NULL)
                                                                printf(BOLD "tetris: " MAGENTA "name warning: " RESET "name '%s' not defined\n", $3);
                                                        }
        ;

PARAM:
        ID EQU EXPR             { 
                                    sprintf($$, "%s = %s", $1, $3);
                                }
        ;

PARAMLIST:
        PARAM PARAMLIST         { 
                                    if (strcmp($2, ""))
                                        sprintf($$, "%s , %s", $1, $2);
                                    else
                                        sprintf($$, "%s", $1);
                                }
        |                       { $$ = strdup(""); }
        ;

ARITHLOGIC:
        INTEGER                                 {
                                                    $$ = strdup($1); 
                                                    // printf("<integer>\n%s</integer>\n", $1);
                                                }
        | ID                                    {   
                                                    if (searchSymbol($1) == NULL)
                                                    {
                                                        printf(BOLD "tetris: " MAGENTA "name warning: " RESET "name '%s' not defined, using as string\n", $1);
                                                        $$ = malloc(strlen($1) + 2);
                                                        memset($$,0,strlen($$));
                                                        strcat($$, "\'");
                                                        strcat($$, $1);
                                                        strcat($$,"\'");
                                                    }
                                                    else
                                                        $$ = strdup($1);
                                                }
        | ARITHLOGIC ADD ARITHLOGIC             {
                                                    $$ = malloc(strlen($1) + 3 + strlen($3));
                                                    memset($$, 0, strlen($$));
                                                    sprintf($$, "%s + %s", $1, $3);
                                                }
        | ARITHLOGIC SUB ARITHLOGIC             {
                                                    $$ = malloc(strlen($1) + 3 + strlen($3));
                                                    memset($$, 0, strlen($$));
                                                    sprintf($$, "%s - %s", $1, $3);
                                                }
        | ARITHLOGIC MUL ARITHLOGIC             {
                                                    $$ = malloc(strlen($1) + 3 + strlen($3));
                                                    memset($$, 0, strlen($$));
                                                    sprintf($$, "%s * %s", $1, $3);
                                                }
        | ARITHLOGIC DIV ARITHLOGIC             {
                                                    $$ = malloc(strlen($1) + 3 + strlen($3));
                                                    memset($$, 0, strlen($$));
                                                    sprintf($$, "%s / %s", $1, $3);
                                                }
        | SUB ARITHLOGIC                        {
                                                    $$ = malloc(1 + strlen($2));
                                                    memset($$, 0, strlen($$));
                                                    sprintf($$, "-%s", $2);
                                                }
        | LPN ARITHLOGIC RPN                    {
                                                    $$ = malloc(strlen($2) + 2);
                                                    memset($$, 0, strlen($$));
                                                    sprintf($$, "(%s)", $2);
                                                }
        ;

%%

void yyerror(char *s) 
{
    fprintf(stderr, "%s\n", s);
}

int main(int argc, char* argv[]) 
{
    if (argc != 2)
    {
        printf(BOLD "tetris: " RED "fatal error:" RESET " no input file\n" "compilation terminated.\n");
        return 1;
    }

    char* filename = strdup(argv[1]);
    freopen(filename, "r", stdin);

    char* token = strtok(filename, ".");

    strcat(token, ".py");

    file = fopen(token, "w, ccs=ISO-8859-1");

    yyparse();
}