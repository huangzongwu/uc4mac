/*
  Copyright (c) 2004-2011 by Hao Jing <haojingus@gmail.com>
  This file is part of gloox's extension. http://camaya.net/gloox

  This software is distributed under a license. The full license
  agreement can be found in the file LICENSE in this distribution.
  This software may not be copied, modified, sold or distributed
  other than expressed in the named license agreement.

  This software is distributed without any warranty.
*/



#ifndef VIKAHANDLER_H__
#define VIKAHANDLER_H__

#include "gloox.h"
#include "vika.h"
#include <string>

namespace gloox
{

	class JID;


	/**
	* @brief A virtual interface which can be reimplemented to receive debug and log messages.
	*
	* @ref handleVika() is called for log messages.
	*
	* @author Hao Jing <haojingus@gmail.com>
	* @since 1.0
	*/
	class GLOOX_API VikaHandler
	{
	public:
	  /**
	   * Virtual Destructor.
	   */
	  virtual ~VikaHandler() {}

	  //reimplemented from VikaHandler
	  virtual void handleVikaGroup(const JID& jid,VikaGroupOperation type,const JID& applyjid,const std::string& reason) = 0;

	  // reimplemented from VikaHandler
	  virtual void handleVikaFindUser(const JID& jid,const std::string& nick,const bool online) = 0;

	  // reimplemented from VikaHandler
	  virtual void handleVikaPrivacy(const std::string s) = 0;

	};

}

#endif // LOGHANDLER_H__
