VERSION=0.3
CFLAGS = -O2 -I/usr/include/X11 -DVERSION=\"$(VERSION)\"
LFLAGS = -L/usr/lib/X11 -lXtst -lX11

#~ all: xmacroplay xmacrorec xmacrorec2

all: xmrec xmplay

xmrec: xmrec.c
	gcc $(CFLAGS) xmrec.c -o xmrec $(LFLAGS)


xmplay: xmplay.c #chartbl.h
	gcc $(CFLAGS) xmplay.c -o xmplay $(LFLAGS)

xmacroplay: xmacroplay.cpp chartbl.h
	g++ -O2  $(CFLAGS) xmacroplay.cpp -o xmacroplay $(LFLAGS)

xmacrorec: xmacrorec.cpp
	g++ -O2 $(CFLAGS) -I/usr/X11R6/include -DVERSION=$(VERSION) xmacrorec.cpp -o xmacrorec -L/usr/X11R6/lib -lXtst -lX11

xmacrorec2: xmacrorec2.cpp
	g++ -O2 $(CFLAGS)  -I/usr/X11R6/include -DVERSION=$(VERSION) xmacrorec2.cpp -o xmacrorec2 -L/usr/X11R6/lib -lXtst -lX11

clean:
	rm xmacrorec xmacroplay xmacrorec2

deb:
	umask 022 && epm -f deb -nsm xmacro

rpm:
	umask 022 && epm -f rpm -nsm xmacro
