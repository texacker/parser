package org.texacker.parser.cup;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.Reader;
import java.io.UnsupportedEncodingException;
import java.util.Stack;

import java_cup.runtime.Symbol;
%%
%class pbxproj_lexer
%cupsym pbxproj_sym
%unicode
%cup
%line
%column
%xstate GCC_PRE_DEF_1 GCC_PRE_DEF_2

%{
    public static final int SINGLE_VALUE = 1;
    public static final int MULTI_VALUE = 2;

    private String zzMacroPattern;
    private String zzMacroAfterExpanded;
    private java.io.Writer zzWriter;

    private void pbx_output(String s)
    {
        if (zzWriter == null)
            System.out.print(s);
        else
            try {
                zzWriter.write(s);
            } catch (IOException e) {
                e.printStackTrace();
            }
    }

    private void pbx_pre_def(int f, String m)
    {
        if (f == SINGLE_VALUE)
        {
            if (m.matches(zzMacroPattern + "[ \\r\\n\\t\\f]*;") || m.matches("\"" + zzMacroPattern + "\""+ "[ \\r\\n\\t\\f]*;"))
                if (zzMacroAfterExpanded.indexOf(",") != -1)
                    pbx_output("( " + zzMacroAfterExpanded + ", );" );
                else
                    pbx_output(zzMacroAfterExpanded + ";" );
            else
                pbx_output(m);
        }
        else if (f == MULTI_VALUE)
        {
            if (m.matches(zzMacroPattern + "[ \\r\\n\\t\\f]*,") || m.matches("\"" + zzMacroPattern + "\"" + "[ \\r\\n\\t\\f]*,"))
                pbx_output(zzMacroAfterExpanded + "," );
            else
                pbx_output(m);
        }
        else
        {
            pbx_output(m);
        }
    }

    public void pbx_parse()
    {
        try {
            Symbol sym = next_token();

            while (sym.sym != pbxproj_sym.EOF)
            {
                sym = next_token();
            }

        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static void main(String args[]) throws Exception
    {
        if (args.length == 3)
        {
            pbxproj_lexer cl = new pbxproj_lexer();

            cl.yyreset(new InputStreamReader(new FileInputStream(new File(args[0])), "UTF-8"),
                    new OutputStreamWriter(new FileOutputStream(new File(args[0] + ".pbx_parser_output")), "UTF-8"));

            cl.yyreset(args[1], args[2]);

//          pbxproj_lexer cl = new pbxproj_lexer(args[0], args[1], args[2]);

//          int[] smallPrimes = { 2, 3, 5, 7, 11, 13 };

//          Symbol sym = cl.next_token();
//          while (sym.sym != pbxproj_sym.EOF)
//          {
//              sym = cl.next_token();
//          }

            cl.pbx_parse();
        }
        else
        {
            System.out.println("Usage: pbxproj_parser pbxproj_file macro_pattern macro_after_expanded");
        }
    }

    pbxproj_lexer()
    {
        yyreset();
    }

    public final void yyreset()
    {
        try {
            if (zzReader != null)
                zzReader.close();

            yyreset(null);

            if (zzWriter != null)
                zzWriter.close();

            zzWriter = null;
        } catch (IOException e) {
            e.printStackTrace();
        }

        zzMacroPattern = null;
        zzMacroAfterExpanded = null;
    }

    public final void yyreset(java.io.Reader in, java.io.Writer out)
    {
        try {
            if (zzReader != null)
                zzReader.close();

            yyreset(in);

            if (zzWriter != null)
                zzWriter.close();

            zzWriter = out;
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public final void yyreset(String p, String e)
    {
        zzMacroPattern = p;
        zzMacroAfterExpanded = e;
    }

    /* end of user code: */
%}

/* main character classes */
LineTerminator = \r|\n|\r\n
InputCharacter = [^\r\n]
WhiteSpace = [ \t\f]
SpaceDelimiter = {LineTerminator} | {WhiteSpace}

/* comments */
Comment = {TraditionalComment} | {EndOfLineComment} | {DocumentationComment}

TraditionalComment = "/*" [^*] ~"*/" | "/*" "*"+ "/"
EndOfLineComment = "//" {InputCharacter}* {LineTerminator}?
DocumentationComment = "/*" "*"+ [^/*] ~"*/"

/* string and character literals */
StringCharacter = [^\r\n\"\\]
SingleCharacter = [^\r\n\'\\]

/* identifiers */
Identifier = ("." | [/_] | [:jletterdigit:])+
String = \" ("\\\"" | {StringCharacter})* \"

rootObject = "rootObject" {SpaceDelimiter}* "=" {SpaceDelimiter}* {Identifier}

pre_def = \" ("_" | [:jletterdigit:])* \" | ("_" | [:jletterdigit:])+

/*pre_def_debug = "_PACKA_MACRO_DEBUG"*/

gcc_pre_def_1_header = "GCC_PREPROCESSOR_DEFINITIONS" {SpaceDelimiter}* "="
gcc_pre_def_2_header = "GCC_PREPROCESSOR_DEFINITIONS" {SpaceDelimiter}* "=" {SpaceDelimiter}* "("

%%

/* separators */
/*
"("         { return new Symbol(pbxproj_sym.LPAREN, yytext()); }
")"         { return new Symbol(pbxproj_sym.RPAREN, yytext()); }
"{"         { return new Symbol(pbxproj_sym.LBRACE, yytext()); }
"}"         { return new Symbol(pbxproj_sym.RBRACE, yytext()); }
";"         { return new Symbol(pbxproj_sym.SEMICOLON, yytext()); }
","         { return new Symbol(pbxproj_sym.COMMA, yytext()); }
*/

/* operators */
/*
"="                 { return new Symbol(pbxproj_sym.EQ, yytext()); }
*/

/* comments */
/*
{Comment}           { }
*/

/* whitespace */
/*
{SpaceDelimiter}    { }
*/

/*
{rootObject}        { return new Symbol(pbxproj_sym.ROOTOBJECT, yytext()); }
*/

/* identifiers */
/*
{Identifier}        { return new Symbol(pbxproj_sym.IDENTIFIER, yytext()); }
*/

/*
{String}            { return new Symbol(pbxproj_sym.STRING_LITERAL, yytext()); }
*/

/* error fallback */
/*
.|\n                { throw new RuntimeException("Illegal character \"" + yytext() + "\" at line " + yyline + ", column " + yycolumn); }
*/

<YYINITIAL> {
    {gcc_pre_def_2_header}                  { pbx_output(yytext()); yybegin(GCC_PRE_DEF_2); }

    {gcc_pre_def_1_header}                  { pbx_output(yytext()); yybegin(GCC_PRE_DEF_1); }

    .|\n                                    { pbx_output(yytext()); }
}

<GCC_PRE_DEF_1> {
/*  {pre_def_debug} {SpaceDelimiter}* ";"   { yybegin(YYINITIAL); pbx_pre_def(); }*/

    {pre_def}? {SpaceDelimiter}* ";"        { yybegin(YYINITIAL); pbx_pre_def(SINGLE_VALUE, yytext()); }

    {SpaceDelimiter}*                       { pbx_output(yytext()); }

    .|\n                                    { System.err.print(yytext()); }
}

<GCC_PRE_DEF_2> {
/*  {pre_def_debug} {SpaceDelimiter}* ","   { pbx_pre_def(); }*/

    {pre_def}? {SpaceDelimiter}* ","        { pbx_pre_def(MULTI_VALUE, yytext()); }

    ")" {SpaceDelimiter}* ";"               { yybegin(YYINITIAL); pbx_output(yytext()); }

    {SpaceDelimiter}*                       { pbx_output(yytext()); }

    .|\n                                    { System.err.print(yytext()); }
}

<<EOF>>                                     { if (zzWriter != null) { zzWriter.flush(); zzWriter.close(); } return new Symbol(pbxproj_sym.EOF); }

/*
Test Cases:

src: GCC_PREPROCESSOR_DEFINITIONS = _PACKA_MACRO_DEBUG;
     GCC_PREPROCESSOR_DEFINITIONS = _PACKA_MACRO_DEBUG_AFTER_EXPANDED;
     GCC_PREPROCESSOR_DEFINITIONS = ( _PACKA_MACRO_DEBUG_AFTER_EXPANDED,_PACKA_MACRO_DEBUG_AFTER_EXPANDED_2, );

src: GCC_PREPROCESSOR_DEFINITIONS = ( _PACKA_MACRO_DEBUG, _DEBUG, );
     GCC_PREPROCESSOR_DEFINITIONS = ( _PACKA_MACRO_DEBUG_AFTER_EXPANDED, _DEBUG, );
     GCC_PREPROCESSOR_DEFINITIONS = ( _PACKA_MACRO_DEBUG_AFTER_EXPANDED,_PACKA_MACRO_DEBUG_AFTER_EXPANDED_2, _DEBUG, );

src: GCC_PREPROCESSOR_DEFINITIONS = ( _PACKA_MACRO_DEBUG, _DEBUG, , );
     GCC_PREPROCESSOR_DEFINITIONS = ( _PACKA_MACRO_DEBUG_AFTER_EXPANDED, _DEBUG, , );
     GCC_PREPROCESSOR_DEFINITIONS = ( _PACKA_MACRO_DEBUG_AFTER_EXPANDED,_PACKA_MACRO_DEBUG_AFTER_EXPANDED_2, _DEBUG, , );
*/
