SHELL        = bash
UNAME_S      = $(shell uname -s)
SRCS         = $(shell find src  -name "*.c" -a -not -name "main.c" -a -not -name "repl.c")
TEST_SRCS    = $(shell find test -name "*.c")
OBJS         = $(patsubst src/%.c, obj/%.o, $(SRCS))
TEST_BINS    = $(patsubst test/%.c, bin/%-test, $(TEST_SRCS))
INCLUDE_DIRS = $(foreach dir, $(shell find include -type d) 3p/bestline, -I$(dir) -Itmp) 
POOL_SIZE   := $(shell echo "$$(( 1 << 24))" )

COMMON_CFLAGS = \
	$(INCLUDE_DIRS) \
	-ggdb \
	-O3 \
	-Wno-misleading-indentation \
	-DAE_OBJ_POOL_SIZE=$(POOL_SIZE) \
	-DAE_DEADLY_MARGIN \
	-DAE_DEBUG_OBJ \

UNUSED_CFLAGS = \
	-DAE_DUMP_SYMS \
	-DAE_LOG_ALLOC \
	-DAE_LOG_CLONE \
	-DAE_LOG_CONS \
	-DAE_LOG_ENV \
	-DAE_LOG_FREE_LIST \
	-DAE_LOG_INIT \
	-DAE_LOG_KVP_SET_GET \
	-DAE_LOG_LEX \
	-DAE_LOG_METADATA \
	-DAE_LOG_MOVE \
	-DAE_LOG_PARSE \
	-DAE_LOG_PUSH \
	-DAE_LOG_SYM \
	-DAE_DUMP_POOL_AFTER \
	-DAE_DUMP_POOL_BEFORE \
	-DAE_NO_SINGLE_SYM_PARAMS \
	-DAE_PAINT_EARLY_OBJECTS \
	-DAE_PREFACE \
	-DAE_PREFER_ALIST \
	-DAE_TRACK_ORIGINS_DURING_EVAL \

TEST_CFLAGS = \
	-Wno-unused-value

BIN_CFLAGS = \

YACC_LEX_CFLAGS = \
	-Wno-implicit-int \
	-Wno-implicit-function-declaration \
	-Wno-address-of-packed-member

STRICTER_CFLAGS = \
	-I3p/acutest/include/ \
	-Werror \
	-Wall \
	-Wextra \
	-Wno-format \
	-Wno-comment \
	-Wno-address-of-packed-member \
	-Wno-unused-variable \
	-Wno-unused-but-set-variable \
	-DACUTEST_SPACES=80 \
	-DACUTEST_IGNORE_EXIT

ifeq ($(UNAME_S),Darwin)
	CXX = g++-13
  CC  = gcc-13
	GDB = lldb
endif

GDB       = gdb
OBJDUMP   = objdump
LEX       = flex
YACC      = /opt/homebrew/opt/bison/bin/bison

ifeq ($(wildcard /opt/homebrew/opt/bison/bin/bison),)
    YACC = bison
else
    YACC = /opt/homebrew/opt/bison/bin/bison
endif

################################################################################
# Targets
################################################################################

all: bin/ae bin/repl $(TEST_BINS) bin/repl

obj/bestline.o:
	$(CC) -o $@ 3p/bestline/bestline.c $(COMMON_CFLAGS) $(STRICTER_CFLAGS) -c

obj/%.o: src/%.c obj obj/core obj/test
	$(CC) -o $@ $< $(LDFLAGS) $(COMMON_CFLAGS) $(STRICTER_CFLAGS) -c

################################################################################
# Executables
################################################################################

bin/%-test: $(OBJS)
	mkdir -p bin
	$(CC) -o $@ $^ $(LDFLAGS) $(COMMON_CFLAGS) $(STRICTER_CFLAGS) $(TEST_CFLAGS) $(patsubst bin/%-test, test/%.c, $@) 

bin/ae: tmp/ae.l.c tmp/ae.tab.c $(OBJS) src/main.c
	mkdir -p bin
	$(CC) -o $@ $^ $(LDFLAGS) $(COMMON_CFLAGS) $(YACC_LEX_CFLAGS) $(BIN_CFLAGS)

bin/repl: tmp/ae.l.c tmp/ae.tab.c $(OBJS) src/repl.c obj/bestline.o
	mkdir -p bin
	$(CC) -o $@ $^ $(LDFLAGS) $(COMMON_CFLAGS) $(YACC_LEX_CFLAGS) $(BIN_CFLAGS)

################################################################################
# Lexer/parser
################################################################################

tmp/%.lex.c: grammar/%.l tmp/%.tab.c tmp
	$(LEX) -o $@ $<

tmp/%.l.c: grammar/%.l tmp
	$(LEX) -o $@ $<

tmp/%.tab.c: grammar/%.y tmp
	$(YACC) -d $< -o $@

################################################################################
# Directories
################################################################################

tmp:
	mkdir -p $@

obj:
	mkdir -p $@

obj/core:
	mkdir -p $@

obj/test:
	mkdir -p $@

bin:
	mkdir -p $@

#bin/test:
#	mkdir -p $@

################################################################################
# Utility targets
################################################################################

tests: clean all
#	$(foreach bin, $(TEST_BINS), $(bin))
	./bin/ae

debug: clean all
	$(GDB) ./bin/ae

################################################################################
# Clean
################################################################################

clean:
	rm -rf bin obj tmp

