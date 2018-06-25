CC 		:= gcc
LIBS	:= 
UNAME_S := $(shell uname -s)

EXEC	:= trab5
BASEDIR	:= src
MODULES	:= common/types common/hash common/tree interpreter
SCANNER	:= $(addprefix $(BASEDIR)/,scanner/scanner.l)
PARSER	:= $(addprefix $(BASEDIR)/,parser/parser.y)
OBJS	:= $(addprefix $(BASEDIR)/,$(MODULES))
TESTFILE := c01.cm

ifeq ($(UNAME_S),Linux)
	LIBS += -lfl
endif

ifeq ($(UNAME_S),Darwin)
	LIBS += -ll
endif

all: build

.PHONY: clean

build:
	@bison --debug $(PARSER) && mv parser.h src/includes/parser.h
	@flex $(SCANNER)
	@for dir in $(OBJS); do (cd $$dir > /dev/null; ${MAKE} all > /dev/null); done
	@gcc -o $(EXEC) parser.c scanner.c $(addsuffix /*.o, $(OBJS)) $(LIBS) --std=c99 -g
	@rm -f scanner.c parser.c includes/parser.h

dot: build
	./trab4 < tests/trab3/in/$(TESTFILE)
	dot -Tpdf tree.dot -o tree.pdf
	open tree.pdf

clean:
	@for dir in $(OBJS); do (cd $$dir; rm -f *.o;); done
	@rm -f src/includes/parser.h parser.c scanner.c trab1 trab2 trab3 trab4
	