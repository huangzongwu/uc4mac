/*
  Copyright (c) 2005-2009 by Hao jing <haojingus@163.com>
  This file is part of the gloox library. http://camaya.net/gloox

  This software is distributed under a license. The full license
  agreement can be found in the file LICENSE in this distribution.
  This software may not be copied, modified, sold or distributed
  other than expressed in the named license agreement.

  This software is distributed without any warranty.
*/


#include "config.h"

#include "httpbase.h"
#include "connectionbase.h"
#include "compressionbase.h"
#include "connectiontcpclient.h"
#include "connectionlistener.h"
#include "loghandler.h"
#include "base64.h"
#include "error.h"
#include "md5.h"
#include "util.h"
#include "eventhandler.h"
#include "event.h"
#include "compressionzlib.h"

#include <cstdlib>
#include <string>
#include <map>
#include <list>
#include <algorithm>
#include <cmath>
#include <ctime>
#include <cstdio>

#include <string.h> // for memset()
#include <stdlib.h> // for atoi

#if defined( _WIN32 ) && !defined( __SYMBIAN32__ )
#include <tchar.h>
#endif

#define HTTP_PORT 80

namespace gloox
{
	HTTPBase::HTTPBase(const std::string& url, const HTTPMethod method,const std::string& webdata)
		:m_compressionActive(false),m_method(method),m_port(HTTP_PORT),m_server(""),m_request(""),
		m_connection(0),m_compression(0)
	{
		init(url);
	}

	HTTPBase::~HTTPBase()
	{

	}

	bool HTTPBase::connect(bool block /* = true */)
	{
		if( m_server.empty() )
			return false;

		if( !m_connection )
			m_connection = new ConnectionTCPClient( this, m_logInstance, m_server, m_port );

		if( m_connection->state() >= StateConnecting )
			return true;

		/*
		if( !m_compression )
			m_compression = getDefaultCompression();
			*/

		m_logInstance.dbg( LogAreaClassClientbase, "This is gloox " + GLOOX_VERSION + ", connecting to http server "
			+ m_server + ":" + util::int2string( m_port ) + "..." );
		m_block = block;
		ConnectionError ret = m_connection->connect();
		if( ret != ConnNoError )
			return false;

		if( m_block )
			m_connection->receive();

		return true;
	}

	ConnectionError HTTPBase::recv( int timeout /* = -1 */ )
	{
		if( !m_connection || m_connection->state() == StateDisconnected )
			return ConnNotConnected;

		return m_connection->recv( timeout );
	}

	void HTTPBase::init(const std::string& url)
	{
		m_server	= "data.3g.sina.com.cn";
		m_port	= 80;
		std::string m_host;
		int m_size	= url.size();

		if(m_size<9)
			return;// url size error

		if(url.substr(0,7)!="http://")
			return;// url format error
		int m_pos	= 0 ;

		if((m_pos	= url.find('/',8))==std::string::npos)
		{
			m_host	= url.substr(7,m_size-7);
			m_request = "";
			//if(m_server.find(':')!=std::string)
		}
		else
		{
			m_host	= url.substr(7,m_pos-7);
			m_request	= url.substr(m_pos,m_size-m_pos);

		}
		m_pos	= 0;
		if((m_pos	= m_host.find(':'))!=std::string::npos)
		{
			m_server	= m_host.substr(0,m_pos);
			m_port	= atoi(m_host.substr(m_pos+1,m_host.size()-m_pos-1).c_str());
		}
		else
		{
			m_server	= m_host;
			m_port	= 80;
		}


	}

	void HTTPBase::setCompression( CompressionBase* cb )
	{
		if( m_compression )
		{
			delete m_compression;
		}
		m_compression = cb;
	}

	void HTTPBase::send(const std::string webdata)
	{
		this->connect();
		this->m_senddata	= webdata;
	}

	void HTTPBase::handleConnect( const ConnectionBase* connection )
	{
		//m_connection->send(m_senddata);
		char ptr_header[256];
		memset(ptr_header,0,256);
		strcat(ptr_header,"GET ");
		strcat(ptr_header,m_request.c_str());
		strcat(ptr_header," HTTP/1.1\nAccept: text/html, application/xml, */*\nAccept-Language: zh-cn\nHost: ");
		strcat(ptr_header,m_server.c_str());
		
		strcat(ptr_header,":");
		char ptr_port[5];
		sprintf(ptr_port,"%d",m_port);
		strcat(ptr_header,ptr_port);
		strcat(ptr_header,"\nConnection: Keep-Alive\n\n");

		//m_connection->send("GET /api/index.php?wm=b122&cid=24&version=2 HTTP/1.1\nAccept: text/html, application/xml, */*\nAccept-Language: zh-cn\nHost: data.3g.sina.com.cn:80\nConnection: Keep-Alive\n\n");
		m_connection->send(std::string(ptr_header));

		//m_connection->send("GET /serverguard/Send.php?user=wangxin&password=wangxin&msg=hello HTTP/1.1\nAccept: text/html, application/xml, */*\nAccept-Language: zh-cn\nHost: 202.108.35.62:80\nConnection: Keep-Alive\n\n");
		
		this->recv();
		
	}

	void HTTPBase::handleDisconnect( const ConnectionBase* connection, ConnectionError reason )
	{
		if( m_connection )
			m_connection->cleanup();

		if( m_compression )
			m_compression->cleanup();

//		m_compressionActive = false;
	}

	void HTTPBase::handleReceivedData( const ConnectionBase* connection, const std::string& data )
	{
		/*
		if( m_compression && m_compressionActive )
			m_compression->decompress( data );
		else
		
			parse( data );
			*/
		printf("\nData:%s\n",data.c_str());
	}





		
}