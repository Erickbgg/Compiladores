CC 		:= gcc
LIBS	:= -lfl

all: build

.PHONY: clean

build:
	@bison src/parser/parser.y && mv parser.h src/includes/parser.h
	@flex src/scanner/scanner.l
	@gcc -o trab2 parser.c scanner.c $(LIBS)
	@rm -f scanner.c parser.c includes/parser.h

clean:
	@rm -f includes/parser.h parser.c scanner-c trab1 trab2
	