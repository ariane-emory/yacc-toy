UNAME_S      = $(shell uname -s)

YACC_LEX_CFLAGS = \
	-ggdb \
	-Iinclude \
	-I. \
	-Wno-implicit-int \
	-Wno-implicit-function-declaration \
	-Wno-address-of-packed-member \
	-DNIL_IS_IMPLICIT

STRICTER_CFLAGS = \
  -ggdb \
	-Iinclude \
	-I. \
	-I3p/acutest/include/ \
	-Werror \
	-Wall \
	-Wextra \
	-Wshadow \
	-Wpedantic \
	-Wno-format \
	-Wno-address-of-packed-member \
	-Wno-unused-variable \
	-Wno-unused-but-set-variable \
	-DACUTEST_SPACES=60 \
	-DNIL_IS_IMPLICIT

ifeq ($(UNAME_S),Darwin)
	CXX = g++-13
  CC  = gcc-13
	GDB = lldb
endif

GDB       = gdb
OBJDUMP   = objdump
LEX       = flex
YACC      = bison

SRCS      = $(shell find src  -name "*.c")
TEST_SRCS = $(shell find test -name "*.c")
OBJS      = $(patsubst src/%.c, obj/%.o, $(SRCS))
TEST_BINS = $(patsubst test/%.c, bin/test/%, $(TEST_SRCS))

################################################################################
# Targets
################################################################################

all: bin/ae $(TEST_BINS)

obj/%.o: src/%.c obj
	$(CC) -o $@ $< $(LDFLAGS) $(STRICTER_CFLAGS) -c

################################################################################
# Executables
################################################################################

bin/test/%: bin/test
	$(CC) -o $@_implicit   $(patsubst bin/test/%, test/%.c, $@) $(OBJS) $(LDFLAGS) $(STRICTER_CFLAGS)
	$(CC) -o $@_interned   $(patsubst bin/test/%, test/%.c, $@) $(OBJS) $(LDFLAGS) $(STRICTER_CFLAGS) -UNIL_IS_IMPLICIT -DNIL_IS_AN_INTERNED_SYMBOL
	$(CC) -o $@_uninterned $(patsubst bin/test/%, test/%.c, $@) $(OBJS) $(LDFLAGS) $(STRICTER_CFLAGS) -UNIL_IS_IMPLICIT -DNIL_IS_AN_UNINTERNED_SYMBOL

bin/ae: tmp/ae.lex.c tmp/ae.tab.c $(OBJS)
	mkdir -p ./bin
	$(CC) -o $@ $^ $(LDFLAGS) $(YACC_LEX_CFLAGS)

################################################################################
# Lexer/parser
################################################################################

tmp/%.lex.c: grammar/%.lex tmp/%.tab.c tmp
	$(LEX) -o $@ $<

tmp/%.lex.c: grammar/%.lex tmp
	$(LEX) -o $@ $<

tmp/%.tab.c: grammar/%.yacc tmp
	$(YACC) -d $< -o $@

################################################################################
# Directories
################################################################################

tmp:
	mkdir -p $@

obj:
	mkdir -p $@

bin:
	mkdir -p $@

bin/test:
	mkdir -p $@

################################################################################
# Utility targets
################################################################################

tests: clean all
	./bin/ae
	$(foreach bin, $(TEST_BINS), echo; $(bin)_implicit)
	$(foreach bin, $(TEST_BINS), echo; $(bin)_interned)
	$(foreach bin, $(TEST_BINS), echo; $(bin)_uninterned)

debug: clean all
	$(GDB) ./bin/ae

################################################################################
# Clean
################################################################################

clean:
	rm -rf bin obj tmp

