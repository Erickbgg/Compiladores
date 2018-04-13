CC 		:= gcc
LIBS	:= -lfl

all: build

.PHONY: clean

build:
	@flex src/scanner/scanner.l
	@gcc -o trab1 scanner.c -lfl
	@rm -rf scanner.c
