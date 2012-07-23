/*
  Copyright (c) 2004-2011 by Hao Jing <haojingus@gmail.com>
  This file is part of gloox's extension. http://camaya.net/gloox

  This software is distributed under a license. The full license
  agreement can be found in the file LICENSE in this distribution.
  This software may not be copied, modified, sold or distributed
  other than expressed in the named license agreement.

  This software is distributed without any warranty.
*/



#ifndef LOCATIONHANDLER_H__
#define LOCATIONHANDLER_H__

#include "gloox.h"
#include "jid.h"
#include <string>

namespace gloox
{



	/**
	* @brief A virtual interface which can be reimplemented to receive debug and log messages.
	*
	* @ref handleVika() is called for log messages.
	*
	* @author Hao Jing <haojingus@gmail.com>
	* @since 1.0
	*/
	class GLOOX_API LocationHandler
	{
//	  class JID;

	  public:
		  /**
		   * Virtual Destructor.
		   */
		  virtual ~LocationHandler() {}

		  //reimplemented from LocationHandler
		  virtual void handleLocationRequest(const JID& jid) = 0;

		  //reimplemented from LocationHandler
		  virtual void handleLocationStopResponse(const JID& jid) = 0;

		  /**
		   * reimplemented from LocationHandler
		   * those parameter without const could only be used after modification,
		   * as its GPS coordinates has been deviated by local governments
		   * @param longitude is the original longitude
		   * @param latitude is the original latitude
		   */
		  virtual void handleLocationResponse(const JID& jid, std::string longitude, std::string latitude,std::string address) = 0;
	};

}

#endif // LOGHANDLER_H__
