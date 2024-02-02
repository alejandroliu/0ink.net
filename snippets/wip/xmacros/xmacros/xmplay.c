/*****************************************************************************
 *
 * xmacroplay - a utility for playing X mouse and key events.
 * Portions Copyright (C) 2000 Gabor Keresztfalvi <keresztg@mail.com>
 *
 * The recorded events are read from the standard input.
 *
 * This program is heavily based on
 * xremote (http://infa.abo.fi/~chakie/xremote/) which is:
 * Copyright (C) 2000 Jan Ekholm <chakie@infa.abo.fi>
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation; either version 2 of the License, or (at your
 * option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
 * for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 ****************************************************************************/

/*****************************************************************************
 * Includes
 ****************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <ctype.h>
#include <X11/Xlibint.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/cursorfont.h>
#include <X11/keysymdef.h>
#include <X11/keysym.h>
#include <X11/extensions/XTest.h>
#include <stdio.h>
#include <ctype.h>

//~ #include "chartbl.h"

#define PROG "xmplay"

/*****************************************************************************
 * The delay in milliseconds when sending events to the remote display
 ****************************************************************************/
const int DefaultDelay = 10;

/*****************************************************************************
 * The multiplier used fot scaling coordinates before sending them to the
 * remote display. By default we don't scale at all
 ****************************************************************************/
const float DefaultScale = 1.0;

/*****************************************************************************
 * Globals...
 ****************************************************************************/
int   Delay = DefaultDelay;
float Scale = DefaultScale;
char * Remote;

/****************************************************************************/
/*! Prints the usage, i.e. how the program is used. Exits the application with
    the passed exit-code.

	\arg const int ExitCode - the exitcode to use for exiting.
*/
/****************************************************************************/
void usage (const int exitCode) {

  // print the usage
  fputs(PROG,stderr);
  fputs(" ",stderr);
  fputs(VERSION,stderr);
  fputs("\n",stderr);

  fputs("Usage: ", stderr);
  fputs(PROG, stderr);
  fputs(" [options] remote_display\n\n", stderr);

  fputs("Options: \n", stderr);
  fputs("  -d  DELAY   delay in milliseconds for events sent to remote display.\n", stderr);
  fputs("              Default: 10ms.\n", stderr);
  fputs("  -s  FACTOR  scalefactor for coordinates. Default: 1.0.\n", stderr);
  fputs("  -v          show version.\n", stderr);
  fputs("  -h          this help. \n\n", stderr);

  // we're done
  exit ( EXIT_SUCCESS );
}

/****************************************************************************/
/*! Prints the version of the application and exits.
*/
/****************************************************************************/
void version () {

  // print the version
  fputs(PROG,stderr);
  fputs(" ",stderr);
  fputs(VERSION,stderr);
  fputs("\n",stderr);

  // we're done
  exit ( EXIT_SUCCESS );
}


/****************************************************************************/
/*! Parses the commandline and stores all data in globals (shudder). Exits
    the application with a failed exitcode if a parameter is illegal.

	\arg int argc - number of commandline arguments.
	\arg char * argv[] - vector of the commandline argument strings.
*/
/****************************************************************************/
void parseCommandLine (int argc, char * argv[]) {

  int Index = 1;

  // check the number of arguments
  if ( argc < 2 ) {
	// oops, too few arguments, go away
	usage ( EXIT_FAILURE );
  }

  // loop through all arguments except the last, which is assumed to be the
  // name of the display
  while ( Index < argc ) {

	// is this '-v'?
	if ( strcmp (argv[Index], "-v" ) == 0 ) {
	  // yep, show version and exit
	  version ();
	}

	// is this '-h'?
	if ( strcmp (argv[Index], "-h" ) == 0 ) {
	  // yep, show usage and exit
	  usage ( EXIT_SUCCESS );
	}

	// is this '-d'?
	else if ( strcmp (argv[Index], "-d" ) == 0 && Index + 1 < argc ) {
	  // yep, and there seems to be a parameter too, interpret it as a
	  // number
	  if ( sscanf ( argv[Index + 1], "%d", &Delay ) != 1 ) {
		// oops, not a valid intereger
		fputs("Invalid parameter for '-d'.\n",stderr);
		usage ( EXIT_FAILURE );
	  }

	  Index++;
	}

	// is this '-s'?
	else if ( strcmp (argv[Index], "-s" ) == 0 && Index + 1 < argc ) {
	  // yep, and there seems to be a parameter too, interpret it as a
	  // floating point number
	  if ( sscanf ( argv[Index + 1], "%f", &Scale ) != 1 ) {
		// oops, not a valid intereger
		fputs("Invalid parameter for '-s'.\n", stderr);
		usage ( EXIT_FAILURE );
	  }

	  Index++;
	}

	// is this the last parameter?
	else if ( Index == argc - 1 ) {
	  // yep, we assume it's the display, store it
	  Remote = argv [ Index ];
	}

	else {
	  // we got this far, the parameter is no good...
	  fputs("Invalid parameter '",stderr);
	  fputs(argv[Index], stderr);
	  fputs(".\n", stderr);
	  usage ( EXIT_FAILURE );
	}

	// next value
	Index++;
  }
}

/****************************************************************************/
/*! Connects to the desired display. Returns the \c Display or \c 0 if
    no display could be obtained.

	\arg const char * DisplayName - name of the remote display.
*/
/****************************************************************************/
Display * remoteDisplay (const char * DisplayName) {

  int Event, Error;
  int Major, Minor;

  // open the display
  Display * D = XOpenDisplay ( DisplayName );

  // did we get it?
  if ( ! D ) {
	// nope, so show error and abort
	fputs(PROG, stderr);
	fputs(": could not open display \"", stderr);
	fputs(XDisplayName ( DisplayName ), stderr);
	fputs("\", aborting.\n", stderr);
	exit ( EXIT_FAILURE );
  }

  // does the remote display have the Xtest-extension?
  if ( ! XTestQueryExtension (D, &Event, &Error, &Major, &Minor ) ) {
	// nope, extension not supported
	fputs(PROG, stderr);
	fputs(": XTest extension not supported on server \"", stderr);
	fputs( DisplayString(D) ,stderr);
	fputs("\"\n",stderr);

	// close the display and go away
	XCloseDisplay ( D );
	exit ( EXIT_FAILURE );
  }

  // print some information
  fputs("XTest for server \"", stderr);
  fputs(DisplayString(D), stderr);
  fputs("\" is version ", stderr);
  fprintf(stderr, "%d.%d.\n\n", Major, Minor);

  // execute requests even if server is grabbed
  XTestGrabControl ( D, True );

  // sync the server
  XSync ( D,True );

  // return the display
  return D;
}

/****************************************************************************/
/*! Scales the passed coordinate with the given saling factor. the factor is
    either given as a commandline argument or it is 1.0.
*/
/****************************************************************************/
int scale (const int Coordinate) {

  // perform the scaling, all in one ugly line
  return (int)( (float)Coordinate * Scale );
}

char *skipSpace(char *p) {
  while (*p && isspace(*p)) p++;
  return p;
}
int getDigit(char *p, char **res) {
  int c = 0, mult = 1;
  if (*p == '-') {
    mult = -1;
    p++;
  }
  while (*p && isdigit(*p)) {
    c = c*10 + *p-'0';
    p++;
  }
  if (res) {
    *res = skipSpace(p);
  }
  return c * mult;
}
char *getToken(char *p, char **res) {
  char *x = p;
  while (*p && !isspace(*p)) p++;
  if (*p && isspace(*p)) *(p++) = 0;
  if (res) {
    *res = skipSpace(p);
  }
  return x;
}

int _startswith(char *k,char *s,int l) {
  if (!strncasecmp(k,s,l-1) && (isspace(s[l-1]) || s[l-1] == 0)) {
    int p = l-1;
    while (s[p] != 0 && isspace(s[p])) p++;
    return p;
  }
  return 0;
}
#define startswith(k, s) _startswith(k,s,sizeof(k))

/****************************************************************************/
/*! Main event-loop of the application. Loops until a key with the keycode
    \a QuitKey is pressed. Sends all mouse- and key-events to the remote
	display.

    \arg Display * RemoteDpy - used display.
	\arg int RemoteScreen - the used screen.
*/
/****************************************************************************/
void eventLoop (Display * RemoteDpy, int RemoteScreen) {

  char ev[1024],  *p;
  int x, y;
  unsigned int b, off;
  KeySym ks;
  KeyCode kc;

  while ( !feof(stdin) ) {
	fgets(ev, sizeof ev, stdin);
	ev[(sizeof ev)-1] = 0;
	p = skipSpace(ev);

	if (p[0] =='#')
	{
	  fputs( "Comment: ", stdout);
	  fputs(ev, stdout);
	  fputs("\n", stdout);
	  continue;
	}
	if ((off = startswith("Delay",p)) != 0) {
	  b = getDigit(p+off, NULL);
	  printf("Delay: %d\n", b);
	  sleep ( b );
	}
	else if ((off = startswith("ButtonPress",p)) != 0) {
	  b = getDigit(p+off, NULL);
	  printf("ButtonPress: %d\n", b);
	  XTestFakeButtonEvent ( RemoteDpy, b, True, Delay );
	}
	else if ((off = startswith("ButtonRelease",p)) != 0) {
	  b = getDigit(p+off, NULL);
	  printf("ButtonRelease: %d\n", b);
	  XTestFakeButtonEvent ( RemoteDpy, b, False, Delay );
	}
	else if ((off = startswith("MotionNotify",p)) != 0) {
	  x = getDigit(p+off,&p);
	  y = getDigit(p, NULL);
	  printf("MotionNotify: %d %d\n", x, y);
	  XTestFakeMotionEvent ( RemoteDpy, RemoteScreen , scale ( x ), scale ( y ), Delay );
	}
	else if ((off = startswith("KeyCodePress",p)) != 0) {
	  kc = getDigit(p+off, NULL);
	  printf("KeyPress: %d\n", kc);
	  XTestFakeKeyEvent ( RemoteDpy, kc, True, Delay );
	}
	else if ((off = startswith("KeyCodeRelease",p)) != 0) {
	  kc = getDigit(p+off, NULL);
	  printf("KeyRelease: %d\n", kc);
  	  XTestFakeKeyEvent ( RemoteDpy, kc, False, Delay );
	}
	else if ((off = startswith("KeySym",p)) != 0) {
	  ks = getDigit(p+off, NULL);
	  printf("KeySym: %d\n", ks);

	  if ( ( kc = XKeysymToKeycode ( RemoteDpy, ks ) ) == 0 )
	  {
	    fprintf(stderr, "No keycode on remote display found for keysym: %d\n", ks);
	    continue;
	  }
	  XTestFakeKeyEvent ( RemoteDpy, kc, True, Delay );
	  XFlush ( RemoteDpy );
	  XTestFakeKeyEvent ( RemoteDpy, kc, False, Delay );
	}
	else if ((off = startswith("KeySymPress",p)) != 0) {
	  ks = getDigit(p+off, NULL);
	  printf("KeySymPress: %d\n", ks);
	  if ( ( kc = XKeysymToKeycode ( RemoteDpy, ks ) ) == 0 )
	  {
	    fprintf(stderr, "No keycode on remote display found for keysym: %d\n", ks);
	    continue;
	  }
	  XTestFakeKeyEvent ( RemoteDpy, kc, True, Delay );
	}
	else if ((off = startswith("KeySymRelease",p)) != 0) {
	  ks = getDigit(p+off, NULL);
	  printf("KeySymRelease: %d\n", ks);
	  if ( ( kc = XKeysymToKeycode ( RemoteDpy, ks ) ) == 0 )
	  {
	    fprintf(stderr, "No keycode on remote display found for keysym: %d\n", ks);
	    continue;
	  }
  	  XTestFakeKeyEvent ( RemoteDpy, kc, False, Delay );
	}
	else if ((off = startswith("KeyStr",p)) != 0) {
	  p = getToken(p+off, NULL);
	  printf("KeyStr: %s\n", p);
	  ks=XStringToKeysym(p);
	  if ( ( kc = XKeysymToKeycode ( RemoteDpy, ks ) ) == 0 )
	  {
	    fprintf(stderr, "No keycode on remote display found for '%s'\n", p);
	    continue;
	  }
	  XTestFakeKeyEvent ( RemoteDpy, kc, True, Delay );
	  XFlush ( RemoteDpy );
	  XTestFakeKeyEvent ( RemoteDpy, kc, False, Delay );
	}
	else if ((off = startswith("KeyStrPress",p)) != 0) {
	  p = getToken(p+off, NULL);
	  printf("KeyStrPress: %s\n", p);
	  ks=XStringToKeysym(p);
	  //~ fprintf(stderr, "Fakey: %s=> %d\n", p, ks);
	  if ( ( kc = XKeysymToKeycode ( RemoteDpy, ks ) ) == 0 )
	  {
	    fprintf(stderr, "No keycode on remote display found for '%s'\n", p);
	    continue;
	  }
	  fprintf(stderr, "Fakey: %d\n", kc);
	  XTestFakeKeyEvent ( RemoteDpy, kc, True, Delay );
	}
	else if ((off = startswith("KeyStrRelease",p)) != 0) {
	  p = getToken(p+off, NULL);
	  printf("KeyStrRelease: %s\n", p);
	  ks=XStringToKeysym(p);
	  if ( ( kc = XKeysymToKeycode ( RemoteDpy, ks ) ) == 0 )
	  {
	    fprintf(stderr, "No keycode on remote display found for '%s'\n", p);
	    continue;
	  }
  	  XTestFakeKeyEvent ( RemoteDpy, kc, False, Delay );
	}
	//~ else if (!strcasecmp("String",ev))
	//~ {
	  //~ cin.ignore().get(str,1024);
	  //~ cout << "String: " << str << endl;
	  //~ b=0;
	  //~ while(str[b]) sendChar(RemoteDpy, str[b++]);
	//~ }
	else if (ev[0]!=0) {
	  printf("Unknown tag: %s\n", ev);
	}

	// sync the remote server
	XFlush ( RemoteDpy );
  }
}



/****************************************************************************/
/*! Main function of the application. It expects no commandline arguments.

    \arg int argc - number of commandline arguments.
	\arg char * argv[] - vector of the commandline argument strings.
*/
/****************************************************************************/
int main (int argc, char * argv[]) {
  Display *RemoteDpy;

  // parse commandline arguments
  parseCommandLine ( argc, argv );

  // open the remote display or abort
  RemoteDpy = remoteDisplay ( Remote );

  // get the screens too
  int RemoteScreen = DefaultScreen ( RemoteDpy );

  XTestDiscard ( RemoteDpy );

  // start the main event loop
  eventLoop ( RemoteDpy, RemoteScreen );

  // discard and even flush all events on the remote display
  XTestDiscard ( RemoteDpy );
  XFlush ( RemoteDpy );

  // we're done with the display
  XCloseDisplay ( RemoteDpy );

  fprintf(stderr, "%s : pointer and keyboard released.\n", PROG);

  // go away
  exit ( EXIT_SUCCESS );
}







