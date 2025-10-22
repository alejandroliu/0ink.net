/**
 * @file
 * NetRelay - Connect virtual networks
 *
 * Copyright 2025 Alejandro Liu
 *
 * Redistribution and use in source and binary forms, with or
 * without modification, are permitted provided that the following
 * conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above
 *    copyright notice, this list of conditions and the following
 *    disclaimer in the documentation and/or other materials provided
 *    with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */
#include <stdio.h>
#include <stdint.h>
#include <errno.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <sys/socket.h>
//~ #include <sys/select.h>
#include <stdlib.h>
#include <unistd.h>
#include <ctype.h>
#include <string.h>
#include <signal.h>
#include <stdarg.h>
#include <net/if.h>
#include <fcntl.h>
#include <sys/ioctl.h>
//~ #include <arpa/inet.h>
#include <linux/if.h>
#include <linux/if_tun.h>
#include <pthread.h>

#define BUFSZ 65536		/*!< @brief Size of network package buffers */

const char *argv0 = "netrelay";	/*!< Command name */
int verbose = 0;		/*!< Flag to add additional diagnostic messages */

/**
 * @brief Boolean types
 */
typedef enum {
  False = 0,
  True
} bool_t;

/**
 * @brief Multi protocol address storage
 */
typedef union sockaddr_u {
  sa_family_t sa_family;	/*!< structure type selector */
  struct sockaddr sa;		/*!< generic socket address */
  struct sockaddr_in in;	/*!< IPv4 socket address */
  struct sockaddr_in6 in6;	/*!< IPv6 socket address */
} sockaddr_u;

/**
 * @brief Linked list for I/O sockets
 */
typedef struct socklst_t {
  int fd;			/*!< socket file descriptor */
  struct socklst_t *next;	/*!< pointer to next item in linked list */
} socklst_t;

/**
 * @brief Types of connections
 */
typedef enum {
  cs_none = 0,		// No connection
  cs_stdio,		// Use stdio
  cs_udp,		// Use UDP
  cs_tap,		// tap device
  cs_tcp,		// tcp
} cs_type_t;

/**
 * @brief stdio connection type
 * stdio connection type, mainly for test/debug
 */
struct cs_stdio_t {
  cs_type_t type;		/*!< type of connection */
};
/**
 * @brief Simple connection type
 * basic connection type.  Here the OS manages the connection state
 */
struct cs_fd_t {
  cs_type_t type;		/*!< type of connection */
  int sock;			/*!< file descriptor */
};
/**
 * @brief UDP connections
 * UDP connections -- these are by default connectionless so we manage
 * the connection on our own
 */
struct cs_udp_t {
  cs_type_t type;		/*!< type of connection */
  int sock;			/*!< file descriptor */
  sockaddr_u peer;		/*!< UDP peer destination */
};
/**
 * @brief Multi connection type storage
 */
typedef union cs_dat_u {
  cs_type_t type;		/*!< type of connection */
  struct cs_stdio_t stdio;	/*!< stdio structure */
  struct cs_fd_t fd;		/*!< generic single file descriptor connection */
  struct cs_udp_t udp;		/*!< UDP connection */
} cs_dat_u;

/**
 * @brief pipe end points
 * When pumping data, these are the two ends of the connected pipe
 */
cs_dat_u chans[2];

/**
 * @brief Format a number into a human-readable string with metric suffix.
 * @param value: number to format
 * @param out: output buffer to store formatted string
 * @param size: size of output buffer
 * @return pointer to output buffer
 *
 * This function scales large numbers into readable formats using metric suffixes:
 * - `K` for thousands
 * - `M` for millions
 * - `B` for billions
 * - `T` for trillions
 * - `P` for quadrillions
 * - `E` for quintillions
 * For example, `1500000` becomes `"1.5M"`. The result is written to
 * `out` using `snprintf`.
 */
char *format_num(unsigned long long value, char *out, int size) {
  const char *suffix = "";
  double scaled = value;

  if (value >= 1e18) {
    suffix = "E";  // Exa (quintillion)
    scaled = value / 1e18;
  } else if (value >= 1e15) {
        suffix = "P";  // Peta (quadrillion)
        scaled = value / 1e15;
  } else if (value >= 1e12) { // Trillion
      suffix = "T";
      scaled = value / 1e12;
  } else if (value >= 1e9) { // Billion
      suffix = "B";
      scaled = value / 1e9;
  } else if (value >= 1e6) {
      suffix = "M";
      scaled = value / 1e6;
  } else if (value >= 1e3) {
      suffix = "K";
      scaled = value / 1e3;
  }

  snprintf(out, size, "%.1f%s", scaled, suffix);
  return out;
}

/**
 * @brief Return string representation of an IP address
 *
 * Given an IP address in the `sockaddr_u` structure, return
 * its string representation.
 *
 * @param addr: pointer to a `sockaddr_u` structure.
 * @param buf: output buffer
 * @param size: size of buf
 * @return pointer to buf
 *
 * This formats the address in addr as a string.  Only supports
 * IPv4 and IPv6 addresses.  If an unknown type is used, it
 * will return `*unknown*`.
 */
char *format_ipaddr(sockaddr_u *addr, char *buf, int size) {
  if (addr->sa_family == AF_INET6) {
    inet_ntop(addr->sa_family, &addr->in6.sin6_addr, buf, size);
  } else if (addr->sa_family == AF_INET) {
    inet_ntop(addr->sa_family, &addr->in.sin_addr, buf, size);
  } else {
    strncpy(buf,"*unknown*", size);
  }
  return buf;
}


/**
 * @brief Create a listening TCP/IP socket
 *
 * @param port: listening port
 * @return UNIX descriptor for socket, `-1` on error.
 *
 * Will create an IPv6 or DualStack socket, otherwise it will create
 * an IPv4 socket.  Any errors are reported on `stderr`.
 */
int make_socket(int port) {
  int sockfd;
  int reuse = 1;

  sockfd = socket(AF_INET6, SOCK_STREAM, 0);
  if (sockfd >= 0) {
    setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &reuse, sizeof(reuse));
    int off = 0;
    if (setsockopt(sockfd, IPPROTO_IPV6, IPV6_V6ONLY, &off, sizeof(off)) != 0)
      fputs("Warning: Unable to disable IPv6 only\n", stderr);
    struct sockaddr_in6 addr6 = {0};
    addr6.sin6_family = AF_INET6;
    addr6.sin6_addr = in6addr_any;
    addr6.sin6_port = htons(port);
    if (bind(sockfd, (struct sockaddr *)&addr6, sizeof(addr6)) == 0 &&
	listen(sockfd, 10) == 0) return sockfd;
    perror("bind/listen");
    return -1;
  }
  // Fall back to IPv4
  sockfd = socket(AF_INET, SOCK_STREAM, 0);
  if (sockfd >= 0) {
    setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &reuse, sizeof(reuse));
    struct sockaddr_in addr4 = {0};
    addr4.sin_family = AF_INET;
    addr4.sin_addr.s_addr = INADDR_ANY;
    addr4.sin_port = htons(port);
    if (bind(sockfd, (struct sockaddr *)&addr4, sizeof(addr4)) == 0 &&
	listen(sockfd, 10) == 0) return sockfd;
    perror("bind/listen");
  } else {
    perror("socket");
  }
  return -1;
}

/**
 * @brief Like send but makes sure that all data is send.
 *
 * @param sock: UNIX descriptor to socket
 * @param bufp: pointer to output buffer
 * @param bfsz: size of data to send
 * @param flags: flags to pass to `send` function
 * @see send(2)
 * @return bytes sent or -1 on error.
 */
int sendEx(int sock, void *bufp, size_t bfsz, int flags) {
  // send payload...
  unsigned char *buffer = (unsigned char *)bufp;
  ssize_t sent = 0;
  while (sent < bfsz) {
    ssize_t n = send(sock, buffer+sent, bfsz - sent, flags);
    if (n <= 0) return -1;
    sent += n;
  }
  // fprintf(stderr,"Sent: %ld\n", sent);
  return sent;
}

/**
 * @brief Send TCP/IP packets using Qemu compatible framing.
 *
 * @param sock: UNIX descriptor to socket
 * @param bufp: pointer to output buffer
 * @param bfsz: size of data to send
 * @param flags: flags to pass to `send` function
 * @see send(2)
 * @return bytes sent or -1 on error.
 *
 * This uses the simple qemu framing of adding a 4 byte header
 * in network byte order containg the size of each frame followed
 * by the payload.
 */
int qemu_send(int sock, void *bufp, size_t bfsz, int flags) {
  // send header
  uint32_t netlen = htonl(bfsz);
  // fprintf(stderr,"Write header: %ld\n", bfsz);
  if (send(sock, &netlen, sizeof(netlen), flags|MSG_MORE) != sizeof(netlen)) return -1;
  // send payload...
  return sendEx(sock, bufp, bfsz, flags);
}

/**
 * @brief Header size in case of error
 */
ssize_t _qemu_recv_hdr_sz = 0;

/**
 * @brief Receive TCP/IP packets using Qemu compatible framing.
 *
 * @param sock: UNIX descriptor to socket
 * @param bufp: pointer to input buffer
 * @param bfsz: size of data to send
 * @param flags: flags to pass to `recv` function
 * @see recv(2)
 * @return bytes received or -1 on error.
 *
 * This uses the simple qemu framing of adding a 4 byte header
 * in network byte order containg the size of each frame followed
 * by the payload.
 *
 * This function assumes that the received buffer is large enough
 * to receive the sent packet.  In theory this is a problem as
 * the maximum size of packets is 4GB, which is unrealistic.  In
 * practice most packets will be at most a few KB in size.
 *
 * In the case of a packet too large being received, it will return -1
 * and set `errno` to `ENOMEM`.  Also the variable `_qemu_recv_hdr_sz`
 * will have the frame size in the case the caller wants to handle this
 * error condition.
 */
int qemu_recv(int sock, void *bufp, size_t bfsz, int flags) {
  uint32_t hdr;
  ssize_t n, netlen;

  n = recv(sock, &hdr, sizeof(hdr), flags|MSG_WAITALL);
  if (n != sizeof(hdr)) {
    if (verbose) fprintf(stderr,"Error reading hdr %d (%ld)\n", sock, n);
    return -1;
  }
  netlen = ntohl(hdr);
  if (netlen > bfsz) {
    if (verbose) fprintf(stderr,"%d: Error size in hdr=%ld > bfsz=%ld\n", sock, netlen, bfsz);
    errno = ENOMEM;
    _qemu_recv_hdr_sz = netlen;
    return -1;
  }

  unsigned char *buffer = bufp;
  ssize_t cnt = 0;
  while (cnt < netlen) {
    n = recv(sock, buffer+cnt, netlen - cnt, flags);
    if (n <= 0) {
      if (verbose) fprintf(stderr,"%d: Short read %ld (%ld read of %ld)\n", sock, n, netlen - cnt, netlen);
      return -1;
    }
    cnt += n;
  }
  return cnt;
}

/**
 * @brief Initialize netrelay server
 *
 * @param port: port to listen on
 * @param root: root node of linked list
 *
 * This will set-up a listening port and initialize the root of
 * the linked list used to store the connected clients.
 */
void server_init(int port, socklst_t *root) {
  root->fd = make_socket(port);
  if (root->fd == -1) {
    fprintf(stderr,"%s: network initialization error\n", argv0);
    exit(__LINE__);
  }
  root->next = NULL;
  if (verbose) fprintf(stderr,"%s: listening on port %d\n", argv0, port);

}

/**
 * @brief Main loop for netrelay server
 *
 * @param root: root node of linked list
 *
 * This is the main loop of handling netrelay servers.  It essentially
 * accepts new client connections.  Then any message received from
 * a client, the message is re-broadcast to all the other connected
 * clients.
 */
void server_loop(socklst_t *root) {
  socklst_t *sp;
  unsigned char buf[BUFSZ];

  unsigned long long b_cnt = 0, p_cnt = 0;
  char b_buf[16], p_buf[16];
  int doup = False, c_cnt;

  int ready, nfds, closing;
  fd_set readfds, closefds;

  for (;;) {
    closing = nfds = 0;
    FD_ZERO(&readfds);
    FD_ZERO(&closefds);
    c_cnt = 0;
    FD_SET(0, &readfds);

    for (sp = root; sp ; sp = sp->next) {
      c_cnt++;
      FD_SET(sp->fd, &readfds);
      if (sp->fd > nfds) nfds = sp->fd;
    }
    ready = select(nfds+1, &readfds, NULL, NULL, NULL);
    if (ready == -1) {
      if (errno == EINTR) continue;
      perror("select");
      exit(__LINE__);
    }

    if (FD_ISSET(root->fd, &readfds)) {
      sockaddr_u addr;
      socklen_t addrlen = sizeof(addr);
      socklst_t *client;
      int fd = accept(root->fd, &addr.sa, &addrlen);
      int flag = 1;
      // Disable nagle algorithm
      setsockopt(fd, IPPROTO_TCP, TCP_NODELAY, &flag, sizeof(flag));
      if (fd == -1) {
	perror("accept");
	if (verbose) doup = False;
      } else {
	char ip[INET6_ADDRSTRLEN];
	if (verbose) {
	  fprintf(stderr,"Accepted %d (%s)\n", fd, format_ipaddr(&addr, ip, sizeof(ip)));
	  doup = False;
	}
	client = (socklst_t *)malloc(sizeof(socklst_t));
	if (!client) {
	  perror("malloc");
	  if (verbose) doup = False;
	  close(fd);
	} else {
	  client->next = root->next;
	  client->fd = fd;
	  root->next = client;
	}
      }
    }
    for (sp = root->next; sp ; sp = sp->next) {
      if (!FD_ISSET(sp->fd, &readfds) || FD_ISSET(sp->fd, &closefds)) continue;

      /* The first version was using raw packets, which would have
       * less overhead, but we switched to using the qemu compatible
       * message framing.  This adds a little bit of overhead, but I
       * believe would be better as it removes the SMALL risk of a client
       * joining in-between raw messages being broadcast.
       */
      //~ ssize_t n = recv(sp->fd, buf, sizeof(buf), 0);
      ssize_t n = qemu_recv(sp->fd, buf, sizeof(buf), 0);

      if (n > 0) {
	b_cnt += n;
	p_cnt++;
	if (verbose) {
	  //~ // Check header... (For raw packets)
	  //~ ssize_t hdr = (buf[0] << 24) | (buf[1] << 16)  | (buf[2] << 8) | buf[3];
	  //~ fprintf(stderr, "%sBytes: %s Packets: %s - Read %ld Hdr: %ld Avg: %lld (Peers: %d)    \n",
			//~ (doup ? "\033[A" : ""),
			//~ format_num(b_cnt, b_buf, sizeof(b_buf)),
			//~ format_num(p_cnt, p_buf, sizeof(p_buf)),
			//~ n, hdr, b_cnt / p_cnt, c_cnt);
	  fprintf(stderr, "%sBytes: %s Packets: %s - Read %ld Avg: %lld (Clients: %d)    \n",
			(doup ? "\033[A" : ""),
			format_num(b_cnt, b_buf, sizeof(b_buf)),
			format_num(p_cnt, p_buf, sizeof(p_buf)),
			n, b_cnt / p_cnt, c_cnt - 1);
	  doup = True;
	}

	socklst_t *np;
	for (np = root->next; np; np = np->next) {
	  if (np->fd == sp->fd || FD_ISSET(np->fd, &closefds)) continue;
	  //~ if (sendEx(np->fd, buf, n) != n) {
	    //~ FD_SET(np->fd, &closefds);
	    //~ ++closing;
	  //~ }
	  if (qemu_send(np->fd, buf, n, MSG_NOSIGNAL) != n) {
	    if (verbose) {
	      fprintf(stderr,"%d: Error sending %ld bytes\n", np->fd, n);
	      doup = False;
	    }
	    FD_SET(np->fd, &closefds);
	    ++closing;
	  }
	}
      } else {
	if (verbose) {
	  fprintf(stderr,"%d,%d: Error reading %ld\n", sp->fd, __LINE__, n);
	  doup = False;
	}
	FD_SET(sp->fd, &closefds);
	++closing;
      }
    }
    // Close all sockets that need to be closed
    if (closing) {
      socklst_t *prev;

      for (prev = root, sp = root->next; sp ; prev = sp, sp = sp->next) {
	if (!FD_ISSET(sp->fd, &closefds)) continue;
	prev->next = sp->next;
	if (verbose) {
	  fprintf(stderr,"Closing %d\n", sp->fd);
	  doup = False;
	}
	close(sp->fd);
	free(sp);
	sp = prev;
      }
    }
  }
}

/**
 * @brief Parse/check integer from a string until a colon or NULL is found.
 *
 * @param s: input string to parse
 * @param num: pointer to an `int` to receive parsed numbers
 * @return Pointer to character after number or `NULL` on error.
 *
 * This function scans the input string and parses a decimal number
 * until it encounters a colon (`:`) or the end of the string. If the
 * string contains non-digit characters before the colon, it returns
 * `NULL`.  The parsed value is stored in the int pointed by `num`.
 *
 * The return value is a pointer to the character after the number
 * (typically the colon).
 */
const char *check_num(const char *s, int *num) {
  if (!s) return s;
  *num  = 0;
  while (*s != '\0' && *s != ':') {
    if (!isdigit((unsigned char)*s)) return NULL;
    *num = (*num)*10 + (*s - '0');
    s++;
  }
  return s;
}

/**
 * @brief Parse/check IPv4/IPv6 addresses from a string until a colon or NULL is found.
 *
 * @param p: input string to parse
 * @param addr: structure to received parsed address.
 * @return Pointer to character after address or `NULL` on error.
 *
 * This function scans the input string and parses an IP address
 * as an IPv4 quad decimal address or square bracket enclosed
 * address ( `[]` ) IPv6 address.  If the string can not be parsed
 * as a IPv4/IPv6 address it returns `NULL`.
 *
 * The parsed address is stored in the `sockaddr_u` structure
 * pointed by `addr`.
 *
 * The return value is a pointer to the character after the IP address
 * (typically the colon).
 */
const char *check_ipaddr(const char *p, sockaddr_u *addr) {
  char ipbuf[70];
  if (*p == '[') {
    // IPv6 in brackets ... find closing bracket first
    const char *closed = strchr(++p,']');
    if (!closed || *(closed+1) != ':') return NULL;
    int len = closed-p;
    if (sizeof(ipbuf) < len) return NULL;
    strncpy(ipbuf, p, len);
    ipbuf[len] = '\0';
    // printf("ip6buf=%s\n", ipbuf);
    p += len + 1;

    // Verify IPv6 address...
    addr->in6.sin6_family = AF_INET6;
    if (inet_pton(AF_INET6, ipbuf, &(addr->in6.sin6_addr)) != 1) return NULL;
  } else if (isdigit(*p)) {
    const char *colon2 = strchr(p,':');
    if (!colon2) return NULL;
    int len = colon2-p;
    if (sizeof(ipbuf) < len) return NULL;
    strncpy(ipbuf, p, len);
    ipbuf[len] = '\0';
    // printf("ip4buf=%s\n", ipbuf);
    p += len;

    // Verify IPv4 address...
    addr->in.sin_family = AF_INET;
    if (inet_pton(AF_INET, ipbuf, &(addr->in.sin_addr)) != 1) return NULL;
  } else {
    return NULL;
  }
  return p;
}

/**
 * @brief Make sure the given name can be used as a network interface
 * 	name
 *
 * @param name: name to check
 * @return `1` if valid, `0` if invalid.
 *
 * Makes sure that the given name is less than `IFNAMSIZ` and only
 * contains number, letters and underscores (`_`).
 */
int check_name(const char *name) {
  if (!name) return 0;
  size_t len = strlen(name);
  if (len ==0 || len >= IFNAMSIZ) return 0;
  for (size_t i=0; i < len; ++i)
    if (!isalnum(name[i]) && name[i] != '_') return 0;
  return 1; // Valid name!
}

/**
 * @brief execute a shell command using printf style varargs
 *
 * @param fmt: A printf-style format string.
 * @param ...: Variable arguments matching the format string.
 * @return Exit status from the shell command.
 *
 * This function formats a shell command using `vsnprintf` and
 * executes it using `system()`.
 *
 * If `verbose` is enabled, it prints the command to stderr before execution.
 */
int fsystem(const char *fmt, ...) {
  char cmd[1024];
  va_list args;
  va_start(args,fmt);
  vsnprintf(cmd, sizeof(cmd), fmt, args);
  va_end(args);
  if (verbose) fprintf(stderr,"x - %s\n", cmd);
  return system(cmd);
}

/**
 * @brief Multi connection type send function
 *
 * @param cs : pointer to `cs_dat_u` structure describing the connection type
 * @param buffer : data to send
 * @param bfsz : size of data to send
 * @param flags : flags to pass to `send` function.
 * @return count of bytes sent or `-1` on error
 *
 * Will handle sending data over a connection taking care the
 * different semantics due to the different connection types.
 */
int cs_send(union cs_dat_u *cs, void *buffer, size_t bfsz, int flags) {
  switch (cs->type) {
  case cs_stdio:
    return write(1, buffer, bfsz);
  case cs_udp:
    return sendto(cs->udp.sock, buffer, bfsz, 0, &cs->udp.peer.sa, sizeof(sockaddr_u));
  case cs_tcp:
    return qemu_send(cs->fd.sock, buffer, bfsz, flags);
  default:
    return write(cs->fd.sock, buffer, bfsz);
  }
}

/**
 * @brief Multi connection type receive function
 *
 * @param cs : pointer to `cs_dat_u` structure describing the connection type
 * @param buffer : buffer to receive data
 * @param bfsz : size of buffer
 * @return count of bytes sent or `-1` on error
 *
 * Will handle receiving data over a connection taking care the
 * different semantics due to the different connection types.
 */
int cs_recv(union cs_dat_u *cs, void *buffer, size_t bfsz) {
  switch (cs->type) {
  case cs_stdio:
    return read(0, buffer, bfsz);
  case cs_udp:
    sockaddr_u peer;
    socklen_t addrlen = sizeof(peer);
    return recvfrom(cs->udp.sock,buffer,bfsz, 0, &peer.sa, &addrlen);
  case cs_tcp:
    return qemu_recv(cs->fd.sock, buffer, bfsz, 0);
  default:
    return read(cs->fd.sock, buffer, bfsz);
  }
}

/**
 * @brief Multi connection type close function
 *
 * @param cs : pointer to `cs_dat_u` structure describing the connection type
 *
 * Will handle closing a connection taking care the
 * different semantics due to the different connection types.
 */
void cs_close(union cs_dat_u *cs) {
  switch (cs->type) {
    case cs_stdio: break;
    case cs_udp: close(cs->udp.sock); break;
    default: close(cs->fd.sock);
  }
}

/**
 * @brief Parses an input string to initialize a `cs_dat_u` structure.
 *
 * @param input: string to parse
 * @param dat: pointer to a `cs_dat_u` structure to initialize
 * @return connection type, `cs_none` if there was an error.
 *
 * Will parse the given string to initialize a connection structure.
 *
 * Possible strings:
 *
 * - `-` : Use stdio, for testing.
 * - _listening-port_ : _ip-address_ : _sending-port_ : UDP connection,
 *   you can omit the _listening-port_ or the _sending-port_, but at
 *   least one of those needs to be specified.  It will use the same
 *   value for the missing one.  IP address can be a IPv4 quad-dotted
 *   numbers, or an IPv6 address enclosed with square brackets ( `[]` ).
 * - _ip-address_ : _port_ : TCP connection,
 *   IP address can be a IPv4 quad-dotted numbers, or an IPv6
 *   address enclosed with square brackets ( `[]` ).  You must
 *   specify the _port_ number of the listening server.
 * - _bridge_ : specify a bridge to connect to.
 */
int cs_parse(const char *input, cs_dat_u *dat) {
  sockaddr_u addr;
  const char *p;
  int first;
  if (!strcmp(input,"-")) {
    dat->stdio.type = cs_stdio;
    return cs_stdio;
  }
  if ((p = check_num(input, &first)) != NULL && *p == ':') {
    // This is an UDP specification...
    dat->udp.type = cs_udp;
    p = check_ipaddr(p+1, &dat->udp.peer);
    if (!p || *p != ':') {
      fprintf(stderr,"%s: Invalid UDP specification \"%s\"\n", argv0, input);
      return cs_none;
    }
    int last;
    if ((p = check_num(p+1, &last)) == NULL || *p != '\0' || !(first || last)) {
      fprintf(stderr,"%s: Invalid UDP port specified in \"%s\"\n", argv0, input);
      return cs_none;
    }
    // Initialize UDP structure
    if (dat->udp.peer.sa_family == AF_INET6) {
      dat->udp.peer.in6.sin6_port = htons(last);
    } else {
      dat->udp.peer.in.sin_port = htons(last);
    }
    dat->udp.sock = socket(dat->udp.peer.sa_family, SOCK_DGRAM, 0);
    sockaddr_u ls;
    if (dat->udp.peer.sa_family == AF_INET6) {
      ls.in6.sin6_family = AF_INET6;
      ls.in6.sin6_port = htons(first);
      ls.in6.sin6_addr = in6addr_any;
    } else if (dat->udp.peer.sa_family == AF_INET) {
      ls.in.sin_family = AF_INET;
      ls.in.sin_port = htons(first);
      ls.in.sin_addr.s_addr = INADDR_ANY;
    } else {
      fprintf(stderr,"%s: Invalid address family %d\n", argv0, dat->udp.peer.sa_family);
    }
    if (bind(dat->udp.sock, &ls.sa, sizeof(ls.sa)) < 0) {
      perror("bind");
      close(dat->udp.sock);
      return cs_none;
    }
    return cs_udp;
  }
  if ((p = check_ipaddr(input, &addr)) != NULL && *p == ':') {
    // This is a TCP specification
    int last;
    if ((p = check_num(p+1, &last)) == NULL || *p != '\0' || !(first || last)) {
      fprintf(stderr,"%s: Invalid TCP port specified in \"%s\"\n", argv0, input);
      return cs_none;
    }
    fprintf(stderr,"Connect to port %d\n", last);
    dat->fd.type = cs_tcp;
    dat->fd.sock = socket(addr.sa_family, SOCK_STREAM, 0);
    if (addr.sa_family == AF_INET6) {
      addr.in6.sin6_port = htons(last);
    } else if (addr.sa_family == AF_INET) {
      addr.in.sin_port = htons(last);
    } else {
      fprintf(stderr,"%s: Invalid address family %d\n", argv0, addr.sa_family);
    }
    if (connect(dat->fd.sock, &addr.sa, sizeof(addr.sa)) < 0) {
      perror("connect");
      close(dat->fd.sock);
      return cs_none;
    }
    return cs_tcp;
  }
  if (check_name(input)) {
    const char SYSFS_BRIDGE_PREFIX[] = "/sys/class/net/";
    const char SYSFS_BRIDGE_SUFFIX[] = "/bridge";
    const int SYSFS_PATH_LEN = sizeof(SYSFS_BRIDGE_PREFIX)+sizeof(SYSFS_BRIDGE_SUFFIX)+IFNAMSIZ;
    char path[SYSFS_PATH_LEN];
    snprintf(path, sizeof(path), "%s%s%s", SYSFS_BRIDGE_PREFIX, input, SYSFS_BRIDGE_SUFFIX);
    if (access(path, F_OK) != 0) {
      fprintf(stderr,"%s: \"%s\" is not bridge device\n", argv0, input);
      return cs_none;
    }
    // Make sure tun is loaded...
    if (access("/dev/net/tun", F_OK) != 0) {
      if (fsystem("modprobe tun") != 0) {
	fprintf(stderr, "%s: missing tun kernel support to connect to \"%s\"\n", argv0, input);
	return cs_none;
      }
    }

    // Create a unique interface name
    int j = 0;
    do {
      snprintf(path,sizeof(path),"tap%d", j++);
    } while (if_nametoindex(path));
    fprintf(stderr,"Creating dev: %s\n", path);

    struct ifreq ifr;
    int fd = open("/dev/net/tun", O_RDWR);
    if (fd < 0) {
      perror("open(/dev/net/tun)");
      return cs_none;
    }
    memset(&ifr,0, sizeof(ifr));
    ifr.ifr_flags = IFF_TAP | IFF_NO_PI;
    strncpy(ifr.ifr_name, path, IFNAMSIZ);
    if (ioctl(fd, TUNSETIFF, &ifr) < 0) {
      perror("ioctl");
      close(fd);
      return cs_none;
    }
    dat->fd.type = cs_tap;
    dat->fd.sock = fd;

    //
    // Connect bridge to tap...
    //
    int r = 0;
    r |= fsystem("ip link set %s up", path);
    r |= fsystem("ip link set %s master %s", path, input);
    if (r) fprintf(stderr, "%s: Error linking \"%s\" to \"%s\".\n   You may need to connect manually\n",
		argv0, path, input);
    return cs_tap;
  }
  fprintf(stderr,"%s: Unknown connect spec \"%s\"\n", argv0, input);
  return cs_none;
}

/**
 * @brief Used for pthread synchronization...
 */
pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;
/**
 * @brief Used for pthread synchronization...
 */
pthread_cond_t cond = PTHREAD_COND_INITIALIZER;
/**
 * @brief Used to signal that a pump is finished...
 */
int finished = 0;

/**
 * @brief Basic function copying data from one channel to the other
 *
 * @param args: array of a pair indeces in the channels array.
 *
 * Will read from the first args item, and write to the second
 * item.  Will use the `cs_recv` and `cs_send` functions to handle
 * communications.
 */
void *pump(void *args) {
  int *ixs = (int *)args;
  char buf[BUFSZ];
  ssize_t len, n;

  for (;;) {
    len = cs_recv(&chans[ixs[0]], buf, sizeof(buf));
    if (len > 0) {
      n = cs_send(&chans[ixs[1]], buf, len, MSG_NOSIGNAL);
      if (n != len) {
	if (verbose) fprintf(stderr,"Send pipe broken\n");
	break;
      }
    } else {
      if (verbose) fprintf(stderr,"Received EOF (%d:%ld)\n", ixs[0], len);
      break;
    }
  }

  // Signal completion
  pthread_mutex_lock(&lock);
  finished = 1;
  pthread_cond_signal(&cond);
  pthread_mutex_unlock(&lock);

  return NULL;
}

/**
 * @brief Manage the threads used for data communications
 *
 * Will create two threads, each handle one direction of communications.
 * If either threads dies, it will close the connection both ways and
 * exit.
 */
void start_pump(void) {
  pthread_t t1, t2;
  int t1dat[] = {0, 1}, t2dat[] = {1, 0};
  fprintf(stderr, "%s: Relay running Press Ctrl+C to stop.\n", argv0);
  pthread_create(&t1, NULL, pump, t1dat);
  pthread_create(&t2, NULL, pump, t2dat);

  // Wait for one thread to finish
  pthread_mutex_lock(&lock);
  while (!finished) {
      pthread_cond_wait(&cond, &lock);
  }
  pthread_mutex_unlock(&lock);

  // Cancel both threads (only one will be active)
  pthread_cancel(t1);
  pthread_cancel(t2);

  pthread_join(t1, NULL);
  pthread_join(t2, NULL);
}

/**
 * @brief Show usage message
 */
void usage() {
  /*
   #@@@ netrelay.1.md
   #@ :version: <%VERSION%>
   #@
   #@ # NAME
   #@
   #@ **netrelay** -- Relay _qemu_ VM traffic
   #@
   #@ # SYNOPSIS
   #@
   #@ - **netrelay** [-v] [_src_] [_dest_]
   #@   - point-to-point connection
   #@ - **netrelay** [-v] **-l** _port_ [_target_ ...]
   #@   - server mode
   #@
   #@ # DESCRIPTION
   #@
   #@ **netrelay** forwards traffic between _qemu_ VMs, other
   #@ **netrelay** instances, or Linux bridge interfaces.
   #@
   #@ It makes it possible for a _qemu_ VM to connect to communicate
   #@ across hosts or to connect to a bridge interface *without* the
   #@ need of admin priviledges.
   #@
   #@ It can operate as a point to point connection (i.e. like a
   #@ straight cable, or as dumb hub-like server accepting multiple
   #@ connections and distributing traffic across all connected
   #@ clients.
   #@
   #@ # OPTIONS
   #@
   #@ - **-l** _port_ : Enable server mode.
   #@ - _src_ | _dest_ | _target_ : Specify an end-point of
   #@   point-to-point connection or a target to connect the hub/server
   #@   mode on start-up.
   #@
   #@ # TARGETS
   #@
   #@ Specifying targets for point-to-point connections or server mode:
   #@
   #@ - `-` : Use stdio, for testing.
   #@ - _listening-port_ : _ip-address_ : _sending-port_ : UDP connection,
   #@   you can omit the _listening-port_ or the _sending-port_, but at
   #@   least one of those needs to be specified.  It will use the same
   #@   value for the missing one.  IP address can be a IPv4 quad-dotted
   #@   numbers, or an IPv6 address enclosed with square brackets ( `[]` ).
   #@ - _ip-address_ : _port_ : TCP connection,
   #@   IP address can be a IPv4 quad-dotted numbers, or an IPv6
   #@   address enclosed with square brackets ( `[]` ).  You must
   #@   specify the _port_ number of the listening server.
   #@ - _bridge_ : specify a bridge to connect to.
   #@
   #@ # COMPATIBILITY
   #@
   #@ **netrelay** will interoperate with _qemu_ VM network interfaces
   #@ using `udp` mode, or tcp `server` or `client` modes.
   #@
   #@ When connecting to a _bridge_ interface, it will do so by
   #@ creating a `tap` device and connecting it to the _bridge_.
   #@ Received frames from VMs or other clients are sent directly
   #@ to the `tap` device.
   #@
   #@ With _qemu_ using the `udp` mode works well with VMs in the same
   #@ host as it uses the loopback device.  However, communicating with
   #@ VMs on other hosts this is unreliable due to MTU limits which
   #@ may cause too much packet fragmentation.  Using one of `tcp`
   #@ modes can overcome this but introduces dependancies on how
   #@ VMs need to be brought up.  To make matters more complicated,
   #@ _qemu_ only establish TCP tunnels on definition, and will no
   #@ try to re-connect later.  Using **netrelay** as a connecting
   #@ glue can be used to work around these problems.
   #@
   #@ # BUGS
   #@
   #@ **netrelay** only acts as a dumb hub. It does not try to
   #@ look into the frames *MAC destination* or *MAC source* address
   #@ to implement bridging/switching.  Similarly, network loops
   #@ are not considered.
   #@
   #@ # TODO
   #@ - UDP connections, should be possible to do listen::target
   #@   listen and target must be different, IP address would
   #@   default to 127.0.0.1
   */
  fputs("Usage:\n", stderr);
  fprintf(stderr, "  %s [-v] [src] [dest]\n", argv0);
  fprintf(stderr, "  %s [-v] -l port [target ...]\n", argv0);
  fputs("\nsrc/dest should be a peer specification\n\n",stderr);
  fputs("\t- listen-port:target-ip:target-port -- UDP peer\n",stderr);
  fputs("\t- target-ip:target-port -- TCP connection\n",stderr);
  fputs("\t- bridge-name -- tap connection bridge\n", stderr);
  fputs("\t- \"-\" -- a single dash, use stdio (for testing)\n", stderr);
  exit(0);
}

/**
 * @brief Main function.
 *
 * @param argc: argument count
 * @param argv: argument values
 * @return 0 on success, non-zero on error
 *
 * Main command line interface for `netrelay`.
 */
int main(int argc, char**argv) {
  const char *p;
  int port;
  argv0 = (argv++)[0];
  --argc;

  while (argc > 0 && !strcmp(*argv,"-v")) {
    ++verbose;
    --argc;
    ++argv;
  }

  if (argc > 1 && !strcmp(argv[0],"-l")) {
    if ((p = check_num(argv[1], &port)) == NULL || *p != '\0') {
      fprintf(stderr,"%s: Invalid port specified\n", argv[1]);
      exit(__LINE__);
    }
    socklst_t root;
    server_init(port, &root);
    signal(SIGCHLD, SIG_IGN);

    for (int i=2;i<argc;i++) {
      if (!cs_parse(argv[i], &chans[0])) continue;
      // we opened a channel
      int sv[2];
      if (socketpair(AF_UNIX, SOCK_STREAM, 0, sv) == -1) {
	perror("socketpair");
	cs_close(&chans[0]);
	continue;
      }
      switch (fork()) {
      case -1:
	perror("fork");
	cs_close(&chans[0]);
	close(sv[0]);
	close(sv[1]);
	continue;
      case 0:
	// This is the child process
	for (socklst_t *p = &root; p ; p = p->next) close(p->fd);
	close(sv[0]);
	chans[1].fd.type = cs_tcp;
	chans[1].fd.sock = sv[1];
	start_pump();
	exit(0);
      default:
	// This is the server process...
	close(sv[1]);
	cs_close(&chans[0]);
	socklst_t *chld = (socklst_t *)malloc(sizeof(socklst_t));
	if (!chld) {
	  perror("malloc");
	  close(sv[0]);
	  continue;
	}
	if (verbose) fprintf(stderr,"Connected %s as %d\n", argv[i], sv[0]);
	chld->fd = sv[0];
	chld->next = root.next;
	root.next = chld;
      }
    }

    server_loop(&root);
    return 0;
  }

  if (argc != 2) usage();

  for (int i=0;i<2;i++) {
    cs_parse(argv[i], &chans[i]);
  }
  start_pump();
  return 0;

}

































