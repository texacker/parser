package org.texacker.parser.cup;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStreamReader;
import java.util.Stack;

import java_cup.runtime.Symbol;
%%
%class sogou_lexer
%cupsym sogou_sym
%unicode
%cup
%line
%column
%state S_DOC, S_URL, S_DOCNO, S_CONTENTTITLE, S_CONTENT

%{
	private Stack<Integer> zzStatusStack = new Stack<Integer>();

	private void yyecho()
	{
		System.err.println(yytext());
	}

	private void yy_push_state(int s)
	{
		zzStatusStack.push(new Integer(yystate()));
		yybegin(s);

		//System.err.println("enter state: " + s);
	}

	private void yy_pop_state()
	{
		int old_state = yystate();

		Object obj = zzStatusStack.pop();

		if ((obj != null) && (obj instanceof Integer))
		{
			Integer s = (Integer)obj;
			yybegin(s.intValue());

			//System.err.println("return to state: " + s.intValue());
		}

		//if ((old_state == S_DOC) && (yystate() == YYINITIAL))
		//{
		//	System.err.println("new doc");
		//}
	}

	public static void main(String args[]) throws Exception
	{
		String f = new String("P:\\founder\\prj\\is\\软件\\sogou\\SogouCS.reduced.utf-8\\news.sohunews.010806.txt");

		sogou_lexer cl = new sogou_lexer(new InputStreamReader(new FileInputStream(new File(f)), "UTF-8"));

		Symbol sym = cl.next_token();
		while (sym.sym != sogou_sym.EOF)
		{
			//System.out.println(sym.toString());

			if (sym.value instanceof String)
			{
				System.out.println((String)sym.value);
			}

			sym = cl.next_token();
		}

		System.out.println("sogou_lexer done.");
	}
%}

tag_doc_s		= "<doc>"
tag_doc_e		= "</doc>"

tag_url_s		= "<url>"
tag_url_e		= "</url>"
tag_docno_s		= "<docno>"
tag_docno_e		= "</docno>"
tag_contenttitle_s	= "<contenttitle>"
tag_contenttitle_e	= "</contenttitle>"
tag_content_s		= "<content>"
tag_content_e		= "</content>"

url			= "http://"
url_site		= [A-Za-z0-9]+ ("." [A-Za-z0-9]+ )*
url_path		= "/" [^\<]+
docno			= [a-z0-9\-]+
contenttitle		= [^\<]+
content			= [^\<]+
cr			= \r|\n|\r\n

%%
<YYINITIAL> {
	{tag_doc_s}		{ yy_push_state(S_DOC); return new Symbol(sogou_sym.TAG_DOC_S); }
}

<S_DOC> {
	{tag_url_s}		{ yy_push_state(S_URL); return new Symbol(sogou_sym.TAG_URL_S); }
	{tag_docno_s}		{ yy_push_state(S_DOCNO); return new Symbol(sogou_sym.TAG_DOCNO_S); }
	{tag_contenttitle_s}	{ yy_push_state(S_CONTENTTITLE); return new Symbol(sogou_sym.TAG_CONTENTTITLE_S); }
	{tag_content_s}		{ yy_push_state(S_CONTENT); return new Symbol(sogou_sym.TAG_CONTENT_S); }

	{tag_doc_e}		{ yy_pop_state(); return new Symbol(sogou_sym.TAG_DOC_E); }
}

<S_URL> {
	{url}			{ return new Symbol(sogou_sym.URL, (Object)yytext()); }
	{url_site}		{ return new Symbol(sogou_sym.URL_SITE, (Object)yytext()); }
	{url_path}		{ return new Symbol(sogou_sym.URL_PATH, (Object)yytext()); }

	{tag_url_e}		{ yy_pop_state(); return new Symbol(sogou_sym.TAG_URL_E); }
}

<S_DOCNO> {
	{docno}			{ return new Symbol(sogou_sym.DOCNO, (Object)yytext()); }

	{tag_docno_e}		{ yy_pop_state(); return new Symbol(sogou_sym.TAG_DOCNO_E); }
}

<S_CONTENTTITLE> {
	{contenttitle}		{ return new Symbol(sogou_sym.CONTENTTITLE, (Object)yytext()); }

	{tag_contenttitle_e}	{ yy_pop_state(); return new Symbol(sogou_sym.TAG_CONTENTTITLE_E); }
}

<S_CONTENT> {
	{content}		{ return new Symbol(sogou_sym.CONTENT, (Object)yytext()); }

	{tag_content_e}		{ yy_pop_state(); return new Symbol(sogou_sym.TAG_CONTENT_E); }
}

{cr}|.				{ /*System.err.println("Illegal character: " + yytext());*/ }