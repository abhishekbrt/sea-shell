CC = gcc
CFLAGS = -Wall -g
LEX = lex
YACC = yacc

TARGET = out

all: $(TARGET)

$(TARGET): lex.yy.c y.tab.c
	$(CC) $(CFLAGS) lex.yy.c y.tab.c -o $(TARGET)

y.tab.c y.tab.h: shell.y
	$(YACC) -d shell.y

lex.yy.c: shell.l y.tab.h
	$(LEX) shell.l

clean:
	rm -f $(TARGET) y.tab.c y.tab.h lex.yy.c

rebuild: clean all

run: $(TARGET)
	./$(TARGET)

.PHONY: all clean rebuild run
