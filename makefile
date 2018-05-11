CC 		:= gcc
LIBS	:= 
SOURCES	:= parser.c scanner.c src/common/types/function.c src/common/types/variable.c src/common/types/literal.c src/common/hash.c

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
	@bison --debug src/parser/parser.y && mv parser.h src/includes/parser.h
	@flex src/scanner/scanner.l
	@gcc -o trab3 $(SOURCES) $(LIBS) -g
	@rm -f scanner.c parser.c includes/parser.h

clean:
	@rm -f src/includes/parser.h parser.c scanner-c trab1 trab2 trab3
	