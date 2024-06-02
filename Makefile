all: compiler

install:
	pip3 install pygame

compiler: lex.yy.c y.tab.c
	gcc lex.yy.c y.tab.c -o tetris

lex.yy.c: lexer.l
	flex lexer.l

y.tab.c: parser.y
	bison -dy -v parser.y

test1:
	./tetris code1.tetris

test2:
	./tetris code2.tetris
	python3 code2.py

test3:
	./tetris code3.tetris
	python3 code3.py


clean:
	rm -f lex.yy.c y.tab.c y.tab.h ./tetris y.output code1.py code2.py code3.py
