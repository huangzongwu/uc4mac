/*
  Copyright (c) 2009 by Jakob Schroeter <js@camaya.net>
  This file is part of the gloox library. http://camaya.net/gloox

  This software is distributed under a license. The full license
  agreement can be found in the file LICENSE in this distribution.
  This software may not be copied, modified, sold or distributed
  other than expressed in the named license agreement.

  This software is distributed without any warranty.
*/


#ifndef CONFIG_H__
#define CONFIG_H__

/* Define to 1 if you have the <arpa/nameser.h> header file. */
#define HAVE_ARPA_NAMESER_H 1

/* Define to 1 if you have the <dlfcn.h> header file. */
#define HAVE_DLFCN_H 1

/* Define to 1 if you have the `dn_skipname' function. */
#define HAVE_DN_SKIPNAME 1

/* Define to 1 if you have the <errno.h> header file. */
#define HAVE_ERRNO_H 1

/* Define to 1 if you have the `getaddrinfo' function. */
/* #undef HAVE_GETADDRINFO */

/* Define to 1 if you want TLS support (GnuTLS). Undefine HAVE_OPENSSL. */
/* #undef HAVE_GNUTLS */

/* Define to 1 if you have the <inttypes.h> header file. */
#define HAVE_INTTYPES_H 1

/* Define to 1 if you have the `bind' library (-lbind). */
/* #undef HAVE_LIBBIND */

/* Define to 1 if you want IDN support. */
/* #undef HAVE_LIBIDN */

/* Define to 1 if you have the `resolv' library (-lresolv). */
/* #undef HAVE_LIBRESOLV */

/* Define to 1 if you have the `socket' library (-lsocket). */
/* #undef HAVE_LIBSOCKET */

/* Define to 1 if you have the <memory.h> header file. */
#define HAVE_MEMORY_H 1

/* Define to 1 if you want TLS support (OpenSSL). Undefine HAVE_GNUTLS. */
#define HAVE_OPENSSL 1

/* Define if you have POSIX threads libraries and header files. */
#define HAVE_PTHREAD 1

/* Define to 1 if you have the `res_query' function. */
#define HAVE_RES_QUERY 1

/* Define to 1 if you have the `res_querydomain' function. */
#define HAVE_RES_QUERYDOMAIN 1

/* Define to 1 if you have the `setsockopt' function. */
#define HAVE_SETSOCKOPT 1

/* Define to 1 if you have the <stdint.h> header file. */
#define HAVE_STDINT_H 1

/* Define to 1 if you have the <stdlib.h> header file. */
#define HAVE_STDLIB_H 1

/* Define to 1 if you have the <strings.h> header file. */
#define HAVE_STRINGS_H 1

/* Define to 1 if you have the <string.h> header file. */
#define HAVE_STRING_H 1

/* Define to 1 if you have the <sys/stat.h> header file. */
#define HAVE_SYS_STAT_H 1

/* Define to 1 if you have the <sys/types.h> header file. */
#define HAVE_SYS_TYPES_H 1

/* Define to 1 if you have the <unistd.h> header file. */
#define HAVE_UNISTD_H 1

/* Define to 1 if you want Stream Compression support. */
#define HAVE_ZLIB 1

/* Define to the sub-directory in which libtool stores uninstalled libraries.
 */
#define LT_OBJDIR ".libs/"

/* Name of package */
#define PACKAGE "gloox"

/* Define to the address where bug reports for this package should be sent. */
#define PACKAGE_BUGREPORT "js@camaya.net"

/* Define to the full name of this package. */
#define PACKAGE_NAME "gloox"

/* Define to the full name and version of this package. */
#define PACKAGE_STRING "gloox 1.0"

/* Define to the one symbol short name of this package. */
#define PACKAGE_TARNAME "gloox"

/* Define to the home page for this package. */
#define PACKAGE_URL ""

/* Define to the version of this package. */
#define PACKAGE_VERSION "1.0"

/* Define to necessary symbol if this constant uses a non-standard name on
 your system. */
/* #undef PTHREAD_CREATE_JOINABLE */

/* Define to 1 if you have the ANSI C header files. */
#define STDC_HEADERS 1

/* Version number of package */
#define VERSION "1.0"

/* Define to empty if `const' does not conform to ANSI C. */
/* #undef const */

/* Define to `__inline__' or `__inline' if that's what the C compiler
 calls it, or to nothing if 'inline' is not supported under any name.  */
#ifndef __cplusplus
/* #undef inline */
#endif

#endif // CONFIG_H__
