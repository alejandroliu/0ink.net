SRC=com.c
DEFAULT_CFLAGS=-static -Os -Wall -s
X86_64_CFLAGS=$(DEFAULT_CFLAGS)

default: $(SRC)
	$(CC) $(CFLAGS) $(LFLAGS) -s -o com.$$(uname -m) $(SRC)

help::
	@echo "Targets:"
	@echo "- default : compile a native executable"
	@echo "- x86_64 : AMD/INTEL 64-bit executable"
	@echo "- aarch64 : ARM 64-bit executable"
	@echo "- bash : Drop to an interactive shell"


x86_64: $(SRC)
	if [ $$(uname -m) = "x86_64" ] ; then $(CC) $(X86_64_CFLAGS) $(SRC) -o com.$@ ; else echo "Don't know how to cross-compile" ; exit 1 ; fi

aarch64: $(SRC)
	aarch64-linux-musl-gcc $(DEFAULT_CFLAGS) -o com.aarch64 $(SRC)

clean:
	rm -f com.aarch64 com.x86_64 com.$$(uname -m)

bash:
	bash -il

