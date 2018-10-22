CC       = gcc -g
LEX      = flex -i -I
YACC     = bison -d -y -v -t
ALLOCA   =

all: dbc

dbc: dbc.y dbc.lex
	$(YACC) dbc.y
	$(LEX) dbc.lex
	$(CC) -o dbc lex.yy.c y.tab.c $(ALLOCA) -ll -lm

clean:
	rm -f *.BAK *.o core *~* *.a
	rm -f *.tab.h *.tab.c
	rm -f lex.yy.c *.out
	rm -f y.output
	rm -f dbc
