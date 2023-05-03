/*****************************************************************************
 *
 * xmacrorec - a utility for recording X mouse and key events.
 * Portions Copyright (C) 2000 Gabor Keresztfalvi <keresztg@mail.com>
 *
 * The recorded events are emitted to the standard output and can be played
 * with the xmacroplay utility.
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
 *
 ****************************************************************************/

/*****************************************************************************
 * Do we have config.h?
 ****************************************************************************/

/*****************************************************************************
 * Includes
 ****************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <X11/Xlibint.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/cursorfont.h>
#include <X11/keysymdef.h>
#include <X11/keysym.h>
#include <X11/extensions/XTest.h>
#include <stdio.h>

#define PROG "xmrec"

typedef int bool;
const bool false = 0;
const bool true = !false;
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

/*****************************************************************************
 * Key used for quitting the application.
 ****************************************************************************/
unsigned int QuitKey;
bool HasQuitKey = false;

/****************************************************************************/
/*! Prints the usage, i.e. how the program is used. Exits the application with
    the passed exit-code.

	\arg const int ExitCode - the exitcode to use for exiting.
*/
/****************************************************************************/
void usage (const int exitCode) {

  // print the usage
  fprintf(stderr, "%s %s\n", PROG, VERSION);
  fprintf(stderr, "Usage: %s [options] remote_display\n", PROG);
  fputs("Options:\n", stderr);
  fputs("  -d  DELAY   delay in milliseconds for events sent to remote display.\n", stderr);
  fputs("              Default: 10ms.\n", stderr);
  fputs("  -s  FACTOR  scalefactor for coordinates. Default: 1.0.\n", stderr);
  fputs("  -k  KEYCODE the keycode for the key used for quitting.\n", stderr);
  fputs("  -v          show version. \n", stderr);
  fputs("  -h          this help.\n\n", stderr);

  // we're done
  exit ( EXIT_SUCCESS );
}


/****************************************************************************/
/*! Prints the version of the application and exits.
*/
/****************************************************************************/
void version () {

  // print the version
  fprintf(stderr, "%s %s\n", PROG, VERSION);

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
		fputs("Invalid parameter for '-d'.\n", stderr);
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

    // is this '-k'?
	else if ( strcmp (argv[Index], "-k" ) == 0 && Index + 1 < argc ) {
	  // yep, and there seems to be a parameter too, interpret it as a
	  // number
	  if ( sscanf ( argv[Index + 1], "%d", &QuitKey ) != 1 ) {
		// oops, not a valid integer
		fprintf(stderr, "Invalid parameter for '-k'.\n   %d\n", QuitKey);
		usage ( EXIT_FAILURE );
	  }

	  // now we have a key for quitting
	  HasQuitKey = true;
	  Index++;
    }

	// is this the last parameter?
	else if ( Index == argc - 1 ) {
	  // yep, we assume it's the display, store it
	  Remote = argv [ Index ];
	}

	else {
	  // we got this far, the parameter is no good...
	  fprintf(stderr,  "Invalid parameter '%s'.\n", argv[Index]);
	  usage ( EXIT_FAILURE );
	}

	// next value
	Index++;
  }
}


/****************************************************************************/
/*! Connects to the local display. Returns the \c Display or \c 0 if
    no display could be obtained.
*/
/****************************************************************************/
Display * localDisplay () {

  // open the display
  Display * D = XOpenDisplay ( 0 );

  // did we get it?
  if ( ! D ) {
	// nope, so show error and abort
	fprintf(stderr, "%s: could not open display \"%s\", aborting.\n",
			PROG, XDisplayName ( 0 ));
	exit ( EXIT_FAILURE );
  }

  // return the display
  return D;
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
	fprintf(stderr,"%s: could not open display \"%s\", aborting.\n",
		  PROG,XDisplayName ( DisplayName ) );
	exit ( EXIT_FAILURE );
  }

  // does the remote display have the Xtest-extension?
  if ( ! XTestQueryExtension (D, &Event, &Error, &Major, &Minor ) ) {
	// nope, extension not supported
	fprintf(stderr, "%s: XTest extension not supported on server \"%s\"\n",
		PROG,DisplayString(D));
	// close the display and go away
	XCloseDisplay ( D );
	exit ( EXIT_FAILURE );
  }

  // print some information
  fprintf(stderr, "XTest for server \"%s\" is version %d.%d.\n\n",
		DisplayString(D), Major, Minor);

  // execute requests even if server is grabbed
  XTestGrabControl ( D, True );

  // sync the server
  XSync ( D,True );

  // return the display
  return D;
}


/****************************************************************************/
/*! Function that finds out the key the user wishes to use for quitting the
    application. This must be configurable, as a suitable key is not always
	possible to determine in advance. By letting the user pick a key one that
	does not interfere with the needed applications can be chosen.

	The function grabs the keyboard and waits for a key to be pressed. Returns
	the keycode of the pressed key.

    \arg Display * Dpy - used display.
	\arg int Screen - the used screen.
*/
/****************************************************************************/
int findQuitKey (Display * Dpy, int Screen) {

  XEvent    Event;
  XKeyEvent EKey;
  Window    Target, Root;
  bool      Loop = true;
  int       Error;

  // get the root window and set default target
  Root   = RootWindow ( Dpy, Screen );
  Target = None;

  // grab the keyboard
  Error = XGrabKeyboard ( Dpy, Root, False, GrabModeSync, GrabModeAsync, CurrentTime );

  // did we succeed in grabbing the keyboard?
  if ( Error != GrabSuccess) {
	// nope, abort
	fputs("Could not grab the keyboard, aborting.\n", stderr);
	exit ( EXIT_FAILURE );
  }

  // print a message to the user informing about what's going on
  fputs("\n"
	"Press the key you want to use to end the application. \n"
	"This key can be any key,\n"
	"as long as you don't need it while working with the remote display.\n"
	"A good choice is Escape.\n\n", stderr);

  // let the user select a window...
  while ( Loop ) {
    // allow one more event
	XAllowEvents ( Dpy, SyncPointer, CurrentTime);
    XWindowEvent ( Dpy, Root, KeyPressMask, &Event);

	// what did we get?
    if ( Event.type == KeyPress ) {
	  // a key was pressed, don't loop more
	  EKey = Event.xkey;
	  Loop = false;
	}
  }

  // we're done with pointer and keyboard
  XUngrabPointer  ( Dpy, CurrentTime );
  XUngrabKeyboard ( Dpy, CurrentTime );

  // show the user what was chosen
  fprintf(stderr, "The chosen quit-key has the keycode: %d\n",
		EKey.keycode);

  // return the found key
  return EKey.keycode;
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


/****************************************************************************/
/*! Returns the KeySym of the key code in the XKeyEvent struct.

    \arg XKeyEvent * ev - The struct which contains the key code.
*/
/****************************************************************************/
KeySym getKeySym(XKeyEvent *ev)
{
  KeySym KS;
  char Buffer [64];

  XLookupString ( ev, Buffer, 64, &KS, 0 );
  return(KS);
}

/****************************************************************************/
/*! Sends the key \a Code to the remote display \a RemoteDpy. The keycode is
    converted to a \c KeySym on the local display and then reconverted to
	a \c KeyCode on the remote display. Seems to work quite ok, apart from
	something weird with the Alt key.

    \arg Display * LocalDpy - used display.
	\arg Display * RemoteDpy - used display.
	\arg const unsigned int Code - keycode of pressed key.
	\arg bool Pressed - true if it is a keypress event, false if a keyrelease.
*/
/****************************************************************************/
void sendKey (XKeyEvent * Event, Display * LocalDpy, Display * RemoteDpy,
			  const unsigned int Code, bool Pressed) {

  KeySym KS;
  char Buffer [64];
  KeyCode RemoteKeyCode;

  // perform lookup of the keycode
  XLookupString ( Event, Buffer, 64, &KS, 0 );

  // convert it to a keycode on the remote server
  if ( ( RemoteKeyCode = XKeysymToKeycode ( RemoteDpy, KS ) ) == 0 ) {
  	// no keycode on the remote display for the keysym
	fprintf(stderr, "No keycode on remote display found for keysym: %d\n", KS);
  	return;
  }

  // send the event. Check if it's a release or press
  if ( Pressed ) {
	// keypress
	XTestFakeKeyEvent ( RemoteDpy, (unsigned int)RemoteKeyCode, True, Delay );
  }

  else {
	// keyrelease
	XTestFakeKeyEvent ( RemoteDpy,(unsigned int) RemoteKeyCode, False, Delay );
  }
}

/*void getParent(Display *d, Window w)
{
cerr << "XQueryTree
}*/
/****************************************************************************/
/*! Main event-loop of the application. Loops until a key with the keycode
    \a QuitKey is pressed. Sends all mouse- and key-events to the remote
	display.

    \arg Display * LocalDpy - used display.
	\arg Display * RemoteDpy - used display.
	\arg int LocalScreen - the used screen.
	\arg int RemoteScreen - the used screen.
	\arg unsigned int QuitKey - the key when pressed that quits the eventloop.
*/
/****************************************************************************/
void eventLoop (Display * LocalDpy, int LocalScreen,
				Display * RemoteDpy, int RemoteScreen, unsigned int QuitKey) {

  int          Status1, Status2, x=0, y=0;
  bool         Loop = true;
  XEvent       Event;
  Window       Root;
  XButtonEvent EButton;
  XMotionEvent EMotion;
  XKeyEvent    EKey;

  // get the root window and set default target
  Root = RootWindow ( LocalDpy, LocalScreen );

  // grab the pointer
  Status1 = XGrabPointer ( LocalDpy, Root, False,
						   PointerMotionMask|ButtonPressMask|ButtonReleaseMask,
						   GrabModeSync, GrabModeAsync, Root, None, CurrentTime );

  // grab the keyboard
  Status2 = XGrabKeyboard ( LocalDpy, Root, False, GrabModeSync, GrabModeAsync, CurrentTime );

  // did we succeed in grabbing the pointer?
  if ( Status1 != GrabSuccess) {
	// nope, abort
	fputs("Could not grab the local mouse, aborting.\n",stderr);
	exit ( EXIT_FAILURE );
  }

  // did we succeed in grabbing the keyboard?
  if ( Status2 != GrabSuccess) {
	// nope, abort
	fputs("Could not grab the local keyboard, aborting.\n", stderr);
	exit ( EXIT_FAILURE );
  }

  Status2=0;
  Status1=2;
  while ( Loop ) {
    // allow one more event
	XAllowEvents ( LocalDpy, SyncPointer, CurrentTime);

	// get an event matching the specified mask
	XWindowEvent ( LocalDpy, Root,
				   KeyPressMask|KeyReleaseMask|PointerMotionMask|ButtonPressMask|ButtonReleaseMask,
				   &Event);

	if (Status1)
	{
	  Status1--;
	  if (Event.type==KeyRelease)
	  {
		fprintf(stderr, "Skipping stale KeyRelease event. %d\n", Status1);
		continue;
	  } else Status1=0;
	}
	// what did we get?
    switch (Event.type) {
    case ButtonPress:
	  // button pressed, create event
	  EButton = Event.xbutton;
#ifdef DEBUG
		//~ cerr << "type: " << Event.xbutton.type << " serial: " << Event.xbutton.serial << endl;
		//~ cerr << "send_event: " << Event.xbutton.send_event << " display_name: " << Event.xbutton.display->display_name << endl;
		//~ cerr << "window:  " << hex << Event.xbutton.window << " root: " << Event.xbutton.root << endl;
		//~ cerr << "subwindow:  " << Event.xbutton.subwindow << " time: " << dec << Event.xbutton.time << endl;
		//~ cerr << "x:  " << Event.xbutton.x << " y: " << Event.xbutton.y << endl;
		//~ cerr << "x_root:  " << Event.xbutton.x_root << " y_root: " << Event.xbutton.y_root << endl;
		//~ cerr << "state:  " << Event.xbutton.state << " button: " << Event.xbutton.button << endl;
		//~ cerr << "same_screen:  " << Event.xbutton.same_screen << endl << "------" << endl;
#endif
	  if (EButton.x!=x || EButton.y!=y)
	  {
		printf("MotionNotify %d %d\n", EButton.x, EButton.y);
		x=EButton.x; y=EButton.y;
	  }
	  if (Status2<0) Status2=0;
	  Status2++;
	  printf("ButtonPress %d\n", EButton.button);
	  XTestFakeButtonEvent ( RemoteDpy, EButton.button, True, Delay );
      break;

    case ButtonRelease:
	  // button released, create event
	  EButton = Event.xbutton;
#ifdef DEBUG
		//~ cerr << "type: " << Event.xbutton.type << " serial: " << Event.xbutton.serial << endl;
		//~ cerr << "send_event: " << Event.xbutton.send_event << " display_name: " << Event.xbutton.display->display_name << endl;
		//~ cerr << "window:  " << hex << Event.xbutton.window << " root: " << Event.xbutton.root << endl;
		//~ cerr << "subwindow:  " << Event.xbutton.subwindow << " time: " << dec << Event.xbutton.time << endl;
		//~ cerr << "x:  " << Event.xbutton.x << " y: " << Event.xbutton.y << endl;
		//~ cerr << "x_root:  " << Event.xbutton.x_root << " y_root: " << Event.xbutton.y_root << endl;
		//~ cerr << "state:  " << Event.xbutton.state << " button: " << Event.xbutton.button << endl;
		//~ cerr << "same_screen:  " << Event.xbutton.same_screen << endl << "------" << endl;
#endif
	  if (EButton.x!=x || EButton.y!=y)
	  {
		printf("MotionNotify %d %d\n", EButton.x, EButton.y);
		x=EButton.x; y=EButton.y;
	  }
	  Status2--;
	  if (Status2<0) Status2=0;
	  printf("ButtonRelease %d\n", EButton.button);
	  XTestFakeButtonEvent ( RemoteDpy, EButton.button, False, Delay );
	  break;

	case MotionNotify:
	  // motion-event, create event
	  EMotion = Event.xmotion;
#ifdef DEBUG
		//~ cerr << "type: " << Event.xmotion.type << " serial: " << Event.xmotion.serial << endl;
		//~ cerr << "send_event: " << Event.xmotion.send_event << " display_name: " << Event.xmotion.display->display_name << endl;
		//~ cerr << "window:  " << hex << Event.xmotion.window << " root: " << Event.xmotion.root << endl;
		//~ cerr << "subwindow:  " << Event.xmotion.subwindow << " time: " << dec << Event.xmotion.time << endl;
		//~ cerr << "x:  " << Event.xmotion.x << " y: " << Event.xmotion.y << endl;
		//~ cerr << "x_root:  " << Event.xmotion.x_root << " y_root: " << Event.xmotion.y_root << endl;
		//~ cerr << "state:  " << Event.xmotion.state << " is_hint: " << Event.xmotion.is_hint << endl;
		//~ cerr << "same_screen:  " << Event.xmotion.same_screen << endl << "------" << endl;
#endif
	  if (Status2>0) printf("MotionNotify %d %d\n", EButton.x, EButton.y);
	  XTestFakeMotionEvent ( RemoteDpy, RemoteScreen , scale ( EMotion.x ), scale ( EMotion.y ), Delay );
	  break;

	case KeyPress:
	  // a key was pressed, don't loop more
	  EKey = Event.xkey;
#ifdef DEBUG
		//~ cerr << "type: " << Event.xkey.type << " serial: " << Event.xkey.serial << endl;
		//~ cerr << "send_event: " << Event.xkey.send_event << " display_name: " << Event.xkey.display->display_name << endl;
		//~ cerr << "window:  " << hex << Event.xkey.window << " root: " << Event.xkey.root << endl;
		//~ cerr << "subwindow:  " << Event.xkey.subwindow << " time: " << dec << Event.xkey.time << endl;
		//~ cerr << "x:  " << Event.xkey.x << " y: " << Event.xkey.y << endl;
		//~ cerr << "x_root:  " << Event.xkey.x_root << " y_root: " << Event.xkey.y_root << endl;
		//~ cerr << "state:  " << Event.xkey.state << " keycode: " << Event.xkey.keycode << endl;
		//~ cerr << "same_screen:  " << Event.xkey.same_screen << endl << "------" << endl;
#endif
	  // should we stop looping, i.e. did the user press the quitkey?
	  if ( EKey.keycode == QuitKey ) {
		// yep, no more loops
		Loop = false;
	  }
	  else {
		// send the keycode to the remote server
		if (EKey.x!=x || EKey.y!=y)
		{
			printf("MotionNotify %d %d\n", EKey.x, EKey.y);
			x=EKey.x; y=EKey.y;
		}
		printf("KeyStrPress %s\n", XKeysymToString(getKeySym(&EKey)));
		sendKey  ( &EKey, LocalDpy, RemoteDpy, EKey.keycode, true );
	  }
	  break;

	case KeyRelease:
	  // a key was released
	  EKey = Event.xkey;
#ifdef DEBUG
		//~ cerr << "type: " << Event.xkey.type << " serial: " << Event.xkey.serial << endl;
		//~ cerr << "send_event: " << Event.xkey.send_event << " display_name: " << Event.xkey.display->display_name << endl;
		//~ cerr << "window:  " << hex << Event.xkey.window << " root: " << Event.xkey.root << endl;
		//~ cerr << "subwindow:  " << Event.xkey.subwindow << " time: " << dec << Event.xkey.time << endl;
		//~ cerr << "x:  " << Event.xkey.x << " y: " << Event.xkey.y << endl;
		//~ cerr << "x_root:  " << Event.xkey.x_root << " y_root: " << Event.xkey.y_root << endl;
		//~ cerr << "state:  " << Event.xkey.state << " keycode: " << Event.xkey.keycode << endl;
		//~ cerr << "same_screen:  " << Event.xkey.same_screen << endl << "------" << endl;
#endif
	  if (EKey.x!=x || EKey.y!=y)
	  {
		printf("MotionNotify %d %d\n", EKey.x, EKey.y);
		x=EKey.x; y=EKey.y;
	  }
	  printf("KeyStrRelease %s\n", XKeysymToString(getKeySym(&EKey)));
	  sendKey  ( &EKey, LocalDpy, RemoteDpy, EKey.keycode, false );
	  break;
	}

	// sync the remote server
	XFlush ( RemoteDpy );
  }

  // we're done with pointer and keyboard
  XUngrabPointer  ( LocalDpy, CurrentTime );
  XUngrabKeyboard ( LocalDpy, CurrentTime );
}


/****************************************************************************/
/*! Main function of the application. It expects no commandline arguments.

    \arg int argc - number of commandline arguments.
	\arg char * argv[] - vector of the commandline argument strings.
*/
/****************************************************************************/
int main (int argc, char * argv[]) {

  // parse commandline arguments
  parseCommandLine ( argc, argv );

  // open the local display
  Display * LocalDpy = localDisplay ();

  // get the screens too
  int LocalScreen  = DefaultScreen ( LocalDpy );

  // do we already have a quit key? If one was supplied as a commandline
  // argument we use that key
  if ( ! HasQuitKey ) {
	// nope, so find the key that quits the application
	QuitKey = findQuitKey ( LocalDpy, LocalScreen );
  }

  else {
	// show the user which key will be used
	fprintf(stderr, "The used quit-key has the keycode: %d\n", QuitKey);
  }

  // open the remote display or abort
  Display * RemoteDpy = remoteDisplay ( Remote );

  // get the screens too
  int RemoteScreen = DefaultScreen ( RemoteDpy );

  // start the main event loop
  eventLoop ( LocalDpy, LocalScreen, RemoteDpy, RemoteScreen, QuitKey );

  // discard and even flush all events on the remote display
  XTestDiscard ( RemoteDpy );
  XFlush ( RemoteDpy );

  // we're done with the display
  XCloseDisplay ( RemoteDpy );
  XCloseDisplay ( LocalDpy );

  fprintf(stderr, "%s: pointer and keyboard released.\n", PROG);

  // go away
  exit ( EXIT_SUCCESS );
}
