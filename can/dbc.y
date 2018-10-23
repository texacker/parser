/*
 * dbc.y : Parser for
 *         CAN (Controller Area Network) dbc file.
 */

%define parse.error verbose

%code top
{
    #include <stdio.h>
    #include <math.h>

    int yylex(void);
}

/*
%code requires
{
    const unsigned int YYLMAX = 64;
}*/

%union
{
    float val;

    char yytext[256];
/*  char *yytext; */
    int yyleng;
}

%code provides
{
    void yyerror(char const *);
}

%code
{
    int global_variable;
}

%token COLON
%token LB
%token RB
%token LBRACK
%token RBRACK
%token AT
%token OR
%token PLUS
%token MINUS
%token SEMICOLON
%token COMMA

%token <yytext> ID
%token <yytext> STRING
%token <yytext> INT
%token <yytext> FLOAT

%token VERSION
%token NS_
%token BS_
%token BU_

%token ERR

%%

dbc_file
        : version
          new_symbols
          bit_timing
          nodes
          dbc_tail
        ;

version
        :
        | VERSION
        | VERSION STRING
        ;

new_symbols
        :
        | new_symbol
        ;

new_symbol
        : NS_ COLON
        | new_symbol ID
        ;

bit_timing
        :
        | BS_ COLON
        ;

nodes
        :
        | BU_ COLON
        ;

dbc_tail
        :
        | dbc_tail tok
        ;

tok     : COLON
        | LB
        | RB
        | LBRACK
        | RBRACK
        | AT
        | OR
        | PLUS
        | MINUS
        | SEMICOLON
        | COMMA
        | ID
        | STRING
        | INT
        | FLOAT
        | ERR
        ;

%%

void yyerror(char const *message)
{
    fprintf(stderr, "%s\n", message);
}

int main(int argc, char *argv[])
{
    if (yyparse() == 0)
    {
        // YYACCEPT
    }

    return(0);
}
