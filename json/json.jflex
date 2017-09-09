package org.texacker.parser.cup.json;

import java_cup.runtime.Symbol;
import java_cup.runtime.SymbolFactory;
%%
%class json_lexer
%cupsym json_sym
%unicode
%cup
%line
%column
%{
        public json_lexer(java.io.InputStream r, SymbolFactory sf)
        {
                this(r);
                this.sf = sf;
        }

        private SymbolFactory sf;
        private StringBuffer string = new StringBuffer();
%}
%eofval{
        return sf.newSymbol("EOF", json_sym.EOF);
%eofval}

LineTerminator    = \r|\n|\r\n
WhiteSpace        = {LineTerminator} | [ \t\f]

/* integer literals */
DecIntegerLiteral = 0 | [1-9][0-9]*
DecLongLiteral    = {DecIntegerLiteral} [lL]

HexIntegerLiteral = 0 [xX] 0* {HexDigit} {1,8}
HexLongLiteral    = 0 [xX] 0* {HexDigit} {1,16} [lL]
HexDigit          = [0-9a-fA-F]

OctIntegerLiteral = 0+ [1-3]? {OctDigit} {1,15}
OctLongLiteral    = 0+ 1? {OctDigit} {1,21} [lL]
OctDigit          = [0-7]

/* floating point literals */
FloatLiteral  = ({FLit1}|{FLit2}|{FLit3}) {Exponent}? [fF]
DoubleLiteral = ({FLit1}|{FLit2}|{FLit3}) {Exponent}?

FLit1    = [0-9]+ \. [0-9]*
FLit2    = \. [0-9]+
FLit3    = [0-9]+
Exponent = [eE] [+-]? [0-9]+

/* string and character literals */
StringCharacter = [^\r\n\"\\]

%state STRING

%%

<YYINITIAL> {

  "true"                         { return sf.newSymbol("", json_sym.TRUE); }
  "false"                        { return sf.newSymbol("", json_sym.FALSE); }
  "null"                         { return sf.newSymbol("", json_sym.NULL); }


/*{DecIntegerLiteral}            { return sf.newSymbol("", json_sym.INTEGER, new Integer(yytext())); }*/
  {DoubleLiteral}                { return sf.newSymbol("", json_sym.NUMBER, new Double(yytext())); }

  /* whitespace */
  {WhiteSpace}                   { /* ignore */ }

  "{"                            { return sf.newSymbol("", json_sym.LBRACE); }
  "}"                            { return sf.newSymbol("", json_sym.RBRACE); }
  "["                            { return sf.newSymbol("", json_sym.LBRACK); }
  "]"                            { return sf.newSymbol("", json_sym.RBRACK); }
  ","                            { return sf.newSymbol("", json_sym.COMMA); }
  ":"                            { return sf.newSymbol("", json_sym.COLON); }

  \"                             { yybegin(STRING); string.setLength(0); }
}

<STRING> {
  \"                             { yybegin(YYINITIAL); return sf.newSymbol("", json_sym.STRING, new String(string.toString())); }

  {StringCharacter}+             { string.append( yytext() ); }

  /* escape sequences */
  "\\\""                         { string.append('\"'); }
  "\\\\"                         { string.append('\\'); }
  "\\/"                          { string.append('/'); }
  "\\b"                          { string.append('\b'); }
  "\\f"                          { string.append('\f'); }
  "\\n"                          { string.append('\n'); }
  "\\r"                          { string.append('\r'); }
  "\\t"                          { string.append('\t'); }
  \\u{HexDigit}{4}               { char val = (char) Integer.parseInt(yytext().substring(2), 16); string.append(val); }

  /* error cases */
  \\.                            { throw new RuntimeException("Illegal escape sequence \"" + yytext() + "\""); }
  {LineTerminator}               { throw new RuntimeException("Unterminated string at end of line"); }
}

.|\n                             { throw new RuntimeException("Illegal character \"" + yytext() + "\" at line " + yyline + ", column " + yycolumn); }
