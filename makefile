CC 		:= gcc
LIBS	:= 

UNAME_S := $(shell uname -s)

ifeq ($(UNAME_S),Linux)
	LIBS += -lfl
endif

ifeq ($(UNAME_S),Darwin)
	LIBS += -ll
endif

all: build

.PHONY: clean

build:
	@bison src/parser/parser.y && mv parser.h src/includes/parser.h
	@flex src/scanner/scanner.l
	@gcc -o trab2 parser.c scanner.c $(LIBS)
	@rm -f scanner.c parser.c includes/parser.h

clean:
	@rm -f src/includes/parser.h parser.c scanner-c trab1 trab2
	