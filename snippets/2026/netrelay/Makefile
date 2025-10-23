PROG = netrelay
SRC = $(PROG).c
CFLAGS = -Os -Wall -s
DEFAULT_CFLAGS=-static -Os -Wall -s
X86_64_CFLAGS=$(DEFAULT_CFLAGS)


help::
	@echo "- help : this message"
	@echo "- default, $(PROG) : compile a native executable"
	@echo "- x86_64 : AMD/INTEL 64-bit executable"
	@echo "- aarch64 : ARM 64-bit executable (requires pkg: cross-aarch64-linux-musl)"
	@echo "- all: Make x86_64 and aarch64"
	@echo "- html : Create HTML documentation"
	@echo "Requires: base-devel"

html:
	doxygen

$(PROG): $(SRC)
	$(CC) $(CFLAGS) $(LFLAGS) -s -o $@ $(SRC)

default: $(PROG)

$(PROG).x86_64: $(SRC)
	if [ $$(uname -m) = "x86_64" ] ; then \
	  $(CC) $(X86_64_CFLAGS) $(SRC) -o $@ ; \
	else \
	  echo "Don't know how to cross-compile" ; \
	  false ; \
	fi

x86_64: $(PROG).x86_64

$(PROG).aarch64: $(SRC)
	if type aarch64-linux-musl-gcc ; then \
	  aarch64-linux-musl-gcc $(DEFAULT_CFLAGS) -o $@ $(SRC) ; \
	else \
	  echo "Install cross-aarch64-linux-musl" ; \
	  false ; \
	fi

aarch64: $(PROG).aarch64

clean:
	rm -f $(PROG).aarch64 $(PROG).x86_64 $(PROG)


all: $(PROG).aarch64 $(PROG).x86_64
