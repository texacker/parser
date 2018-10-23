/*
 * dbc.lex : Scanner for
 *           CAN (Controller Area Network) dbc file.
 */

%{

#include "y.tab.h"

#ifndef YYVAL
#define YYVAL strcpy(yylval.yytext, yytext); yylval.yyleng = yyleng
#endif

%}

LineTerminator      \r|\n|\r\n
WhiteSpace          [ \t\f]
StringCharacter     [^\r\n\"\\]
String              \"("\\\""|{StringCharacter})*\"
Identifier          [_a-zA-Z][_a-zA-Z0-9]*

DecIntegerLiteral   [+-]?(0|[1-9][0-9]*)
FloatLiteral        [+-]?({FLit1}|{FLit2}|{FLit3})

FLit1               [0-9]+"."[0-9]*
FLit2               "."[0-9]+
FLit3               [0-9]+

%%

VERSION             return(VERSION);
NS_                 return(NS_);
BS_                 return(BS_);
BU_                 return(BU_);

":"                 return(COLON);
"("                 return(LB);
")"                 return(RB);
"["                 return(LBRACK);
"]"                 return(RBRACK);
"@"                 return(AT);
"|"                 return(OR);
"+"                 return(PLUS);
"-"                 return(MINUS);
";"                 return(SEMICOLON);
","                 return(COMMA);

{Identifier}        YYVAL; return(ID);
{String}            YYVAL; return(STRING);
{DecIntegerLiteral} YYVAL; return(INT);
{FloatLiteral}      YYVAL; return(FLOAT);

{LineTerminator}+   /* throw away */
{WhiteSpace}+       /* throw away */

.                   { yyerror("Illegal character"); return(ERR); }

%%

/*
int main(int argc, char *argv[])
{
    // skip over program name
    ++argv, --argc;

    if (argc > 0)
        yyin = fopen(argv[0], "r");
    else
        yyin = stdin;

    while (yylex() != YY_NULL)
        ;
}
*/
