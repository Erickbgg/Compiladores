CC 		:= gcc
LIBS	:= 
UNAME_S := $(shell uname -s)

EXEC	:= trab3
BASEDIR	:= src
MODULES	:= common/types common/hash common/tree
SCANNER	:= $(addprefix $(BASEDIR)/,scanner/scanner.l)
PARSER	:= $(addprefix $(BASEDIR)/,parser/parser.y)
OBJS	:= $(addprefix $(BASEDIR)/,$(MODULES))

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
	@for dir in $(OBJS); do (cd $$dir > /dev/null; ${MAKE} all); done
	gcc -o $(EXEC) parser.c scanner.c $(addsuffix /*.o, $(OBJS)) $(LIBS) --std=c99
	@rm -f scanner.c parser.c includes/parser.h
	

clean:
	@for dir in $(OBJS); do (cd $$dir; rm -f *.o;); done
	@rm -f src/includes/parser.h parser.c scanner-c trab1 trab2 trab3 trab4
	