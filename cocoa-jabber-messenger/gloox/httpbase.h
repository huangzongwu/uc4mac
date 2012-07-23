/*
  Copyright (c) 2005-2009 by Hao jing <haojingus@163.com>
  This file is part of the gloox library. http://camaya.net/gloox

  This software is distributed under a license. The full license
  agreement can be found in the file LICENSE in this distribution.
  This software may not be copied, modified, sold or distributed
  other than expressed in the named license agreement.

  This software is distributed without any warranty.
*/

#ifndef HTTPBASE_H__
#define HTTPBASE_H__

#include "macros.h"
#include "gloox.h"
#include "connectiondatahandler.h"
#include "logsink.h"

#include <string>
#include <list>
#include <map>

#if defined( _WIN32 ) && !defined( __SYMBIAN32__ )
#include <windows.h>
#endif

#endif

namespace gloox
{

  class ConnectionBase;
  class CompressionBase;
  class ConnectionListener;

  enum HTTPMethod
  {
	  GET,
	  POST,
	  PUT
  };
  /**
   * @brief This is the common base class for a Jabber/XMPP Client and a Jabber Component.
   *
   * It manages connection establishing, authentication, filter registration and invocation.
   * You should normally use Client for client connections and Component for component connections.
   *
   * @author Jakob Schroeter <js@camaya.net>
   * @since 0.3
   */
   class GLOOX_API HTTPBase: public ConnectionDataHandler
   {
     public:

	  HTTPBase(const std::string& url, const HTTPMethod method,const std::string& webdata);

	  virtual ~HTTPBase();

      /**
       * Switches usage of Stream Compression on/off (if available). Default: on if available. Stream
       * Compression should only be disabled if there are problems with using it.
       * @param compression Whether to switch Stream Compression usage on or off.
       */
      void setCompression( CompressionBase* cb );

      /**
       * A convenience function that sends the given Presence stanza.
       * @param webdata The Web data to send.
       */
      void send(const std::string webdata);

	  void addHeader(const std::string key , const std::string value);



      // reimplemented from ConnectionDataHandler
      virtual void handleReceivedData( const ConnectionBase* connection, const std::string& data );

	  // reimplemented from ConnectionDataHandler
      virtual void handleConnect( const ConnectionBase* connection );

	  virtual void handleDisconnect( const ConnectionBase* connection, ConnectionError reason );

    private:

      /**
       * Initiates the connection to a server. This function blocks as long as a connection is
       * established.
       * You can have the connection block 'til the end of the connection, or you can have it return
       * immediately. If you choose the latter, its your responsibility to call @ref recv() every now
       * and then to actually receive data from the socket and to feed the parser.
       * @param block @b True for blocking, @b false for non-blocking connect. Defaults to @b true.
       * @return @b False if prerequisits are not met (server not set) or if the connection was refused,
       * @b true otherwise.
       * @note Since 0.9 @link ConnectionListener::onDisconnect() onDisconnect() @endlink is called
       * in addition to a return value of @b false.
       */
	  bool connect(bool block = true);

      /**
       * Use this periodically to receive data from the socket and to feed the parser. You need to use
       * this only if you chose to connect in non-blocking mode.
       * @param timeout The timeout in microseconds to use for select. Default of -1 means blocking
       * until data was available.
       * @return The state of the connection.
       */
      ConnectionError recv( int timeout = -1 );

	  void init(const std::string& url);

	  typedef std::list<ConnectionListener*>               ConnectionListenerList;
	  bool m_compressionActive;                   /**< Whether stream compression
                                          * is desired at all. */
	  CompressionBase* m_compression;    /**< Used for connection compression. */
	  std::string m_server;				/* Server */
	  int	m_port;						/* port */
	  std::string m_request;			/* Request */
	  HTTPMethod m_method;				/* method */
	  ConnectionListenerList   m_connectionListeners;
	  LogSink m_logInstance;
	  ConnectionBase* m_connection;      /**< The transport connection. */
	  bool m_block;                      /**< Whether blocking connection is wanted. */

	  std::string m_senddata;


   };

}
